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
pub const BASE_LEN: usize = 46;
pub const HEADER_LEN: usize = 190;
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
    let salt = random::<16>()?;
    let key = Zeroizing::new(random::<32>()?);
    let entropy = Zeroizing::new(random::<32>()?);
    let mut header = MAGIC.to_vec();
    for identifier in [1_u16, 1, 1] {
        header.extend_from_slice(&identifier.to_le_bytes());
    }
    header.extend_from_slice(&id);
    header.extend_from_slice(&salt);
    let password_nonce = random::<24>()?;
    let recovery_nonce = random::<24>()?;
    let password_key = password_key(password, &salt)?;
    let recovery_key = recovery_key(entropy.as_ref(), &id)?;
    let password_slot = encrypt(
        password_key.as_ref(),
        &password_nonce,
        key.as_ref(),
        &context(&header, b"/password"),
    )?;
    let recovery_slot = encrypt(
        recovery_key.as_ref(),
        &recovery_nonce,
        key.as_ref(),
        &context(&header, b"/recovery"),
    )?;
    header.extend_from_slice(&password_nonce);
    header.extend_from_slice(&password_slot);
    header.extend_from_slice(&recovery_nonce);
    header.extend_from_slice(&recovery_slot);
    let payload_nonce = random::<24>()?;
    let mut plaintext = Zeroizing::new(1_u32.to_le_bytes().to_vec());
    plaintext.extend_from_slice(document);
    let ciphertext = encrypt(
        key.as_ref(),
        &payload_nonce,
        &plaintext,
        &context(&header, b"/payload"),
    )?;
    let mut bytes = header;
    bytes.extend_from_slice(&payload_nonce);
    bytes.extend_from_slice(&ciphertext);
    Ok(Prepared {
        opened: Opened {
            key,
            document: Zeroizing::new(document.to_vec()),
            id,
        },
        bytes,
        entropy,
    })
}

fn header(bytes: &[u8]) -> Result<(), VaultFailure> {
    if bytes.len() < HEADER_LEN + 44 || bytes.len() > MAX_FILE {
        return Err(VaultFailure::Corrupt);
    }
    if &bytes[..8] != MAGIC || bytes[8..14] != [1, 0, 1, 0, 1, 0] {
        return Err(VaultFailure::Unsupported);
    }
    Ok(())
}

fn open_key(bytes: &[u8], key: Zeroizing<Vec<u8>>) -> Result<Opened, VaultFailure> {
    if key.len() != 32 {
        return Err(VaultFailure::Corrupt);
    }
    let plaintext = decrypt(
        &key,
        &bytes[HEADER_LEN..HEADER_LEN + 24],
        &bytes[HEADER_LEN + 24..],
        &context(&bytes[..HEADER_LEN], b"/payload"),
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
    header(bytes)?;
    validate_password(password)?;
    let key = password_key(password, &bytes[30..46])?;
    let unwrapped = decrypt(
        key.as_ref(),
        &bytes[46..70],
        &bytes[70..118],
        &context(&bytes[..BASE_LEN], b"/password"),
    )?;
    open_key(bytes, unwrapped)
}

pub fn words(entropy: &[u8]) -> Result<Vec<String>, VaultFailure> {
    let phrase = Mnemonic::from_entropy(entropy).map_err(|_| VaultFailure::InvalidPhrase)?;
    Ok(phrase.words().map(str::to_owned).collect())
}

pub fn open_recovery(bytes: &[u8], phrase: &str) -> Result<Opened, VaultFailure> {
    header(bytes)?;
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
        &bytes[118..142],
        &bytes[142..190],
        &context(&bytes[..BASE_LEN], b"/recovery"),
    )?;
    open_key(bytes, unwrapped)
}
