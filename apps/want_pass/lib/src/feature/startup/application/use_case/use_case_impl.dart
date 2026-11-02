import 'package:domain_error/domain_error.dart';
import 'package:injectable/injectable.dart';
import 'package:want_pass/src/feature/startup/application/_barrel.dart';
import 'package:want_pass_core/want_pass_core.dart';

@Singleton(as: StartupUseCase)
final class StartupUseCaseImpl implements StartupUseCase {
  final StartupAccessService _access;
  final StartupReporter _reporter;

  const StartupUseCaseImpl(this._access, this._reporter);

  @override
  FutureDomainResult<InitializeStartupResultV1> initializeV1({
    required InitializeStartupParamsV1 params,
  }) async {
    const op = 'StartupUseCaseImpl.initializeV1():';
    final result = await captureResult<InitializeStartupResultV1>(
      () async {
        final access = await _access.checkForegroundV1();
        if (access.isError) {
          throw access.domainError;
        }
        return const InitializeStartupResultV1();
      },
      mapToDomainError: (error, stackTrace) =>
          StartupUnexpectedErrorV1(cause: error, stackTrace: stackTrace),
    );
    if (result.isError) {
      reportStartupDiagnostic(
        _reporter,
        layer: StartupDiagnosticLayer.application,
        operation: op,
        event: StartupDiagnosticEvent.failure,
        error: result.error is StartupErrorV1
            ? result.error as StartupErrorV1
            : const StartupUnexpectedErrorV1(),
      );
    }
    return result;
  }
}
