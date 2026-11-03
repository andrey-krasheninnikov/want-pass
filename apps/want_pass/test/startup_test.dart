import 'package:want_pass/src/feature/vault/infrastructure/_barrel.dart';

import 'dart:async';
import 'dart:isolate';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:bloc_effects/bloc_effects.dart';
import 'package:domain_error/domain_error.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:launch_mode/launch_mode.dart';
import 'package:talker/talker.dart';
import 'package:want_pass/src/core/_barrel.dart';
import 'package:want_pass/src/feature/_common/presentation/_barrel.dart';
import 'package:want_pass/src/feature/startup/application/_barrel.dart';
import 'package:want_pass/src/feature/startup/infrastructure/_barrel.dart';
import 'package:want_pass_core/want_pass_core.dart';
import 'package:want_pass/src/feature/vault/application/_barrel.dart';

final class _Access implements StartupAccessService {
  final FutureDomainResult<void> Function() run;

  const _Access(this.run);

  @override
  FutureDomainResult<void> checkForegroundV1() => run();
}

final class _UseCase implements StartupUseCase {
  final FutureDomainResult<InitializeStartupResultV1> Function() run;
  int calls = 0;

  _UseCase(this.run);

  @override
  FutureDomainResult<InitializeStartupResultV1> initializeV1({
    required InitializeStartupParamsV1 params,
  }) {
    calls++;
    return run();
  }
}

final class _Reporter implements StartupReporter {
  final layers = <StartupDiagnosticLayer>[];
  bool broken = false;

  @override
  void report({
    required StartupDiagnosticLayer layer,
    required String operation,
    required StartupDiagnosticEvent event,
    StartupErrorV1? error,
  }) {
    if (broken) {
      throw const _PrivatePayload();
    }
    layers.add(layer);
  }
}

final class _ProbeCubit extends CubitWithEffects<Object, Object> {
  _ProbeCubit() : super(Object());

  void change(Object value) => emit(value);
  void fail(Object error) => addError(error, StackTrace.current);
}

final class _PrivatePayload {
  const _PrivatePayload();

  @override
  String toString() => throw StateError('Payload formatting is forbidden');
}

final class _ForeignErrorV1 extends DomainError {
  const _ForeignErrorV1();

  @override
  String get typeIdentifier => '_ForeignErrorV1';
}

final class _BrokenTalker extends Talker {
  @override
  void log(
    dynamic message, {
    LogLevel logLevel = LogLevel.debug,
    Object? exception,
    StackTrace? stackTrace,
    AnsiPen? pen,
  }) => throw const _PrivatePayload();

  @override
  void logCustom(TalkerLog log) => throw const _PrivatePayload();
}

FutureDomainResult<InitializeStartupResultV1> _success() async =>
    const Result.success(InitializeStartupResultV1());

final class _VaultHandle implements VaultHandleV1 {
  const _VaultHandle();
  @override
  void invalidateSync() {}
  @override
  Future<void> close() async {}
}

final class _VaultAccess implements VaultAccessService {
  const _VaultAccess();
  @override
  FutureDomainResult<void> waitForExportsV2({
    required VaultHandleV1 handle,
  }) async => const Result.success(null);

  @override
  FutureDomainResult<VaultHintsDtoV2> hintsV2({
    required VaultHandleV1 handle,
  }) async => const Result.success(VaultHintsDtoV2());
  @override
  FutureDomainResult<VaultRecoveryChallengeV2> prepareCreationV2({
    required VaultHandleV1 handle,
    required String password,
  }) async =>
      const Result.error(VaultRejectedErrorV1(VaultFailureKindV1.unavailable));
  @override
  FutureDomainResult<VaultRecoveryChallengeV2> prepareRecoveryV2({
    required VaultHandleV1 handle,
    required String phrase,
    required String password,
  }) async =>
      const Result.error(VaultRejectedErrorV1(VaultFailureKindV1.unavailable));
  @override
  FutureDomainResult<void> confirmV2({
    required VaultHandleV1 handle,
    required List<String> answers,
    required String password,
    required VaultHintsDtoV2 hints,
  }) async =>
      const Result.error(VaultRejectedErrorV1(VaultFailureKindV1.unavailable));
  @override
  FutureDomainResult<void> exportRecoveryV2({
    required VaultHandleV1 handle,
    required String destination,
  }) async =>
      const Result.error(VaultRejectedErrorV1(VaultFailureKindV1.unavailable));

  @override
  FutureDomainResult<VaultHandleV1> openV1() async =>
      const Result.success(_VaultHandle());
  @override
  FutureDomainResult<VaultAccessStateV1> statusV1({
    required VaultHandleV1 handle,
  }) async => const Result.success(VaultAccessStateV1.missing);
  @override
  FutureDomainResult<VaultRecoveryChallengeV1> prepareCreationV1({
    required VaultHandleV1 handle,
    required String password,
  }) async =>
      const Result.error(VaultRejectedErrorV1(VaultFailureKindV1.unavailable));
  @override
  FutureDomainResult<VaultRecoveryChallengeV1> prepareRecoveryV1({
    required VaultHandleV1 handle,
    required String phrase,
    required String password,
  }) async =>
      const Result.error(VaultRejectedErrorV1(VaultFailureKindV1.unavailable));
  @override
  FutureDomainResult<void> confirmV1({
    required VaultHandleV1 handle,
    required List<String> answers,
  }) async =>
      const Result.error(VaultRejectedErrorV1(VaultFailureKindV1.unavailable));
  @override
  FutureDomainResult<void> unlockV1({
    required VaultHandleV1 handle,
    required String password,
  }) async =>
      const Result.error(VaultRejectedErrorV1(VaultFailureKindV1.unavailable));
}

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    binding.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
  });
  tearDown(binding.platformDispatcher.clearAccessibilityFeaturesTestValue);
  LaunchMode.initializeAutomatically();
  late Talker talker;
  late SafeBlocObserver observer;
  late BlocObserver previousObserver;
  late StreamController<VaultLockSignal> vaultLockEvents;
  late Stream<VaultLockSignal> vaultEvents;
  late Directory preferencesDirectory;

  setUp(() {
    preferencesDirectory = Directory.systemTemp.createTempSync(
      'want-pass-preferences-test-',
    );
    vaultLockEvents = StreamController<VaultLockSignal>.broadcast();
    vaultEvents = vaultLockEvents.stream;
    talker = Talker(settings: TalkerSettings(useConsoleLogs: false));
    observer = SafeBlocObserver(talker: talker);
    previousObserver = Bloc.observer;
    Bloc.observer = observer;
  });

  tearDown(() async {
    Bloc.observer = previousObserver;
    await vaultLockEvents.close();
    await preferencesDirectory.delete(recursive: true);
  });

  Future<AppRuntime> bootstrapRuntime() => AppRuntime.bootstrap(
    vaultAccess: const _VaultAccess(),
    vaultLockEvents: vaultEvents,
    preferencesDirectory: preferencesDirectory.path,
  );

  Future<VaultController> shellVault() async {
    final controller = VaultController(
      VaultUseCaseImpl(
        const _VaultAccess(),
        observer,
        PlatformRecoveryExportService(observer),
      ),
      observer,
      vaultEvents,
    );
    addTearDown(controller.close);
    await controller.init();
    return controller;
  }

  Future<StartupController> start({required bool foreground}) async {
    final runtime = initPackage(
      config: Config(isForeground: foreground),
      dependencies: Dependencies(reporter: observer),
    );
    addTearDown(runtime.close);
    final startup = StartupController(
      StartupUseCaseImpl(runtime.startupAccessService, observer),
      observer,
    );
    addTearDown(startup.close);
    await startup.init();
    return startup;
  }

  testWidgets('the local shell starts without a backend', (tester) async {
    final startup = await start(foreground: true);
    await tester.pumpWidget(
      WantPassApp(
        startup: startup,
        vault: (await tester.runAsync(shellVault))!,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Master password'), findsWidgets);
    expect(find.byKey(const ValueKey('vault-create')), findsOneWidget);
    expect(startup.state, const StartupReady());
    expect(
      talker.history.single.message,
      'controller StartupController.init(): ready',
    );
    await tester.pumpWidget(const SizedBox.shrink());
    expect(startup.isClosed, isFalse);
  });

  testWidgets('a denied startup shows only a safe localized error', (
    tester,
  ) async {
    final startup = await start(foreground: false);
    await tester.pumpWidget(
      WantPassApp(
        startup: startup,
        vault: (await tester.runAsync(shellVault))!,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Startup unavailable'), findsOneWidget);
    expect(
      startup.state,
      const StartupFailed(StartupForegroundRequiredErrorV1()),
    );
    expect(talker.history, hasLength(3));
  });

  testWidgets(
    'the shell keeps Russian localization after the UI kit migration',
    (tester) async {
      tester.platformDispatcher.localesTestValue = const [Locale('ru')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      final startup = await start(foreground: true);
      await tester.pumpWidget(
        WantPassApp(
          startup: startup,
          vault: (await tester.runAsync(shellVault))!,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Мастер-пароль'), findsWidgets);
    },
  );

  test('use case maps success and has no retained state', () async {
    var calls = 0;
    final useCase = StartupUseCaseImpl(
      _Access(() async {
        calls++;
        return const Result.success(null);
      }),
      observer,
    );
    final first = await useCase.initializeV1(
      params: const InitializeStartupParamsV1(),
    );
    final second = await useCase.initializeV1(
      params: const InitializeStartupParamsV1(),
    );
    expect(first.value, const InitializeStartupResultV1());
    expect(second.value, first.value);
    expect(calls, 2);
  });

  test('use case preserves every startup domain error instance', () async {
    for (final error in <StartupErrorV1>[
      const StartupNotInitializedErrorV1(),
      const StartupForegroundRequiredErrorV1(),
      const StartupConfigurationConflictErrorV1(),
      const StartupUnexpectedErrorV1(),
    ]) {
      final reporter = _Reporter();
      final useCase = StartupUseCaseImpl(
        _Access(() async => Result.error(error)),
        reporter,
      );
      final result = await useCase.initializeV1(
        params: const InitializeStartupParamsV1(),
      );
      expect(identical(result.error, error), isTrue);
      expect(reporter.layers, [StartupDiagnosticLayer.application]);
    }
  });

  test(
    'unexpected application exceptions become typed errors without disclosure',
    () async {
      final useCase = StartupUseCaseImpl(
        _Access(() async => throw const _PrivatePayload()),
        observer,
      );
      final result = await useCase.initializeV1(
        params: const InitializeStartupParamsV1(),
      );
      expect(result.error, isA<StartupUnexpectedErrorV1>());
      expect(identical(result.error.cause, const _PrivatePayload()), isTrue);
      expect(
        talker.history.single.message,
        'application StartupUseCaseImpl.initializeV1(): unexpectedError',
      );
      expect(talker.history.single.error, isNull);
    },
  );

  test('reporter failure preserves an application result', () async {
    final reporter = _Reporter()..broken = true;
    final useCase = StartupUseCaseImpl(
      _Access(() async => const Result.error(StartupNotInitializedErrorV1())),
      reporter,
    );
    expect(
      (await useCase.initializeV1(params: const InitializeStartupParamsV1()))
          .error,
      const StartupNotInitializedErrorV1(),
    );
  });

  test('DTOs and startup states compare their semantic values', () {
    expect(
      const InitializeStartupParamsV1(),
      const InitializeStartupParamsV1(),
    );
    expect(
      const InitializeStartupResultV1(),
      const InitializeStartupResultV1(),
    );
    expect(const StartupLoading(), const StartupLoading());
    expect(const StartupReady(), isNot(const StartupLoading()));
    expect(
      const StartupFailed(StartupNotInitializedErrorV1()),
      isNot(const StartupFailed(StartupForegroundRequiredErrorV1())),
    );
  });

  test('concurrent and repeated init share one operation', () async {
    final completion = Completer<DomainResult<InitializeStartupResultV1>>();
    final useCase = _UseCase(() => completion.future);
    final controller = StartupController(useCase, observer);
    addTearDown(controller.close);
    expect(controller.state, const StartupLoading());
    final first = controller.init();
    final second = controller.init();
    expect(identical(first, second), isTrue);
    completion.complete(const Result.success(InitializeStartupResultV1()));
    await first;
    await controller.init();
    expect(useCase.calls, 1);
    expect(controller.state, const StartupReady());
  });

  test('controller exhaustively maps typed error results', () async {
    for (final error in <StartupErrorV1>[
      const StartupNotInitializedErrorV1(),
      const StartupForegroundRequiredErrorV1(),
      const StartupConfigurationConflictErrorV1(),
      const StartupUnexpectedErrorV1(),
    ]) {
      final controller = StartupController(
        _UseCase(() async => Result.error(error)),
        observer,
      );
      await controller.init();
      expect(controller.state, StartupFailed(error));
      await controller.close();
    }
  });

  test('controller gives an unrelated domain error a safe fallback', () async {
    final controller = StartupController(
      _UseCase(() async => const Result.error(_ForeignErrorV1())),
      observer,
    );
    addTearDown(controller.close);
    await controller.init();
    expect(controller.state, const StartupFailed(StartupUnexpectedErrorV1()));
  });

  test('background initialization does not invoke the use case', () async {
    await LaunchMode.withBackgroundMode(() async {
      final useCase = _UseCase(_success);
      final controller = StartupController(useCase, observer);
      await controller.init();
      expect(
        controller.state,
        const StartupFailed(StartupForegroundRequiredErrorV1()),
      );
      expect(useCase.calls, 0);
      await controller.close();
    });
  });

  test(
    'fresh worker contexts require initialization and deny foreground startup',
    () async {
      for (final initialize in [false, true]) {
        final result = await Isolate.run(() async {
          if (initialize) {
            LaunchMode.initializeAutomatically();
          }
          final useCase = _UseCase(_success);
          final controller = StartupController(useCase, _Reporter());
          await controller.init();
          final error = (controller.state as StartupFailed).error;
          await controller.close();
          return (error.typeIdentifier, useCase.calls, LaunchMode.isIsolate);
        });
        expect(
          result.$1,
          initialize
              ? 'StartupForegroundRequiredErrorV1'
              : 'StartupNotInitializedErrorV1',
        );
        expect(result.$2, 0);
        expect(result.$3, initialize);
      }
    },
  );

  test(
    'close completes the stream and prevents late state emissions',
    () async {
      final completion = Completer<DomainResult<InitializeStartupResultV1>>();
      final controller = StartupController(
        _UseCase(() => completion.future),
        observer,
      );
      final states = <StartupState>[];
      final subscription = controller.stream.listen(states.add);
      final done = subscription.asFuture<void>();
      final initialization = controller.init();
      final close = controller.close();
      expect(identical(close, controller.close()), isTrue);
      await close;
      await done;
      completion.complete(const Result.success(InitializeStartupResultV1()));
      await initialization;
      await controller.init();
      expect(controller.isClosed, isTrue);
      expect(states, isEmpty);
    },
  );

  test(
    'arbitrary states, effects and errors are not formatted or retained',
    () async {
      final probe = _ProbeCubit();
      addTearDown(probe.close);
      const payload = _PrivatePayload();
      probe.change(payload);
      probe.emitEffect(payload);
      probe.fail(payload);
      observer.onEffect(payload);
      observer.report(
        layer: StartupDiagnosticLayer.framework,
        operation: 'untrusted operation text',
        event: StartupDiagnosticEvent.failure,
        error: const StartupUnexpectedErrorV1(cause: payload),
      );
      expect(talker.history, hasLength(2));
      expect(
        talker.history.last.message,
        'framework unknownOperation unexpectedError',
      );
      for (final entry in talker.history) {
        expect(entry.error, isNull);
        expect(entry.exception, isNull);
        expect(entry.stackTrace, isNull);
      }
    },
  );

  test(
    'allowlisted effects and diagnostic sink failures are isolated',
    () async {
      observer.onEffect(StartupDiagnosticEvent.ready);
      expect(
        talker.history.single.message,
        contains('StartupDiagnosticEvent.ready'),
      );
      final broken = SafeBlocObserver(talker: _BrokenTalker());
      broken.onEffect(StartupDiagnosticEvent.ready);
      broken.report(
        layer: StartupDiagnosticLayer.framework,
        operation: 'SafeBlocObserver.onEffect():',
        event: StartupDiagnosticEvent.observerError,
      );
    },
  );

  testWidgets('framework errors use a generic fallback and restore handlers', (
    tester,
  ) async {
    final oldHandler = FlutterError.onError;
    final oldBuilder = ErrorWidget.builder;
    final dispatcher = WidgetsBinding.instance.platformDispatcher;
    final oldPlatformHandler = dispatcher.onError;
    final scope = ErrorReportingScope(observer);
    addTearDown(scope.close);
    final details = FlutterErrorDetails(exception: const _PrivatePayload());
    FlutterError.reportError(details);
    await tester.pumpWidget(ErrorWidget.builder(details));
    expect(
      find.text('Want Pass could not display this screen.'),
      findsOneWidget,
    );
    expect(
      talker.history.single.message,
      'framework ErrorReportingScope.frameworkError(): unexpectedError',
    );
    scope.close();
    expect(identical(FlutterError.onError, oldHandler), isTrue);
    expect(identical(ErrorWidget.builder, oldBuilder), isTrue);
    expect(identical(dispatcher.onError, oldPlatformHandler), isTrue);
  });

  test('closing a diagnostic scope preserves a newer handler owner', () {
    final oldHandler = FlutterError.onError;
    final scope = ErrorReportingScope(observer);
    void replacement(FlutterErrorDetails details) {}
    FlutterError.onError = replacement;
    scope.close();
    expect(identical(FlutterError.onError, replacement), isTrue);
    FlutterError.onError = oldHandler;
  });

  test(
    'runtime bootstrap reuses DI and disposes its singleton controller',
    () async {
      final oldHandler = FlutterError.onError;
      final first = bootstrapRuntime();
      expect(identical(first, bootstrapRuntime()), isTrue);
      final runtime = await first;
      addTearDown(runtime.close);
      final controller = runtime.startup;
      expect(identical(controller, runtime.startup), isTrue);
      expect(controller.state, const StartupReady());
      await LaunchMode.withBackgroundMode(() async {
        await expectLater(
          bootstrapRuntime(),
          throwsA(isA<StartupConfigurationConflictErrorV1>()),
        );
      });
      await runtime.close();
      expect(controller.isClosed, isTrue);
      expect(identical(FlutterError.onError, oldHandler), isTrue);
      final next = await bootstrapRuntime();
      addTearDown(next.close);
      expect(identical(next, runtime), isFalse);
      await next.close();
    },
  );

  test(
    'failed bootstrap restores handlers and preserves an existing core runtime',
    () async {
      final core = initPackage(
        config: const Config(isForeground: true),
        dependencies: Dependencies(reporter: observer),
      );
      addTearDown(core.close);
      final oldHandler = FlutterError.onError;
      final oldObserver = Bloc.observer;
      await expectLater(
        bootstrapRuntime(),
        throwsA(isA<StartupConfigurationConflictErrorV1>()),
      );
      expect(identical(FlutterError.onError, oldHandler), isTrue);
      expect(identical(Bloc.observer, oldObserver), isTrue);
      expect(
        (await core.startupAccessService.checkForegroundV1()).isSuccess,
        isTrue,
      );
    },
  );
}
