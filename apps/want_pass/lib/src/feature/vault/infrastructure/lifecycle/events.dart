import 'dart:io';

import 'package:flutter/services.dart';
import 'package:want_pass/src/feature/vault/application/_barrel.dart';
import 'package:want_pass_core/want_pass_core.dart';

Future<Stream<VaultLockSignal>> createVaultLockEvents(
  VaultReporter reporter,
) async {
  const op = 'createVaultLockEvents():';
  try {
    if (!Platform.isMacOS) {
      throw const VaultRejectedErrorV1(VaultFailureKindV1.unsupported);
    }
    final ready = await const MethodChannel('want_pass/vault_lifecycle')
        .invokeMethod<bool>('ready');
    if (ready != true) {
      throw const VaultRejectedErrorV1(VaultFailureKindV1.unavailable);
    }
    return const EventChannel('want_pass/vault_lock_events')
        .receiveBroadcastStream()
        .map((event) {
          if (event != 'lock') {
            throw const VaultRejectedErrorV1(VaultFailureKindV1.unavailable);
          }
          return VaultLockSignal.lock;
        });
  } on Object catch (error, stack) {
    final mapped = error is VaultErrorV1
        ? error
        : const VaultUnexpectedErrorV1();
    reportVaultSafely(
      reporter,
      layer: VaultDiagnosticLayer.infrastructure,
      operation: op,
      error: mapped,
    );
    Error.throwWithStackTrace(mapped, stack);
  }
}
