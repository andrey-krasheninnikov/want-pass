// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import 'package:want_pass_core/src/feature/vault/infrastructure/_barrel.dart';

import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

// These functions are ignored because they are not marked as `pub`: `challenge`, `export_recovery_with_hook`, `index`, `new`
// These types are ignored because they are neither used by any `pub` functions nor (for structs and enums) marked `#[frb(unignore)]`: `DraftV2`

class RecoveryChallengeV2 {
  final List<String> words;
  final Uint32List positions;
  final List<List<String>> choices;

  const RecoveryChallengeV2({
    required this.words,
    required this.positions,
    required this.choices,
  });

  @override
  int get hashCode => words.hashCode ^ positions.hashCode ^ choices.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecoveryChallengeV2 &&
          runtimeType == other.runtimeType &&
          words == other.words &&
          positions == other.positions &&
          choices == other.choices;
}

class VaultHintsV2 {
  final String password;
  final String recovery;

  const VaultHintsV2({required this.password, required this.recovery});

  @override
  int get hashCode => password.hashCode ^ recovery.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VaultHintsV2 &&
          runtimeType == other.runtimeType &&
          password == other.password &&
          recovery == other.recovery;
}
