use crate::api::VaultFailure;
use argon2::{Algorithm, Argon2, Params, Version};
use bip39::Mnemonic;
use chacha20poly1305::{
    XChaCha20Poly1305, XNonce,
    aead::{Aead, KeyInit, Payload},
};
use hkdf::Hkdf;
use sha2::Sha256;
use zeroize::Zeroizing;

pub const MAX_FILE: usize = 64 * 1024 * 1024;
pub const BASE_LEN: usize = 50;
pub const HEADER_LEN: usize = 194;
const MAGIC: &[u8; 8] = b"WPASS\0\x01\0";

pub struct Opened {
    pub key: Zeroizing<[u8; 32]>,
    pub document: Zeroizing<Vec<u8>>,
    pub id: [u8; 16],
}

pub struct Prepared {
    pub opened: Opened,
    pub bytes: Vec<u8>,
    pub entropy: Zeroizing<[u8; 32]>,
}

pub fn random<const N: usize>() -> Result<[u8; N], VaultFailure> {
    let mut bytes = [0; N];
    getrandom::fill(&mut bytes).map_err(|_| VaultFailure::Unavailable)?;
    Ok(bytes)
}

pub fn validate_password(password: &str) -> Result<(), VaultFailure> {
    if password.chars().count() < 15 || password.len() > 1024 {
        return Err(VaultFailure::InvalidPassword);
    }
    Ok(())
}

fn password_key(password: &str, salt: &[u8]) -> Result<Zeroizing<[u8; 32]>, VaultFailure> {
    let params = Params::new(65536, 3, 4, Some(32)).map_err(|_| VaultFailure::Unavailable)?;
    let mut key = Zeroizing::new([0; 32]);
    Argon2::new(Algorithm::Argon2id, Version::V0x13, params)
        .hash_password_into(password.as_bytes(), salt, key.as_mut())
        .map_err(|_| VaultFailure::Unavailable)?;
    Ok(key)
}

fn recovery_key(entropy: &[u8], id: &[u8]) -> Result<Zeroizing<[u8; 32]>, VaultFailure> {
    let mut key = Zeroizing::new([0; 32]);
    Hkdf::<Sha256>::new(Some(id), entropy)
        .expand(b"WantPass/recovery/v1", key.as_mut())
        .map_err(|_| VaultFailure::Unavailable)?;
    Ok(key)
}

fn context(header: &[u8], purpose: &[u8]) -> Vec<u8> {
    let mut aad = header.to_vec();
    aad.extend_from_slice(purpose);
    aad
}

fn encrypt(
    key: &[u8],
    nonce: &[u8],
    plaintext: &[u8],
    aad: &[u8],
) -> Result<Vec<u8>, VaultFailure> {
    let nonce = XNonce::from(<[u8; 24]>::try_from(nonce).map_err(|_| VaultFailure::Corrupt)?);
    XChaCha20Poly1305::new_from_slice(key)
        .map_err(|_| VaultFailure::Unavailable)?
        .encrypt(
            &nonce,
            Payload {
                msg: plaintext,
                aad,
            },
        )
        .map_err(|_| VaultFailure::Unavailable)
}

fn decrypt(
    key: &[u8],
    nonce: &[u8],
    ciphertext: &[u8],
    aad: &[u8],
) -> Result<Zeroizing<Vec<u8>>, VaultFailure> {
    let nonce = XNonce::from(<[u8; 24]>::try_from(nonce).map_err(|_| VaultFailure::Corrupt)?);
    XChaCha20Poly1305::new_from_slice(key)
        .map_err(|_| VaultFailure::Unavailable)?
        .decrypt(
            &nonce,
            Payload {
                msg: ciphertext,
                aad,
            },
        )
        .map(Zeroizing::new)
        .map_err(|_| VaultFailure::Credentials)
}

pub fn prepare(
    password: &str,
    document: &[u8],
    id: Option<[u8; 16]>,
) -> Result<Prepared, VaultFailure> {
    validate_password(password)?;
    if document.len() > MAX_FILE - HEADER_LEN - 44 {
        return Err(VaultFailure::Unsupported);
    }
    let id = match id {
        Some(id) => id,
        None => random()?,
    };
    seal(
        password,
        Opened {
            key: Zeroizing::new(random()?),
            document: Zeroizing::new(document.to_vec()),
            id,
        },
        Zeroizing::new(random()?),
        &VaultHints::default(),
    )
}

#[derive(Default, Clone)]
pub struct VaultHints {
    pub password: String,
    pub recovery: String,
}

pub fn validate_hints(hints: &VaultHints) -> Result<(), VaultFailure> {
    if [&hints.password, &hints.recovery]
        .iter()
        .any(|v| v.len() > 1024 || v.chars().count() > 256)
    {
        return Err(VaultFailure::Unsupported);
    }
    Ok(())
}

pub fn validate_password_v2(password: &str) -> Result<(), VaultFailure> {
    use unicode_general_category::{GeneralCategory as G, get_general_category};
    validate_password(password)?;
    let mut upper = false;
    let mut lower = false;
    let mut special = false;
    for ch in password.chars() {
        let kind = get_general_category(ch);
        upper |= kind == G::UppercaseLetter;
        lower |= kind == G::LowercaseLetter;
        special |= matches!(
            kind,
            G::ConnectorPunctuation
                | G::DashPunctuation
                | G::OpenPunctuation
                | G::ClosePunctuation
                | G::InitialPunctuation
                | G::FinalPunctuation
                | G::OtherPunctuation
                | G::MathSymbol
                | G::CurrencySymbol
                | G::ModifierSymbol
                | G::OtherSymbol
        );
    }
    if !upper
        || !lower
        || !special
        || !password.chars().any(|c| c.is_ascii_digit())
        || password
            .chars()
            .any(|c| matches!(c, '\r' | '\n' | '\u{85}' | '\u{2028}' | '\u{2029}'))
    {
        return Err(VaultFailure::InvalidPassword);
    }
    Ok(())
}

pub fn seal(
    password: &str,
    opened: Opened,
    entropy: Zeroizing<[u8; 32]>,
    hints: &VaultHints,
) -> Result<Prepared, VaultFailure> {
    validate_hints(hints)?;
    let salt = random::<16>()?;
    let mut header = MAGIC.to_vec();
    for identifier in [2_u16, 1, 1] {
        header.extend_from_slice(&identifier.to_le_bytes());
    }
    header.extend_from_slice(&opened.id);
    header.extend_from_slice(&salt);
    header.extend_from_slice(&(hints.password.len() as u16).to_le_bytes());
    header.extend_from_slice(&(hints.recovery.len() as u16).to_le_bytes());
    header.extend_from_slice(hints.password.as_bytes());
    header.extend_from_slice(hints.recovery.as_bytes());
    let base_len = header.len();
    if opened.document.len() > MAX_FILE - base_len - 144 - 44 {
        return Err(VaultFailure::Unsupported);
    }
    let password_nonce = random::<24>()?;
    let recovery_nonce = random::<24>()?;
    let password_key = password_key(password, &salt)?;
    let recovery_key = recovery_key(entropy.as_ref(), &opened.id)?;
    let password_slot = encrypt(
        password_key.as_ref(),
        &password_nonce,
        opened.key.as_ref(),
        &context(&header, b"/password"),
    )?;
    let recovery_slot = encrypt(
        recovery_key.as_ref(),
        &recovery_nonce,
        opened.key.as_ref(),
        &context(&header, b"/recovery"),
    )?;
    header.extend_from_slice(&password_nonce);
    header.extend_from_slice(&password_slot);
    header.extend_from_slice(&recovery_nonce);
    header.extend_from_slice(&recovery_slot);
    let payload_nonce = random::<24>()?;
    let mut plaintext = Zeroizing::new(1_u32.to_le_bytes().to_vec());
    plaintext.extend_from_slice(&opened.document);
    let ciphertext = encrypt(
        opened.key.as_ref(),
        &payload_nonce,
        &plaintext,
        &context(&header, b"/payload"),
    )?;
    let mut bytes = header;
    bytes.extend_from_slice(&payload_nonce);
    bytes.extend_from_slice(&ciphertext);
    Ok(Prepared {
        opened,
        bytes,
        entropy,
    })
}

fn header(bytes: &[u8]) -> Result<usize, VaultFailure> {
    if bytes.len() < HEADER_LEN + 44 || bytes.len() > MAX_FILE {
        return Err(VaultFailure::Corrupt);
    }
    if &bytes[..8] != MAGIC || bytes[8..14] != [2, 0, 1, 0, 1, 0] {
        return Err(VaultFailure::Unsupported);
    }
    let password_len = u16::from_le_bytes([bytes[46], bytes[47]]) as usize;
    let recovery_len = u16::from_le_bytes([bytes[48], bytes[49]]) as usize;
    if password_len > 1024
        || recovery_len > 1024
        || bytes.len() < HEADER_LEN + password_len + recovery_len + 44
    {
        return Err(VaultFailure::Corrupt);
    }
    let base_len = BASE_LEN + password_len + recovery_len;
    let hints = VaultHints {
        password: std::str::from_utf8(&bytes[50..50 + password_len])
            .map_err(|_| VaultFailure::Corrupt)?
            .to_owned(),
        recovery: std::str::from_utf8(&bytes[50 + password_len..base_len])
            .map_err(|_| VaultFailure::Corrupt)?
            .to_owned(),
    };
    validate_hints(&hints).map_err(|_| VaultFailure::Corrupt)?;
    Ok(base_len)
}

pub fn read_hints(bytes: &[u8]) -> Result<VaultHints, VaultFailure> {
    let base = header(bytes)?;
    let length = u16::from_le_bytes([bytes[46], bytes[47]]) as usize;
    Ok(VaultHints {
        password: std::str::from_utf8(&bytes[50..50 + length])
            .map_err(|_| VaultFailure::Corrupt)?
            .to_owned(),
        recovery: std::str::from_utf8(&bytes[50 + length..base])
            .map_err(|_| VaultFailure::Corrupt)?
            .to_owned(),
    })
}

fn open_key(bytes: &[u8], key: Zeroizing<Vec<u8>>) -> Result<Opened, VaultFailure> {
    let header_len = header(bytes)? + 144;
    if key.len() != 32 {
        return Err(VaultFailure::Corrupt);
    }
    let plaintext = decrypt(
        &key,
        &bytes[header_len..header_len + 24],
        &bytes[header_len + 24..],
        &context(&bytes[..header_len], b"/payload"),
    )?;
    if plaintext.len() < 4 || plaintext[..4] != 1_u32.to_le_bytes() {
        return Err(VaultFailure::Unsupported);
    }
    let mut data_key = Zeroizing::new([0; 32]);
    data_key.copy_from_slice(&key);
    Ok(Opened {
        key: data_key,
        document: Zeroizing::new(plaintext[4..].to_vec()),
        id: bytes[14..30]
            .try_into()
            .map_err(|_| VaultFailure::Corrupt)?,
    })
}

pub fn open_password(bytes: &[u8], password: &str) -> Result<Opened, VaultFailure> {
    let base_len = header(bytes)?;
    validate_password(password)?;
    let key = password_key(password, &bytes[30..46])?;
    let unwrapped = decrypt(
        key.as_ref(),
        &bytes[base_len..base_len + 24],
        &bytes[base_len + 24..base_len + 72],
        &context(&bytes[..base_len], b"/password"),
    )?;
    open_key(bytes, unwrapped)
}

pub fn words(entropy: &[u8]) -> Result<Vec<String>, VaultFailure> {
    let phrase = Mnemonic::from_entropy(entropy).map_err(|_| VaultFailure::InvalidPhrase)?;
    Ok(phrase.words().map(str::to_owned).collect())
}

pub fn open_recovery(bytes: &[u8], phrase: &str) -> Result<Opened, VaultFailure> {
    let base_len = header(bytes)?;
    if phrase.len() > 1024 {
        return Err(VaultFailure::InvalidPhrase);
    }
    let mnemonic = Mnemonic::parse_in(bip39::Language::English, phrase)
        .map_err(|_| VaultFailure::InvalidPhrase)?;
    if mnemonic.word_count() != 24 {
        return Err(VaultFailure::InvalidPhrase);
    }
    let entropy = Zeroizing::new(mnemonic.to_entropy());
    let key = recovery_key(&entropy, &bytes[14..30])?;
    let unwrapped = decrypt(
        key.as_ref(),
        &bytes[base_len + 72..base_len + 96],
        &bytes[base_len + 96..base_len + 144],
        &context(&bytes[..base_len], b"/recovery"),
    )?;
    open_key(bytes, unwrapped)
}

// Preserve authenticated key slots; document edits never need the master password.
pub fn replace_document(
    bytes: &[u8],
    opened: &Opened,
    document: &[u8],
) -> Result<Vec<u8>, VaultFailure> {
    let header_len = header(bytes)? + 144;
    if document.len() > MAX_FILE - header_len - 44 {
        return Err(VaultFailure::Unsupported);
    }
    let verified = open_key(bytes, Zeroizing::new(opened.key.to_vec()))?;
    if verified.id != opened.id || verified.document.as_slice() != opened.document.as_slice() {
        return Err(VaultFailure::Stale);
    }
    let nonce = random::<24>()?;
    let mut plaintext = Zeroizing::new(1_u32.to_le_bytes().to_vec());
    plaintext.extend_from_slice(document);
    let ciphertext = encrypt(
        opened.key.as_ref(),
        &nonce,
        &plaintext,
        &context(&bytes[..header_len], b"/payload"),
    )?;
    let mut candidate = bytes[..header_len].to_vec();
    candidate.extend_from_slice(&nonce);
    candidate.extend_from_slice(&ciphertext);
    Ok(candidate)
}
