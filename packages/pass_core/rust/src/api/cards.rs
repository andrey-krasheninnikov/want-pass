use super::content::{StoredGroup, bounded, new_id, validate_logo};
use super::{GroupInputV1, GroupRecordV1, Vault, VaultFailure};
use base64::{Engine, engine::general_purpose::STANDARD as BASE64};
use serde::{Deserialize, Serialize};
use std::collections::BTreeSet;
use zeroize::{Zeroize, ZeroizeOnDrop, Zeroizing};

#[derive(Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "kebab-case")]
pub enum CardTypeV1 {
    Account,
    Pat,
    Rsa,
    Ed25519,
    SecretKey,
    Passphrase,
    RecoveryCodes,
    RecoveryUrl,
    SecretQa,
    Vless,
    WireGuard,
    Gpg,
    Certificate,
    OAuth,
    Dsn,
    Kubeconfig,
    WebhookSecret,
    SecureNote,
    File,
}
#[derive(Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "kebab-case")]
pub enum EnvironmentV1 {
    Local,
    UnitTests,
    IntegrationTests,
    E2eTests,
    Development,
    Stand,
    Feature,
    Stage,
    PreRelease,
    Production,
}
#[derive(Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Serialize, Deserialize)]
#[serde(rename_all = "kebab-case")]
pub enum FieldIdV1 {
    Login,
    Password,
    TotpSeed,
    TotpAlgorithm,
    TotpDigits,
    TotpPeriod,
    RecoveryCodes,
    ReserveLogins,
    Value,
    PublicKey,
    PrivateKey,
    Certificate,
    ClientId,
    ClientSecret,
    AccessToken,
    RefreshToken,
    Question,
    Answer,
}
#[derive(Clone, Serialize, Deserialize, Zeroize)]
#[serde(deny_unknown_fields)]
pub struct CardValueV1 {
    #[zeroize(skip)]
    pub id: FieldIdV1,
    pub value: String,
}
pub struct AttachmentInputV1 {
    pub name: String,
    pub bytes: Vec<u8>,
}
pub struct CardInputV1 {
    pub id: Option<String>,
    pub name: String,
    pub description: String,
    pub service: String,
    pub environment: Option<EnvironmentV1>,
    pub group_ids: Vec<String>,
    pub card_type: CardTypeV1,
    pub fields: Vec<CardValueV1>,
    pub attachment: Option<AttachmentInputV1>,
}
pub struct CardSummaryV1 {
    pub id: String,
    pub name: String,
    pub service: String,
    pub environment: Option<EnvironmentV1>,
    pub group_ids: Vec<String>,
    pub card_type: CardTypeV1,
    pub template_version: u32,
}
pub struct AttachmentSummaryV1 {
    pub name: String,
    pub size: u32,
}
pub struct CardRecordV1 {
    pub summary: CardSummaryV1,
    pub description: String,
    pub fields: Vec<CardValueV1>,
    pub attachment: Option<AttachmentSummaryV1>,
    pub protected_container: bool,
}
pub struct ContentSnapshotV2 {
    pub revision: u64,
    pub groups: Vec<GroupRecordV1>,
    pub cards: Vec<CardSummaryV1>,
}
pub struct CardSearchV1 {
    pub text: String,
    pub card_type: Option<CardTypeV1>,
    pub service: Option<String>,
    pub environment: Option<EnvironmentV1>,
    pub without_environment: bool,
}
pub struct CardMatchesV1 {
    pub revision: u64,
    pub card_ids: Vec<String>,
    pub group_ids: Vec<String>,
}
pub struct CardRowV1 {
    pub id: String,
    pub fields: Vec<FieldIdV1>,
    pub login: Option<String>,
    pub otp: Option<super::TotpCodeV1>,
    pub attachment: Option<AttachmentSummaryV1>,
}
pub fn services_v1() -> Vec<String> {
    [
        "microsoft",
        "google",
        "apple",
        "github",
        "gitlab",
        "atlassian",
        "jira",
        "confluence",
        "telegram",
        "aws",
        "azure",
        "gcp",
        "cloudflare",
        "docker",
        "ghcr",
        "npm",
        "pypi",
        "crates-io",
        "firebase",
        "supabase",
        "sentry",
        "other",
    ]
    .iter()
    .map(|v| (*v).into())
    .collect()
}
#[derive(Serialize, Deserialize, Zeroize, ZeroizeOnDrop)]
#[serde(deny_unknown_fields)]
struct DocumentV2 {
    schema: u32,
    revision: u64,
    groups: Vec<StoredGroup>,
    cards: Vec<StoredCard>,
}
const MAX_ATTACHMENT: usize = 20 * 1024 * 1024;
#[derive(Serialize, Deserialize, Zeroize, ZeroizeOnDrop)]
#[serde(deny_unknown_fields)]
struct StoredAttachment {
    name: String,
    data: String,
}
impl StoredAttachment {
    fn bytes(&self) -> Result<Zeroizing<Vec<u8>>, VaultFailure> {
        bounded(&self.name, 512, true)?;
        if self.name.contains('/')
            || self.name.contains('\\')
            || self.name == "."
            || self.name == ".."
            || self.data.len() > MAX_ATTACHMENT.div_ceil(3) * 4
        {
            return Err(VaultFailure::Unsupported);
        }
        let bytes = Zeroizing::new(
            BASE64
                .decode(&self.data)
                .map_err(|_| VaultFailure::Unsupported)?,
        );
        if bytes.len() > MAX_ATTACHMENT {
            return Err(VaultFailure::Unsupported);
        }
        Ok(bytes)
    }
    fn summary(&self) -> Result<AttachmentSummaryV1, VaultFailure> {
        Ok(AttachmentSummaryV1 {
            name: self.name.clone(),
            size: self.bytes()?.len() as u32,
        })
    }
}
#[derive(Serialize, Deserialize, Zeroize, ZeroizeOnDrop)]
#[serde(deny_unknown_fields)]
struct StoredCard {
    id: String,
    name: String,
    description: String,
    service: String,
    #[zeroize(skip)]
    environment: Option<EnvironmentV1>,
    group_ids: Vec<String>,
    #[zeroize(skip)]
    card_type: CardTypeV1,
    template_version: u32,
    fields: Vec<CardValueV1>,
    attachment: Option<StoredAttachment>,
}
impl StoredCard {
    fn summary(&self) -> CardSummaryV1 {
        CardSummaryV1 {
            id: self.id.clone(),
            name: self.name.clone(),
            service: self.service.clone(),
            environment: self.environment,
            group_ids: self.group_ids.clone(),
            card_type: self.card_type,
            template_version: self.template_version,
        }
    }
    fn validate(&self) -> Result<(), VaultFailure> {
        bounded(&self.name, 512, true)?;
        bounded(&self.description, 16384, false)?;
        if self.template_version != 1 || !services_v1().contains(&self.service) {
            return Err(VaultFailure::Unsupported);
        }
        super::presets::validate_fields(self.card_type, &self.fields)?;
        match (&self.attachment, self.card_type) {
            (Some(file), CardTypeV1::File) => {
                file.bytes()?;
            }
            (None, kind) if kind != CardTypeV1::File => {}
            _ => return Err(VaultFailure::Unsupported),
        }
        Ok(())
    }
}
impl DocumentV2 {
    fn decode(bytes: &[u8]) -> Result<Self, VaultFailure> {
        let document = if bytes.is_empty() {
            Self {
                schema: 2,
                revision: 0,
                groups: vec![],
                cards: vec![],
            }
        } else {
            serde_json::from_slice(bytes).map_err(|_| VaultFailure::Unsupported)?
        };
        if document.schema != 2 || document.groups.len() > 10000 || document.cards.len() > 100000 {
            return Err(VaultFailure::Unsupported);
        }
        let mut groups = BTreeSet::new();
        for g in &document.groups {
            bounded(&g.id, 32, true)?;
            bounded(&g.name, 512, true)?;
            bounded(&g.description, 16384, false)?;
            validate_logo(&g.icon, &g.logo)?;
            if !groups.insert(g.id.clone()) {
                return Err(VaultFailure::Corrupt);
            }
        }
        let mut ids = BTreeSet::new();
        for c in &document.cards {
            c.validate()?;
            if !ids.insert(c.id.clone())
                || c.id.len() != 32
                || c.group_ids.iter().any(|g| !groups.contains(g))
                || c.group_ids.iter().collect::<BTreeSet<_>>().len() != c.group_ids.len()
            {
                return Err(VaultFailure::Corrupt);
            }
        }
        Ok(document)
    }
    fn snapshot(&self) -> ContentSnapshotV2 {
        ContentSnapshotV2 {
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
            cards: self.cards.iter().map(StoredCard::summary).collect(),
        }
    }
}
impl Vault {
    pub fn content_v2(&self, generation: u64) -> Result<ContentSnapshotV2, VaultFailure> {
        self.read_cards(generation, |d| Ok(d.snapshot()))
    }
    pub fn search_cards_v1(
        &self,
        query: CardSearchV1,
        revision: u64,
        generation: u64,
    ) -> Result<CardMatchesV1, VaultFailure> {
        let text = Zeroizing::new(query.text);
        if text.len() > 16384
            || text.contains('\0')
            || (query.without_environment && query.environment.is_some())
            || query
                .service
                .as_ref()
                .is_some_and(|s| !services_v1().contains(s))
        {
            return Err(VaultFailure::Unsupported);
        }
        self.read_cards(generation, |d| {
            if d.revision != revision {
                return Err(VaultFailure::Stale);
            }
            let needle = Zeroizing::new(text.to_lowercase());
            let group_ids: Vec<String> = d
                .groups
                .iter()
                .filter(|g| g.name.to_lowercase().contains(needle.as_str()))
                .map(|g| g.id.clone())
                .collect();
            let groups: BTreeSet<&str> = group_ids.iter().map(String::as_str).collect();
            let card_ids = d
                .cards
                .iter()
                .filter(|c| {
                    query.card_type.is_none_or(|v| c.card_type == v)
                        && query.service.as_ref().is_none_or(|v| c.service == *v)
                        && query.environment.is_none_or(|v| c.environment == Some(v))
                        && (!query.without_environment || c.environment.is_none())
                        && (needle.is_empty()
                            || c.name.to_lowercase().contains(needle.as_str())
                            || c.group_ids.iter().any(|id| groups.contains(id.as_str()))
                            || c.fields.iter().any(|f| {
                                Zeroizing::new(f.value.to_lowercase()).contains(needle.as_str())
                            }))
                })
                .map(|c| c.id.clone())
                .collect();
            Ok(CardMatchesV1 {
                revision: d.revision,
                card_ids,
                group_ids,
            })
        })
    }
    pub fn card_rows_v1(
        &self,
        ids: Vec<String>,
        revision: u64,
        generation: u64,
    ) -> Result<Vec<CardRowV1>, VaultFailure> {
        if ids.len() > 50 || ids.iter().collect::<BTreeSet<_>>().len() != ids.len() {
            return Err(VaultFailure::Unsupported);
        }
        self.read_cards(generation, |d| {
            if d.revision != revision {
                return Err(VaultFailure::Stale);
            }
            ids.iter()
                .map(|id| {
                    let c = d
                        .cards
                        .iter()
                        .find(|c| c.id == *id)
                        .ok_or(VaultFailure::Missing)?;
                    Ok(CardRowV1 {
                        id: c.id.clone(),
                        fields: c
                            .fields
                            .iter()
                            .filter(|f| !f.value.is_empty())
                            .map(|f| f.id)
                            .collect(),
                        login: super::otp::field(&c.fields, FieldIdV1::Login).map(str::to_owned),
                        otp: if super::otp::field(&c.fields, FieldIdV1::TotpSeed).is_some() {
                            Some(super::otp::current_code(&c.fields)?)
                        } else {
                            None
                        },
                        attachment: c
                            .attachment
                            .as_ref()
                            .map(StoredAttachment::summary)
                            .transpose()?,
                    })
                })
                .collect()
        })
    }
    pub fn card_v1(&self, id: String, generation: u64) -> Result<CardRecordV1, VaultFailure> {
        self.read_cards(generation, |d| {
            let c = d
                .cards
                .iter()
                .find(|c| c.id == id)
                .ok_or(VaultFailure::Missing)?;
            Ok(CardRecordV1 {
                summary: c.summary(),
                description: c.description.clone(),
                fields: c.fields.clone(),
                attachment: c
                    .attachment
                    .as_ref()
                    .map(StoredAttachment::summary)
                    .transpose()?,
                protected_container: super::presets::validate_fields(c.card_type, &c.fields)?,
            })
        })
    }
    pub fn save_card_v1(
        &self,
        input: CardInputV1,
        revision: u64,
        generation: u64,
    ) -> Result<ContentSnapshotV2, VaultFailure> {
        let mut fields = Zeroizing::new(input.fields);
        let attachment = if let Some(mut input) = input.attachment {
            let bytes = Zeroizing::new(std::mem::take(&mut input.bytes));
            if bytes.len() > MAX_ATTACHMENT {
                return Err(VaultFailure::Unsupported);
            }
            Some(StoredAttachment {
                name: input.name,
                data: BASE64.encode(bytes.as_slice()),
            })
        } else {
            None
        };
        let mut card = StoredCard {
            id: input.id.clone().unwrap_or_default(),
            name: input.name,
            description: input.description,
            service: input.service,
            environment: input.environment,
            group_ids: input.group_ids,
            card_type: input.card_type,
            template_version: 1,
            fields: std::mem::take(&mut *fields),
            attachment,
        };
        self.mutate_cards(revision, generation, |d| {
            card.name = card.name.trim().into();
            card.group_ids.sort();
            card.group_ids.dedup();
            if card.card_type == CardTypeV1::File && card.attachment.is_none() {
                let previous = d
                    .cards
                    .iter()
                    .find(|c| Some(&c.id) == input.id.as_ref())
                    .ok_or(VaultFailure::Missing)?;
                card.attachment = previous.attachment.as_ref().map(|a| StoredAttachment {
                    name: a.name.clone(),
                    data: a.data.clone(),
                });
            }
            if card.card_type == CardTypeV1::Account {
                super::otp::normalize_totp(&mut card.fields)?;
            }
            card.validate()?;
            if card
                .group_ids
                .iter()
                .any(|id| !d.groups.iter().any(|g| &g.id == id))
            {
                return Err(VaultFailure::Missing);
            }
            if let Some(id) = input.id {
                let previous = d
                    .cards
                    .iter_mut()
                    .find(|c| c.id == id)
                    .ok_or(VaultFailure::Missing)?;
                if previous.card_type != card.card_type {
                    return Err(VaultFailure::Unsupported);
                }
                std::mem::swap(previous, &mut card);
            } else {
                card.id = new_id()?;
                d.cards.push(card);
            }
            Ok(())
        })
    }
    pub fn current_totp_v1(
        &self,
        id: String,
        generation: u64,
    ) -> Result<super::TotpCodeV1, VaultFailure> {
        self.read_cards(generation, |d| {
            let c = d
                .cards
                .iter()
                .find(|c| c.id == id)
                .ok_or(VaultFailure::Missing)?;
            super::otp::current_code(&c.fields)
        })
    }
    pub fn copy_card_field_v1(
        &self,
        id: String,
        field: FieldIdV1,
        generation: u64,
    ) -> Result<String, VaultFailure> {
        self.read_cards(generation, |d| {
            let c = d
                .cards
                .iter()
                .find(|c| c.id == id)
                .ok_or(VaultFailure::Missing)?;
            c.fields
                .iter()
                .find(|f| f.id == field)
                .map(|f| f.value.clone())
                .ok_or(VaultFailure::Missing)
        })
    }
    pub fn copy_account_v1(&self, id: String, generation: u64) -> Result<String, VaultFailure> {
        self.read_cards(generation, |d| {
            let c = d
                .cards
                .iter()
                .find(|c| c.id == id)
                .ok_or(VaultFailure::Missing)?;
            let login =
                super::otp::field(&c.fields, FieldIdV1::Login).ok_or(VaultFailure::Unsupported)?;
            let password = super::otp::field(&c.fields, FieldIdV1::Password)
                .ok_or(VaultFailure::Unsupported)?;
            let mut text = format!("Login: {login}\nPassword: {password}");
            if super::otp::field(&c.fields, FieldIdV1::TotpSeed).is_some() {
                text.push_str(&format!(
                    "\nOTP: {}",
                    super::otp::current_code(&c.fields)?.code
                ));
            }
            Ok(text)
        })
    }
    pub fn export_attachment_v1(
        &self,
        id: String,
        destination: String,
        revision: u64,
        generation: u64,
    ) -> Result<(), VaultFailure> {
        use std::{fs, io::Write, path::Path};
        let bytes = self.read_cards(generation, |d| {
            if d.revision != revision {
                return Err(VaultFailure::Stale);
            }
            let file = d
                .cards
                .iter()
                .find(|c| c.id == id)
                .and_then(|c| c.attachment.as_ref())
                .ok_or(VaultFailure::Missing)?;
            file.bytes()
        })?;
        let directory = {
            let state = self.state.lock().map_err(|_| VaultFailure::Unavailable)?;
            state.store.directory().to_owned()
        };
        let path = Path::new(&destination);
        let parent = path.parent().ok_or(VaultFailure::Storage)?;
        if parent.canonicalize().map_err(|_| VaultFailure::Storage)?
            == directory
                .canonicalize()
                .map_err(|_| VaultFailure::Storage)?
        {
            return Err(VaultFailure::Storage);
        }
        match fs::symlink_metadata(path) {
            Ok(m) if !m.is_file() || m.file_type().is_symlink() => {
                return Err(VaultFailure::Storage);
            }
            Ok(_) => {}
            Err(e) if e.kind() == std::io::ErrorKind::NotFound => {}
            Err(_) => return Err(VaultFailure::Storage),
        }
        let mut file =
            tempfile::NamedTempFile::new_in(parent).map_err(|_| VaultFailure::Storage)?;
        file.write_all(&bytes)
            .and_then(|()| file.as_file().sync_all())
            .map_err(|_| VaultFailure::Storage)?;
        let _publication = self
            .export_publication
            .lock()
            .map_err(|_| VaultFailure::Unavailable)?;
        self.read_cards(generation, |d| {
            if d.revision == revision {
                Ok(())
            } else {
                Err(VaultFailure::Stale)
            }
        })?;
        file.persist(path).map_err(|_| VaultFailure::Storage)?;
        fs::File::open(parent)
            .and_then(|f| f.sync_all())
            .map_err(|_| VaultFailure::WriteUncertain)
    }
    pub fn delete_card_v1(
        &self,
        id: String,
        revision: u64,
        generation: u64,
    ) -> Result<ContentSnapshotV2, VaultFailure> {
        self.mutate_cards(revision, generation, |d| {
            let index = d
                .cards
                .iter()
                .position(|c| c.id == id)
                .ok_or(VaultFailure::Missing)?;
            d.cards.remove(index);
            Ok(())
        })
    }
    pub fn save_group_v2(
        &self,
        input: GroupInputV1,
        revision: u64,
        generation: u64,
    ) -> Result<ContentSnapshotV2, VaultFailure> {
        self.mutate_cards(revision, generation, |d| {
            bounded(&input.name, 512, true)?;
            bounded(&input.description, 16384, false)?;
            validate_logo(&input.icon, &input.logo)?;
            let mut value = StoredGroup {
                id: input.id.clone().unwrap_or(new_id()?),
                name: input.name.trim().into(),
                description: input.description,
                icon: input.icon,
                logo: input.logo,
            };
            if let Some(id) = input.id {
                let previous = d
                    .groups
                    .iter_mut()
                    .find(|g| g.id == id)
                    .ok_or(VaultFailure::Missing)?;
                std::mem::swap(previous, &mut value);
            } else {
                d.groups.push(value);
            }
            Ok(())
        })
    }
    pub fn delete_group_v2(
        &self,
        id: String,
        revision: u64,
        generation: u64,
    ) -> Result<ContentSnapshotV2, VaultFailure> {
        self.mutate_cards(revision, generation, |d| {
            let index = d
                .groups
                .iter()
                .position(|g| g.id == id)
                .ok_or(VaultFailure::Missing)?;
            d.groups.remove(index);
            for c in &mut d.cards {
                c.group_ids.retain(|g| g != &id);
            }
            Ok(())
        })
    }
    fn read_cards<T>(
        &self,
        generation: u64,
        read: impl FnOnce(&DocumentV2) -> Result<T, VaultFailure>,
    ) -> Result<T, VaultFailure> {
        let bytes = {
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
        let result = read(&DocumentV2::decode(&bytes)?);
        if self.generation() != generation {
            return Err(VaultFailure::Stale);
        }
        result
    }

    fn mutate_cards(
        &self,
        revision: u64,
        generation: u64,
        operation: impl FnOnce(&mut DocumentV2) -> Result<(), VaultFailure>,
    ) -> Result<ContentSnapshotV2, VaultFailure> {
        self.update_document(generation, |bytes| {
            let mut document = DocumentV2::decode(bytes)?;
            if document.revision != revision {
                return Err(VaultFailure::Stale);
            }
            operation(&mut document)?;
            document.revision = revision.checked_add(1).ok_or(VaultFailure::Unsupported)?;
            let bytes = Zeroizing::new(
                serde_json::to_vec(&document).map_err(|_| VaultFailure::Unsupported)?,
            );
            DocumentV2::decode(&bytes)?;
            Ok((bytes, document.snapshot()))
        })
    }
}
