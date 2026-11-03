import 'package:want_pass_core/src/feature/vault/domain/_barrel.dart';

enum VaultDiagnosticLayer { infrastructure, application, controller }

abstract interface class VaultReporter {
  const VaultReporter();
  void reportVault({
    required VaultDiagnosticLayer layer,
    required String operation,
    required VaultErrorV1 error,
  });
}

void reportVaultSafely(
  VaultReporter reporter, {
  required VaultDiagnosticLayer layer,
  required String operation,
  required VaultErrorV1 error,
}) {
  try {
    reporter.reportVault(layer: layer, operation: operation, error: error);
  } on Object {
    // Reporting cannot change a vault operation or retain its sensitive input.
  }
}
