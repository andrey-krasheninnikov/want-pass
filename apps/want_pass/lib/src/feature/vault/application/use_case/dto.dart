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

final class PrepareVaultSetupParamsV2 extends Equatable {
  final VaultHandleV1 handle;
  final String password, confirmation;
  final String? phrase;
  const PrepareVaultSetupParamsV2({
    required this.handle,
    required this.password,
    required this.confirmation,
    this.phrase,
  });
  @override
  List<Object?> get props => [handle, password, confirmation, phrase];
  @override
  String toString() => 'PrepareVaultSetupParamsV2(<redacted>)';
}

final class PrepareVaultSetupResultV2 extends Equatable {
  final VaultRecoveryChallengeV2 challenge;
  const PrepareVaultSetupResultV2({required this.challenge});
  @override
  List<Object?> get props => [challenge];
  @override
  String toString() => 'PrepareVaultSetupResultV2(<redacted>)';
}

final class ConfirmVaultSetupParamsV2 extends Equatable {
  final VaultHandleV1 handle;
  final List<String> answers;
  final String password;
  final VaultHintsDtoV2 hints;
  const ConfirmVaultSetupParamsV2({
    required this.handle,
    required this.answers,
    required this.password,
    required this.hints,
  });
  @override
  List<Object?> get props => [handle, answers, password, hints];
  @override
  String toString() => 'ConfirmVaultSetupParamsV2(<redacted>)';
}

final class ConfirmVaultSetupResultV2 extends Equatable {
  final VaultAccessStateV1 state;
  const ConfirmVaultSetupResultV2({required this.state});
  @override
  List<Object?> get props => [state];
}

final class ReadVaultHintsParamsV2 extends Equatable {
  final VaultHandleV1 handle;
  const ReadVaultHintsParamsV2({required this.handle});
  @override
  List<Object?> get props => [handle];
}

final class ReadVaultHintsResultV2 extends Equatable {
  final VaultHintsDtoV2 hints;
  const ReadVaultHintsResultV2({required this.hints});
  @override
  List<Object?> get props => [hints];
  @override
  String toString() => 'ReadVaultHintsResultV2(<redacted>)';
}

final class SelectRecoveryFileParamsV1 extends Equatable {
  const SelectRecoveryFileParamsV1();
  @override
  List<Object?> get props => [];
}

final class SelectRecoveryFileResultV1 extends Equatable {
  final String? destination;
  const SelectRecoveryFileResultV1({required this.destination});
  @override
  List<Object?> get props => [destination];
  @override
  String toString() => 'SelectRecoveryFileResultV1(<redacted>)';
}

final class ExportRecoveryParamsV2 extends Equatable {
  final VaultHandleV1 handle;
  final String destination;
  const ExportRecoveryParamsV2({
    required this.handle,
    required this.destination,
  });
  @override
  List<Object?> get props => [handle, destination];
  @override
  String toString() => 'ExportRecoveryParamsV2(<redacted>)';
}

final class RecoveryClipboardParamsV1 extends Equatable {
  final String phrase;
  const RecoveryClipboardParamsV1({required this.phrase});
  @override
  List<Object?> get props => [phrase];
  @override
  String toString() => 'RecoveryClipboardParamsV1(<redacted>)';
}

final class RecoveryExportResultV1 extends Equatable {
  const RecoveryExportResultV1();
  @override
  List<Object?> get props => [];
}

final class PrepareVaultSetupParamsV3 extends Equatable {
  final VaultHandleV1 handle;
  final String password, confirmation;
  final String? phrase;
  const PrepareVaultSetupParamsV3({
    required this.handle,
    required this.password,
    required this.confirmation,
    this.phrase,
  });
  @override
  List<Object?> get props => [handle, password, confirmation, phrase];
  @override
  String toString() => 'PrepareVaultSetupParamsV3(<redacted>)';
}

final class PrepareVaultSetupResultV3 extends Equatable {
  final VaultRecoveryChallengeV3 challenge;
  const PrepareVaultSetupResultV3({required this.challenge});
  @override
  List<Object?> get props => [challenge];
  @override
  String toString() => 'PrepareVaultSetupResultV3(<redacted>)';
}

final class ConfirmVaultSetupParamsV3 extends Equatable {
  final VaultHandleV1 handle;
  final List<String> answers;
  final String password;
  final BigInt revision;
  final bool passwordSaved, phraseSaved, lossAccepted;
  final VaultHintsDtoV2 hints;
  const ConfirmVaultSetupParamsV3({
    required this.handle,
    required this.answers,
    required this.password,
    required this.revision,
    required this.passwordSaved,
    required this.phraseSaved,
    required this.lossAccepted,
    required this.hints,
  });
  @override
  List<Object?> get props => [
    handle,
    answers,
    password,
    hints,
    revision,
    passwordSaved,
    phraseSaved,
    lossAccepted,
  ];
  @override
  String toString() => 'ConfirmVaultSetupParamsV3(<redacted>)';
}

final class ConfirmVaultSetupResultV3 extends Equatable {
  final VaultAccessStateV1 state;
  const ConfirmVaultSetupResultV3({required this.state});
  @override
  List<Object?> get props => [state];
}

final class RegenerateVaultRecoveryParamsV3 extends Equatable {
  final VaultHandleV1 handle;
  const RegenerateVaultRecoveryParamsV3({required this.handle});
  @override
  List<Object?> get props => [handle];
  @override
  String toString() => 'RegenerateVaultRecoveryParamsV3(<redacted>)';
}

final class ValidateVaultRecoveryParamsV3 extends Equatable {
  final VaultHandleV1 handle;
  final String phrase;
  const ValidateVaultRecoveryParamsV3({
    required this.handle,
    required this.phrase,
  });
  @override
  List<Object?> get props => [handle, phrase];
  @override
  String toString() => 'ValidateVaultRecoveryParamsV3(<redacted>)';
}

final class ExportRecoveryParamsV3 extends Equatable {
  final VaultHandleV1 handle;
  final String destination;
  final BigInt revision;
  const ExportRecoveryParamsV3({
    required this.handle,
    required this.destination,
    required this.revision,
  });
  @override
  List<Object?> get props => [handle, destination, revision];
  @override
  String toString() => 'ExportRecoveryParamsV3(<redacted>)';
}

final class ValidateVaultRecoveryResultV3 extends Equatable {
  const ValidateVaultRecoveryResultV3();
  @override
  List<Object?> get props => [];
}

final class SelectRecoveryFileParamsV3 extends Equatable {
  const SelectRecoveryFileParamsV3();
  @override
  List<Object?> get props => [];
}

final class ValidatePasswordParamsV3 extends Equatable {
  final String password;
  const ValidatePasswordParamsV3({required this.password});
  @override
  List<Object?> get props => [password];
  @override
  String toString() => 'ValidatePasswordParamsV3(<redacted>)';
}

final class ValidatePasswordResultV3 extends Equatable {
  final bool valid;
  const ValidatePasswordResultV3({required this.valid});
  @override
  List<Object?> get props => [valid];
}

final class UnlockVaultParamsV3 extends Equatable {
  final VaultHandleV1 handle;
  final String password;
  const UnlockVaultParamsV3({required this.handle, required this.password});
  @override
  List<Object?> get props => [handle, password];
  @override
  String toString() => 'UnlockVaultParamsV3(<redacted>)';
}

final class UnlockVaultResultV3 extends Equatable {
  final VaultAccessStateV1 state;
  const UnlockVaultResultV3({required this.state});
  @override
  List<Object?> get props => [state];
}
