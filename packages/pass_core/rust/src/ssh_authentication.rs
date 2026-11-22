use crate::api::VaultFailure;
use base64::{Engine, engine::general_purpose::STANDARD};
use signature::{Signer, Verifier};
use ssh_key::{Algorithm, LineEnding, PrivateKey, PublicKey, Signature, private::Ed25519Keypair};
use zeroize::Zeroizing;

type Output<T> = Result<T, VaultFailure>;
const BAD: VaultFailure = VaultFailure::Unsupported;

pub(crate) fn public(input: &str) -> Output<PublicKey> {
    let mut key = PublicKey::from_openssh(input).map_err(|_| BAD)?;
    if key.algorithm() != Algorithm::Ed25519 {
        return Err(BAD);
    }
    key.set_comment("");
    Ok(key)
}

pub(crate) fn make_key() -> Output<(String, Zeroizing<String>)> {
    let seed = Zeroizing::new(crate::format::random::<32>()?);
    let key = PrivateKey::new(Ed25519Keypair::from_seed(&seed).into(), "").map_err(|_| BAD)?;
    Ok((
        key.public_key().to_openssh().map_err(|_| BAD)?,
        key.to_openssh(LineEnding::LF).map_err(|_| BAD)?,
    ))
}

pub(crate) fn matching(public_text: &str, private_text: &str) -> Output<PrivateKey> {
    let key = PrivateKey::from_openssh(private_text).map_err(|_| BAD)?;
    let public = public(public_text)?;
    if key.is_encrypted() || key.public_key().key_data() != public.key_data() {
        return Err(BAD);
    }
    Ok(key)
}

struct Reader<'a>(&'a [u8]);
impl<'a> Reader<'a> {
    fn take(&mut self, n: usize) -> Output<&'a [u8]> {
        let (first, rest) = self.0.split_at_checked(n).ok_or(BAD)?;
        self.0 = rest;
        Ok(first)
    }
    fn string(&mut self) -> Output<&'a [u8]> {
        let n = u32::from_be_bytes(self.take(4)?.try_into().map_err(|_| BAD)?);
        self.take(n as usize)
    }
    fn equal(&mut self, want: &[u8]) -> Output<()> {
        if self.string()? == want {
            Ok(())
        } else {
            Err(BAD)
        }
    }
}

pub(crate) fn sign_userauth(
    host: &PublicKey,
    user: &str,
    key: &PrivateKey,
    offered_key: &str,
    attachment: &str,
    data: &str,
) -> Output<String> {
    let decode = |s: &str| STANDARD.decode(s).map_err(|_| BAD);
    let binding_bytes = decode(attachment)?;
    let mut binding = Reader(&binding_bytes);
    let bound_host = binding.string()?;
    let session = binding.string()?;
    let signature = Signature::try_from(binding.string()?).map_err(|_| BAD)?;
    let host_blob = host.to_bytes().map_err(|_| BAD)?;
    if !(16..=64).contains(&session.len())
        || bound_host != host_blob
        || binding.take(1)? != [0]
        || !binding.0.is_empty()
    {
        return Err(BAD);
    }
    Verifier::verify(host, session, &signature).map_err(|_| VaultFailure::Credentials)?;
    let public_blob = key.public_key().to_bytes().map_err(|_| BAD)?;
    if decode(offered_key)? != public_blob {
        return Err(BAD);
    }
    let data = decode(data)?;
    let mut request = Reader(&data);
    request.equal(session)?;
    if request.take(1)? != [50] {
        return Err(BAD);
    }
    request.equal(user.as_bytes())?;
    request.equal(b"ssh-connection")?;
    let method = request.string()?;
    if !matches!(
        method,
        b"publickey" | b"publickey-hostbound-v00@openssh.com"
    ) || request.take(1)? != [1]
    {
        return Err(BAD);
    }
    request.equal(b"ssh-ed25519")?;
    request.equal(&public_blob)?;
    if method != b"publickey" {
        request.equal(&host_blob)?;
    }
    if !request.0.is_empty() {
        return Err(BAD);
    }
    let signature: Signature = key.try_sign(&data).map_err(|_| BAD)?;
    Ok(STANDARD.encode(Vec::<u8>::try_from(signature).map_err(|_| BAD)?))
}
