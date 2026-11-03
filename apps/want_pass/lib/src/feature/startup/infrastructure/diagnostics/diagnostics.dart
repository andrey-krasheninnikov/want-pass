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
      'PlatformCredentialFileService.selectAttachmentV1():' ||
      'PlatformCredentialFileService.selectDestinationV1():' ||
      'RustVaultAccessService.cardCatalogV1():' ||
      'RustVaultAccessService.searchCardsV1():' ||
      'RustVaultAccessService.cardRowsV1():' ||
      'RustVaultAccessService.cardV1():' ||
      'RustVaultAccessService.contentV2():' ||
      'RustVaultAccessService.copyAccountV1():' ||
      'RustVaultAccessService.currentTotpV1():' ||
      'RustVaultAccessService.deleteCardV1():' ||
      'RustVaultAccessService.deleteGroupV2():' ||
      'RustVaultAccessService.exportAttachmentV1():' ||
      'RustVaultAccessService.saveCardV1():' ||
      'RustVaultAccessService.saveGroupV2():' ||
      'VaultController.copyCard():' ||
      'VaultController.deleteCard():' ||
      'VaultController.downloadAttachment():' ||
      'VaultController.searchCards():' ||
      'VaultController.readCardRows():' ||
      'VaultController.readCard():' ||
      'VaultController.readTotp():' ||
      'VaultController.saveCard():' ||
      'VaultController.selectAttachment():' ||
      'VaultUseCaseImpl.copyCardV1():' ||
      'VaultUseCaseImpl.deleteCardV1():' ||
      'VaultUseCaseImpl.deleteGroupV2():' ||
      'VaultUseCaseImpl.exportCardAttachmentV1():' ||
      'VaultUseCaseImpl.loadContentV2():' ||
      'VaultUseCaseImpl.searchCardsV1():' ||
      'VaultUseCaseImpl.readCardRowsV1():' ||
      'VaultUseCaseImpl.readCardV1():' ||
      'VaultUseCaseImpl.readTotpV1():' ||
      'VaultUseCaseImpl.saveCardV1():' ||
      'VaultUseCaseImpl.saveGroupV2():' ||
      'VaultUseCaseImpl.selectAttachmentV1():' ||
      'VaultUseCaseImpl.selectCardDestinationV1():' ||
      'RustVaultAccessService.contentV1():' ||
      'RustVaultAccessService.saveGroupV1():' ||
      'RustVaultAccessService.deleteGroupV1():' ||
      'RustVaultAccessService.accountV1():' ||
      'RustVaultAccessService.saveAccountV1():' ||
      'RustVaultAccessService.deleteAccountV1():' ||
      'VaultUseCaseImpl.loadContentV1():' ||
      'VaultUseCaseImpl.saveGroupV1():' ||
      'VaultUseCaseImpl.deleteGroupV1():' ||
      'VaultUseCaseImpl.readAccountV1():' ||
      'VaultUseCaseImpl.saveAccountV1():' ||
      'VaultUseCaseImpl.deleteAccountV1():' ||
      'VaultUseCaseImpl.selectGroupLogoV1():' ||
      'VaultController.loadContent():' ||
      'VaultController.saveGroup():' ||
      'VaultController.deleteGroup():' ||
      'VaultController.readAccount():' ||
      'VaultController.saveAccount():' ||
      'VaultController.deleteAccount():' ||
      'VaultController.selectGroupLogo():' ||
      'PlatformGroupLogoService.selectV1():' ||
      'VaultController.validatePassword():' ||
      'RustVaultAccessService.validatePasswordV3():' ||
      'RustVaultAccessService.unlockV3():' ||
      'VaultUseCaseImpl.validatePasswordV3():' ||
      'VaultUseCaseImpl.unlockV3():' ||
      'VaultController.acknowledge():' ||
      'VaultController.validateRecovery():' ||
      'PlatformRecoveryExportService.selectFileV3():' ||
      'RustVaultAccessService.validateRecoveryV3():' ||
      'RustVaultAccessService.prepareCreationV3():' ||
      'RustVaultAccessService.prepareRecoveryV3():' ||
      'RustVaultAccessService.regenerateRecoveryV3():' ||
      'RustVaultAccessService.exportRecoveryV3():' ||
      'RustVaultAccessService.confirmV3():' ||
      'VaultUseCaseImpl.prepareSetupV3():' ||
      'VaultUseCaseImpl.confirmSetupV3():' ||
      'VaultUseCaseImpl.regenerateRecoveryV3():' ||
      'VaultUseCaseImpl.validateRecoveryV3():' ||
      'VaultUseCaseImpl.exportRecoveryV3():' ||
      'VaultUseCaseImpl.selectRecoveryFileV3():' ||
      'PlatformRecoveryExportService.clearClipboardV1():' ||
      'PlatformRecoveryExportService.copyV1():' ||
      'PlatformRecoveryExportService.selectFileV1():' ||
      'RustVaultAccessService.confirmV2():' ||
      'RustVaultAccessService.exportRecoveryV2():' ||
      'RustVaultAccessService.waitForExportsV2():' ||
      'RustVaultAccessService.hintsV2():' ||
      'RustVaultAccessService.prepareCreationV2():' ||
      'RustVaultAccessService.prepareRecoveryV2():' ||
      'VaultController._clearClipboard():' ||
      'VaultController.chooseSetupWord():' ||
      'VaultController.confirmSetup():' ||
      'VaultController.copyRecovery():' ||
      'VaultController.dismissFailure():' ||
      'VaultController.downloadRecovery():' ||
      'VaultController.prepareSetup():' ||
      'VaultController.readHints():' ||
      'VaultUseCaseImpl.clearRecoveryClipboardV1():' ||
      'VaultUseCaseImpl.confirmSetupV2():' ||
      'VaultUseCaseImpl.copyRecoveryV1():' ||
      'VaultUseCaseImpl.exportRecoveryV2():' ||
      'VaultUseCaseImpl.prepareSetupV2():' ||
      'VaultUseCaseImpl.readHintsV2():' ||
      'VaultUseCaseImpl.selectRecoveryFileV1():' ||
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
      'PlatformCredentialFileService.selectAttachmentV1():' ||
      'PlatformCredentialFileService.selectDestinationV1():' ||
      'RustVaultAccessService.cardCatalogV1():' ||
      'RustVaultAccessService.searchCardsV1():' ||
      'RustVaultAccessService.cardRowsV1():' ||
      'RustVaultAccessService.cardV1():' ||
      'RustVaultAccessService.contentV2():' ||
      'RustVaultAccessService.copyAccountV1():' ||
      'RustVaultAccessService.currentTotpV1():' ||
      'RustVaultAccessService.deleteCardV1():' ||
      'RustVaultAccessService.deleteGroupV2():' ||
      'RustVaultAccessService.exportAttachmentV1():' ||
      'RustVaultAccessService.saveCardV1():' ||
      'RustVaultAccessService.saveGroupV2():' ||
      'VaultController.copyCard():' ||
      'VaultController.deleteCard():' ||
      'VaultController.downloadAttachment():' ||
      'VaultController.searchCards():' ||
      'VaultController.readCardRows():' ||
      'VaultController.readCard():' ||
      'VaultController.readTotp():' ||
      'VaultController.saveCard():' ||
      'VaultController.selectAttachment():' ||
      'VaultUseCaseImpl.copyCardV1():' ||
      'VaultUseCaseImpl.deleteCardV1():' ||
      'VaultUseCaseImpl.deleteGroupV2():' ||
      'VaultUseCaseImpl.exportCardAttachmentV1():' ||
      'VaultUseCaseImpl.loadContentV2():' ||
      'VaultUseCaseImpl.searchCardsV1():' ||
      'VaultUseCaseImpl.readCardRowsV1():' ||
      'VaultUseCaseImpl.readCardV1():' ||
      'VaultUseCaseImpl.readTotpV1():' ||
      'VaultUseCaseImpl.saveCardV1():' ||
      'VaultUseCaseImpl.saveGroupV2():' ||
      'VaultUseCaseImpl.selectAttachmentV1():' ||
      'VaultUseCaseImpl.selectCardDestinationV1():' ||
      'VaultController.validatePassword():' ||
      'RustVaultAccessService.validatePasswordV3():' ||
      'RustVaultAccessService.unlockV3():' ||
      'VaultUseCaseImpl.validatePasswordV3():' ||
      'VaultUseCaseImpl.unlockV3():' ||
      'VaultController.acknowledge():' ||
      'VaultController.validateRecovery():' ||
      'PlatformRecoveryExportService.selectFileV3():' ||
      'RustVaultAccessService.validateRecoveryV3():' ||
      'RustVaultAccessService.prepareCreationV3():' ||
      'RustVaultAccessService.prepareRecoveryV3():' ||
      'RustVaultAccessService.regenerateRecoveryV3():' ||
      'RustVaultAccessService.exportRecoveryV3():' ||
      'RustVaultAccessService.confirmV3():' ||
      'VaultUseCaseImpl.prepareSetupV3():' ||
      'VaultUseCaseImpl.confirmSetupV3():' ||
      'VaultUseCaseImpl.regenerateRecoveryV3():' ||
      'VaultUseCaseImpl.validateRecoveryV3():' ||
      'VaultUseCaseImpl.exportRecoveryV3():' ||
      'VaultUseCaseImpl.selectRecoveryFileV3():' ||
      'AppearanceController.close():' ||
      'AppearanceController.init():' ||
      'AppearanceController.save():' ||
      'AppearanceUseCaseImpl.loadV1():' ||
      'AppearanceUseCaseImpl.saveV1():' ||
      'FileAppearancePreferencesService.loadV1():' ||
      'FileAppearancePreferencesService.saveV1():' ||
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
