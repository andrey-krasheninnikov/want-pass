import 'package:equatable/equatable.dart';
import 'package:want_pass_core/src/feature/vault/application/_barrel.dart';
import 'package:want_pass_core/src/feature/vault/domain/_barrel.dart';

final class CardDraftV1 extends Equatable {
  final String? id;
  final String name, description, service;
  final CardTypeV1 cardType;
  final EnvironmentV1? environment;
  final List<String> groupIds;
  final List<CardFieldDraftV1> fields;
  final AttachmentDraftV1? attachment;
  const CardDraftV1({
    this.id,
    required this.name,
    this.description = '',
    required this.service,
    required this.cardType,
    this.environment,
    this.groupIds = const [],
    this.fields = const [],
    this.attachment,
  });
  @override
  List<Object?> get props => [
    id,
    name,
    description,
    service,
    cardType,
    environment,
    groupIds,
    fields,
    attachment,
  ];
  @override
  String toString() => 'CardDraftV1(<redacted>)';
}
