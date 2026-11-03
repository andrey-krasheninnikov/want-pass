import 'package:domain_error/domain_error.dart';

abstract interface class GroupLogoService {
  const GroupLogoService();
  FutureDomainResult<List<int>?> selectV1();
}
