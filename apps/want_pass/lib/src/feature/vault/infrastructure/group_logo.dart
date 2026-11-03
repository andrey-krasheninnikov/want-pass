import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:domain_error/domain_error.dart';
import 'package:file_selector/file_selector.dart';
import 'package:injectable/injectable.dart';
import 'package:want_pass/src/feature/vault/application/_barrel.dart';
import 'package:want_pass_core/want_pass_core.dart';

@Singleton(as: GroupLogoService)
final class PlatformGroupLogoService implements GroupLogoService {
  final VaultReporter _reporter;
  const PlatformGroupLogoService(this._reporter);
  @override
  FutureDomainResult<List<int>?> selectV1() async {
    const op = 'PlatformGroupLogoService.selectV1():';
    final result = await captureResult<List<int>?>(
      () async {
        final file = await openFile(
          acceptedTypeGroups: [
            const XTypeGroup(
              label: 'PNG / JPEG',
              extensions: ['png', 'jpg', 'jpeg'],
              uniformTypeIdentifiers: ['public.png', 'public.jpeg'],
            ),
          ],
        );
        if (file == null) return null;
        const limit = 5 * 1024 * 1024;
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
        final bytes = builder.takeBytes();
        final png =
            bytes.length >= 8 &&
            bytes[0] == 137 &&
            bytes[1] == 80 &&
            bytes[2] == 78 &&
            bytes[3] == 71;
        final jpeg =
            bytes.length >= 3 &&
            bytes[0] == 255 &&
            bytes[1] == 216 &&
            bytes[2] == 255;
        if (!png && !jpeg) {
          throw const VaultRejectedErrorV1(VaultFailureKindV1.unsupported);
        }
        final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
        try {
          final descriptor = await ui.ImageDescriptor.encoded(buffer);
          try {
            if (descriptor.width > 4096 || descriptor.height > 4096) {
              throw const VaultRejectedErrorV1(VaultFailureKindV1.unsupported);
            }
            final scale = math.min(
              1.0,
              256 / math.max(descriptor.width, descriptor.height),
            );
            final codec = await descriptor.instantiateCodec(
              targetWidth: math.max(1, (descriptor.width * scale).round()),
              targetHeight: math.max(1, (descriptor.height * scale).round()),
            );
            try {
              final frame = await codec.getNextFrame();
              try {
                final data = await frame.image.toByteData(
                  format: ui.ImageByteFormat.png,
                );
                if (data == null || data.lengthInBytes > 512 * 1024) {
                  throw const VaultRejectedErrorV1(
                    VaultFailureKindV1.unsupported,
                  );
                }
                return List<int>.unmodifiable(
                  data.buffer.asUint8List(
                    data.offsetInBytes,
                    data.lengthInBytes,
                  ),
                );
              } finally {
                frame.image.dispose();
              }
            } finally {
              codec.dispose();
            }
          } finally {
            descriptor.dispose();
          }
        } finally {
          buffer.dispose();
        }
      },
      mapToDomainError: (_, _) =>
          const VaultRejectedErrorV1(VaultFailureKindV1.unsupported),
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
