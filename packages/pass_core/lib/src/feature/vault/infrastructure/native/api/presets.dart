// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import 'package:want_pass_core/src/feature/vault/infrastructure/_barrel.dart';

import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

// These functions are ignored because they are not marked as `pub`: `specs`, `validate_fields`

Future<List<CardPresetV1>> cardPresetsV1() =>
    VaultRustLib.instance.api.crateApiPresetsCardPresetsV1();

class CardPresetV1 {
  final CardTypeV1 cardType;
  final List<FieldSpecV1> fields;

  const CardPresetV1({required this.cardType, required this.fields});

  @override
  int get hashCode => cardType.hashCode ^ fields.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardPresetV1 &&
          runtimeType == other.runtimeType &&
          cardType == other.cardType &&
          fields == other.fields;
}

class FieldSpecV1 {
  final FieldIdV1 id;
  final bool required_;
  final bool concealed;
  final bool multiline;
  final int maxBytes;

  const FieldSpecV1({
    required this.id,
    required this.required_,
    required this.concealed,
    required this.multiline,
    required this.maxBytes,
  });

  @override
  int get hashCode =>
      id.hashCode ^
      required_.hashCode ^
      concealed.hashCode ^
      multiline.hashCode ^
      maxBytes.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FieldSpecV1 &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          required_ == other.required_ &&
          concealed == other.concealed &&
          multiline == other.multiline &&
          maxBytes == other.maxBytes;
}
