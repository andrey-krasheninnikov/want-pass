import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:want_pass_core/src/feature/vault/domain/_barrel.dart';

final class AttachmentV1 extends Equatable {
  final String name;
  final int size;
  const AttachmentV1._({required this.name, required this.size});
  factory AttachmentV1({required String name, required int size}) {
    if (name.trim().isEmpty ||
        utf8.encode(name).length > 512 ||
        name.contains('/') ||
        name.contains(r'\') ||
        name.contains('\u0000') ||
        name == '.' ||
        name == '..' ||
        size < 0 ||
        size > 20 * 1024 * 1024) {
      throw const VaultRejectedErrorV1(VaultFailureKindV1.unsupported);
    }
    return AttachmentV1._(name: name, size: size);
  }
  AttachmentV1 copyWith({String? name, int? size}) =>
      AttachmentV1(name: name ?? this.name, size: size ?? this.size);
  @override
  List<Object?> get props => [name, size];
  @override
  String toString() => 'AttachmentV1(<redacted>)';
  String toDebugString() => 'AttachmentV1(name: <redacted>, size: <redacted>)';
}
