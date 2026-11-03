import 'dart:typed_data';

import 'package:domain_error/domain_error.dart';
import 'package:file_selector/file_selector.dart';
import 'package:injectable/injectable.dart';
import 'package:want_pass/src/feature/vault/application/_barrel.dart';
import 'package:want_pass_core/want_pass_core.dart';

@Singleton(as: CredentialFileService)
final class PlatformCredentialFileService implements CredentialFileService {
  final VaultReporter _reporter;
  const PlatformCredentialFileService(this._reporter);
  @override
  FutureDomainResult<AttachmentDraftV1?> selectAttachmentV1() async {
    const op = 'PlatformCredentialFileService.selectAttachmentV1():';
    final result = await captureResult<AttachmentDraftV1?>(() async {
      final file = await openFile();
      if (file == null) return null;
      const limit = 20 * 1024 * 1024;
      if (await file.length() > limit) {
        throw const VaultRejectedErrorV1(VaultFailureKindV1.unsupported);
      }
      final builder = BytesBuilder(copy: false);
      await for (final chunk in file.openRead(0, limit + 1)) {
        builder.add(chunk);
        if (builder.length > limit) {
          throw const VaultRejectedErrorV1(VaultFailureKindV1.unsupported);
        }
      }
      return AttachmentDraftV1(
        name: file.name,
        bytes: List.unmodifiable(builder.takeBytes()),
      );
    }, mapToDomainError: (_, _) => const VaultUnexpectedErrorV1());
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.infrastructure,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<String?> selectDestinationV1(String name) async {
    const op = 'PlatformCredentialFileService.selectDestinationV1():';
    final result = await captureResult<String?>(
      () async => (await getSaveLocation(suggestedName: name))?.path,
      mapToDomainError: (_, _) => const VaultUnexpectedErrorV1(),
    );
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.infrastructure,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }
}
