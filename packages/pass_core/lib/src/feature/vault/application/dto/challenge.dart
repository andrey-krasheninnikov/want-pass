import 'package:equatable/equatable.dart';

final class VaultRecoveryChallengeV1 extends Equatable {
  final List<String> words;
  final List<int> positions;
  const VaultRecoveryChallengeV1({
    required this.words,
    required this.positions,
  });
  @override
  List<Object?> get props => [words, positions];
  @override
  String toString() => 'VaultRecoveryChallengeV1(<redacted>)';
}
