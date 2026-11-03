use super::{CardTypeV1 as C, CardValueV1, FieldIdV1 as F, VaultFailure};
use std::collections::BTreeSet;
pub struct FieldSpecV1 {
    pub id: super::FieldIdV1,
    pub required: bool,
    pub concealed: bool,
    pub multiline: bool,
    pub max_bytes: u32,
}
pub struct CardPresetV1 {
    pub card_type: super::CardTypeV1,
    pub fields: Vec<FieldSpecV1>,
}
pub fn card_presets_v1() -> Vec<CardPresetV1> {
    [
        C::Account,
        C::Pat,
        C::Rsa,
        C::Ed25519,
        C::SecretKey,
        C::Passphrase,
        C::RecoveryCodes,
        C::RecoveryUrl,
        C::SecretQa,
        C::Vless,
        C::WireGuard,
        C::Gpg,
        C::Certificate,
        C::OAuth,
        C::Dsn,
        C::Kubeconfig,
        C::WebhookSecret,
        C::SecureNote,
        C::File,
    ]
    .into_iter()
    .map(|card_type| CardPresetV1 {
        card_type,
        fields: specs(card_type),
    })
    .collect()
}
fn specs(kind: C) -> Vec<FieldSpecV1> {
    let fields: &[(F, bool)] = match kind {
        C::Account => &[
            (F::Login, true),
            (F::Password, true),
            (F::TotpSeed, false),
            (F::TotpAlgorithm, false),
            (F::TotpDigits, false),
            (F::TotpPeriod, false),
            (F::RecoveryCodes, false),
            (F::ReserveLogins, false),
        ],
        C::Rsa | C::Ed25519 | C::Gpg => &[(F::PublicKey, true), (F::PrivateKey, true)],
        C::Certificate => &[(F::Certificate, true), (F::PrivateKey, true)],
        C::OAuth => &[
            (F::ClientId, true),
            (F::ClientSecret, true),
            (F::AccessToken, false),
            (F::RefreshToken, false),
        ],
        C::SecretQa => &[(F::Question, true), (F::Answer, true)],
        C::RecoveryCodes => &[(F::RecoveryCodes, true)],
        C::File => &[],
        _ => &[(F::Value, true)],
    };
    fields
        .iter()
        .map(|(id, required)| {
            let multiline = matches!(
                id,
                F::PublicKey | F::PrivateKey | F::Certificate | F::RecoveryCodes | F::ReserveLogins
            ) || (*id == F::Value
                && matches!(kind, C::WireGuard | C::Kubeconfig | C::SecureNote));
            FieldSpecV1 {
                id: *id,
                required: *required,
                concealed: !matches!(
                    id,
                    F::Login
                        | F::TotpAlgorithm
                        | F::TotpDigits
                        | F::TotpPeriod
                        | F::PublicKey
                        | F::Certificate
                        | F::ClientId
                        | F::Question
                ),
                multiline,
                max_bytes: if *id == F::Login {
                    4096
                } else if multiline && !matches!(id, F::RecoveryCodes | F::ReserveLogins) {
                    1024 * 1024
                } else {
                    65536
                },
            }
        })
        .collect()
}
pub(super) fn validate_fields(kind: C, fields: &[CardValueV1]) -> Result<bool, VaultFailure> {
    let specs = specs(kind);
    let mut ids = BTreeSet::new();
    for value in fields {
        let spec = specs
            .iter()
            .find(|s| s.id == value.id)
            .ok_or(VaultFailure::Unsupported)?;
        if !ids.insert(value.id) {
            return Err(VaultFailure::Unsupported);
        }
        super::content::bounded(&value.value, spec.max_bytes as usize, false)?;
    }
    for spec in &specs {
        if spec.required
            && !fields
                .iter()
                .any(|v| v.id == spec.id && !v.value.is_empty())
        {
            return Err(VaultFailure::Unsupported);
        }
    }
    super::validation::validate(kind, fields)
}
