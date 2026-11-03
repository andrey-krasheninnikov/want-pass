import 'package:domain_error/domain_error.dart';
import 'package:want_pass/src/feature/vault/application/_barrel.dart';

abstract interface class VaultUseCase {
  const VaultUseCase();
  FutureDomainResult<InitializeVaultResultV1> initializeV1({
    required InitializeVaultParamsV1 params,
  });
  FutureDomainResult<PrepareVaultCreationResultV1> prepareCreationV1({
    required PrepareVaultCreationParamsV1 params,
  });
  FutureDomainResult<ConfirmVaultCreationResultV1> confirmCreationV1({
    required ConfirmVaultCreationParamsV1 params,
  });
  FutureDomainResult<UnlockVaultResultV1> unlockV1({
    required UnlockVaultParamsV1 params,
  });
  FutureDomainResult<LockVaultResultV1> lockV1({
    required LockVaultParamsV1 params,
  });
  FutureDomainResult<PrepareVaultRecoveryResultV1> prepareRecoveryV1({
    required PrepareVaultRecoveryParamsV1 params,
  });
  FutureDomainResult<ConfirmVaultRecoveryResultV1> confirmRecoveryV1({
    required ConfirmVaultRecoveryParamsV1 params,
  });
  FutureDomainResult<CloseVaultResultV1> closeV1({
    required CloseVaultParamsV1 params,
  });
}
