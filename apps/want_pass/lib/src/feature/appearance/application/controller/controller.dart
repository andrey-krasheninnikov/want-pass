import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:launch_mode/launch_mode.dart';
import 'package:want_pass/src/feature/appearance/application/_barrel.dart';
import 'package:want_pass_core/want_pass_core.dart';

final class AppearanceState extends Equatable {
  final AppearanceSettingsV1 settings;
  final bool busy, failed;
  const AppearanceState({
    this.settings = const AppearanceSettingsV1(),
    this.busy = false,
    this.failed = false,
  });
  @override
  List<Object?> get props => [settings, busy, failed];
}

@singleton
final class AppearanceController extends Cubit<AppearanceState> {
  final AppearanceUseCase _useCase;
  final StartupReporter _reporter;
  Future<void>? _initialization, _operation, _closure;
  bool _closing = false;
  AppearanceController(this._useCase, this._reporter)
    : super(const AppearanceState());
  @PostConstruct(preResolve: true)
  Future<void> init() {
    const op = 'AppearanceController.init():';
    if (_closing) return Future.value();
    return _initialization ??= () async {
      if (!LaunchMode.isInitialized || !LaunchMode.isForeground) {
        _fail(op);
        return;
      }
      final result = await _useCase.loadV1(
        params: const LoadAppearanceParamsV1(),
      );
      if (_closing) return;
      if (result.isError) {
        _fail(op);
        return;
      }
      emit(AppearanceState(settings: result.value.settings));
    }();
  }

  Future<void> save(AppearanceSettingsV1 settings) async {
    const op = 'AppearanceController.save():';
    if (_closing || state.busy) return;
    if (!LaunchMode.isInitialized || !LaunchMode.isForeground) {
      _fail(op);
      return;
    }
    emit(AppearanceState(settings: state.settings, busy: true));
    final operation = () async {
      final result = await _useCase.saveV1(
        params: SaveAppearanceParamsV1(settings: settings),
      );
      if (_closing) return;
      if (result.isError) {
        _fail(op);
        return;
      }
      emit(AppearanceState(settings: result.value.settings));
    }();
    _operation = operation;
    await operation;
    if (identical(_operation, operation)) _operation = null;
  }

  void _fail(String operation) {
    reportStartupDiagnostic(
      _reporter,
      layer: StartupDiagnosticLayer.controller,
      operation: operation,
      event: StartupDiagnosticEvent.failure,
      error: const StartupUnexpectedErrorV1(),
    );
    if (!_closing) {
      emit(AppearanceState(settings: state.settings, failed: true));
    }
  }

  @disposeMethod
  @override
  Future<void> close() {
    const op = 'AppearanceController.close():';
    if (!_closing) {
      reportStartupDiagnostic(
        _reporter,
        layer: StartupDiagnosticLayer.controller,
        operation: op,
        event: StartupDiagnosticEvent.closed,
      );
    }
    _closing = true;
    return _closure ??= () async {
      await _initialization;
      await _operation;
      await super.close();
    }();
  }
}
