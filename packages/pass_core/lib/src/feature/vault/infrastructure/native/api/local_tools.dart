// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import 'package:want_pass_core/src/feature/vault/infrastructure/_barrel.dart';

import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

// These functions are ignored because they are not marked as `pub`: `check_tool_grant`, `encode`, `parse`
// These types are ignored because they are neither used by any `pub` functions nor (for structs and enums) marked `#[frb(unignore)]`: `ProfileInput`, `Scope`, `SigningRequest`, `SshProfile`, `ToolRequest`
// These function are ignored because they are on traits that is not defined in current crate (put an empty `#[frb]` on it to unignore): `assert_receiver_is_total_eq`, `assert_receiver_is_total_eq`, `clone`, `clone`, `clone`, `cmp`, `eq`, `eq`, `partial_cmp`, `zeroize`

Future<String> localToolSubjectV1({
  required LocalToolCommandV1 command,
  required String body,
}) => VaultRustLib.instance.api.crateApiLocalToolsLocalToolSubjectV1(
  command: command,
  body: body,
);

enum LocalToolCommandV1 {
  dashboard,
  configure,
  disconnect,
  grant,
  revoke,
  request,
  publicKey,
  agentIdentity,
  agentSign,
}
