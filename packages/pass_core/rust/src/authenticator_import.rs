use crate::api::account_import::{ImportRow, MAX_PARTS, MAX_ROWS};
use crate::api::{CardTypeV1, CardValueV1, FieldIdV1 as F, VaultFailure};
use base64::{
    Engine,
    engine::general_purpose::{STANDARD, STANDARD_NO_PAD},
};
use percent_encoding::percent_decode_str;
use prost::Message;
use std::collections::{BTreeMap, BTreeSet};
use totp_rs::Secret;
use url::Url;
use zeroize::{Zeroize, ZeroizeOnDrop, Zeroizing};

#[derive(Message, Zeroize, ZeroizeOnDrop)]
#[prost(skip_debug)]
struct Batch {
    #[prost(message, repeated, tag = "1")]
    accounts: Vec<Otp>,
    #[prost(int32, tag = "2")]
    version: i32,
    #[prost(int32, tag = "3")]
    size: i32,
    #[prost(int32, tag = "4")]
    index: i32,
    #[prost(int32, optional, tag = "5")]
    id: Option<i32>,
}
#[derive(Message, Zeroize, ZeroizeOnDrop)]
#[prost(skip_debug)]
struct Otp {
    #[prost(bytes = "vec", tag = "1")]
    secret: Vec<u8>,
    #[prost(string, tag = "2")]
    name: String,
    #[prost(string, tag = "3")]
    issuer: String,
    #[prost(int32, tag = "4")]
    algorithm: i32,
    #[prost(int32, tag = "5")]
    digits: i32,
    #[prost(int32, tag = "6")]
    kind: i32,
    #[prost(int64, tag = "7")]
    counter: i64,
}

pub(crate) fn parse(payloads: &[String]) -> Result<Vec<ImportRow>, VaultFailure> {
    let mut rows = Vec::new();
    let mut parts = BTreeMap::new();
    let mut batch_descriptor = None;
    for text in payloads {
        if text.len() > 32768 || text.contains(['\r', '\n', '\0']) {
            return Err(VaultFailure::Unsupported);
        }
        let uri = Url::parse(text).map_err(|_| VaultFailure::Unsupported)?;
        if !uri.username().is_empty()
            || uri.password().is_some()
            || uri.fragment().is_some()
            || uri.port().is_some()
        {
            return Err(VaultFailure::Unsupported);
        }
        match (uri.scheme(), uri.host_str()) {
            ("otpauth", Some("totp" | "hotp")) if parts.is_empty() => {
                rows.push(provisioning(&uri)?)
            }
            ("otpauth-migration", Some("offline"))
                if rows.is_empty() && matches!(uri.path(), "" | "/") =>
            {
                let raw = uri
                    .query()
                    .and_then(|q| q.strip_prefix("data="))
                    .filter(|s| !s.contains('&'))
                    .ok_or(VaultFailure::Unsupported)?;
                let base64 = percent_decode_str(raw)
                    .decode_utf8()
                    .map_err(|_| VaultFailure::Unsupported)?;
                let data = Zeroizing::new(
                    STANDARD
                        .decode(base64.as_bytes())
                        .or_else(|_| STANDARD_NO_PAD.decode(base64.as_bytes()))
                        .map_err(|_| VaultFailure::Unsupported)?,
                );
                let part = Batch::decode(data.as_slice()).map_err(|_| VaultFailure::Unsupported)?;
                let size = usize::try_from(part.size).map_err(|_| VaultFailure::Unsupported)?;
                if part.version != 1
                    || !(1..=MAX_PARTS).contains(&size)
                    || !(0..part.size).contains(&part.index)
                    || part.accounts.is_empty()
                    || part.accounts.len() > MAX_ROWS
                    || (size > 1 && part.id.is_none())
                {
                    return Err(VaultFailure::Unsupported);
                }
                let descriptor = (size, part.id);
                if batch_descriptor
                    .replace(descriptor)
                    .is_some_and(|d| d != descriptor)
                    || parts.insert(part.index, part).is_some()
                {
                    return Err(VaultFailure::Unsupported);
                }
            }
            _ => return Err(VaultFailure::Unsupported),
        }
    }
    if let Some((size, _)) = batch_descriptor {
        if parts.len() != size {
            return Err(VaultFailure::Unsupported);
        }
        for part in parts.values() {
            if rows.len() + part.accounts.len() > MAX_ROWS {
                return Err(VaultFailure::Unsupported);
            }
            for otp in &part.accounts {
                let algorithm = match otp.algorithm {
                    1 => "SHA1",
                    2 => "SHA256",
                    3 => "SHA512",
                    _ => return Err(VaultFailure::Unsupported),
                };
                let digits = match otp.digits {
                    1 => 6,
                    2 => 8,
                    _ => return Err(VaultFailure::Unsupported),
                };
                if otp.secret.is_empty() || otp.secret.len() > 128 {
                    return Err(VaultFailure::Unsupported);
                }
                let counter = match otp.kind {
                    2 if otp.counter == 0 => None,
                    1 => Some(u64::try_from(otp.counter).map_err(|_| VaultFailure::Unsupported)?),
                    _ => return Err(VaultFailure::Unsupported),
                };
                let seed = Secret::new(otp.secret.clone().into_boxed_slice()).to_base32();
                rows.push(otp_row(
                    &otp.name,
                    &otp.issuer,
                    seed,
                    algorithm,
                    digits,
                    30,
                    counter,
                )?);
            }
        }
    }
    Ok(rows)
}

fn provisioning(uri: &Url) -> Result<ImportRow, VaultFailure> {
    let label = uri
        .path()
        .strip_prefix('/')
        .filter(|s| !s.is_empty() && !s.contains('/'))
        .ok_or(VaultFailure::Unsupported)?;
    let label = percent_decode_str(label)
        .decode_utf8()
        .map_err(|_| VaultFailure::Unsupported)?;
    let hotp = uri.host_str() == Some("hotp");
    let mut seen = BTreeSet::new();
    let mut seed = Zeroizing::new(String::new());
    let mut issuer = String::new();
    let mut algorithm = String::from("SHA1");
    let mut digits = 6;
    let mut period = 30;
    let mut counter = None;
    for (key, value) in uri.query_pairs() {
        if !seen.insert(key.to_string()) {
            return Err(VaultFailure::Unsupported);
        }
        match key.as_ref() {
            "secret" => *seed = value.into_owned(),
            "issuer" => issuer = value.into_owned(),
            "algorithm" => algorithm = value.into_owned(),
            "digits" => digits = value.parse().map_err(|_| VaultFailure::Unsupported)?,
            "period" if !hotp => period = value.parse().map_err(|_| VaultFailure::Unsupported)?,
            "counter" if hotp => {
                counter = Some(value.parse().map_err(|_| VaultFailure::Unsupported)?)
            }
            _ => return Err(VaultFailure::Unsupported),
        }
    }
    if seed.len() > 1024 || hotp != counter.is_some() {
        return Err(VaultFailure::Unsupported);
    }
    let seed = Secret::try_from_base32(seed.as_str())
        .map_err(|_| VaultFailure::Unsupported)?
        .to_base32();
    let (label_issuer, name) = label.split_once(':').unwrap_or(("", &label));
    if !issuer.is_empty() && !label_issuer.is_empty() && issuer != label_issuer {
        return Err(VaultFailure::Unsupported);
    }
    otp_row(
        name,
        if issuer.is_empty() {
            label_issuer
        } else {
            &issuer
        },
        seed,
        &algorithm,
        digits,
        period,
        counter,
    )
}

fn otp_row(
    name: &str,
    issuer: &str,
    seed: String,
    algorithm: &str,
    digits: u8,
    period: u64,
    counter: Option<u64>,
) -> Result<ImportRow, VaultFailure> {
    let name = name.trim();
    let issuer = issuer.trim();
    if name.is_empty() || issuer.chars().chain(name.chars()).any(char::is_control) {
        return Err(VaultFailure::Unsupported);
    }
    let name = if issuer.is_empty()
        || name
            .split_once(':')
            .is_some_and(|(prefix, _)| prefix == issuer)
    {
        name.into()
    } else {
        format!("{issuer}: {name}")
    };
    let field = |id, value| CardValueV1 { id, value };
    let (kind, fields) = if let Some(counter) = counter {
        if algorithm != "SHA1" || digits != 6 || counter == u64::MAX {
            return Err(VaultFailure::Unsupported);
        }
        (
            CardTypeV1::Hotp,
            vec![
                field(F::HotpSeed, seed),
                field(F::Counter, counter.to_string()),
            ],
        )
    } else {
        (
            CardTypeV1::Totp,
            vec![
                field(F::TotpSeed, seed),
                field(F::TotpAlgorithm, algorithm.into()),
                field(F::TotpDigits, digits.to_string()),
                field(F::TotpPeriod, period.to_string()),
            ],
        )
    };
    Ok(ImportRow {
        name,
        notes: String::new(),
        url: None,
        kind,
        fields,
    })
}
