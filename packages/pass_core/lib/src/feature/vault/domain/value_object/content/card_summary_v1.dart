import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:want_pass_core/src/feature/vault/domain/_barrel.dart';

final class CardSummaryV1 extends Equatable {
  final String id;
  final String name;
  final String service;
  final EnvironmentV1? environment;
  final List<String> groupIds;
  final CardTypeV1 cardType;
  final int templateVersion;
  const CardSummaryV1._({
    required this.id,
    required this.name,
    required this.service,
    required this.environment,
    required this.groupIds,
    required this.cardType,
    required this.templateVersion,
  });
  factory CardSummaryV1({
    required String id,
    required String name,
    required String service,
    EnvironmentV1? environment,
    required List<String> groupIds,
    required CardTypeV1 cardType,
    required int templateVersion,
  }) {
    if (!RegExp(r'^[0-9a-f]{32}$').hasMatch(id) ||
        name.trim().isEmpty ||
        utf8.encode(name).length > 512 ||
        service.trim().isEmpty ||
        utf8.encode(service).length > 512 ||
        templateVersion != 1 ||
        groupIds.toSet().length != groupIds.length ||
        groupIds.any((id) => !RegExp(r'^[0-9a-f]{32}$').hasMatch(id))) {
      throw const VaultRejectedErrorV1(VaultFailureKindV1.unsupported);
    }
    return CardSummaryV1._(
      id: id,
      name: name,
      service: service,
      environment: environment,
      groupIds: List.unmodifiable(groupIds),
      cardType: cardType,
      templateVersion: templateVersion,
    );
  }
  CardSummaryV1 copyWith({
    String? id,
    String? name,
    String? service,
    EnvironmentV1? Function()? environment,
    List<String>? groupIds,
    CardTypeV1? cardType,
    int? templateVersion,
  }) => CardSummaryV1(
    id: id ?? this.id,
    name: name ?? this.name,
    service: service ?? this.service,
    environment: environment == null ? this.environment : environment(),
    groupIds: groupIds ?? this.groupIds,
    cardType: cardType ?? this.cardType,
    templateVersion: templateVersion ?? this.templateVersion,
  );
  @override
  List<Object?> get props => [
    id,
    name,
    service,
    environment,
    groupIds,
    cardType,
    templateVersion,
  ];
  @override
  String toString() => 'CardSummaryV1(<redacted>)';
  String toDebugString() =>
      'CardSummaryV1(id: <redacted>, name: <redacted>, service: <redacted>, environment: <redacted>, groupIds: <redacted>, cardType: <redacted>, templateVersion: <redacted>)';
}
