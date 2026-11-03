import 'package:domain_error/domain_error.dart';

abstract interface class RecoveryExportService {
  const RecoveryExportService();
  FutureDomainResult<String?> selectFileV1();
  FutureDomainResult<String?> selectFileV3();
  FutureDomainResult<void> copyV1(String phrase);
  FutureDomainResult<void> clearClipboardV1(String expected);
}
