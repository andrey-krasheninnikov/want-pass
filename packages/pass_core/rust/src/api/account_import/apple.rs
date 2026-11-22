use super::{ImportRow, MAX_ROWS};
use crate::api::{CardTypeV1, CardValueV1, FieldIdV1, ResourceBindingV1, VaultFailure};
use std::collections::BTreeMap;

pub(super) fn parse(input: &str) -> Result<Vec<ImportRow>, VaultFailure> {
    let input = input.strip_prefix('\u{feff}').unwrap_or(input);
    check_quotes(input.as_bytes())?;
    let mut reader = csv::ReaderBuilder::new().from_reader(input.as_bytes());
    let headers = reader.headers().map_err(|_| VaultFailure::Unsupported)?;
    let mut columns = BTreeMap::new();
    for (index, name) in headers.iter().enumerate() {
        let name = name.trim().to_ascii_lowercase();
        if !matches!(
            name.as_str(),
            "title" | "url" | "username" | "password" | "notes" | "otpauth"
        ) || columns.insert(name, index).is_some()
        {
            return Err(VaultFailure::Unsupported);
        }
    }
    let index = |name: &str| columns.get(name).copied().ok_or(VaultFailure::Unsupported);
    let (title, url, login, password) = (
        index("title")?,
        index("url")?,
        index("username")?,
        index("password")?,
    );
    let mut rows = Vec::new();
    for record in reader.records() {
        let record = record.map_err(|_| VaultFailure::Unsupported)?;
        if rows.len() == MAX_ROWS {
            return Err(VaultFailure::Unsupported);
        }
        let target = record[url].trim();
        let target = (!target.is_empty())
            .then(|| ResourceBindingV1::web_target(target))
            .transpose()?;
        let title = record[title].trim();
        let name = if title.is_empty() {
            target
                .as_ref()
                .and_then(|url| url::Url::parse(url).ok())
                .and_then(|url| url.host_str().map(str::to_owned))
                .ok_or(VaultFailure::Unsupported)?
        } else {
            title.to_owned()
        };
        rows.push(ImportRow {
            name,
            notes: columns.get("notes").map_or("", |i| &record[*i]).into(),
            url: target,
            kind: CardTypeV1::Account,
            fields: vec![
                CardValueV1 {
                    id: FieldIdV1::Login,
                    value: record[login].into(),
                },
                CardValueV1 {
                    id: FieldIdV1::Password,
                    value: record[password].into(),
                },
            ],
        });
    }
    Ok(rows)
}

// The csv reader accepts a dangling quote at EOF; avoid importing truncated password exports.
fn check_quotes(input: &[u8]) -> Result<(), VaultFailure> {
    #[derive(Clone, Copy)]
    enum Field {
        Start,
        Plain,
        Quoted,
        AfterQuote,
    }
    let mut field = Field::Start;
    for b in input {
        field = match (field, b) {
            (Field::Start, b'"') => Field::Quoted,
            (Field::Quoted, b'"') => Field::AfterQuote,
            (Field::Quoted, _) => Field::Quoted,
            (Field::AfterQuote, b'"') => Field::Quoted,
            (_, b',' | b'\r' | b'\n') => Field::Start,
            (Field::AfterQuote, _) | (Field::Plain, b'"') => return Err(VaultFailure::Unsupported),
            _ => Field::Plain,
        };
    }
    if matches!(field, Field::Quoted) {
        Err(VaultFailure::Unsupported)
    } else {
        Ok(())
    }
}
