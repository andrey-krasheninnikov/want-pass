import 'package:equatable/equatable.dart';
import 'package:want_pass_core/src/feature/vault/domain/_barrel.dart';

final class CardSearchV1 extends Equatable {
  final String text;
  final CardTypeV1? cardType;
  final String? service;
  final EnvironmentV1? environment;
  final bool withoutEnvironment;
  const CardSearchV1({
    this.text = '',
    this.cardType,
    this.service,
    this.environment,
    this.withoutEnvironment = false,
  });
  @override
  List<Object?> get props => [
    text,
    cardType,
    service,
    environment,
    withoutEnvironment,
  ];
  @override
  String toString() => 'CardSearchV1(<redacted>)';
}

final class CardMatchesV1 extends Equatable {
  final BigInt revision;
  final List<String> cardIds, groupIds;
  const CardMatchesV1({
    required this.revision,
    required this.cardIds,
    required this.groupIds,
  });
  @override
  List<Object?> get props => [revision, cardIds, groupIds];
  @override
  String toString() => 'CardMatchesV1(<redacted>)';
}

final class CardRowV1 extends Equatable {
  final String id;
  final List<FieldIdV1> fields;
  final String? login;
  final TotpCodeV1? otp;
  final AttachmentV1? attachment;
  const CardRowV1({
    required this.id,
    required this.fields,
    this.login,
    this.otp,
    this.attachment,
  });
  @override
  List<Object?> get props => [id, fields, login, otp, attachment];
  @override
  String toString() => 'CardRowV1(<redacted>)';
}

final class CardPreviewV1 extends Equatable {
  final CardRowV1 row;
  final String description;
  final bool protectedContainer;
  const CardPreviewV1({
    required this.row,
    required this.description,
    required this.protectedContainer,
  });
  @override
  List<Object?> get props => [row, description, protectedContainer];
  @override
  String toString() => 'CardPreviewV1(<redacted>)';
}
