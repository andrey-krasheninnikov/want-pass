import 'package:equatable/equatable.dart';
import 'package:want_pass_core/want_pass_core.dart';

final class InitializeVaultParamsV1 extends Equatable {
  const InitializeVaultParamsV1();
  @override
  List<Object?> get props => [];
  @override
  String toString() => 'InitializeVaultParamsV1(<redacted>)';
}

final class InitializeVaultResultV1 extends Equatable {
  final VaultHandleV1 handle;
  final VaultAccessStateV1 state;
  const InitializeVaultResultV1({required this.handle, required this.state});
  @override
  List<Object?> get props => [handle, state];
  @override
  String toString() => 'InitializeVaultResultV1(<redacted>)';
}

final class PrepareVaultCreationParamsV1 extends Equatable {
  final VaultHandleV1 handle;
  final String password;
  final String confirmation;
  const PrepareVaultCreationParamsV1({
    required this.handle,
    required this.password,
    required this.confirmation,
  });
  @override
  List<Object?> get props => [handle, password, confirmation];
  @override
  String toString() => 'PrepareVaultCreationParamsV1(<redacted>)';
}

final class PrepareVaultCreationResultV1 extends Equatable {
  final VaultRecoveryChallengeV1 challenge;
  const PrepareVaultCreationResultV1({required this.challenge});
  @override
  List<Object?> get props => [challenge];
  @override
  String toString() => 'PrepareVaultCreationResultV1(<redacted>)';
}

final class ConfirmVaultCreationParamsV1 extends Equatable {
  final VaultHandleV1 handle;
  final List<String> answers;
  const ConfirmVaultCreationParamsV1({
    required this.handle,
    required this.answers,
  });
  @override
  List<Object?> get props => [handle, answers];
  @override
  String toString() => 'ConfirmVaultCreationParamsV1(<redacted>)';
}

final class ConfirmVaultCreationResultV1 extends Equatable {
  final VaultAccessStateV1 state;
  const ConfirmVaultCreationResultV1({required this.state});
  @override
  List<Object?> get props => [state];
  @override
  String toString() => 'ConfirmVaultCreationResultV1(<redacted>)';
}

final class UnlockVaultParamsV1 extends Equatable {
  final VaultHandleV1 handle;
  final String password;
  const UnlockVaultParamsV1({required this.handle, required this.password});
  @override
  List<Object?> get props => [handle, password];
  @override
  String toString() => 'UnlockVaultParamsV1(<redacted>)';
}

final class UnlockVaultResultV1 extends Equatable {
  final VaultAccessStateV1 state;
  const UnlockVaultResultV1({required this.state});
  @override
  List<Object?> get props => [state];
  @override
  String toString() => 'UnlockVaultResultV1(<redacted>)';
}

final class LockVaultParamsV1 extends Equatable {
  final VaultHandleV1 handle;
  const LockVaultParamsV1({required this.handle});
  @override
  List<Object?> get props => [handle];
  @override
  String toString() => 'LockVaultParamsV1(<redacted>)';
}

final class LockVaultResultV1 extends Equatable {
  final VaultAccessStateV1 state;
  const LockVaultResultV1({required this.state});
  @override
  List<Object?> get props => [state];
  @override
  String toString() => 'LockVaultResultV1(<redacted>)';
}

final class PrepareVaultRecoveryParamsV1 extends Equatable {
  final VaultHandleV1 handle;
  final String phrase;
  final String password;
  final String confirmation;
  const PrepareVaultRecoveryParamsV1({
    required this.handle,
    required this.phrase,
    required this.password,
    required this.confirmation,
  });
  @override
  List<Object?> get props => [handle, phrase, password, confirmation];
  @override
  String toString() => 'PrepareVaultRecoveryParamsV1(<redacted>)';
}

final class PrepareVaultRecoveryResultV1 extends Equatable {
  final VaultRecoveryChallengeV1 challenge;
  const PrepareVaultRecoveryResultV1({required this.challenge});
  @override
  List<Object?> get props => [challenge];
  @override
  String toString() => 'PrepareVaultRecoveryResultV1(<redacted>)';
}

final class ConfirmVaultRecoveryParamsV1 extends Equatable {
  final VaultHandleV1 handle;
  final List<String> answers;
  const ConfirmVaultRecoveryParamsV1({
    required this.handle,
    required this.answers,
  });
  @override
  List<Object?> get props => [handle, answers];
  @override
  String toString() => 'ConfirmVaultRecoveryParamsV1(<redacted>)';
}

final class ConfirmVaultRecoveryResultV1 extends Equatable {
  final VaultAccessStateV1 state;
  const ConfirmVaultRecoveryResultV1({required this.state});
  @override
  List<Object?> get props => [state];
  @override
  String toString() => 'ConfirmVaultRecoveryResultV1(<redacted>)';
}

final class CloseVaultParamsV1 extends Equatable {
  final VaultHandleV1 handle;
  const CloseVaultParamsV1({required this.handle});
  @override
  List<Object?> get props => [handle];
  @override
  String toString() => 'CloseVaultParamsV1(<redacted>)';
}

final class CloseVaultResultV1 extends Equatable {
  const CloseVaultResultV1();
  @override
  List<Object?> get props => [];
  @override
  String toString() => 'CloseVaultResultV1(<redacted>)';
}
