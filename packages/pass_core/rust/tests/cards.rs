use want_pass_vault::api::{CardInputV1, CardTypeV1, CardValueV1, FieldIdV1, Vault, VaultFailure};
const PASSWORD: &str = "Synthetic cards password 2026!";
fn create() -> (tempfile::TempDir, Vault) {
    let directory = tempfile::tempdir().unwrap();
    let vault = Vault::open(directory.path().join("vault").to_str().unwrap().into()).unwrap();
    let challenge = vault
        .prepare_creation_v3(PASSWORD.into(), vault.generation())
        .unwrap();
    vault
        .confirm_v3(
            challenge
                .positions
                .iter()
                .map(|p| challenge.words[*p as usize].clone())
                .collect(),
            PASSWORD.into(),
            String::new(),
            String::new(),
            challenge.revision,
        )
        .unwrap();
    (directory, vault)
}
fn account() -> CardInputV1 {
    CardInputV1 {
        id: None,
        name: "Synthetic account".into(),
        description: "Fixture".into(),
        service: "github".into(),
        environment: None,
        group_ids: vec![],
        card_type: CardTypeV1::Account,
        fields: vec![
            CardValueV1 {
                id: FieldIdV1::Login,
                value: "fixture@example.invalid".into(),
            },
            CardValueV1 {
                id: FieldIdV1::Password,
                value: " exact\npassword ".into(),
            },
        ],
        attachment: None,
    }
}
#[test]
fn service_accounts_remain_distinct_and_reopen_exactly() {
    let (_directory, vault) = create();
    let one = vault
        .save_card_v1(account(), 0, vault.generation())
        .unwrap();
    let two = vault
        .save_card_v1(account(), one.revision, vault.generation())
        .unwrap();
    assert_ne!(two.cards[0].id, two.cards[1].id);
    vault.lock().unwrap();
    vault
        .unlock_v3(PASSWORD.into(), vault.generation())
        .unwrap();
    let saved = vault
        .card_v1(two.cards[0].id.clone(), vault.generation())
        .unwrap();
    assert_eq!(saved.summary.service, "github");
    assert_eq!(
        saved
            .fields
            .iter()
            .find(|v| v.id == FieldIdV1::Password)
            .unwrap()
            .value,
        " exact\npassword "
    );
}
#[test]
fn missing_service_and_stale_writes_preserve_current_data() {
    let (_directory, vault) = create();
    let saved = vault
        .save_card_v1(account(), 0, vault.generation())
        .unwrap();
    let mut invalid = account();
    invalid.service.clear();
    assert!(matches!(
        vault.save_card_v1(invalid, saved.revision, vault.generation()),
        Err(VaultFailure::Unsupported)
    ));
    assert!(matches!(
        vault.save_card_v1(account(), 0, vault.generation()),
        Err(VaultFailure::Stale)
    ));
    assert_eq!(vault.content_v2(vault.generation()).unwrap().cards.len(), 1);
}
#[test]
fn totp_matches_rfc6238_and_copy_all_excludes_recovery_material() {
    use want_pass_vault::api::totp_code_v1;
    assert_eq!(
        totp_code_v1(
            "GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ".into(),
            "SHA1".into(),
            8,
            30,
            59
        )
        .unwrap()
        .code,
        "94287082"
    );
    let (_directory, vault) = create();
    let mut input = account();
    input.fields.extend([
        CardValueV1 {
            id: FieldIdV1::TotpSeed,
            value:
                "otpauth://totp/Fixture?secret=GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ&issuer=Synthetic"
                    .into(),
        },
        CardValueV1 {
            id: FieldIdV1::RecoveryCodes,
            value: "synthetic-recovery-code".into(),
        },
        CardValueV1 {
            id: FieldIdV1::ReserveLogins,
            value: "reserve@example.invalid".into(),
        },
    ]);
    let saved = vault.save_card_v1(input, 0, vault.generation()).unwrap();
    let id = saved.cards[0].id.clone();
    let current = vault
        .current_totp_v1(id.clone(), vault.generation())
        .unwrap();
    assert_eq!(current.code.len(), 6);
    let copied = vault.copy_account_v1(id, vault.generation()).unwrap();
    assert!(copied.contains("fixture@example.invalid"));
    assert!(!copied.contains("synthetic-recovery-code"));
    assert!(!copied.contains("reserve@example.invalid"));
    assert!(!copied.contains("GEZDGNBV"));
}
#[test]
fn developer_cards_and_files_reopen_without_losing_bytes() {
    use want_pass_vault::api::AttachmentInputV1;
    let (directory, vault) = create();
    let mut input = account();
    input.card_type = CardTypeV1::SecureNote;
    input.fields = vec![CardValueV1 {
        id: FieldIdV1::Value,
        value: " exact\nsynthetic note ".into(),
    }];
    let one = vault.save_card_v1(input, 0, vault.generation()).unwrap();
    let mut file = account();
    file.card_type = CardTypeV1::File;
    file.fields.clear();
    file.attachment = Some(AttachmentInputV1 {
        name: "fixture.bin".into(),
        bytes: vec![0, 1, 2, 255],
    });
    let saved = vault
        .save_card_v1(file, one.revision, vault.generation())
        .unwrap();
    let id = saved.cards[1].id.clone();
    vault.lock().unwrap();
    vault
        .unlock_v3(PASSWORD.into(), vault.generation())
        .unwrap();
    let record = vault.card_v1(id.clone(), vault.generation()).unwrap();
    assert_eq!(record.attachment.unwrap().size, 4);
    let path = directory.path().join("export.bin");
    vault
        .export_attachment_v1(
            id,
            path.to_str().unwrap().into(),
            saved.revision,
            vault.generation(),
        )
        .unwrap();
    assert_eq!(std::fs::read(path).unwrap(), vec![0, 1, 2, 255]);
    assert!(
        vault
            .copy_account_v1(saved.cards[0].id.clone(), vault.generation())
            .is_err()
    );
}
#[test]
fn every_developer_preset_saves_and_reopens_with_format_validation() {
    use pgp::composed::{KeyType, SecretKeyParamsBuilder};
    let secret = SecretKeyParamsBuilder::default()
        .key_type(KeyType::Ed25519Legacy)
        .can_sign(true)
        .can_certify(true)
        .primary_user_id("Synthetic fixture <fixture@example.invalid>".into())
        .build()
        .unwrap()
        .generate(rand::thread_rng())
        .unwrap();
    let private = secret.to_armored_string(None.into()).unwrap();
    let public = secret
        .to_public_key()
        .to_armored_string(None.into())
        .unwrap();
    let value = |id, value: &str| CardValueV1 {
        id,
        value: value.into(),
    };
    let simple = |v: &str| vec![value(FieldIdV1::Value, v)];
    let cases = vec![
        (CardTypeV1::Pat, simple("synthetic-pat")),
        (CardTypeV1::SecretKey, simple("synthetic-key")),
        (CardTypeV1::Passphrase, simple(" synthetic phrase ")),
        (
            CardTypeV1::RecoveryCodes,
            vec![value(
                FieldIdV1::RecoveryCodes,
                "synthetic-one\nsynthetic-two",
            )],
        ),
        (
            CardTypeV1::RecoveryUrl,
            simple("https://example.invalid/recover?code=synthetic"),
        ),
        (
            CardTypeV1::SecretQa,
            vec![
                value(FieldIdV1::Question, "Synthetic question"),
                value(FieldIdV1::Answer, "Synthetic answer"),
            ],
        ),
        (
            CardTypeV1::Vless,
            simple("vless://01234567-89ab-cdef-0123-456789abcdef@example.invalid:443?security=tls"),
        ),
        (
            CardTypeV1::WireGuard,
            simple(
                "[Interface]\nPrivateKey = AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=\nAddress = 10.0.0.2/32\n[Peer]\nPublicKey = AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=\nAllowedIPs = 0.0.0.0/0\nEndpoint = example.invalid:51820",
            ),
        ),
        (
            CardTypeV1::Rsa,
            vec![
                value(
                    FieldIdV1::PublicKey,
                    include_str!("fixtures/synthetic_rsa.pub"),
                ),
                value(
                    FieldIdV1::PrivateKey,
                    include_str!("fixtures/synthetic_rsa"),
                ),
            ],
        ),
        (
            CardTypeV1::Ed25519,
            vec![
                value(
                    FieldIdV1::PublicKey,
                    include_str!("fixtures/synthetic_ed25519.pub"),
                ),
                value(
                    FieldIdV1::PrivateKey,
                    include_str!("fixtures/synthetic_ed25519"),
                ),
            ],
        ),
        (
            CardTypeV1::Gpg,
            vec![
                value(FieldIdV1::PublicKey, &public),
                value(FieldIdV1::PrivateKey, &private),
            ],
        ),
        (
            CardTypeV1::Certificate,
            vec![
                value(
                    FieldIdV1::Certificate,
                    include_str!("fixtures/synthetic_certificate.pem"),
                ),
                value(
                    FieldIdV1::PrivateKey,
                    include_str!("fixtures/synthetic_certificate_key.pem"),
                ),
            ],
        ),
        (
            CardTypeV1::OAuth,
            vec![
                value(FieldIdV1::ClientId, "synthetic-client"),
                value(FieldIdV1::ClientSecret, "synthetic-client-secret"),
            ],
        ),
        (
            CardTypeV1::Dsn,
            simple("postgresql://fixture:synthetic@example.invalid:5432/fixture"),
        ),
        (
            CardTypeV1::Kubeconfig,
            simple(
                "apiVersion: v1\nkind: Config\nclusters:\n- name: fixture\n  cluster:\n    server: https://example.invalid\ncontexts:\n- name: fixture\n  context:\n    cluster: fixture\n    user: fixture\nusers:\n- name: fixture\n  user:\n    token: synthetic\ncurrent-context: fixture",
            ),
        ),
        (CardTypeV1::WebhookSecret, simple("synthetic-signing-key")),
        (CardTypeV1::SecureNote, simple(" synthetic\nnote ")),
    ];
    let (_directory, vault) = create();
    let mut revision = 0;
    let mut expected = vec![];
    for (kind, fields) in cases {
        let mut input = account();
        input.card_type = kind;
        input.fields = fields.clone();
        let saved = vault
            .save_card_v1(input, revision, vault.generation())
            .unwrap();
        revision = saved.revision;
        expected.push((saved.cards.last().unwrap().id.clone(), fields));
    }
    vault.lock().unwrap();
    vault
        .unlock_v3(PASSWORD.into(), vault.generation())
        .unwrap();
    for (id, fields) in expected {
        let card = vault.card_v1(id, vault.generation()).unwrap();
        assert_eq!(card.fields.len(), fields.len());
        for f in fields {
            assert_eq!(
                card.fields.iter().find(|v| v.id == f.id).unwrap().value,
                f.value
            );
        }
    }
    for kind in [
        CardTypeV1::Rsa,
        CardTypeV1::Ed25519,
        CardTypeV1::Certificate,
        CardTypeV1::Gpg,
        CardTypeV1::Kubeconfig,
        CardTypeV1::WireGuard,
        CardTypeV1::Vless,
        CardTypeV1::Dsn,
        CardTypeV1::RecoveryUrl,
    ] {
        let mut input = account();
        input.card_type = kind;
        input.fields = match kind {
            CardTypeV1::Rsa | CardTypeV1::Ed25519 | CardTypeV1::Gpg => vec![
                value(FieldIdV1::PublicKey, "invalid synthetic public key"),
                value(FieldIdV1::PrivateKey, "invalid synthetic private key"),
            ],
            CardTypeV1::Certificate => vec![
                value(FieldIdV1::Certificate, "invalid synthetic certificate"),
                value(FieldIdV1::PrivateKey, "invalid synthetic private key"),
            ],
            _ => simple("invalid synthetic format"),
        };
        assert!(
            vault
                .save_card_v1(input, revision, vault.generation())
                .is_err()
        );
    }
    assert_eq!(
        vault.content_v2(vault.generation()).unwrap().revision,
        revision
    );
}
#[test]
fn malformed_private_key_and_kubeconfig_references_are_rejected() {
    use base64::{Engine, engine::general_purpose::STANDARD};
    let (_directory, vault) = create();
    let mut input = account();
    input.card_type = CardTypeV1::Certificate;
    let invalid_der = [
        0x30, 0x16, 0x02, 0x01, 0, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d,
        0x01, 0x01, 0x01, 0x05, 0, 0x04, 0x02, 0, 0,
    ];
    input.fields = vec![
        CardValueV1 {
            id: FieldIdV1::Certificate,
            value: include_str!("fixtures/synthetic_certificate.pem").into(),
        },
        CardValueV1 {
            id: FieldIdV1::PrivateKey,
            value: format!(
                "-----BEGIN PRIVATE KEY-----\n{}\n-----END PRIVATE KEY-----\n",
                STANDARD.encode(invalid_der)
            ),
        },
    ];
    assert!(vault.save_card_v1(input, 0, vault.generation()).is_err());
    let mut input = account();
    input.card_type = CardTypeV1::Kubeconfig;
    input.fields=vec![CardValueV1{id:FieldIdV1::Value,value:"apiVersion: v1\nkind: Config\nclusters:\n- name: present\n  cluster:\n    server: https://example.invalid\ncontexts:\n- name: fixture\n  context:\n    cluster: absent\n    user: fixture\nusers:\n- name: fixture\n  user: {}\n".into()}];
    assert!(vault.save_card_v1(input, 0, vault.generation()).is_err());
}
#[test]
fn all_rfc6238_vectors_and_invalid_parameters() {
    use totp_rs::Secret;
    use want_pass_vault::api::totp_code_v1;
    let times = [
        59,
        1111111109,
        1111111111,
        1234567890,
        2000000000,
        20000000000,
    ];
    let rows = [
        (
            "SHA1",
            "12345678901234567890",
            [
                "94287082", "07081804", "14050471", "89005924", "69279037", "65353130",
            ],
        ),
        (
            "SHA256",
            "12345678901234567890123456789012",
            [
                "46119246", "68084774", "67062674", "91819424", "90698825", "77737706",
            ],
        ),
        (
            "SHA512",
            "1234567890123456789012345678901234567890123456789012345678901234",
            [
                "90693936", "25091201", "99943326", "93441116", "38618901", "47863826",
            ],
        ),
    ];
    for (algorithm, secret, expected) in rows {
        for (time, code) in times.into_iter().zip(expected) {
            let result = totp_code_v1(
                Secret::from(secret.as_bytes()).to_base32(),
                algorithm.into(),
                8,
                30,
                time,
            )
            .unwrap();
            assert_eq!(result.code, code);
            assert_eq!(result.valid_until, time - time % 30 + 30);
        }
    }
    for (algorithm, digits, period) in [
        ("SHA1", 5, 30),
        ("MD5", 6, 30),
        ("SHA1", 6, 0),
        ("SHA1", 6, 86401),
    ] {
        assert!(
            totp_code_v1(
                "GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ".into(),
                algorithm.into(),
                digits,
                period,
                59
            )
            .is_err()
        );
    }
    assert!(totp_code_v1("not-base32!".into(), "SHA1".into(), 6, 30, 59).is_err());
}
#[test]
fn file_size_and_vault_capacity_preserve_the_previous_document() {
    use std::os::unix::fs::PermissionsExt;
    use want_pass_vault::api::AttachmentInputV1;
    let (directory, vault) = create();
    let file = |bytes: Vec<u8>| {
        let mut input = account();
        input.card_type = CardTypeV1::File;
        input.fields.clear();
        input.attachment = Some(AttachmentInputV1 {
            name: "synthetic.bin".into(),
            bytes,
        });
        input
    };
    assert!(
        vault
            .save_card_v1(file(vec![7; 20 * 1024 * 1024 + 1]), 0, vault.generation())
            .is_err()
    );
    assert_eq!(vault.content_v2(vault.generation()).unwrap().revision, 0);
    let payload = vec![7; 20 * 1024 * 1024];
    let one = vault
        .save_card_v1(file(payload.clone()), 0, vault.generation())
        .unwrap();
    let output = directory.path().join("synthetic-export.bin");
    vault
        .export_attachment_v1(
            one.cards[0].id.clone(),
            output.to_str().unwrap().into(),
            one.revision,
            vault.generation(),
        )
        .unwrap();
    assert_eq!(std::fs::read(&output).unwrap(), payload);
    assert_eq!(
        std::fs::metadata(&output).unwrap().permissions().mode() & 0o777,
        0o600
    );
    let two = vault
        .save_card_v1(file(payload.clone()), one.revision, vault.generation())
        .unwrap();
    assert!(
        vault
            .save_card_v1(file(payload), two.revision, vault.generation())
            .is_err()
    );
    let current = vault.content_v2(vault.generation()).unwrap();
    assert_eq!(current.revision, two.revision);
    assert_eq!(current.cards.len(), 2);
}
#[test]
fn pem_key_pairs_must_match_and_protected_containers_remain_explicit() {
    let (_directory, vault) = create();
    let mut input = account();
    input.card_type = CardTypeV1::Rsa;
    input.fields = vec![
        CardValueV1 {
            id: FieldIdV1::PublicKey,
            value: include_str!("fixtures/synthetic_rsa_public.pem").into(),
        },
        CardValueV1 {
            id: FieldIdV1::PrivateKey,
            value: include_str!("fixtures/synthetic_certificate_key.pem").into(),
        },
    ];
    assert!(vault.save_card_v1(input, 0, vault.generation()).is_err());
    let mut input = account();
    input.card_type = CardTypeV1::Ed25519;
    input.fields = vec![
        CardValueV1 {
            id: FieldIdV1::PublicKey,
            value: include_str!("fixtures/synthetic_ed25519.pub").into(),
        },
        CardValueV1 {
            id: FieldIdV1::PrivateKey,
            value: include_str!("fixtures/synthetic_protected_ed25519").into(),
        },
    ];
    let one = vault.save_card_v1(input, 0, vault.generation()).unwrap();
    assert!(
        vault
            .card_v1(one.cards[0].id.clone(), vault.generation())
            .unwrap()
            .protected_container
    );
    let mut input = account();
    input.card_type = CardTypeV1::Certificate;
    input.fields = vec![
        CardValueV1 {
            id: FieldIdV1::Certificate,
            value: include_str!("fixtures/synthetic_certificate.pem").into(),
        },
        CardValueV1 {
            id: FieldIdV1::PrivateKey,
            value: include_str!("fixtures/synthetic_protected_pkcs8.pem").into(),
        },
    ];
    let two = vault
        .save_card_v1(input, one.revision, vault.generation())
        .unwrap();
    assert!(
        vault
            .card_v1(two.cards[1].id.clone(), vault.generation())
            .unwrap()
            .protected_container
    );
}
