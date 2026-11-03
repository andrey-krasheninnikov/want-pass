import 'package:equatable/equatable.dart';
import 'package:want_pass_core/src/feature/vault/domain/_barrel.dart';

final class FieldSpecV1 extends Equatable {
  final FieldIdV1 id;
  final bool required;
  final bool concealed;
  final bool multiline;
  final int maxBytes;
  const FieldSpecV1._({
    required this.id,
    required this.required,
    required this.concealed,
    required this.multiline,
    required this.maxBytes,
  });
  factory FieldSpecV1({
    required FieldIdV1 id,
    required bool required,
    required bool concealed,
    required bool multiline,
    required int maxBytes,
  }) {
    if (maxBytes <= 0 || maxBytes > 1024 * 1024) {
      throw const VaultRejectedErrorV1(VaultFailureKindV1.unsupported);
    }
    return FieldSpecV1._(
      id: id,
      required: required,
      concealed: concealed,
      multiline: multiline,
      maxBytes: maxBytes,
    );
  }
  FieldSpecV1 copyWith({
    FieldIdV1? id,
    bool? required,
    bool? concealed,
    bool? multiline,
    int? maxBytes,
  }) => FieldSpecV1(
    id: id ?? this.id,
    required: required ?? this.required,
    concealed: concealed ?? this.concealed,
    multiline: multiline ?? this.multiline,
    maxBytes: maxBytes ?? this.maxBytes,
  );
  @override
  List<Object?> get props => [id, required, concealed, multiline, maxBytes];
  @override
  String toString() => 'FieldSpecV1(<redacted>)';
  String toDebugString() =>
      'FieldSpecV1(id: <redacted>, required: <redacted>, concealed: <redacted>, multiline: <redacted>, maxBytes: <redacted>)';
}
