use base64::{Engine, engine::general_purpose::STANDARD};
use serde_json::{Value, json};
use signature::{Signer, Verifier};
use ssh_key::{PrivateKey, PublicKey, Signature};
use want_pass_vault::api::{AccountImportSourceV1, LocalToolCommandV1 as C, Vault, VaultFailure};

fn vault() -> (tempfile::TempDir, Vault) {
    let dir = tempfile::tempdir().unwrap();
    let v = Vault::open(dir.path().join("synthetic").to_str().unwrap().into()).unwrap();
    let pass = "Synthetic vault example 2026!";
    let d = v.prepare_creation_v3(pass.into(), v.generation()).unwrap();
    v.confirm_v3(
        d.positions
            .iter()
            .map(|i| d.words[*i as usize].clone())
            .collect(),
        pass.into(),
        String::new(),
        String::new(),
        d.revision,
    )
    .unwrap();
    (dir, v)
}
fn local(v: &Vault, c: C, body: Value) -> Result<Value, VaultFailure> {
    let output = v.local_tools_v1(c, body.to_string(), v.generation())?;
    Ok(serde_json::from_str(&output).unwrap())
}
fn push(data: &mut Vec<u8>, field: &[u8]) {
    data.extend((field.len() as u32).to_be_bytes());
    data.extend(field);
}
#[test]
fn scoped_metadata_storage_revocation_and_session_boundaries() {
    let (_dir, v) = vault();
    let c = v
        .prepare_account_import_v1(
            AccountImportSourceV1::ApplePasswords,
            vec![include_str!("fixtures/apple-passwords-macos.csv").into()],
            0,
            v.generation(),
        )
        .unwrap();
    let saved = v
        .apply_account_import_v1(c.token, vec![0], v.generation())
        .unwrap();
    let bind = v
        .bindings_v1(saved.cards[0].id.clone(), saved.revision, v.generation())
        .unwrap()
        .remove(0);
    let scope = json!({"client":"wpass","action":"search","target":bind.id,"resource":bind.target,"environment":"unassigned","fields":["name","service"]});
    let search = json!({"scope":scope,"query":"Example"});
    assert!(local(&v, C::Request, search.clone()).is_err());
    for (key, val) in [
        ("client", json!("unknown")),
        ("action", json!("shell")),
        ("fields", json!(["password"])),
        ("resource", json!("https://unknown.invalid")),
        ("environment", json!("production")),
    ] {
        let mut wrong = scope.clone();
        wrong[key] = val;
        assert!(local(&v, C::Grant, wrong).is_err());
    }
    local(&v, C::Grant, scope.clone()).unwrap();
    let data = local(&v, C::Request, search.clone()).unwrap();
    assert_eq!(data, json!([{"name":"Example","service":"other"}]));
    let mut store = scope.clone();
    store["action"] = json!("store");
    store["fields"] = json!(["login", "password"]);
    let candidate =
        json!({"scope":store,"name":"Second","login":"test-user","password":"fixture-only"});
    assert!(local(&v, C::Request, candidate.clone()).is_err());
    local(&v, C::Grant, store).unwrap();
    assert_eq!(local(&v, C::Request, candidate).unwrap(), json!({}));
    assert_eq!(v.content_v2(v.generation()).unwrap().cards.len(), 2);
    let same_resource = local(&v, C::Request, json!({"scope":scope,"query":""})).unwrap();
    assert_eq!(same_resource, json!([{"name":"Example","service":"other"}]));
    assert_eq!(
        local(&v, C::Request, json!({"scope":scope,"query":"Second"})).unwrap(),
        json!([])
    );

    local(&v, C::Revoke, scope).unwrap();
    assert!(local(&v, C::Request, search.clone()).is_err());
    v.lock().unwrap();
    assert!(local(&v, C::Request, search).is_err());
}
#[test]
fn narrowing_binding_permissions_disables_profiles_and_new_bindings_enter_card_history() {
    let (_directory, v) = vault();
    let host = PrivateKey::from_openssh(include_str!("fixtures/synthetic_ed25519")).unwrap();
    let public = host.public_key().to_openssh().unwrap();
    let input = |alias: &str, host: &str, key: Option<&str>| json!({"alias":alias,"host":host,"user":"owner","port":22,"environment":"development","host_key":public,"key_id":key});
    let first = local(&v, C::Configure, input("one", "one.invalid", None)).unwrap();
    let state = v.content_v2(v.generation()).unwrap();
    let key = state.cards[0].id.clone();
    let second = local(&v, C::Configure, input("two", "two.invalid", Some(&key))).unwrap();
    let state = v.content_v2(v.generation()).unwrap();
    let history = v
        .history_v1(Some(key.clone()), state.revision, v.generation())
        .unwrap();
    assert_eq!(history.len(), 1);
    let old = v
        .historical_card_v1(history[0].id.clone(), state.revision, v.generation())
        .unwrap();
    assert_eq!(old.bindings.len(), 1);
    let dashboard = local(&v, C::Dashboard, json!({})).unwrap();
    let p = dashboard["profiles"]
        .as_array()
        .unwrap()
        .iter()
        .find(|p| p["id"] == second)
        .unwrap();
    local(&v, C::Grant, p["scope"].clone()).unwrap();
    assert!(local(&v, C::AgentIdentity, second.clone()).is_ok());
    let mut bindings = v
        .bindings_v1(key.clone(), state.revision, v.generation())
        .unwrap();
    let target = bindings
        .iter_mut()
        .find(|b| b.target.contains("two.invalid"))
        .unwrap();
    target.fields = vec!["public-key".into()];
    v.save_bindings_v1(key.clone(), bindings, state.revision, v.generation())
        .unwrap();
    assert!(local(&v, C::AgentIdentity, second.clone()).is_err());
    assert!(
        local(
            &v,
            C::AgentSign,
            json!({"profile":second,"binding":"","key":"","data":""})
        )
        .is_err()
    );
    assert!(local(&v, C::Configure, input("again", "two.invalid", Some(&key))).is_err());
    let shown = local(&v, C::Dashboard, json!({})).unwrap();
    assert_eq!(shown["profiles"].as_array().unwrap().len(), 1);
    assert_eq!(shown["profiles"][0]["id"], first);
    assert_eq!(shown["grants"], json!([]));
}

#[test]
fn ssh_signs_only_for_pinned_host_requested_user_and_unlocked_grant() {
    let (_dir, v) = vault();
    let host = PrivateKey::from_openssh(include_str!("fixtures/synthetic_ed25519")).unwrap();
    let public = host.public_key().to_openssh().unwrap();
    let profile = json!({"alias":"fixture","host":"example.invalid","user":"owner","port":22,"environment":"development","host_key":public});
    let id = local(&v, C::Configure, profile).unwrap();
    let dashboard = local(&v, C::Dashboard, json!({})).unwrap();
    let scoped = dashboard["profiles"][0]["scope"].clone();
    assert!(local(&v, C::AgentIdentity, id.clone()).is_err());
    local(&v, C::Grant, scoped.clone()).unwrap();
    let blob = STANDARD
        .decode(
            local(&v, C::AgentIdentity, id.clone())
                .unwrap()
                .as_str()
                .unwrap(),
        )
        .unwrap();
    let host_blob = host.public_key().to_bytes().unwrap();
    let session = b"synthetic-session-identifier-only";
    let proof: Signature = host.try_sign(session).unwrap();
    let mut binding = vec![];
    push(&mut binding, &host_blob);
    push(&mut binding, session);
    push(&mut binding, &Vec::try_from(proof).unwrap());
    binding.push(0);
    let signed_data = |user: &[u8]| {
        let mut data = vec![];
        push(&mut data, session);
        data.push(50);
        push(&mut data, user);
        push(&mut data, b"ssh-connection");
        push(&mut data, b"publickey-hostbound-v00@openssh.com");
        data.push(1);
        push(&mut data, b"ssh-ed25519");
        push(&mut data, &blob);
        push(&mut data, &host_blob);
        data
    };
    let args = |data: &[u8], b: &[u8]| json!({"profile":id,"binding":STANDARD.encode(b),"key":STANDARD.encode(&blob),"data":STANDARD.encode(data)});
    let good = signed_data(b"owner");
    let mut invalid = binding.clone();
    *invalid.last_mut().unwrap() = 1;
    assert!(local(&v, C::AgentSign, args(&good, &invalid)).is_err());
    assert!(local(&v, C::AgentSign, args(&signed_data(b"other"), &binding)).is_err());
    assert!(local(&v, C::AgentSign, args(b"arbitrary input", &binding)).is_err());
    let result = local(&v, C::AgentSign, args(&good, &binding)).unwrap();
    let bytes = STANDARD.decode(result.as_str().unwrap()).unwrap();
    let signature = Signature::try_from(bytes.as_slice()).unwrap();
    let identity = PublicKey::from_bytes(&blob).unwrap();
    Verifier::verify(&identity, &good, &signature).unwrap();
    let exported = local(&v, C::PublicKey, id.clone()).unwrap();
    assert!(
        PublicKey::from_openssh(exported.as_str().unwrap())
            .unwrap()
            .key_data()
            == identity.key_data()
    );
    let info = local(&v, C::Request, json!({"scope":scoped})).unwrap();
    assert_eq!(info["host"], "example.invalid");
    let grants = local(&v, C::Dashboard, json!({})).unwrap()["grants"].clone();
    assert_eq!(grants, json!([scoped]));
    assert_eq!(scoped["client"], "wpass + /usr/bin/ssh");
    local(&v, C::Revoke, scoped.clone()).unwrap();
    assert!(local(&v, C::AgentIdentity, id.clone()).is_err());
    assert!(local(&v, C::AgentSign, args(&good, &binding)).is_err());
    assert!(local(&v, C::Request, json!({"scope":scoped})).is_err());
    local(&v, C::Grant, scoped).unwrap();

    local(&v, C::Disconnect, id.clone()).unwrap();
    assert!(local(&v, C::AgentSign, args(&good, &binding)).is_err());
    assert_eq!(v.content_v2(v.generation()).unwrap().cards.len(), 1);
}
