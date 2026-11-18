import 'package:equatable/equatable.dart';

final class AttachmentDraftV1 extends Equatable {
  final String name;
  final List<int> bytes;
  const AttachmentDraftV1({required this.name, required this.bytes});
  @override
  List<Object?> get props => [name, bytes];
  @override
  String toString() => 'AttachmentDraftV1(<redacted>)';
}
