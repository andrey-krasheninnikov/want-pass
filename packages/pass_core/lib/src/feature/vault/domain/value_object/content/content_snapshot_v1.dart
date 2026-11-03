import 'package:equatable/equatable.dart';
import 'package:want_pass_core/src/feature/vault/domain/_barrel.dart';

final class ContentSnapshotV1 extends Equatable {
  final BigInt revision;
  final List<GroupV1> groups;
  final List<AccountSummaryV1> accounts;
  const ContentSnapshotV1._({
    required this.revision,
    required this.groups,
    required this.accounts,
  });
  factory ContentSnapshotV1({
    required BigInt revision,
    required List<GroupV1> groups,
    required List<AccountSummaryV1> accounts,
  }) {
    if (revision.isNegative) {
      throw const VaultRejectedErrorV1(VaultFailureKindV1.unsupported);
    }
    return ContentSnapshotV1._(
      revision: revision,
      groups: List.unmodifiable(groups),
      accounts: List.unmodifiable(accounts),
    );
  }
  ContentSnapshotV1 copyWith({
    BigInt? revision,
    List<GroupV1>? groups,
    List<AccountSummaryV1>? accounts,
  }) => ContentSnapshotV1(
    revision: revision ?? this.revision,
    groups: groups ?? this.groups,
    accounts: accounts ?? this.accounts,
  );
  @override
  List<Object?> get props => [revision, groups, accounts];
  @override
  String toString() => 'ContentSnapshotV1(<redacted>)';
  String toDebugString() =>
      'ContentSnapshotV1(revision: <redacted>, groups: <redacted>, accounts: <redacted>)';
}
