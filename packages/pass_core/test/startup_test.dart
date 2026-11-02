import 'package:package_context/package_context.dart';
import 'package:test/test.dart';
import 'package:want_pass_core/src/feature/startup/infrastructure/_barrel.dart';
import 'package:want_pass_core/want_pass_core.dart';

final class _Reporter implements StartupReporter {
  final layers = <StartupDiagnosticLayer>[];
  final errors = <StartupErrorV1?>[];

  @override
  void report({
    required StartupDiagnosticLayer layer,
    required String operation,
    required StartupDiagnosticEvent event,
    StartupErrorV1? error,
  }) {
    layers.add(layer);
    errors.add(error);
  }
}

final class _BrokenReporter implements StartupReporter {
  int calls = 0;

  @override
  void report({
    required StartupDiagnosticLayer layer,
    required String operation,
    required StartupDiagnosticEvent event,
    StartupErrorV1? error,
  }) {
    calls++;
    throw StateError('Diagnostic sink is unavailable');
  }
}

void main() {
  test('an empty package context returns a typed error', () async {
    final reporter = _Reporter();
    final service = StartupAccessServiceImpl(
      PackageContext<Config, Dependencies>(),
      reporter,
    );
    final result = await service.checkForegroundV1();
    expect(result.isError, isTrue);
    expect(result.error, const StartupNotInitializedErrorV1());
    expect(reporter.layers, [StartupDiagnosticLayer.infrastructure]);
    expect(identical(reporter.errors.single, result.error), isTrue);
  });

  test(
    'foreground startup works without a backend and reuses its package runtime',
    () async {
      final reporter = _Reporter();
      final runtime = initPackage(
        config: const Config(isForeground: true),
        dependencies: Dependencies(reporter: reporter),
      );
      addTearDown(runtime.close);
      expect(
        identical(
          initPackage(
            config: const Config(isForeground: true),
            dependencies: Dependencies(reporter: reporter),
          ),
          runtime,
        ),
        isTrue,
      );
      expect(
        (await runtime.startupAccessService.checkForegroundV1()).isSuccess,
        isTrue,
      );
      expect(reporter.layers, isEmpty);
    },
  );

  test('a conflicting package graph leaves the current graph intact', () async {
    final reporter = _Reporter();
    final runtime = initPackage(
      config: const Config(isForeground: true),
      dependencies: Dependencies(reporter: reporter),
    );
    addTearDown(runtime.close);
    expect(
      () => initPackage(
        config: const Config(isForeground: false),
        dependencies: Dependencies(reporter: reporter),
      ),
      throwsA(isA<StartupConfigurationConflictErrorV1>()),
    );
    expect(
      (await runtime.startupAccessService.checkForegroundV1()).isSuccess,
      isTrue,
    );
  });

  test('a background graph cannot start foreground UI', () async {
    final reporter = _Reporter();
    final runtime = initPackage(
      config: const Config(isForeground: false),
      dependencies: Dependencies(reporter: reporter),
    );
    addTearDown(runtime.close);
    final result = await runtime.startupAccessService.checkForegroundV1();
    expect(result.error, const StartupForegroundRequiredErrorV1());
    expect(reporter.errors, [const StartupForegroundRequiredErrorV1()]);
  });

  test(
    'package close is idempotent and allows another configuration',
    () async {
      final reporter = _Reporter();
      final first = initPackage(
        config: const Config(isForeground: true),
        dependencies: Dependencies(reporter: reporter),
      );
      first.close();
      first.close();
      final second = initPackage(
        config: const Config(isForeground: false),
        dependencies: Dependencies(reporter: reporter),
      );
      addTearDown(second.close);
      first.close();
      expect(
        identical(
          second,
          initPackage(
            config: const Config(isForeground: false),
            dependencies: Dependencies(reporter: reporter),
          ),
        ),
        isTrue,
      );
      expect(
        (await second.startupAccessService.checkForegroundV1()).isError,
        isTrue,
      );
    },
  );

  test('domain error identifiers match their public versioned types', () {
    final errors = <StartupErrorV1>[
      const StartupNotInitializedErrorV1(),
      const StartupForegroundRequiredErrorV1(),
      const StartupConfigurationConflictErrorV1(),
      const StartupUnexpectedErrorV1(),
    ];
    for (final error in errors) {
      expect(error.typeIdentifier, error.runtimeType.toString());
    }
    expect(
      StartupUnexpectedErrorV1(cause: Object(), stackTrace: StackTrace.current),
      StartupUnexpectedErrorV1(cause: Object()),
    );
    expect(
      const StartupNotInitializedErrorV1(),
      isNot(const StartupForegroundRequiredErrorV1()),
    );
  });

  test(
    'a broken reporter preserves the operation result without recursion',
    () async {
      final reporter = _BrokenReporter();
      final service = StartupAccessServiceImpl(
        PackageContext<Config, Dependencies>(),
        reporter,
      );
      expect(
        (await service.checkForegroundV1()).error,
        const StartupNotInitializedErrorV1(),
      );
      expect(reporter.calls, 2);
    },
  );
}
