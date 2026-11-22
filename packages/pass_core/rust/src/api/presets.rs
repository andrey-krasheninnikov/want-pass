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
        C::ApiKey,
        C::Totp,
        C::AwsIam,
        C::GoogleCloudKey,
        C::AzureAppSecret,
        C::BearerToken,
        C::AppPassword,
        C::SshCertificate,
        C::KubernetesToken,
        C::OpenVpn,
        C::Ipsec,
        C::KeyContainer,
        C::ArtifactSigningKey,
        C::ApnsKey,
        C::AppStoreConnectKey,
        C::RegistryAccess,
        C::EnvironmentVariables,
        C::SmtpAccess,
        C::PresignedUrl,
        C::SessionCookie,
        C::Hotp,
        C::LicenseKey,
        C::Wifi,
        C::DevicePin,
        C::SimPinPuk,
        C::PaymentCard,
        C::BankDetails,
        C::IdentityDocument,
        C::WalletMnemonic,
        C::WalletPrivateKey,
    ]
    .into_iter()
    .map(|card_type| CardPresetV1 {
        card_type,
        fields: specs(card_type),
    })
    .collect()
}
pub(super) fn specs(kind: C) -> Vec<FieldSpecV1> {
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
        C::File | C::Custom => &[],
        C::Pat => &[(F::Value, true), (F::Scopes, false), (F::ExpiresAt, false)],
        C::ApiKey => &[(F::Value, true), (F::KeyId, false)],
        C::Totp => &[
            (F::TotpSeed, true),
            (F::TotpAlgorithm, false),
            (F::TotpDigits, false),
            (F::TotpPeriod, false),
        ],
        C::AwsIam => &[
            (F::AccessKeyId, true),
            (F::Value, true),
            (F::SessionToken, false),
        ],
        C::GoogleCloudKey => &[(F::JsonKey, true), (F::Project, true)],
        C::AzureAppSecret => &[
            (F::TenantId, true),
            (F::ClientId, true),
            (F::ClientSecret, true),
        ],
        C::BearerToken => &[(F::Value, true), (F::ExpiresAt, false)],
        C::AppPassword => &[(F::Password, true)],
        C::SshCertificate => &[(F::Certificate, true), (F::PrivateKey, true)],
        C::KubernetesToken => &[
            (F::Value, true),
            (F::Namespace, true),
            (F::AccountName, true),
        ],
        C::OpenVpn => &[
            (F::Configuration, true),
            (F::PrivateKey, false),
            (F::Certificate, false),
        ],
        C::Ipsec => &[
            (F::Identity, true),
            (F::Value, false),
            (F::Certificate, false),
        ],
        C::KeyContainer => &[(F::ContainerFormat, true), (F::Password, true)],
        C::ArtifactSigningKey => &[(F::PrivateKey, true), (F::KeyId, true)],
        C::ApnsKey => &[(F::PrivateKey, true), (F::KeyId, true), (F::TeamId, true)],
        C::AppStoreConnectKey => &[(F::PrivateKey, true), (F::KeyId, true), (F::IssuerId, true)],
        C::RegistryAccess => &[
            (F::Endpoint, true),
            (F::Login, true),
            (F::Password, false),
            (F::AccessToken, false),
        ],
        C::EnvironmentVariables => &[(F::Variables, true)],
        C::SmtpAccess => &[
            (F::Endpoint, true),
            (F::Login, true),
            (F::Password, false),
            (F::AccessToken, false),
        ],
        C::PresignedUrl => &[(F::Url, true), (F::ExpiresAt, true)],
        C::SessionCookie => &[
            (F::Domain, true),
            (F::CookieName, true),
            (F::Value, true),
            (F::ExpiresAt, false),
        ],
        C::Hotp => &[(F::HotpSeed, true), (F::Counter, true)],
        C::LicenseKey => &[(F::Product, true), (F::Value, true), (F::ExpiresAt, false)],
        C::Wifi => &[(F::Ssid, true), (F::Password, true)],
        C::DevicePin => &[(F::Device, true), (F::Pin, true)],
        C::SimPinPuk => &[(F::Carrier, true), (F::Pin, true), (F::Puk, true)],
        C::PaymentCard => &[
            (F::CardNumber, true),
            (F::Holder, true),
            (F::ExpiryMonth, true),
        ],
        C::BankDetails => &[
            (F::Holder, true),
            (F::Iban, false),
            (F::AccountNumber, false),
            (F::Bic, false),
        ],
        C::IdentityDocument => &[
            (F::DocumentType, true),
            (F::DocumentNumber, true),
            (F::Authority, true),
            (F::ExpiresAt, false),
        ],
        C::WalletMnemonic => &[(F::Mnemonic, true), (F::WalletPassphrase, false)],
        C::WalletPrivateKey => &[
            (F::Network, true),
            (F::Address, true),
            (F::PrivateKey, true),
        ],
        _ => &[(F::Value, true)],
    };
    fields
        .iter()
        .map(|(id, required)| {
            let multiline = matches!(
                id,
                F::PublicKey
                    | F::PrivateKey
                    | F::Certificate
                    | F::RecoveryCodes
                    | F::ReserveLogins
                    | F::JsonKey
                    | F::Configuration
                    | F::Variables
                    | F::Scopes
                    | F::Mnemonic
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
                        | F::KeyId
                        | F::AccessKeyId
                        | F::Project
                        | F::TenantId
                        | F::ExpiresAt
                        | F::Namespace
                        | F::AccountName
                        | F::ContainerFormat
                        | F::TeamId
                        | F::IssuerId
                        | F::Endpoint
                        | F::Domain
                        | F::CookieName
                        | F::Counter
                        | F::Product
                        | F::Ssid
                        | F::Device
                        | F::Carrier
                        | F::ExpiryMonth
                        | F::DocumentType
                        | F::Network
                        | F::Address
                        | F::Scopes
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
