import 'package:equatable/equatable.dart';
import 'package:want_pass_core/src/feature/vault/domain/_barrel.dart';

final class ContentSnapshotV2 extends Equatable {
  final BigInt revision;
  final List<GroupV1> groups;
  final List<CardSummaryV1> cards;
  final List<ServiceDefinitionV1> services;
  final List<TemplateDefinitionV1> templates;
  const ContentSnapshotV2._({
    required this.revision,
    required this.groups,
    required this.cards,
    required this.services,
    required this.templates,
  });
  factory ContentSnapshotV2({
    required BigInt revision,
    required List<GroupV1> groups,
    required List<CardSummaryV1> cards,
    List<ServiceDefinitionV1> services = const [],
    List<TemplateDefinitionV1> templates = const [],
  }) {
    if (revision.isNegative || groups.length > 10000 || cards.length > 100000) {
      throw const VaultRejectedErrorV1(VaultFailureKindV1.unsupported);
    }
    final groupIds = groups.map((g) => g.id).toSet();
    if (groupIds.length != groups.length ||
        cards.map((c) => c.id).toSet().length != cards.length ||
        cards.any((c) => c.groupIds.any((id) => !groupIds.contains(id)))) {
      throw const VaultRejectedErrorV1(VaultFailureKindV1.unsupported);
    }
    return ContentSnapshotV2._(
      revision: revision,
      groups: List.unmodifiable(groups),
      cards: List.unmodifiable(cards),
      services: List.unmodifiable(services),
      templates: List.unmodifiable(templates),
    );
  }
  ContentSnapshotV2 copyWith({
    BigInt? revision,
    List<GroupV1>? groups,
    List<CardSummaryV1>? cards,
    List<ServiceDefinitionV1>? services,
    List<TemplateDefinitionV1>? templates,
  }) => ContentSnapshotV2(
    revision: revision ?? this.revision,
    groups: groups ?? this.groups,
    cards: cards ?? this.cards,
    services: services ?? this.services,
    templates: templates ?? this.templates,
  );
  @override
  List<Object?> get props => [revision, groups, cards, services, templates];
  @override
  String toString() => 'ContentSnapshotV2(<redacted>)';
  String toDebugString() =>
      'ContentSnapshotV2(revision: <redacted>, groups: <redacted>, cards: <redacted>)';
}
