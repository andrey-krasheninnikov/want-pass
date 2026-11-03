use super::{CardTypeV1 as C, CardValueV1, FieldIdV1 as F, VaultFailure};
use base64::{Engine, engine::general_purpose::STANDARD as BASE64};
use pkcs8::der::{Decode, DecodePem};
use std::collections::BTreeSet;
fn rejected<T>() -> Result<T, VaultFailure> {
    Err(VaultFailure::Unsupported)
}
fn get(fields: &[CardValueV1], id: F) -> &str {
    super::otp::field(fields, id).unwrap_or("")
}
pub(super) fn validate(kind: C, fields: &[CardValueV1]) -> Result<bool, VaultFailure> {
    let value = get(fields, F::Value);
    match kind {
        C::Account => {
            if get(fields, F::Login).trim().is_empty() {
                return rejected();
            }
            super::otp::validate_account_totp(fields)?;
        }
        C::RecoveryUrl => {
            let u = url::Url::parse(value).map_err(|_| VaultFailure::Unsupported)?;
            if !matches!(u.scheme(), "https" | "http") || u.host_str().is_none() {
                return rejected();
            }
        }
        C::Vless => {
            let u = url::Url::parse(value).map_err(|_| VaultFailure::Unsupported)?;
            let id = u.username();
            if u.scheme() != "vless"
                || u.host_str().is_none()
                || u.port().is_none()
                || id.len() != 36
                || !id.bytes().enumerate().all(|(i, c)| {
                    if [8, 13, 18, 23].contains(&i) {
                        c == b'-'
                    } else {
                        c.is_ascii_hexdigit()
                    }
                })
            {
                return rejected();
            }
        }
        C::Dsn => {
            let u = url::Url::parse(value).map_err(|_| VaultFailure::Unsupported)?;
            if u.scheme().is_empty() || (u.host_str().is_none() && u.path().is_empty()) {
                return rejected();
            }
        }
        C::WireGuard => wireguard(value)?,
        C::Kubeconfig => kubeconfig(value)?,
        C::Rsa | C::Ed25519 => {
            return key_pair(kind, get(fields, F::PublicKey), get(fields, F::PrivateKey));
        }
        C::Certificate => {
            use pkcs8::der::Encode;
            let certificate = x509_cert::Certificate::from_pem(get(fields, F::Certificate))
                .map_err(|_| VaultFailure::Unsupported)?;
            let key = get(fields, F::PrivateKey);
            let protected = private_key(key, None)?;
            if !protected {
                matching_public(
                    key,
                    &certificate
                        .tbs_certificate()
                        .subject_public_key_info()
                        .to_der()
                        .map_err(|_| VaultFailure::Unsupported)?,
                )?;
            }
            return Ok(protected);
        }
        C::Gpg => {
            use pgp::{
                composed::{Deserializable, SignedPublicKey, SignedSecretKey},
                types::KeyDetails,
            };
            let (public, _) = SignedPublicKey::from_string(get(fields, F::PublicKey))
                .map_err(|_| VaultFailure::Unsupported)?;
            let (private, _) = SignedSecretKey::from_string(get(fields, F::PrivateKey))
                .map_err(|_| VaultFailure::Unsupported)?;
            if public.primary_key.fingerprint() != private.primary_key.fingerprint() {
                return rejected();
            }
            return Ok(private.primary_key.secret_params().is_encrypted()
                || private
                    .secret_subkeys
                    .iter()
                    .any(|s| s.key.secret_params().is_encrypted()));
        }
        C::SecretQa => {
            if get(fields, F::Question).trim().is_empty() {
                return rejected();
            }
        }
        C::OAuth => {
            if get(fields, F::ClientId).trim().is_empty() {
                return rejected();
            }
        }
        C::RecoveryCodes => {
            if !get(fields, F::RecoveryCodes)
                .lines()
                .any(|v| !v.trim().is_empty())
            {
                return rejected();
            }
        }
        _ => {}
    }
    Ok(false)
}
fn private_key(value: &str, algorithm: Option<&str>) -> Result<bool, VaultFailure> {
    if value.starts_with("-----BEGIN OPENSSH PRIVATE KEY-----") {
        let key =
            ssh_key::PrivateKey::from_openssh(value).map_err(|_| VaultFailure::Unsupported)?;
        return Ok(key.is_encrypted());
    }
    let (label, der) =
        pkcs8::der::pem::decode_vec(value.as_bytes()).map_err(|_| VaultFailure::Unsupported)?;
    let der = zeroize::Zeroizing::new(der);
    match label {
        "ENCRYPTED PRIVATE KEY" => {
            pkcs8::EncryptedPrivateKeyInfoRef::from_der(&der)
                .map_err(|_| VaultFailure::Unsupported)?;
            Ok(true)
        }
        "PRIVATE KEY" => {
            let key =
                pkcs8::PrivateKeyInfoRef::from_der(&der).map_err(|_| VaultFailure::Unsupported)?;
            if algorithm.is_some_and(|a| key.algorithm.oid.to_string() != a) {
                return rejected();
            }
            match key.algorithm.oid.to_string().as_str() {
                "1.2.840.113549.1.1.1" => {
                    use rsa::pkcs8::DecodePrivateKey;
                    rsa::RsaPrivateKey::from_pkcs8_pem(value)
                        .map_err(|_| VaultFailure::Unsupported)?;
                }
                "1.3.101.112" => {
                    let secret =
                        <&pkcs8::der::asn1::OctetStringRef>::from_der(key.private_key.as_bytes())
                            .map_err(|_| VaultFailure::Unsupported)?;
                    if secret.as_bytes().len() != 32 {
                        return rejected();
                    }
                }
                "1.2.840.10045.2.1" => {
                    let body = pkcs8::der::asn1::AnyRef::from_der(key.private_key.as_bytes())
                        .map_err(|_| VaultFailure::Unsupported)?;
                    if body.value().is_empty() {
                        return rejected();
                    }
                }
                _ => return rejected(),
            }
            Ok(false)
        }
        "RSA PRIVATE KEY" => {
            use rsa::pkcs1::DecodeRsaPrivateKey;
            if algorithm.is_some_and(|a| a != "1.2.840.113549.1.1.1") {
                return rejected();
            }
            rsa::RsaPrivateKey::from_pkcs1_pem(value).map_err(|_| VaultFailure::Unsupported)?;
            Ok(false)
        }
        _ => rejected(),
    }
}
fn private_public_der(value: &str) -> Result<Vec<u8>, VaultFailure> {
    use rsa::{
        pkcs1::DecodeRsaPrivateKey,
        pkcs8::{DecodePrivateKey, EncodePublicKey},
    };
    if value.starts_with("-----BEGIN RSA PRIVATE KEY-----") {
        return rsa::RsaPrivateKey::from_pkcs1_pem(value)
            .and_then(|k| k.to_public_key().to_public_key_der().map_err(Into::into))
            .map(|v| v.as_bytes().to_vec())
            .map_err(|_| VaultFailure::Unsupported);
    }
    let (_, bytes) =
        pkcs8::der::pem::decode_vec(value.as_bytes()).map_err(|_| VaultFailure::Unsupported)?;
    let bytes = zeroize::Zeroizing::new(bytes);
    let info = pkcs8::PrivateKeyInfoRef::from_der(&bytes).map_err(|_| VaultFailure::Unsupported)?;
    let oid = info.algorithm.oid.to_string();
    match oid.as_str() {
        "1.2.840.113549.1.1.1" => rsa::RsaPrivateKey::from_pkcs8_pem(value)
            .map_err(|_| VaultFailure::Unsupported)?
            .to_public_key()
            .to_public_key_der(),
        "1.3.101.112" => ed25519_dalek::SigningKey::from_pkcs8_pem(value)
            .map_err(|_| VaultFailure::Unsupported)?
            .verifying_key()
            .to_public_key_der(),
        "1.2.840.10045.2.1" => {
            let curve = info
                .algorithm
                .parameters
                .ok_or(VaultFailure::Unsupported)?
                .decode_as::<pkcs8::ObjectIdentifier>()
                .map_err(|_| VaultFailure::Unsupported)?
                .to_string();
            match curve.as_str() {
                "1.2.840.10045.3.1.7" => p256::SecretKey::from_pkcs8_pem(value)
                    .map_err(|_| VaultFailure::Unsupported)?
                    .public_key()
                    .to_public_key_der(),
                "1.3.132.0.34" => p384::SecretKey::from_pkcs8_pem(value)
                    .map_err(|_| VaultFailure::Unsupported)?
                    .public_key()
                    .to_public_key_der(),
                "1.3.132.0.35" => p521::SecretKey::from_pkcs8_pem(value)
                    .map_err(|_| VaultFailure::Unsupported)?
                    .public_key()
                    .to_public_key_der(),
                _ => return rejected(),
            }
        }
        _ => return rejected(),
    }
    .map(|v| v.as_bytes().to_vec())
    .map_err(|_| VaultFailure::Unsupported)
}
fn matching_public(private: &str, public_der: &[u8]) -> Result<(), VaultFailure> {
    let derived = private_public_der(private)?;
    let expected = pkcs8::SubjectPublicKeyInfoRef::from_der(&derived)
        .map_err(|_| VaultFailure::Unsupported)?;
    let actual = pkcs8::SubjectPublicKeyInfoRef::from_der(public_der)
        .map_err(|_| VaultFailure::Unsupported)?;
    if actual.algorithm.oid != expected.algorithm.oid
        || actual.subject_public_key.as_bytes().is_none()
        || actual.subject_public_key.as_bytes() != expected.subject_public_key.as_bytes()
        || (actual.algorithm.oid.to_string() == "1.2.840.10045.2.1"
            && actual.algorithm.parameters != expected.algorithm.parameters)
    {
        return rejected();
    }
    Ok(())
}
fn key_pair(kind: C, public: &str, private: &str) -> Result<bool, VaultFailure> {
    let rsa = kind == C::Rsa;
    let oid = if rsa {
        "1.2.840.113549.1.1.1"
    } else {
        "1.3.101.112"
    };
    if private.starts_with("-----BEGIN OPENSSH PRIVATE KEY-----") {
        let key =
            ssh_key::PrivateKey::from_openssh(private).map_err(|_| VaultFailure::Unsupported)?;
        let public =
            ssh_key::PublicKey::from_openssh(public).map_err(|_| VaultFailure::Unsupported)?;
        if key.public_key().key_data() != public.key_data()
            || !matches!(
                (key.algorithm(), rsa),
                (ssh_key::Algorithm::Rsa { .. }, true) | (ssh_key::Algorithm::Ed25519, false)
            )
        {
            return rejected();
        }
        return Ok(key.is_encrypted());
    }
    let (label, der) =
        pkcs8::der::pem::decode_vec(public.as_bytes()).map_err(|_| VaultFailure::Unsupported)?;
    if label != "PUBLIC KEY" {
        return rejected();
    }
    let key =
        pkcs8::SubjectPublicKeyInfoRef::from_der(&der).map_err(|_| VaultFailure::Unsupported)?;
    if key.algorithm.oid.to_string() != oid {
        return rejected();
    }
    let protected = private_key(private, Some(oid))?;
    if !protected {
        matching_public(private, &der)?;
    }
    Ok(protected)
}
fn wireguard(value: &str) -> Result<(), VaultFailure> {
    let mut interface = false;
    let mut peers = 0;
    let mut section = "";
    let mut keys = BTreeSet::new();
    let mut private = false;
    let mut public = false;
    for line in value
        .lines()
        .map(str::trim)
        .filter(|l| !l.is_empty() && !l.starts_with('#') && !l.starts_with(';'))
    {
        if line.starts_with('[') {
            if section == "Peer" && !public {
                return rejected();
            }
            match line {
                "[Interface]" if !interface => {
                    interface = true;
                    section = "Interface";
                }
                "[Peer]" => {
                    peers += 1;
                    section = "Peer";
                    public = false;
                }
                _ => return rejected(),
            }
            keys.clear();
            continue;
        }
        let (key, value) = line.split_once('=').ok_or(VaultFailure::Unsupported)?;
        let key = key.trim();
        let value = value.trim();
        if section.is_empty() || value.is_empty() || !keys.insert(key.to_owned()) {
            return rejected();
        }
        if matches!(key, "PrivateKey" | "PublicKey" | "PresharedKey") {
            let bytes = zeroize::Zeroizing::new(
                BASE64
                    .decode(value)
                    .map_err(|_| VaultFailure::Unsupported)?,
            );
            if bytes.len() != 32 {
                return rejected();
            }
            if key == "PrivateKey" && section == "Interface" {
                private = true;
            }
            if key == "PublicKey" && section == "Peer" {
                public = true;
            }
        }
        if matches!(key, "Address" | "AllowedIPs") {
            for cidr in value.split(',').map(str::trim) {
                let (ip, prefix) = cidr.split_once('/').ok_or(VaultFailure::Unsupported)?;
                let ip: std::net::IpAddr = ip.parse().map_err(|_| VaultFailure::Unsupported)?;
                let prefix: u8 = prefix.parse().map_err(|_| VaultFailure::Unsupported)?;
                if prefix > if ip.is_ipv4() { 32 } else { 128 } {
                    return rejected();
                }
            }
        }
        if key == "ListenPort" && value.parse::<u16>().is_err() {
            return rejected();
        }
    }
    if !interface || !private || peers == 0 || !public {
        return rejected();
    }
    Ok(())
}
#[derive(serde::Deserialize)]
struct Kubeconfig {
    #[serde(rename = "apiVersion")]
    api_version: String,
    kind: String,
    #[serde(default)]
    clusters: Vec<KubeCluster>,
    #[serde(default)]
    contexts: Vec<KubeContext>,
    #[serde(default)]
    users: Vec<KubeUser>,
    #[serde(rename = "current-context", default)]
    current_context: String,
}
#[derive(serde::Deserialize)]
struct KubeCluster {
    name: String,
    cluster: ClusterSettings,
}
#[derive(serde::Deserialize)]
struct ClusterSettings {
    server: String,
}
#[derive(serde::Deserialize)]
struct KubeUser {
    name: String,
    user: std::collections::BTreeMap<String, serde_json::Value>,
}
#[derive(serde::Deserialize)]
struct KubeContext {
    name: String,
    context: ContextSettings,
}
#[derive(serde::Deserialize)]
struct ContextSettings {
    cluster: String,
    #[serde(default)]
    user: String,
}
fn kubeconfig(value: &str) -> Result<(), VaultFailure> {
    let options = serde_saphyr::options! {budget:serde_saphyr::budget!{max_depth:32,max_anchors:0,max_aliases:0,max_events:100000,max_documents:1,max_total_scalar_bytes:1024*1024},duplicate_keys:serde_saphyr::DuplicateKeyPolicy::Error};
    let config: Kubeconfig = serde_saphyr::from_str_with_options(value, options)
        .map_err(|_| VaultFailure::Unsupported)?;
    if config.api_version != "v1"
        || config.kind != "Config"
        || config.clusters.is_empty()
        || config.contexts.is_empty()
        || (!config.current_context.is_empty()
            && !config
                .contexts
                .iter()
                .any(|c| c.name == config.current_context))
    {
        return rejected();
    }
    let mut clusters = BTreeSet::new();
    for c in &config.clusters {
        if c.name.is_empty() || !clusters.insert(&c.name) {
            return rejected();
        }
        let url = url::Url::parse(&c.cluster.server).map_err(|_| VaultFailure::Unsupported)?;
        if !matches!(url.scheme(), "https" | "http") || url.host_str().is_none() {
            return rejected();
        }
    }
    let mut users = BTreeSet::new();
    for u in &config.users {
        if u.name.is_empty() || !users.insert(&u.name) {
            return rejected();
        }
        let _ = &u.user;
    }
    let mut contexts = BTreeSet::new();
    for c in &config.contexts {
        if c.name.is_empty()
            || !contexts.insert(&c.name)
            || !clusters.contains(&c.context.cluster)
            || (!c.context.user.is_empty() && !users.contains(&c.context.user))
        {
            return rejected();
        }
    }
    Ok(())
}
