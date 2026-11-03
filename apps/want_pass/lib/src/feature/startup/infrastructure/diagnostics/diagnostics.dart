import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:bloc_effects/bloc_effects.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:talker/talker.dart';
import 'package:talker_bloc_effects/talker_bloc_effects.dart';
import 'package:want_pass_core/want_pass_core.dart';

final class SafeBlocObserver extends BlocObserver
    implements BlocWithEffectsObserver, StartupReporter, VaultReporter {
  final Talker _talker;
  final TalkerBlocEffectsObserver _effects;

  SafeBlocObserver({required Talker talker})
    : _talker = talker,
      _effects = TalkerBlocEffectsObserver(
        talker: talker,
        settings: const TalkerBlocLoggerSettings(
          printEvents: false,
          printTransitions: false,
        ),
        effectsSettings: TalkerBlocEffectsSettings(
          effectFilter: (_, effect) => effect is StartupDiagnosticEvent,
        ),
      );

  @override
  void reportVault({
    required VaultDiagnosticLayer layer,
    required String operation,
    required VaultErrorV1 error,
  }) {
    final marker = switch (error) {
      VaultRejectedErrorV1(:final kind) => kind.name,
      VaultUnexpectedErrorV1() => 'unexpectedError',
    };
    final safeOperation = switch (operation) {
      'RustVaultAccessService.openV1():' ||
      'RustVaultAccessService.statusV1():' ||
      'RustVaultAccessService.prepareCreationV1():' ||
      'RustVaultAccessService.prepareRecoveryV1():' ||
      'RustVaultAccessService.confirmV1():' ||
      'RustVaultAccessService.unlockV1():' ||
      'VaultUseCaseImpl.initializeV1():' ||
      'VaultUseCaseImpl.prepareCreationV1():' ||
      'VaultUseCaseImpl.prepareRecoveryV1():' ||
      'VaultUseCaseImpl.confirmCreationV1():' ||
      'VaultUseCaseImpl.confirmRecoveryV1():' ||
      'VaultUseCaseImpl.unlockV1():' ||
      'VaultUseCaseImpl.lockV1():' ||
      'VaultUseCaseImpl.closeV1():' ||
      'VaultController.init():' ||
      'VaultController.prepareCreation():' ||
      'VaultController.prepareRecovery():' ||
      'VaultController.confirm():' ||
      'VaultController.unlock():' ||
      'VaultController.lock():' ||
      'VaultController.activity():' ||
      'VaultController._monitorLost():' ||
      'VaultController.close():' ||
      '_NativeVaultHandle.invalidateSync():' ||
      '_NativeVaultHandle.close():' ||
      'createVaultLockEvents():' => operation,
      _ => 'unknownOperation',
    };
    try {
      _talker.log(
        '${layer.name} $safeOperation $marker',
        logLevel: LogLevel.warning,
      );
    } on Object {
      // Diagnostics cannot interrupt a vault operation.
    }
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    report(
      layer: StartupDiagnosticLayer.framework,
      operation: 'SafeBlocObserver.onError():',
      event: StartupDiagnosticEvent.unexpectedError,
    );
  }

  @override
  void onBlocEffect(BlocBase<dynamic> bloc, Object? effect) => onEffect(effect);

  @override
  void onEffect<E>(E effect) {
    try {
      // The delegate receives neither a source bloc nor arbitrary effect payloads.
      _effects.onEffect(effect);
    } on Object {
      report(
        layer: StartupDiagnosticLayer.framework,
        operation: 'SafeBlocObserver.onEffect():',
        event: StartupDiagnosticEvent.observerError,
      );
    }
  }

  @override
  void report({
    required StartupDiagnosticLayer layer,
    required String operation,
    required StartupDiagnosticEvent event,
    StartupErrorV1? error,
  }) {
    final (level, marker) = switch (error) {
      StartupNotInitializedErrorV1() => (LogLevel.warning, 'notInitialized'),
      StartupForegroundRequiredErrorV1() => (
        LogLevel.warning,
        'foregroundRequired',
      ),
      StartupConfigurationConflictErrorV1() => (
        LogLevel.warning,
        'configurationConflict',
      ),
      StartupUnexpectedErrorV1() => (LogLevel.error, 'unexpectedError'),
      null => switch (event) {
        StartupDiagnosticEvent.ready ||
        StartupDiagnosticEvent.closed => (LogLevel.info, event.name),
        StartupDiagnosticEvent.failure => (LogLevel.warning, event.name),
        StartupDiagnosticEvent.unexpectedError ||
        StartupDiagnosticEvent.observerError => (LogLevel.error, event.name),
      },
    };
    // Operation text is supplied by fixed call sites, never by an exception or user input.
    final safeOperation = switch (operation) {
      'StartupAccessServiceImpl.checkForegroundV1():' ||
      'StartupUseCaseImpl.initializeV1():' ||
      'StartupController.init():' ||
      'StartupController.close():' ||
      'SafeBlocObserver.onError():' ||
      'SafeBlocObserver.onEffect():' ||
      'AppRuntime.bootstrap():' ||
      'ErrorReportingScope.frameworkError():' ||
      'ErrorReportingScope.platformError():' => operation,
      _ => 'unknownOperation',
    };
    try {
      _talker.log('${layer.name} $safeOperation $marker', logLevel: level);
    } on Object {
      // Diagnostics cannot interrupt startup, error handling or shutdown.
    }
  }
}

final class ErrorReportingScope {
  final FlutterExceptionHandler? _previousFlutterHandler;
  final ErrorWidgetBuilder _previousWidgetBuilder;
  final bool Function(Object, StackTrace)? _previousPlatformHandler;
  late final FlutterExceptionHandler _flutterHandler;
  late final ErrorWidgetBuilder _widgetBuilder;
  late final bool Function(Object, StackTrace) _platformHandler;

  ErrorReportingScope(SafeBlocObserver observer)
    : _previousFlutterHandler = FlutterError.onError,
      _previousWidgetBuilder = ErrorWidget.builder,
      _previousPlatformHandler = PlatformDispatcher.instance.onError {
    _flutterHandler = (_) => observer.report(
      layer: StartupDiagnosticLayer.framework,
      operation: 'ErrorReportingScope.frameworkError():',
      event: StartupDiagnosticEvent.unexpectedError,
    );
    _platformHandler = (_, _) {
      observer.report(
        layer: StartupDiagnosticLayer.framework,
        operation: 'ErrorReportingScope.platformError():',
        event: StartupDiagnosticEvent.unexpectedError,
      );
      return true;
    };
    _widgetBuilder = (_) => const Directionality(
      textDirection: TextDirection.ltr,
      child: ColoredBox(
        color: Color(0xFF1A1A1A),
        child: Center(
          child: Text(
            'Want Pass could not display this screen.',
            style: TextStyle(color: Color(0xFFFFFFFF)),
          ),
        ),
      ),
    );
    FlutterError.onError = _flutterHandler;
    ErrorWidget.builder = _widgetBuilder;
    PlatformDispatcher.instance.onError = _platformHandler;
  }

  void close() {
    if (identical(FlutterError.onError, _flutterHandler)) {
      FlutterError.onError = _previousFlutterHandler;
    }
    if (identical(ErrorWidget.builder, _widgetBuilder)) {
      ErrorWidget.builder = _previousWidgetBuilder;
    }
    if (identical(PlatformDispatcher.instance.onError, _platformHandler)) {
      PlatformDispatcher.instance.onError = _previousPlatformHandler;
    }
  }
}
