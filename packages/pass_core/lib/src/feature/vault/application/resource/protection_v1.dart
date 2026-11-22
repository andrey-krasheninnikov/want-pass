import 'package:domain_error/domain_error.dart';
import 'package:want_pass_core/src/feature/vault/domain/_barrel.dart';

enum ProtectedOperationV1 {
  reveal,
  copy,
  exportData,
  transfer,
  integrationGrant,
  recoveryKit,
  delete,
  protection,
}

typedef VaultCodePromptV1 = Future<String?> Function(
  ProtectedOperationV1 operation,
);

final class ProtectionSettingsDtoV1 {
  final bool enrolled;
  final Set<ProtectedOperationV1> operations;
  ProtectionSettingsDtoV1(
    this.enrolled,
    Iterable<ProtectedOperationV1> operations,
  ) : operations = Set.unmodifiable(operations);
}

abstract interface class VaultProtectionSessionV1 {
  Future<bool> biometricAvailable();
  FutureDomainResult<bool> biometricEnabled();
  FutureDomainResult<void> configureBiometric(bool enable);
  FutureDomainResult<void> unlockBiometric();
  FutureDomainResult<ProtectionSettingsDtoV1> protectionSettings();
  FutureDomainResult<String> beginEnrollment();
  FutureDomainResult<void> enroll(
    String code,
    Set<ProtectedOperationV1> operations,
  );
  FutureDomainResult<void> configureFactor(
    String code,
    Set<ProtectedOperationV1> operations, {
    required bool disable,
  });
  FutureDomainResult<String> revealField(String id, FieldIdV1 field);
  FutureDomainResult<TotpCodeV1> copyCurrentOtp(String id);
}
