import 'package:equatable/equatable.dart';
import 'package:want_pass_core/src/feature/vault/domain/_barrel.dart';

final class CardCatalogV1 extends Equatable {
  final List<String> services;
  final List<CardPresetV1> presets;
  const CardCatalogV1._({required this.services, required this.presets});
  factory CardCatalogV1({
    required List<String> services,
    required List<CardPresetV1> presets,
  }) {
    if (services.isEmpty ||
        services.any((s) => s.trim().isEmpty) ||
        services.toSet().length != services.length ||
        presets.map((p) => p.cardType).toSet().length != presets.length) {
      throw const VaultRejectedErrorV1(VaultFailureKindV1.unsupported);
    }
    return CardCatalogV1._(
      services: List.unmodifiable(services),
      presets: List.unmodifiable(presets),
    );
  }
  CardCatalogV1 copyWith({
    List<String>? services,
    List<CardPresetV1>? presets,
  }) => CardCatalogV1(
    services: services ?? this.services,
    presets: presets ?? this.presets,
  );
  @override
  List<Object?> get props => [services, presets];
  @override
  String toString() => 'CardCatalogV1(<redacted>)';
  String toDebugString() =>
      'CardCatalogV1(services: <redacted>, presets: <redacted>)';
}
