import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

void presentWantPass(Widget app) {
  runApp(app);
  WidgetsBinding.instance.addPostFrameCallback((_) {
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
