import 'package:bloc_effects/bloc_effects.dart';
import 'package:want_pass_core/want_pass_core.dart' as core;

enum StartupState { loading, ready, failed }

enum DiagnosticEvent { startupReady, startupFailed, unexpectedError }

class StartupCubit extends CubitWithEffects<StartupState, DiagnosticEvent> {
  StartupCubit() : super(StartupState.loading);

  void start() {
    final result = core.checkForegroundStartup();
    emit(result.isSuccess ? StartupState.ready : StartupState.failed);
    emitEffect(
      result.isSuccess
          ? DiagnosticEvent.startupReady
          : DiagnosticEvent.startupFailed,
    );
  }
}
