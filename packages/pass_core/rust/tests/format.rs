use want_pass_vault::format;

const PASSWORD: &str = "Synthetic format password 2026";

#[test]
fn complete_user_payload_is_authenticated_encrypted_and_recoverable() {
    let document = br#"{"name":"synthetic-account","groups":["synthetic-group"],"environment":"production","history":["old-synthetic-value"],"attachment":"synthetic-file-content"}"#;
    let prepared = format::prepare(PASSWORD, document, None).unwrap();
    for plaintext in [
        "synthetic-account",
        "synthetic-group",
        "production",
        "old-synthetic-value",
        "synthetic-file-content",
        PASSWORD,
    ] {
        assert!(
            !prepared
                .bytes
                .windows(plaintext.len())
                .any(|value| value == plaintext.as_bytes())
        );
    }
    let by_password = format::open_password(&prepared.bytes, PASSWORD).unwrap();
    assert_eq!(by_password.document.as_slice(), document);
    let phrase = format::words(prepared.entropy.as_ref()).unwrap().join(" ");
    let by_recovery = format::open_recovery(&prepared.bytes, &phrase).unwrap();
    assert_eq!(by_recovery.document.as_slice(), document);
    let recovered = format::prepare(
        "Another synthetic password 2026",
        &by_recovery.document,
        Some(by_recovery.id),
    )
    .unwrap();
    assert_ne!(prepared.opened.key.as_ref(), recovered.opened.key.as_ref());
    assert_ne!(prepared.entropy.as_ref(), recovered.entropy.as_ref());
    assert_eq!(
        format::open_password(&recovered.bytes, "Another synthetic password 2026")
            .unwrap()
            .document
            .as_slice(),
        document
    );
    assert!(format::open_recovery(&recovered.bytes, &phrase).is_err());
}

#[test]
fn bip39_256_bit_published_zero_entropy_vector() {
    // https://github.com/trezor/python-mnemonic/blob/master/vectors.json
    let words = format::words(&[0; 32]).unwrap();
    assert_eq!(words.len(), 24);
    assert_eq!(&words[..23], vec!["abandon"; 23]);
    assert_eq!(words[23], "art");
}

#[test]
fn argon2id_rfc9106_vector() {
    // RFC 9106 section 5.3.
    use argon2::{Algorithm, Argon2, AssociatedData, ParamsBuilder, Version};
    let params = ParamsBuilder::new()
        .m_cost(32)
        .t_cost(3)
        .p_cost(4)
        .data(AssociatedData::new(&[4; 12]).unwrap())
        .build()
        .unwrap();
    let mut output = [0; 32];
    Argon2::new_with_secret(&[3; 8], Algorithm::Argon2id, Version::V0x13, params)
        .unwrap()
        .hash_password_into(&[1; 32], &[2; 16], &mut output)
        .unwrap();
    assert_eq!(
        output,
        [
            0x0d, 0x64, 0x0d, 0xf5, 0x8d, 0x78, 0x76, 0x6c, 0x08, 0xc0, 0x37, 0xa3, 0x4a, 0x8b,
            0x53, 0xc9, 0xd0, 0x1e, 0xf0, 0x45, 0x2d, 0x75, 0xb6, 0x5e, 0xb5, 0x25, 0x20, 0xe9,
            0x6b, 0x01, 0xe6, 0x59
        ]
    );
}

#[test]
fn hkdf_sha256_rfc5869_vector() {
    // RFC 5869 appendix A.1.
    let mut output = [0; 42];
    hkdf::Hkdf::<sha2::Sha256>::new(Some(&(0_u8..=12).collect::<Vec<_>>()), &[0x0b; 22])
        .expand(&(0xf0_u8..=0xf9).collect::<Vec<_>>(), &mut output)
        .unwrap();
    assert_eq!(
        output,
        [
            0x3c, 0xb2, 0x5f, 0x25, 0xfa, 0xac, 0xd5, 0x7a, 0x90, 0x43, 0x4f, 0x64, 0xd0, 0x36,
            0x2f, 0x2a, 0x2d, 0x2d, 0x0a, 0x90, 0xcf, 0x1a, 0x5a, 0x4c, 0x5d, 0xb0, 0x2d, 0x56,
            0xec, 0xc4, 0xc5, 0xbf, 0x34, 0x00, 0x72, 0x08, 0xd5, 0xb8, 0x87, 0x18, 0x58, 0x65
        ]
    );
}

#[test]
fn xchacha20_poly1305_published_aead_vector() {
    // draft-irtf-cfrg-xchacha-03 appendix A.1.
    use chacha20poly1305::{
        XChaCha20Poly1305, XNonce,
        aead::{Aead, KeyInit, Payload},
    };
    let key: Vec<u8> = (0x80..=0x9f).collect();
    let nonce = XNonce::from(std::array::from_fn(|i| 0x40 + i as u8));
    let aad = [
        0x50, 0x51, 0x52, 0x53, 0xc0, 0xc1, 0xc2, 0xc3, 0xc4, 0xc5, 0xc6, 0xc7,
    ];
    let plaintext = b"Ladies and Gentlemen of the class of '99: If I could offer you only one tip for the future, sunscreen would be it.";
    let ciphertext = XChaCha20Poly1305::new_from_slice(&key)
        .unwrap()
        .encrypt(
            &nonce,
            Payload {
                msg: plaintext,
                aad: &aad,
            },
        )
        .unwrap();
    let expected = "bd6d179d3e83d43b9576579493c0e939572a1700252bfaccbed2902c21396cbb731c7f1b0b4aa6440bf3a82f4eda7e39ae64c6708c54c216cb96b72e1213b4522f8c9ba40db5d945b11b69b982c1bb9e3f3fac2bc369488f76b2383565d3fff921f9664c97637da9768812f615c68b13b52ec0875924c1c7987947deafd8780acf49";
    let expected: Vec<u8> = expected
        .as_bytes()
        .chunks_exact(2)
        .map(|pair| u8::from_str_radix(std::str::from_utf8(pair).unwrap(), 16).unwrap())
        .collect();
    assert_eq!(ciphertext, expected);
}

#[test]
fn password_policy_counts_unicode_scalars_and_preserves_exact_bytes() {
    use want_pass_vault::api::VaultFailure;
    for invalid in ["a".repeat(14), "a".repeat(1025)] {
        assert!(matches!(
            format::prepare(&invalid, &[], None),
            Err(VaultFailure::InvalidPassword)
        ));
    }
    let password = "é".repeat(15);
    let prepared = format::prepare(&password, &[], None).unwrap();
    assert!(format::open_password(&prepared.bytes, &password).is_ok());
    assert!(matches!(
        format::open_password(&prepared.bytes, &"e\u{301}".repeat(15)),
        Err(VaultFailure::Credentials)
    ));
    let spaced = " synthetic exact spaces ";
    let prepared = format::prepare(spaced, &[], None).unwrap();
    assert!(matches!(
        format::open_password(&prepared.bytes, spaced.trim()),
        Err(VaultFailure::Credentials)
    ));
}
