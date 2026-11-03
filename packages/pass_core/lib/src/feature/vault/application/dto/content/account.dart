import 'package:equatable/equatable.dart';

final class AccountDraftV1 extends Equatable {
  final String? id;
  final String name;
  final String description;
  final String login;
  final String password;
  final List<String> groupIds;
  const AccountDraftV1({
    this.id,
    required this.name,
    this.description = '',
    required this.login,
    required this.password,
    this.groupIds = const [],
  });
  @override
  List<Object?> get props => [id, name, description, login, password, groupIds];
  @override
  String toString() => 'AccountDraftV1(<redacted>)';
}
