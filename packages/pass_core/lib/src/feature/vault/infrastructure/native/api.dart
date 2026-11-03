// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import 'package:want_pass_core/src/feature/vault/infrastructure/_barrel.dart';

import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

// These types are ignored because they are neither used by any `pub` functions nor (for structs and enums) marked `#[frb(unignore)]`: `Draft`, `State`
// These function are ignored because they are on traits that is not defined in current crate (put an empty `#[frb]` on it to unignore): `assert_receiver_is_total_eq`, `assert_receiver_is_total_eq`, `clone`, `clone`, `eq`, `eq`, `fmt`, `fmt`

// Rust type: RustOpaqueMoi<flutter_rust_bridge::for_generated::RustAutoOpaqueInner<Vault>>
abstract class Vault implements RustOpaqueInterface {
  Future<AccountRecordV1> accountV1({
    required String id,
    required BigInt generation,
  });

  Future<void> close();

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

  Future<ContentSnapshotV1> deleteAccountV1({
    required String id,
    required BigInt revision,
    required BigInt generation,
  });

  Future<ContentSnapshotV1> deleteGroupV1({
    required String id,
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

  void lock();

  static Future<Vault> open({required String directory}) =>
      VaultRustLib.instance.api.crateApiVaultOpen(directory: directory);

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

  Future<RecoveryChallengeV3> regenerateRecoveryV3({
    required BigInt generation,
  });

  Future<ContentSnapshotV1> saveAccountV1({
    required AccountInputV1 input,
    required BigInt revision,
    required BigInt generation,
  });

  Future<ContentSnapshotV1> saveGroupV1({
    required GroupInputV1 input,
    required BigInt revision,
    required BigInt generation,
  });

  Future<VaultStatus> status();

  Future<void> unlock({required String password, required BigInt generation});

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
