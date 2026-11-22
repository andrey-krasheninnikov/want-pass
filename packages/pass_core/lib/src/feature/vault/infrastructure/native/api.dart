// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import 'package:want_pass_core/src/feature/vault/infrastructure/_barrel.dart';

import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

// These functions are ignored because they are not marked as `pub`: `clear_active`, `from_store`, `unlock_with`
// These types are ignored because they are neither used by any `pub` functions nor (for structs and enums) marked `#[frb(unignore)]`: `Draft`, `State`
// These function are ignored because they are on traits that is not defined in current crate (put an empty `#[frb]` on it to unignore): `assert_receiver_is_total_eq`, `assert_receiver_is_total_eq`, `clone`, `clone`, `eq`, `eq`, `fmt`, `fmt`

// Rust type: RustOpaqueMoi<flutter_rust_bridge::for_generated::RustAutoOpaqueInner<Vault>>
abstract class Vault implements RustOpaqueInterface {
  Future<AccountRecordV1> accountV1({
    required String id,
    required BigInt generation,
  });

  Future<ContentSnapshotV2> applyAccountImportV1({
    required String token,
    required List<int> selected,
    required BigInt generation,
  });

  Future<void> applyBackupV1({
    required String source,
    required String phrase,
    required BackupStrategyV1 strategy,
    required List<BackupChoiceV1> choices,
    required BigInt revision,
    required String fingerprint,
    required BigInt generation,
  });

  Future<void> authorizeOperationV1({
    required OperationV1 action,
    required String subject,
    required String code,
    required BigInt generation,
  });

  Future<String> beginExternalTotpV1({required BigInt generation});

  Future<List<ResourceBindingV1>> bindingsV1({
    required String id,
    required BigInt revision,
    required BigInt generation,
  });

  Future<bool> biometricEnabledV1({required BigInt generation});

  Future<void> cancelAccountImportV1({
    required String token,
    required BigInt generation,
  });

  Future<List<CardListRowV1>> cardListRowsV1({
    required List<String> ids,
    required BigInt revision,
    required BigInt generation,
  });

  Future<CardPreviewV1> cardPreviewV1({
    required String id,
    required BigInt revision,
    required BigInt generation,
  });

  Future<List<CardRowV1>> cardRowsV1({
    required List<String> ids,
    required BigInt revision,
    required BigInt generation,
  });

  Future<CardRecordV1> cardV1({required String id, required BigInt generation});

  Future<ContentSnapshotV2> clearHistoryV1({
    String? cardId,
    required bool confirmed,
    required BigInt revision,
    required BigInt generation,
  });

  Future<void> close();

  Future<void> configureBiometricV1({
    required bool enable,
    required BigInt generation,
  });

  Future<void> configureExternalTotpV1({
    required String code,
    required List<OperationV1> operations,
    required bool disable,
    required BigInt generation,
  });

  Future<void> confirm({
    required List<String> answers,
    required BigInt generation,
  });

  Future<void> confirmV2({
    required List<String> answers,
    required String password,
    required String passwordHint,
    required String recoveryHint,
    required BigInt generation,
  });

  Future<void> confirmV3({
    required List<String> answers,
    required String password,
    required String passwordHint,
    required String recoveryHint,
    required BigInt revision,
  });

  Future<ContentSnapshotV1> contentV1({required BigInt generation});

  Future<ContentSnapshotV2> contentV2({required BigInt generation});

  Future<String> copyAccountV1({
    required String id,
    required BigInt generation,
  });

  Future<String> copyCardFieldV1({
    required String id,
    required FieldIdV1 field,
    required BigInt generation,
  });

  Future<TotpCodeV1> copyCurrentTotpV1({
    required String id,
    required BigInt generation,
  });

  Future<String> copyQuickCardV1({
    required String id,
    required BigInt revision,
    required BigInt generation,
  });

  Future<TotpCodeV1> currentTotpV1({
    required String id,
    required BigInt generation,
  });

  Future<List<CustomValueViewV1>> customCardValuesV1({
    required String id,
    required BigInt revision,
    required BigInt generation,
  });

  Future<String> customFieldValueV1({
    required String id,
    required String fieldId,
    required bool copy,
    required BigInt revision,
    required BigInt generation,
  });

  Future<ContentSnapshotV1> deleteAccountV1({
    required String id,
    required BigInt revision,
    required BigInt generation,
  });

  Future<ContentSnapshotV2> deleteCardV1({
    required String id,
    required BigInt revision,
    required BigInt generation,
  });

  Future<ContentSnapshotV1> deleteGroupV1({
    required String id,
    required BigInt revision,
    required BigInt generation,
  });

  Future<ContentSnapshotV2> deleteGroupV2({
    required String id,
    required BigInt revision,
    required BigInt generation,
  });

  Future<void> enrollExternalTotpV1({
    required String code,
    required List<OperationV1> operations,
    required BigInt generation,
  });

  Future<void> exportAttachmentV1({
    required String id,
    required String destination,
    required BigInt revision,
    required BigInt generation,
  });

  Future<void> exportBackupV1({
    required String destination,
    required BigInt revision,
    required BigInt generation,
  });

  Future<void> exportCustomFileV1({
    required String id,
    required String fieldId,
    required String destination,
    required BigInt revision,
    required BigInt generation,
  });

  Future<void> exportRecoveryV2({
    required String destination,
    required BigInt generation,
  });

  Future<void> exportRecoveryV3({
    required String destination,
    required BigInt revision,
  });

  BigInt generation();

  Future<VaultHintsV2> hintsV2();

  Future<HistoricalCardV1> historicalCardV1({
    required String id,
    required BigInt revision,
    required BigInt generation,
  });

  Future<List<HistorySummaryV1>> historyV1({
    String? cardId,
    required BigInt revision,
    required BigInt generation,
  });

  Future<String> localToolsV1({
    required LocalToolCommandV1 command,
    required String body,
    required BigInt generation,
  });

  void lock();

  Future<HotpAdvanceV1> nextHotpV1({
    required String id,
    required BigInt revision,
    required BigInt generation,
  });

  static Future<Vault> open({required String directory}) =>
      VaultRustLib.instance.api.crateApiVaultOpen(directory: directory);

  static Future<Vault> openApplicationV1({required String directory}) =>
      VaultRustLib.instance.api.crateApiVaultOpenApplicationV1(
        directory: directory,
      );

  Future<AccountImportPreviewV1> prepareAccountImportV1({
    required AccountImportSourceV1 source,
    required List<String> payloads,
    required BigInt revision,
    required BigInt generation,
  });

  Future<RecoveryChallenge> prepareCreation({
    required String password,
    required BigInt generation,
  });

  Future<RecoveryChallengeV2> prepareCreationV2({
    required String password,
    required BigInt generation,
  });

  Future<RecoveryChallengeV3> prepareCreationV3({
    required String password,
    required BigInt generation,
  });

  Future<RecoveryChallenge> prepareRecovery({
    required String phrase,
    required String password,
    required BigInt generation,
  });

  Future<RecoveryChallengeV2> prepareRecoveryV2({
    required String phrase,
    required String password,
    required BigInt generation,
  });

  Future<RecoveryChallengeV3> prepareRecoveryV3({
    required String phrase,
    required String password,
    required BigInt generation,
  });

  Future<BackupPreviewV1> previewBackupV1({
    required String source,
    required String phrase,
    required BackupStrategyV1 strategy,
    required List<BackupChoiceV1> choices,
    required BigInt generation,
  });

  Future<ProtectionSettingsV1> protectionSettingsV1({
    required BigInt generation,
  });

  Future<RecoveryChallengeV3> regenerateRecoveryV3({
    required BigInt generation,
  });

  Future<ContentSnapshotV2> removeServiceV1({
    required String id,
    String? replacement,
    required bool preserve,
    required BigInt revision,
    required BigInt generation,
  });

  Future<void> resetApplicationV1({
    required String phrase,
    required BigInt generation,
  });

  Future<ContentSnapshotV2> restoreHistoryV1({
    required String id,
    required BigInt revision,
    required BigInt generation,
  });

  Future<String> revealCardFieldV1({
    required String id,
    required FieldIdV1 field,
    required BigInt generation,
  });

  Future<ContentSnapshotV1> saveAccountV1({
    required AccountInputV1 input,
    required BigInt revision,
    required BigInt generation,
  });

  Future<ContentSnapshotV2> saveBindingsV1({
    required String id,
    required List<ResourceBindingV1> bindings,
    required BigInt revision,
    required BigInt generation,
  });

  Future<ContentSnapshotV2> saveCardV1({
    required CardInputV1 input,
    required BigInt revision,
    required BigInt generation,
  });

  Future<ContentSnapshotV2> saveCustomCardV1({
    required CustomCardInputV1 input,
    required BigInt revision,
    required BigInt generation,
  });

  Future<ContentSnapshotV1> saveGroupV1({
    required GroupInputV1 input,
    required BigInt revision,
    required BigInt generation,
  });

  Future<ContentSnapshotV2> saveGroupV2({
    required GroupInputV1 input,
    required BigInt revision,
    required BigInt generation,
  });

  Future<ContentSnapshotV2> saveServiceV1({
    required ServiceDefinitionV1 service,
    required BigInt revision,
    required BigInt generation,
  });

  Future<ContentSnapshotV2> saveTemplateV1({
    String? id,
    required String name,
    required List<TemplateFieldV1> fields,
    required BigInt revision,
    required BigInt generation,
  });

  Future<CardMatchesV1> searchCardsV1({
    required CardSearchV1 query,
    required BigInt revision,
    required BigInt generation,
  });

  Future<VaultStatus> status();

  Future<void> unlock({required String password, required BigInt generation});

  Future<void> unlockBiometricV1({required BigInt generation});

  Future<void> unlockV3({required String password, required BigInt generation});

  Future<void> validateRecoveryV3({
    required String phrase,
    required BigInt generation,
  });

  Future<void> waitForExportsV2();
}

class RecoveryChallenge {
  final List<String> words;
  final Uint32List positions;

  const RecoveryChallenge({required this.words, required this.positions});

  @override
  int get hashCode => words.hashCode ^ positions.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecoveryChallenge &&
          runtimeType == other.runtimeType &&
          words == other.words &&
          positions == other.positions;
}

enum VaultFailure {
  credentials,
  invalidPassword,
  invalidPhrase,
  confirmation,
  exists,
  missing,
  locked,
  busy,
  unsupported,
  corrupt,
  storage,
  stale,
  closed,
  unavailable,
  writeUncertain,
}

enum VaultStatus { missing, locked, unlocked, confirmation }
