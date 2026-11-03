// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import 'package:want_pass_core/src/feature/vault/infrastructure/_barrel.dart';

import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

// These functions are ignored because they are not marked as `pub`: `bytes`, `decode`, `mutate_cards`, `read_cards`, `snapshot`, `summary`, `summary`, `validate`
// These types are ignored because they are neither used by any `pub` functions nor (for structs and enums) marked `#[frb(unignore)]`: `DocumentV2`, `StoredAttachment`, `StoredCard`
// These function are ignored because they are on traits that is not defined in current crate (put an empty `#[frb]` on it to unignore): `assert_receiver_is_total_eq`, `assert_receiver_is_total_eq`, `assert_receiver_is_total_eq`, `clone`, `clone`, `clone`, `clone`, `cmp`, `drop`, `drop`, `drop`, `eq`, `eq`, `eq`, `partial_cmp`, `zeroize`, `zeroize`, `zeroize`, `zeroize`

Future<List<String>> servicesV1() =>
    VaultRustLib.instance.api.crateApiCardsServicesV1();

class AttachmentInputV1 {
  final String name;
  final Uint8List bytes;

  const AttachmentInputV1({required this.name, required this.bytes});

  @override
  int get hashCode => name.hashCode ^ bytes.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttachmentInputV1 &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          bytes == other.bytes;
}

class AttachmentSummaryV1 {
  final String name;
  final int size;

  const AttachmentSummaryV1({required this.name, required this.size});

  @override
  int get hashCode => name.hashCode ^ size.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttachmentSummaryV1 &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          size == other.size;
}

class CardInputV1 {
  final String? id;
  final String name;
  final String description;
  final String service;
  final EnvironmentV1? environment;
  final List<String> groupIds;
  final CardTypeV1 cardType;
  final List<CardValueV1> fields;
  final AttachmentInputV1? attachment;

  const CardInputV1({
    this.id,
    required this.name,
    required this.description,
    required this.service,
    this.environment,
    required this.groupIds,
    required this.cardType,
    required this.fields,
    this.attachment,
  });

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      service.hashCode ^
      environment.hashCode ^
      groupIds.hashCode ^
      cardType.hashCode ^
      fields.hashCode ^
      attachment.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardInputV1 &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          service == other.service &&
          environment == other.environment &&
          groupIds == other.groupIds &&
          cardType == other.cardType &&
          fields == other.fields &&
          attachment == other.attachment;
}

class CardMatchesV1 {
  final BigInt revision;
  final List<String> cardIds;
  final List<String> groupIds;

  const CardMatchesV1({
    required this.revision,
    required this.cardIds,
    required this.groupIds,
  });

  @override
  int get hashCode => revision.hashCode ^ cardIds.hashCode ^ groupIds.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardMatchesV1 &&
          runtimeType == other.runtimeType &&
          revision == other.revision &&
          cardIds == other.cardIds &&
          groupIds == other.groupIds;
}

class CardRecordV1 {
  final CardSummaryV1 summary;
  final String description;
  final List<CardValueV1> fields;
  final AttachmentSummaryV1? attachment;
  final bool protectedContainer;

  const CardRecordV1({
    required this.summary,
    required this.description,
    required this.fields,
    this.attachment,
    required this.protectedContainer,
  });

  @override
  int get hashCode =>
      summary.hashCode ^
      description.hashCode ^
      fields.hashCode ^
      attachment.hashCode ^
      protectedContainer.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardRecordV1 &&
          runtimeType == other.runtimeType &&
          summary == other.summary &&
          description == other.description &&
          fields == other.fields &&
          attachment == other.attachment &&
          protectedContainer == other.protectedContainer;
}

class CardRowV1 {
  final String id;
  final List<FieldIdV1> fields;
  final String? login;
  final TotpCodeV1? otp;
  final AttachmentSummaryV1? attachment;

  const CardRowV1({
    required this.id,
    required this.fields,
    this.login,
    this.otp,
    this.attachment,
  });

  @override
  int get hashCode =>
      id.hashCode ^
      fields.hashCode ^
      login.hashCode ^
      otp.hashCode ^
      attachment.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardRowV1 &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          fields == other.fields &&
          login == other.login &&
          otp == other.otp &&
          attachment == other.attachment;
}

class CardSearchV1 {
  final String text;
  final CardTypeV1? cardType;
  final String? service;
  final EnvironmentV1? environment;
  final bool withoutEnvironment;

  const CardSearchV1({
    required this.text,
    this.cardType,
    this.service,
    this.environment,
    required this.withoutEnvironment,
  });

  @override
  int get hashCode =>
      text.hashCode ^
      cardType.hashCode ^
      service.hashCode ^
      environment.hashCode ^
      withoutEnvironment.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardSearchV1 &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          cardType == other.cardType &&
          service == other.service &&
          environment == other.environment &&
          withoutEnvironment == other.withoutEnvironment;
}

class CardSummaryV1 {
  final String id;
  final String name;
  final String service;
  final EnvironmentV1? environment;
  final List<String> groupIds;
  final CardTypeV1 cardType;
  final int templateVersion;

  const CardSummaryV1({
    required this.id,
    required this.name,
    required this.service,
    this.environment,
    required this.groupIds,
    required this.cardType,
    required this.templateVersion,
  });

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      service.hashCode ^
      environment.hashCode ^
      groupIds.hashCode ^
      cardType.hashCode ^
      templateVersion.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardSummaryV1 &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          service == other.service &&
          environment == other.environment &&
          groupIds == other.groupIds &&
          cardType == other.cardType &&
          templateVersion == other.templateVersion;
}

enum CardTypeV1 {
  account,
  pat,
  rsa,
  ed25519,
  secretKey,
  passphrase,
  recoveryCodes,
  recoveryUrl,
  secretQa,
  vless,
  wireGuard,
  gpg,
  certificate,
  oAuth,
  dsn,
  kubeconfig,
  webhookSecret,
  secureNote,
  file,
}

class CardValueV1 {
  final FieldIdV1 id;
  final String value;

  const CardValueV1({required this.id, required this.value});

  @override
  int get hashCode => id.hashCode ^ value.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardValueV1 &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          value == other.value;
}

class ContentSnapshotV2 {
  final BigInt revision;
  final List<GroupRecordV1> groups;
  final List<CardSummaryV1> cards;

  const ContentSnapshotV2({
    required this.revision,
    required this.groups,
    required this.cards,
  });

  @override
  int get hashCode => revision.hashCode ^ groups.hashCode ^ cards.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentSnapshotV2 &&
          runtimeType == other.runtimeType &&
          revision == other.revision &&
          groups == other.groups &&
          cards == other.cards;
}

enum EnvironmentV1 {
  local,
  unitTests,
  integrationTests,
  e2ETests,
  development,
  stand,
  feature,
  stage,
  preRelease,
  production,
}

enum FieldIdV1 {
  login,
  password,
  totpSeed,
  totpAlgorithm,
  totpDigits,
  totpPeriod,
  recoveryCodes,
  reserveLogins,
  value,
  publicKey,
  privateKey,
  certificate,
  clientId,
  clientSecret,
  accessToken,
  refreshToken,
  question,
  answer,
}
