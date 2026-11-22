use super::{Vault, VaultFailure, cards::DocumentV2};
use crate::format;
use serde::{Deserialize, Serialize};
use std::time::{Duration, Instant, SystemTime, UNIX_EPOCH};
use totp_rs::{Builder, Secret};
use zeroize::{Zeroize, ZeroizeOnDrop, Zeroizing};

#[derive(Clone, Copy, Debug, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum OperationV1 {
    Reveal,
    Copy,
    Export,
    Transfer,
    IntegrationGrant,
    RecoveryKit,
    Delete,
    Protection,
}

#[derive(Default, Clone, Serialize, Deserialize, Zeroize, ZeroizeOnDrop)]
#[serde(deny_unknown_fields)]
#[flutter_rust_bridge::frb(ignore)]
pub(crate) struct Policy {
    seed: Option<String>,
    #[zeroize(skip)]
    operations: Vec<OperationV1>,
    last_step: Option<u64>,
    failures: u8,
    retry_after: u64,
    version: u64,
}

impl Policy {
    pub(crate) fn is_empty(&self) -> bool {
        self.seed.is_none() && self.version == 0
    }

    pub(crate) fn requires(&self, action: OperationV1) -> bool {
        self.seed.is_some()
            && (action == OperationV1::Protection || self.operations.contains(&action))
    }

    fn accept(&mut self, input: &str, now: u64) -> Result<bool, VaultFailure> {
        if now < self.retry_after {
            return Err(VaultFailure::Credentials);
        }
        let seed = self.seed.as_ref().ok_or(VaultFailure::Confirmation)?;
        let step = verifier(seed)?.check(input, now);
        if let Some(step) = step.filter(|step| self.last_step.is_none_or(|last| *step > last)) {
            self.last_step = Some(step);
            self.failures = 0;
            self.retry_after = 0;
            return Ok(true);
        }
        self.failures = self.failures.saturating_add(1);
        if self.failures >= 5 {
            self.retry_after = now.saturating_add(30_u64 << (self.failures - 5).min(5));
        }
        Ok(false)
    }
}

pub struct ProtectionSettingsV1 {
    pub enrolled: bool,
    pub operations: Vec<OperationV1>,
}

#[flutter_rust_bridge::frb(ignore)]
struct Permit {
    action: OperationV1,
    subject: String,
    version: u64,
    revision: u64,
    expires: Instant,
}

#[derive(Default)]
#[flutter_rust_bridge::frb(ignore)]
pub(super) struct Pending {
    enrollment: Option<(Zeroizing<String>, Instant, u8)>,
    permit: Option<Permit>,
}

fn seconds() -> Result<u64, VaultFailure> {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|d| d.as_secs())
        .map_err(|_| VaultFailure::Unavailable)
}

fn verifier(seed: &str) -> Result<totp_rs::Totp, VaultFailure> {
    Builder::new()
        .with_secret(Secret::try_from_base32(seed).map_err(|_| VaultFailure::Corrupt)?)
        .with_digits(6)
        .with_step_duration(30)
        .with_skew(1)
        .build()
        .map_err(|_| VaultFailure::Corrupt)
}

fn validate_operations(operations: &[OperationV1]) -> Result<(), VaultFailure> {
    if operations.len() > 8
        || operations
            .iter()
            .enumerate()
            .any(|(i, op)| operations[..i].contains(op))
    {
        return Err(VaultFailure::Unsupported);
    }
    Ok(())
}

#[derive(Default, Deserialize)]
#[flutter_rust_bridge::frb(ignore)]
struct PolicyView {
    #[serde(default)]
    policy: Policy,
    #[serde(default)]
    revision: u64,
}

fn view(bytes: &[u8]) -> Result<PolicyView, VaultFailure> {
    if bytes.is_empty() {
        return Ok(PolicyView::default());
    }
    serde_json::from_slice(bytes).map_err(|_| VaultFailure::Corrupt)
}

pub(super) fn after_recovery(bytes: &[u8]) -> Result<Zeroizing<Vec<u8>>, VaultFailure> {
    if bytes.iter().find(|c| !c.is_ascii_whitespace()) != Some(&b'{')
        || view(bytes)?.policy.is_empty()
    {
        return Ok(Zeroizing::new(bytes.to_vec()));
    }
    let mut document = DocumentV2::decode(bytes)?;
    document.policy = Policy::default();
    serde_json::to_vec(&document)
        .map(Zeroizing::new)
        .map_err(|_| VaultFailure::Corrupt)
}

impl Vault {
    fn update_policy<T>(
        &self,
        generation: u64,
        edit: impl FnOnce(&mut Policy, u64) -> Result<T, VaultFailure>,
    ) -> Result<T, VaultFailure> {
        self.update_document_scoped(generation, |bytes| {
            let mut doc = DocumentV2::decode(bytes)?;
            let previous_version = doc.policy.version;
            let result = edit(&mut doc.policy, doc.revision)?;
            let changed = previous_version != doc.policy.version;
            if changed {
                doc.schema = 3;
                doc.revision = doc
                    .revision
                    .checked_add(1)
                    .ok_or(VaultFailure::Unsupported)?;
            }
            let encoded = serde_json::to_vec(&doc).map_err(|_| VaultFailure::Storage)?;
            Ok((Zeroizing::new(encoded), result, changed))
        })
    }

    pub fn protection_settings_v1(
        &self,
        generation: u64,
    ) -> Result<ProtectionSettingsV1, VaultFailure> {
        let state = self.state.lock().map_err(|_| VaultFailure::Unavailable)?;
        if self.generation() != generation {
            return Err(VaultFailure::Stale);
        }
        let p = view(&state.active.as_ref().ok_or(VaultFailure::Locked)?.document)?.policy;
        Ok(ProtectionSettingsV1 {
            enrolled: p.seed.is_some(),
            operations: p.operations.clone(),
        })
    }

    pub fn begin_external_totp_v1(&self, generation: u64) -> Result<String, VaultFailure> {
        let mut state = self.state.lock().map_err(|_| VaultFailure::Unavailable)?;
        if self.generation() != generation {
            return Err(VaultFailure::Stale);
        }
        if view(&state.active.as_ref().ok_or(VaultFailure::Locked)?.document)?
            .policy
            .seed
            .is_some()
        {
            return Err(VaultFailure::Exists);
        }
        let seed = Zeroizing::new(Secret::from(format::random::<20>()?).to_base32());
        let result = seed.to_string();
        state.authorization.enrollment = Some((seed, Instant::now() + Duration::from_secs(300), 0));
        Ok(result)
    }

    pub fn enroll_external_totp_v1(
        &self,
        code: String,
        operations: Vec<OperationV1>,
        generation: u64,
    ) -> Result<(), VaultFailure> {
        let code = Zeroizing::new(code);
        validate_operations(&operations)?;
        let (seed, step) = {
            let mut state = self.state.lock().map_err(|_| VaultFailure::Unavailable)?;
            if self.generation() != generation || state.active.is_none() {
                return Err(VaultFailure::Stale);
            }
            let (seed, expires, failures) = state
                .authorization
                .enrollment
                .as_mut()
                .ok_or(VaultFailure::Confirmation)?;
            if Instant::now() >= *expires || *failures >= 5 {
                return Err(VaultFailure::Confirmation);
            }
            *failures += 1;
            let step = verifier(seed)?
                .check(&code, seconds()?)
                .ok_or(VaultFailure::Credentials)?;
            (seed.clone(), step)
        };
        self.update_policy(generation, |p, _| {
            if p.seed.is_some() {
                return Err(VaultFailure::Exists);
            }
            p.version = p.version.checked_add(1).ok_or(VaultFailure::Corrupt)?;
            p.seed = Some(seed.to_string());
            p.operations = operations;
            p.last_step = Some(step);
            Ok(())
        })?;
        Ok(())
    }

    pub fn configure_external_totp_v1(
        &self,
        code: String,
        operations: Vec<OperationV1>,
        disable: bool,
        generation: u64,
    ) -> Result<(), VaultFailure> {
        validate_operations(&operations)?;
        let code = Zeroizing::new(code);
        let accepted = self.update_policy(generation, |p, _| {
            if !p.accept(&code, seconds()?)? {
                return Ok(false);
            }
            p.version = p.version.checked_add(1).ok_or(VaultFailure::Corrupt)?;
            if disable {
                p.seed.zeroize();
                p.seed = None;
                p.last_step = None;
                p.operations.clear();
            } else {
                p.operations = operations;
            }
            Ok(true)
        })?;
        if accepted {
            Ok(())
        } else {
            Err(VaultFailure::Credentials)
        }
    }

    pub fn authorize_operation_v1(
        &self,
        action: OperationV1,
        subject: String,
        code: String,
        generation: u64,
    ) -> Result<(), VaultFailure> {
        if subject.len() > 8192 {
            return Err(VaultFailure::Unsupported);
        }
        let code = Zeroizing::new(code);
        let (accepted, version, revision) = self.update_policy(generation, |p, revision| {
            if !p.requires(action) {
                return Err(VaultFailure::Confirmation);
            }
            Ok((p.accept(&code, seconds()?)?, p.version, revision))
        })?;
        if !accepted {
            return Err(VaultFailure::Credentials);
        }
        let mut state = self.state.lock().map_err(|_| VaultFailure::Unavailable)?;
        if state.active.is_none() || self.generation() != generation {
            return Err(VaultFailure::Stale);
        }
        state.authorization.permit = Some(Permit {
            action,
            subject,
            version,
            revision,
            expires: Instant::now() + Duration::from_secs(30),
        });
        Ok(())
    }

    pub(crate) fn require_operation(
        &self,
        action: OperationV1,
        subject: &str,
        generation: u64,
    ) -> Result<(), VaultFailure> {
        let mut state = self.state.lock().map_err(|_| VaultFailure::Unavailable)?;
        if self.generation() != generation {
            return Err(VaultFailure::Stale);
        }
        let data = view(&state.active.as_ref().ok_or(VaultFailure::Locked)?.document)?;
        if !data.policy.requires(action) {
            return Ok(());
        }
        if state.authorization.permit.as_ref().is_some_and(|p| {
            p.action == action
                && p.subject == subject
                && p.version == data.policy.version
                && p.revision == data.revision
                && Instant::now() < p.expires
        }) {
            state.authorization.permit = None;
            Ok(())
        } else {
            Err(VaultFailure::Confirmation)
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn fresh_code_authorizes_one_subject_and_operation_until_lock() {
        let directory = tempfile::tempdir().unwrap();
        let vault = Vault::open(directory.path().join("vault").to_str().unwrap().into()).unwrap();
        let pass = "Synthetic operation policy 2026!";
        let draft = vault
            .prepare_creation(pass.into(), vault.generation())
            .unwrap();
        vault
            .confirm(
                draft
                    .positions
                    .iter()
                    .map(|p| draft.words[*p as usize].clone())
                    .collect(),
                vault.generation(),
            )
            .unwrap();
        let first = vault.generation();
        let seed = vault.begin_external_totp_v1(first).unwrap();
        let now = seconds().unwrap();
        let totp = verifier(&seed).unwrap();
        let initial = totp.generate(now.saturating_sub(30)).to_string();
        let code = totp.generate(now).to_string();
        let actions = vec![OperationV1::Reveal, OperationV1::Copy];
        vault
            .enroll_external_totp_v1(initial, actions, first)
            .unwrap();
        let generation = vault.generation();
        assert_ne!(first, generation);
        assert_eq!(
            vault.require_operation(OperationV1::Reveal, "field", first),
            Err(VaultFailure::Stale)
        );
        assert_eq!(
            vault.require_operation(OperationV1::Reveal, "field", generation),
            Err(VaultFailure::Confirmation)
        );
        vault
            .authorize_operation_v1(
                OperationV1::Reveal,
                "field".into(),
                code.clone(),
                generation,
            )
            .unwrap();
        assert_eq!(
            vault.require_operation(OperationV1::Copy, "field", generation),
            Err(VaultFailure::Confirmation)
        );
        assert_eq!(
            vault.require_operation(OperationV1::Reveal, "other", generation),
            Err(VaultFailure::Confirmation)
        );
        vault
            .require_operation(OperationV1::Reveal, "field", generation)
            .unwrap();
        assert_eq!(
            vault.require_operation(OperationV1::Reveal, "field", generation),
            Err(VaultFailure::Confirmation)
        );
        vault.lock().unwrap();
        vault.unlock(pass.into(), vault.generation()).unwrap();
        assert_eq!(
            vault.authorize_operation_v1(
                OperationV1::Reveal,
                "field".into(),
                code,
                vault.generation()
            ),
            Err(VaultFailure::Credentials)
        );
        // Only a confirmed recovery with the complete offline phrase drops the policy.
        vault.lock().unwrap();
        let pending = vault
            .prepare_recovery(
                draft.words.join(" "),
                "New synthetic operation policy 2026!".into(),
                vault.generation(),
            )
            .unwrap();
        vault
            .confirm(
                pending
                    .positions
                    .iter()
                    .map(|n| pending.words[*n as usize].clone())
                    .collect(),
                vault.generation(),
            )
            .unwrap();
        assert!(
            !vault
                .protection_settings_v1(vault.generation())
                .unwrap()
                .enrolled
        );
    }

    #[test]
    fn fresh_counter_is_single_use_and_attempt_limit_survives_serialization() {
        let mut policy = Policy::default();
        policy.seed = Some(Secret::from(*b"12345678901234567890").to_base32());
        assert!(policy.accept("287082", 59).unwrap());
        assert!(!policy.accept("287082", 60).unwrap());
        for _ in 0..4 {
            assert!(!policy.accept("000000", 61).unwrap());
        }
        let serialized = serde_json::to_vec(&policy).unwrap();
        let mut restored: Policy = serde_json::from_slice(&serialized).unwrap();
        assert_eq!(
            restored.accept("359152", 90),
            Err(VaultFailure::Credentials)
        );
        assert!(restored.accept("969429", 92).unwrap());
    }
}
