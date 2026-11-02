import 'package:bloc/bloc.dart';
import 'package:bloc_effects/bloc_effects.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talker/talker.dart';
import 'package:want_pass/application/startup_cubit.dart';
import 'package:want_pass/infrastructure/diagnostics.dart';
import 'package:want_pass/presentation/app.dart';
import 'package:want_pass_core/want_pass_core.dart' as core;

class _ProbeCubit extends CubitWithEffects<Object, Object> {
  _ProbeCubit() : super(Object());

  void change(Object value) => emit(value);

  void fail(Object error) => addError(error, StackTrace.current);
}

class _PrivatePayload {
  @override
  String toString() => throw StateError('Payload formatting is forbidden');
}

void main() {
  late Talker talker;
  late SafeBlocObserver observer;
  late BlocObserver previousObserver;

  setUp(() {
    talker = Talker(settings: TalkerSettings(useConsoleLogs: false));
    observer = SafeBlocObserver(talker: talker);
    previousObserver = Bloc.observer;
    Bloc.observer = observer;
  });

  tearDown(() {
    Bloc.observer = previousObserver;
  });

  StartupCubit start({required bool foreground}) {
    core.initPackage(
      config: core.Config(isForeground: foreground),
      dependencies: const core.Dependencies(),
    );
    return StartupCubit()..start();
  }

  testWidgets('the local shell starts without a backend', (tester) async {
    final startup = start(foreground: true);
    addTearDown(startup.close);
    await tester.pumpWidget(WantPassApp(startup: startup));
    await tester.pumpAndSettle();

    expect(find.text('Want Pass'), findsOneWidget);
    expect(find.text('A private home for your secrets.'), findsOneWidget);
    expect(startup.state, StartupState.ready);
    expect(
      talker.history.single.message,
      contains('DiagnosticEvent.startupReady'),
    );
  });

  testWidgets('a denied startup shows only a safe error', (tester) async {
    final startup = start(foreground: false);
    addTearDown(startup.close);
    await tester.pumpWidget(WantPassApp(startup: startup));
    await tester.pumpAndSettle();

    expect(find.text('Want Pass could not start.'), findsOneWidget);
    expect(startup.state, StartupState.failed);
    expect(
      talker.history.single.message,
      contains('DiagnosticEvent.startupFailed'),
    );
  });

  test(
    'arbitrary states, effects and errors are not formatted or retained',
    () async {
      final probe = _ProbeCubit();
      addTearDown(probe.close);
      final payload = _PrivatePayload();
      probe.change(payload);
      probe.emitEffect(payload);
      probe.fail(payload);
      observer.onEffect(payload);

      expect(talker.history, hasLength(1));
      expect(talker.history.single.message, 'unexpectedError');
      expect(talker.history.single.error, isNull);
      expect(talker.history.single.exception, isNull);
      expect(talker.history.single.stackTrace, isNull);
    },
  );

  testWidgets('framework errors use a generic fallback without raw details', (
    tester,
  ) async {
    final oldHandler = FlutterError.onError;
    final oldBuilder = ErrorWidget.builder;
    final dispatcher = WidgetsBinding.instance.platformDispatcher;
    final oldPlatformHandler = dispatcher.onError;
    addTearDown(() {
      FlutterError.onError = oldHandler;
      ErrorWidget.builder = oldBuilder;
      dispatcher.onError = oldPlatformHandler;
    });
    configureErrorReporting(observer);
    final details = FlutterErrorDetails(exception: _PrivatePayload());
    FlutterError.reportError(details);
    await tester.pumpWidget(ErrorWidget.builder(details));

    expect(
      find.text('Want Pass could not display this screen.'),
      findsOneWidget,
    );
    expect(talker.history.map((entry) => entry.message), ['unexpectedError']);
  });
}
