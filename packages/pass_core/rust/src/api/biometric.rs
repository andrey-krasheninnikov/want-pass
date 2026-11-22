use super::{Vault, VaultFailure};

pub(super) fn retire(store: &crate::storage::Store, previous: &[u8]) -> Result<(), VaultFailure> {
    #[cfg(target_os = "macos")]
    {
        if let Ok(service) = store.biometric_service() {
            let account = crate::format::device_account(previous)?;
            return keychain::retire(service, &account);
        }
    }
    let _ = (store, previous);
    Ok(())
}

impl Vault {
    pub(super) fn commit_credentials(
        store: &crate::storage::Store,
        bytes: &[u8],
        expected: Option<[u8; 32]>,
    ) -> Result<(), VaultFailure> {
        if let Some(expected) = expected {
            let previous = store.read()?.ok_or(VaultFailure::Missing)?;
            if crate::storage::digest(&previous) != expected {
                return Err(VaultFailure::Stale);
            }
            retire(store, &previous)?;
        }
        store.commit(bytes, expected)
    }

    pub fn biometric_enabled_v1(&self, generation: u64) -> Result<bool, VaultFailure> {
        #[cfg(target_os = "macos")]
        {
            let state = self.state.lock().map_err(|_| VaultFailure::Unavailable)?;
            if state.closed || self.generation() != generation {
                return Err(VaultFailure::Stale);
            }
            let bytes = state.store.read()?.ok_or(VaultFailure::Missing)?;
            let (service, account) = keychain::identity(&state.store, &bytes)?;
            keychain::registered(service, &account)
        }
        #[cfg(not(target_os = "macos"))]
        {
            let _ = generation;
            Ok(false)
        }
    }

    pub fn unlock_biometric_v1(&self, generation: u64) -> Result<(), VaultFailure> {
        #[cfg(target_os = "macos")]
        {
            self.unlock_with(generation, |bytes, store| {
                let (service, account) = keychain::identity(store, bytes)?;
                let key = keychain::read(service, &account)?;
                crate::format::open_key(bytes, key)
            })
        }
        #[cfg(not(target_os = "macos"))]
        {
            let _ = generation;
            Err(VaultFailure::Unavailable)
        }
    }

    pub fn configure_biometric_v1(
        &self,
        enable: bool,
        generation: u64,
    ) -> Result<(), VaultFailure> {
        #[cfg(target_os = "macos")]
        {
            self.require_operation(super::OperationV1::Protection, "biometric", generation)?;
            let _job = self.job.try_lock().map_err(|_| VaultFailure::Busy)?;
            let (service, account, key) = {
                let state = self.state.lock().map_err(|_| VaultFailure::Unavailable)?;
                if state.closed || self.generation() != generation {
                    return Err(VaultFailure::Stale);
                }
                let active = state.active.as_ref().ok_or(VaultFailure::Locked)?;
                let bytes = state.store.read()?.ok_or(VaultFailure::Missing)?;
                let (service, account) = keychain::identity(&state.store, &bytes)?;
                (service, account, active.key.clone())
            };
            if !enable {
                return keychain::remove(service, &account);
            }
            if keychain::registered(service, &account)? {
                return Err(VaultFailure::Exists);
            }
            keychain::add(service, &account, key.as_ref())?;
            let verified = keychain::read(service, &account).and_then(|retrieved| {
                if retrieved.as_slice() != key.as_ref() {
                    return Err(VaultFailure::Credentials);
                }
                let state = self.state.lock().map_err(|_| VaultFailure::Unavailable)?;
                if self.generation() != generation || state.active.is_none() || state.closed {
                    return Err(VaultFailure::Stale);
                }
                Ok(())
            });
            if verified.is_err() {
                keychain::remove(service, &account)?;
            }
            verified
        }
        #[cfg(not(target_os = "macos"))]
        {
            let _ = (enable, generation);
            Err(VaultFailure::Unavailable)
        }
    }
}

#[cfg(all(test, target_os = "macos"))]
mod tests {
    use super::*;
    use crate::{api::VaultStatus, format};
    use zeroize::Zeroizing;

    #[test]
    fn device_unlock_checks_generation_after_prompt_and_stays_locked_on_rejection() {
        let directory = tempfile::tempdir().unwrap();
        let password = "Synthetic device test password 2026!";
        let vault = Vault::open(directory.path().join("vault").to_str().unwrap().into()).unwrap();
        let draft = vault
            .prepare_creation(password.into(), vault.generation())
            .unwrap();
        vault
            .confirm(
                draft
                    .positions
                    .iter()
                    .map(|n| draft.words[*n as usize].clone())
                    .collect(),
                vault.generation(),
            )
            .unwrap();
        let key = vault
            .state
            .lock()
            .unwrap()
            .active
            .as_ref()
            .unwrap()
            .key
            .clone();
        vault.lock().unwrap();
        let generation = vault.generation();
        assert_eq!(
            vault.unlock_with(generation, |_, _| Err(VaultFailure::Credentials)),
            Err(VaultFailure::Credentials)
        );
        assert_eq!(vault.status().unwrap(), VaultStatus::Locked);
        let result = vault.unlock_with(generation, |bytes, _| {
            vault.lock()?;
            format::open_key(bytes, Zeroizing::new(key.to_vec()))
        });
        assert_eq!(result, Err(VaultFailure::Stale));
        assert_eq!(vault.status().unwrap(), VaultStatus::Locked);
        // Test directories must never acquire access to the real device keychain.
        assert_eq!(
            vault.biometric_enabled_v1(vault.generation()),
            Err(VaultFailure::Unavailable)
        );
        vault.unlock(password.into(), vault.generation()).unwrap();
        assert_eq!(vault.status().unwrap(), VaultStatus::Unlocked);
    }
}

#[cfg(target_os = "macos")]
mod keychain {
    use crate::{api::VaultFailure, format, storage::Store};
    use security_framework::{
        access_control::{ProtectionMode, SecAccessControl},
        item::{ItemClass, ItemSearchOptions},
        passwords::{self, AccessControlOptions, PasswordOptions},
    };
    use zeroize::Zeroizing;

    pub(super) fn identity(
        store: &Store,
        bytes: &[u8],
    ) -> Result<(&'static str, String), VaultFailure> {
        Ok((store.biometric_service()?, format::device_account(bytes)?))
    }
    fn options(service: &str, account: &str) -> PasswordOptions {
        let mut options = PasswordOptions::new_generic_password(service, account);
        options.use_protected_keychain();
        options.set_access_synchronized(Some(false));
        options
    }
    fn failure(error: security_framework::base::Error) -> VaultFailure {
        match error.code() {
            -128 | -25293 | -25300 => VaultFailure::Credentials,
            _ => VaultFailure::Unavailable,
        }
    }
    pub(super) fn registered(service: &str, account: &str) -> Result<bool, VaultFailure> {
        match ItemSearchOptions::new()
            .ignore_legacy_keychains()
            .class(ItemClass::generic_password())
            .service(service)
            .account(account)
            .search()
        {
            Ok(_) => Ok(true),
            Err(error) if error.code() == -25300 => Ok(false),
            Err(error) => Err(failure(error)),
        }
    }
    pub(super) fn add(service: &str, account: &str, key: &[u8]) -> Result<(), VaultFailure> {
        let acl = SecAccessControl::create_with_protection(
            Some(ProtectionMode::AccessibleWhenUnlockedThisDeviceOnly),
            AccessControlOptions::BIOMETRY_CURRENT_SET.bits(),
        )
        .map_err(failure)?;
        let mut options = options(service, account);
        options.set_access_control(acl);
        passwords::set_generic_password_options(key, options).map_err(failure)
    }
    pub(super) fn read(service: &str, account: &str) -> Result<Zeroizing<Vec<u8>>, VaultFailure> {
        passwords::generic_password(options(service, account))
            .map(Zeroizing::new)
            .map_err(failure)
    }
    pub(super) fn retire(service: &str, account: &str) -> Result<(), VaultFailure> {
        match passwords::delete_generic_password_options(options(service, account)) {
            // A development build without a signing team cannot own protected items.
            Err(error)
                if error.code() == -34018 && service == "foundation.want.pass.dev.biometric" =>
            {
                Ok(())
            }
            Ok(()) => Ok(()),
            Err(error) if error.code() == -25300 => Ok(()),
            Err(error) => Err(failure(error)),
        }
    }
    pub(super) fn remove(service: &str, account: &str) -> Result<(), VaultFailure> {
        match passwords::delete_generic_password_options(options(service, account)) {
            Ok(()) => Ok(()),
            Err(error) if error.code() == -25300 => Ok(()),
            Err(error) => Err(failure(error)),
        }
    }
}
