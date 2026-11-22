use super::{OperationV1, Vault, VaultFailure};
use serde::{Deserialize, Serialize, de::DeserializeOwned};
use sha2::{Digest, Sha256};
use zeroize::{Zeroize, Zeroizing};

#[derive(Clone, Copy, PartialEq, Eq, Serialize)]
#[serde(rename_all = "snake_case")]
pub enum LocalToolCommandV1 {
    Dashboard,
    Configure,
    Disconnect,
    Grant,
    Revoke,
    Request,
    PublicKey,
    AgentIdentity,
    AgentSign,
}

#[derive(Clone, PartialEq, Eq, PartialOrd, Ord, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
#[flutter_rust_bridge::frb(ignore)]
pub(crate) struct Scope {
    pub client: String,
    pub action: String,
    pub target: String,
    pub resource: String,
    pub fields: Vec<String>,
    pub environment: String,
}

#[derive(Clone, Serialize, Deserialize, Zeroize)]
#[serde(deny_unknown_fields)]
#[flutter_rust_bridge::frb(ignore)]
pub(crate) struct SshProfile {
    pub id: String,
    pub key_id: String,
    pub binding_id: String,
    pub alias: String,
    pub host: String,
    pub user: String,
    pub port: u16,
    pub environment: String,
    pub host_key: String,
}

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
#[flutter_rust_bridge::frb(ignore)]
pub(crate) struct ProfileInput {
    pub key_id: Option<String>,
    pub alias: String,
    pub host: String,
    pub user: String,
    pub port: u16,
    pub environment: String,
    pub host_key: String,
}

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
#[flutter_rust_bridge::frb(ignore)]
pub(crate) struct ToolRequest {
    pub scope: Scope,
    #[serde(default)]
    pub export_public_key: bool,
    #[serde(default)]
    pub query: String,
    #[serde(default)]
    pub name: String,
    #[serde(default)]
    pub login: String,
    #[serde(default)]
    pub password: String,
}

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
#[flutter_rust_bridge::frb(ignore)]
pub(crate) struct SigningRequest {
    pub profile: String,
    pub binding: String,
    pub data: String,
    pub key: String,
}

pub(crate) fn parse<T: DeserializeOwned>(body: &str) -> Result<T, VaultFailure> {
    serde_json::from_str(body).map_err(|_| VaultFailure::Unsupported)
}
pub(crate) fn encode<T: Serialize>(value: &T) -> Result<String, VaultFailure> {
    serde_json::to_string(value).map_err(|_| VaultFailure::Unsupported)
}

pub fn local_tool_subject_v1(
    command: LocalToolCommandV1,
    body: String,
) -> Result<String, VaultFailure> {
    let body = Zeroizing::new(body);
    if body.len() > 65536 {
        return Err(VaultFailure::Unsupported);
    }
    let mut hash = Sha256::new();
    hash.update(encode(&command)?.as_bytes());
    hash.update([0]);
    hash.update(body.as_bytes());
    use base64::{Engine, engine::general_purpose::URL_SAFE_NO_PAD};
    Ok(format!(
        "local-tool:{}",
        URL_SAFE_NO_PAD.encode(hash.finalize())
    ))
}

impl Vault {
    pub fn local_tools_v1(
        &self,
        command: LocalToolCommandV1,
        body: String,
        generation: u64,
    ) -> Result<String, VaultFailure> {
        use LocalToolCommandV1 as C;
        let _turn = self
            .tool_job
            .lock()
            .map_err(|_| VaultFailure::Unavailable)?;
        let body = Zeroizing::new(body);
        if body.len() > 65536 {
            return Err(VaultFailure::Unsupported);
        }
        if !matches!(command, C::Dashboard | C::Revoke | C::AgentIdentity) {
            self.require_operation(
                OperationV1::IntegrationGrant,
                &local_tool_subject_v1(command, body.to_string())?,
                generation,
            )?;
        }
        match command {
            C::Dashboard => self.tool_dashboard(generation),
            C::Configure => self.configure_ssh_profile(parse(&body)?, generation),
            C::Disconnect => self.disconnect_ssh_profile(parse(&body)?, generation),
            C::Grant | C::Revoke => {
                let scope: Scope = parse(&body)?;
                if command == C::Grant {
                    self.read_cards(generation, |d| d.check_scope(&scope))?;
                }
                let mut state = self.state.lock().map_err(|_| VaultFailure::Unavailable)?;
                if self.generation() != generation || state.active.is_none() {
                    return Err(VaultFailure::Locked);
                }
                if command == C::Grant {
                    if state.tool_grants.len() >= 128 {
                        return Err(VaultFailure::Unsupported);
                    }
                    state.tool_grants.insert(scope);
                } else {
                    state.tool_grants.remove(&scope);
                }
                Ok("{}".into())
            }
            C::Request => self.execute_tool_request(parse(&body)?, generation),
            C::PublicKey => self.tool_public_key(parse(&body)?, generation),
            C::AgentIdentity => self.tool_agent_identity(parse(&body)?, generation),
            C::AgentSign => self.tool_agent_sign(parse(&body)?, generation),
        }
    }

    pub(in crate::api) fn check_tool_grant(
        &self,
        scope: &Scope,
        generation: u64,
    ) -> Result<(), VaultFailure> {
        let state = self.state.lock().map_err(|_| VaultFailure::Unavailable)?;
        if self.generation() != generation || state.active.is_none() {
            return Err(VaultFailure::Locked);
        }
        if !state.tool_grants.contains(scope) {
            return Err(VaultFailure::Credentials);
        }
        Ok(())
    }
}
