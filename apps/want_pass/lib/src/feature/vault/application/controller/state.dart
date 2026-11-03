part of 'controller.dart';

enum VaultLockSignal { lock }

enum VaultPhase {
  loading,
  missing,
  locked,
  unlocked,
  confirmation,
  unavailable,
}

final class VaultState extends Equatable {
  final VaultPhase phase;
  final bool busy;
  final bool? passwordValid;
  final bool passwordChecking;
  final bool recovering;
  final bool passwordSaved, phraseSaved, lossAccepted;
  final VaultRecoveryChallengeV1? challenge;
  final VaultErrorV1? error;
  final VaultRecoveryChallengeV3? setupChallenge;
  final VaultHintsDtoV2 hints;
  final List<String?> setupAnswers;
  final List<bool> quizPassed;
  const VaultState({
    required this.phase,
    this.busy = false,
    this.passwordValid,
    this.passwordChecking = false,
    this.recovering = false,
    this.passwordSaved = false,
    this.phraseSaved = false,
    this.lossAccepted = false,
    this.challenge,
    this.error,
    this.setupChallenge,
    this.hints = const VaultHintsDtoV2(),
    this.setupAnswers = const [null, null, null],
    this.quizPassed = const [false, false, false],
  });
  VaultState copyWith({
    bool? busy,
    bool? Function()? passwordValid,
    bool? passwordChecking,
    bool? passwordSaved,
    bool? phraseSaved,
    bool? lossAccepted,
    VaultErrorV1? Function()? error,
    VaultHintsDtoV2? hints,
    List<String?>? setupAnswers,
    List<bool>? quizPassed,
  }) => VaultState(
    phase: phase,
    busy: busy ?? this.busy,
    passwordValid: passwordValid == null ? this.passwordValid : passwordValid(),
    passwordChecking: passwordChecking ?? this.passwordChecking,
    recovering: recovering,
    passwordSaved: passwordSaved ?? this.passwordSaved,
    phraseSaved: phraseSaved ?? this.phraseSaved,
    lossAccepted: lossAccepted ?? this.lossAccepted,
    challenge: challenge,
    setupChallenge: setupChallenge,
    hints: hints ?? this.hints,
    setupAnswers: setupAnswers ?? this.setupAnswers,
    quizPassed: quizPassed ?? this.quizPassed,
    error: error == null ? this.error : error(),
  );
  @override
  List<Object?> get props => [
    phase,
    busy,
    passwordValid,
    passwordChecking,
    recovering,
    passwordSaved,
    phraseSaved,
    lossAccepted,
    challenge,
    setupChallenge,
    hints,
    setupAnswers,
    quizPassed,
    error,
  ];
  @override
  String toString() => 'VaultState(phase: ${phase.name}, busy: $busy)';
}
