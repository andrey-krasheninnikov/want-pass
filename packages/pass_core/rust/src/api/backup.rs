use super::{Vault, VaultFailure, cards, phrase::parse_phrase, policy::OperationV1};
use crate::{backup_crypto, storage::digest};
use bip39::{Language, Mnemonic};
use serde::{Deserialize, Serialize};
use std::{
    fs,
    io::{Read, Write},
    path::Path,
};
use zeroize::Zeroizing;

mod merge;
use merge::Portable;

#[derive(Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum BackupStrategyV1 {
    Replace,
    Merge,
}
#[derive(Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum BackupResolutionV1 {
    Local,
    Incoming,
    Both,
}
#[derive(Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Serialize, Deserialize)]
pub enum BackupEntityV1 {
    Group,
    Service,
    Template,
    Card,
    History,
}
#[derive(Clone, Serialize)]
pub struct BackupChoiceV1 {
    pub entity: BackupEntityV1,
    pub id: String,
    pub resolution: BackupResolutionV1,
}
pub struct BackupConflictV1 {
    pub entity: BackupEntityV1,
    pub id: String,
    pub local_name: String,
    pub incoming_name: String,
    pub resolution: Option<BackupResolutionV1>,
}
pub struct BackupPreviewV1 {
    pub revision: u64,
    pub fingerprint: String,
    pub added: u32,
    pub changed: u32,
    pub removed: u32,
    pub identical_count: u32,
    pub conflicts: Vec<BackupConflictV1>,
}

fn archive_file(path: &Path) -> Result<Vec<u8>, VaultFailure> {
    let mut options = fs::OpenOptions::new();
    options.read(true);
    #[cfg(unix)]
    {
        use std::os::unix::fs::OpenOptionsExt;
        options.custom_flags(libc::O_NOFOLLOW | libc::O_NONBLOCK);
    }
    let file = options.open(path).map_err(|_| VaultFailure::Storage)?;
    let stat = file.metadata().map_err(|_| VaultFailure::Storage)?;
    if !stat.is_file() || stat.len() > backup_crypto::MAX_ARCHIVE as u64 {
        return Err(VaultFailure::Unsupported);
    }
    let mut bytes = Vec::with_capacity(stat.len() as usize);
    file.take(backup_crypto::MAX_ARCHIVE as u64 + 1)
        .read_to_end(&mut bytes)
        .map_err(|_| VaultFailure::Storage)?;
    if bytes.len() > backup_crypto::MAX_ARCHIVE {
        return Err(VaultFailure::Unsupported);
    }
    Ok(bytes)
}

fn incoming(source: &str, phrase: String) -> Result<(Portable, [u8; 32], [u8; 16]), VaultFailure> {
    let phrase = parse_phrase(&Zeroizing::new(phrase))?;
    let words =
        Mnemonic::parse_in(Language::English, &*phrase).map_err(|_| VaultFailure::InvalidPhrase)?;
    let ciphertext = archive_file(Path::new(source))?;
    let clear = backup_crypto::open(&ciphertext, &Zeroizing::new(words.to_entropy()))?;
    let portable = Portable::from_archive(&clear)?;
    let id = ciphertext[8..24]
        .try_into()
        .map_err(|_| VaultFailure::Corrupt)?;
    Ok((portable, digest(&ciphertext), id))
}

impl Vault {
    pub fn export_backup_v1(
        &self,
        destination: String,
        revision: u64,
        generation: u64,
    ) -> Result<(), VaultFailure> {
        let policy = self.protection_settings_v1(generation)?;
        let operation = if policy.operations.contains(&OperationV1::RecoveryKit) {
            OperationV1::RecoveryKit
        } else {
            OperationV1::Export
        };
        self.require_operation(operation, &destination, generation)?;
        let (document, id, recipient, root) = {
            let state = self.state.lock().map_err(|_| VaultFailure::Unavailable)?;
            if state.closed || self.generation() != generation {
                return Err(VaultFailure::Stale);
            }
            let active = state.active.as_ref().ok_or(VaultFailure::Locked)?;
            (
                active.document.clone(),
                active.id,
                active.backup_recipient.ok_or(VaultFailure::Unsupported)?,
                state.store.directory().to_path_buf(),
            )
        };
        let portable = Portable::from_live(&document)?;
        if portable.revision != revision {
            return Err(VaultFailure::Stale);
        }
        let ciphertext = backup_crypto::seal(&portable.encode()?, &id, &recipient)?;
        let path = Path::new(&destination);
        if !path.is_absolute() || path.extension().and_then(|s| s.to_str()) != Some("wpassbackup") {
            return Err(VaultFailure::Storage);
        }
        let selected = path.parent().ok_or(VaultFailure::Storage)?;
        if !fs::symlink_metadata(selected)
            .map_err(|_| VaultFailure::Storage)?
            .is_dir()
        {
            return Err(VaultFailure::Storage);
        }
        let directory = selected.canonicalize().map_err(|_| VaultFailure::Storage)?;
        let parent = fs::File::open(&directory).map_err(|_| VaultFailure::Storage)?;
        if directory.starts_with(root.canonicalize().map_err(|_| VaultFailure::Storage)?) {
            return Err(VaultFailure::Storage);
        }
        let path = directory.join(path.file_name().ok_or(VaultFailure::Storage)?);
        match path.symlink_metadata() {
            Err(err) if err.kind() == std::io::ErrorKind::NotFound => {}
            _ => return Err(VaultFailure::Storage),
        }
        let mut staged =
            tempfile::NamedTempFile::new_in(&directory).map_err(|_| VaultFailure::Storage)?;
        staged
            .write_all(&ciphertext)
            .and_then(|()| staged.as_file().sync_all())
            .map_err(|_| VaultFailure::Storage)?;
        let _publication = self
            .export_publication
            .lock()
            .map_err(|_| VaultFailure::Unavailable)?;
        self.backup_current(&document, generation)?;
        #[cfg(unix)]
        {
            use std::os::unix::fs::MetadataExt;
            let before = parent.metadata().map_err(|_| VaultFailure::Storage)?;
            let current = fs::symlink_metadata(selected).map_err(|_| VaultFailure::Storage)?;
            if !current.is_dir() || current.dev() != before.dev() || current.ino() != before.ino() {
                return Err(VaultFailure::Storage);
            }
        }
        staged
            .persist_noclobber(path)
            .map_err(|_| VaultFailure::Storage)?;
        parent.sync_all().map_err(|_| VaultFailure::WriteUncertain)
    }

    fn backup_current(&self, document: &[u8], generation: u64) -> Result<(), VaultFailure> {
        let state = self.state.lock().map_err(|_| VaultFailure::Unavailable)?;
        if state.closed || self.generation() != generation {
            return Err(VaultFailure::Stale);
        }
        if state
            .active
            .as_ref()
            .ok_or(VaultFailure::Locked)?
            .document
            .as_slice()
            != document
        {
            return Err(VaultFailure::Stale);
        }
        Ok(())
    }

    pub fn preview_backup_v1(
        &self,
        source: String,
        phrase: String,
        strategy: BackupStrategyV1,
        choices: Vec<BackupChoiceV1>,
        generation: u64,
    ) -> Result<BackupPreviewV1, VaultFailure> {
        let document = {
            let state = self.state.lock().map_err(|_| VaultFailure::Unavailable)?;
            if state.closed || self.generation() != generation {
                return Err(VaultFailure::Stale);
            }
            state
                .active
                .as_ref()
                .ok_or(VaultFailure::Locked)?
                .document
                .clone()
        };
        let (source, hash, id) = incoming(&source, phrase)?;
        let mut target = Portable::from_live(&document)?;
        let mut report = target.restore(source, id, hash, strategy, choices)?;
        let projection = target.project_live(&document, strategy)?;
        report.removed += projection.removed_profiles;
        if report.conflicts.iter().all(|c| c.resolution.is_some()) {
            projection.encode(target.revision)?;
        }
        self.backup_current(&document, generation)?;
        Ok(report)
    }

    #[expect(
        clippy::too_many_arguments,
        reason = "The bridge passes the reviewed source, choices and session explicitly."
    )]
    pub fn apply_backup_v1(
        &self,
        source: String,
        phrase: String,
        strategy: BackupStrategyV1,
        choices: Vec<BackupChoiceV1>,
        revision: u64,
        fingerprint: String,
        generation: u64,
    ) -> Result<(), VaultFailure> {
        let op = match strategy {
            BackupStrategyV1::Replace => OperationV1::Delete,
            BackupStrategyV1::Merge => OperationV1::Protection,
        };
        self.require_operation(op, &fingerprint, generation)?;
        let (source, hash, id) = incoming(&source, phrase)?;
        self.update_document_scoped(generation, |document| {
            let mut target = Portable::from_live(document)?;
            if target.revision != revision {
                return Err(VaultFailure::Stale);
            }
            let report = target.restore(source, id, hash, strategy, choices)?;
            if report.fingerprint != fingerprint {
                return Err(VaultFailure::Stale);
            }
            if report.conflicts.iter().any(|c| c.resolution.is_none()) {
                return Err(VaultFailure::Confirmation);
            }
            let projection = target.project_live(document, strategy)?;
            if report.added == 0
                && report.changed == 0
                && report.removed == 0
                && projection.removed_profiles == 0
            {
                return Ok((Zeroizing::new(document.to_vec()), (), true));
            }
            let next = revision.checked_add(1).ok_or(VaultFailure::Unsupported)?;
            Ok((projection.encode(next)?, (), true))
        })
    }
}
