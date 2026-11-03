import 'package:want_pass_core/src/feature/vault/application/_barrel.dart';
import 'package:want_pass_core/src/feature/vault/infrastructure/_barrel.dart';

Future<VaultAccessService> initializeVaultAccess({
  required String directory,
  required VaultReporter reporter,
}) async {
  await initializeVaultBridge();
  return RustVaultAccessService(directory, reporter);
}
