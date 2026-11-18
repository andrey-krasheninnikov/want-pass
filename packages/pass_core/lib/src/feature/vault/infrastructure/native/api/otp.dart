// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import 'package:want_pass_core/src/feature/vault/infrastructure/_barrel.dart';

import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

// These functions are ignored because they are not marked as `pub`: `build`, `code`, `current_code`, `field`, `normalize_totp`, `parameters`, `validate_account_totp`
// These functions are ignored (category: IgnoreBecauseExplicitAttribute): `totp_code_v1`

class TotpCodeV1 {
  final String code;
  final BigInt validUntil;
  final BigInt period;

  const TotpCodeV1({
    required this.code,
    required this.validUntil,
    required this.period,
  });

  @override
  int get hashCode => code.hashCode ^ validUntil.hashCode ^ period.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TotpCodeV1 &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          validUntil == other.validUntil &&
          period == other.period;
}
