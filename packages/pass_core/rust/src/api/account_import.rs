mod apple;
use crate::authenticator_import;

use super::content::{bounded, new_id};
use super::{CardTypeV1, CardValueV1, ContentSnapshotV2, Vault, VaultFailure};
use std::collections::BTreeSet;
use zeroize::{Zeroize, ZeroizeOnDrop, Zeroizing};

#[derive(Clone, Copy)]
pub enum AccountImportSourceV1 {
    ApplePasswords,
    Authenticator,
}
pub struct AccountImportPreviewV1 {
    pub token: String,
    pub rows: Vec<AccountImportRowV1>,
}
pub struct AccountImportRowV1 {
    pub name: String,
    pub duplicate: bool,
}

pub(crate) const MAX_ROWS: usize = 4096;
const MAX_BYTES: usize = 4 * 1024 * 1024;
pub(crate) const MAX_PARTS: usize = 64;

#[derive(Zeroize, ZeroizeOnDrop)]
pub(crate) struct ImportRow {
    pub(crate) name: String,
    pub(crate) notes: String,
    pub(crate) url: Option<String>,
    #[zeroize(skip)]
    pub(crate) kind: CardTypeV1,
    pub(crate) fields: Vec<CardValueV1>,
}

pub(super) struct PendingImport {
    token: String,
    revision: u64,
    generation: u64,
    rows: Vec<ImportRow>,
}

impl Vault {
    pub fn prepare_account_import_v1(
        &self,
        source: AccountImportSourceV1,
        payloads: Vec<String>,
        revision: u64,
        generation: u64,
    ) -> Result<AccountImportPreviewV1, VaultFailure> {
        let payloads = Zeroizing::new(payloads);
        {
            let state = self.state.lock().map_err(|_| VaultFailure::Unavailable)?;
            if self.generation() != generation {
                return Err(VaultFailure::Stale);
            }
            if state.active.is_none() {
                return Err(VaultFailure::Locked);
            }
        }
        if payloads.len() > MAX_PARTS
            || payloads
                .iter()
                .try_fold(0usize, |sum, p| sum.checked_add(p.len()))
                .is_none_or(|n| n > MAX_BYTES)
        {
            return Err(VaultFailure::Unsupported);
        }
        let rows = match source {
            AccountImportSourceV1::ApplePasswords if payloads.len() == 1 => {
                apple::parse(&payloads[0])?
            }
            AccountImportSourceV1::Authenticator => authenticator_import::parse(&payloads)?,
            _ => return Err(VaultFailure::Unsupported),
        };
        if rows.is_empty() || rows.len() > MAX_ROWS {
            return Err(VaultFailure::Unsupported);
        }
        for row in &rows {
            bounded(&row.name, 512, true)?;
            bounded(&row.notes, 16384, false)?;
            super::presets::validate_fields(row.kind, &row.fields)?;
        }
        let preview = self.compare_import_rows(&rows, revision, generation)?;
        let token = new_id()?;
        let mut state = self.state.lock().map_err(|_| VaultFailure::Unavailable)?;
        if self.generation() != generation || state.active.is_none() {
            return Err(VaultFailure::Stale);
        }
        state.account_import = Some(PendingImport {
            token: token.clone(),
            revision,
            generation,
            rows,
        });
        Ok(AccountImportPreviewV1 {
            token,
            rows: preview,
        })
    }

    pub fn cancel_account_import_v1(
        &self,
        token: String,
        generation: u64,
    ) -> Result<(), VaultFailure> {
        let mut state = self.state.lock().map_err(|_| VaultFailure::Unavailable)?;
        if self.generation() != generation
            || state
                .account_import
                .as_ref()
                .is_none_or(|p| p.token != token)
        {
            return Err(VaultFailure::Stale);
        }
        state.account_import = None;
        Ok(())
    }

    pub fn apply_account_import_v1(
        &self,
        token: String,
        selected: Vec<u32>,
        generation: u64,
    ) -> Result<ContentSnapshotV2, VaultFailure> {
        let pending = {
            let mut state = self.state.lock().map_err(|_| VaultFailure::Unavailable)?;
            let p = state.account_import.as_ref().ok_or(VaultFailure::Stale)?;
            if p.token != token
                || p.generation != generation
                || self.generation() != generation
                || state.active.is_none()
            {
                return Err(VaultFailure::Stale);
            }
            state.account_import.take().ok_or(VaultFailure::Stale)?
        };
        let indexes: BTreeSet<_> = selected.iter().map(|v| *v as usize).collect();
        if indexes.len() != selected.len()
            || indexes.last().is_some_and(|i| *i >= pending.rows.len())
        {
            return Err(VaultFailure::Unsupported);
        }
        if indexes.is_empty() {
            let snapshot = self.content_v2(generation)?;
            return if snapshot.revision == pending.revision {
                Ok(snapshot)
            } else {
                Err(VaultFailure::Stale)
            };
        }
        let rows = pending
            .rows
            .into_iter()
            .enumerate()
            .filter_map(|(i, row)| indexes.contains(&i).then_some(row))
            .collect();
        self.insert_import_rows(rows, pending.revision, generation)
    }
}
