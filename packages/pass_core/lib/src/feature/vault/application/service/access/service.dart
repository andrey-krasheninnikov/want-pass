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
  FutureDomainResult<ContentSnapshotV1> contentV1({
    required VaultHandleV1 handle,
  });
  FutureDomainResult<ContentSnapshotV1> saveGroupV1({
    required VaultHandleV1 handle,
    required GroupDraftV1 input,
    required BigInt revision,
  });
  FutureDomainResult<ContentSnapshotV1> deleteGroupV1({
    required VaultHandleV1 handle,
    required String id,
    required BigInt revision,
  });
  FutureDomainResult<AccountV1> accountV1({
    required VaultHandleV1 handle,
    required String id,
  });
  FutureDomainResult<ContentSnapshotV1> saveAccountV1({
    required VaultHandleV1 handle,
    required AccountDraftV1 input,
    required BigInt revision,
  });
  FutureDomainResult<ContentSnapshotV1> deleteAccountV1({
    required VaultHandleV1 handle,
    required String id,
    required BigInt revision,
  });
  FutureDomainResult<CardCatalogV1> cardCatalogV1();
  FutureDomainResult<ContentSnapshotV2> contentV2({
    required VaultHandleV1 handle,
  });
  FutureDomainResult<ContentSnapshotV2> saveGroupV2({
    required VaultHandleV1 handle,
    required GroupDraftV1 input,
    required BigInt revision,
  });
  FutureDomainResult<ContentSnapshotV2> deleteGroupV2({
    required VaultHandleV1 handle,
    required String id,
    required BigInt revision,
  });
  FutureDomainResult<CardV1> cardV1({
    required VaultHandleV1 handle,
    required String id,
  });
  FutureDomainResult<ContentSnapshotV2> saveCardV1({
    required VaultHandleV1 handle,
    required CardDraftV1 input,
    required BigInt revision,
  });
  FutureDomainResult<ContentSnapshotV2> deleteCardV1({
    required VaultHandleV1 handle,
    required String id,
    required BigInt revision,
  });
  FutureDomainResult<TotpCodeV1> currentTotpV1({
    required VaultHandleV1 handle,
    required String id,
  });
  FutureDomainResult<String> copyAccountV1({
    required VaultHandleV1 handle,
    required String id,
  });
  FutureDomainResult<void> exportAttachmentV1({
    required VaultHandleV1 handle,
    required String id,
    required String destination,
    required BigInt revision,
  });
}
