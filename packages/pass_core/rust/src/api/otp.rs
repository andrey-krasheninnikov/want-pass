use super::{CardValueV1, FieldIdV1, VaultFailure};
use flutter_rust_bridge::frb;
use std::{
    collections::BTreeSet,
    time::{SystemTime, UNIX_EPOCH},
};
use totp_rs::{Algorithm, Builder, Secret, Totp};
use zeroize::Zeroizing;
pub struct TotpCodeV1 {
    pub code: String,
    pub valid_until: u64,
    pub period: u64,
}
pub(super) fn field(fields: &[CardValueV1], id: FieldIdV1) -> Option<&str> {
    fields
        .iter()
        .find(|v| v.id == id && !v.value.is_empty())
        .map(|v| v.value.as_str())
}
fn build(seed: &str, algorithm: &str, digits: u8, period: u64) -> Result<Totp, VaultFailure> {
    if seed.len() > 1024 || !(1..=86400).contains(&period) || !(6..=8).contains(&digits) {
        return Err(VaultFailure::Unsupported);
    }
    let seed = Zeroizing::new(
        seed.chars()
            .filter(|c| !c.is_ascii_whitespace())
            .collect::<String>()
            .to_ascii_uppercase(),
    );
    let secret = Secret::try_from_base32(seed.as_str()).map_err(|_| VaultFailure::Unsupported)?;
    if secret.as_bytes().len() > 128 {
        return Err(VaultFailure::Unsupported);
    }
    let algorithm = match algorithm {
        "SHA1" => Algorithm::SHA1,
        "SHA256" => Algorithm::SHA256,
        "SHA512" => Algorithm::SHA512,
        _ => return Err(VaultFailure::Unsupported),
    };
    Builder::new()
        .with_secret(secret)
        .with_algorithm(algorithm)
        .with_digits(digits)
        .with_step_duration(period)
        .build()
        .map_err(|_| VaultFailure::Unsupported)
}
fn parameters(fields: &[CardValueV1]) -> Result<Option<Totp>, VaultFailure> {
    let Some(seed) = field(fields, FieldIdV1::TotpSeed) else {
        if [
            FieldIdV1::TotpAlgorithm,
            FieldIdV1::TotpDigits,
            FieldIdV1::TotpPeriod,
        ]
        .iter()
        .any(|id| field(fields, *id).is_some())
        {
            return Err(VaultFailure::Unsupported);
        }
        return Ok(None);
    };
    if seed.starts_with("otpauth:") {
        let url = url::Url::parse(seed).map_err(|_| VaultFailure::Unsupported)?;
        let mut keys = BTreeSet::new();
        if url.fragment().is_some()
            || !url.username().is_empty()
            || url.password().is_some()
            || url.port().is_some()
        {
            return Err(VaultFailure::Unsupported);
        }
        for (key, _) in url.query_pairs() {
            if !["secret", "algorithm", "digits", "period", "issuer"].contains(&key.as_ref())
                || !keys.insert(key.to_string())
            {
                return Err(VaultFailure::Unsupported);
            }
        }
        let value = Totp::from_url(seed).map_err(|_| VaultFailure::Unsupported)?;
        if !(1..=86400).contains(&value.step()) || value.secret().len() > 128 {
            return Err(VaultFailure::Unsupported);
        }
        return Ok(Some(value));
    }
    let digits = field(fields, FieldIdV1::TotpDigits)
        .unwrap_or("6")
        .parse()
        .map_err(|_| VaultFailure::Unsupported)?;
    let period = field(fields, FieldIdV1::TotpPeriod)
        .unwrap_or("30")
        .parse()
        .map_err(|_| VaultFailure::Unsupported)?;
    build(
        seed,
        field(fields, FieldIdV1::TotpAlgorithm).unwrap_or("SHA1"),
        digits,
        period,
    )
    .map(Some)
}
pub(super) fn validate_account_totp(fields: &[CardValueV1]) -> Result<(), VaultFailure> {
    parameters(fields).map(|_| ())
}
pub(super) fn normalize_totp(fields: &mut Vec<CardValueV1>) -> Result<(), VaultFailure> {
    let Some(value) = parameters(fields)? else {
        return Ok(());
    };
    fields.retain(|v| {
        ![
            FieldIdV1::TotpSeed,
            FieldIdV1::TotpAlgorithm,
            FieldIdV1::TotpDigits,
            FieldIdV1::TotpPeriod,
        ]
        .contains(&v.id)
    });
    fields.extend([
        CardValueV1 {
            id: FieldIdV1::TotpSeed,
            value: value.secret().to_base32(),
        },
        CardValueV1 {
            id: FieldIdV1::TotpAlgorithm,
            value: value.algorithm().to_string(),
        },
        CardValueV1 {
            id: FieldIdV1::TotpDigits,
            value: value.digits().to_string(),
        },
        CardValueV1 {
            id: FieldIdV1::TotpPeriod,
            value: value.step().to_string(),
        },
    ]);
    Ok(())
}
fn code(value: &Totp, time: u64) -> Result<TotpCodeV1, VaultFailure> {
    let valid_until = (time - time % value.step())
        .checked_add(value.step())
        .ok_or(VaultFailure::Unsupported)?;
    Ok(TotpCodeV1 {
        code: value.generate(time).to_string(),
        valid_until,
        period: value.step(),
    })
}
#[frb(ignore)]
pub fn totp_code_v1(
    seed: String,
    algorithm: String,
    digits: u8,
    period: u64,
    time: u64,
) -> Result<TotpCodeV1, VaultFailure> {
    let seed = Zeroizing::new(seed);
    code(&build(&seed, &algorithm, digits, period)?, time)
}
pub(super) fn current_code(fields: &[CardValueV1]) -> Result<TotpCodeV1, VaultFailure> {
    let value = parameters(fields)?.ok_or(VaultFailure::Missing)?;
    let time = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map_err(|_| VaultFailure::Unavailable)?
        .as_secs();
    code(&value, time)
}
