use want_pass_vault::api::{
    BackupChoiceV1, BackupEntityV1, BackupResolutionV1, BackupStrategyV1, CardInputV1, CardTypeV1,
    CardValueV1, FieldIdV1, GroupInputV1, Vault, VaultFailure,
};

const PW: &str = "Synthetic backup password 2026!";

fn vault() -> (tempfile::TempDir, Vault, String) {
    let directory = tempfile::tempdir().unwrap();
    let vault = Vault::open(directory.path().join("vault").to_str().unwrap().into()).unwrap();
    let draft = vault
        .prepare_creation_v3(PW.into(), vault.generation())
        .unwrap();
    let answers = draft
        .positions
        .iter()
        .map(|p| draft.words[*p as usize].clone())
        .collect();
    vault
        .confirm_v3(
            answers,
            PW.into(),
            String::new(),
            String::new(),
            draft.revision,
        )
        .unwrap();
    (directory, vault, draft.json)
}

fn group(id: Option<String>, name: &str) -> GroupInputV1 {
    GroupInputV1 {
        id,
        name: name.into(),
        description: String::new(),
        icon: "folder".into(),
        logo: vec![],
    }
}

fn card(id: Option<String>, group: &str, name: &str) -> CardInputV1 {
    CardInputV1 {
        id,
        name: name.into(),
        description: String::new(),
        service: "github".into(),
        environment: None,
        group_ids: vec![group.into()],
        card_type: CardTypeV1::Account,
        fields: vec![
            CardValueV1 {
                id: FieldIdV1::Login,
                value: "backup@example.invalid".into(),
            },
            CardValueV1 {
                id: FieldIdV1::Password,
                value: "synthetic password".into(),
            },
        ],
        attachment: None,
    }
}

#[test]
fn restore_previews_and_preserves_the_target_identity_and_forked_references() {
    let (files, origin, phrase) = vault();
    let (_target_files, target, target_phrase) = vault();
    let path = files
        .path()
        .join("portable.wpassbackup")
        .to_str()
        .unwrap()
        .to_owned();
    let g = origin.generation();
    let one = origin
        .save_group_v2(group(None, "Source group"), 0, g)
        .unwrap();
    let gid = one.groups[0].id.clone();
    let two = origin
        .save_card_v1(card(None, &gid, "Earlier card"), one.revision, g)
        .unwrap();
    let cid = two.cards[0].id.clone();
    let three = origin
        .save_card_v1(
            card(Some(cid.clone()), &gid, "Source card"),
            two.revision,
            g,
        )
        .unwrap();
    origin
        .export_backup_v1(path.clone(), three.revision, g)
        .unwrap();
    let encrypted = std::fs::read(&path).unwrap();
    assert!(!encrypted.windows(12).any(|w| w == b"Source group"));
    let tg = target.generation();
    assert!(
        target
            .preview_backup_v1(
                path.clone(),
                target_phrase.clone(),
                BackupStrategyV1::Replace,
                vec![],
                tg
            )
            .is_err()
    );
    let start = target
        .save_group_v2(group(None, "Temporary"), 0, tg)
        .unwrap();
    let preview = target
        .preview_backup_v1(
            path.clone(),
            phrase.clone(),
            BackupStrategyV1::Replace,
            vec![],
            tg,
        )
        .unwrap();
    assert_eq!(
        (preview.added, preview.removed, preview.revision),
        (3, 1, start.revision)
    );
    target
        .apply_backup_v1(
            path.clone(),
            phrase.clone(),
            BackupStrategyV1::Replace,
            vec![],
            preview.revision,
            preview.fingerprint,
            tg,
        )
        .unwrap();
    assert!(matches!(target.content_v2(tg), Err(VaultFailure::Stale)));
    let tg = target.generation();
    let first = target.content_v2(tg).unwrap();
    assert_eq!(first.groups[0].id, gid);
    let local = target
        .save_group_v2(group(Some(gid.clone()), "Local group"), first.revision, tg)
        .unwrap();
    let conflict = target
        .preview_backup_v1(
            path.clone(),
            phrase.clone(),
            BackupStrategyV1::Merge,
            vec![],
            tg,
        )
        .unwrap();
    assert!(
        conflict
            .conflicts
            .iter()
            .any(|c| c.entity == BackupEntityV1::Group && c.id == gid && c.resolution.is_none())
    );
    assert!(matches!(
        target.apply_backup_v1(
            path.clone(),
            phrase.clone(),
            BackupStrategyV1::Merge,
            vec![],
            conflict.revision,
            conflict.fingerprint.clone(),
            tg
        ),
        Err(VaultFailure::Confirmation)
    ));
    let mut choices = vec![BackupChoiceV1 {
        entity: BackupEntityV1::Group,
        id: gid.clone(),
        resolution: BackupResolutionV1::Both,
    }];
    let linked = target
        .preview_backup_v1(
            path.clone(),
            phrase.clone(),
            BackupStrategyV1::Merge,
            choices.clone(),
            tg,
        )
        .unwrap();
    assert!(
        linked
            .conflicts
            .iter()
            .any(|c| c.entity == BackupEntityV1::Card && c.id == cid)
    );
    choices.push(BackupChoiceV1 {
        entity: BackupEntityV1::Card,
        id: cid.clone(),
        resolution: BackupResolutionV1::Both,
    });
    let linked_history = target
        .preview_backup_v1(
            path.clone(),
            phrase.clone(),
            BackupStrategyV1::Merge,
            choices.clone(),
            tg,
        )
        .unwrap();
    for h in linked_history
        .conflicts
        .iter()
        .filter(|c| c.entity == BackupEntityV1::History)
    {
        choices.push(BackupChoiceV1 {
            entity: h.entity,
            id: h.id.clone(),
            resolution: BackupResolutionV1::Both,
        });
    }
    let ready = target
        .preview_backup_v1(
            path.clone(),
            phrase.clone(),
            BackupStrategyV1::Merge,
            choices.clone(),
            tg,
        )
        .unwrap();
    assert!(ready.conflicts.iter().all(|c| c.resolution.is_some()));
    assert!(matches!(
        target.apply_backup_v1(
            path.clone(),
            phrase.clone(),
            BackupStrategyV1::Merge,
            choices.clone(),
            ready.revision,
            conflict.fingerprint,
            tg
        ),
        Err(VaultFailure::Stale)
    ));
    target
        .apply_backup_v1(
            path.clone(),
            phrase.clone(),
            BackupStrategyV1::Merge,
            choices,
            ready.revision,
            ready.fingerprint,
            tg,
        )
        .unwrap();
    let tg = target.generation();
    let forked = target.content_v2(tg).unwrap();
    assert_eq!((forked.groups.len(), forked.cards.len()), (2, 2));
    let alternate_group = forked.groups.iter().find(|v| v.id != gid).unwrap();
    let alternate_card = forked.cards.iter().find(|v| v.id != cid).unwrap();
    assert_eq!(
        alternate_card.group_ids.as_slice(),
        std::slice::from_ref(&alternate_group.id)
    );
    let snapshots = target
        .history_v1(Some(alternate_card.id.clone()), forked.revision, tg)
        .unwrap();
    assert_eq!(snapshots.len(), 1);
    let unchanged = target
        .preview_backup_v1(
            path.clone(),
            phrase.clone(),
            BackupStrategyV1::Merge,
            vec![],
            tg,
        )
        .unwrap();
    assert_eq!(
        (
            unchanged.added,
            unchanged.changed,
            unchanged.conflicts.len()
        ),
        (0, 0, 0)
    );
    target
        .apply_backup_v1(
            path.clone(),
            phrase.clone(),
            BackupStrategyV1::Merge,
            vec![],
            unchanged.revision,
            unchanged.fingerprint,
            tg,
        )
        .unwrap();
    let tg = target.generation();
    assert_eq!(target.content_v2(tg).unwrap().revision, forked.revision);
    assert!(
        target
            .export_backup_v1(path.clone(), local.revision, tg)
            .is_err()
    );
    let target_file = files
        .path()
        .join("target.wpassbackup")
        .to_str()
        .unwrap()
        .to_owned();
    target
        .export_backup_v1(target_file.clone(), forked.revision, tg)
        .unwrap();
    assert!(
        origin
            .preview_backup_v1(
                target_file.clone(),
                phrase,
                BackupStrategyV1::Replace,
                vec![],
                g
            )
            .is_err()
    );
    assert!(
        origin
            .preview_backup_v1(
                target_file,
                target_phrase,
                BackupStrategyV1::Replace,
                vec![],
                g
            )
            .is_ok()
    );
}

fn restore(
    v: &Vault,
    path: &str,
    words: &str,
    mode: BackupStrategyV1,
    choices: Vec<BackupChoiceV1>,
) {
    let g = v.generation();
    let plan = v
        .preview_backup_v1(path.into(), words.into(), mode, choices.clone(), g)
        .unwrap();
    v.apply_backup_v1(
        path.into(),
        words.into(),
        mode,
        choices,
        plan.revision,
        plan.fingerprint,
        g,
    )
    .unwrap();
}

#[test]
fn ssh_profile_removals_match_preview_for_replace_and_merge() {
    use serde_json::{Value, json};
    use want_pass_vault::api::LocalToolCommandV1 as Tool;
    let (dir, v, words) = vault();
    let public = ssh_key::PrivateKey::from_openssh(include_str!("fixtures/synthetic_ed25519"))
        .unwrap()
        .public_key()
        .to_openssh()
        .unwrap();
    let configure = |alias: &str, hostname: &str, key: Option<&str>| {
        let data = json!({"alias":alias,"host":hostname,"user":"owner","port":22,"environment":"development","host_key":public,"key_id":key});
        v.local_tools_v1(Tool::Configure, data.to_string(), v.generation())
            .unwrap();
    };
    let profiles = || {
        let json = v
            .local_tools_v1(Tool::Dashboard, "{}".into(), v.generation())
            .unwrap();
        serde_json::from_str::<Value>(&json).unwrap()["profiles"]
            .as_array()
            .unwrap()
            .len()
    };
    configure("first", "first.invalid", None);
    let archive = dir.path().join("profiles.wpassbackup");
    let path = archive.to_str().unwrap();
    let first = v.content_v2(v.generation()).unwrap();
    let key = first.cards[0].id.clone();
    v.export_backup_v1(path.into(), first.revision, v.generation())
        .unwrap();
    let preview = |mode, choices| {
        v.preview_backup_v1(path.into(), words.clone(), mode, choices, v.generation())
            .unwrap()
    };
    assert_eq!(preview(BackupStrategyV1::Replace, vec![]).removed, 1);
    assert_eq!(preview(BackupStrategyV1::Merge, vec![]).removed, 0);
    configure("second", "second.invalid", Some(&key));
    assert_eq!(profiles(), 2);
    let choices = vec![BackupChoiceV1 {
        entity: BackupEntityV1::Card,
        id: key,
        resolution: BackupResolutionV1::Incoming,
    }];
    assert_eq!(preview(BackupStrategyV1::Merge, choices.clone()).removed, 2);
    restore(&v, path, &words, BackupStrategyV1::Merge, choices);
    assert_eq!(profiles(), 0);
    let key = v.content_v2(v.generation()).unwrap().cards[0].id.clone();
    configure("first", "first.invalid", Some(&key));
    assert_eq!(profiles(), 1);
    let next = dir.path().join("identical.wpassbackup");
    let revision = v.content_v2(v.generation()).unwrap().revision;
    let path = next.to_str().unwrap();
    v.export_backup_v1(path.into(), revision, v.generation())
        .unwrap();
    let plan = v
        .preview_backup_v1(
            path.into(),
            words.clone(),
            BackupStrategyV1::Replace,
            vec![],
            v.generation(),
        )
        .unwrap();
    assert_eq!((plan.added, plan.changed, plan.removed), (0, 0, 1));
    restore(&v, path, &words, BackupStrategyV1::Replace, vec![]);
    assert_eq!(profiles(), 0);
}

#[test]
fn taking_incoming_archives_the_displaced_local_card_once() {
    let (dir, local, _) = vault();
    let (source_dir, source, words) = vault();
    let g = source.generation();
    let state = source.save_group_v2(group(None, "Team"), 0, g).unwrap();
    let gid = state.groups[0].id.clone();
    let a = source
        .save_card_v1(card(None, &gid, "A"), state.revision, g)
        .unwrap();
    let id = a.cards[0].id.clone();
    let shared = source_dir.path().join("a.wpassbackup");
    source
        .export_backup_v1(shared.to_str().unwrap().into(), a.revision, g)
        .unwrap();
    restore(
        &local,
        shared.to_str().unwrap(),
        &words,
        BackupStrategyV1::Replace,
        vec![],
    );
    let lg = local.generation();
    let rev = local.content_v2(lg).unwrap().revision;
    local
        .save_card_v1(card(Some(id.clone()), &gid, "B"), rev, lg)
        .unwrap();
    let c = source
        .save_card_v1(card(Some(id.clone()), &gid, "C"), a.revision, g)
        .unwrap();
    let new = dir.path().join("c.wpassbackup");
    let path = new.to_str().unwrap();
    source.export_backup_v1(path.into(), c.revision, g).unwrap();
    let choice = BackupChoiceV1 {
        entity: BackupEntityV1::Card,
        id: id.clone(),
        resolution: BackupResolutionV1::Incoming,
    };
    restore(&local, path, &words, BackupStrategyV1::Merge, vec![choice]);
    let current = local.content_v2(local.generation()).unwrap();
    assert_eq!(current.cards[0].name, "C");
    let hist = local
        .history_v1(Some(id.clone()), current.revision, local.generation())
        .unwrap();
    let displaced: Vec<_> = hist.iter().filter(|h| h.name == "B").collect();
    assert_eq!(displaced.len(), 1);
    let replay = local
        .preview_backup_v1(
            path.into(),
            words.clone(),
            BackupStrategyV1::Merge,
            vec![],
            local.generation(),
        )
        .unwrap();
    assert_eq!((replay.added, replay.changed, replay.removed), (0, 0, 0));
    restore(&local, path, &words, BackupStrategyV1::Merge, vec![]);
    let current = local.content_v2(local.generation()).unwrap();
    assert_eq!(
        local
            .history_v1(Some(id), current.revision, local.generation())
            .unwrap()
            .len(),
        hist.len()
    );
    let restored = local
        .restore_history_v1(
            displaced[0].id.clone(),
            current.revision,
            local.generation(),
        )
        .unwrap();
    assert_eq!(restored.cards[0].name, "B");
}

#[cfg(unix)]
#[test]
fn export_uses_a_new_private_file_and_preserves_existing_paths() {
    use std::os::unix::fs::{PermissionsExt, symlink};
    let (dir, v, _) = vault();
    let export =
        |p: &std::path::Path| v.export_backup_v1(p.to_str().unwrap().into(), 0, v.generation());
    let path = dir.path().join("fixture.wpassbackup");
    let results = std::thread::scope(|scope| {
        let one = scope.spawn(|| export(&path));
        let two = scope.spawn(|| export(&path));
        [one.join().unwrap(), two.join().unwrap()]
    });
    assert_eq!(results.iter().filter(|r| r.is_ok()).count(), 1);
    let bytes = std::fs::read(&path).unwrap();
    assert_eq!(
        std::fs::metadata(&path).unwrap().permissions().mode() & 0o777,
        0o600
    );
    assert!(export(&path).is_err());
    assert_eq!(std::fs::read(&path).unwrap(), bytes);
    let link = dir.path().join("alias.wpassbackup");
    symlink(&path, &link).unwrap();
    assert!(export(&link).is_err());
    let alias = dir.path().join("dir-link");
    symlink(dir.path(), &alias).unwrap();
    assert!(export(&alias.join("new.wpassbackup")).is_err());
    assert!(!dir.path().join("new.wpassbackup").exists());
    let names: Vec<_> = dir
        .path()
        .read_dir()
        .unwrap()
        .map(|e| e.unwrap().file_name())
        .collect();
    assert_eq!(names.len(), 4);
}

#[test]
fn rotating_recovery_changes_only_future_backup_recipients() {
    let (files, vault, previous) = vault();
    let before = files
        .path()
        .join("before.wpassbackup")
        .to_str()
        .unwrap()
        .to_owned();
    let after = files
        .path()
        .join("after.wpassbackup")
        .to_str()
        .unwrap()
        .to_owned();
    vault
        .export_backup_v1(before.clone(), 0, vault.generation())
        .unwrap();
    vault.lock().unwrap();
    let replacement = vault
        .prepare_recovery_v3(previous.clone(), PW.into(), vault.generation())
        .unwrap();
    let answers = replacement
        .positions
        .iter()
        .map(|p| replacement.words[*p as usize].clone())
        .collect();
    vault
        .confirm_v3(
            answers,
            PW.into(),
            String::new(),
            String::new(),
            replacement.revision,
        )
        .unwrap();
    let generation = vault.generation();
    let revision = vault.content_v2(generation).unwrap().revision;
    vault
        .export_backup_v1(after.clone(), revision, generation)
        .unwrap();
    assert!(
        vault
            .preview_backup_v1(
                before.clone(),
                previous.clone(),
                BackupStrategyV1::Merge,
                vec![],
                generation
            )
            .is_ok()
    );
    assert!(
        vault
            .preview_backup_v1(
                before,
                replacement.json.clone(),
                BackupStrategyV1::Merge,
                vec![],
                generation
            )
            .is_err()
    );
    assert!(
        vault
            .preview_backup_v1(
                after.clone(),
                previous,
                BackupStrategyV1::Merge,
                vec![],
                generation
            )
            .is_err()
    );
    assert!(
        vault
            .preview_backup_v1(
                after,
                replacement.json,
                BackupStrategyV1::Merge,
                vec![],
                generation
            )
            .is_ok()
    );
}

#[test]
fn replacement_preserves_target_authenticator_and_rejects_damaged_data_before_writing() {
    use std::time::{SystemTime, UNIX_EPOCH};
    use totp_rs::{Builder, Secret};
    use want_pass_vault::api::OperationV1;

    fn enroll(vault: &Vault, operation: OperationV1) {
        let generation = vault.generation();
        let seed = vault.begin_external_totp_v1(generation).unwrap();
        let authenticator = Builder::new()
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
                authenticator.generate(now).to_string(),
                vec![operation],
                generation,
            )
            .unwrap();
    }

    let (files, source, phrase) = vault();
    let (_target_files, target, _) = vault();
    enroll(&source, OperationV1::Reveal);
    enroll(&target, OperationV1::Copy);
    let current = target.generation();
    let previous = target.content_v2(current).unwrap();
    let path = files.path().join("secured.wpassbackup");
    let source_generation = source.generation();
    let revision = source.content_v2(source_generation).unwrap().revision;
    let with_group = source
        .save_group_v2(group(None, "Source group"), revision, source_generation)
        .unwrap();
    source
        .export_backup_v1(
            path.to_str().unwrap().into(),
            with_group.revision,
            source_generation,
        )
        .unwrap();
    let damaged = files.path().join("damaged.wpassbackup");
    let mut altered = std::fs::read(&path).unwrap();
    *altered.last_mut().unwrap() ^= 1;
    std::fs::write(&damaged, altered).unwrap();
    assert!(
        target
            .preview_backup_v1(
                damaged.to_str().unwrap().into(),
                phrase.clone(),
                BackupStrategyV1::Replace,
                vec![],
                current
            )
            .is_err()
    );
    assert_eq!(
        target.content_v2(current).unwrap().revision,
        previous.revision
    );
    let preview = target
        .preview_backup_v1(
            path.to_str().unwrap().into(),
            phrase.clone(),
            BackupStrategyV1::Replace,
            vec![],
            current,
        )
        .unwrap();
    target
        .apply_backup_v1(
            path.to_str().unwrap().into(),
            phrase,
            BackupStrategyV1::Replace,
            vec![],
            preview.revision,
            preview.fingerprint,
            current,
        )
        .unwrap();
    let policy = target.protection_settings_v1(target.generation()).unwrap();
    assert!(policy.enrolled);
    assert_eq!(policy.operations, [OperationV1::Copy]);
}
