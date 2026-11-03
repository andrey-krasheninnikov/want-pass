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
  FutureDomainResult<PrepareVaultSetupResultV2> prepareSetupV2({
    required PrepareVaultSetupParamsV2 params,
  });
  FutureDomainResult<ConfirmVaultSetupResultV2> confirmSetupV2({
    required ConfirmVaultSetupParamsV2 params,
  });
  FutureDomainResult<ReadVaultHintsResultV2> readHintsV2({
    required ReadVaultHintsParamsV2 params,
  });
  FutureDomainResult<SelectRecoveryFileResultV1> selectRecoveryFileV1({
    required SelectRecoveryFileParamsV1 params,
  });
  FutureDomainResult<RecoveryExportResultV1> exportRecoveryV2({
    required ExportRecoveryParamsV2 params,
  });
  FutureDomainResult<RecoveryExportResultV1> copyRecoveryV1({
    required RecoveryClipboardParamsV1 params,
  });
  FutureDomainResult<RecoveryExportResultV1> clearRecoveryClipboardV1({
    required RecoveryClipboardParamsV1 params,
  });
}
