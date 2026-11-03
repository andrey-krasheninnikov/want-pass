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
  FutureDomainResult<void> unlockV1({
    required VaultHandleV1 handle,
    required String password,
  });
}
