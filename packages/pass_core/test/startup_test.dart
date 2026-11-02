import 'dart:isolate';

import 'package:test/test.dart';
import 'package:want_pass_core/want_pass_core.dart';

void main() {
  test(
    'an uninitialized isolate receives an explicit startup failure',
    () async {
      final identifier = await Isolate.run(
        () => checkForegroundStartup().error.typeIdentifier,
      );
      expect(identifier, 'application.not_initialized');
    },
  );

  test('foreground startup needs no backend or network dependency', () {
    initPackage(
      config: const Config(isForeground: true),
      dependencies: const Dependencies(),
    );
    expect(checkForegroundStartup().isSuccess, isTrue);
  });

  test('a refreshed background graph cannot start foreground UI', () {
    initPackage(
      config: const Config(isForeground: true),
      dependencies: const Dependencies(),
    );
    initPackage(
      config: const Config(isForeground: false),
      dependencies: const Dependencies(),
    );
    final result = checkForegroundStartup();
    expect(result.isError, isTrue);
    expect(
      result.error,
      const StartupFailure(StartupFailureKind.foregroundRequired),
    );
  });
}
