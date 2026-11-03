part of 'controller.dart';

sealed class VaultEffect {
  const VaultEffect();
}

enum VaultNoticeKind { copied, exportStarted, exported, locked, unlocked }

final class VaultNotice extends VaultEffect {
  final VaultNoticeKind kind;
  const VaultNotice(this.kind);
}

final class VaultRecoveryReset extends VaultEffect {
  const VaultRecoveryReset();
}

final class VaultRecoveryRegenerated extends VaultEffect {
  const VaultRecoveryRegenerated();
}

final class VaultCredentialCopiedV1 extends VaultEffect {
  final String cardId;
  final CardCopyKindV1 kind;
  final FieldIdV1? field;
  const VaultCredentialCopiedV1({
    required this.cardId,
    required this.kind,
    this.field,
  });
  @override
  String toString() => 'VaultCredentialCopiedV1(<redacted>)';
}
