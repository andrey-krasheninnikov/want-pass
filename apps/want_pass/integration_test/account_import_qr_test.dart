import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:integration_test/integration_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('macOS Vision reads a local QR image and rejects a blank image', (
    tester,
  ) async {
    const channel = MethodChannel('want_pass/import_qr');
    const uri = 'otpauth://totp/Test?secret=GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ';
    final qr = QrImage(
      QrCode.fromData(data: uri, errorCorrectLevel: QrErrorCorrectLevel.M),
    );
    const scale = 8;
    const margin = 4;
    final size = (qr.moduleCount + 2 * margin) * scale;
    final bitmap = image.Image(width: size, height: size);
    image.fill(bitmap, color: image.ColorRgb8(255, 255, 255));
    final blank = image.encodePng(bitmap);
    for (var row = 0; row < qr.moduleCount; row++) {
      for (var column = 0; column < qr.moduleCount; column++) {
        if (!qr.isDark(row, column)) continue;
        final x = (column + margin) * scale;
        final y = (row + margin) * scale;
        image.fillRect(
          bitmap,
          x1: x,
          y1: y,
          x2: x + scale - 1,
          y2: y + scale - 1,
          color: image.ColorRgb8(0, 0, 0),
        );
      }
    }
    final results = await channel.invokeListMethod<String>(
      'decode',
      image.encodePng(bitmap),
    );
    expect(results?.length, 1);
    expect(results?.first == uri, isTrue);
    await expectLater(
      channel.invokeMethod<void>('decode', blank),
      throwsA(isA<PlatformException>()),
    );
  });
}
