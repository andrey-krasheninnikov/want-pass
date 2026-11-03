import 'package:domain_error/domain_error.dart';
import 'package:want_pass/src/feature/appearance/application/_barrel.dart';

abstract interface class AppearanceUseCase {
  const AppearanceUseCase();
  FutureDomainResult<AppearanceResultV1> loadV1({
    required LoadAppearanceParamsV1 params,
  });
  FutureDomainResult<AppearanceResultV1> saveV1({
    required SaveAppearanceParamsV1 params,
  });
}
