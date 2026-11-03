import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:want_pass_core/src/feature/vault/domain/_barrel.dart';

final class CardValueV1 extends Equatable {
  final FieldIdV1 id;
  final String value;
  const CardValueV1._({required this.id, required this.value});
  factory CardValueV1({required FieldIdV1 id, required String value}) {
    if (utf8.encode(value).length > 1024 * 1024 || value.contains('\u0000')) {
      throw const VaultRejectedErrorV1(VaultFailureKindV1.unsupported);
    }
    return CardValueV1._(id: id, value: value);
  }
  CardValueV1 copyWith({FieldIdV1? id, String? value}) =>
      CardValueV1(id: id ?? this.id, value: value ?? this.value);
  @override
  List<Object?> get props => [id, value];
  @override
  String toString() => 'CardValueV1(<redacted>)';
  String toDebugString() => 'CardValueV1(id: <redacted>, value: <redacted>)';
}
