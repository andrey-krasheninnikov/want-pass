// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import 'package:want_pass_core/src/feature/vault/infrastructure/_barrel.dart';

import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

// These functions are ignored because they are not marked as `pub`: `accept`, `after_recovery`, `is_empty`, `require_operation`, `requires`, `seconds`, `update_policy`, `validate_operations`, `verifier`, `view`
// These types are ignored because they are neither used by any `pub` functions nor (for structs and enums) marked `#[frb(unignore)]`: `Pending`, `Permit`, `PolicyView`, `Policy`
// These function are ignored because they are on traits that is not defined in current crate (put an empty `#[frb]` on it to unignore): `assert_receiver_is_total_eq`, `clone`, `clone`, `drop`, `eq`, `fmt`, `zeroize`
// These functions are ignored (category: IgnoreBecauseOwnerTyShouldIgnore): `default`, `default`, `default`

enum OperationV1 {
  reveal,
  copy,
  export_,
  transfer,
  integrationGrant,
  recoveryKit,
  delete,
  protection,
}

class ProtectionSettingsV1 {
  final bool enrolled;
  final List<OperationV1> operations;

  const ProtectionSettingsV1({
    required this.enrolled,
    required this.operations,
  });

  @override
  int get hashCode => enrolled.hashCode ^ operations.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProtectionSettingsV1 &&
          runtimeType == other.runtimeType &&
          enrolled == other.enrolled &&
          operations == other.operations;
}
