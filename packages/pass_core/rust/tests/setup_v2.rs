use std::{fs, os::unix::fs::PermissionsExt};
use want_pass_vault::{
    api::{Vault, VaultFailure, VaultStatus},
    format,
};

const PASSWORD: &str = "Synthetic master password 2026!";
const NEXT: &str = "Different master password 2026!";

#[test]
fn v3_unlock_is_strict_and_v1_unlock_keeps_its_contract() {
    let temporary = tempfile::tempdir().unwrap();
    let directory = temporary.path().join("vault");
    let vault = Vault::open(directory.to_str().unwrap().to_owned()).unwrap();
    let password = "legacy synthetic password";
    let challenge = vault
        .prepare_creation(password.to_owned(), vault.generation())
        .unwrap();
    let answers = challenge
        .positions
        .iter()
        .map(|i| challenge.words[*i as usize].clone())
        .collect();
    vault.confirm(answers, vault.generation()).unwrap();
    vault.lock().unwrap();
    let before = fs::read(directory.join("vault.wpass")).unwrap();
    assert_eq!(
        vault.unlock_v3(password.to_owned(), vault.generation()),
        Err(VaultFailure::InvalidPassword)
    );
    assert_eq!(fs::read(directory.join("vault.wpass")).unwrap(), before);
    vault
        .unlock(password.to_owned(), vault.generation())
        .unwrap();
}

#[test]
fn unicode_password_policy_requires_all_classes_and_one_line() {
    for value in [
        PASSWORD,
        "Синтетический пароль 2026!",
        "Aa123456789012😀",
        " Space preserved 2026! ",
    ] {
        assert_eq!(format::validate_password_v2(value), Ok(()));
    }
    for value in [
        "shortA1!",
        "lowercase password 2026!",
        "UPPERCASE PASSWORD 2026!",
        "No digits in this password!",
        "No special character 2026",
        "NoAsciiDigit password ２０２６!",
        "Combining mark password 2026\u{301}",
        "Line\nbreak Password 2026!",
        "Line\rbreak Password 2026!",
        "Line\u{2028}break Password 2026!",
    ] {
        assert_eq!(
            format::validate_password_v2(value),
            Err(VaultFailure::InvalidPassword)
        );
    }
    assert!(format::validate_password_v2(&format!("Aa1!{}", "é".repeat(511))).is_err());
}

#[test]
fn setup_preserves_words_and_authenticates_public_hints() {
    let temporary = tempfile::tempdir().unwrap();
    let directory = temporary.path().join("vault");
    let vault = Vault::open(directory.to_str().unwrap().to_owned()).unwrap();
    let challenge = vault
        .prepare_creation_v2(PASSWORD.to_owned(), vault.generation())
        .unwrap();
    let again = vault
        .prepare_creation_v2(NEXT.to_owned(), vault.generation())
        .unwrap();
    assert_eq!(challenge.words, again.words);
    assert_eq!(challenge.positions, again.positions);
    assert_eq!(challenge.choices, again.choices);
    let checked = challenge
        .positions
        .iter()
        .map(|i| &challenge.words[*i as usize])
        .collect::<std::collections::BTreeSet<_>>();
    assert_eq!(checked.len(), 3);
    for (options, index) in challenge.choices.iter().zip(&challenge.positions) {
        assert_eq!(options.len(), 3);
        assert_eq!(
            options
                .iter()
                .collect::<std::collections::BTreeSet<_>>()
                .len(),
            3
        );
        assert_eq!(
            options
                .iter()
                .filter(|v| challenge.words.contains(v))
                .count(),
            1
        );
        assert!(options.contains(&challenge.words[*index as usize]));
    }
    let answers = challenge
        .positions
        .iter()
        .map(|i| challenge.words[*i as usize].clone())
        .collect::<Vec<_>>();
    assert!(!directory.join("vault.wpass").exists());
    assert_eq!(
        vault.confirm_v2(
            answers.clone(),
            NEXT.to_owned(),
            "x".repeat(257),
            String::new(),
            vault.generation()
        ),
        Err(VaultFailure::Unsupported)
    );
    vault
        .confirm_v2(
            answers,
            NEXT.to_owned(),
            "synthetic password hint".to_owned(),
            "synthetic location hint".to_owned(),
            vault.generation(),
        )
        .unwrap();
    vault.lock().unwrap();
    let hints = vault.hints_v2().unwrap();
    assert_eq!(hints.password, "synthetic password hint");
    assert_eq!(hints.recovery, "synthetic location hint");
    assert!(
        vault
            .unlock(PASSWORD.to_owned(), vault.generation())
            .is_err()
    );
    vault.unlock(NEXT.to_owned(), vault.generation()).unwrap();
    vault.lock().unwrap();
    vault
        .unlock_v3(NEXT.to_owned(), vault.generation())
        .unwrap();
    vault.lock().unwrap();
    let original = fs::read(directory.join("vault.wpass")).unwrap();
    let mut changed = original.clone();
    changed[50] ^= 1;
    fs::write(directory.join("vault.wpass"), &changed).unwrap();
    assert!(vault.unlock(NEXT.to_owned(), vault.generation()).is_err());
    assert!(
        vault
            .prepare_recovery_v2(
                challenge.words.join(" "),
                NEXT.to_owned(),
                vault.generation()
            )
            .is_err()
    );
    assert_eq!(fs::read(directory.join("vault.wpass")).unwrap(), changed);
    let mut old_format = original;
    old_format[8] = 1;
    fs::write(directory.join("vault.wpass"), &old_format).unwrap();
    assert_eq!(
        vault.unlock(NEXT.to_owned(), vault.generation()),
        Err(VaultFailure::Unsupported)
    );
    assert_eq!(fs::read(directory.join("vault.wpass")).unwrap(), old_format);
}

#[test]
fn export_is_private_and_lock_invalidates_pending_export() {
    let temporary = tempfile::tempdir().unwrap();
    let directory = temporary.path().join("vault");
    let vault = Vault::open(directory.to_str().unwrap().to_owned()).unwrap();
    let challenge = vault
        .prepare_creation_v2(PASSWORD.to_owned(), vault.generation())
        .unwrap();
    let path = temporary.path().join("recovery.txt");
    vault
        .export_recovery_v2(path.to_str().unwrap().to_owned(), vault.generation())
        .unwrap();
    assert_eq!(
        fs::read_to_string(&path).unwrap(),
        challenge.words.join(" ")
    );
    assert_eq!(
        fs::metadata(&path).unwrap().permissions().mode() & 0o777,
        0o600
    );
    assert_eq!(
        vault.export_recovery_v2(
            directory.join("vault.wpass").to_str().unwrap().to_owned(),
            vault.generation()
        ),
        Err(VaultFailure::Storage)
    );
    let generation = vault.generation();
    vault.lock().unwrap();
    let cancelled = temporary.path().join("cancelled.txt");
    assert_eq!(
        vault.export_recovery_v2(cancelled.to_str().unwrap().to_owned(), generation),
        Err(VaultFailure::Stale)
    );
    assert!(!cancelled.exists());
    assert_eq!(vault.status().unwrap(), VaultStatus::Missing);
}

#[test]
fn recovery_v2_rotates_phrase_and_password_after_three_answers() {
    let temporary = tempfile::tempdir().unwrap();
    let vault = Vault::open(temporary.path().join("vault").to_str().unwrap().to_owned()).unwrap();
    let first = vault
        .prepare_creation_v2(PASSWORD.to_owned(), vault.generation())
        .unwrap();
    vault
        .confirm_v2(
            first
                .positions
                .iter()
                .map(|i| first.words[*i as usize].clone())
                .collect(),
            PASSWORD.to_owned(),
            String::new(),
            String::new(),
            vault.generation(),
        )
        .unwrap();
    vault.lock().unwrap();
    let next = vault
        .prepare_recovery_v2(first.words.join(" "), NEXT.to_owned(), vault.generation())
        .unwrap();
    assert_ne!(next.words, first.words);
    assert_eq!(
        vault.confirm_v2(
            vec!["wrong".to_owned(); 3],
            NEXT.to_owned(),
            String::new(),
            String::new(),
            vault.generation()
        ),
        Err(VaultFailure::Confirmation)
    );
    vault
        .confirm_v2(
            next.positions
                .iter()
                .map(|i| next.words[*i as usize].clone())
                .collect(),
            NEXT.to_owned(),
            "new hint".to_owned(),
            "new location".to_owned(),
            vault.generation(),
        )
        .unwrap();
    vault.lock().unwrap();
    assert!(
        vault
            .unlock(PASSWORD.to_owned(), vault.generation())
            .is_err()
    );
    assert!(
        vault
            .prepare_recovery_v2(first.words.join(" "), NEXT.to_owned(), vault.generation())
            .is_err()
    );
    vault.unlock(NEXT.to_owned(), vault.generation()).unwrap();
    assert_eq!(vault.hints_v2().unwrap().recovery, "new location");
}
