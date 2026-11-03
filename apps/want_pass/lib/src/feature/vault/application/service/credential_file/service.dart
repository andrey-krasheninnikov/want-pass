import 'package:domain_error/domain_error.dart';
import 'package:want_pass_core/want_pass_core.dart';

abstract interface class CredentialFileService {
  const CredentialFileService();
  FutureDomainResult<AttachmentDraftV1?> selectAttachmentV1();
  FutureDomainResult<String?> selectDestinationV1(String name);
}
