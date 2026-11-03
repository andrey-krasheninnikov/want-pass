use super::*;

pub struct RecoveryChallengeV2 {
    pub words: Vec<String>,
    pub positions: Vec<u32>,
    pub choices: Vec<Vec<String>>,
}

pub struct VaultHintsV2 {
    pub password: String,
    pub recovery: String,
}

pub(super) struct DraftV2 {
    opened: Opened,
    entropy: Zeroizing<[u8; 32]>,
    positions: Vec<u32>,
    choices: Vec<Vec<String>>,
    expected: Option<[u8; 32]>,
    candidate: Option<Prepared>,
    input_digest: Option<Zeroizing<[u8; 32]>>,
}

fn index(limit: usize) -> Result<usize, VaultFailure> {
    let ceiling = 256 - 256 % limit;
    loop {
        let n = usize::from(format::random::<1>()?[0]);
        if n < ceiling {
            return Ok(n % limit);
        }
    }
}

impl DraftV2 {
    fn new(
        document: &[u8],
        id: Option<[u8; 16]>,
        expected: Option<[u8; 32]>,
    ) -> Result<Self, VaultFailure> {
        let (entropy, words) = loop {
            let entropy = Zeroizing::new(format::random::<32>()?);
            let words = format::words(entropy.as_ref())?;
            if words
                .iter()
                .collect::<std::collections::BTreeSet<_>>()
                .len()
                >= 3
            {
                break (entropy, words);
            }
        };
        let mut positions = Vec::new();
        while positions.len() < 3 {
            let next = index(24)?;
            if !positions.iter().any(|i| words[*i as usize] == words[next]) {
                positions.push(next as u32);
            }
        }
        let dictionary = bip39::Language::English.word_list();
        let mut choices = Vec::new();
        for position in &positions {
            let mut options = vec![words[*position as usize].clone()];
            while options.len() < 3 {
                let n = u16::from_le_bytes(format::random::<2>()?) as usize % dictionary.len();
                let word = dictionary[n].to_owned();
                if !words.contains(&word) && !options.contains(&word) {
                    options.push(word);
                }
            }
            for n in (1..options.len()).rev() {
                options.swap(n, index(n + 1)?);
            }
            choices.push(options);
        }
        Ok(Self {
            opened: Opened {
                key: Zeroizing::new(format::random()?),
                document: Zeroizing::new(document.to_vec()),
                id: match id {
                    Some(v) => v,
                    None => format::random()?,
                },
            },
            entropy,
            positions,
            choices,
            expected,
            candidate: None,
            input_digest: None,
        })
    }
    fn challenge(&self) -> Result<RecoveryChallengeV2, VaultFailure> {
        Ok(RecoveryChallengeV2 {
            words: format::words(self.entropy.as_ref())?,
            positions: self.positions.clone(),
            choices: self.choices.clone(),
        })
    }
}

impl Vault {
    pub fn export_recovery_v2(
        &self,
        destination: String,
        generation: u64,
    ) -> Result<(), VaultFailure> {
        use std::{fs, io::Write, path::Path};
        let state = self.state.lock().map_err(|_| VaultFailure::Unavailable)?;
        if state.closed || self.generation() != generation {
            return Err(VaultFailure::Stale);
        }
        let draft = state.draft_v2.as_ref().ok_or(VaultFailure::Confirmation)?;
        let path = Path::new(&destination);
        let parent = path.parent().ok_or(VaultFailure::Storage)?;
        if state.store.is_reserved_destination(path)? {
            return Err(VaultFailure::Storage);
        }
        match fs::symlink_metadata(path) {
            Ok(meta) if !meta.is_file() || meta.file_type().is_symlink() => {
                return Err(VaultFailure::Storage);
            }
            Ok(_) => {}
            Err(e) if e.kind() == std::io::ErrorKind::NotFound => {}
            Err(_) => return Err(VaultFailure::Storage),
        }
        let words = format::words(draft.entropy.as_ref())?
            .into_iter()
            .map(Zeroizing::new)
            .collect::<Vec<_>>();
        let phrase = Zeroizing::new(
            words
                .iter()
                .map(|v| v.as_str())
                .collect::<Vec<_>>()
                .join(" "),
        );
        let mut file =
            tempfile::NamedTempFile::new_in(parent).map_err(|_| VaultFailure::Storage)?;
        file.write_all(phrase.as_bytes())
            .and_then(|()| file.as_file().sync_all())
            .map_err(|_| VaultFailure::Storage)?;
        file.persist(path).map_err(|_| VaultFailure::Storage)?;
        fs::File::open(parent)
            .and_then(|f| f.sync_all())
            .map_err(|_| VaultFailure::WriteUncertain)
    }
    pub fn hints_v2(&self) -> Result<VaultHintsV2, VaultFailure> {
        let state = self.state.lock().map_err(|_| VaultFailure::Unavailable)?;
        if state.closed {
            return Err(VaultFailure::Closed);
        }
        let hints = match state.store.read()? {
            Some(bytes) => format::read_hints(&bytes)?,
            None => format::VaultHints::default(),
        };
        Ok(VaultHintsV2 {
            password: hints.password,
            recovery: hints.recovery,
        })
    }
    pub fn prepare_creation_v2(
        &self,
        password: String,
        generation: u64,
    ) -> Result<RecoveryChallengeV2, VaultFailure> {
        let password = Zeroizing::new(password);
        format::validate_password_v2(&password)?;
        let _job = self.job.try_lock().map_err(|_| VaultFailure::Busy)?;
        let mut state = self.state.lock().map_err(|_| VaultFailure::Unavailable)?;
        if state.closed || self.generation() != generation {
            return Err(VaultFailure::Stale);
        }
        if state.store.read()?.is_some() {
            return Err(VaultFailure::Exists);
        }
        if state.draft.is_some() {
            return Err(VaultFailure::Busy);
        }
        if let Some(draft) = &state.draft_v2 {
            return draft.challenge();
        }
        let draft = DraftV2::new(&[], None, None)?;
        let challenge = draft.challenge()?;
        state.draft_v2 = Some(draft);
        Ok(challenge)
    }
    pub fn prepare_recovery_v2(
        &self,
        phrase: String,
        password: String,
        generation: u64,
    ) -> Result<RecoveryChallengeV2, VaultFailure> {
        let phrase = Zeroizing::new(phrase);
        let password = Zeroizing::new(password);
        format::validate_password_v2(&password)?;
        let _job = self.job.try_lock().map_err(|_| VaultFailure::Busy)?;
        if self.generation() != generation {
            return Err(VaultFailure::Stale);
        }
        let bytes = {
            let state = self.state.lock().map_err(|_| VaultFailure::Unavailable)?;
            if state.closed {
                return Err(VaultFailure::Closed);
            }
            if state.draft.is_some() {
                return Err(VaultFailure::Busy);
            }
            state.store.read()?.ok_or(VaultFailure::Missing)?
        };
        let opened = format::open_recovery(&bytes, &phrase)?;
        let mut state = self.state.lock().map_err(|_| VaultFailure::Unavailable)?;
        if state.closed || self.generation() != generation {
            return Err(VaultFailure::Stale);
        }
        if state.store.read()?.as_deref().map(digest) != Some(digest(&bytes)) {
            return Err(VaultFailure::Stale);
        }
        if let Some(draft) = &state.draft_v2 {
            if draft.expected != Some(digest(&bytes)) {
                return Err(VaultFailure::Stale);
            }
            return draft.challenge();
        }
        let draft = DraftV2::new(&opened.document, Some(opened.id), Some(digest(&bytes)))?;
        let challenge = draft.challenge()?;
        state.active = None;
        state.draft_v2 = Some(draft);
        Ok(challenge)
    }
    pub fn confirm_v2(
        &self,
        answers: Vec<String>,
        password: String,
        password_hint: String,
        recovery_hint: String,
        generation: u64,
    ) -> Result<(), VaultFailure> {
        let password = Zeroizing::new(password);
        let answers: Vec<_> = answers.into_iter().map(Zeroizing::new).collect();
        format::validate_password_v2(&password)?;
        let hints = format::VaultHints {
            password: password_hint,
            recovery: recovery_hint,
        };
        format::validate_hints(&hints)?;
        let _job = self.job.try_lock().map_err(|_| VaultFailure::Busy)?;
        let (opened, entropy, input_digest) = {
            let state = self.state.lock().map_err(|_| VaultFailure::Unavailable)?;
            if state.closed || self.generation() != generation {
                return Err(VaultFailure::Stale);
            }
            let draft = state.draft_v2.as_ref().ok_or(VaultFailure::Confirmation)?;
            let words = format::words(draft.entropy.as_ref())?
                .into_iter()
                .map(Zeroizing::new)
                .collect::<Vec<_>>();
            if answers.len() != 3
                || answers
                    .iter()
                    .zip(&draft.positions)
                    .any(|(a, i)| a.as_str() != words[*i as usize].as_str())
            {
                return Err(VaultFailure::Confirmation);
            }
            let mut input = Zeroizing::new(Vec::new());
            for value in [
                password.as_bytes(),
                hints.password.as_bytes(),
                hints.recovery.as_bytes(),
            ] {
                input.extend_from_slice(&(value.len() as u32).to_le_bytes());
                input.extend_from_slice(value);
            }
            let input_digest = Zeroizing::new(digest(&input));
            if let Some(previous) = &draft.input_digest
                && previous.as_ref() != input_digest.as_ref()
            {
                return Err(VaultFailure::Stale);
            }
            (
                Opened {
                    key: draft.opened.key.clone(),
                    document: draft.opened.document.clone(),
                    id: draft.opened.id,
                },
                draft.entropy.clone(),
                input_digest,
            )
        };
        // KDF runs outside the state lock so a lock request can invalidate this operation.
        let candidate = format::seal(&password, opened, entropy, &hints)?;
        let mut state = self.state.lock().map_err(|_| VaultFailure::Unavailable)?;
        if state.closed || self.generation() != generation {
            return Err(VaultFailure::Stale);
        }
        let draft = state.draft_v2.as_mut().ok_or(VaultFailure::Confirmation)?;
        if draft.candidate.is_none() {
            draft.candidate = Some(candidate);
            draft.input_digest = Some(input_digest);
        }
        let draft = state.draft_v2.as_ref().ok_or(VaultFailure::Confirmation)?;
        state.store.commit(
            &draft
                .candidate
                .as_ref()
                .ok_or(VaultFailure::Confirmation)?
                .bytes,
            draft.expected,
        )?;
        let draft = state.draft_v2.take().ok_or(VaultFailure::Confirmation)?;
        state.active = Some(draft.candidate.ok_or(VaultFailure::Confirmation)?.opened);
        Ok(())
    }
}
