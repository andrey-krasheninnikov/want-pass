import 'package:equatable/equatable.dart';
import 'package:want_pass_core/src/feature/vault/domain/_barrel.dart';

final class AccountSummaryV1 extends Equatable {
  final String id;
  final String name;
  final List<String> groupIds;
  const AccountSummaryV1._({
    required this.id,
    required this.name,
    required this.groupIds,
  });
  factory AccountSummaryV1({
    required String id,
    required String name,
    required List<String> groupIds,
  }) {
    if (id.length != 32 ||
        !RegExp(r'^[0-9a-f]{32}$').hasMatch(id) ||
        name.trim().isEmpty ||
        name.length > 512) {
      throw const VaultRejectedErrorV1(VaultFailureKindV1.unsupported);
    }
    return AccountSummaryV1._(
      id: id,
      name: name,
      groupIds: List.unmodifiable(groupIds),
    );
  }
  AccountSummaryV1 copyWith({
    String? id,
    String? name,
    List<String>? groupIds,
  }) => AccountSummaryV1(
    id: id ?? this.id,
    name: name ?? this.name,
    groupIds: groupIds ?? this.groupIds,
  );
  @override
  List<Object?> get props => [id, name, groupIds];
  @override
  String toString() => 'AccountSummaryV1(<redacted>)';
  String toDebugString() =>
      'AccountSummaryV1(id: <redacted>, name: <redacted>, groupIds: <redacted>)';
}
