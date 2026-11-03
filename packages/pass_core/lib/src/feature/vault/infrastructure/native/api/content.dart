// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import 'package:want_pass_core/src/feature/vault/infrastructure/_barrel.dart';

import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

// These functions are ignored because they are not marked as `pub`: `bounded`, `decode`, `mutate_content`, `new_id`, `snapshot`, `validate_logo`
// These types are ignored because they are neither used by any `pub` functions nor (for structs and enums) marked `#[frb(unignore)]`: `Document`, `StoredAccount`, `StoredGroup`
// These function are ignored because they are on traits that is not defined in current crate (put an empty `#[frb]` on it to unignore): `drop`, `drop`, `drop`, `zeroize`, `zeroize`, `zeroize`

class AccountInputV1 {
  final String? id;
  final String name;
  final String description;
  final String login;
  final String password;
  final List<String> groupIds;

  const AccountInputV1({
    this.id,
    required this.name,
    required this.description,
    required this.login,
    required this.password,
    required this.groupIds,
  });

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      login.hashCode ^
      password.hashCode ^
      groupIds.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountInputV1 &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          login == other.login &&
          password == other.password &&
          groupIds == other.groupIds;
}

class AccountRecordV1 {
  final String id;
  final String name;
  final String description;
  final String login;
  final String password;
  final List<String> groupIds;

  const AccountRecordV1({
    required this.id,
    required this.name,
    required this.description,
    required this.login,
    required this.password,
    required this.groupIds,
  });

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      login.hashCode ^
      password.hashCode ^
      groupIds.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountRecordV1 &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          login == other.login &&
          password == other.password &&
          groupIds == other.groupIds;
}

class AccountSummaryV1 {
  final String id;
  final String name;
  final List<String> groupIds;

  const AccountSummaryV1({
    required this.id,
    required this.name,
    required this.groupIds,
  });

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ groupIds.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountSummaryV1 &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          groupIds == other.groupIds;
}

class ContentSnapshotV1 {
  final BigInt revision;
  final List<GroupRecordV1> groups;
  final List<AccountSummaryV1> accounts;

  const ContentSnapshotV1({
    required this.revision,
    required this.groups,
    required this.accounts,
  });

  @override
  int get hashCode => revision.hashCode ^ groups.hashCode ^ accounts.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentSnapshotV1 &&
          runtimeType == other.runtimeType &&
          revision == other.revision &&
          groups == other.groups &&
          accounts == other.accounts;
}

class GroupInputV1 {
  final String? id;
  final String name;
  final String description;
  final String icon;
  final Uint8List logo;

  const GroupInputV1({
    this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.logo,
  });

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      icon.hashCode ^
      logo.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroupInputV1 &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          icon == other.icon &&
          logo == other.logo;
}

class GroupRecordV1 {
  final String id;
  final String name;
  final String description;
  final String icon;
  final Uint8List logo;

  const GroupRecordV1({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.logo,
  });

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      icon.hashCode ^
      logo.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroupRecordV1 &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          icon == other.icon &&
          logo == other.logo;
}
