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
  final bool recovering;
  final VaultRecoveryChallengeV1? challenge;
  final VaultErrorV1? error;
  final VaultRecoveryChallengeV2? setupChallenge;
  final VaultHintsDtoV2 hints;
  final List<String?> setupAnswers;
  final List<bool> quizPassed;
  const VaultState({
    required this.phase,
    this.busy = false,
    this.recovering = false,
    this.challenge,
    this.error,
    this.setupChallenge,
    this.hints = const VaultHintsDtoV2(),
    this.setupAnswers = const [null, null, null],
    this.quizPassed = const [false, false, false],
  });
  VaultState copyWith({
    bool? busy,
    VaultErrorV1? Function()? error,
    VaultHintsDtoV2? hints,
    List<String?>? setupAnswers,
    List<bool>? quizPassed,
  }) => VaultState(
    phase: phase,
    busy: busy ?? this.busy,
    recovering: recovering,
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
    recovering,
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
