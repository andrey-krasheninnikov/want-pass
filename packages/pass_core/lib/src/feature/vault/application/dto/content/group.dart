import 'package:equatable/equatable.dart';

final class GroupDraftV1 extends Equatable {
  final String? id;
  final String name;
  final String description;
  final String icon;
  final List<int> logo;
  const GroupDraftV1({
    this.id,
    required this.name,
    this.description = '',
    this.icon = 'folder',
    this.logo = const [],
  });
  @override
  List<Object?> get props => [id, name, description, icon, logo];
  @override
  String toString() => 'GroupDraftV1(<redacted>)';
}
