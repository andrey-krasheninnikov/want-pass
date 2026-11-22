// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import 'package:want_pass_core/src/feature/vault/infrastructure/_barrel.dart';

import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

// These functions are ignored because they are not marked as `pub`: `index`, `parse_phrase`, `unpack`
// These types are ignored because they are neither used by any `pub` functions nor (for structs and enums) marked `#[frb(unignore)]`: `Numbered`
// These function are ignored because they are on traits that is not defined in current crate (put an empty `#[frb]` on it to unignore): `expecting`, `visit_map`

RecoveryInputV1 inspectRecoveryInputV1({required String input}) => VaultRustLib
    .instance
    .api
    .crateApiPhraseInspectRecoveryInputV1(input: input);

class RecoveryInputV1 {
  final List<String> words;
  final Uint32List invalidPositions;
  final bool complete;
  final bool recognized;

  const RecoveryInputV1({
    required this.words,
    required this.invalidPositions,
    required this.complete,
    required this.recognized,
  });

  @override
  int get hashCode =>
      words.hashCode ^
      invalidPositions.hashCode ^
      complete.hashCode ^
      recognized.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecoveryInputV1 &&
          runtimeType == other.runtimeType &&
          words == other.words &&
          invalidPositions == other.invalidPositions &&
          complete == other.complete &&
          recognized == other.recognized;
}
