import 'package:domain_error/domain_error.dart';
import 'package:want_pass/src/feature/appearance/application/_barrel.dart';

abstract interface class AppearancePreferencesService {
  const AppearancePreferencesService();
  FutureDomainResult<AppearanceSettingsV1> loadV1();
  FutureDomainResult<void> saveV1(AppearanceSettingsV1 settings);
}
