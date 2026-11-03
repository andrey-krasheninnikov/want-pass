use want_pass_vault::api::{Vault, VaultStatus};

const PASSWORD: &str = "Synthetic vault test password 2026";

#[test]
fn owner_creates_confirms_locks_and_reopens_an_offline_vault() {
    let directory = tempfile::tempdir().unwrap();
    let path = directory.path().join("private-vault");
    let vault = Vault::open(path.to_str().unwrap().to_owned()).unwrap();
    assert_eq!(vault.status().unwrap(), VaultStatus::Missing);
    let challenge = vault
        .prepare_creation(PASSWORD.to_owned(), vault.generation())
        .unwrap();
    assert_eq!(challenge.words.len(), 24);
    assert!(!path.join("vault.wpass").exists());
    let answers = challenge
        .positions
        .iter()
        .map(|i| challenge.words[*i as usize].clone())
        .collect();
    vault.confirm(answers, vault.generation()).unwrap();
    assert_eq!(vault.status().unwrap(), VaultStatus::Unlocked);
    vault.lock().unwrap();
    assert_eq!(vault.status().unwrap(), VaultStatus::Locked);
    vault
        .unlock(PASSWORD.to_owned(), vault.generation())
        .unwrap();
    assert_eq!(vault.status().unwrap(), VaultStatus::Unlocked);
    vault.close().unwrap();
    let reopened = Vault::open(path.to_str().unwrap().to_owned()).unwrap();
    assert_eq!(reopened.status().unwrap(), VaultStatus::Locked);
    reopened
        .unlock(PASSWORD.to_owned(), reopened.generation())
        .unwrap();
    assert_eq!(reopened.status().unwrap(), VaultStatus::Unlocked);
}

#[test]
fn owner_recovers_offline_and_retires_old_credentials() {
    let directory = tempfile::tempdir().unwrap();
    let path = directory.path().join("private-vault");
    let vault = Vault::open(path.to_str().unwrap().to_owned()).unwrap();
    let first = vault
        .prepare_creation(PASSWORD.to_owned(), vault.generation())
        .unwrap();
    let old_phrase = first.words.join(" ");
    vault
        .confirm(
            first
                .positions
                .iter()
                .map(|i| first.words[*i as usize].clone())
                .collect(),
            vault.generation(),
        )
        .unwrap();
    vault.lock().unwrap();
    let next_password = "Different synthetic recovery password 2026";
    let next = vault
        .prepare_recovery(
            old_phrase.clone(),
            next_password.to_owned(),
            vault.generation(),
        )
        .unwrap();
    let before = std::fs::read(path.join("vault.wpass")).unwrap();
    vault
        .confirm(
            next.positions
                .iter()
                .map(|i| next.words[*i as usize].clone())
                .collect(),
            vault.generation(),
        )
        .unwrap();
    assert_ne!(std::fs::read(path.join("vault.wpass")).unwrap(), before);
    vault.lock().unwrap();
    assert!(
        vault
            .unlock(PASSWORD.to_owned(), vault.generation())
            .is_err()
    );
    assert!(
        vault
            .prepare_recovery(old_phrase, next_password.to_owned(), vault.generation())
            .is_err()
    );
    vault
        .unlock(next_password.to_owned(), vault.generation())
        .unwrap();
    assert_eq!(vault.status().unwrap(), VaultStatus::Unlocked);
}

#[test]
fn authentication_and_tampering_never_replace_the_file() {
    use want_pass_vault::api::VaultFailure;
    let directory = tempfile::tempdir().unwrap();
    let path = directory.path().join("private-vault");
    let vault = Vault::open(path.to_str().unwrap().to_owned()).unwrap();
    let challenge = vault
        .prepare_creation(PASSWORD.to_owned(), vault.generation())
        .unwrap();
    let phrase = challenge.words.join(" ");
    assert_eq!(
        vault.confirm(vec!["wrong".to_owned(); 3], vault.generation()),
        Err(VaultFailure::Confirmation)
    );
    assert!(!path.join("vault.wpass").exists());
    vault
        .confirm(
            challenge
                .positions
                .iter()
                .map(|i| challenge.words[*i as usize].clone())
                .collect(),
            vault.generation(),
        )
        .unwrap();
    vault.lock().unwrap();
    let original = std::fs::read(path.join("vault.wpass")).unwrap();
    assert_eq!(
        vault.unlock(
            "Wrong synthetic password 2026".to_owned(),
            vault.generation()
        ),
        Err(VaultFailure::Credentials)
    );
    assert_eq!(std::fs::read(path.join("vault.wpass")).unwrap(), original);
    for position in [0, 8, 14, 30, 46, 70, 118, 142, 190, original.len() - 1] {
        let mut modified = original.clone();
        modified[position] ^= 1;
        std::fs::write(path.join("vault.wpass"), &modified).unwrap();
        assert!(
            vault
                .unlock(PASSWORD.to_owned(), vault.generation())
                .is_err()
        );
        assert!(
            vault
                .prepare_recovery(phrase.clone(), PASSWORD.to_owned(), vault.generation())
                .is_err()
        );
        assert_eq!(std::fs::read(path.join("vault.wpass")).unwrap(), modified);
        assert!(matches!(
            vault.prepare_creation(PASSWORD.to_owned(), vault.generation()),
            Err(VaultFailure::Exists)
        ));
    }
}

#[test]
fn lock_wins_over_an_unlock_already_running() {
    use std::{
        sync::Arc,
        time::{Duration, Instant},
    };
    use want_pass_vault::api::VaultFailure;
    let directory = tempfile::tempdir().unwrap();
    let path = directory.path().join("private-vault");
    let vault = Arc::new(Vault::open(path.to_str().unwrap().to_owned()).unwrap());
    let challenge = vault
        .prepare_creation(PASSWORD.to_owned(), vault.generation())
        .unwrap();
    vault
        .confirm(
            challenge
                .positions
                .iter()
                .map(|i| challenge.words[*i as usize].clone())
                .collect(),
            vault.generation(),
        )
        .unwrap();
    vault.lock().unwrap();
    let worker_vault = Arc::clone(&vault);
    let worker = std::thread::spawn(move || {
        loop {
            match worker_vault.unlock(PASSWORD.to_owned(), worker_vault.generation()) {
                Err(VaultFailure::Busy) => std::thread::sleep(Duration::from_millis(1)),
                result => break result,
            }
        }
    });
    let deadline = Instant::now() + Duration::from_secs(10);
    loop {
        if matches!(
            vault.prepare_creation(PASSWORD.to_owned(), vault.generation()),
            Err(VaultFailure::Busy)
        ) {
            break;
        }
        assert!(
            Instant::now() < deadline,
            "unlock never entered the operation boundary"
        );
        std::thread::sleep(Duration::from_millis(1));
    }
    vault.lock().unwrap();
    assert_eq!(worker.join().unwrap(), Err(VaultFailure::Stale));
    assert_eq!(vault.status().unwrap(), VaultStatus::Locked);
}

#[test]
fn a_request_queued_before_lock_cannot_open_the_next_generation() {
    use want_pass_vault::api::VaultFailure;
    let directory = tempfile::tempdir().unwrap();
    let vault = Vault::open(directory.path().join("vault").to_str().unwrap().to_owned()).unwrap();
    let queued_generation = vault.generation();
    vault.lock().unwrap();
    assert!(matches!(
        vault.prepare_creation(
            "Synthetic generation password 2026".to_owned(),
            queued_generation
        ),
        Err(VaultFailure::Stale)
    ));
    assert_eq!(vault.status().unwrap(), VaultStatus::Missing);
}
