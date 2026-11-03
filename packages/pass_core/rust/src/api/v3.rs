use super::*;
use serde::de::{Error, MapAccess, Visitor};
use std::fmt;

pub struct RecoveryChallengeV3 {
    pub words: Vec<String>,
    pub positions: Vec<u32>,
    pub choices: Vec<Vec<String>>,
    pub json: String,
    pub revision: u64,
}

pub(super) fn recovery_json(words: &[String]) -> Zeroizing<String> {
    Zeroizing::new(format!(
        "{{{}}}",
        words
            .iter()
            .enumerate()
            .map(|(i, w)| format!("\"{}\":\"{}\"", i + 1, w))
            .collect::<Vec<_>>()
            .join(",")
    ))
}

fn parse_phrase(input: &str) -> Result<Zeroizing<String>, VaultFailure> {
    if input.len() > 16 * 1024 {
        return Err(VaultFailure::InvalidPhrase);
    }
    if !input.trim_start().starts_with('{') {
        return Ok(Zeroizing::new(input.to_owned()));
    }
    struct Words;
    impl<'de> Visitor<'de> for Words {
        type Value = Zeroizing<String>;
        fn expecting(&self, f: &mut fmt::Formatter) -> fmt::Result {
            f.write_str("24 numbered recovery words")
        }
        fn visit_map<M: MapAccess<'de>>(self, mut map: M) -> Result<Self::Value, M::Error> {
            let mut words: Vec<Option<Zeroizing<String>>> = (0..24).map(|_| None).collect();
            while let Some((key, word)) = map.next_entry::<String, String>()? {
                let word = Zeroizing::new(word);
                let index = (1..=24)
                    .find(|i| i.to_string() == key)
                    .ok_or_else(|| M::Error::custom("invalid recovery key"))?
                    - 1;
                if words[index].is_some()
                    || !bip39::Language::English
                        .word_list()
                        .contains(&word.as_str())
                {
                    return Err(M::Error::custom("invalid recovery word"));
                }
                words[index] = Some(word);
            }
            if words.iter().any(Option::is_none) {
                return Err(M::Error::custom("missing recovery word"));
            }
            Ok(Zeroizing::new(
                words
                    .iter()
                    .map(|w| w.as_ref().unwrap().as_str())
                    .collect::<Vec<_>>()
                    .join(" "),
            ))
        }
    }
    let mut decoder = serde_json::Deserializer::from_str(input);
    let phrase = serde::Deserializer::deserialize_map(&mut decoder, Words)
        .map_err(|_| VaultFailure::InvalidPhrase)?;
    decoder.end().map_err(|_| VaultFailure::InvalidPhrase)?;
    Ok(phrase)
}

fn challenge(value: RecoveryChallengeV2, revision: u64) -> RecoveryChallengeV3 {
    RecoveryChallengeV3 {
        json: recovery_json(&value.words).to_string(),
        words: value.words,
        positions: value.positions,
        choices: value.choices,
        revision,
    }
}

impl Vault {
    pub fn validate_recovery_v3(
        &self,
        phrase: String,
        generation: u64,
    ) -> Result<(), VaultFailure> {
        let input = Zeroizing::new(phrase);
        let phrase = parse_phrase(&input)?;
        let _job = self.job.try_lock().map_err(|_| VaultFailure::Busy)?;
        let bytes = {
            let state = self.state.lock().map_err(|_| VaultFailure::Unavailable)?;
            if state.closed || self.generation() != generation {
                return Err(VaultFailure::Stale);
            }
            state.store.read()?.ok_or(VaultFailure::Missing)?
        };
        let _opened = format::open_recovery(&bytes, &phrase)?;
        if self.generation() != generation {
            return Err(VaultFailure::Stale);
        }
        Ok(())
    }
    pub fn prepare_creation_v3(
        &self,
        password: String,
        generation: u64,
    ) -> Result<RecoveryChallengeV3, VaultFailure> {
        self.prepare_creation_v2(password, generation)
            .map(|v| challenge(v, generation))
    }
    pub fn prepare_recovery_v3(
        &self,
        phrase: String,
        password: String,
        generation: u64,
    ) -> Result<RecoveryChallengeV3, VaultFailure> {
        let input = Zeroizing::new(phrase);
        let password = Zeroizing::new(password);
        let phrase = parse_phrase(&input)?;
        self.prepare_recovery_v2(phrase.to_string(), password.to_string(), generation)
            .map(|v| challenge(v, generation))
    }
    pub fn regenerate_recovery_v3(
        &self,
        generation: u64,
    ) -> Result<RecoveryChallengeV3, VaultFailure> {
        let _job = self.job.try_lock().map_err(|_| VaultFailure::Busy)?;
        let (value, revision) = {
            let mut state = self.state.lock().map_err(|_| VaultFailure::Unavailable)?;
            if state.closed || self.generation() != generation {
                return Err(VaultFailure::Stale);
            }
            let previous = state.draft_v2.take().ok_or(VaultFailure::Confirmation)?;
            // Invalidate old exports and candidates even when fresh entropy is unavailable.
            let revision = self.epoch.fetch_add(1, Ordering::SeqCst) + 1;
            let next = v2::DraftV2::new(
                &previous.opened.document,
                Some(previous.opened.id),
                previous.expected,
            );
            match next {
                Ok(next) => {
                    let value = next.challenge();
                    state.draft_v2 = Some(next);
                    (value, revision)
                }
                Err(error) => (Err(error), revision),
            }
        };
        self.wait_for_exports_v2()?;
        if self.generation() != revision {
            return Err(VaultFailure::Stale);
        }
        Ok(challenge(value?, revision))
    }
    pub fn export_recovery_v3(
        &self,
        destination: String,
        revision: u64,
    ) -> Result<(), VaultFailure> {
        self.export_recovery_with_hook(destination, revision, true, || {}, || {})
    }
    pub fn confirm_v3(
        &self,
        answers: Vec<String>,
        password: String,
        password_hint: String,
        recovery_hint: String,
        revision: u64,
    ) -> Result<(), VaultFailure> {
        self.confirm_v2(answers, password, password_hint, recovery_hint, revision)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn json_is_strict_and_allows_repeated_words() {
        let words = format::words(&[0; 32]).unwrap();
        let json = recovery_json(&words);
        assert_eq!(parse_phrase(&json).unwrap().as_str(), words.join(" "));
        let reordered = format!(
            "{{{}}}",
            words
                .iter()
                .enumerate()
                .rev()
                .map(|(i, w)| format!("\"{}\":\"{}\"", i + 1, w))
                .collect::<Vec<_>>()
                .join(",")
        );
        assert_eq!(parse_phrase(&reordered).unwrap().as_str(), words.join(" "));
        for invalid in [
            "{}".to_owned(),
            json.replace("\"24\":", "\"1\":"),
            json.replace("\"24\":", "\"25\":"),
            json.replace("\"abandon\"", "true"),
            json.replace("abandon", "ABANDON"),
            format!("{} false", json.as_str()),
            " ".repeat(16385),
        ] {
            assert_eq!(
                parse_phrase(&invalid).unwrap_err(),
                VaultFailure::InvalidPhrase
            );
        }
    }
    #[test]
    fn regeneration_fences_both_queued_and_admitted_exports() {
        use std::{
            sync::{Arc, mpsc},
            thread,
            time::Duration,
        };
        for admitted in [false, true] {
            let temporary = tempfile::tempdir().unwrap();
            let vault = Arc::new(
                Vault::open(temporary.path().join("vault").to_str().unwrap().to_owned()).unwrap(),
            );
            let old = vault
                .prepare_creation_v3(
                    "Synthetic export password 2026!".to_owned(),
                    vault.generation(),
                )
                .unwrap();
            let destination = temporary.path().join("recovery.json");
            let (ready_tx, ready_rx) = mpsc::channel();
            let (resume_tx, resume_rx) = mpsc::channel();
            let worker = Arc::clone(&vault);
            let path = destination.to_str().unwrap().to_owned();
            let export = thread::spawn(move || {
                if admitted {
                    worker.export_recovery_with_hook(
                        path,
                        old.revision,
                        true,
                        || {},
                        || {
                            ready_tx.send(()).unwrap();
                            resume_rx.recv().unwrap();
                        },
                    )
                } else {
                    worker.export_recovery_with_hook(
                        path,
                        old.revision,
                        true,
                        || {
                            ready_tx.send(()).unwrap();
                            resume_rx.recv().unwrap();
                        },
                        || {},
                    )
                }
            });
            ready_rx.recv_timeout(Duration::from_secs(2)).unwrap();
            let (done_tx, done_rx) = mpsc::channel();
            let replacing = Arc::clone(&vault);
            let regenerate = thread::spawn(move || {
                done_tx
                    .send(replacing.regenerate_recovery_v3(old.revision))
                    .unwrap()
            });
            let early = done_rx.recv_timeout(Duration::from_millis(100));
            let invalidated = vault.generation() != old.revision;
            resume_tx.send(()).unwrap();
            let exported = export.join().unwrap();
            regenerate.join().unwrap();
            assert!(invalidated);
            if admitted {
                assert!(matches!(early, Err(mpsc::RecvTimeoutError::Timeout)));
                assert_eq!(exported, Ok(()));
                done_rx
                    .recv_timeout(Duration::from_secs(2))
                    .unwrap()
                    .unwrap();
            } else {
                early.unwrap().unwrap();
                assert_eq!(exported, Err(VaultFailure::Stale));
                assert!(!destination.exists());
            }
        }
    }

    #[test]
    fn regeneration_invalidates_revision_and_json_export_round_trips() {
        let temporary = tempfile::tempdir().unwrap();
        let vault =
            Vault::open(temporary.path().join("vault").to_str().unwrap().to_owned()).unwrap();
        let password = "Synthetic password 2026!".to_owned();
        let original = vault
            .prepare_creation_v3(password.clone(), vault.generation())
            .unwrap();
        let next = vault.regenerate_recovery_v3(original.revision).unwrap();
        assert_ne!(original.words, next.words);
        assert_ne!(original.revision, next.revision);
        let destination = temporary.path().join("recovery.json");
        assert_eq!(
            vault.export_recovery_v3(destination.to_str().unwrap().to_owned(), original.revision),
            Err(VaultFailure::Stale)
        );
        vault
            .export_recovery_v3(destination.to_str().unwrap().to_owned(), next.revision)
            .unwrap();
        assert_eq!(std::fs::read_to_string(&destination).unwrap(), next.json);
        let answers = next
            .positions
            .iter()
            .map(|i| next.words[*i as usize].clone())
            .collect();
        vault
            .confirm_v3(
                answers,
                password,
                String::new(),
                String::new(),
                next.revision,
            )
            .unwrap();
        vault.lock().unwrap();
        vault
            .validate_recovery_v3(next.json, vault.generation())
            .unwrap();
        assert!(
            vault
                .validate_recovery_v3(original.json, vault.generation())
                .is_err()
        );
    }
}
