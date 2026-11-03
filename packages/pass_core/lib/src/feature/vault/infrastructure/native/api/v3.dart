// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import 'package:want_pass_core/src/feature/vault/infrastructure/_barrel.dart';

import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

// These functions are ignored because they are not marked as `pub`: `challenge`, `parse_phrase`, `recovery_json`

class RecoveryChallengeV3 {
  final List<String> words;
  final Uint32List positions;
  final List<List<String>> choices;
  final String json;
  final BigInt revision;

  const RecoveryChallengeV3({
    required this.words,
    required this.positions,
    required this.choices,
    required this.json,
    required this.revision,
  });

  @override
  int get hashCode =>
      words.hashCode ^
      positions.hashCode ^
      choices.hashCode ^
      json.hashCode ^
      revision.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecoveryChallengeV3 &&
          runtimeType == other.runtimeType &&
          words == other.words &&
          positions == other.positions &&
          choices == other.choices &&
          json == other.json &&
          revision == other.revision;
}
