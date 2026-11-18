use super::Store;
use crate::api::VaultFailure;
use serde::{Deserialize, Serialize};
use std::fs::{self, File, OpenOptions};
use std::io::{Read, Write};
use std::os::unix::fs::{MetadataExt, OpenOptionsExt};
use std::path::{Path, PathBuf};

const MARKER: &str = "reset.pending";

#[derive(Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
struct Fingerprint {
    device: u64,
    inode: u64,
    length: u64,
    mtime: i64,
    nanos: i64,
}

#[derive(Serialize, Deserialize)]
pub(crate) struct ResetV1 {
    version: u8,
    files: [Option<Fingerprint>; 3],
}

#[allow(unsafe_code)]
pub(super) fn owner() -> u32 {
    // SAFETY: geteuid reads the caller's effective identity and takes no arguments.
    unsafe { libc::geteuid() }
}

fn validate_absolute(path: &Path) -> Result<(), VaultFailure> {
    if !path.is_absolute()
        || path
            .components()
            .any(|part| part == std::path::Component::ParentDir)
    {
        return Err(VaultFailure::Storage);
    }
    Ok(())
}

fn validate_root(path: &Path) -> Result<(), VaultFailure> {
    validate_absolute(path)?;
    for parent in path.ancestors() {
        if !fs::symlink_metadata(parent)
            .map_err(|_| VaultFailure::Storage)?
            .is_dir()
        {
            return Err(VaultFailure::Storage);
        }
    }
    if fs::symlink_metadata(path)
        .map_err(|_| VaultFailure::Storage)?
        .uid()
        != owner()
    {
        return Err(VaultFailure::Storage);
    }
    Ok(())
}

fn fingerprint(path: &Path) -> Result<Option<Fingerprint>, VaultFailure> {
    let meta = match fs::symlink_metadata(path) {
        Ok(meta) => meta,
        Err(e) if e.kind() == std::io::ErrorKind::NotFound => return Ok(None),
        Err(_) => return Err(VaultFailure::Storage),
    };
    if !meta.is_file() || meta.uid() != owner() || meta.nlink() != 1 {
        return Err(VaultFailure::Storage);
    }
    Ok(Some(Fingerprint {
        device: meta.dev(),
        inode: meta.ino(),
        length: meta.len(),
        mtime: meta.mtime(),
        nanos: meta.mtime_nsec(),
    }))
}

fn sync_directory(path: &Path) -> Result<(), VaultFailure> {
    File::open(path)
        .and_then(|file| file.sync_all())
        .map_err(|_| VaultFailure::WriteUncertain)
}

impl Store {
    pub(super) fn marker(&self) -> PathBuf {
        self.directory.join(MARKER)
    }

    pub fn open_application(root: &Path) -> Result<Self, VaultFailure> {
        validate_absolute(root)?;
        // The app support directory may not exist on first launch.
        // Check existing ancestors before creating anything.
        for parent in root.ancestors() {
            match fs::symlink_metadata(parent) {
                Ok(meta) if !meta.is_dir() => return Err(VaultFailure::Storage),
                Ok(_) => (),
                Err(e) if e.kind() == std::io::ErrorKind::NotFound => (),
                Err(_) => return Err(VaultFailure::Storage),
            }
        }
        let mut store = Self::open_locked(&root.join("vault"))?;
        validate_root(root)?;
        store.application = true;
        store.resume_reset()?;
        Ok(store)
    }

    fn reset_targets(&self) -> Result<[PathBuf; 3], VaultFailure> {
        if !self.application {
            return Err(VaultFailure::Unsupported);
        }
        let root = self.directory.parent().ok_or(VaultFailure::Storage)?;
        validate_root(root)?;
        validate_root(&self.directory)?;
        Ok([
            self.directory.join("vault.wpass"),
            root.join("appearance.json"),
            root.join("appearance.tmp"),
        ])
    }

    pub fn plan_reset(&self) -> Result<ResetV1, VaultFailure> {
        let [vault, settings, temporary] = self.reset_targets()?;
        let vault = fingerprint(&vault)?.ok_or(VaultFailure::Missing)?;
        if fingerprint(&self.marker())?.is_some() {
            return Err(VaultFailure::WriteUncertain);
        }
        Ok(ResetV1 {
            version: 1,
            files: [
                Some(vault),
                fingerprint(&settings)?,
                fingerprint(&temporary)?,
            ],
        })
    }

    fn verify_reset(&self, plan: &ResetV1) -> Result<(), VaultFailure> {
        if plan.version != 1 || plan.files[0].is_none() {
            return Err(VaultFailure::Corrupt);
        }
        for (path, expected) in self.reset_targets()?.iter().zip(plan.files) {
            if let Some(current) = fingerprint(path)?
                && Some(current) != expected
            {
                return Err(VaultFailure::Stale);
            }
        }
        Ok(())
    }

    fn publish_reset(&self, plan: &ResetV1) -> Result<(), VaultFailure> {
        self.verify_reset(plan)?;
        let bytes = serde_json::to_vec(plan).map_err(|_| VaultFailure::Storage)?;
        let mut temporary =
            tempfile::NamedTempFile::new_in(&self.directory).map_err(|_| VaultFailure::Storage)?;
        temporary
            .write_all(&bytes)
            .and_then(|()| temporary.as_file().sync_all())
            .map_err(|_| VaultFailure::Storage)?;
        temporary
            .persist_noclobber(self.marker())
            .map_err(|_| VaultFailure::WriteUncertain)?;
        sync_directory(&self.directory)
    }

    fn finish_reset(&self, plan: &ResetV1) -> Result<(), VaultFailure> {
        self.verify_reset(plan)?;
        for (path, expected) in self.reset_targets()?.iter().zip(plan.files) {
            if let Some(current) = fingerprint(path)? {
                if Some(current) != expected {
                    return Err(VaultFailure::Stale);
                }
                fs::remove_file(path).map_err(|_| VaultFailure::Storage)?;
            }
        }
        sync_directory(&self.directory)?;
        sync_directory(self.directory.parent().ok_or(VaultFailure::Storage)?)?;
        fs::remove_file(self.marker()).map_err(|_| VaultFailure::Storage)?;
        sync_directory(&self.directory)
    }

    pub fn reset_application(&self, plan: &ResetV1) -> Result<(), VaultFailure> {
        self.reset_pending
            .store(true, std::sync::atomic::Ordering::SeqCst);
        self.publish_reset(plan)
            .and_then(|()| self.finish_reset(plan))
            .map_err(|_| VaultFailure::WriteUncertain)?;
        self.reset_pending
            .store(false, std::sync::atomic::Ordering::SeqCst);
        Ok(())
    }

    fn resume_reset(&self) -> Result<(), VaultFailure> {
        let marker = self.marker();
        let Some(info) = fingerprint(&marker)? else {
            return Ok(());
        };
        const LIMIT: u64 = 4096;
        if info.length > LIMIT {
            return Err(VaultFailure::Corrupt);
        }
        let mut bytes = Vec::new();
        OpenOptions::new()
            .read(true)
            .custom_flags(libc::O_NOFOLLOW)
            .open(marker)
            .and_then(|file| file.take(LIMIT + 1).read_to_end(&mut bytes))
            .map_err(|_| VaultFailure::Storage)?;
        let plan: ResetV1 = serde_json::from_slice(&bytes).map_err(|_| VaultFailure::Corrupt)?;
        self.finish_reset(&plan)
            .map_err(|_| VaultFailure::WriteUncertain)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn resume_finishes_only_the_admitted_reset() {
        let tmp = tempfile::tempdir().unwrap();
        let root = tmp.path().canonicalize().unwrap();
        let store = Store::open_application(&root).unwrap();
        fs::write(store.directory.join("vault.wpass"), b"fixture vault").unwrap();
        fs::write(root.join("appearance.json"), b"fixture preferences").unwrap();
        fs::write(root.join("user-export.json"), b"fixture export").unwrap();
        let plan = store.plan_reset().unwrap();
        store.publish_reset(&plan).unwrap();
        fs::remove_file(store.directory.join("vault.wpass")).unwrap();
        drop(store);
        let store = Store::open_application(&root).unwrap();
        assert!(!root.join("appearance.json").exists());
        assert!(!store.marker().exists());
        assert!(root.join("user-export.json").exists());
        assert!(store.directory.join("vault.lock").exists());
    }

    #[test]
    fn resume_rejects_replaced_files_before_removing_any_target() {
        let tmp = tempfile::tempdir().unwrap();
        let root = tmp.path().canonicalize().unwrap();
        let store = Store::open_application(&root).unwrap();
        fs::write(store.directory.join("vault.wpass"), b"fixture vault").unwrap();
        fs::write(root.join("appearance.json"), b"old preferences").unwrap();
        let plan = store.plan_reset().unwrap();
        store.publish_reset(&plan).unwrap();
        fs::write(root.join("appearance.json"), b"replacement preferences").unwrap();
        drop(store);
        assert!(matches!(
            Store::open_application(&root),
            Err(VaultFailure::WriteUncertain)
        ));
        assert!(root.join("vault/vault.wpass").exists());
        assert_eq!(
            fs::read(root.join("appearance.json")).unwrap(),
            b"replacement preferences"
        );
    }
}
