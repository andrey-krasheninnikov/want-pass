import 'package:equatable/equatable.dart';
import 'package:want_pass_core/src/feature/vault/domain/_barrel.dart';

final class CardPresetV1 extends Equatable {
  final CardTypeV1 cardType;
  final List<FieldSpecV1> fields;
  const CardPresetV1._({required this.cardType, required this.fields});
  factory CardPresetV1({
    required CardTypeV1 cardType,
    required List<FieldSpecV1> fields,
  }) {
    if (fields.map((f) => f.id).toSet().length != fields.length) {
      throw const VaultRejectedErrorV1(VaultFailureKindV1.unsupported);
    }
    return CardPresetV1._(
      cardType: cardType,
      fields: List.unmodifiable(fields),
    );
  }
  CardPresetV1 copyWith({CardTypeV1? cardType, List<FieldSpecV1>? fields}) =>
      CardPresetV1(
        cardType: cardType ?? this.cardType,
        fields: fields ?? this.fields,
      );
  @override
  List<Object?> get props => [cardType, fields];
  @override
  String toString() => 'CardPresetV1(<redacted>)';
  String toDebugString() =>
      'CardPresetV1(cardType: <redacted>, fields: <redacted>)';
}
