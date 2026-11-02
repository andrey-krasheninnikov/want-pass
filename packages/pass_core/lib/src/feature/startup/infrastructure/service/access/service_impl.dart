import 'package:domain_error/domain_error.dart';
import 'package:injectable/injectable.dart';
import 'package:package_context/package_context.dart';
import 'package:want_pass_core/src/application/_barrel.dart';
import 'package:want_pass_core/src/config/_barrel.dart';
import 'package:want_pass_core/src/dependencies/_barrel.dart';
import 'package:want_pass_core/src/feature/startup/application/_barrel.dart';
import 'package:want_pass_core/src/feature/startup/domain/_barrel.dart';

@Singleton(as: StartupAccessService)
final class StartupAccessServiceImpl implements StartupAccessService {
  final PackageContext<Config, Dependencies> _context;
  final StartupReporter _reporter;

  const StartupAccessServiceImpl(this._context, this._reporter);

  @override
  FutureDomainResult<void> checkForegroundV1() async {
    const op = 'StartupAccessServiceImpl.checkForegroundV1():';
    final result = await captureResult<void>(
      () {
        if (!_context.isInitialized) {
          throw const StartupNotInitializedErrorV1();
        }
        if (!_context.config.isForeground) {
          throw const StartupForegroundRequiredErrorV1();
        }
      },
      mapToDomainError: (error, stackTrace) =>
          StartupUnexpectedErrorV1(cause: error, stackTrace: stackTrace),
    );
    if (result.isError) {
      reportStartupDiagnostic(
        _reporter,
        layer: StartupDiagnosticLayer.infrastructure,
        operation: op,
        event: StartupDiagnosticEvent.failure,
        error: result.error as StartupErrorV1,
      );
    }
    return result;
  }
}
