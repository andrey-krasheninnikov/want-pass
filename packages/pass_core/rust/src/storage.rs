use crate::{api::VaultFailure, format::MAX_FILE};
use sha2::{Digest, Sha256};
use std::os::unix::fs::{DirBuilderExt, OpenOptionsExt, PermissionsExt};
use std::{
    fs::{self, File, OpenOptions},
    io::{Read, Write},
    path::{Path, PathBuf},
};

pub struct Store {
    directory: PathBuf,
    lock: File,
}

#[derive(Clone, Copy, PartialEq, Eq)]
enum CommitStage {
    Flushed,
    Published,
}

impl Store {
    pub fn open(directory: &Path) -> Result<Self, VaultFailure> {
        fs::DirBuilder::new()
            .recursive(true)
            .mode(0o700)
            .create(directory)
            .map_err(|_| VaultFailure::Storage)?;
        let metadata = fs::symlink_metadata(directory).map_err(|_| VaultFailure::Storage)?;
        if !metadata.is_dir()
            || metadata.file_type().is_symlink()
            || metadata.permissions().mode() & 0o777 != 0o700
        {
            return Err(VaultFailure::Storage);
        }
        let lock = OpenOptions::new()
            .read(true)
            .write(true)
            .create(true)
            .truncate(false)
            .mode(0o600)
            .custom_flags(libc::O_NOFOLLOW)
            .open(directory.join("vault.lock"))
            .map_err(|_| VaultFailure::Storage)?;
        lock.try_lock().map_err(|error| match error {
            fs::TryLockError::WouldBlock => VaultFailure::Busy,
            fs::TryLockError::Error(_) => VaultFailure::Storage,
        })?;
        Ok(Self {
            directory: directory.to_owned(),
            lock,
        })
    }
    pub fn read(&self) -> Result<Option<Vec<u8>>, VaultFailure> {
        let file = match OpenOptions::new()
            .read(true)
            .custom_flags(libc::O_NOFOLLOW)
            .open(self.directory.join("vault.wpass"))
        {
            Ok(file) => file,
            Err(error) if error.kind() == std::io::ErrorKind::NotFound => return Ok(None),
            Err(_) => return Err(VaultFailure::Storage),
        };
        let metadata = file.metadata().map_err(|_| VaultFailure::Storage)?;
        if !metadata.is_file() || metadata.len() > MAX_FILE as u64 {
            return Err(VaultFailure::Corrupt);
        }
        let mut bytes = Vec::new();
        file.take(MAX_FILE as u64 + 1)
            .read_to_end(&mut bytes)
            .map_err(|_| VaultFailure::Storage)?;
        if bytes.len() > MAX_FILE {
            return Err(VaultFailure::Corrupt);
        }
        Ok(Some(bytes))
    }
    pub fn commit(&self, bytes: &[u8], expected: Option<[u8; 32]>) -> Result<(), VaultFailure> {
        self.commit_with_hook(bytes, expected, |_| Ok(()))
    }
    fn commit_with_hook(
        &self,
        bytes: &[u8],
        expected: Option<[u8; 32]>,
        mut checkpoint: impl FnMut(CommitStage) -> Result<(), VaultFailure>,
    ) -> Result<(), VaultFailure> {
        let current = self.read()?;
        if current.as_deref() == Some(bytes) {
            return File::open(&self.directory)
                .and_then(|f| f.sync_all())
                .map_err(|_| VaultFailure::WriteUncertain);
        }
        if current.as_deref().map(digest) != expected {
            return Err(VaultFailure::Stale);
        }
        let mut temporary =
            tempfile::NamedTempFile::new_in(&self.directory).map_err(|_| VaultFailure::Storage)?;
        temporary
            .write_all(bytes)
            .and_then(|()| temporary.as_file().sync_all())
            .map_err(|_| VaultFailure::Storage)?;
        checkpoint(CommitStage::Flushed)?;
        let destination = self.directory.join("vault.wpass");
        if expected.is_none() {
            temporary
                .persist_noclobber(destination)
                .map_err(|_| VaultFailure::WriteUncertain)?;
        } else {
            temporary
                .persist(destination)
                .map_err(|_| VaultFailure::WriteUncertain)?;
        }
        checkpoint(CommitStage::Published)?;
        File::open(&self.directory)
            .and_then(|f| f.sync_all())
            .map_err(|_| VaultFailure::WriteUncertain)
    }
    pub fn close(&self) -> Result<(), VaultFailure> {
        self.lock.unlock().map_err(|_| VaultFailure::Storage)
    }
}

pub fn digest(bytes: &[u8]) -> [u8; 32] {
    Sha256::digest(bytes).into()
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::format;

    const PASSWORD: &str = "Synthetic interrupted-write password 2026";

    #[test]
    fn uncertain_publish_reconciles_without_rewriting() {
        use std::os::unix::fs::MetadataExt;
        let temporary = tempfile::tempdir().unwrap();
        let path = temporary.path().join("vault");
        let store = Store::open(&path).unwrap();
        let old = b"old synthetic ciphertext";
        let candidate = b"new synthetic ciphertext";
        store.commit(old, None).unwrap();
        assert_eq!(
            store.commit_with_hook(candidate, Some(digest(old)), |point| {
                if point == CommitStage::Published {
                    Err(VaultFailure::WriteUncertain)
                } else {
                    Ok(())
                }
            }),
            Err(VaultFailure::WriteUncertain)
        );
        let inode = fs::metadata(path.join("vault.wpass")).unwrap().ino();
        store.commit(candidate, Some(digest(old))).unwrap();
        assert_eq!(fs::metadata(path.join("vault.wpass")).unwrap().ino(), inode);
        assert_eq!(store.read().unwrap().unwrap(), candidate);
        assert_eq!(
            store.commit(b"unrelated ciphertext", Some(digest(old))),
            Err(VaultFailure::Stale)
        );
        assert_eq!(store.read().unwrap().unwrap(), candidate);
    }

    #[test]
    fn storage_refuses_competing_owners_symlinks_and_oversized_files() {
        use std::os::unix::fs::symlink;
        let temporary = tempfile::tempdir().unwrap();
        let path = temporary.path().join("vault");
        let store = Store::open(&path).unwrap();
        assert!(matches!(Store::open(&path), Err(VaultFailure::Busy)));
        let outside = temporary.path().join("outside");
        fs::write(&outside, b"synthetic outside data").unwrap();
        symlink(&outside, path.join("vault.wpass")).unwrap();
        assert_eq!(store.read(), Err(VaultFailure::Storage));
        assert_eq!(store.commit(b"candidate", None), Err(VaultFailure::Storage));
        assert_eq!(fs::read(&outside).unwrap(), b"synthetic outside data");
        fs::remove_file(path.join("vault.wpass")).unwrap();
        File::create(path.join("vault.wpass"))
            .unwrap()
            .set_len(MAX_FILE as u64 + 1)
            .unwrap();
        assert_eq!(store.read(), Err(VaultFailure::Corrupt));
        drop(store);
        let alias = temporary.path().join("alias");
        symlink(&path, &alias).unwrap();
        assert!(matches!(Store::open(&alias), Err(VaultFailure::Storage)));
    }

    #[test]
    fn interrupted_child() {
        let Ok(stage) = std::env::var("WANT_PASS_TEST_INTERRUPT_STAGE") else {
            return;
        };
        let directory = PathBuf::from(std::env::var("WANT_PASS_TEST_DIRECTORY").unwrap());
        let candidate = fs::read(directory.join("candidate.fixture")).unwrap();
        let store = Store::open(&directory.join("vault")).unwrap();
        let baseline = store.read().unwrap().unwrap();
        store
            .commit_with_hook(&candidate, Some(digest(&baseline)), |point| {
                if (stage == "flushed" && point == CommitStage::Flushed)
                    || (stage == "published" && point == CommitStage::Published)
                {
                    std::process::exit(77);
                }
                Ok(())
            })
            .unwrap();
        panic!("the requested interruption was not reached");
    }

    #[test]
    fn interruption_keeps_one_complete_authenticated_version() {
        let baseline = format::prepare(PASSWORD, b"old synthetic document", None).unwrap();
        let candidate = format::prepare(
            PASSWORD,
            b"new synthetic document",
            Some(baseline.opened.id),
        )
        .unwrap();
        for stage in ["flushed", "published"] {
            let temporary = tempfile::tempdir().unwrap();
            let store = Store::open(&temporary.path().join("vault")).unwrap();
            store.commit(&baseline.bytes, None).unwrap();
            drop(store);
            fs::write(temporary.path().join("candidate.fixture"), &candidate.bytes).unwrap();
            let child = std::process::Command::new(std::env::current_exe().unwrap())
                .args([
                    "--exact",
                    "storage::tests::interrupted_child",
                    "--nocapture",
                ])
                .env("WANT_PASS_TEST_INTERRUPT_STAGE", stage)
                .env("WANT_PASS_TEST_DIRECTORY", temporary.path())
                .output()
                .unwrap();
            assert_eq!(child.status.code(), Some(77));
            let reopened = Store::open(&temporary.path().join("vault")).unwrap();
            let actual = reopened.read().unwrap().unwrap();
            let expected = if stage == "flushed" {
                &baseline.bytes
            } else {
                &candidate.bytes
            };
            assert_eq!(&actual, expected);
            assert!(format::open_password(&actual, PASSWORD).is_ok());
            assert_eq!(
                fs::metadata(temporary.path().join("vault/vault.wpass"))
                    .unwrap()
                    .permissions()
                    .mode()
                    & 0o777,
                0o600
            );
        }
    }
}
