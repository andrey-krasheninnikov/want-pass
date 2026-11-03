import 'package:domain_error/domain_error.dart';
import 'package:want_pass_core/src/feature/vault/application/_barrel.dart';
import 'package:want_pass_core/src/feature/vault/domain/_barrel.dart';

abstract interface class VaultAccessService {
  const VaultAccessService();
  FutureDomainResult<VaultHandleV1> openV1();
  FutureDomainResult<VaultAccessStateV1> statusV1({
    required VaultHandleV1 handle,
  });
  FutureDomainResult<VaultRecoveryChallengeV1> prepareCreationV1({
    required VaultHandleV1 handle,
    required String password,
  });
  FutureDomainResult<VaultRecoveryChallengeV1> prepareRecoveryV1({
    required VaultHandleV1 handle,
    required String phrase,
    required String password,
  });
  FutureDomainResult<void> confirmV1({
    required VaultHandleV1 handle,
    required List<String> answers,
  });
  FutureDomainResult<bool> validatePasswordV3({required String password});
  FutureDomainResult<void> unlockV3({
    required VaultHandleV1 handle,
    required String password,
  });
  FutureDomainResult<void> unlockV1({
    required VaultHandleV1 handle,
    required String password,
  });
  FutureDomainResult<VaultHintsDtoV2> hintsV2({required VaultHandleV1 handle});
  FutureDomainResult<VaultRecoveryChallengeV2> prepareCreationV2({
    required VaultHandleV1 handle,
    required String password,
  });
  FutureDomainResult<VaultRecoveryChallengeV2> prepareRecoveryV2({
    required VaultHandleV1 handle,
    required String phrase,
    required String password,
  });
  FutureDomainResult<void> confirmV2({
    required VaultHandleV1 handle,
    required List<String> answers,
    required String password,
    required VaultHintsDtoV2 hints,
  });
  FutureDomainResult<void> waitForExportsV2({required VaultHandleV1 handle});
  FutureDomainResult<void> exportRecoveryV2({
    required VaultHandleV1 handle,
    required String destination,
  });
  FutureDomainResult<void> validateRecoveryV3({
    required VaultHandleV1 handle,
    required String phrase,
  });
  FutureDomainResult<VaultRecoveryChallengeV3> prepareCreationV3({
    required VaultHandleV1 handle,
    required String password,
  });
  FutureDomainResult<VaultRecoveryChallengeV3> prepareRecoveryV3({
    required VaultHandleV1 handle,
    required String phrase,
    required String password,
  });
  FutureDomainResult<VaultRecoveryChallengeV3> regenerateRecoveryV3({
    required VaultHandleV1 handle,
  });
  FutureDomainResult<void> exportRecoveryV3({
    required VaultHandleV1 handle,
    required String destination,
    required BigInt revision,
  });
  FutureDomainResult<void> confirmV3({
    required VaultHandleV1 handle,
    required List<String> answers,
    required String password,
    required VaultHintsDtoV2 hints,
    required BigInt revision,
  });
}
