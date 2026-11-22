use super::content::{bounded, new_id};
use super::{AttachmentInputV1, AttachmentSummaryV1, CardSummaryV1, CardValueV1, VaultFailure};
use serde::{Deserialize, Serialize};
use std::collections::BTreeSet;
use zeroize::Zeroize;

#[derive(Clone, PartialEq, Eq, Serialize, Deserialize, Zeroize)]
#[serde(deny_unknown_fields)]
pub struct ServiceDefinitionV1 {
    pub id: String,
    pub name: String,
    pub description: String,
    pub icon: String,
    pub logo: Vec<u8>,
    pub archived: bool,
}

#[derive(Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "kebab-case")]
pub enum CustomFieldKindV1 {
    Text,
    Concealed,
    Url,
    Otp,
    Codes,
    File,
}

#[derive(Clone, PartialEq, Eq, Serialize, Deserialize, Zeroize)]
#[serde(deny_unknown_fields)]
pub struct TemplateFieldV1 {
    pub id: String,
    pub label: String,
    #[zeroize(skip)]
    pub kind: CustomFieldKindV1,
    pub required: bool,
}

#[derive(Clone, PartialEq, Eq, Serialize, Deserialize, Zeroize)]
#[serde(deny_unknown_fields)]
pub struct TemplateVersionV1 {
    pub number: u32,
    pub name: String,
    pub fields: Vec<TemplateFieldV1>,
}

#[derive(Clone, PartialEq, Eq, Serialize, Deserialize, Zeroize)]
#[serde(deny_unknown_fields)]
pub struct TemplateDefinitionV1 {
    pub id: String,
    pub versions: Vec<TemplateVersionV1>,
}

#[derive(Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "kebab-case")]
pub enum ResourceKindV1 {
    WebApp,
    RestEndpoint,
    SshHost,
    GitRepository,
    PackageRegistry,
    ContainerRegistry,
    Database,
    KubernetesContext,
}

#[derive(Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "kebab-case")]
pub enum BindingMethodV1 {
    Web,
    Rest,
    Ssh,
    Git,
    Registry,
    Database,
    Kubernetes,
    AwsCli,
    Netrc,
    Mtls,
}

#[derive(Clone, PartialEq, Eq, Serialize, Deserialize, Zeroize)]
#[serde(deny_unknown_fields)]
pub struct ResourceBindingV1 {
    pub id: String,
    #[zeroize(skip)]
    pub kind: ResourceKindV1,
    pub target: String,
    #[zeroize(skip)]
    pub method: BindingMethodV1,
    pub fields: Vec<String>,
}

impl ResourceBindingV1 {
    pub(crate) fn web_target(input: &str) -> Result<String, VaultFailure> {
        normalize_target(ResourceKindV1::WebApp, input)
    }

    pub(crate) fn web_account(url: &str) -> Result<Self, VaultFailure> {
        Ok(Self {
            id: new_id()?,
            kind: ResourceKindV1::WebApp,
            target: Self::web_target(url)?,
            method: BindingMethodV1::Web,
            fields: vec!["login".into(), "password".into()],
        })
    }

    pub(crate) fn validate(&self, field_ids: &BTreeSet<String>) -> Result<(), VaultFailure> {
        use BindingMethodV1 as M;
        use ResourceKindV1 as R;
        let allowed = match self.kind {
            R::WebApp => matches!(self.method, M::Web | M::Netrc | M::Mtls),
            R::RestEndpoint => matches!(self.method, M::Rest | M::Netrc | M::Mtls | M::AwsCli),
            R::SshHost => self.method == M::Ssh,
            R::GitRepository => matches!(self.method, M::Git | M::Ssh | M::Netrc),
            R::PackageRegistry | R::ContainerRegistry => {
                matches!(self.method, M::Registry | M::Netrc | M::Mtls)
            }
            R::Database => matches!(self.method, M::Database | M::Mtls),
            R::KubernetesContext => matches!(self.method, M::Kubernetes | M::Mtls),
        };
        if !allowed
            || !valid_id(&self.id)
            || self.target != normalize_target(self.kind, &self.target)?
            || self.fields.is_empty()
            || self.fields.iter().any(|key| !field_ids.contains(key))
            || self.fields.iter().collect::<BTreeSet<_>>().len() != self.fields.len()
        {
            return Err(VaultFailure::Unsupported);
        }
        Ok(())
    }
}

pub(crate) fn valid_id(id: &str) -> bool {
    id.len() == 32
        && id
            .bytes()
            .all(|b| b.is_ascii_digit() || (b'a'..=b'f').contains(&b))
}

pub(crate) fn normalize_target(kind: ResourceKindV1, input: &str) -> Result<String, VaultFailure> {
    use ResourceKindV1 as R;
    let input = input.trim();
    bounded(input, 4096, true)?;
    if input
        .bytes()
        .any(|b| b.is_ascii_control() || b.is_ascii_whitespace())
    {
        return Err(VaultFailure::Unsupported);
    }
    if kind == R::KubernetesContext {
        if input
            .bytes()
            .all(|b| b.is_ascii_alphanumeric() || b"-_.@:/".contains(&b))
        {
            return Ok(input.into());
        }
        return Err(VaultFailure::Unsupported);
    }
    let target = if kind == R::SshHost && !input.contains("://") {
        format!("ssh://{input}")
    } else {
        input.to_owned()
    };
    let url = url::Url::parse(&target).map_err(|_| VaultFailure::Unsupported)?;
    let allowed = match kind {
        R::WebApp | R::RestEndpoint | R::PackageRegistry | R::ContainerRegistry => {
            matches!(url.scheme(), "https" | "http")
        }
        R::SshHost => {
            url.scheme() == "ssh"
                && (url.path().is_empty() || url.path() == "/")
                && url.query().is_none()
        }
        R::GitRepository => matches!(url.scheme(), "https" | "ssh") && url.path().len() > 1,
        R::Database => matches!(
            url.scheme(),
            "postgres"
                | "postgresql"
                | "mysql"
                | "mariadb"
                | "mongodb"
                | "mongodb+srv"
                | "redis"
                | "rediss"
                | "mssql"
                | "oracle"
        ),
        R::KubernetesContext => false,
    };
    if !allowed
        || url.host_str().is_none()
        || url.password().is_some()
        || url.fragment().is_some()
        || (!url.username().is_empty() && url.scheme() != "ssh")
    {
        return Err(VaultFailure::Unsupported);
    }
    Ok(url.into())
}

pub struct CustomValueInputV1 {
    pub field_id: String,
    pub value: String,
    pub file: Option<AttachmentInputV1>,
    pub keep_file: bool,
}
pub struct CustomValueViewV1 {
    pub field_id: String,
    pub value: String,
    pub file: Option<AttachmentSummaryV1>,
}
pub struct CustomCardInputV1 {
    pub id: Option<String>,
    pub name: String,
    pub description: String,
    pub service: String,
    pub environment: Option<super::EnvironmentV1>,
    pub group_ids: Vec<String>,
    pub template_id: String,
    pub template_version: u32,
    pub accept_template_update: bool,
    pub values: Vec<CustomValueInputV1>,
}
pub struct HistorySummaryV1 {
    pub id: String,
    pub at: i64,
    pub card_id: String,
    pub name: String,
    pub service: String,
}
pub struct HistoricalCardV1 {
    pub summary: CardSummaryV1,
    pub description: String,
    pub fields: Vec<CardValueV1>,
    pub custom_values: Vec<CustomValueViewV1>,
    pub bindings: Vec<ResourceBindingV1>,
    pub attachment: Option<AttachmentSummaryV1>,
}
