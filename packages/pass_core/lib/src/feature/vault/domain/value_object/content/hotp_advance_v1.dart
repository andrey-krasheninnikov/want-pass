import 'package:equatable/equatable.dart';
import 'package:want_pass_core/src/feature/vault/domain/_barrel.dart';

final class HotpAdvanceV1 extends Equatable {
  final ContentSnapshotV2 snapshot;
  final String code;

  HotpAdvanceV1({required this.snapshot, required this.code}) {
    if (!RegExp(r'^[0-9]{6}$').hasMatch(code)) {
      throw const VaultRejectedErrorV1(VaultFailureKindV1.unsupported);
    }
  }

  @override
  List<Object?> get props => [snapshot, code];

  @override
  String toString() => 'HotpAdvanceV1(<redacted>)';

  String toDebugString() =>
      'HotpAdvanceV1(snapshot: <redacted>, code: <redacted>)';
}
