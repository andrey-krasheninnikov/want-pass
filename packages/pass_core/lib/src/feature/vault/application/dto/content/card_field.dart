import 'package:equatable/equatable.dart';
import 'package:want_pass_core/src/feature/vault/domain/_barrel.dart';

final class CardFieldDraftV1 extends Equatable {
  final FieldIdV1 id;
  final String value;
  const CardFieldDraftV1({required this.id, required this.value});
  @override
  List<Object?> get props => [id, value];
  @override
  String toString() => 'CardFieldDraftV1(<redacted>)';
}
