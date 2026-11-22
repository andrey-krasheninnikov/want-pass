use super::VaultFailure;
use bip39::{Language, Mnemonic};
use serde::de::{Error, MapAccess, Visitor};
use std::fmt;
use zeroize::Zeroizing;

const COUNT: usize = 24;
const INPUT_LIMIT: usize = 16 * 1024;

pub struct RecoveryInputV1 {
    pub words: Vec<String>,
    pub invalid_positions: Vec<u32>,
    pub complete: bool,
    pub recognized: bool,
}

fn index(key: &str) -> Option<usize> {
    let n = key.parse::<usize>().ok()?;
    ((1..=COUNT).contains(&n) && key == n.to_string()).then(|| n - 1)
}

struct Numbered;
impl<'de> Visitor<'de> for Numbered {
    type Value = Vec<String>;
    fn expecting(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str("a numbered recovery phrase")
    }
    fn visit_map<M: MapAccess<'de>>(self, mut data: M) -> Result<Vec<String>, M::Error> {
        let mut result = vec![None; COUNT];
        while let Some((key, value)) = data.next_entry::<String, String>()? {
            let slot = index(&key).ok_or_else(|| M::Error::custom("invalid position"))?;
            if result[slot].replace(value).is_some() {
                return Err(M::Error::custom("repeated position"));
            }
        }
        result
            .into_iter()
            .collect::<Option<Vec<_>>>()
            .ok_or_else(|| M::Error::custom("missing position"))
    }
}

fn unpack(input: &str) -> Option<Vec<String>> {
    if input.len() > INPUT_LIMIT {
        return None;
    }
    let input = input.trim();
    if input.starts_with('{') {
        let mut decoder = serde_json::Deserializer::from_str(input);
        let words = serde::Deserializer::deserialize_map(&mut decoder, Numbered).ok()?;
        decoder.end().ok()?;
        return Some(words);
    }
    if input.starts_with('[') {
        let words: Vec<String> = serde_json::from_str(input).ok()?;
        return (words.len() <= COUNT).then_some(words);
    }
    if input.as_bytes().first().is_some_and(u8::is_ascii_digit) {
        let mut words = vec![None; COUNT];
        for line in input.lines().map(str::trim).filter(|s| !s.is_empty()) {
            let (n, value) = line.split_once(['.', ')', ':'])?;
            let slot = index(n.trim())?;
            let word = value.trim();
            if word.is_empty()
                || word.split_whitespace().count() != 1
                || words[slot].replace(word.to_owned()).is_some()
            {
                return None;
            }
        }
        return words.into_iter().collect();
    }
    let words: Vec<_> = input
        .split(|c: char| c.is_whitespace() || c == ',')
        .filter(|word| !word.is_empty())
        .take(COUNT + 1)
        .map(str::to_owned)
        .collect();
    (words.len() <= COUNT).then_some(words)
}

#[flutter_rust_bridge::frb(sync)]
pub fn inspect_recovery_input_v1(input: String) -> RecoveryInputV1 {
    let input = Zeroizing::new(input);
    let Some(words) = unpack(&input) else {
        return RecoveryInputV1 {
            words: Vec::new(),
            invalid_positions: Vec::new(),
            complete: false,
            recognized: false,
        };
    };
    let invalid_positions: Vec<_> = words
        .iter()
        .enumerate()
        .filter_map(|(i, word)| {
            (!word.is_empty()
                && Language::English
                    .word_list()
                    .binary_search(&word.as_str())
                    .is_err())
            .then_some(i as u32 + 1)
        })
        .collect();
    let complete = words.len() == COUNT
        && invalid_positions.is_empty()
        && words.iter().all(|w| !w.is_empty())
        && Mnemonic::parse_in(Language::English, &*Zeroizing::new(words.join(" "))).is_ok();
    RecoveryInputV1 {
        words,
        invalid_positions,
        complete,
        recognized: true,
    }
}

pub(super) fn parse_phrase(input: &str) -> Result<Zeroizing<String>, VaultFailure> {
    let parsed = inspect_recovery_input_v1(input.to_owned());
    let words = Zeroizing::new(parsed.words);
    if !parsed.complete {
        return Err(VaultFailure::InvalidPhrase);
    }
    Ok(Zeroizing::new(words.join(" ")))
}
