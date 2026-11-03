import 'package:equatable/equatable.dart';
import 'package:want_pass_core/src/feature/vault/domain/_barrel.dart';

final class GroupV1 extends Equatable {
  final String id;
  final String name;
  final String description;
  final String icon;
  final List<int> logo;
  const GroupV1._({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.logo,
  });
  factory GroupV1({
    required String id,
    required String name,
    required String description,
    required String icon,
    required List<int> logo,
  }) {
    if (id.length != 32 ||
        !RegExp(r'^[0-9a-f]{32}$').hasMatch(id) ||
        name.trim().isEmpty ||
        name.length > 512) {
      throw const VaultRejectedErrorV1(VaultFailureKindV1.unsupported);
    }
    if (description.length > 16384 ||
        !const [
          'folder',
          'building',
          'briefcase',
          'code',
          'home',
          'key',
        ].contains(icon) ||
        logo.length > 512 * 1024) {
      throw const VaultRejectedErrorV1(VaultFailureKindV1.unsupported);
    }
    return GroupV1._(
      id: id,
      name: name,
      description: description,
      icon: icon,
      logo: List.unmodifiable(logo),
    );
  }
  GroupV1 copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    List<int>? logo,
  }) => GroupV1(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    icon: icon ?? this.icon,
    logo: logo ?? this.logo,
  );
  @override
  List<Object?> get props => [id, name, description, icon, logo];
  @override
  String toString() => 'GroupV1(<redacted>)';
  String toDebugString() =>
      'GroupV1(id: <redacted>, name: <redacted>, description: <redacted>, icon: <redacted>, logo: <redacted>)';
}
