import 'package:domain_error/domain_error.dart';
import 'package:want_pass_core/want_pass_core.dart';

abstract interface class CredentialFileService {
  const CredentialFileService();
  FutureDomainResult<String?> selectBackupSourceV1();
  FutureDomainResult<String?> withBackupDestinationV1(
    Future<bool> Function(String) save,
  );
  FutureDomainResult<List<String>?> selectAccountImportV1(
    AccountImportSourceV1 source, {
    required bool clipboard,
  });

  FutureDomainResult<AttachmentDraftV1?> selectAttachmentV1();
  FutureDomainResult<String?> selectDestinationV1(String name);
}
