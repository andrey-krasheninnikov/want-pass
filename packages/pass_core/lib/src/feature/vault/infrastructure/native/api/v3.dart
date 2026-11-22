// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import 'package:want_pass_core/src/feature/vault/infrastructure/_barrel.dart';

import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

// These functions are ignored because they are not marked as `pub`: `challenge`, `recovery_json`, `reset_application_after_validation`

Future<bool> validatePasswordV3({required String password}) =>
    VaultRustLib.instance.api.crateApiV3ValidatePasswordV3(password: password);

Future<PasswordPolicyStatusV4> passwordPolicyV4({required String password}) =>
    VaultRustLib.instance.api.crateApiV3PasswordPolicyV4(password: password);

class PasswordPolicyStatusV4 {
  final bool minimumLength;
  final bool maximumBytes;
  final bool uppercase;
  final bool lowercase;
  final bool digit;
  final bool special;
  final bool singleLine;

  const PasswordPolicyStatusV4({
    required this.minimumLength,
    required this.maximumBytes,
    required this.uppercase,
    required this.lowercase,
    required this.digit,
    required this.special,
    required this.singleLine,
  });

  @override
  int get hashCode =>
      minimumLength.hashCode ^
      maximumBytes.hashCode ^
      uppercase.hashCode ^
      lowercase.hashCode ^
      digit.hashCode ^
      special.hashCode ^
      singleLine.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PasswordPolicyStatusV4 &&
          runtimeType == other.runtimeType &&
          minimumLength == other.minimumLength &&
          maximumBytes == other.maximumBytes &&
          uppercase == other.uppercase &&
          lowercase == other.lowercase &&
          digit == other.digit &&
          special == other.special &&
          singleLine == other.singleLine;
}

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
