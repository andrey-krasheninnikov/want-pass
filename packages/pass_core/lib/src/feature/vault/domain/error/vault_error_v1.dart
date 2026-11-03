import 'package:domain_error/domain_error.dart';
import 'package:want_pass_core/src/feature/vault/domain/_barrel.dart';

sealed class VaultErrorV1 extends DomainError {
  const VaultErrorV1();
  @override
  String get typeIdentifier => 'VaultErrorV1';
  @override
  String toString() => typeIdentifier;
}

final class VaultRejectedErrorV1 extends VaultErrorV1 {
  final VaultFailureKindV1 kind;
  const VaultRejectedErrorV1(this.kind);
  @override
  String get typeIdentifier => 'VaultRejectedErrorV1';
  @override
  List<Object?> get props => [...super.props, kind];
}

final class VaultUnexpectedErrorV1 extends VaultErrorV1 {
  const VaultUnexpectedErrorV1();
  @override
  String get typeIdentifier => 'VaultUnexpectedErrorV1';
}
