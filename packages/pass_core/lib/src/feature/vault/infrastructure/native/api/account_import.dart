// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import 'package:want_pass_core/src/feature/vault/infrastructure/_barrel.dart';

import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

// These types are ignored because they are neither used by any `pub` functions nor (for structs and enums) marked `#[frb(unignore)]`: `ImportRow`, `PendingImport`
// These function are ignored because they are on traits that is not defined in current crate (put an empty `#[frb]` on it to unignore): `clone`, `drop`, `zeroize`

class AccountImportPreviewV1 {
  final String token;
  final List<AccountImportRowV1> rows;

  const AccountImportPreviewV1({required this.token, required this.rows});

  @override
  int get hashCode => token.hashCode ^ rows.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountImportPreviewV1 &&
          runtimeType == other.runtimeType &&
          token == other.token &&
          rows == other.rows;
}

class AccountImportRowV1 {
  final String name;
  final bool duplicate;

  const AccountImportRowV1({required this.name, required this.duplicate});

  @override
  int get hashCode => name.hashCode ^ duplicate.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountImportRowV1 &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          duplicate == other.duplicate;
}

enum AccountImportSourceV1 { applePasswords, authenticator }
