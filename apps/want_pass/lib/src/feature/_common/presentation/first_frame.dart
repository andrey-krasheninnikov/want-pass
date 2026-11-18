import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:want_pass/src/feature/vault/presentation/_barrel.dart';

Future<void> presentWantPass(Widget app) async {
  final ready = Completer<void>();
  final stream = vaultSplashLogo.resolve(ImageConfiguration.empty);
  final listener = ImageStreamListener(
    (image, _) {
      image.dispose();
      if (!ready.isCompleted) ready.complete();
    },
    onError: (_, _) {
      if (!ready.isCompleted) ready.complete();
    },
  );
  stream.addListener(listener);
  await ready.future;
  runApp(app);
  WidgetsBinding.instance.addPostFrameCallback((_) {
    stream.removeListener(listener);
    unawaited(signalWantPassFirstFrame());
  });
}

Future<bool> signalWantPassFirstFrame() async {
  if (defaultTargetPlatform != TargetPlatform.macOS || kIsWeb) return true;
  await WidgetsBinding.instance.waitUntilFirstFrameRasterized;
  return await const MethodChannel('want_pass/splash')
          .invokeMethod<bool>('firstFrame') ==
      true;
}
