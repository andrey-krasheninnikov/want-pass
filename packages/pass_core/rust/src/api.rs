pub(crate) mod v2;
pub(crate) mod v3;
use crate::{
    format::{self, Opened, Prepared},
    storage::{Store, digest},
};
use flutter_rust_bridge::frb;
use std::{
    path::Path,
    sync::{
        Mutex,
        atomic::{AtomicU64, Ordering},
    },
};
pub use v2::{RecoveryChallengeV2, VaultHintsV2};
use zeroize::Zeroizing;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum VaultFailure {
    Credentials,
    InvalidPassword,
    InvalidPhrase,
    Confirmation,
    Exists,
    Missing,
    Locked,
    Busy,
    Unsupported,
    Corrupt,
    Storage,
    Stale,
    Closed,
    Unavailable,
    WriteUncertain,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum VaultStatus {
    Missing,
    Locked,
    Unlocked,
    Confirmation,
}

pub struct RecoveryChallenge {
    pub words: Vec<String>,
    pub positions: Vec<u32>,
}
struct Draft {
    prepared: Prepared,
    positions: Vec<u32>,
    expected: Option<[u8; 32]>,
}
struct State {
    store: Store,
    active: Option<Opened>,
    draft: Option<Draft>,
    draft_v2: Option<v2::DraftV2>,
    closed: bool,
}

#[frb(opaque)]
pub struct Vault {
    state: Mutex<State>,
    job: Mutex<()>,
    export_publication: Mutex<()>,
    epoch: AtomicU64,
}

impl Vault {
    #[frb(sync)]
    pub fn generation(&self) -> u64 {
        self.epoch.load(Ordering::SeqCst)
    }

    pub fn open(directory: String) -> Result<Self, VaultFailure> {
        let store = Store::open(Path::new(&directory))?;
        Ok(Self {
            state: Mutex::new(State {
                store,
                active: None,
                draft: None,
                draft_v2: None,
                closed: false,
            }),
            job: Mutex::new(()),
            export_publication: Mutex::new(()),
            epoch: AtomicU64::new(0),
        })
    }
    pub fn status(&self) -> Result<VaultStatus, VaultFailure> {
        let state = self.state.lock().map_err(|_| VaultFailure::Unavailable)?;
        if state.closed {
            return Err(VaultFailure::Closed);
        }
        if state.draft.is_some() || state.draft_v2.is_some() {
            return Ok(VaultStatus::Confirmation);
        }
        if state.active.is_some() {
            return Ok(VaultStatus::Unlocked);
        }
        Ok(if state.store.read()?.is_some() {
            VaultStatus::Locked
        } else {
            VaultStatus::Missing
        })
    }
    pub fn prepare_creation(
        &self,
        password: String,
        generation: u64,
    ) -> Result<RecoveryChallenge, VaultFailure> {
        let password = Zeroizing::new(password);
        let _job = self.job.try_lock().map_err(|_| VaultFailure::Busy)?;
        let epoch = generation;
        if self.epoch.load(Ordering::SeqCst) != epoch {
            return Err(VaultFailure::Stale);
        }
        {
            let state = self.state.lock().map_err(|_| VaultFailure::Unavailable)?;
            if state.closed {
                return Err(VaultFailure::Closed);
            }
            if state.store.read()?.is_some() {
                return Err(VaultFailure::Exists);
            }
            if state.draft.is_some() || state.draft_v2.is_some() {
                return Err(VaultFailure::Busy);
            }
        }
        let prepared = format::prepare(&password, &[], None)?;
        let words = format::words(prepared.entropy.as_ref())?;
        let mut positions = std::collections::BTreeSet::new();
        while positions.len() < 3 {
            positions.insert(u32::from(format::random::<1>()?[0] % 24));
        }
        let positions: Vec<u32> = positions.into_iter().collect();
        let mut state = self.state.lock().map_err(|_| VaultFailure::Unavailable)?;
        if state.closed || self.epoch.load(Ordering::SeqCst) != epoch {
            return Err(VaultFailure::Stale);
        }
        state.draft = Some(Draft {
            prepared,
            positions: positions.clone(),
            expected: None,
        });
        Ok(RecoveryChallenge { words, positions })
    }
    pub fn prepare_recovery(
        &self,
        phrase: String,
        password: String,
        generation: u64,
    ) -> Result<RecoveryChallenge, VaultFailure> {
        let phrase = Zeroizing::new(phrase);
        let password = Zeroizing::new(password);
        let _job = self.job.try_lock().map_err(|_| VaultFailure::Busy)?;
        let epoch = generation;
        if self.epoch.load(Ordering::SeqCst) != epoch {
            return Err(VaultFailure::Stale);
        }
        let bytes = {
            let state = self.state.lock().map_err(|_| VaultFailure::Unavailable)?;
            if state.closed {
                return Err(VaultFailure::Closed);
            }
            if state.draft.is_some() || state.draft_v2.is_some() {
                return Err(VaultFailure::Busy);
            }
            state.store.read()?.ok_or(VaultFailure::Missing)?
        };
        let opened = format::open_recovery(&bytes, &phrase)?;
        let prepared = format::prepare(&password, &opened.document, Some(opened.id))?;
        let words = format::words(prepared.entropy.as_ref())?;
        let mut positions = std::collections::BTreeSet::new();
        while positions.len() < 3 {
            positions.insert(u32::from(format::random::<1>()?[0] % 24));
        }
        let positions: Vec<u32> = positions.into_iter().collect();
        let mut state = self.state.lock().map_err(|_| VaultFailure::Unavailable)?;
        if state.closed || self.epoch.load(Ordering::SeqCst) != epoch {
            return Err(VaultFailure::Stale);
        }
        state.active = None;
        state.draft = Some(Draft {
            prepared,
            positions: positions.clone(),
            expected: Some(digest(&bytes)),
        });
        Ok(RecoveryChallenge { words, positions })
    }
    pub fn confirm(&self, answers: Vec<String>, generation: u64) -> Result<(), VaultFailure> {
        let answers = answers.into_iter().map(Zeroizing::new).collect::<Vec<_>>();
        let _job = self.job.try_lock().map_err(|_| VaultFailure::Busy)?;
        let mut state = self.state.lock().map_err(|_| VaultFailure::Unavailable)?;
        if self.epoch.load(Ordering::SeqCst) != generation {
            return Err(VaultFailure::Stale);
        }
        if state.closed {
            return Err(VaultFailure::Closed);
        }
        let draft = state.draft.as_ref().ok_or(VaultFailure::Confirmation)?;
        let words = format::words(draft.prepared.entropy.as_ref())?
            .into_iter()
            .map(Zeroizing::new)
            .collect::<Vec<_>>();
        if answers.len() != 3
            || answers
                .iter()
                .zip(&draft.positions)
                .any(|(answer, position)| answer.trim() != words[*position as usize].as_str())
        {
            return Err(VaultFailure::Confirmation);
        }
        state.store.commit(&draft.prepared.bytes, draft.expected)?;
        let draft = state.draft.take().ok_or(VaultFailure::Confirmation)?;
        state.active = Some(draft.prepared.opened);
        Ok(())
    }
    pub fn unlock(&self, password: String, generation: u64) -> Result<(), VaultFailure> {
        let password = Zeroizing::new(password);
        let _job = self.job.try_lock().map_err(|_| VaultFailure::Busy)?;
        let epoch = generation;
        if self.epoch.load(Ordering::SeqCst) != epoch {
            return Err(VaultFailure::Stale);
        }
        let bytes = {
            let state = self.state.lock().map_err(|_| VaultFailure::Unavailable)?;
            if state.closed {
                return Err(VaultFailure::Closed);
            }
            if state.active.is_some() {
                return Ok(());
            }
            if state.draft.is_some() || state.draft_v2.is_some() {
                return Err(VaultFailure::Busy);
            }
            state.store.read()?.ok_or(VaultFailure::Missing)?
        };
        let opened = format::open_password(&bytes, &password)?;
        let mut state = self.state.lock().map_err(|_| VaultFailure::Unavailable)?;
        if state.closed || self.epoch.load(Ordering::SeqCst) != epoch {
            return Err(VaultFailure::Stale);
        }
        if state.store.read()?.as_deref().map(digest) != Some(digest(&bytes)) {
            return Err(VaultFailure::Stale);
        }
        state.active = Some(opened);
        Ok(())
    }
    // Invalidate keys immediately; await wait_for_exports_v2 before reporting completion.
    #[frb(sync)]
    pub fn lock(&self) -> Result<(), VaultFailure> {
        self.epoch.fetch_add(1, Ordering::SeqCst);
        let mut state = self.state.lock().map_err(|_| VaultFailure::Unavailable)?;
        if state.closed {
            return Err(VaultFailure::Closed);
        }
        state.active = None;
        state.draft = None;
        state.draft_v2 = None;
        Ok(())
    }
    pub fn close(&self) -> Result<(), VaultFailure> {
        self.epoch.fetch_add(1, Ordering::SeqCst);
        let mut state = self.state.lock().map_err(|_| VaultFailure::Unavailable)?;
        let closed = if !state.closed {
            state.active = None;
            state.draft = None;
            state.draft_v2 = None;
            state.closed = true;
            state.store.close()
        } else {
            Ok(())
        };
        drop(state);
        let publication = self.wait_for_exports_v2();
        closed.and(publication)
    }
}
