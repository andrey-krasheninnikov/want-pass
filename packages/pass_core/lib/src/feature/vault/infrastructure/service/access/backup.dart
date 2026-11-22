part of 'service_impl.dart';

mixin _RustBackupAccess on Object implements VaultBackupAccessV1 {
  VaultReporter get _reporter;
  Future<void> _confirmOperation(
    native.Vault vault,
    native.OperationV1 action,
    String subject,
    BigInt generation,
  );

  FutureDomainResult<T> _backupResult<T>(
    String operation,
    Future<T> Function() read,
  ) async {
    final result = await captureResult<T>(
      read,
      mapToDomainError: _mapNativeError,
    );
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.infrastructure,
        operation: operation,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<RecoveryWordsV1> inspectRecoveryWordsV1(String input) =>
      _backupResult(
        'RustVaultAccessService.inspectRecoveryWordsV1():',
        () async {
          final parsed = native.inspectRecoveryInputV1(input: input);
          return RecoveryWordsV1(
            words: parsed.words,
            invalidPositions: parsed.invalidPositions,
            complete: parsed.complete,
            recognized: parsed.recognized,
          );
        },
      );

  @override
  FutureDomainResult<void> exportBackupV1({
    required VaultHandleV1 handle,
    required String destination,
    required BigInt revision,
  }) => _backupResult('RustVaultAccessService.exportBackupV1():', () async {
    final vault = (handle as _NativeVaultHandle)._vault;
    final generation = vault.generation();
    final policy = await vault.protectionSettingsV1(generation: generation);
    final action = policy.operations.contains(native.OperationV1.recoveryKit)
        ? native.OperationV1.recoveryKit
        : native.OperationV1.export_;
    await _confirmOperation(vault, action, destination, generation);
    await vault.exportBackupV1(
      destination: destination,
      revision: revision,
      generation: generation,
    );
  });

  @override
  FutureDomainResult<BackupReviewV1> previewBackupV1({
    required VaultHandleV1 handle,
    required String source,
    required String phrase,
    required BackupModeV1 mode,
    required List<BackupSelectionV1> choices,
  }) => _backupResult('RustVaultAccessService.previewBackupV1():', () async {
    final vault = (handle as _NativeVaultHandle)._vault;
    final preview = await vault.previewBackupV1(
      source: source,
      phrase: phrase,
      strategy: _backupMode(mode),
      choices: _backupChoices(choices),
      generation: vault.generation(),
    );
    return BackupReviewV1(
      revision: preview.revision,
      fingerprint: preview.fingerprint,
      added: preview.added,
      changed: preview.changed,
      removed: preview.removed,
      identical: preview.identicalCount,
      conflicts: preview.conflicts.map(
        (c) => BackupDifferenceV1(
          BackupEntryKindV1.values.byName(c.entity.name),
          c.id,
          c.localName,
          c.incomingName,
          c.resolution == null
              ? null
              : BackupDecisionV1.values.byName(c.resolution!.name),
        ),
      ),
    );
  });

  @override
  FutureDomainResult<void> applyBackupV1({
    required VaultHandleV1 handle,
    required String source,
    required String phrase,
    required BackupModeV1 mode,
    required List<BackupSelectionV1> choices,
    required BackupReviewV1 review,
  }) => _backupResult('RustVaultAccessService.applyBackupV1():', () async {
    final vault = (handle as _NativeVaultHandle)._vault;
    final generation = vault.generation();
    final operation = mode == BackupModeV1.replace
        ? native.OperationV1.delete
        : native.OperationV1.protection;
    await _confirmOperation(vault, operation, review.fingerprint, generation);
    await vault.applyBackupV1(
      source: source,
      phrase: phrase,
      strategy: _backupMode(mode),
      choices: _backupChoices(choices),
      revision: review.revision,
      fingerprint: review.fingerprint,
      generation: generation,
    );
  });
}

native.BackupStrategyV1 _backupMode(BackupModeV1 mode) =>
    native.BackupStrategyV1.values.byName(mode.name);

List<native.BackupChoiceV1> _backupChoices(List<BackupSelectionV1> choices) => [
  for (final choice in choices)
    native.BackupChoiceV1(
      entity: native.BackupEntityV1.values.byName(choice.kind.name),
      id: choice.id,
      resolution: native.BackupResolutionV1.values.byName(choice.decision.name),
    ),
];
