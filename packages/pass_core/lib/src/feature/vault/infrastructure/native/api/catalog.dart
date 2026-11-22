// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import 'package:want_pass_core/src/feature/vault/infrastructure/_barrel.dart';

import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

// These functions are ignored because they are not marked as `pub`: `normalize_target`, `valid_id`, `validate`, `web_account`, `web_target`
// These function are ignored because they are on traits that is not defined in current crate (put an empty `#[frb]` on it to unignore): `assert_receiver_is_total_eq`, `assert_receiver_is_total_eq`, `assert_receiver_is_total_eq`, `assert_receiver_is_total_eq`, `assert_receiver_is_total_eq`, `assert_receiver_is_total_eq`, `assert_receiver_is_total_eq`, `assert_receiver_is_total_eq`, `clone`, `clone`, `clone`, `clone`, `clone`, `clone`, `clone`, `clone`, `eq`, `eq`, `eq`, `eq`, `eq`, `eq`, `eq`, `eq`, `zeroize`, `zeroize`, `zeroize`, `zeroize`, `zeroize`

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

class CustomCardInputV1 {
  final String? id;
  final String name;
  final String description;
  final String service;
  final EnvironmentV1? environment;
  final List<String> groupIds;
  final String templateId;
  final int templateVersion;
  final bool acceptTemplateUpdate;
  final List<CustomValueInputV1> values;

  const CustomCardInputV1({
    this.id,
    required this.name,
    required this.description,
    required this.service,
    this.environment,
    required this.groupIds,
    required this.templateId,
    required this.templateVersion,
    required this.acceptTemplateUpdate,
    required this.values,
  });

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      service.hashCode ^
      environment.hashCode ^
      groupIds.hashCode ^
      templateId.hashCode ^
      templateVersion.hashCode ^
      acceptTemplateUpdate.hashCode ^
      values.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomCardInputV1 &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          service == other.service &&
          environment == other.environment &&
          groupIds == other.groupIds &&
          templateId == other.templateId &&
          templateVersion == other.templateVersion &&
          acceptTemplateUpdate == other.acceptTemplateUpdate &&
          values == other.values;
}

enum CustomFieldKindV1 { text, concealed, url, otp, codes, file }

class CustomValueInputV1 {
  final String fieldId;
  final String value;
  final AttachmentInputV1? file;
  final bool keepFile;

  const CustomValueInputV1({
    required this.fieldId,
    required this.value,
    this.file,
    required this.keepFile,
  });

  @override
  int get hashCode =>
      fieldId.hashCode ^ value.hashCode ^ file.hashCode ^ keepFile.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomValueInputV1 &&
          runtimeType == other.runtimeType &&
          fieldId == other.fieldId &&
          value == other.value &&
          file == other.file &&
          keepFile == other.keepFile;
}

class CustomValueViewV1 {
  final String fieldId;
  final String value;
  final AttachmentSummaryV1? file;

  const CustomValueViewV1({
    required this.fieldId,
    required this.value,
    this.file,
  });

  @override
  int get hashCode => fieldId.hashCode ^ value.hashCode ^ file.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomValueViewV1 &&
          runtimeType == other.runtimeType &&
          fieldId == other.fieldId &&
          value == other.value &&
          file == other.file;
}

class HistoricalCardV1 {
  final CardSummaryV1 summary;
  final String description;
  final List<CardValueV1> fields;
  final List<CustomValueViewV1> customValues;
  final List<ResourceBindingV1> bindings;
  final AttachmentSummaryV1? attachment;

  const HistoricalCardV1({
    required this.summary,
    required this.description,
    required this.fields,
    required this.customValues,
    required this.bindings,
    this.attachment,
  });

  @override
  int get hashCode =>
      summary.hashCode ^
      description.hashCode ^
      fields.hashCode ^
      customValues.hashCode ^
      bindings.hashCode ^
      attachment.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoricalCardV1 &&
          runtimeType == other.runtimeType &&
          summary == other.summary &&
          description == other.description &&
          fields == other.fields &&
          customValues == other.customValues &&
          bindings == other.bindings &&
          attachment == other.attachment;
}

class HistorySummaryV1 {
  final String id;
  final PlatformInt64 at;
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
  int get hashCode =>
      id.hashCode ^
      at.hashCode ^
      cardId.hashCode ^
      name.hashCode ^
      service.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistorySummaryV1 &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          at == other.at &&
          cardId == other.cardId &&
          name == other.name &&
          service == other.service;
}

class ResourceBindingV1 {
  final String id;
  final ResourceKindV1 kind;
  final String target;
  final BindingMethodV1 method;
  final List<String> fields;

  const ResourceBindingV1({
    required this.id,
    required this.kind,
    required this.target,
    required this.method,
    required this.fields,
  });

  @override
  int get hashCode =>
      id.hashCode ^
      kind.hashCode ^
      target.hashCode ^
      method.hashCode ^
      fields.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResourceBindingV1 &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          kind == other.kind &&
          target == other.target &&
          method == other.method &&
          fields == other.fields;
}

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

class ServiceDefinitionV1 {
  final String id;
  final String name;
  final String description;
  final String icon;
  final Uint8List logo;
  final bool archived;

  const ServiceDefinitionV1({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.logo,
    required this.archived,
  });

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      icon.hashCode ^
      logo.hashCode ^
      archived.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceDefinitionV1 &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          icon == other.icon &&
          logo == other.logo &&
          archived == other.archived;
}

class TemplateDefinitionV1 {
  final String id;
  final List<TemplateVersionV1> versions;

  const TemplateDefinitionV1({required this.id, required this.versions});

  @override
  int get hashCode => id.hashCode ^ versions.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TemplateDefinitionV1 &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          versions == other.versions;
}

class TemplateFieldV1 {
  final String id;
  final String label;
  final CustomFieldKindV1 kind;
  final bool required_;

  const TemplateFieldV1({
    required this.id,
    required this.label,
    required this.kind,
    required this.required_,
  });

  @override
  int get hashCode =>
      id.hashCode ^ label.hashCode ^ kind.hashCode ^ required_.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TemplateFieldV1 &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          label == other.label &&
          kind == other.kind &&
          required_ == other.required_;
}

class TemplateVersionV1 {
  final int number;
  final String name;
  final List<TemplateFieldV1> fields;

  const TemplateVersionV1({
    required this.number,
    required this.name,
    required this.fields,
  });

  @override
  int get hashCode => number.hashCode ^ name.hashCode ^ fields.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TemplateVersionV1 &&
          runtimeType == other.runtimeType &&
          number == other.number &&
          name == other.name &&
          fields == other.fields;
}
