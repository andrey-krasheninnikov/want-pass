import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:launch_mode/launch_mode.dart';
import 'package:want_pass/src/feature/startup/application/_barrel.dart';
import 'package:want_pass_core/want_pass_core.dart';

part 'state.dart';

@singleton
final class StartupController extends Cubit<StartupState> {
  final StartupUseCase _useCase;
  final StartupReporter _reporter;
  Future<void>? _initFuture;
  Future<void>? _closeFuture;
  bool _closing = false;

  StartupController(this._useCase, this._reporter)
    : super(const StartupLoading());

  @PostConstruct(preResolve: true)
  Future<void> init() {
    const op = 'StartupController.init():';
    final initialized = LaunchMode.isInitialized;
    final mode = LaunchMode.current;
    if (_closing || isClosed) {
      return Future<void>.value();
    }
    return _initFuture ??= _initialize(op, initialized, mode);
  }

  Future<void> _initialize(
    String operation,
    bool initialized,
    LaunchModeType mode,
  ) async {
    if (!initialized || mode != LaunchModeType.foreground) {
      final error = initialized
          ? const StartupForegroundRequiredErrorV1()
          : const StartupNotInitializedErrorV1();
      reportStartupDiagnostic(
        _reporter,
        layer: StartupDiagnosticLayer.controller,
        operation: operation,
        event: StartupDiagnosticEvent.failure,
        error: error,
      );
      emit(StartupFailed(error));
      return;
    }
    final result = await _useCase.initializeV1(
      params: const InitializeStartupParamsV1(),
    );
    if (_closing || isClosed) {
      return;
    }
    if (result.isError) {
      final error = switch (result.error) {
        final StartupErrorV1 error => error,
        _ => const StartupUnexpectedErrorV1(),
      };
      reportStartupDiagnostic(
        _reporter,
        layer: StartupDiagnosticLayer.controller,
        operation: operation,
        event: StartupDiagnosticEvent.failure,
        error: error,
      );
      emit(StartupFailed(error));
      return;
    }
    emit(const StartupReady());
    reportStartupDiagnostic(
      _reporter,
      layer: StartupDiagnosticLayer.controller,
      operation: operation,
      event: StartupDiagnosticEvent.ready,
    );
  }

  @disposeMethod
  @override
  Future<void> close() {
    const op = 'StartupController.close():';
    if (!_closing) {
      _closing = true;
      reportStartupDiagnostic(
        _reporter,
        layer: StartupDiagnosticLayer.controller,
        operation: op,
        event: StartupDiagnosticEvent.closed,
      );
    }
    return _closeFuture ??= super.close();
  }
}
