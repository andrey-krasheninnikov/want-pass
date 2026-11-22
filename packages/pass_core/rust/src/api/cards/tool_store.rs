use super::*;
use crate::api::local_tools::{
    ProfileInput, Scope, SigningRequest, SshProfile, ToolRequest, encode,
};
use crate::api::otp::field;
use crate::ssh_authentication as ssh;
use serde_json::{Value, json};
use zeroize::Zeroizing;

const BAD: VaultFailure = VaultFailure::Unsupported;
const SSH_CLIENTS: &str = "wpass + /usr/bin/ssh";
fn env(value: Option<EnvironmentV1>) -> String {
    value
        .and_then(|e| serde_json::to_value(e).ok()?.as_str().map(str::to_owned))
        .unwrap_or_else(|| "unassigned".into())
}
fn strings(values: &[&str]) -> Vec<String> {
    values.iter().map(|s| s.to_string()).collect()
}
fn safe_atom(s: &str, max: usize) -> bool {
    !s.is_empty()
        && s.len() <= max
        && s.as_bytes()[0].is_ascii_alphanumeric()
        && s.bytes()
            .all(|b| b.is_ascii_alphanumeric() || b"-_.".contains(&b))
}
impl SshProfile {
    fn resource(&self) -> String {
        format!("ssh://{}@{}:{}", self.user, self.host, self.port)
    }
    fn scope(&self) -> Scope {
        Scope {
            client: SSH_CLIENTS.into(),
            action: "ssh".into(),
            target: self.id.clone(),
            resource: self.resource(),
            fields: strings(&["public-key", "signature"]),
            environment: self.environment.clone(),
        }
    }
    fn metadata(&self) -> Value {
        json!({"id":self.id,"alias":self.alias,"host":self.host,"user":self.user,"port":self.port,"environment":self.environment,"host_key":self.host_key,"scope":self.scope()})
    }
}
impl DocumentV2 {
    fn tool_profile(&self, id: &str) -> Result<&SshProfile, VaultFailure> {
        self.ssh_profiles
            .iter()
            .find(|p| p.id == id || p.alias == id)
            .ok_or(VaultFailure::Missing)
    }
    fn permits_signing(binding: &ResourceBindingV1) -> bool {
        binding.kind == ResourceKindV1::SshHost
            && binding.method == BindingMethodV1::Ssh
            && ["public-key", "private-key"]
                .iter()
                .all(|field| binding.fields.iter().any(|allowed| allowed == field))
    }
    fn profile_ready(cards: &[StoredCard], p: &SshProfile) -> bool {
        cards.iter().any(|c| {
            c.id == p.key_id
                && c.card_type == CardTypeV1::Ed25519
                && (c.environment.is_none() || env(c.environment) == p.environment)
                && c.bindings.iter().any(|b| {
                    b.id == p.binding_id && Self::permits_signing(b) && b.target == p.resource()
                })
        })
    }
    pub(crate) fn prune_tool_profiles(&mut self) {
        self.ssh_profiles
            .retain(|p| Self::profile_ready(&self.cards, p));
    }
    pub(in crate::api) fn validate_tool_profiles(&self) -> Result<(), VaultFailure> {
        let mut aliases = BTreeSet::new();
        let mut ids = BTreeSet::new();
        if self.ssh_profiles.len() > 128 {
            return Err(BAD);
        }
        for p in &self.ssh_profiles {
            if !valid_id(&p.id)
                || !safe_atom(&p.alias, 60)
                || !safe_atom(&p.host, 253)
                || !safe_atom(&p.user, 64)
                || p.port == 0
                || !aliases.insert(&p.alias)
                || !ids.insert(&p.id)
                || !Self::profile_ready(&self.cards, p)
            {
                return Err(BAD);
            }
            ssh::public(&p.host_key)?;
            serde_json::from_value::<EnvironmentV1>(json!(&p.environment)).map_err(|_| BAD)?;
        }
        Ok(())
    }
    fn web_binding(&self, id: &str) -> Result<(&StoredCard, &ResourceBindingV1), VaultFailure> {
        self.cards
            .iter()
            .find_map(|c| {
                c.bindings
                    .iter()
                    .find(|b| b.id == id && b.kind == ResourceKindV1::WebApp)
                    .map(|b| (c, b))
            })
            .ok_or(VaultFailure::Missing)
    }
    pub(in crate::api) fn check_scope(&self, s: &Scope) -> Result<(), VaultFailure> {
        if s.action == "ssh" {
            let profile = self.tool_profile(&s.target)?;
            if !Self::profile_ready(&self.cards, profile) || profile.scope() != *s {
                return Err(BAD);
            }
        } else {
            let (card, b) = self.web_binding(&s.target)?;
            let expected = match s.action.as_str() {
                "search" => strings(&["name", "service"]),
                "store" => strings(&["login", "password"]),
                _ => return Err(BAD),
            };
            if s.client != "wpass"
                || s.resource != b.target
                || s.environment != env(card.environment)
                || s.fields != expected
                || s.action == "store" && !expected.iter().all(|f| b.fields.contains(f))
            {
                return Err(BAD);
            }
        }
        Ok(())
    }
}

impl Vault {
    pub(in crate::api) fn tool_dashboard(&self, g: u64) -> Result<String, VaultFailure> {
        let mut result=self.read_cards(g,|d|{
            let bindings:Vec<_>=d.cards.iter().flat_map(|c|c.bindings.iter().filter(|b|b.kind==ResourceKindV1::WebApp).map(|b|json!({"id":b.id,"resource":b.target,"environment":env(c.environment),"name":c.name}))).collect();
            let keys:Vec<_>=d.cards.iter().filter(|c|c.card_type==CardTypeV1::Ed25519).map(|c|json!({"id":c.id,"name":c.name})).collect();
            Ok(json!({"profiles":d.ssh_profiles.iter().map(SshProfile::metadata).collect::<Vec<_>>(),"bindings":bindings,"keys":keys}))
        })?;
        let state = self.state.lock().map_err(|_| VaultFailure::Unavailable)?;
        if self.generation() != g || state.active.is_none() {
            return Err(VaultFailure::Locked);
        }
        result["grants"] = serde_json::to_value(&state.tool_grants).map_err(|_| BAD)?;
        encode(&result)
    }

    pub(in crate::api) fn configure_ssh_profile(
        &self,
        input: ProfileInput,
        g: u64,
    ) -> Result<String, VaultFailure> {
        if !safe_atom(&input.alias, 60)
            || !safe_atom(&input.user, 64)
            || !safe_atom(&input.host, 253)
            || input.port == 0
        {
            return Err(BAD);
        }
        let host = input.host.to_ascii_lowercase();
        let environment: EnvironmentV1 =
            serde_json::from_value(json!(input.environment)).map_err(|_| BAD)?;
        let host_key = ssh::public(&input.host_key)?
            .to_openssh()
            .map_err(|_| BAD)?;
        let revision = self.content_v2(g)?.revision;
        let (_, id) = self.mutate_cards_with(revision, g, |d| {
            if d.ssh_profiles.len() >= 128 || d.ssh_profiles.iter().any(|p| p.alias == input.alias)
            {
                return Err(VaultFailure::Exists);
            }
            let existing_key = input.key_id.is_some();
            let i = if let Some(key) = input.key_id {
                let i = d.card_index(&key)?;
                let c = &d.cards[i];
                if c.card_type != CardTypeV1::Ed25519
                    || c.environment.is_some_and(|value| value != environment)
                {
                    return Err(BAD);
                }
                ssh::matching(
                    field(&c.fields, FieldIdV1::PublicKey).ok_or(BAD)?,
                    field(&c.fields, FieldIdV1::PrivateKey).ok_or(BAD)?,
                )?;
                i
            } else {
                let (public, private) = ssh::make_key()?;
                let c = StoredCard {
                    id: new_id()?,
                    name: input.alias.clone(),
                    description: String::new(),
                    service: "other".into(),
                    environment: Some(environment),
                    group_ids: vec![],
                    card_type: CardTypeV1::Ed25519,
                    template_version: 1,
                    fields: vec![
                        CardValueV1 {
                            id: FieldIdV1::PublicKey,
                            value: public,
                        },
                        CardValueV1 {
                            id: FieldIdV1::PrivateKey,
                            value: private.to_string(),
                        },
                    ],
                    attachment: None,
                    bindings: vec![],
                    custom: None,
                };
                c.validate(d)?;
                d.cards.push(c);
                d.cards.len() - 1
            };
            let target = format!("ssh://{}@{}:{}", input.user, host, input.port);
            let binding_id = if let Some(b) = d.cards[i]
                .bindings
                .iter()
                .find(|b| b.kind == ResourceKindV1::SshHost && b.target == target)
            {
                if !DocumentV2::permits_signing(b) {
                    return Err(BAD);
                }
                b.id.clone()
            } else {
                let id = new_id()?;
                if existing_key {
                    d.archive(i)?;
                }
                d.cards[i].bindings.push(ResourceBindingV1 {
                    id: id.clone(),
                    kind: ResourceKindV1::SshHost,
                    target,
                    method: BindingMethodV1::Ssh,
                    fields: strings(&["public-key", "private-key"]),
                });
                id
            };
            let id = new_id()?;
            d.ssh_profiles.push(SshProfile {
                id: id.clone(),
                key_id: d.cards[i].id.clone(),
                binding_id,
                alias: input.alias,
                user: input.user,
                host,
                port: input.port,
                host_key,
                environment: input.environment,
            });
            Ok(id)
        })?;
        encode(&id)
    }

    pub(in crate::api) fn disconnect_ssh_profile(
        &self,
        id: String,
        g: u64,
    ) -> Result<String, VaultFailure> {
        let revision = self.content_v2(g)?.revision;
        self.mutate_cards(revision, g, |d| {
            let p = d
                .ssh_profiles
                .iter()
                .position(|p| p.id == id)
                .ok_or(VaultFailure::Missing)?;
            d.ssh_profiles.remove(p);
            Ok(())
        })?;
        self.state
            .lock()
            .map_err(|_| VaultFailure::Unavailable)?
            .tool_grants
            .retain(|s| s.target != id);
        Ok("{}".into())
    }
    pub(in crate::api) fn tool_public_key(
        &self,
        id: String,
        g: u64,
    ) -> Result<String, VaultFailure> {
        self.read_cards(g, |d| {
            let p = d.tool_profile(&id)?;
            let c = &d.cards[d.card_index(&p.key_id)?];
            encode(
                &ssh::public(field(&c.fields, FieldIdV1::PublicKey).ok_or(BAD)?)?
                    .to_openssh()
                    .map_err(|_| BAD)?,
            )
        })
    }
    pub(in crate::api) fn execute_tool_request(
        &self,
        mut req: ToolRequest,
        g: u64,
    ) -> Result<String, VaultFailure> {
        let password = Zeroizing::new(std::mem::take(&mut req.password));
        if req.scope.client != "wpass"
            && !(req.scope.action == "ssh" && req.scope.client == SSH_CLIENTS)
        {
            return Err(BAD);
        }
        if req.export_public_key && req.scope.action != "ssh" {
            return Err(BAD);
        }
        self.check_tool_grant(&req.scope, g)?;
        match req.scope.action.as_str() {
            "ssh" | "search" => {
                let _snapshot = self.job.try_lock().map_err(|_| VaultFailure::Busy)?;
                if !req.name.is_empty()
                    || !req.login.is_empty()
                    || !password.is_empty()
                    || req.query.len() > 256
                {
                    return Err(BAD);
                }
                self.read_cards(g, |d| {
                    d.check_scope(&req.scope)?;
                    if req.scope.action == "ssh" {
                        if !req.query.is_empty() {
                            return Err(BAD);
                        }
                        if req.export_public_key {
                            let profile = d.tool_profile(&req.scope.target)?;
                            let card = &d.cards[d.card_index(&profile.key_id)?];
                            let public =
                                ssh::public(field(&card.fields, FieldIdV1::PublicKey).ok_or(BAD)?)?;
                            return encode(&public.to_openssh().map_err(|_| BAD)?);
                        }
                        return encode(&d.tool_profile(&req.scope.target)?.metadata());
                    }
                    let query = req.query.to_lowercase();
                    let (card, _) = d.web_binding(&req.scope.target)?;
                    let result = card
                        .name
                        .to_lowercase()
                        .contains(&query)
                        .then(|| json!({"name":card.name,"service":card.service}))
                        .into_iter()
                        .collect::<Vec<_>>();
                    encode(&result)
                })
            }
            "store" => {
                if !req.query.is_empty() {
                    return Err(BAD);
                }
                let revision = self.content_v2(g)?.revision;
                self.mutate_cards(revision, g, |d| {
                    d.check_scope(&req.scope)?;
                    if d.cards.iter().any(|c| {
                        c.card_type == CardTypeV1::Account
                            && c.name == req.name
                            && env(c.environment) == req.scope.environment
                            && field(&c.fields, FieldIdV1::Login) == Some(req.login.as_str())
                            && field(&c.fields, FieldIdV1::Password) == Some(password.as_str())
                            && c.bindings.iter().any(|b| {
                                b.kind == ResourceKindV1::WebApp && b.target == req.scope.resource
                            })
                    }) {
                        return Ok(());
                    }
                    let (original, _) = d.web_binding(&req.scope.target)?;
                    let c = StoredCard {
                        id: new_id()?,
                        name: req.name,
                        description: String::new(),
                        service: original.service.clone(),
                        environment: original.environment,
                        group_ids: vec![],
                        card_type: CardTypeV1::Account,
                        template_version: 1,
                        fields: vec![
                            CardValueV1 {
                                id: FieldIdV1::Login,
                                value: req.login,
                            },
                            CardValueV1 {
                                id: FieldIdV1::Password,
                                value: password.to_string(),
                            },
                        ],
                        attachment: None,
                        bindings: vec![ResourceBindingV1::web_account(&req.scope.resource)?],
                        custom: None,
                    };
                    c.validate(d)?;
                    d.cards.push(c);
                    Ok(())
                })?;
                Ok("{}".into())
            }
            _ => Err(BAD),
        }
    }
    pub(in crate::api) fn tool_agent_identity(
        &self,
        id: String,
        g: u64,
    ) -> Result<String, VaultFailure> {
        let (scope, blob) = self.read_cards(g, |d| {
            let p = d.tool_profile(&id)?;
            let c = &d.cards[d.card_index(&p.key_id)?];
            let key = ssh::public(field(&c.fields, FieldIdV1::PublicKey).ok_or(BAD)?)?;
            Ok((p.scope(), BASE64.encode(key.to_bytes().map_err(|_| BAD)?)))
        })?;
        self.check_tool_grant(&scope, g)?;
        encode(&blob)
    }
    pub(in crate::api) fn tool_agent_sign(
        &self,
        req: SigningRequest,
        g: u64,
    ) -> Result<String, VaultFailure> {
        let _snapshot = self.job.try_lock().map_err(|_| VaultFailure::Busy)?;
        let scope = self.read_cards(g, |d| Ok(d.tool_profile(&req.profile)?.scope()))?;
        self.check_tool_grant(&scope, g)?;
        self.read_cards(g, |d| {
            d.check_scope(&scope)?;
            let p = d.tool_profile(&req.profile)?;
            let c = &d.cards[d.card_index(&p.key_id)?];
            let key = ssh::matching(
                field(&c.fields, FieldIdV1::PublicKey).ok_or(BAD)?,
                field(&c.fields, FieldIdV1::PrivateKey).ok_or(BAD)?,
            )?;
            encode(&ssh::sign_userauth(
                &ssh::public(&p.host_key)?,
                &p.user,
                &key,
                &req.key,
                &req.binding,
                &req.data,
            )?)
        })
    }
}
