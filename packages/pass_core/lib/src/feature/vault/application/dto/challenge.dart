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

final class VaultRecoveryChallengeV2 extends Equatable {
  final List<String> words;
  final List<int> positions;
  final List<List<String>> choices;
  const VaultRecoveryChallengeV2({
    required this.words,
    required this.positions,
    required this.choices,
  });
  @override
  List<Object?> get props => [words, positions, choices];
  @override
  String toString() => 'VaultRecoveryChallengeV2(<redacted>)';
}

final class VaultHintsDtoV2 extends Equatable {
  final String password;
  final String recovery;
  const VaultHintsDtoV2({this.password = '', this.recovery = ''});
  @override
  List<Object?> get props => [password, recovery];
  @override
  String toString() => 'VaultHintsDtoV2(<redacted>)';
}
