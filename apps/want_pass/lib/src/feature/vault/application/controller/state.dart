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
  const VaultState({
    required this.phase,
    this.busy = false,
    this.recovering = false,
    this.challenge,
    this.error,
  });
  VaultState copyWith({bool? busy, VaultErrorV1? Function()? error}) =>
      VaultState(
        phase: phase,
        busy: busy ?? this.busy,
        recovering: recovering,
        challenge: challenge,
        error: error == null ? this.error : error(),
      );
  @override
  List<Object?> get props => [phase, busy, recovering, challenge, error];
  @override
  String toString() => 'VaultState(phase: ${phase.name}, busy: $busy)';
}
