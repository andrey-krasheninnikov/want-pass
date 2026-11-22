import 'dart:convert';
import 'dart:typed_data';

import 'package:domain_error/domain_error.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/services.dart' show Clipboard, MethodChannel;
import 'package:injectable/injectable.dart';
import 'package:want_pass/src/feature/vault/application/_barrel.dart';
import 'package:want_pass_core/want_pass_core.dart';

@Singleton(as: CredentialFileService)
final class PlatformCredentialFileService implements CredentialFileService {
  final VaultReporter _reporter;
  const PlatformCredentialFileService(this._reporter);

  @override
  FutureDomainResult<String?> withBackupDestinationV1(
    Future<bool> Function(String) save,
  ) async {
    const panel = MethodChannel('want_pass/backup_directory');
    return captureResult<String?>(() async {
      final String? path;
      if (defaultTargetPlatform == TargetPlatform.macOS) {
        path = await panel.invokeMethod<String>('choose');
      } else {
        final directory = await getDirectoryPath();
        if (directory == null) return null;
        final name =
            'want-pass-${DateTime.now().toUtc().microsecondsSinceEpoch}.wpassbackup';
        path = Uri.directory(directory).resolve(name).toFilePath();
      }
      if (path == null) return null;
      try {
        return await save(path) ? path : null;
      } finally {
        if (defaultTargetPlatform == TargetPlatform.macOS) {
          await panel.invokeMethod<void>('release', path);
        }
      }
    }, mapToDomainError: (_, _) => const VaultUnexpectedErrorV1());
  }

  @override
  FutureDomainResult<String?> selectBackupSourceV1() async {
    final result = await captureResult<String?>(
      () async => (await openFile())?.path,
      mapToDomainError: (_, _) => const VaultUnexpectedErrorV1(),
    );
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.infrastructure,
        operation: 'PlatformCredentialFileService.selectBackupSourceV1():',
        error: const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<List<String>?> selectAccountImportV1(
    AccountImportSourceV1 source, {
    required bool clipboard,
  }) async {
    const op = 'PlatformCredentialFileService.selectAccountImportV1():';
    final result = await captureResult<List<String>?>(
      () async {
        const bad = VaultRejectedErrorV1(VaultFailureKindV1.unsupported);
        if (clipboard) {
          final text = (await Clipboard.getData(Clipboard.kTextPlain))?.text;
          if (source != AccountImportSourceV1.authenticator ||
              text == null ||
              text.length > 2 * 1024 * 1024) {
            throw bad;
          }
          final uris = const LineSplitter()
              .convert(text)
              .map((v) => v.trim())
              .where((v) => v.isNotEmpty)
              .toList();
          if (uris.isEmpty || uris.length > 64) throw bad;
          return uris;
        }
        if (source == AccountImportSourceV1.applePasswords) {
          const type = XTypeGroup(
            label: 'CSV',
            extensions: ['csv'],
            uniformTypeIdentifiers: ['public.comma-separated-values-text'],
          );
          final file = await openFile(acceptedTypeGroups: [type]);
          if (file == null) return null;
          final bytes = await _boundedImportFile(file, 4 * 1024 * 1024);
          try {
            return [utf8.decode(bytes)];
          } finally {
            bytes.fillRange(0, bytes.length, 0);
          }
        }
        const images = XTypeGroup(
          label: 'QR',
          extensions: ['png', 'jpg', 'jpeg'],
          uniformTypeIdentifiers: ['public.png', 'public.jpeg'],
        );
        final files = await openFiles(acceptedTypeGroups: [images]);
        if (files.isEmpty) return null;
        if (files.length > 64) throw bad;
        const scanner = MethodChannel('want_pass/import_qr');
        final uris = <String>[];
        for (final file in files) {
          final bytes = await _boundedImportFile(file, 12 * 1024 * 1024);
          try {
            final decoded = await scanner.invokeListMethod<String>(
              'decode',
              bytes,
            );
            if (decoded == null ||
                decoded.isEmpty ||
                uris.length + decoded.length > 64) {
              throw bad;
            }
            uris.addAll(decoded);
          } finally {
            bytes.fillRange(0, bytes.length, 0);
          }
        }
        return uris;
      },
      mapToDomainError: (error, _) => error is VaultErrorV1
          ? error
          : const VaultRejectedErrorV1(VaultFailureKindV1.unsupported),
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

  static Future<Uint8List> _boundedImportFile(XFile file, int limit) async {
    const bad = VaultRejectedErrorV1(VaultFailureKindV1.unsupported);
    if (await file.length() > limit) throw bad;
    final builder = BytesBuilder(copy: false);
    await for (final chunk in file.openRead()) {
      if (builder.length + chunk.length > limit) throw bad;
      builder.add(chunk);
    }
    return builder.takeBytes();
  }

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
