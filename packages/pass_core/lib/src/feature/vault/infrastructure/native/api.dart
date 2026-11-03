// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import 'package:want_pass_core/src/feature/vault/infrastructure/_barrel.dart';

import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

// These types are ignored because they are neither used by any `pub` functions nor (for structs and enums) marked `#[frb(unignore)]`: `Draft`, `State`
// These function are ignored because they are on traits that is not defined in current crate (put an empty `#[frb]` on it to unignore): `assert_receiver_is_total_eq`, `assert_receiver_is_total_eq`, `clone`, `clone`, `eq`, `eq`, `fmt`, `fmt`

// Rust type: RustOpaqueMoi<flutter_rust_bridge::for_generated::RustAutoOpaqueInner<Vault>>
abstract class Vault implements RustOpaqueInterface {
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

  Future<void> exportRecoveryV2({
    required String destination,
    required BigInt generation,
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

  Future<VaultStatus> status();

  Future<void> unlock({required String password, required BigInt generation});

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
