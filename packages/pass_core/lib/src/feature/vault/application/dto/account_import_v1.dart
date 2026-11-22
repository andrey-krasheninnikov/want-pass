import 'package:equatable/equatable.dart';

enum AccountImportSourceV1 { applePasswords, authenticator }

final class AccountImportRowV1 extends Equatable {
  final String name;
  final bool duplicate;
  const AccountImportRowV1({required this.name, required this.duplicate});
  @override
  List<Object?> get props => [name, duplicate];
  @override
  String toString() => 'AccountImportRowV1(<redacted>)';
}

final class AccountImportPreviewV1 extends Equatable {
  final String token;
  final List<AccountImportRowV1> rows;
  AccountImportPreviewV1({
    required this.token,
    required Iterable<AccountImportRowV1> rows,
  }) : rows = List.unmodifiable(rows);
  @override
  List<Object?> get props => [token, rows];
  @override
  String toString() => 'AccountImportPreviewV1(<redacted>)';
}
