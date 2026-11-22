use crate::{api::VaultFailure, format::MAX_FILE};
use hkdf::Hkdf;
use hpke::{
    Deserializable, Kem, OpModeR, OpModeS, Serializable, aead::ChaCha20Poly1305, kdf::HkdfSha256,
    kem::X25519HkdfSha256,
};
use sha2::Sha256;
use zeroize::Zeroizing;

type Suite = X25519HkdfSha256;
const MAGIC: &[u8; 8] = b"WPBACK\0\x01";
const INFO: &[u8] = b"WantPass/portable-backup/HPKE/v1";
const HEADER: usize = 8 + 16 + 32;
pub(crate) const MAX_ARCHIVE: usize = MAX_FILE + HEADER + 16;

fn key_pair(
    entropy: &[u8],
    vault_id: &[u8; 16],
) -> Result<(<Suite as Kem>::PrivateKey, <Suite as Kem>::PublicKey), VaultFailure> {
    if entropy.len() != 32 {
        return Err(VaultFailure::InvalidPhrase);
    }
    let mut material = Zeroizing::new([0; 32]);
    Hkdf::<Sha256>::new(Some(vault_id), entropy)
        .expand(b"WantPass/backup-recipient/v1", material.as_mut())
        .map_err(|_| VaultFailure::Unavailable)?;
    Ok(Suite::derive_keypair(material.as_ref()))
}

pub(crate) fn recipient(entropy: &[u8], id: &[u8; 16]) -> Result<[u8; 32], VaultFailure> {
    Ok(key_pair(entropy, id)?.1.to_bytes().into())
}

pub(crate) fn seal(
    data: &[u8],
    id: &[u8; 16],
    recipient: &[u8; 32],
) -> Result<Vec<u8>, VaultFailure> {
    if data.len() > MAX_FILE {
        return Err(VaultFailure::Unsupported);
    }
    let public =
        <Suite as Kem>::PublicKey::from_bytes(recipient).map_err(|_| VaultFailure::Corrupt)?;
    let (enc, mut sender) =
        hpke::setup_sender::<ChaCha20Poly1305, HkdfSha256, Suite>(&OpModeS::Base, &public, INFO)
            .map_err(|_| VaultFailure::Unavailable)?;
    let mut output = Vec::with_capacity(HEADER + data.len() + 16);
    output.extend_from_slice(MAGIC);
    output.extend_from_slice(id);
    output.extend_from_slice(&enc.to_bytes());
    let ciphertext = sender
        .seal(data, &output)
        .map_err(|_| VaultFailure::Unavailable)?;
    output.extend_from_slice(&ciphertext);
    Ok(output)
}

pub(crate) fn open(bytes: &[u8], entropy: &[u8]) -> Result<Zeroizing<Vec<u8>>, VaultFailure> {
    if !(HEADER + 16..=MAX_ARCHIVE).contains(&bytes.len()) {
        return Err(VaultFailure::Corrupt);
    }
    if &bytes[..8] != MAGIC {
        return Err(VaultFailure::Unsupported);
    }
    let id = bytes[8..24].try_into().map_err(|_| VaultFailure::Corrupt)?;
    let (key, _) = key_pair(entropy, id)?;
    let enc = <Suite as Kem>::EncappedKey::from_bytes(&bytes[24..HEADER])
        .map_err(|_| VaultFailure::Credentials)?;
    let mut receiver = hpke::setup_receiver::<ChaCha20Poly1305, HkdfSha256, Suite>(
        &OpModeR::Base,
        &key,
        &enc,
        INFO,
    )
    .map_err(|_| VaultFailure::Credentials)?;
    receiver
        .open(&bytes[HEADER..], &bytes[..HEADER])
        .map(Zeroizing::new)
        .map_err(|_| VaultFailure::Credentials)
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn only_the_source_recovery_material_opens_each_randomized_export() {
        let entropy = [7; 32];
        let id = [43; 16];
        let pk = recipient(&entropy, &id).unwrap();
        let plain = b"disposable fixture document";
        let mut file = seal(plain, &id, &pk).unwrap();
        assert_ne!(seal(plain, &id, &pk).unwrap(), file);
        assert_eq!(open(&file, &entropy).unwrap().as_slice(), plain);
        assert!(open(&file, &[9; 32]).is_err());
        assert!(open(&file, &pk).is_err());
        assert!(open(&file[..file.len() - 1], &entropy).is_err());
        file[8] ^= 1;
        assert!(open(&file, &entropy).is_err());
    }
}
