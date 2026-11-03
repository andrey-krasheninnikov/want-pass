import 'package:equatable/equatable.dart';
import 'package:want_pass_core/src/feature/vault/domain/_barrel.dart';

final class TotpCodeV1 extends Equatable {
  final String code;
  final DateTime validUntil;
  final Duration period;
  const TotpCodeV1._({
    required this.code,
    required this.validUntil,
    required this.period,
  });
  factory TotpCodeV1({
    required String code,
    required DateTime validUntil,
    required Duration period,
  }) {
    if (!RegExp(r'^[0-9]{6,8}$').hasMatch(code) ||
        !validUntil.isUtc ||
        period.inSeconds < 1 ||
        period.inSeconds > 86400) {
      throw const VaultRejectedErrorV1(VaultFailureKindV1.unsupported);
    }
    return TotpCodeV1._(code: code, validUntil: validUntil, period: period);
  }
  TotpCodeV1 copyWith({String? code, DateTime? validUntil, Duration? period}) =>
      TotpCodeV1(
        code: code ?? this.code,
        validUntil: validUntil ?? this.validUntil,
        period: period ?? this.period,
      );
  @override
  List<Object?> get props => [code, validUntil, period];
  @override
  String toString() => 'TotpCodeV1(<redacted>)';
  String toDebugString() =>
      'TotpCodeV1(code: <redacted>, validUntil: <redacted>, period: <redacted>)';
}
