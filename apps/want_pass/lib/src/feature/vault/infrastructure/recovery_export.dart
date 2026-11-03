import 'package:domain_error/domain_error.dart';
import 'package:flutter/services.dart';
import 'package:file_selector/file_selector.dart';
import 'package:injectable/injectable.dart';
import 'package:want_pass/src/feature/vault/application/_barrel.dart';
import 'package:want_pass_core/want_pass_core.dart';

@Singleton(as: RecoveryExportService)
final class PlatformRecoveryExportService implements RecoveryExportService {
  final VaultReporter _reporter;
  const PlatformRecoveryExportService(this._reporter);
  @override
  FutureDomainResult<String?> selectFileV1() async {
    const op = 'PlatformRecoveryExportService.selectFileV1():';
    final result = await captureResult<String?>(
      () async => (await getSaveLocation(
        suggestedName: 'want-pass-recovery.txt',
        acceptedTypeGroups: [
          const XTypeGroup(label: 'TXT', extensions: ['txt']),
        ],
      ))?.path,
      mapToDomainError: (_, _) => const VaultUnexpectedErrorV1(),
    );
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.infrastructure,
        operation: op,
        error: const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<String?> selectFileV3() async {
    const op = 'PlatformRecoveryExportService.selectFileV3():';
    final result = await captureResult<String?>(
      () async => (await getSaveLocation(
        suggestedName: 'want-pass-recovery.json',
        acceptedTypeGroups: [
          const XTypeGroup(label: 'JSON', extensions: ['json']),
        ],
      ))?.path,
      mapToDomainError: (_, _) => const VaultUnexpectedErrorV1(),
    );
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.infrastructure,
        operation: op,
        error: const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<void> copyV1(String phrase) async {
    const op = 'PlatformRecoveryExportService.copyV1():';
    final result = await captureResult<void>(
      () => Clipboard.setData(ClipboardData(text: phrase)),
      mapToDomainError: (_, _) => const VaultUnexpectedErrorV1(),
    );
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.infrastructure,
        operation: op,
        error: const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<void> clearClipboardV1(String expected) async {
    const op = 'PlatformRecoveryExportService.clearClipboardV1():';
    final result = await captureResult<void>(() async {
      if ((await Clipboard.getData(Clipboard.kTextPlain))?.text == expected) {
        await Clipboard.setData(const ClipboardData(text: ''));
      }
    }, mapToDomainError: (_, _) => const VaultUnexpectedErrorV1());
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.infrastructure,
        operation: op,
        error: const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }
}
