use want_pass_vault::api::{AccountInputV1, GroupInputV1, Vault};

const PASSWORD: &str = "Synthetic content password 2026!";

fn create() -> (tempfile::TempDir, Vault) {
    let directory = tempfile::tempdir().unwrap();
    let vault = Vault::open(directory.path().join("vault").to_str().unwrap().to_owned()).unwrap();
    let challenge = vault
        .prepare_creation_v3(PASSWORD.to_owned(), vault.generation())
        .unwrap();
    vault
        .confirm_v3(
            challenge
                .positions
                .iter()
                .map(|p| challenge.words[*p as usize].clone())
                .collect(),
            PASSWORD.to_owned(),
            String::new(),
            String::new(),
            challenge.revision,
        )
        .unwrap();
    (directory, vault)
}

#[test]
fn groups_preserve_accounts_across_deletion_lock_and_reopen() {
    let (_directory, vault) = create();
    let empty = vault.content_v1(vault.generation()).unwrap();
    assert_eq!(empty.groups.len(), 0);
    let first = vault
        .save_group_v1(
            GroupInputV1 {
                id: None,
                name: "Synthetic project".into(),
                description: "Fixture description".into(),
                icon: "folder".into(),
                logo: vec![],
            },
            empty.revision,
            vault.generation(),
        )
        .unwrap();
    let group = first.groups[0].id.clone();
    let second = vault
        .save_group_v1(
            GroupInputV1 {
                id: None,
                name: "Synthetic company".into(),
                description: String::new(),
                icon: "building".into(),
                logo: vec![],
            },
            first.revision,
            vault.generation(),
        )
        .unwrap();
    let other = second.groups[1].id.clone();
    let account = vault
        .save_account_v1(
            AccountInputV1 {
                id: None,
                name: "Synthetic account".into(),
                description: "Fixture".into(),
                login: "fixture@example.invalid".into(),
                password: " synthetic account password ".into(),
                group_ids: vec![group.clone(), other.clone(), group.clone()],
            },
            second.revision,
            vault.generation(),
        )
        .unwrap();
    let id = account.accounts[0].id.clone();
    assert_eq!(account.accounts[0].group_ids.len(), 2);
    let removed = vault
        .delete_group_v1(group, account.revision, vault.generation())
        .unwrap();
    assert_eq!(removed.accounts.len(), 1);
    assert_eq!(removed.accounts[0].group_ids, vec![other]);
    vault.lock().unwrap();
    assert!(vault.content_v1(vault.generation()).is_err());
    vault
        .unlock_v3(PASSWORD.to_owned(), vault.generation())
        .unwrap();
    let reopened = vault.account_v1(id, vault.generation()).unwrap();
    assert_eq!(reopened.password, " synthetic account password ");
    assert_eq!(reopened.login, "fixture@example.invalid");
    assert_eq!(
        vault.content_v1(vault.generation()).unwrap().revision,
        removed.revision
    );
}

#[test]
fn invalid_and_stale_edits_preserve_the_authenticated_file() {
    use want_pass_vault::api::VaultFailure;
    let (directory, vault) = create();
    let path = directory.path().join("vault/vault.wpass");
    let original = std::fs::read(&path).unwrap();
    let invalid = vault.save_group_v1(
        GroupInputV1 {
            id: None,
            name: "  ".into(),
            description: String::new(),
            icon: "folder".into(),
            logo: vec![],
        },
        0,
        vault.generation(),
    );
    assert!(matches!(invalid, Err(VaultFailure::Unsupported)));
    assert_eq!(std::fs::read(&path).unwrap(), original);
    let saved = vault
        .save_group_v1(
            GroupInputV1 {
                id: None,
                name: "Fixture group".into(),
                description: String::new(),
                icon: "folder".into(),
                logo: vec![],
            },
            0,
            vault.generation(),
        )
        .unwrap();
    let baseline = std::fs::read(&path).unwrap();
    assert!(matches!(
        vault.delete_group_v1(saved.groups[0].id.clone(), 0, vault.generation()),
        Err(VaultFailure::Stale)
    ));
    assert_eq!(std::fs::read(&path).unwrap(), baseline);
    for marker in [b"Fixture group".as_slice(), b"Synthetic project".as_slice()] {
        assert!(!baseline.windows(marker.len()).any(|part| part == marker));
    }
    let generation = vault.generation();
    vault.lock().unwrap();
    assert!(matches!(
        vault.delete_group_v1(saved.groups[0].id.clone(), saved.revision, generation),
        Err(VaultFailure::Stale)
    ));
    assert_eq!(std::fs::read(&path).unwrap(), baseline);
}
