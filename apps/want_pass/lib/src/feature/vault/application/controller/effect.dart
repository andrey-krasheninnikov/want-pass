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
