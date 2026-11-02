import 'package:want_pass_core/src/feature/startup/domain/_barrel.dart';

enum StartupDiagnosticLayer {
  infrastructure,
  application,
  controller,
  bootstrap,
  framework,
}

enum StartupDiagnosticEvent {
  ready,
  failure,
  unexpectedError,
  observerError,
  closed,
}

/// Receives local diagnostic context. Implementations must not throw or retain raw causes.
abstract interface class StartupReporter {
  const StartupReporter();

  void report({
    required StartupDiagnosticLayer layer,
    required String operation,
    required StartupDiagnosticEvent event,
    StartupErrorV1? error,
  });
}

/// Isolates a faulty diagnostic sink without replacing the operation's result.
void reportStartupDiagnostic(
  StartupReporter reporter, {
  required StartupDiagnosticLayer layer,
  required String operation,
  required StartupDiagnosticEvent event,
  StartupErrorV1? error,
}) {
  try {
    reporter.report(
      layer: layer,
      operation: operation,
      event: event,
      error: error,
    );
  } on Object {
    try {
      reporter.report(
        layer: layer,
        operation: operation,
        event: StartupDiagnosticEvent.observerError,
      );
    } on Object {
      // A failing diagnostic sink cannot recover by calling itself again.
    }
  }
}
