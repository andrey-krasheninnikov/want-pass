import 'dart:convert';

import 'package:domain_error/domain_error.dart';
import 'package:want_pass_core/want_pass_core.dart';

final backupFixtureWords = [...List.filled(23, 'abandon'), 'art'];
final backupFixturePhrase = backupFixtureWords.join(' ');
final backupFixtureJson = const JsonEncoder.withIndent('  ').convert({
  for (var i = 0; i < backupFixtureWords.length; i++)
    '${i + 1}': backupFixtureWords[i],
});

mixin BackupAccessFixture implements VaultBackupAccessV1 {
  @override
  FutureDomainResult<RecoveryWordsV1> inspectRecoveryWordsV1(
    String input,
  ) async {
    final known = input == backupFixturePhrase || input == backupFixtureJson;
    return Result.success(
      RecoveryWordsV1(
        words: known ? backupFixtureWords : const [],
        invalidPositions: const [],
        complete: known,
        recognized: known,
      ),
    );
  }

  @override
  FutureDomainResult<void> exportBackupV1({
    required VaultHandleV1 handle,
    required String destination,
    required BigInt revision,
  }) => throw UnimplementedError();

  @override
  FutureDomainResult<BackupReviewV1> previewBackupV1({
    required VaultHandleV1 handle,
    required String source,
    required String phrase,
    required BackupModeV1 mode,
    required List<BackupSelectionV1> choices,
  }) => throw UnimplementedError();

  @override
  FutureDomainResult<void> applyBackupV1({
    required VaultHandleV1 handle,
    required String source,
    required String phrase,
    required BackupModeV1 mode,
    required List<BackupSelectionV1> choices,
    required BackupReviewV1 review,
  }) => throw UnimplementedError();
}
