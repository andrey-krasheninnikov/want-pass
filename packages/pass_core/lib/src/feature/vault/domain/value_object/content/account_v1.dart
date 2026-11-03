import 'package:equatable/equatable.dart';
import 'package:want_pass_core/src/feature/vault/domain/_barrel.dart';

final class AccountV1 extends Equatable {
  final String id;
  final String name;
  final String description;
  final String login;
  final String password;
  final List<String> groupIds;
  const AccountV1._({
    required this.id,
    required this.name,
    required this.description,
    required this.login,
    required this.password,
    required this.groupIds,
  });
  factory AccountV1({
    required String id,
    required String name,
    required String description,
    required String login,
    required String password,
    required List<String> groupIds,
  }) {
    if (id.length != 32 ||
        !RegExp(r'^[0-9a-f]{32}$').hasMatch(id) ||
        name.trim().isEmpty ||
        name.length > 512) {
      throw const VaultRejectedErrorV1(VaultFailureKindV1.unsupported);
    }
    if (description.length > 16384 ||
        login.trim().isEmpty ||
        login.length > 4096 ||
        password.isEmpty ||
        password.length > 65536) {
      throw const VaultRejectedErrorV1(VaultFailureKindV1.unsupported);
    }
    return AccountV1._(
      id: id,
      name: name,
      description: description,
      login: login,
      password: password,
      groupIds: List.unmodifiable(groupIds),
    );
  }
  AccountV1 copyWith({
    String? id,
    String? name,
    String? description,
    String? login,
    String? password,
    List<String>? groupIds,
  }) => AccountV1(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    login: login ?? this.login,
    password: password ?? this.password,
    groupIds: groupIds ?? this.groupIds,
  );
  @override
  List<Object?> get props => [id, name, description, login, password, groupIds];
  @override
  String toString() => 'AccountV1(<redacted>)';
  String toDebugString() =>
      'AccountV1(id: <redacted>, name: <redacted>, description: <redacted>, login: <redacted>, password: <redacted>, groupIds: <redacted>)';
}
