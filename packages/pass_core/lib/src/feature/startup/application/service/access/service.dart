import 'package:domain_error/domain_error.dart';

abstract interface class StartupAccessService {
  const StartupAccessService();

  FutureDomainResult<void> checkForegroundV1();
}
