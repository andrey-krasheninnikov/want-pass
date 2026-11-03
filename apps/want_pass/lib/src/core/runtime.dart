import 'dart:ui';

import 'package:want_pass/src/feature/appearance/application/_barrel.dart';

import 'package:path_provider/path_provider.dart';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:launch_mode/launch_mode.dart';
import 'package:talker/talker.dart';
import 'package:want_pass/src/dependencies/_barrel.dart';
import 'package:want_pass/src/feature/startup/application/_barrel.dart';
import 'package:want_pass/src/feature/startup/infrastructure/_barrel.dart';
import 'package:want_pass_core/want_pass_core.dart';
import 'package:want_pass/src/feature/vault/application/_barrel.dart';
import 'package:want_pass/src/feature/vault/infrastructure/_barrel.dart';

Future<AppRuntime>? _bootstrap;
LaunchModeType? _bootstrapMode;
VaultAccessService? _accessOverride;
Stream<VaultLockSignal>? _eventsOverride;
String? _preferencesOverride;

final class AppRuntime {
  final GetIt _container;
  final CoreRuntime _core;
  final ErrorReportingScope _reporting;
  final BlocObserver _previousObserver;
  final SafeBlocObserver _observer;
  AppLifecycleListener? _lifecycle;
  Future<void>? _closeFuture;

  AppRuntime._(
    this._container,
    this._core,
    this._reporting,
    this._previousObserver,
    this._observer,
  ) {
    _lifecycle = AppLifecycleListener(
      onExitRequested: () async {
        await close();
        return AppExitResponse.exit;
      },
    );
  }

  StartupController get startup => _container<StartupController>();

  AppearanceController get appearance => _container<AppearanceController>();

  VaultController get vault => _container<VaultController>();

  static Future<AppRuntime> bootstrap({
    VaultAccessService? vaultAccess,
    Stream<VaultLockSignal>? vaultLockEvents,
    String? preferencesDirectory,
  }) {
    const op = 'AppRuntime.bootstrap():';
    final mode = LaunchMode.current;
    final pending = _bootstrap;
    if (pending != null) {
      if (_bootstrapMode != mode ||
          !identical(_accessOverride, vaultAccess) ||
          !identical(_eventsOverride, vaultLockEvents) ||
          _preferencesOverride != preferencesDirectory) {
        return Future<AppRuntime>.error(
          const StartupConfigurationConflictErrorV1(),
        );
      }
      return pending;
    }
    if (!LaunchMode.isInitialized || mode != LaunchModeType.foreground) {
      return Future<AppRuntime>.error(const StartupForegroundRequiredErrorV1());
    }
    _bootstrapMode = mode;
    _accessOverride = vaultAccess;
    _eventsOverride = vaultLockEvents;
    _preferencesOverride = preferencesDirectory;
    return _bootstrap = _initialize(
      op,
      vaultAccess,
      vaultLockEvents,
      preferencesDirectory,
    );
  }

  static Future<AppRuntime> _initialize(
    String operation,
    VaultAccessService? vaultAccess,
    Stream<VaultLockSignal>? vaultLockEvents,
    String? preferencesDirectory,
  ) async {
    final container = GetIt.asNewInstance();
    final observer = SafeBlocObserver(talker: Talker());
    final previousObserver = Bloc.observer;
    final reporting = ErrorReportingScope(observer);
    Bloc.observer = observer;
    CoreRuntime? core;
    try {
      core = initPackage(
        config: const Config(isForeground: true),
        dependencies: Dependencies(reporter: observer),
      );
      container.registerSingleton<StartupAccessService>(
        core.startupAccessService,
      );
      container.registerSingleton<StartupReporter>(observer);
      final access =
          vaultAccess ??
          await initializeVaultAccess(
            directory: '${(await getApplicationSupportDirectory()).path}/vault',
            reporter: observer,
          );
      final events = vaultLockEvents ?? await createVaultLockEvents(observer);
      container.registerSingleton<VaultAccessService>(access);
      container.registerSingleton<VaultReporter>(observer);
      container.registerSingleton<Stream<VaultLockSignal>>(
        events,
        instanceName: 'vaultLockEvents',
      );
      container.registerSingleton<String>(
        preferencesDirectory ?? (await getApplicationSupportDirectory()).path,
        instanceName: 'preferencesDirectory',
      );
      await configureDependencies(container);
      return AppRuntime._(
        container,
        core,
        reporting,
        previousObserver,
        observer,
      );
    } on Object catch (error, stackTrace) {
      try {
        await container.reset();
      } on Object {
        observer.report(
          layer: StartupDiagnosticLayer.bootstrap,
          operation: operation,
          event: StartupDiagnosticEvent.observerError,
        );
      } finally {
        core?.close();
        reporting.close();
        if (identical(Bloc.observer, observer)) {
          Bloc.observer = previousObserver;
        }
        _bootstrap = null;
        _bootstrapMode = null;
        _accessOverride = null;
        _eventsOverride = null;
        _preferencesOverride = null;
      }
      observer.report(
        layer: StartupDiagnosticLayer.bootstrap,
        operation: operation,
        event: StartupDiagnosticEvent.unexpectedError,
      );
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<void> close() => _closeFuture ??= _dispose();

  Future<void> _dispose() async {
    _lifecycle?.dispose();
    _lifecycle = null;
    try {
      await vault.lock();
      await _container.reset();
    } finally {
      _core.close();
      _reporting.close();
      if (identical(Bloc.observer, _observer)) {
        Bloc.observer = _previousObserver;
      }
      _bootstrap = null;
      _bootstrapMode = null;
      _accessOverride = null;
      _eventsOverride = null;
      _preferencesOverride = null;
    }
  }
}
