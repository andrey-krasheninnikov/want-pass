use super::{Vault, VaultFailure};
use crate::{format, storage::digest};
use serde::{Deserialize, Serialize};
use std::collections::BTreeSet;
use zeroize::{Zeroize, ZeroizeOnDrop, Zeroizing};

pub struct GroupInputV1 {
    pub id: Option<String>,
    pub name: String,
    pub description: String,
    pub icon: String,
    pub logo: Vec<u8>,
}
pub struct GroupRecordV1 {
    pub id: String,
    pub name: String,
    pub description: String,
    pub icon: String,
    pub logo: Vec<u8>,
}
pub struct AccountInputV1 {
    pub id: Option<String>,
    pub name: String,
    pub description: String,
    pub login: String,
    pub password: String,
    pub group_ids: Vec<String>,
}
pub struct AccountRecordV1 {
    pub id: String,
    pub name: String,
    pub description: String,
    pub login: String,
    pub password: String,
    pub group_ids: Vec<String>,
}
pub struct AccountSummaryV1 {
    pub id: String,
    pub name: String,
    pub group_ids: Vec<String>,
}
pub struct ContentSnapshotV1 {
    pub revision: u64,
    pub groups: Vec<GroupRecordV1>,
    pub accounts: Vec<AccountSummaryV1>,
}

#[derive(Serialize, Deserialize, Zeroize, ZeroizeOnDrop)]
#[serde(deny_unknown_fields)]
struct Document {
    schema: u32,
    revision: u64,
    groups: Vec<StoredGroup>,
    accounts: Vec<StoredAccount>,
}
#[derive(Serialize, Deserialize, Zeroize, ZeroizeOnDrop)]
#[serde(deny_unknown_fields)]
pub(super) struct StoredGroup {
    pub(super) id: String,
    pub(super) name: String,
    pub(super) description: String,
    pub(super) icon: String,
    pub(super) logo: Vec<u8>,
}
#[derive(Serialize, Deserialize, Zeroize, ZeroizeOnDrop)]
#[serde(deny_unknown_fields)]
struct StoredAccount {
    id: String,
    name: String,
    description: String,
    login: String,
    password: String,
    group_ids: Vec<String>,
}
pub(super) fn bounded(value: &str, limit: usize, required: bool) -> Result<(), VaultFailure> {
    if value.len() > limit || (required && value.trim().is_empty()) || value.contains('\0') {
        return Err(VaultFailure::Unsupported);
    }
    Ok(())
}
pub(super) fn validate_logo(icon: &str, logo: &[u8]) -> Result<(), VaultFailure> {
    if !["folder", "building", "briefcase", "code", "home", "key"].contains(&icon) {
        return Err(VaultFailure::Unsupported);
    }
    if !logo.is_empty()
        && (logo.len() > 512 * 1024
            || logo.len() < 33
            || &logo[..8] != b"\x89PNG\r\n\x1a\n"
            || &logo[12..16] != b"IHDR"
            || u32::from_be_bytes(logo[16..20].try_into().unwrap()) == 0
            || u32::from_be_bytes(logo[16..20].try_into().unwrap()) > 256
            || u32::from_be_bytes(logo[20..24].try_into().unwrap()) == 0
            || u32::from_be_bytes(logo[20..24].try_into().unwrap()) > 256)
    {
        return Err(VaultFailure::Unsupported);
    }
    Ok(())
}
pub(super) fn new_id() -> Result<String, VaultFailure> {
    Ok(format::random::<16>()?
        .iter()
        .map(|b| format!("{b:02x}"))
        .collect())
}
impl Document {
    fn decode(bytes: &[u8]) -> Result<Self, VaultFailure> {
        if bytes.is_empty() {
            return Ok(Self {
                schema: 1,
                revision: 0,
                groups: vec![],
                accounts: vec![],
            });
        }
        let document: Self =
            serde_json::from_slice(bytes).map_err(|_| VaultFailure::Unsupported)?;
        if document.schema != 1 || document.groups.len() > 10000 || document.accounts.len() > 100000
        {
            return Err(VaultFailure::Unsupported);
        }
        let mut ids = BTreeSet::new();
        for group in &document.groups {
            bounded(&group.id, 32, true)?;
            bounded(&group.name, 512, true)?;
            bounded(&group.description, 16384, false)?;
            validate_logo(&group.icon, &group.logo)?;
            if !ids.insert(group.id.clone()) {
                return Err(VaultFailure::Corrupt);
            }
        }
        let groups = ids;
        let mut ids = BTreeSet::new();
        for account in &document.accounts {
            bounded(&account.id, 32, true)?;
            bounded(&account.name, 512, true)?;
            bounded(&account.description, 16384, false)?;
            bounded(&account.login, 4096, true)?;
            bounded(&account.password, 65536, false)?;
            if account.password.is_empty()
                || !ids.insert(account.id.clone())
                || account.group_ids.iter().any(|id| !groups.contains(id))
                || account.group_ids.iter().collect::<BTreeSet<_>>().len()
                    != account.group_ids.len()
            {
                return Err(VaultFailure::Corrupt);
            }
        }
        Ok(document)
    }
    fn snapshot(&self) -> ContentSnapshotV1 {
        ContentSnapshotV1 {
            revision: self.revision,
            groups: self
                .groups
                .iter()
                .map(|g| GroupRecordV1 {
                    id: g.id.clone(),
                    name: g.name.clone(),
                    description: g.description.clone(),
                    icon: g.icon.clone(),
                    logo: g.logo.clone(),
                })
                .collect(),
            accounts: self
                .accounts
                .iter()
                .map(|a| AccountSummaryV1 {
                    id: a.id.clone(),
                    name: a.name.clone(),
                    group_ids: a.group_ids.clone(),
                })
                .collect(),
        }
    }
}
impl Vault {
    pub fn content_v1(&self, generation: u64) -> Result<ContentSnapshotV1, VaultFailure> {
        let state = self.state.lock().map_err(|_| VaultFailure::Unavailable)?;
        if state.closed || self.generation() != generation {
            return Err(VaultFailure::Stale);
        }
        let active = state.active.as_ref().ok_or(VaultFailure::Locked)?;
        Ok(Document::decode(&active.document)?.snapshot())
    }
    pub fn account_v1(&self, id: String, generation: u64) -> Result<AccountRecordV1, VaultFailure> {
        let state = self.state.lock().map_err(|_| VaultFailure::Unavailable)?;
        if state.closed || self.generation() != generation {
            return Err(VaultFailure::Stale);
        }
        let active = state.active.as_ref().ok_or(VaultFailure::Locked)?;
        let document = Document::decode(&active.document)?;
        let a = document
            .accounts
            .iter()
            .find(|a| a.id == id)
            .ok_or(VaultFailure::Missing)?;
        Ok(AccountRecordV1 {
            id: a.id.clone(),
            name: a.name.clone(),
            description: a.description.clone(),
            login: a.login.clone(),
            password: a.password.clone(),
            group_ids: a.group_ids.clone(),
        })
    }
    pub fn save_group_v1(
        &self,
        input: GroupInputV1,
        revision: u64,
        generation: u64,
    ) -> Result<ContentSnapshotV1, VaultFailure> {
        self.mutate_content(revision, generation, |document| {
            bounded(&input.name, 512, true)?;
            bounded(&input.description, 16384, false)?;
            validate_logo(&input.icon, &input.logo)?;
            let id = match &input.id {
                Some(id) => id.clone(),
                None => new_id()?,
            };
            let group = StoredGroup {
                id: id.clone(),
                name: input.name.trim().to_owned(),
                description: input.description,
                icon: input.icon,
                logo: input.logo,
            };
            if input.id.is_some() {
                let existing = document
                    .groups
                    .iter_mut()
                    .find(|g| g.id == id)
                    .ok_or(VaultFailure::Missing)?;
                existing.zeroize();
                *existing = group;
            } else {
                document.groups.push(group);
            }
            Ok(())
        })
    }
    pub fn delete_group_v1(
        &self,
        id: String,
        revision: u64,
        generation: u64,
    ) -> Result<ContentSnapshotV1, VaultFailure> {
        self.mutate_content(revision, generation, |document| {
            let index = document
                .groups
                .iter()
                .position(|g| g.id == id)
                .ok_or(VaultFailure::Missing)?;
            document.groups.remove(index).zeroize();
            for account in &mut document.accounts {
                account.group_ids.retain(|g| g != &id);
            }
            Ok(())
        })
    }
    pub fn save_account_v1(
        &self,
        input: AccountInputV1,
        revision: u64,
        generation: u64,
    ) -> Result<ContentSnapshotV1, VaultFailure> {
        // All credential copies owned by this call are cleared on every return path.
        let mut account = StoredAccount {
            id: input.id.clone().unwrap_or_default(),
            name: input.name,
            description: input.description,
            login: input.login,
            password: input.password,
            group_ids: input.group_ids,
        };
        let result = self.mutate_content(revision, generation, |document| {
            bounded(&account.name, 512, true)?;
            bounded(&account.description, 16384, false)?;
            bounded(&account.login, 4096, true)?;
            bounded(&account.password, 65536, false)?;
            if account.password.is_empty() {
                return Err(VaultFailure::Unsupported);
            }
            account.group_ids.sort();
            account.group_ids.dedup();
            if account
                .group_ids
                .iter()
                .any(|id| !document.groups.iter().any(|g| &g.id == id))
            {
                return Err(VaultFailure::Missing);
            }
            account.name = account.name.trim().to_owned();
            let value = StoredAccount {
                id: if input.id.is_some() {
                    account.id.clone()
                } else {
                    new_id()?
                },
                name: account.name.clone(),
                description: account.description.clone(),
                login: account.login.clone(),
                password: account.password.clone(),
                group_ids: account.group_ids.clone(),
            };
            if input.id.is_some() {
                let existing = document
                    .accounts
                    .iter_mut()
                    .find(|a| a.id == value.id)
                    .ok_or(VaultFailure::Missing)?;
                existing.zeroize();
                *existing = value;
            } else {
                document.accounts.push(value);
            }
            Ok(())
        });
        account.zeroize();
        result
    }
    pub fn delete_account_v1(
        &self,
        id: String,
        revision: u64,
        generation: u64,
    ) -> Result<ContentSnapshotV1, VaultFailure> {
        self.mutate_content(revision, generation, |document| {
            let index = document
                .accounts
                .iter()
                .position(|a| a.id == id)
                .ok_or(VaultFailure::Missing)?;
            document.accounts.remove(index).zeroize();
            Ok(())
        })
    }
    fn mutate_content(
        &self,
        revision: u64,
        generation: u64,
        operation: impl FnOnce(&mut Document) -> Result<(), VaultFailure>,
    ) -> Result<ContentSnapshotV1, VaultFailure> {
        self.update_document(generation, |bytes| {
            let mut document = Document::decode(bytes)?;
            if document.revision != revision {
                return Err(VaultFailure::Stale);
            }
            operation(&mut document)?;
            document.revision = revision.checked_add(1).ok_or(VaultFailure::Unsupported)?;
            let encoded = Zeroizing::new(
                serde_json::to_vec(&document).map_err(|_| VaultFailure::Unsupported)?,
            );
            Document::decode(&encoded)?;
            Ok((encoded, document.snapshot()))
        })
    }
    pub(super) fn update_document<T>(
        &self,
        generation: u64,
        operation: impl FnOnce(&[u8]) -> Result<(Zeroizing<Vec<u8>>, T), VaultFailure>,
    ) -> Result<T, VaultFailure> {
        let _job = self.job.try_lock().map_err(|_| VaultFailure::Busy)?;
        let (opened, bytes, store) = {
            let state = self.state.lock().map_err(|_| VaultFailure::Unavailable)?;
            if state.closed || self.generation() != generation {
                return Err(VaultFailure::Stale);
            }
            let active = state.active.as_ref().ok_or(VaultFailure::Locked)?;
            (
                format::Opened {
                    key: active.key.clone(),
                    document: active.document.clone(),
                    id: active.id,
                },
                state.store.read()?.ok_or(VaultFailure::Missing)?,
                std::sync::Arc::clone(&state.store),
            )
        };
        let (encoded, value) = operation(&opened.document)?;
        let candidate = format::replace_document(&bytes, &opened, &encoded)?;
        let _publication = self
            .export_publication
            .lock()
            .map_err(|_| VaultFailure::Unavailable)?;
        let state = self.state.lock().map_err(|_| VaultFailure::Unavailable)?;
        if state.closed || self.generation() != generation || state.active.is_none() {
            return Err(VaultFailure::Stale);
        }
        drop(state);
        // The publication barrier retains exclusive storage ownership until completion.
        let result = store.commit(&candidate, Some(digest(&bytes)));
        if let Err(error) = result {
            if error == VaultFailure::WriteUncertain {
                self.lock()?;
            }
            return Err(error);
        }
        let mut state = self.state.lock().map_err(|_| VaultFailure::Unavailable)?;
        if self.generation() != generation || state.closed {
            return Err(VaultFailure::Stale);
        }
        let active = state.active.as_mut().ok_or(VaultFailure::Locked)?;
        active.document = encoded;
        Ok(value)
    }
}
