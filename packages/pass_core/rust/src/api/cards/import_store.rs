use super::*;
use crate::api::{
    ResourceBindingV1, ResourceKindV1,
    account_import::{AccountImportRowV1, ImportRow},
    otp::field,
};
use sha2::{Digest, Sha256};

fn identity(namespace: u8, parts: &[&str]) -> [u8; 32] {
    let mut digest = Sha256::new();
    digest.update([namespace]);
    for part in parts {
        digest.update((part.len() as u64).to_be_bytes());
        digest.update(part.as_bytes());
    }
    digest.finalize().into()
}
fn otp_id(fields: &[CardValueV1]) -> Option<[u8; 32]> {
    field(fields, FieldIdV1::TotpSeed)
        .map(|s| identity(1, &[s]))
        .or_else(|| field(fields, FieldIdV1::HotpSeed).map(|s| identity(2, &[s])))
}

impl Vault {
    pub(in crate::api) fn compare_import_rows(
        &self,
        rows: &[ImportRow],
        revision: u64,
        generation: u64,
    ) -> Result<Vec<AccountImportRowV1>, VaultFailure> {
        self.read_cards(generation, |doc| {
            if doc.revision != revision {
                return Err(VaultFailure::Stale);
            }
            let mut keys = BTreeSet::new();
            for existing in &doc.cards {
                if let Some(id) = otp_id(&existing.fields) {
                    keys.insert(id);
                }
                if existing.card_type == CardTypeV1::Account
                    && let Some(login) = field(&existing.fields, FieldIdV1::Login)
                {
                    let mut found = false;
                    for binding in &existing.bindings {
                        if binding.kind == ResourceKindV1::WebApp {
                            keys.insert(identity(3, &[&binding.target, login]));
                            found = true;
                        }
                    }
                    if !found {
                        keys.insert(identity(4, &[&existing.name, login]));
                    }
                }
            }
            rows.iter()
                .map(|row| {
                    let duplicate = if row.kind == CardTypeV1::Account {
                        let login = field(&row.fields, FieldIdV1::Login)
                            .ok_or(VaultFailure::Unsupported)?;
                        let title_key = identity(4, &[&row.name, login]);
                        match row.url.as_deref() {
                            Some(url) => {
                                let known_title = keys.contains(&title_key);
                                !keys.insert(identity(3, &[url, login])) || known_title
                            }
                            None => !keys.insert(title_key),
                        }
                    } else {
                        !keys.insert(otp_id(&row.fields).ok_or(VaultFailure::Unsupported)?)
                    };
                    Ok(AccountImportRowV1 {
                        name: row.name.clone(),
                        duplicate,
                    })
                })
                .collect()
        })
    }

    pub(in crate::api) fn insert_import_rows(
        &self,
        rows: Vec<ImportRow>,
        revision: u64,
        generation: u64,
    ) -> Result<ContentSnapshotV2, VaultFailure> {
        self.mutate_cards(revision, generation, |doc| {
            for mut row in rows {
                let bindings = row
                    .url
                    .as_deref()
                    .map(ResourceBindingV1::web_account)
                    .transpose()?
                    .into_iter()
                    .collect();
                let card = StoredCard {
                    id: new_id()?,
                    name: std::mem::take(&mut row.name),
                    description: std::mem::take(&mut row.notes),
                    service: "other".into(),
                    environment: None,
                    group_ids: vec![],
                    card_type: row.kind,
                    template_version: 1,
                    fields: std::mem::take(&mut row.fields),
                    attachment: None,
                    bindings,
                    custom: None,
                };
                card.validate(doc)?;
                doc.cards.push(card);
            }
            Ok(())
        })
    }
}
