import 'package:equatable/equatable.dart';
import 'package:want_pass_core/src/feature/vault/domain/_barrel.dart';

enum CustomFieldKindV1 { text, concealed, url, otp, codes, file }

enum ResourceKindV1 {
  webApp,
  restEndpoint,
  sshHost,
  gitRepository,
  packageRegistry,
  containerRegistry,
  database,
  kubernetesContext,
}

enum BindingMethodV1 {
  web,
  rest,
  ssh,
  git,
  registry,
  database,
  kubernetes,
  awsCli,
  netrc,
  mtls,
}

final class ServiceDefinitionV1 extends Equatable {
  final String id;
  final String name;
  final String description;
  final String icon;
  final List<int> logo;
  final bool archived;
  ServiceDefinitionV1({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required List<int> logo,
    required this.archived,
  }) : logo = List.unmodifiable(logo);
  @override
  List<Object?> get props => [id, name, description, icon, logo, archived];
  @override
  String toString() => 'ServiceDefinitionV1(<redacted>)';
}

final class TemplateFieldV1 extends Equatable {
  final String id;
  final String label;
  final CustomFieldKindV1 kind;
  final bool required;
  const TemplateFieldV1({
    required this.id,
    required this.label,
    required this.kind,
    required this.required,
  });
  @override
  List<Object?> get props => [id, label, kind, required];
  @override
  String toString() => 'TemplateFieldV1(<redacted>)';
}

final class TemplateVersionV1 extends Equatable {
  final int number;
  final String name;
  final List<TemplateFieldV1> fields;
  TemplateVersionV1({
    required this.number,
    required this.name,
    required List<TemplateFieldV1> fields,
  }) : fields = List.unmodifiable(fields);
  @override
  List<Object?> get props => [number, name, fields];
  @override
  String toString() => 'TemplateVersionV1(<redacted>)';
}

final class TemplateDefinitionV1 extends Equatable {
  final String id;
  final List<TemplateVersionV1> versions;
  TemplateDefinitionV1({
    required this.id,
    required List<TemplateVersionV1> versions,
  }) : versions = List.unmodifiable(versions);
  @override
  List<Object?> get props => [id, versions];
  @override
  String toString() => 'TemplateDefinitionV1(<redacted>)';
}

final class ResourceBindingV1 extends Equatable {
  final String id;
  final ResourceKindV1 kind;
  final String target;
  final BindingMethodV1 method;
  final List<String> fields;
  ResourceBindingV1({
    required this.id,
    required this.kind,
    required this.target,
    required this.method,
    required List<String> fields,
  }) : fields = List.unmodifiable(fields);
  @override
  List<Object?> get props => [id, kind, target, method, fields];
  @override
  String toString() => 'ResourceBindingV1(<redacted>)';
}

final class HistorySummaryV1 extends Equatable {
  final String id;
  final DateTime at;
  final String cardId;
  final String name;
  final String service;
  const HistorySummaryV1({
    required this.id,
    required this.at,
    required this.cardId,
    required this.name,
    required this.service,
  });
  @override
  List<Object?> get props => [id, at, cardId, name, service];
  @override
  String toString() => 'HistorySummaryV1(<redacted>)';
}

final class CustomValueViewV1 extends Equatable {
  final String fieldId;
  final String value;
  final AttachmentV1? file;
  const CustomValueViewV1({
    required this.fieldId,
    required this.value,
    required this.file,
  });
  @override
  List<Object?> get props => [fieldId, value, file];
  @override
  String toString() => 'CustomValueViewV1(<redacted>)';
}

final class HistoricalCardV1 extends Equatable {
  final CardSummaryV1 summary;
  final String description;
  final List<CardValueV1> fields;
  final List<CustomValueViewV1> customValues;
  final List<ResourceBindingV1> bindings;
  final AttachmentV1? attachment;
  HistoricalCardV1({
    required this.summary,
    required this.description,
    required List<CardValueV1> fields,
    required List<CustomValueViewV1> customValues,
    required List<ResourceBindingV1> bindings,
    required this.attachment,
  }) : fields = List.unmodifiable(fields),
       customValues = List.unmodifiable(customValues),
       bindings = List.unmodifiable(bindings);
  @override
  List<Object?> get props => [
    summary,
    description,
    fields,
    customValues,
    bindings,
    attachment,
  ];
  @override
  String toString() => 'HistoricalCardV1(<redacted>)';
}
