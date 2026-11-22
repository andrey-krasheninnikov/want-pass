import 'package:domain_error/domain_error.dart';
import 'package:want_pass_core/src/feature/vault/application/_barrel.dart';

/// Input material is transient and never included in diagnostics.
final class RecoveryWordsV1 {
  final List<String> words;
  final List<int> invalidPositions;
  final bool complete;
  final bool recognized;

  RecoveryWordsV1({
    required Iterable<String> words,
    required Iterable<int> invalidPositions,
    required this.complete,
    required this.recognized,
  }) : words = List.unmodifiable(words),
       invalidPositions = List.unmodifiable(invalidPositions);

  @override
  String toString() => 'RecoveryWordsV1(<redacted>)';
}

enum BackupModeV1 { replace, merge }

enum BackupDecisionV1 { local, incoming, both }

enum BackupEntryKindV1 { group, service, template, card, history }

final class BackupSelectionV1 {
  final BackupEntryKindV1 kind;
  final String id;
  final BackupDecisionV1 decision;
  const BackupSelectionV1(this.kind, this.id, this.decision);
}

final class BackupDifferenceV1 {
  final BackupEntryKindV1 kind;
  final String id, localName, incomingName;
  final BackupDecisionV1? decision;
  const BackupDifferenceV1(
    this.kind,
    this.id,
    this.localName,
    this.incomingName,
    this.decision,
  );
}

final class BackupReviewV1 {
  final BigInt revision;
  final String fingerprint;
  final int added, changed, removed, identical;
  final List<BackupDifferenceV1> conflicts;

  BackupReviewV1({
    required this.revision,
    required this.fingerprint,
    required this.added,
    required this.changed,
    required this.removed,
    required this.identical,
    required Iterable<BackupDifferenceV1> conflicts,
  }) : conflicts = List.unmodifiable(conflicts);

  bool get resolved =>
      conflicts.every((difference) => difference.decision != null);
}

abstract interface class VaultBackupAccessV1 {
  FutureDomainResult<RecoveryWordsV1> inspectRecoveryWordsV1(String input);
  FutureDomainResult<void> exportBackupV1({
    required VaultHandleV1 handle,
    required String destination,
    required BigInt revision,
  });
  FutureDomainResult<BackupReviewV1> previewBackupV1({
    required VaultHandleV1 handle,
    required String source,
    required String phrase,
    required BackupModeV1 mode,
    required List<BackupSelectionV1> choices,
  });
  FutureDomainResult<void> applyBackupV1({
    required VaultHandleV1 handle,
    required String source,
    required String phrase,
    required BackupModeV1 mode,
    required List<BackupSelectionV1> choices,
    required BackupReviewV1 review,
  });
}
