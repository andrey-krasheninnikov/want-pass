import 'package:domain_error/domain_error.dart';
import 'package:injectable/injectable.dart';
import 'package:want_pass/src/feature/appearance/application/_barrel.dart';
import 'package:want_pass_core/want_pass_core.dart';

@Singleton(as: AppearanceUseCase)
final class AppearanceUseCaseImpl implements AppearanceUseCase {
  final AppearancePreferencesService _preferences;
  final StartupReporter _reporter;
  const AppearanceUseCaseImpl(this._preferences, this._reporter);
  @override
  FutureDomainResult<AppearanceResultV1> loadV1({
    required LoadAppearanceParamsV1 params,
  }) async {
    const op = 'AppearanceUseCaseImpl.loadV1():';
    final result = await captureResult<AppearanceResultV1>(() async {
      final value = await _preferences.loadV1();
      if (value.isError) throw value.error;
      return AppearanceResultV1(settings: value.value);
    }, mapToDomainError: (_, _) => const StartupUnexpectedErrorV1());
    if (result.isError) {
      reportStartupDiagnostic(
        _reporter,
        layer: StartupDiagnosticLayer.application,
        operation: op,
        event: StartupDiagnosticEvent.failure,
        error: const StartupUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<AppearanceResultV1> saveV1({
    required SaveAppearanceParamsV1 params,
  }) async {
    const op = 'AppearanceUseCaseImpl.saveV1():';
    final result = await captureResult<AppearanceResultV1>(() async {
      final value = await _preferences.saveV1(params.settings);
      if (value.isError) throw value.error;
      return AppearanceResultV1(settings: params.settings);
    }, mapToDomainError: (_, _) => const StartupUnexpectedErrorV1());
    if (result.isError) {
      reportStartupDiagnostic(
        _reporter,
        layer: StartupDiagnosticLayer.application,
        operation: op,
        event: StartupDiagnosticEvent.failure,
        error: const StartupUnexpectedErrorV1(),
      );
    }
    return result;
  }
}
