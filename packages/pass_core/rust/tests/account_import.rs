use want_pass_vault::api::{
    AccountImportSourceV1, BindingMethodV1, CardTypeV1, FieldIdV1, ResourceKindV1, Vault,
    VaultFailure, totp_code_v1,
};

const CSV: &str = include_str!("fixtures/apple-passwords-macos.csv");
const PASSWORD: &str = "Synthetic import lock 2026!";

fn vault() -> (tempfile::TempDir, Vault) {
    let directory = tempfile::tempdir().unwrap();
    let vault = Vault::open(directory.path().join("data").to_str().unwrap().into()).unwrap();
    let draft = vault
        .prepare_creation_v3(PASSWORD.into(), vault.generation())
        .unwrap();
    vault
        .confirm_v3(
            draft
                .positions
                .iter()
                .map(|p| draft.words[*p as usize].clone())
                .collect(),
            PASSWORD.into(),
            String::new(),
            String::new(),
            draft.revision,
        )
        .unwrap();
    (directory, vault)
}

const MULTIPART: &str = include_str!("fixtures/authenticator-migration-v1.txt");
const SINGLE: &str = include_str!("fixtures/authenticator-single-v1.txt");
const PROVISIONING: &str =
    "otpauth://totp/Test%3Afirst?secret=GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ&issuer=Test&digits=8";

#[test]
fn migration_batch_reorders_parts_and_matches_the_source_at_a_time_boundary() {
    let (_directory, vault) = vault();
    let generation = vault.generation();
    let prepare = |input: Vec<String>, revision| {
        vault.prepare_account_import_v1(
            AccountImportSourceV1::Authenticator,
            input,
            revision,
            generation,
        )
    };
    let parts: Vec<String> = MULTIPART.lines().map(str::to_owned).collect();
    let single = prepare(vec![SINGLE.trim().into()], 0).unwrap();
    assert_eq!(single.rows.len(), 1);
    vault
        .cancel_account_import_v1(single.token, generation)
        .unwrap();
    for invalid in [
        vec![parts[0].clone()],
        vec![parts[1].clone(), parts[1].clone()],
        vec![PROVISIONING.into(), parts[1].clone()],
        vec![parts[0].clone(), SINGLE.trim().into()],
        vec![PROVISIONING.into(), format!("{PROVISIONING}&algorithm=MD5")],
        vec![format!("{PROVISIONING}&period=0")],
        vec![format!("{PROVISIONING}&issuer=second")],
        vec!["otpauth-migration://offline?data=broken".into()],
    ] {
        assert!(prepare(invalid, 0).is_err());
    }
    assert!(vault.content_v2(generation).unwrap().cards.is_empty());
    let draft = prepare(parts.into_iter().rev().collect(), 0).unwrap();
    assert_eq!(draft.rows.len(), 2);
    assert_eq!(draft.rows[0].name, "Test: first");
    assert_eq!(draft.rows[1].name, "Test: second");
    let saved = vault
        .apply_account_import_v1(draft.token, vec![0, 1], generation)
        .unwrap();
    assert_eq!(saved.revision, 1);
    for (index, expected) in [(0, "94287082"), (1, "46119246")] {
        let card = vault
            .card_v1(saved.cards[index].id.clone(), generation)
            .unwrap();
        assert!(card.summary.card_type == CardTypeV1::Totp);
        let field = |id| {
            card.fields
                .iter()
                .find(|f| f.id == id)
                .unwrap()
                .value
                .clone()
        };
        let code = |time| {
            totp_code_v1(
                field(FieldIdV1::TotpSeed),
                field(FieldIdV1::TotpAlgorithm),
                field(FieldIdV1::TotpDigits).parse().unwrap(),
                field(FieldIdV1::TotpPeriod).parse().unwrap(),
                time,
            )
            .unwrap()
        };
        assert!(code(59).code == expected);
        assert_eq!(code(59).valid_until, 60);
        assert_eq!(code(60).valid_until, 90);
        if index == 0 {
            assert!(code(60).code == "37359152");
        }
    }
    let duplicate = prepare(vec![PROVISIONING.into()], saved.revision).unwrap();
    assert!(duplicate.rows[0].duplicate);
    assert_eq!(
        vault
            .apply_account_import_v1(duplicate.token, vec![], generation)
            .unwrap()
            .cards
            .len(),
        2
    );
}

#[test]
fn provisioning_hotp_preserves_counter_and_checks_conflicts_without_partial_writes() {
    let (_directory, vault) = vault();
    let generation = vault.generation();
    let uri = "otpauth://hotp/Test%3Acounter?secret=GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ&counter=0&issuer=Test";
    let prepare = |rows: Vec<String>, rev| {
        vault.prepare_account_import_v1(AccountImportSourceV1::Authenticator, rows, rev, generation)
    };
    assert!(prepare(vec![format!("{uri}&digits=8")], 0).is_err());
    let batch = prepare(vec![PROVISIONING.into(), uri.into(), uri.into()], 0).unwrap();
    assert!(!batch.rows[1].duplicate && batch.rows[2].duplicate);
    assert!(
        vault
            .apply_account_import_v1(batch.token, vec![0, 5], generation)
            .is_err()
    );
    assert!(vault.content_v2(generation).unwrap().cards.is_empty());
    let batch = prepare(vec![uri.into()], 0).unwrap();
    let saved = vault
        .apply_account_import_v1(batch.token, vec![0], generation)
        .unwrap();
    let stale = prepare(vec![PROVISIONING.into()], saved.revision).unwrap();
    let next = vault
        .next_hotp_v1(saved.cards[0].id.clone(), saved.revision, generation)
        .unwrap();
    assert!(next.code == "755224");
    assert!(matches!(
        vault.apply_account_import_v1(stale.token, vec![0], generation),
        Err(VaultFailure::Stale)
    ));
    assert_eq!(vault.content_v2(generation).unwrap().cards.len(), 1);
}

#[test]
fn apple_preview_cancel_duplicates_and_atomic_apply() {
    let (_dir, vault) = vault();
    let generation = vault.generation();
    let preview = |csv: &str, rev| {
        vault.prepare_account_import_v1(
            AccountImportSourceV1::ApplePasswords,
            vec![csv.into()],
            rev,
            generation,
        )
    };
    let draft = preview(CSV, 0).unwrap();
    assert_eq!(draft.rows.len(), 1);
    assert_eq!(draft.rows[0].name, "Example");
    assert!(!draft.rows[0].duplicate);
    vault
        .cancel_account_import_v1(draft.token.clone(), generation)
        .unwrap();
    assert!(matches!(
        vault.apply_account_import_v1(draft.token, vec![0], generation),
        Err(VaultFailure::Stale)
    ));
    let bad = format!("{CSV}Broken,not-a-url,user,second,,\r\n");
    assert!(preview(&bad, 0).is_err());
    assert!(vault.content_v2(generation).unwrap().cards.is_empty());
    let crlf = format!("\u{feff}{}", CSV.replace('\n', "\r\n"));
    let draft = preview(&crlf, 0).unwrap();
    let saved = vault
        .apply_account_import_v1(draft.token, vec![0], generation)
        .unwrap();
    assert_eq!(saved.cards.len(), 1);
    let card = vault
        .card_v1(saved.cards[0].id.clone(), generation)
        .unwrap();
    let bindings = vault
        .bindings_v1(saved.cards[0].id.clone(), saved.revision, generation)
        .unwrap();
    assert_eq!(bindings.len(), 1);
    assert!(
        bindings[0].kind == ResourceKindV1::WebApp && bindings[0].method == BindingMethodV1::Web
    );
    assert_eq!(bindings[0].target, "https://example.invalid/login");
    assert_eq!(bindings[0].fields, ["login", "password"]);

    assert_eq!(
        card.fields
            .iter()
            .find(|f| f.id == FieldIdV1::Password)
            .unwrap()
            .value,
        "  sample,test  "
    );
    assert_eq!(card.description, "line one\r\nline two");
    let duplicate = preview(CSV, saved.revision).unwrap();
    assert!(duplicate.rows[0].duplicate);
    let state = vault
        .apply_account_import_v1(duplicate.token, vec![], generation)
        .unwrap();
    assert_eq!(state.revision, saved.revision);
    let chosen = preview(CSV, state.revision).unwrap();
    let copy = vault
        .apply_account_import_v1(chosen.token, vec![0], generation)
        .unwrap();
    assert_eq!(copy.cards.len(), 2);
    assert_ne!(copy.cards[0].id, copy.cards[1].id);
    let malformed = "Title,URL,Username,Password\nExample,,u,\"unfinished";
    assert!(preview(malformed, copy.revision).is_err());
    assert_eq!(
        vault.content_v2(generation).unwrap().revision,
        copy.revision
    );
    let pending = preview(CSV, copy.revision).unwrap();
    vault.lock().unwrap();
    assert!(
        vault
            .apply_account_import_v1(pending.token, vec![0], generation)
            .is_err()
    );
}
