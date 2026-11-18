import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:want_pass_core/src/feature/vault/domain/_barrel.dart';

final class CardV1 extends Equatable {
  final CardSummaryV1 summary;
  final String description;
  final List<CardValueV1> fields;
  final AttachmentV1? attachment;
  final bool protectedContainer;
  const CardV1._({
    required this.summary,
    required this.description,
    required this.fields,
    required this.attachment,
    required this.protectedContainer,
  });
  factory CardV1({
    required CardSummaryV1 summary,
    required String description,
    required List<CardValueV1> fields,
    AttachmentV1? attachment,
    required bool protectedContainer,
  }) {
    if (utf8.encode(description).length > 16384 ||
        description.contains('\u0000') ||
        fields.map((f) => f.id).toSet().length != fields.length ||
        summary.cardType.requiredFields.any(
          (id) => !fields.any((f) => f.id == id && f.value.isNotEmpty),
        ) ||
        fields.any(
          (f) =>
              !summary.cardType.requiredFields.contains(f.id) &&
              !summary.cardType.optionalFields.contains(f.id),
        ) ||
        (summary.cardType == CardTypeV1.file) != (attachment != null)) {
      throw const VaultRejectedErrorV1(VaultFailureKindV1.unsupported);
    }
    return CardV1._(
      summary: summary,
      description: description,
      fields: List.unmodifiable(fields),
      attachment: attachment,
      protectedContainer: protectedContainer,
    );
  }
  CardV1 copyWith({
    CardSummaryV1? summary,
    String? description,
    List<CardValueV1>? fields,
    AttachmentV1? Function()? attachment,
    bool? protectedContainer,
  }) => CardV1(
    summary: summary ?? this.summary,
    description: description ?? this.description,
    fields: fields ?? this.fields,
    attachment: attachment == null ? this.attachment : attachment(),
    protectedContainer: protectedContainer ?? this.protectedContainer,
  );
  @override
  List<Object?> get props => [
    summary,
    description,
    fields,
    attachment,
    protectedContainer,
  ];
  @override
  String toString() => 'CardV1(<redacted>)';
  String toDebugString() =>
      'CardV1(summary: <redacted>, description: <redacted>, fields: <redacted>, attachment: <redacted>, protectedContainer: <redacted>)';
}
