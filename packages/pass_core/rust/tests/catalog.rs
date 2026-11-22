use want_pass_vault::api::{
    AttachmentInputV1, BindingMethodV1, CardInputV1, CardTypeV1, CardValueV1, CustomCardInputV1,
    CustomFieldKindV1, CustomValueInputV1, FieldIdV1, ResourceBindingV1, ResourceKindV1,
    ServiceDefinitionV1, TemplateFieldV1, Vault, VaultFailure,
};

fn fixture() -> (tempfile::TempDir, Vault) {
    let dir = tempfile::tempdir().unwrap();
    let vault = Vault::open(dir.path().join("vault").to_str().unwrap().into()).unwrap();
    let password = "Fixture catalog passphrase 2026!";
    let kit = vault
        .prepare_creation_v3(password.into(), vault.generation())
        .unwrap();
    vault
        .confirm_v3(
            kit.positions
                .iter()
                .map(|p| kit.words[*p as usize].clone())
                .collect(),
            password.into(),
            String::new(),
            String::new(),
            kit.revision,
        )
        .unwrap();
    (dir, vault)
}
fn field(id: &str, name: &str, kind: CustomFieldKindV1, required: bool) -> TemplateFieldV1 {
    TemplateFieldV1 {
        id: id.into(),
        label: name.into(),
        kind,
        required,
    }
}
fn value(id: &str, text: &str) -> CustomValueInputV1 {
    CustomValueInputV1 {
        field_id: id.into(),
        value: text.into(),
        file: None,
        keep_file: false,
    }
}
fn custom(
    id: Option<&str>,
    template: &str,
    version: u32,
    accept: bool,
    values: Vec<CustomValueInputV1>,
) -> CustomCardInputV1 {
    CustomCardInputV1 {
        id: id.map(str::to_string),
        name: "Example".into(),
        description: "Fixture".into(),
        service: "github".into(),
        environment: None,
        group_ids: vec![],
        template_id: template.into(),
        template_version: version,
        accept_template_update: accept,
        values,
    }
}
#[test]
fn version_update_requires_consent_and_preserves_previous_fields_and_file() {
    let (dir, vault) = fixture();
    let g = vault.generation();
    let s = vault
        .save_template_v1(
            None,
            "Example".into(),
            vec![
                field("", "URL", CustomFieldKindV1::Url, true),
                field("", "File", CustomFieldKindV1::File, true),
            ],
            0,
            g,
        )
        .unwrap();
    let t = s.templates[0].id.clone();
    let url = s.templates[0].versions[0].fields[0].id.clone();
    let file = s.templates[0].versions[0].fields[1].id.clone();
    let s = vault
        .save_custom_card_v1(
            custom(
                None,
                &t,
                1,
                false,
                vec![
                    value(&url, "https://example.invalid"),
                    CustomValueInputV1 {
                        file: Some(AttachmentInputV1 {
                            name: "fixture.dat".into(),
                            bytes: vec![1, 2, 3],
                        }),
                        ..value(&file, "")
                    },
                ],
            ),
            s.revision,
            g,
        )
        .unwrap();
    let card = s.cards[0].id.clone();
    let s = vault
        .save_template_v1(
            Some(t.clone()),
            "Updated".into(),
            vec![field(&url, "URL", CustomFieldKindV1::Url, true)],
            s.revision,
            g,
        )
        .unwrap();
    assert_eq!(s.cards[0].template_version, 1);
    assert!(matches!(
        vault.save_custom_card_v1(
            custom(
                Some(&card),
                &t,
                2,
                false,
                vec![value(&url, "https://example.invalid")]
            ),
            s.revision,
            g
        ),
        Err(VaultFailure::Confirmation)
    ));
    let s = vault
        .save_custom_card_v1(
            custom(
                Some(&card),
                &t,
                2,
                true,
                vec![value(&url, "https://new.example.invalid")],
            ),
            s.revision,
            g,
        )
        .unwrap();
    assert_eq!(
        vault
            .custom_field_value_v1(card.clone(), url.clone(), true, s.revision, g)
            .unwrap(),
        "https://new.example.invalid"
    );
    let history = vault.history_v1(Some(card.clone()), s.revision, g).unwrap();
    let old = vault
        .historical_card_v1(history[0].id.clone(), s.revision, g)
        .unwrap();
    assert_eq!(old.custom_values.len(), 2);
    assert_eq!(old.custom_values[1].file.as_ref().unwrap().size, 3);
    let s = vault
        .restore_history_v1(history[0].id.clone(), s.revision, g)
        .unwrap();
    assert_eq!(s.cards[0].template_version, 1);
    let path = dir.path().join("export.dat");
    vault
        .export_custom_file_v1(
            card.clone(),
            file,
            path.to_str().unwrap().into(),
            s.revision,
            g,
        )
        .unwrap();
    assert_eq!(std::fs::read(path).unwrap(), [1, 2, 3]);
    assert!(matches!(
        vault.clear_history_v1(Some(card.clone()), false, s.revision, g),
        Err(VaultFailure::Confirmation)
    ));
    let s = vault
        .clear_history_v1(Some(card.clone()), true, s.revision, g)
        .unwrap();
    assert!(
        vault
            .history_v1(Some(card), s.revision, g)
            .unwrap()
            .is_empty()
    );
}
#[test]
fn bindings_validate_resource_method_and_field_and_keep_multiple_targets() {
    let (_dir, vault) = fixture();
    let g = vault.generation();
    let s = vault.save_card_v1(account("github"), 0, g).unwrap();
    let card = s.cards[0].id.clone();
    let binding = |target: &str, method, fields: Vec<&str>| ResourceBindingV1 {
        id: String::new(),
        kind: ResourceKindV1::WebApp,
        target: target.into(),
        method,
        fields: fields.into_iter().map(str::to_string).collect(),
    };
    assert!(
        vault
            .save_bindings_v1(
                card.clone(),
                vec![binding(
                    "https://example.invalid",
                    BindingMethodV1::Ssh,
                    vec!["password"]
                )],
                s.revision,
                g
            )
            .is_err()
    );
    assert!(
        vault
            .save_bindings_v1(
                card.clone(),
                vec![binding(
                    "https://example.invalid",
                    BindingMethodV1::Web,
                    vec!["absent"]
                )],
                s.revision,
                g
            )
            .is_err()
    );
    let s = vault
        .save_bindings_v1(
            card.clone(),
            vec![
                binding(
                    "https://EXAMPLE.invalid:443",
                    BindingMethodV1::Web,
                    vec!["login", "password"],
                ),
                binding(
                    "https://example.invalid/another",
                    BindingMethodV1::Mtls,
                    vec!["password"],
                ),
            ],
            s.revision,
            g,
        )
        .unwrap();
    let bindings = vault.bindings_v1(card.clone(), s.revision, g).unwrap();
    assert_eq!(bindings.len(), 2);
    assert_eq!(bindings[0].target, "https://example.invalid/");
    assert_ne!(bindings[0].id, bindings[1].id);
    let s = vault.delete_card_v1(card.clone(), s.revision, g).unwrap();
    assert!(s.cards.is_empty());
    let history = vault.history_v1(None, s.revision, g).unwrap();
    let s = vault
        .restore_history_v1(history[0].id.clone(), s.revision, g)
        .unwrap();
    assert_eq!(vault.bindings_v1(card, s.revision, g).unwrap().len(), 2);
}

#[test]
fn quick_copy_uses_its_own_card_scope_and_returns_only_a_current_totp_code() {
    use std::time::{SystemTime, UNIX_EPOCH};
    use totp_rs::{Builder, Secret};
    use want_pass_vault::api::OperationV1;

    let (_dir, vault) = fixture();
    let g = vault.generation();
    let mut note = account("github");
    note.card_type = CardTypeV1::SecureNote;
    note.fields = vec![CardValueV1 {
        id: FieldIdV1::Value,
        value: "fixture note".into(),
    }];
    let saved = vault.save_card_v1(note, 0, g).unwrap();
    let id = saved.cards[0].id.clone();
    assert_eq!(
        vault.copy_account_v1(id.clone(), g),
        Err(VaultFailure::Unsupported)
    );
    assert_eq!(
        vault
            .copy_quick_card_v1(id.clone(), saved.revision, g)
            .unwrap(),
        "value: fixture note"
    );

    let mut otp = account("github");
    otp.card_type = CardTypeV1::Totp;
    otp.fields = vec![CardValueV1 {
        id: FieldIdV1::TotpSeed,
        value: "GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ".into(),
    }];
    let with_otp = vault.save_card_v1(otp, saved.revision, g).unwrap();
    let otp_id = with_otp.cards[1].id.clone();
    assert_eq!(
        vault.copy_quick_card_v1(id.clone(), saved.revision, g),
        Err(VaultFailure::Stale)
    );
    let current = vault
        .copy_quick_card_v1(otp_id.clone(), with_otp.revision, g)
        .unwrap();
    assert!(current.len() == 6 && current.bytes().all(|c| c.is_ascii_digit()));

    let seed = vault.begin_external_totp_v1(g).unwrap();
    let clock = Builder::new()
        .with_secret(Secret::try_from_base32(&seed).unwrap())
        .with_digits(6)
        .with_step_duration(30)
        .build()
        .unwrap();
    let now = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap()
        .as_secs();
    vault
        .enroll_external_totp_v1(
            clock.generate(now - 30).to_string(),
            vec![OperationV1::Copy],
            g,
        )
        .unwrap();
    let g = vault.generation();
    let rev = vault.content_v2(g).unwrap().revision;
    assert_eq!(
        vault.copy_quick_card_v1(id.clone(), rev, g),
        Err(VaultFailure::Confirmation)
    );
    vault
        .authorize_operation_v1(
            OperationV1::Copy,
            format!("{id}:quick-all"),
            clock.generate(now).to_string(),
            g,
        )
        .unwrap();
    assert_eq!(
        vault.copy_quick_card_v1(otp_id, rev, g),
        Err(VaultFailure::Confirmation)
    );
    assert_eq!(
        vault.copy_account_v1(id.clone(), g),
        Err(VaultFailure::Confirmation)
    );
    assert_eq!(
        vault.copy_quick_card_v1(id.clone(), rev, g).unwrap(),
        "value: fixture note"
    );
    assert_eq!(
        vault.copy_quick_card_v1(id, rev, g),
        Err(VaultFailure::Confirmation)
    );
}

#[test]
fn restoring_deleted_hotp_keeps_the_last_issued_counter() {
    let (_dir, vault) = fixture();
    let generation = vault.generation();
    let mut input = account("github");
    input.card_type = CardTypeV1::Hotp;
    input.fields = vec![
        CardValueV1 {
            id: FieldIdV1::HotpSeed,
            value: "GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ".into(),
        },
        CardValueV1 {
            id: FieldIdV1::Counter,
            value: "0".into(),
        },
    ];
    let saved = vault.save_card_v1(input, 0, generation).unwrap();
    let card_id = saved.cards[0].id.clone();
    let first = vault
        .next_hotp_v1(card_id.clone(), saved.revision, generation)
        .unwrap();
    let retained = vault
        .history_v1(Some(card_id.clone()), first.snapshot.revision, generation)
        .unwrap();
    let second = vault
        .next_hotp_v1(card_id.clone(), first.snapshot.revision, generation)
        .unwrap();
    let deleted = vault
        .delete_card_v1(card_id.clone(), second.snapshot.revision, generation)
        .unwrap();
    let restored = vault
        .restore_history_v1(retained[0].id.clone(), deleted.revision, generation)
        .unwrap();
    let next = vault
        .next_hotp_v1(card_id, restored.revision, generation)
        .unwrap();
    assert_eq!(first.code, "755224");
    assert_eq!(second.code, "287082");
    assert_eq!(next.code, "359152");
}

fn account(service: &str) -> CardInputV1 {
    CardInputV1 {
        id: None,
        name: "Example".into(),
        description: String::new(),
        service: service.into(),
        environment: None,
        group_ids: vec![],
        card_type: CardTypeV1::Account,
        fields: vec![
            CardValueV1 {
                id: FieldIdV1::Login,
                value: "test@example.invalid".into(),
            },
            CardValueV1 {
                id: FieldIdV1::Password,
                value: "fixture".into(),
            },
        ],
        attachment: None,
    }
}
#[test]
fn custom_service_reassignment_preserves_credentials_and_revision() {
    let (_dir, vault) = fixture();
    let g = vault.generation();
    let s = vault
        .save_service_v1(
            ServiceDefinitionV1 {
                id: String::new(),
                name: "Internal".into(),
                description: "Local".into(),
                icon: "key".into(),
                logo: vec![],
                archived: false,
            },
            0,
            g,
        )
        .unwrap();
    let service = s.services[0].id.clone();
    let s = vault
        .save_card_v1(account(&service), s.revision, g)
        .unwrap();
    assert!(matches!(
        vault.remove_service_v1(service.clone(), None, false, s.revision, g),
        Err(VaultFailure::Confirmation)
    ));
    let s = vault
        .remove_service_v1(service.clone(), Some("github".into()), false, s.revision, g)
        .unwrap();
    let current = vault.card_v1(s.cards[0].id.clone(), g).unwrap();
    assert_eq!(current.summary.service, "github");
    assert_eq!(current.fields[1].value, "fixture");
    let history = vault
        .history_v1(Some(current.summary.id), s.revision, g)
        .unwrap();
    assert_eq!(history.len(), 1);
    assert_eq!(history[0].service, service);
}
