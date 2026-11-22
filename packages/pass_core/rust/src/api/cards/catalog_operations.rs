use super::*;
use crate::api::policy::OperationV1;
use std::time::{SystemTime, UNIX_EPOCH};

const YEAR: i64 = 365 * 24 * 60 * 60;

pub(super) fn now() -> Result<i64, VaultFailure> {
    let seconds = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map_err(|_| VaultFailure::Unavailable)?
        .as_secs();
    seconds.try_into().map_err(|_| VaultFailure::Unavailable)
}

#[derive(Clone, PartialEq, Eq, Serialize, Deserialize, Zeroize)]
#[serde(deny_unknown_fields)]
pub(super) struct CustomCardDataV1 {
    pub(super) template_id: String,
    pub(super) values: Vec<CustomStoredValue>,
}
#[derive(Clone, PartialEq, Eq, Serialize, Deserialize, Zeroize)]
#[serde(deny_unknown_fields)]
pub(super) struct CustomStoredValue {
    pub(super) field_id: String,
    pub(super) value: String,
    pub(super) file: Option<StoredAttachment>,
}
#[derive(Serialize, Deserialize, Zeroize)]
#[serde(deny_unknown_fields)]
pub(in crate::api) struct CardRevision {
    pub(super) id: String,
    pub(super) at: i64,
    pub(super) card: StoredCard,
}

impl CardRevision {
    pub(in crate::api) fn capture(card: StoredCard) -> Result<Self, VaultFailure> {
        Ok(Self {
            id: new_id()?,
            at: now()?,
            card,
        })
    }
}

fn unique<'a>(ids: impl Iterator<Item = &'a str>) -> bool {
    let mut seen = BTreeSet::new();
    ids.into_iter().all(|id| valid_id(id) && seen.insert(id))
}

impl DocumentV2 {
    pub(super) fn recognizes_service(&self, id: &str) -> bool {
        SERVICES_V1.contains(&id) || self.services.iter().any(|s| s.id == id)
    }
    pub(super) fn check_service_assignment(
        &self,
        card_id: Option<&str>,
        service: &str,
    ) -> Result<(), VaultFailure> {
        if self.services.iter().any(|s| s.id == service && s.archived)
            && !self
                .cards
                .iter()
                .any(|c| Some(c.id.as_str()) == card_id && c.service == service)
        {
            return Err(VaultFailure::Unsupported);
        }
        Ok(())
    }
    pub(super) fn card_index(&self, id: &str) -> Result<usize, VaultFailure> {
        self.cards
            .iter()
            .position(|c| c.id == id)
            .ok_or(VaultFailure::Missing)
    }
    fn template(&self, id: &str, version: u32) -> Result<&TemplateVersionV1, VaultFailure> {
        self.templates
            .iter()
            .find(|t| t.id == id)
            .and_then(|t| t.versions.iter().find(|v| v.number == version))
            .ok_or(VaultFailure::Missing)
    }
    pub(super) fn prune_history(&mut self, time: i64) {
        self.history
            .retain(|entry| entry.at > time.saturating_sub(YEAR));
    }
    pub(super) fn archive(&mut self, index: usize) -> Result<(), VaultFailure> {
        self.history
            .push(CardRevision::capture(self.cards[index].clone())?);
        Ok(())
    }
    pub(super) fn replace_card(
        &mut self,
        index: usize,
        card: StoredCard,
    ) -> Result<(), VaultFailure> {
        if self.cards[index] != card {
            self.archive(index)?;
            self.cards[index] = card;
        }
        Ok(())
    }
    pub(super) fn validate_catalog(&self) -> Result<(), VaultFailure> {
        if self.services.len() > 10_000
            || self.templates.len() > 10_000
            || self.history.len() > 100_000
            || !unique(self.services.iter().map(|v| v.id.as_str()))
            || !unique(self.templates.iter().map(|v| v.id.as_str()))
            || !unique(self.history.iter().map(|v| v.id.as_str()))
        {
            return Err(VaultFailure::Corrupt);
        }
        for s in &self.services {
            bounded(&s.name, 512, true)?;
            bounded(&s.description, 16384, false)?;
            validate_logo(&s.icon, &s.logo)?;
        }
        for t in &self.templates {
            if t.versions.is_empty() || t.versions.len() > 1024 {
                return Err(VaultFailure::Unsupported);
            }
            for (index, v) in t.versions.iter().enumerate() {
                bounded(&v.name, 512, true)?;
                if v.number as usize != index + 1
                    || v.fields.is_empty()
                    || v.fields.len() > 128
                    || !unique(v.fields.iter().map(|f| f.id.as_str()))
                {
                    return Err(VaultFailure::Unsupported);
                }
                for field in &v.fields {
                    bounded(&field.label, 256, true)?;
                }
            }
        }
        for h in &self.history {
            if h.at <= 0 || !valid_id(&h.card.id) {
                return Err(VaultFailure::Corrupt);
            }
            h.card.validate(self)?;
        }
        Ok(())
    }
}

impl StoredCard {
    fn field_ids(&self, doc: &DocumentV2) -> Result<BTreeSet<String>, VaultFailure> {
        if let Some(custom) = &self.custom {
            return Ok(doc
                .template(&custom.template_id, self.template_version)?
                .fields
                .iter()
                .map(|f| f.id.clone())
                .collect());
        }
        let mut fields: BTreeSet<String> = super::super::presets::specs(self.card_type)
            .iter()
            .map(|f| {
                serde_json::to_value(f.id)
                    .ok()
                    .and_then(|v| v.as_str().map(str::to_owned))
                    .ok_or(VaultFailure::Unsupported)
            })
            .collect::<Result<_, _>>()?;
        if self.card_type.requires_attachment() {
            fields.insert("attachment".into());
        }
        Ok(fields)
    }
    pub(super) fn validate_bindings(&self, doc: &DocumentV2) -> Result<(), VaultFailure> {
        if self.bindings.is_empty() {
            return Ok(());
        }
        if self.bindings.len() > 256 || !unique(self.bindings.iter().map(|v| v.id.as_str())) {
            return Err(VaultFailure::Unsupported);
        }
        let fields = self.field_ids(doc)?;
        for b in &self.bindings {
            b.validate(&fields)?;
        }
        Ok(())
    }
    pub(super) fn validate_custom(&self, doc: &DocumentV2) -> Result<(), VaultFailure> {
        let data = self.custom.as_ref().ok_or(VaultFailure::Unsupported)?;
        let version = doc.template(&data.template_id, self.template_version)?;
        if !self.fields.is_empty()
            || self.attachment.is_some()
            || data.values.len() > version.fields.len()
            || !unique(data.values.iter().map(|v| v.field_id.as_str()))
        {
            return Err(VaultFailure::Unsupported);
        }
        for value in &data.values {
            let field = version
                .fields
                .iter()
                .find(|f| f.id == value.field_id)
                .ok_or(VaultFailure::Unsupported)?;
            bounded(&value.value, 1024 * 1024, false)?;
            if field.kind == CustomFieldKindV1::File {
                if !value.value.is_empty() {
                    return Err(VaultFailure::Unsupported);
                }
                if let Some(file) = &value.file {
                    file.bytes()?;
                }
            } else {
                if value.file.is_some() {
                    return Err(VaultFailure::Unsupported);
                }
                if !value.value.is_empty() {
                    match field.kind {
                        CustomFieldKindV1::Url => {
                            ResourceBindingV1::web_target(&value.value)?;
                        }
                        CustomFieldKindV1::Otp => {
                            super::super::otp::validate_account_totp(&[CardValueV1 {
                                id: FieldIdV1::TotpSeed,
                                value: value.value.clone(),
                            }])?;
                        }
                        CustomFieldKindV1::Codes
                            if !value.value.lines().any(|v| !v.trim().is_empty()) =>
                        {
                            return Err(VaultFailure::Unsupported);
                        }
                        _ => {}
                    }
                }
            }
        }
        for field in version.fields.iter().filter(|f| f.required) {
            if !data
                .values
                .iter()
                .any(|v| v.field_id == field.id && (v.file.is_some() || !v.value.is_empty()))
            {
                return Err(VaultFailure::Unsupported);
            }
        }
        Ok(())
    }
    pub(super) fn account_copy_text(&self) -> Result<String, VaultFailure> {
        if self.card_type != CardTypeV1::Account {
            return Err(VaultFailure::Unsupported);
        }
        use super::super::otp;
        let login = otp::field(&self.fields, FieldIdV1::Login).ok_or(VaultFailure::Unsupported)?;
        let password =
            otp::field(&self.fields, FieldIdV1::Password).ok_or(VaultFailure::Unsupported)?;
        let mut text = format!("Login: {login}\nPassword: {password}");
        if otp::field(&self.fields, FieldIdV1::TotpSeed).is_some() {
            text.push_str(&format!("\nOTP: {}", otp::current_code(&self.fields)?.code));
        }
        Ok(text)
    }
    pub(super) fn quick_copy_text(&self, doc: &DocumentV2) -> Result<String, VaultFailure> {
        let mut lines = Zeroizing::new(Vec::<String>::new());
        if let Some(custom) = &self.custom {
            let template = doc.template(&custom.template_id, self.template_version)?;
            for field in &template.fields {
                let Some(v) = custom
                    .values
                    .iter()
                    .find(|v| v.field_id == field.id && !v.value.is_empty())
                else {
                    continue;
                };
                let text = if field.kind == CustomFieldKindV1::Otp {
                    super::super::otp::current_code(&[CardValueV1 {
                        id: FieldIdV1::TotpSeed,
                        value: v.value.clone(),
                    }])?
                    .code
                } else {
                    v.value.clone()
                };
                lines.push(format!("{}: {}", field.label, text));
            }
        } else if self.card_type == CardTypeV1::Totp {
            return Ok(super::super::otp::current_code(&self.fields)?.code);
        } else {
            for f in &self.fields {
                if f.value.is_empty()
                    || matches!(
                        f.id,
                        FieldIdV1::TotpSeed
                            | FieldIdV1::TotpAlgorithm
                            | FieldIdV1::TotpDigits
                            | FieldIdV1::TotpPeriod
                            | FieldIdV1::HotpSeed
                            | FieldIdV1::Counter
                    )
                {
                    continue;
                }
                let key = serde_json::to_value(f.id).map_err(|_| VaultFailure::Unsupported)?;
                lines.push(format!(
                    "{}: {}",
                    key.as_str().ok_or(VaultFailure::Unsupported)?,
                    f.value
                ));
            }
        }
        if lines.is_empty() {
            return Err(VaultFailure::Unsupported);
        }
        Ok(lines.join("\n"))
    }
    fn custom_views(&self) -> Result<Vec<CustomValueViewV1>, VaultFailure> {
        let Some(c) = &self.custom else {
            return Ok(vec![]);
        };
        c.values
            .iter()
            .map(|v| {
                Ok(CustomValueViewV1 {
                    field_id: v.field_id.clone(),
                    value: v.value.clone(),
                    file: v.file.as_ref().map(StoredAttachment::summary).transpose()?,
                })
            })
            .collect()
    }
}

impl Vault {
    pub fn save_service_v1(
        &self,
        mut service: ServiceDefinitionV1,
        revision: u64,
        generation: u64,
    ) -> Result<ContentSnapshotV2, VaultFailure> {
        self.mutate_cards(revision, generation, |d| {
            service.name = service.name.trim().into();
            if service.id.is_empty() {
                service.id = new_id()?;
                service.archived = false;
                d.services.push(service);
            } else {
                let old = d
                    .services
                    .iter_mut()
                    .find(|s| s.id == service.id)
                    .ok_or(VaultFailure::Missing)?;
                service.archived = old.archived;
                *old = service;
            }
            Ok(())
        })
    }
    pub fn remove_service_v1(
        &self,
        id: String,
        replacement: Option<String>,
        preserve: bool,
        revision: u64,
        generation: u64,
    ) -> Result<ContentSnapshotV2, VaultFailure> {
        self.require_operation(OperationV1::Delete, &format!("service:{id}"), generation)?;
        self.mutate_cards(revision, generation, |d| {
            let idx = d
                .services
                .iter()
                .position(|s| s.id == id)
                .ok_or(VaultFailure::Missing)?;
            if preserve && replacement.is_some() {
                return Err(VaultFailure::Unsupported);
            }
            if let Some(ref new) = replacement
                && (*new == id
                    || !d.recognizes_service(new)
                    || d.services.iter().any(|s| s.id == *new && s.archived))
            {
                return Err(VaultFailure::Unsupported);
            }
            for i in 0..d.cards.len() {
                if d.cards[i].service == id && !preserve {
                    let target = replacement.as_ref().ok_or(VaultFailure::Confirmation)?;
                    d.archive(i)?;
                    d.cards[i].service = target.clone();
                }
            }
            if preserve || d.history.iter().any(|r| r.card.service == id) {
                d.services[idx].archived = true;
            } else {
                d.services.remove(idx);
            }
            Ok(())
        })
    }
    pub fn save_template_v1(
        &self,
        id: Option<String>,
        name: String,
        mut fields: Vec<TemplateFieldV1>,
        revision: u64,
        generation: u64,
    ) -> Result<ContentSnapshotV2, VaultFailure> {
        self.mutate_cards(revision, generation, |d| {
            let current = if let Some(ref id) = id {
                Some(
                    d.templates
                        .iter()
                        .position(|s| s.id == *id)
                        .ok_or(VaultFailure::Missing)?,
                )
            } else {
                None
            };
            for f in &mut fields {
                f.label = f.label.trim().to_string();
                if f.id.is_empty() {
                    f.id = new_id()?;
                } else if !current.is_some_and(|i| {
                    d.templates[i]
                        .versions
                        .last()
                        .is_some_and(|v| v.fields.iter().any(|old| old.id == f.id))
                }) {
                    return Err(VaultFailure::Unsupported);
                }
            }
            let mut version = TemplateVersionV1 {
                number: 1,
                name: name.trim().into(),
                fields,
            };
            if let Some(index) = current {
                let t = &mut d.templates[index];
                let last = t.versions.last().ok_or(VaultFailure::Corrupt)?;
                if last.name != version.name || last.fields != version.fields {
                    version.number = last
                        .number
                        .checked_add(1)
                        .ok_or(VaultFailure::Unsupported)?;
                    t.versions.push(version);
                }
            } else {
                d.templates.push(TemplateDefinitionV1 {
                    id: new_id()?,
                    versions: vec![version],
                });
            }
            Ok(())
        })
    }
    pub fn bindings_v1(
        &self,
        id: String,
        revision: u64,
        generation: u64,
    ) -> Result<Vec<ResourceBindingV1>, VaultFailure> {
        self.read_cards(generation, |d| {
            if d.revision != revision {
                return Err(VaultFailure::Stale);
            }
            Ok(d.cards[d.card_index(&id)?].bindings.clone())
        })
    }
    pub fn save_bindings_v1(
        &self,
        id: String,
        mut bindings: Vec<ResourceBindingV1>,
        revision: u64,
        generation: u64,
    ) -> Result<ContentSnapshotV2, VaultFailure> {
        self.mutate_cards(revision, generation, |d| {
            let idx = d.card_index(&id)?;
            for b in &mut bindings {
                if b.id.is_empty() {
                    b.id = new_id()?;
                } else if !d.cards[idx].bindings.iter().any(|old| old.id == b.id) {
                    return Err(VaultFailure::Unsupported);
                }
                b.target = normalize_target(b.kind, &b.target)?;
            }
            let mut card = d.cards[idx].clone();
            card.bindings = bindings;
            card.validate_bindings(d)?;
            d.replace_card(idx, card)
        })
    }
    pub fn custom_card_values_v1(
        &self,
        id: String,
        revision: u64,
        generation: u64,
    ) -> Result<Vec<CustomValueViewV1>, VaultFailure> {
        self.require_operation(OperationV1::Reveal, &id, generation)?;
        self.read_cards(generation, |d| {
            if d.revision != revision {
                return Err(VaultFailure::Stale);
            }
            d.cards[d.card_index(&id)?].custom_views()
        })
    }
    pub fn save_custom_card_v1(
        &self,
        input: CustomCardInputV1,
        revision: u64,
        generation: u64,
    ) -> Result<ContentSnapshotV2, VaultFailure> {
        self.mutate_cards(revision, generation, |d| {
            d.check_service_assignment(input.id.as_deref(), &input.service)?;
            if input
                .group_ids
                .iter()
                .any(|id| !d.groups.iter().any(|group| group.id == *id))
            {
                return Err(VaultFailure::Missing);
            }
            let definition = d
                .templates
                .iter()
                .find(|t| t.id == input.template_id)
                .ok_or(VaultFailure::Missing)?;
            let latest = definition
                .versions
                .last()
                .ok_or(VaultFailure::Corrupt)?
                .number;
            let previous = input.id.as_ref().map(|id| d.card_index(id)).transpose()?;
            let old = previous.map(|i| &d.cards[i]);
            if let Some(old) = old {
                if old
                    .custom
                    .as_ref()
                    .is_none_or(|c| c.template_id != input.template_id)
                {
                    return Err(VaultFailure::Unsupported);
                }
                if old.template_version != input.template_version
                    && (!input.accept_template_update || input.template_version != latest)
                {
                    return Err(VaultFailure::Confirmation);
                }
            } else if input.template_version != latest {
                return Err(VaultFailure::Stale);
            }
            let mut values = vec![];
            for v in input.values {
                if v.keep_file && v.file.is_some() {
                    return Err(VaultFailure::Unsupported);
                }
                let file = if let Some(f) = v.file {
                    let bytes = Zeroizing::new(f.bytes);
                    if bytes.len() > MAX_ATTACHMENT {
                        return Err(VaultFailure::Unsupported);
                    }
                    Some(StoredAttachment {
                        name: f.name,
                        data: BASE64.encode(&*bytes),
                    })
                } else if v.keep_file {
                    Some(
                        old.and_then(|c| c.custom.as_ref())
                            .and_then(|c| c.values.iter().find(|o| o.field_id == v.field_id))
                            .and_then(|v| v.file.clone())
                            .ok_or(VaultFailure::Missing)?,
                    )
                } else {
                    None
                };
                values.push(CustomStoredValue {
                    field_id: v.field_id,
                    value: v.value,
                    file,
                });
            }
            let mut card = StoredCard {
                id: if let Some(id) = input.id {
                    id
                } else {
                    new_id()?
                },
                name: input.name.trim().into(),
                description: input.description,
                service: input.service,
                environment: input.environment,
                group_ids: input.group_ids,
                card_type: CardTypeV1::Custom,
                template_version: input.template_version,
                fields: vec![],
                attachment: None,
                bindings: old.map(|c| c.bindings.clone()).unwrap_or_default(),
                custom: Some(CustomCardDataV1 {
                    template_id: input.template_id,
                    values,
                }),
            };
            card.group_ids.sort();
            card.group_ids.dedup();
            if input.accept_template_update {
                let fields = card.field_ids(d)?;
                for b in &mut card.bindings {
                    b.fields.retain(|f| fields.contains(f));
                }
                card.bindings.retain(|b| !b.fields.is_empty());
            }
            card.validate(d)?;
            if let Some(i) = previous {
                d.replace_card(i, card)?;
            } else {
                d.cards.push(card);
            }
            Ok(())
        })
    }
    pub fn custom_field_value_v1(
        &self,
        id: String,
        field_id: String,
        copy: bool,
        revision: u64,
        generation: u64,
    ) -> Result<String, VaultFailure> {
        self.require_operation(
            if copy {
                OperationV1::Copy
            } else {
                OperationV1::Reveal
            },
            &format!("{id}:custom:{field_id}"),
            generation,
        )?;
        self.read_cards(generation, |doc| {
            if doc.revision != revision {
                return Err(VaultFailure::Stale);
            }
            let card = &doc.cards[doc.card_index(&id)?];
            let custom = card.custom.as_ref().ok_or(VaultFailure::Unsupported)?;
            let field = doc
                .template(&custom.template_id, card.template_version)?
                .fields
                .iter()
                .find(|f| f.id == field_id)
                .ok_or(VaultFailure::Missing)?;
            let value = custom
                .values
                .iter()
                .find(|f| f.field_id == field_id && !f.value.is_empty())
                .ok_or(VaultFailure::Missing)?;
            if field.kind == CustomFieldKindV1::Otp {
                let normalized = Zeroizing::new(vec![CardValueV1 {
                    id: FieldIdV1::TotpSeed,
                    value: value.value.clone(),
                }]);
                return Ok(super::super::otp::current_code(&normalized)?.code);
            }
            Ok(value.value.clone())
        })
    }
    pub fn history_v1(
        &self,
        card_id: Option<String>,
        revision: u64,
        generation: u64,
    ) -> Result<Vec<HistorySummaryV1>, VaultFailure> {
        self.read_cards(generation, |d| {
            if d.revision != revision {
                return Err(VaultFailure::Stale);
            }
            let mut entries: Vec<_> = d
                .history
                .iter()
                .rev()
                .filter(|h| card_id.as_ref().is_none_or(|id| h.card.id == *id))
                .map(|h| HistorySummaryV1 {
                    id: h.id.clone(),
                    at: h.at,
                    card_id: h.card.id.clone(),
                    name: h.card.name.clone(),
                    service: h.card.service.clone(),
                })
                .collect();
            entries.sort_by_key(|entry| std::cmp::Reverse(entry.at));
            Ok(entries)
        })
    }
    pub fn historical_card_v1(
        &self,
        id: String,
        revision: u64,
        generation: u64,
    ) -> Result<HistoricalCardV1, VaultFailure> {
        self.require_operation(OperationV1::Reveal, &format!("history:{id}"), generation)?;
        self.read_cards(generation, |d| {
            if d.revision != revision {
                return Err(VaultFailure::Stale);
            }
            let card = &d
                .history
                .iter()
                .find(|h| h.id == id)
                .ok_or(VaultFailure::Missing)?
                .card;
            Ok(HistoricalCardV1 {
                summary: card.summary(),
                description: card.description.clone(),
                fields: card.fields.clone(),
                custom_values: card.custom_views()?,
                bindings: card.bindings.clone(),
                attachment: card
                    .attachment
                    .as_ref()
                    .map(StoredAttachment::summary)
                    .transpose()?,
            })
        })
    }
    pub fn restore_history_v1(
        &self,
        id: String,
        revision: u64,
        generation: u64,
    ) -> Result<ContentSnapshotV2, VaultFailure> {
        self.require_operation(
            OperationV1::Protection,
            &format!("history:{id}"),
            generation,
        )?;
        self.mutate_cards(revision, generation, |d| {
            let mut card = d
                .history
                .iter()
                .find(|h| h.id == id)
                .ok_or(VaultFailure::Missing)?
                .card
                .clone();
            card.group_ids
                .retain(|g| d.groups.iter().any(|known| known.id == *g));
            if card.card_type == CardTypeV1::Hotp {
                use super::super::otp::field;
                let seed = field(&card.fields, FieldIdV1::HotpSeed);
                let max_counter = d
                    .cards
                    .iter()
                    .chain(d.history.iter().map(|entry| &entry.card))
                    .filter(|other| {
                        other.id == card.id && field(&other.fields, FieldIdV1::HotpSeed) == seed
                    })
                    .filter_map(|other| {
                        field(&other.fields, FieldIdV1::Counter)?
                            .parse::<u64>()
                            .ok()
                    })
                    .max()
                    .ok_or(VaultFailure::Corrupt)?;
                let counter = card
                    .fields
                    .iter_mut()
                    .find(|f| f.id == FieldIdV1::Counter)
                    .ok_or(VaultFailure::Corrupt)?;
                counter.value = max_counter.to_string();
            }
            if let Ok(i) = d.card_index(&card.id) {
                d.archive(i)?;
                d.cards[i] = card;
            } else {
                d.cards.push(card);
            }
            Ok(())
        })
    }
    pub fn clear_history_v1(
        &self,
        card_id: Option<String>,
        confirmed: bool,
        revision: u64,
        generation: u64,
    ) -> Result<ContentSnapshotV2, VaultFailure> {
        if !confirmed {
            return Err(VaultFailure::Confirmation);
        }
        let subject = card_id
            .as_ref()
            .map(|id| format!("history:{id}"))
            .unwrap_or_else(|| "history".into());
        self.require_operation(OperationV1::Delete, &subject, generation)?;
        self.mutate_cards(revision, generation, |d| {
            d.history
                .retain(|h| card_id.as_ref().is_some_and(|id| h.card.id != *id));
            Ok(())
        })
    }
}

#[cfg(test)]
mod retention_tests {
    use super::*;
    #[test]
    fn expiration_is_inclusive_at_the_365_day_boundary() {
        let mut doc = DocumentV2::decode(b"").unwrap();
        let card = StoredCard {
            id: "aa".repeat(16),
            name: "Fixture".into(),
            description: String::new(),
            service: "github".into(),
            environment: None,
            group_ids: vec![],
            card_type: CardTypeV1::Account,
            template_version: 1,
            fields: vec![],
            attachment: None,
            bindings: vec![],
            custom: None,
        };
        for (n, at) in [10, 11, 12].into_iter().enumerate() {
            doc.history.push(CardRevision {
                id: format!("{n:032x}"),
                at,
                card: card.clone(),
            });
        }
        doc.prune_history(11 + YEAR);
        assert_eq!(doc.history.len(), 1);
        assert_eq!(doc.history[0].at, 12);
    }
}
