import 'package:domain_error/domain_error.dart';
import 'package:want_pass/src/feature/startup/application/_barrel.dart';

abstract interface class StartupUseCase {
  const StartupUseCase();

  FutureDomainResult<InitializeStartupResultV1> initializeV1({
    required InitializeStartupParamsV1 params,
  });
}
