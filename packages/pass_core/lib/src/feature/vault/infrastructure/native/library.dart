import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:want_pass_core/src/feature/vault/domain/_barrel.dart';
import 'package:want_pass_core/src/feature/vault/infrastructure/_barrel.dart';

@Native<Pointer<Utf8> Function()>(symbol: 'want_pass_vault_library_path')
external Pointer<Utf8> _libraryPath();

Future<void> initializeVaultBridge() async {
  if (VaultRustLib.instance.initialized) return;
  final path = _libraryPath();
  if (path.address == 0) {
    throw const VaultRejectedErrorV1(VaultFailureKindV1.unavailable);
  }
  await VaultRustLib.init(
    externalLibrary: ExternalLibrary.open(path.toDartString()),
  );
}
