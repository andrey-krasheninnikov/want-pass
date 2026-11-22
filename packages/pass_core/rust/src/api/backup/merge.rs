use super::*;
use serde_json::Value;
use sha2::{Digest, Sha256};
use std::collections::{BTreeMap, BTreeSet};
use zeroize::Zeroize;

const KINDS: [BackupEntityV1; 5] = [
    BackupEntityV1::Group,
    BackupEntityV1::Service,
    BackupEntityV1::Template,
    BackupEntityV1::Card,
    BackupEntityV1::History,
];

impl BackupEntityV1 {
    fn collection(self) -> &'static str {
        match self {
            Self::Group => "groups",
            Self::Service => "services",
            Self::Template => "templates",
            Self::Card => "cards",
            Self::History => "history",
        }
    }
}

#[derive(Clone, PartialEq, Serialize, Deserialize)]
#[serde(transparent)]
struct Record(Value);

fn wipe(value: &mut Value) {
    match value {
        Value::String(s) => s.zeroize(),
        Value::Array(a) => a.iter_mut().for_each(wipe),
        Value::Object(o) => o.values_mut().for_each(wipe),
        _ => {}
    }
}
impl Drop for Record {
    fn drop(&mut self) {
        wipe(&mut self.0);
    }
}
impl Record {
    fn id(&self) -> Result<&str, VaultFailure> {
        self.0
            .get("id")
            .and_then(Value::as_str)
            .ok_or(VaultFailure::Corrupt)
    }
    fn name(&self) -> String {
        self.0
            .get("name")
            .or_else(|| self.0.pointer("/card/name"))
            .or_else(|| self.0.get("versions")?.as_array()?.last()?.get("name"))
            .and_then(Value::as_str)
            .unwrap_or("")
            .to_owned()
    }
}

#[derive(Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub(super) struct Portable {
    schema: u32,
    pub(super) revision: u64,
    groups: Vec<Record>,
    cards: Vec<Record>,
    #[serde(default)]
    services: Vec<Record>,
    #[serde(default)]
    templates: Vec<Record>,
    #[serde(default)]
    history: Vec<Record>,
}

pub(super) struct LiveProjection {
    document: Record,
    pub(super) removed_profiles: u32,
}
impl LiveProjection {
    pub(super) fn encode(mut self, revision: u64) -> Result<Zeroizing<Vec<u8>>, VaultFailure> {
        self.document.0["revision"] = Value::from(revision);
        let result =
            Zeroizing::new(serde_json::to_vec(&self.document).map_err(|_| VaultFailure::Corrupt)?);
        if result.len() > crate::format::MAX_FILE {
            return Err(VaultFailure::Unsupported);
        }
        cards::DocumentV2::decode(&result)?;
        Ok(result)
    }
}

type Remap = BTreeMap<BackupEntityV1, BTreeMap<String, String>>;

fn remap_ref(value: Option<&mut Value>, kind: BackupEntityV1, maps: &Remap) {
    if let Some(Value::String(id)) = value
        && let Some(mapped) = maps.get(&kind).and_then(|m| m.get(id))
    {
        id.clone_from(mapped);
    }
}

fn remap_card(card: &mut Value, maps: &Remap) {
    remap_ref(card.get_mut("service"), BackupEntityV1::Service, maps);
    if let Some(Value::Array(ids)) = card.get_mut("group_ids") {
        for id in ids {
            remap_ref(Some(id), BackupEntityV1::Group, maps);
        }
    }
    remap_ref(
        card.pointer_mut("/custom/template_id"),
        BackupEntityV1::Template,
        maps,
    );
}

fn rewrite_references(record: &mut Record, kind: BackupEntityV1, maps: &Remap) {
    if kind == BackupEntityV1::Card {
        remap_card(&mut record.0, maps);
    }
    if kind == BackupEntityV1::History
        && let Some(card) = record.0.get_mut("card")
    {
        remap_ref(card.get_mut("id"), BackupEntityV1::Card, maps);
        remap_card(card, maps);
    }
}

fn alternative_id(source: &[u8; 16], kind: BackupEntityV1, original: &str, count: u32) -> String {
    let mut h = Sha256::new();
    h.update(b"WantPass/backup-fork/v1");
    h.update(source);
    h.update(kind.collection());
    h.update(original);
    h.update(count.to_be_bytes());
    h.finalize()[..16]
        .iter()
        .map(|b| format!("{b:02x}"))
        .collect()
}

impl Portable {
    pub(super) fn from_live(bytes: &[u8]) -> Result<Self, VaultFailure> {
        serde_json::from_slice(&cards::portable_document(bytes)?)
            .map_err(|_| VaultFailure::Unsupported)
    }
    pub(super) fn from_archive(bytes: &[u8]) -> Result<Self, VaultFailure> {
        let file: Self = serde_json::from_slice(bytes).map_err(|_| VaultFailure::Corrupt)?;
        if file.schema != 3 {
            return Err(VaultFailure::Unsupported);
        }
        drop(file);
        Self::from_live(bytes)
    }
    pub(super) fn encode(&self) -> Result<Zeroizing<Vec<u8>>, VaultFailure> {
        serde_json::to_vec(self)
            .map(Zeroizing::new)
            .map_err(|_| VaultFailure::Corrupt)
    }
    fn records(&mut self, kind: BackupEntityV1) -> &mut Vec<Record> {
        match kind {
            BackupEntityV1::Group => &mut self.groups,
            BackupEntityV1::Service => &mut self.services,
            BackupEntityV1::Template => &mut self.templates,
            BackupEntityV1::Card => &mut self.cards,
            BackupEntityV1::History => &mut self.history,
        }
    }
    pub(super) fn project_live(
        &self,
        live: &[u8],
        strategy: BackupStrategyV1,
    ) -> Result<LiveProjection, VaultFailure> {
        let mut removed_profiles = 0;
        let mut out = Record(serde_json::to_value(self).map_err(|_| VaultFailure::Corrupt)?);
        if !live.is_empty() {
            let mut original: Record =
                serde_json::from_slice(live).map_err(|_| VaultFailure::Corrupt)?;
            let obj = original.0.as_object_mut().ok_or(VaultFailure::Corrupt)?;
            let profile_count = obj
                .get("ssh_profiles")
                .and_then(Value::as_array)
                .map_or(0, Vec::len);
            if strategy == BackupStrategyV1::Replace {
                obj.remove("ssh_profiles");
            } else if profile_count > 0 {
                let incoming: BTreeMap<_, _> = self
                    .cards
                    .iter()
                    .filter_map(|record| Some((record.id().ok()?, &record.0)))
                    .collect();
                let unchanged_keys: BTreeSet<_> = obj
                    .get("cards")
                    .and_then(Value::as_array)
                    .into_iter()
                    .flatten()
                    .filter_map(|card| {
                        let id = card.get("id")?.as_str()?;
                        let next = incoming.get(id)?;
                        [
                            "card_type",
                            "environment",
                            "service",
                            "fields",
                            "bindings",
                            "custom",
                            "attachment",
                        ]
                        .iter()
                        .all(|key| card.get(*key) == next.get(*key))
                        .then(|| id.to_owned())
                    })
                    .collect();
                if let Some(Value::Array(profiles)) = obj.get_mut("ssh_profiles") {
                    profiles.retain(|profile| {
                        profile
                            .get("key_id")
                            .and_then(Value::as_str)
                            .is_some_and(|id| unchanged_keys.contains(id))
                    });
                }
            }
            let retained = obj
                .get("ssh_profiles")
                .and_then(Value::as_array)
                .map_or(0, Vec::len);
            removed_profiles = (profile_count - retained)
                .try_into()
                .map_err(|_| VaultFailure::Unsupported)?;
            let keys: Vec<_> = obj
                .keys()
                .filter(|key| {
                    key.as_str() != "schema"
                        && key.as_str() != "revision"
                        && !KINDS.iter().any(|k| k.collection() == key.as_str())
                })
                .cloned()
                .collect();
            for key in keys {
                let value = obj.remove(&key).ok_or(VaultFailure::Corrupt)?;
                out.0
                    .as_object_mut()
                    .ok_or(VaultFailure::Corrupt)?
                    .insert(key, value);
            }
        }
        Ok(LiveProjection {
            document: out,
            removed_profiles,
        })
    }

    pub(super) fn restore(
        &mut self,
        mut incoming: Self,
        source_id: [u8; 16],
        source_hash: [u8; 32],
        strategy: BackupStrategyV1,
        choices: Vec<BackupChoiceV1>,
    ) -> Result<BackupPreviewV1, VaultFailure> {
        let mut selected = BTreeMap::new();
        for c in choices {
            if selected.insert((c.entity, c.id), c.resolution).is_some() {
                return Err(VaultFailure::Confirmation);
            }
        }
        let mut report = BackupPreviewV1 {
            revision: self.revision,
            fingerprint: String::new(),
            added: 0,
            changed: 0,
            removed: 0,
            identical_count: 0,
            conflicts: vec![],
        };
        let mut maps = Remap::new();
        let mut archived = Vec::new();
        let mut fingerprint = Sha256::new();
        fingerprint.update(b"WantPass/restore-plan/v1");
        fingerprint.update(source_hash);
        fingerprint.update(self.revision.to_be_bytes());
        fingerprint.update([strategy as u8]);
        for kind in KINDS {
            let entries = std::mem::take(self.records(kind));
            let mut local: BTreeMap<String, Record> = BTreeMap::new();
            for e in entries {
                local.insert(e.id()?.to_owned(), e);
            }
            let imported = std::mem::take(incoming.records(kind));
            let reserved = imported
                .iter()
                .map(|r| r.id().map(str::to_owned))
                .collect::<Result<BTreeSet<_>, _>>()?;
            if strategy == BackupStrategyV1::Replace {
                report.removed +=
                    local.keys().filter(|key| !reserved.contains(*key)).count() as u32;
                for record in &imported {
                    match local.get(record.id()?) {
                        None => report.added += 1,
                        Some(l) if l == record => report.identical_count += 1,
                        Some(_) => report.changed += 1,
                    }
                }
                *self.records(kind) = imported;
                continue;
            }
            for mut entry in imported {
                rewrite_references(&mut entry, kind, &maps);
                let id = entry.id()?.to_owned();
                let Some(existing) = local.get(&id) else {
                    local.insert(id, entry);
                    report.added += 1;
                    continue;
                };
                if existing == &entry {
                    report.identical_count += 1;
                    continue;
                }
                let local_name = existing.name();
                let incoming_name = entry.name();
                // Stable aliases let another import of the same version find an earlier "keep both".
                let mut fork = String::new();
                let mut matched = false;
                for attempt in 0..=local.len() + reserved.len() {
                    let next = alternative_id(&source_id, kind, &id, attempt as u32);
                    if reserved.contains(&next) {
                        continue;
                    }
                    entry.0["id"] = Value::String(next.clone());
                    match local.get(&next) {
                        Some(other) if other != &entry => continue,
                        Some(_) => matched = true,
                        None => {}
                    }
                    fork = next;
                    break;
                }
                if fork.is_empty() {
                    return Err(VaultFailure::Corrupt);
                }
                if matched {
                    maps.entry(kind).or_default().insert(id, fork);
                    report.identical_count += 1;
                    continue;
                }
                let choice = selected.get(&(kind, id.clone())).copied();
                fingerprint.update(kind.collection());
                fingerprint.update((id.len() as u32).to_be_bytes());
                fingerprint.update(id.as_bytes());
                fingerprint.update([choice.map_or(255, |v| v as u8)]);
                report.conflicts.push(BackupConflictV1 {
                    entity: kind,
                    id: id.clone(),
                    local_name,
                    incoming_name,
                    resolution: choice,
                });
                match choice {
                    None | Some(BackupResolutionV1::Local) => {}
                    Some(BackupResolutionV1::Incoming) => {
                        if kind == BackupEntityV1::Card {
                            let card = serde_json::from_value(existing.0.clone())
                                .map_err(|_| VaultFailure::Corrupt)?;
                            let revision = cards::CardRevision::capture(card)?;
                            archived.push(Record(
                                serde_json::to_value(revision)
                                    .map_err(|_| VaultFailure::Corrupt)?,
                            ));
                            report.added += 1;
                        }
                        entry.0["id"] = Value::String(id.clone());
                        local.insert(id, entry);
                        report.changed += 1;
                    }
                    Some(BackupResolutionV1::Both) => {
                        maps.entry(kind).or_default().insert(id, fork.clone());
                        local.insert(fork, entry);
                        report.added += 1;
                    }
                }
            }
            *self.records(kind) = local.into_values().collect();
        }
        self.history.extend(archived);
        report.fingerprint = fingerprint
            .finalize()
            .iter()
            .map(|b| format!("{b:02x}"))
            .collect();
        Ok(report)
    }
}
