// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import 'package:want_pass_core/src/feature/vault/infrastructure/_barrel.dart';

import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

// These functions are ignored because they are not marked as `pub`: `archive_file`, `backup_current`, `incoming`
// These function are ignored because they are on traits that is not defined in current crate (put an empty `#[frb]` on it to unignore): `assert_receiver_is_total_eq`, `assert_receiver_is_total_eq`, `assert_receiver_is_total_eq`, `clone`, `clone`, `clone`, `clone`, `cmp`, `eq`, `eq`, `eq`, `partial_cmp`

class BackupChoiceV1 {
  final BackupEntityV1 entity;
  final String id;
  final BackupResolutionV1 resolution;

  const BackupChoiceV1({
    required this.entity,
    required this.id,
    required this.resolution,
  });

  @override
  int get hashCode => entity.hashCode ^ id.hashCode ^ resolution.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BackupChoiceV1 &&
          runtimeType == other.runtimeType &&
          entity == other.entity &&
          id == other.id &&
          resolution == other.resolution;
}

class BackupConflictV1 {
  final BackupEntityV1 entity;
  final String id;
  final String localName;
  final String incomingName;
  final BackupResolutionV1? resolution;

  const BackupConflictV1({
    required this.entity,
    required this.id,
    required this.localName,
    required this.incomingName,
    this.resolution,
  });

  @override
  int get hashCode =>
      entity.hashCode ^
      id.hashCode ^
      localName.hashCode ^
      incomingName.hashCode ^
      resolution.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BackupConflictV1 &&
          runtimeType == other.runtimeType &&
          entity == other.entity &&
          id == other.id &&
          localName == other.localName &&
          incomingName == other.incomingName &&
          resolution == other.resolution;
}

enum BackupEntityV1 { group, service, template, card, history }

class BackupPreviewV1 {
  final BigInt revision;
  final String fingerprint;
  final int added;
  final int changed;
  final int removed;
  final int identicalCount;
  final List<BackupConflictV1> conflicts;

  const BackupPreviewV1({
    required this.revision,
    required this.fingerprint,
    required this.added,
    required this.changed,
    required this.removed,
    required this.identicalCount,
    required this.conflicts,
  });

  @override
  int get hashCode =>
      revision.hashCode ^
      fingerprint.hashCode ^
      added.hashCode ^
      changed.hashCode ^
      removed.hashCode ^
      identicalCount.hashCode ^
      conflicts.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BackupPreviewV1 &&
          runtimeType == other.runtimeType &&
          revision == other.revision &&
          fingerprint == other.fingerprint &&
          added == other.added &&
          changed == other.changed &&
          removed == other.removed &&
          identicalCount == other.identicalCount &&
          conflicts == other.conflicts;
}

enum BackupResolutionV1 { local, incoming, both }

enum BackupStrategyV1 { replace, merge }
