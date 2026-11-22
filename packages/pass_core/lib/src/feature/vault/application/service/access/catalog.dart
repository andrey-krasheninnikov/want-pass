import 'package:domain_error/domain_error.dart';
import 'package:want_pass_core/src/feature/vault/application/_barrel.dart';
import 'package:want_pass_core/src/feature/vault/domain/_barrel.dart';

sealed class CatalogEditV1 {
  const CatalogEditV1();
  @override
  String toString() => 'CatalogEditV1(<redacted>)';
}

final class SaveServiceV1 extends CatalogEditV1 {
  final ServiceDefinitionV1 service;
  const SaveServiceV1(this.service);
}

final class RemoveServiceV1 extends CatalogEditV1 {
  final String id;
  final String? replacement;
  final bool preserve;
  const RemoveServiceV1(this.id, this.replacement, this.preserve);
}

final class SaveTemplateV1 extends CatalogEditV1 {
  final String? id;
  final String name;
  final List<TemplateFieldV1> fields;
  const SaveTemplateV1(this.id, this.name, this.fields);
}

final class SaveBindingsV1 extends CatalogEditV1 {
  final String cardId;
  final List<ResourceBindingV1> bindings;
  const SaveBindingsV1(this.cardId, this.bindings);
}

final class SaveCustomCardV1 extends CatalogEditV1 {
  final CardDraftV1 card;
  final String templateId;
  final int templateVersion;
  final bool acceptUpdate;
  final List<CustomValueDraftV1> values;
  const SaveCustomCardV1(
    this.card,
    this.templateId,
    this.templateVersion,
    this.acceptUpdate,
    this.values,
  );
}

final class RestoreHistoryV1 extends CatalogEditV1 {
  final String id;
  const RestoreHistoryV1(this.id);
}

final class ClearHistoryV1 extends CatalogEditV1 {
  final String? cardId;
  final bool confirmed;
  const ClearHistoryV1(this.cardId, this.confirmed);
}

final class CustomValueDraftV1 {
  final String fieldId, value;
  final AttachmentDraftV1? file;
  final bool keepFile;
  const CustomValueDraftV1({
    required this.fieldId,
    required this.value,
    this.file,
    this.keepFile = false,
  });
  @override
  String toString() => 'CustomValueDraftV1(<redacted>)';
}

abstract interface class VaultCatalogAccessV1 {
  FutureDomainResult<String> copyQuickCardV1({
    required VaultHandleV1 handle,
    required BigInt revision,
    required String id,
  });
  FutureDomainResult<String> customFieldV1({
    required VaultHandleV1 handle,
    required BigInt revision,
    required String id,
    required String fieldId,
    required bool copy,
  });
  FutureDomainResult<void> exportCustomFileV1({
    required VaultHandleV1 handle,
    required BigInt revision,
    required String id,
    required String fieldId,
    required String destination,
  });
  FutureDomainResult<List<ResourceBindingV1>> bindingsV1({
    required VaultHandleV1 handle,
    required BigInt revision,
    required String id,
  });
  FutureDomainResult<List<CustomValueViewV1>> customValuesV1({
    required VaultHandleV1 handle,
    required BigInt revision,
    required String id,
  });
  FutureDomainResult<List<HistorySummaryV1>> historyV1({
    required VaultHandleV1 handle,
    required BigInt revision,
    required String? cardId,
  });
  FutureDomainResult<HistoricalCardV1> historicalCardV1({
    required VaultHandleV1 handle,
    required BigInt revision,
    required String id,
  });
  FutureDomainResult<ContentSnapshotV2> catalogEditV1({
    required VaultHandleV1 handle,
    required BigInt revision,
    required CatalogEditV1 edit,
  });
}
