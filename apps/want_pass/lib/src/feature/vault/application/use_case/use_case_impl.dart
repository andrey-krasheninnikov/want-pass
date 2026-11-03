import 'package:domain_error/domain_error.dart';
import 'package:injectable/injectable.dart';
import 'package:want_pass/src/feature/vault/application/_barrel.dart';
import 'package:want_pass_core/want_pass_core.dart';

@Singleton(as: VaultUseCase)
final class VaultUseCaseImpl implements VaultUseCase {
  final VaultAccessService _access;
  final VaultReporter _reporter;
  final RecoveryExportService _export;
  final GroupLogoService _logos;
  final CredentialFileService _files;
  const VaultUseCaseImpl(
    this._access,
    this._reporter,
    this._export,
    this._logos,
    this._files,
  );
  @override
  FutureDomainResult<InitializeVaultResultV1> initializeV1({
    required InitializeVaultParamsV1 params,
  }) async {
    const op = 'VaultUseCaseImpl.initializeV1():';
    final result = await captureResult<InitializeVaultResultV1>(() async {
      final opened = await _access.openV1();
      if (opened.isError) throw opened.error;
      final handle = opened.value;
      final status = await _access.statusV1(handle: handle);
      if (status.isError) {
        try {
          await handle.close();
        } on Object {
          reportVaultSafely(
            _reporter,
            layer: VaultDiagnosticLayer.application,
            operation: op,
            error: const VaultUnexpectedErrorV1(),
          );
        }
        throw status.error;
      }
      return InitializeVaultResultV1(handle: handle, state: status.value);
    }, mapToDomainError: (error, stack) => const VaultUnexpectedErrorV1());
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.application,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<PrepareVaultCreationResultV1> prepareCreationV1({
    required PrepareVaultCreationParamsV1 params,
  }) async {
    const op = 'VaultUseCaseImpl.prepareCreationV1():';
    final result = await captureResult<PrepareVaultCreationResultV1>(() async {
      if (params.password != params.confirmation) {
        throw const VaultRejectedErrorV1(VaultFailureKindV1.passwordMismatch);
      }
      final prepared = await _access.prepareCreationV1(
        handle: params.handle,
        password: params.password,
      );
      if (prepared.isError) throw prepared.error;
      return PrepareVaultCreationResultV1(challenge: prepared.value);
    }, mapToDomainError: (error, stack) => const VaultUnexpectedErrorV1());
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.application,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<ConfirmVaultCreationResultV1> confirmCreationV1({
    required ConfirmVaultCreationParamsV1 params,
  }) async {
    const op = 'VaultUseCaseImpl.confirmCreationV1():';
    final result = await captureResult<ConfirmVaultCreationResultV1>(() async {
      final confirmed = await _access.confirmV1(
        handle: params.handle,
        answers: params.answers,
      );
      if (confirmed.isError) throw confirmed.error;
      final status = await _access.statusV1(handle: params.handle);
      if (status.isError) throw status.error;
      return ConfirmVaultCreationResultV1(state: status.value);
    }, mapToDomainError: (error, stack) => const VaultUnexpectedErrorV1());
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.application,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<ValidatePasswordResultV3> validatePasswordV3({
    required ValidatePasswordParamsV3 params,
  }) async {
    const op = 'VaultUseCaseImpl.validatePasswordV3():';
    final result = await captureResult<ValidatePasswordResultV3>(() async {
      final checked = await _access.validatePasswordV3(
        password: params.password,
      );
      if (checked.isError) throw checked.error;
      return ValidatePasswordResultV3(valid: checked.value);
    }, mapToDomainError: (error, stack) => const VaultUnexpectedErrorV1());
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.application,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<UnlockVaultResultV3> unlockV3({
    required UnlockVaultParamsV3 params,
  }) async {
    const op = 'VaultUseCaseImpl.unlockV3():';
    final result = await captureResult<UnlockVaultResultV3>(() async {
      final unlocked = await _access.unlockV3(
        handle: params.handle,
        password: params.password,
      );
      if (unlocked.isError) throw unlocked.error;
      final status = await _access.statusV1(handle: params.handle);
      if (status.isError) throw status.error;
      return UnlockVaultResultV3(state: status.value);
    }, mapToDomainError: (error, stack) => const VaultUnexpectedErrorV1());
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.application,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<UnlockVaultResultV1> unlockV1({
    required UnlockVaultParamsV1 params,
  }) async {
    const op = 'VaultUseCaseImpl.unlockV1():';
    final result = await captureResult<UnlockVaultResultV1>(() async {
      final unlocked = await _access.unlockV1(
        handle: params.handle,
        password: params.password,
      );
      if (unlocked.isError) throw unlocked.error;
      final status = await _access.statusV1(handle: params.handle);
      if (status.isError) throw status.error;
      return UnlockVaultResultV1(state: status.value);
    }, mapToDomainError: (error, stack) => const VaultUnexpectedErrorV1());
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.application,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<LockVaultResultV1> lockV1({
    required LockVaultParamsV1 params,
  }) async {
    const op = 'VaultUseCaseImpl.lockV1():';
    final result = await captureResult<LockVaultResultV1>(() async {
      params.handle.invalidateSync();
      final publication = await _access.waitForExportsV2(handle: params.handle);
      if (publication.isError) throw publication.error;
      final status = await _access.statusV1(handle: params.handle);
      if (status.isError) throw status.error;
      return LockVaultResultV1(state: status.value);
    }, mapToDomainError: (error, stack) => const VaultUnexpectedErrorV1());
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.application,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<PrepareVaultRecoveryResultV1> prepareRecoveryV1({
    required PrepareVaultRecoveryParamsV1 params,
  }) async {
    const op = 'VaultUseCaseImpl.prepareRecoveryV1():';
    final result = await captureResult<PrepareVaultRecoveryResultV1>(() async {
      if (params.password != params.confirmation) {
        throw const VaultRejectedErrorV1(VaultFailureKindV1.passwordMismatch);
      }
      final prepared = await _access.prepareRecoveryV1(
        handle: params.handle,
        phrase: params.phrase,
        password: params.password,
      );
      if (prepared.isError) throw prepared.error;
      return PrepareVaultRecoveryResultV1(challenge: prepared.value);
    }, mapToDomainError: (error, stack) => const VaultUnexpectedErrorV1());
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.application,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<ConfirmVaultRecoveryResultV1> confirmRecoveryV1({
    required ConfirmVaultRecoveryParamsV1 params,
  }) async {
    const op = 'VaultUseCaseImpl.confirmRecoveryV1():';
    final result = await captureResult<ConfirmVaultRecoveryResultV1>(() async {
      final confirmed = await _access.confirmV1(
        handle: params.handle,
        answers: params.answers,
      );
      if (confirmed.isError) throw confirmed.error;
      final status = await _access.statusV1(handle: params.handle);
      if (status.isError) throw status.error;
      return ConfirmVaultRecoveryResultV1(state: status.value);
    }, mapToDomainError: (error, stack) => const VaultUnexpectedErrorV1());
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.application,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<CloseVaultResultV1> closeV1({
    required CloseVaultParamsV1 params,
  }) async {
    const op = 'VaultUseCaseImpl.closeV1():';
    final result = await captureResult<CloseVaultResultV1>(() async {
      await params.handle.close();
      return const CloseVaultResultV1();
    }, mapToDomainError: (error, stack) => const VaultUnexpectedErrorV1());
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.application,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<PrepareVaultSetupResultV2> prepareSetupV2({
    required PrepareVaultSetupParamsV2 params,
  }) async {
    const op = 'VaultUseCaseImpl.prepareSetupV2():';
    final result = await captureResult<PrepareVaultSetupResultV2>(() async {
      if (params.password != params.confirmation) {
        throw const VaultRejectedErrorV1(VaultFailureKindV1.passwordMismatch);
      }
      final prepared = params.phrase == null
          ? await _access.prepareCreationV2(
              handle: params.handle,
              password: params.password,
            )
          : await _access.prepareRecoveryV2(
              handle: params.handle,
              phrase: params.phrase!,
              password: params.password,
            );
      if (prepared.isError) throw prepared.error;
      return PrepareVaultSetupResultV2(challenge: prepared.value);
    }, mapToDomainError: (_, _) => const VaultUnexpectedErrorV1());
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.application,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<ConfirmVaultSetupResultV2> confirmSetupV2({
    required ConfirmVaultSetupParamsV2 params,
  }) async {
    const op = 'VaultUseCaseImpl.confirmSetupV2():';
    final result = await captureResult<ConfirmVaultSetupResultV2>(() async {
      final result = await _access.confirmV2(
        handle: params.handle,
        answers: params.answers,
        password: params.password,
        hints: params.hints,
      );
      if (result.isError) throw result.error;
      final status = await _access.statusV1(handle: params.handle);
      if (status.isError) throw status.error;
      return ConfirmVaultSetupResultV2(state: status.value);
    }, mapToDomainError: (_, _) => const VaultUnexpectedErrorV1());
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.application,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<ReadVaultHintsResultV2> readHintsV2({
    required ReadVaultHintsParamsV2 params,
  }) async {
    const op = 'VaultUseCaseImpl.readHintsV2():';
    final result = await captureResult<ReadVaultHintsResultV2>(() async {
      final result = await _access.hintsV2(handle: params.handle);
      if (result.isError) throw result.error;
      return ReadVaultHintsResultV2(hints: result.value);
    }, mapToDomainError: (_, _) => const VaultUnexpectedErrorV1());
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.application,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<SelectRecoveryFileResultV1> selectRecoveryFileV1({
    required SelectRecoveryFileParamsV1 params,
  }) async {
    const op = 'VaultUseCaseImpl.selectRecoveryFileV1():';
    final result = await captureResult<SelectRecoveryFileResultV1>(() async {
      final result = await _export.selectFileV1();
      if (result.isError) throw result.error;
      return SelectRecoveryFileResultV1(destination: result.value);
    }, mapToDomainError: (_, _) => const VaultUnexpectedErrorV1());
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.application,
        operation: op,
        error: const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<RecoveryExportResultV1> exportRecoveryV2({
    required ExportRecoveryParamsV2 params,
  }) async {
    const op = 'VaultUseCaseImpl.exportRecoveryV2():';
    final result = await captureResult<RecoveryExportResultV1>(() async {
      final result = await _access.exportRecoveryV2(
        handle: params.handle,
        destination: params.destination,
      );
      if (result.isError) throw result.error;
      return const RecoveryExportResultV1();
    }, mapToDomainError: (_, _) => const VaultUnexpectedErrorV1());
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.application,
        operation: op,
        error: const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<RecoveryExportResultV1> copyRecoveryV1({
    required RecoveryClipboardParamsV1 params,
  }) async {
    const op = 'VaultUseCaseImpl.copyRecoveryV1():';
    final result = await captureResult<RecoveryExportResultV1>(() async {
      final result = await _export.copyV1(params.phrase);
      if (result.isError) throw result.error;
      return const RecoveryExportResultV1();
    }, mapToDomainError: (_, _) => const VaultUnexpectedErrorV1());
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.application,
        operation: op,
        error: const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<RecoveryExportResultV1> clearRecoveryClipboardV1({
    required RecoveryClipboardParamsV1 params,
  }) async {
    const op = 'VaultUseCaseImpl.clearRecoveryClipboardV1():';
    final result = await captureResult<RecoveryExportResultV1>(() async {
      final result = await _export.clearClipboardV1(params.phrase);
      if (result.isError) throw result.error;
      return const RecoveryExportResultV1();
    }, mapToDomainError: (_, _) => const VaultUnexpectedErrorV1());
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.application,
        operation: op,
        error: const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<PrepareVaultSetupResultV3> prepareSetupV3({
    required PrepareVaultSetupParamsV3 params,
  }) async {
    const op = 'VaultUseCaseImpl.prepareSetupV3():';
    final result = await captureResult<PrepareVaultSetupResultV3>(() async {
      if (params.password != params.confirmation) {
        throw const VaultRejectedErrorV1(VaultFailureKindV1.passwordMismatch);
      }
      final prepared = params.phrase == null
          ? await _access.prepareCreationV3(
              handle: params.handle,
              password: params.password,
            )
          : await _access.prepareRecoveryV3(
              handle: params.handle,
              phrase: params.phrase!,
              password: params.password,
            );
      if (prepared.isError) throw prepared.error;
      return PrepareVaultSetupResultV3(challenge: prepared.value);
    }, mapToDomainError: (_, _) => const VaultUnexpectedErrorV1());
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.application,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<ConfirmVaultSetupResultV3> confirmSetupV3({
    required ConfirmVaultSetupParamsV3 params,
  }) async {
    const op = 'VaultUseCaseImpl.confirmSetupV3():';
    final result = await captureResult<ConfirmVaultSetupResultV3>(() async {
      if (!params.passwordSaved ||
          !params.phraseSaved ||
          !params.lossAccepted) {
        throw const VaultRejectedErrorV1(VaultFailureKindV1.confirmation);
      }
      final result = await _access.confirmV3(
        handle: params.handle,
        answers: params.answers,
        password: params.password,
        hints: params.hints,
        revision: params.revision,
      );
      if (result.isError) throw result.error;
      final status = await _access.statusV1(handle: params.handle);
      if (status.isError) throw status.error;
      return ConfirmVaultSetupResultV3(state: status.value);
    }, mapToDomainError: (_, _) => const VaultUnexpectedErrorV1());
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.application,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<RecoveryExportResultV1> exportRecoveryV3({
    required ExportRecoveryParamsV3 params,
  }) async {
    const op = 'VaultUseCaseImpl.exportRecoveryV3():';
    final result = await captureResult<RecoveryExportResultV1>(() async {
      final result = await _access.exportRecoveryV3(
        handle: params.handle,
        destination: params.destination,
        revision: params.revision,
      );
      if (result.isError) throw result.error;
      return const RecoveryExportResultV1();
    }, mapToDomainError: (_, _) => const VaultUnexpectedErrorV1());
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.application,
        operation: op,
        error: const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<SelectRecoveryFileResultV1> selectRecoveryFileV3({
    required SelectRecoveryFileParamsV3 params,
  }) async {
    const op = 'VaultUseCaseImpl.selectRecoveryFileV3():';
    final result = await captureResult<SelectRecoveryFileResultV1>(() async {
      final result = await _export.selectFileV3();
      if (result.isError) throw result.error;
      return SelectRecoveryFileResultV1(destination: result.value);
    }, mapToDomainError: (_, _) => const VaultUnexpectedErrorV1());
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.application,
        operation: op,
        error: const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<PrepareVaultSetupResultV3> regenerateRecoveryV3({
    required RegenerateVaultRecoveryParamsV3 params,
  }) async {
    const op = 'VaultUseCaseImpl.regenerateRecoveryV3():';
    final result = await captureResult<PrepareVaultSetupResultV3>(() async {
      final outcome = await _access.regenerateRecoveryV3(handle: params.handle);
      if (outcome.isError) throw outcome.error;
      return PrepareVaultSetupResultV3(challenge: outcome.value);
    }, mapToDomainError: (_, _) => const VaultUnexpectedErrorV1());
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.application,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<ValidateVaultRecoveryResultV3> validateRecoveryV3({
    required ValidateVaultRecoveryParamsV3 params,
  }) async {
    const op = 'VaultUseCaseImpl.validateRecoveryV3():';
    final result = await captureResult<ValidateVaultRecoveryResultV3>(() async {
      final outcome = await _access.validateRecoveryV3(
        handle: params.handle,
        phrase: params.phrase,
      );
      if (outcome.isError) throw outcome.error;
      return const ValidateVaultRecoveryResultV3();
    }, mapToDomainError: (_, _) => const VaultUnexpectedErrorV1());
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.application,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<LoadContentResultV1> loadContentV1({
    required LoadContentParamsV1 params,
  }) async {
    const op = 'VaultUseCaseImpl.loadContentV1():';
    final result = await captureResult<LoadContentResultV1>(() async {
      final result = await _access.contentV1(handle: params.handle);
      if (result.isError) throw result.error;
      return LoadContentResultV1(snapshot: result.value);
    }, mapToDomainError: (_, _) => const VaultUnexpectedErrorV1());
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.application,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<SaveGroupResultV1> saveGroupV1({
    required SaveGroupParamsV1 params,
  }) async {
    const op = 'VaultUseCaseImpl.saveGroupV1():';
    final result = await captureResult<SaveGroupResultV1>(() async {
      final result = await _access.saveGroupV1(
        handle: params.handle,
        input: params.input,
        revision: params.revision,
      );
      if (result.isError) throw result.error;
      return SaveGroupResultV1(snapshot: result.value);
    }, mapToDomainError: (_, _) => const VaultUnexpectedErrorV1());
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.application,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<DeleteGroupResultV1> deleteGroupV1({
    required DeleteGroupParamsV1 params,
  }) async {
    const op = 'VaultUseCaseImpl.deleteGroupV1():';
    final result = await captureResult<DeleteGroupResultV1>(() async {
      final result = await _access.deleteGroupV1(
        handle: params.handle,
        id: params.id,
        revision: params.revision,
      );
      if (result.isError) throw result.error;
      return DeleteGroupResultV1(snapshot: result.value);
    }, mapToDomainError: (_, _) => const VaultUnexpectedErrorV1());
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.application,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<ReadAccountResultV1> readAccountV1({
    required ReadAccountParamsV1 params,
  }) async {
    const op = 'VaultUseCaseImpl.readAccountV1():';
    final result = await captureResult<ReadAccountResultV1>(() async {
      final result = await _access.accountV1(
        handle: params.handle,
        id: params.id,
      );
      if (result.isError) throw result.error;
      return ReadAccountResultV1(account: result.value);
    }, mapToDomainError: (_, _) => const VaultUnexpectedErrorV1());
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.application,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<SaveAccountResultV1> saveAccountV1({
    required SaveAccountParamsV1 params,
  }) async {
    const op = 'VaultUseCaseImpl.saveAccountV1():';
    final result = await captureResult<SaveAccountResultV1>(() async {
      final result = await _access.saveAccountV1(
        handle: params.handle,
        input: params.input,
        revision: params.revision,
      );
      if (result.isError) throw result.error;
      return SaveAccountResultV1(snapshot: result.value);
    }, mapToDomainError: (_, _) => const VaultUnexpectedErrorV1());
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.application,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<DeleteAccountResultV1> deleteAccountV1({
    required DeleteAccountParamsV1 params,
  }) async {
    const op = 'VaultUseCaseImpl.deleteAccountV1():';
    final result = await captureResult<DeleteAccountResultV1>(() async {
      final result = await _access.deleteAccountV1(
        handle: params.handle,
        id: params.id,
        revision: params.revision,
      );
      if (result.isError) throw result.error;
      return DeleteAccountResultV1(snapshot: result.value);
    }, mapToDomainError: (_, _) => const VaultUnexpectedErrorV1());
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.application,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<SelectGroupLogoResultV1> selectGroupLogoV1({
    required SelectGroupLogoParamsV1 params,
  }) async {
    const op = 'VaultUseCaseImpl.selectGroupLogoV1():';
    final result = await captureResult<SelectGroupLogoResultV1>(() async {
      final selected = await _logos.selectV1();
      if (selected.isError) throw selected.error;
      return SelectGroupLogoResultV1(bytes: selected.value);
    }, mapToDomainError: (_, _) => const VaultUnexpectedErrorV1());
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.application,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<LoadContentResultV2> loadContentV2({
    required LoadContentParamsV2 params,
  }) async {
    const op = 'VaultUseCaseImpl.loadContentV2():';
    final result = await captureResult<LoadContentResultV2>(() async {
      final content = await _access.contentV2(handle: params.handle);
      if (content.isError) throw content.error;
      final catalog = await _access.cardCatalogV1();
      if (catalog.isError) throw catalog.error;
      return LoadContentResultV2(
        snapshot: content.value,
        catalog: catalog.value,
      );
    }, mapToDomainError: (_, _) => const VaultUnexpectedErrorV1());
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.application,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<SaveGroupResultV2> saveGroupV2({
    required SaveGroupParamsV2 params,
  }) async {
    const op = 'VaultUseCaseImpl.saveGroupV2():';
    final result = await captureResult<SaveGroupResultV2>(() async {
      final result = await _access.saveGroupV2(
        handle: params.handle,
        input: params.input,
        revision: params.revision,
      );
      if (result.isError) throw result.error;
      return SaveGroupResultV2(snapshot: result.value);
    }, mapToDomainError: (_, _) => const VaultUnexpectedErrorV1());
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.application,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<DeleteGroupResultV2> deleteGroupV2({
    required DeleteGroupParamsV2 params,
  }) async {
    const op = 'VaultUseCaseImpl.deleteGroupV2():';
    final result = await captureResult<DeleteGroupResultV2>(() async {
      final result = await _access.deleteGroupV2(
        handle: params.handle,
        id: params.id,
        revision: params.revision,
      );
      if (result.isError) throw result.error;
      return DeleteGroupResultV2(snapshot: result.value);
    }, mapToDomainError: (_, _) => const VaultUnexpectedErrorV1());
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.application,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<SearchCardsResultV1> searchCardsV1({
    required SearchCardsParamsV1 params,
  }) async {
    const op = 'VaultUseCaseImpl.searchCardsV1():';
    final result = await captureResult<SearchCardsResultV1>(() async {
      final value = await _access.searchCardsV1(
        handle: params.handle,
        query: params.query,
        revision: params.revision,
      );
      if (value.isError) throw value.error;
      return SearchCardsResultV1(matches: value.value);
    }, mapToDomainError: (_, _) => const VaultUnexpectedErrorV1());
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.application,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<ReadCardRowsResultV1> readCardRowsV1({
    required ReadCardRowsParamsV1 params,
  }) async {
    const op = 'VaultUseCaseImpl.readCardRowsV1():';
    final result = await captureResult<ReadCardRowsResultV1>(() async {
      final value = await _access.cardRowsV1(
        handle: params.handle,
        ids: params.ids,
        revision: params.revision,
      );
      if (value.isError) throw value.error;
      return ReadCardRowsResultV1(rows: value.value);
    }, mapToDomainError: (_, _) => const VaultUnexpectedErrorV1());
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.application,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<ReadCardPreviewResultV1> readCardPreviewV1({
    required ReadCardPreviewParamsV1 params,
  }) async {
    const op = 'VaultUseCaseImpl.readCardPreviewV1():';
    final result = await captureResult<ReadCardPreviewResultV1>(() async {
      final value = await _access.cardPreviewV1(
        handle: params.handle,
        id: params.id,
        revision: params.revision,
      );
      if (value.isError) throw value.error;
      return ReadCardPreviewResultV1(preview: value.value);
    }, mapToDomainError: (_, _) => const VaultUnexpectedErrorV1());
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.application,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<ReadCardFieldResultV1> readCardFieldV1({
    required ReadCardFieldParamsV1 params,
  }) async {
    const op = 'VaultUseCaseImpl.readCardFieldV1():';
    final result = await captureResult<ReadCardFieldResultV1>(() async {
      final value = await _access.copyCardFieldV1(
        handle: params.handle,
        id: params.id,
        field: params.field,
      );
      if (value.isError) throw value.error;
      return ReadCardFieldResultV1(value: value.value);
    }, mapToDomainError: (_, _) => const VaultUnexpectedErrorV1());
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.application,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<ReadCardResultV1> readCardV1({
    required ReadCardParamsV1 params,
  }) async {
    const op = 'VaultUseCaseImpl.readCardV1():';
    final result = await captureResult<ReadCardResultV1>(() async {
      final result = await _access.cardV1(handle: params.handle, id: params.id);
      if (result.isError) throw result.error;
      return ReadCardResultV1(card: result.value);
    }, mapToDomainError: (_, _) => const VaultUnexpectedErrorV1());
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.application,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<SaveCardResultV1> saveCardV1({
    required SaveCardParamsV1 params,
  }) async {
    const op = 'VaultUseCaseImpl.saveCardV1():';
    final result = await captureResult<SaveCardResultV1>(() async {
      final result = await _access.saveCardV1(
        handle: params.handle,
        input: params.input,
        revision: params.revision,
      );
      if (result.isError) throw result.error;
      return SaveCardResultV1(snapshot: result.value);
    }, mapToDomainError: (_, _) => const VaultUnexpectedErrorV1());
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.application,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<DeleteCardResultV1> deleteCardV1({
    required DeleteCardParamsV1 params,
  }) async {
    const op = 'VaultUseCaseImpl.deleteCardV1():';
    final result = await captureResult<DeleteCardResultV1>(() async {
      final result = await _access.deleteCardV1(
        handle: params.handle,
        id: params.id,
        revision: params.revision,
      );
      if (result.isError) throw result.error;
      return DeleteCardResultV1(snapshot: result.value);
    }, mapToDomainError: (_, _) => const VaultUnexpectedErrorV1());
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.application,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<ReadTotpResultV1> readTotpV1({
    required ReadTotpParamsV1 params,
  }) async {
    const op = 'VaultUseCaseImpl.readTotpV1():';
    final result = await captureResult<ReadTotpResultV1>(() async {
      final result = await _access.currentTotpV1(
        handle: params.handle,
        id: params.id,
      );
      if (result.isError) throw result.error;
      return ReadTotpResultV1(code: result.value);
    }, mapToDomainError: (_, _) => const VaultUnexpectedErrorV1());
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.application,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<CopyCardResultV1> copyCardV1({
    required CopyCardParamsV1 params,
  }) async {
    const op = 'VaultUseCaseImpl.copyCardV1():';
    final result = await captureResult<CopyCardResultV1>(() async {
      String text;
      switch (params.kind) {
        case CardCopyKindV1.account:
          final result = await _access.copyAccountV1(
            handle: params.handle,
            id: params.id,
          );
          if (result.isError) throw result.error;
          text = result.value;
        case CardCopyKindV1.otp:
          final result = await _access.currentTotpV1(
            handle: params.handle,
            id: params.id,
          );
          if (result.isError) throw result.error;
          text = result.value.code;
        case CardCopyKindV1.field:
          final result = await _access.copyCardFieldV1(
            handle: params.handle,
            id: params.id,
            field: params.field!,
          );
          if (result.isError) throw result.error;
          text = result.value;
      }
      final copied = await _export.copyV1(text);
      if (copied.isError) throw copied.error;
      return CopyCardResultV1(text: text);
    }, mapToDomainError: (_, _) => const VaultUnexpectedErrorV1());
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.application,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<SelectAttachmentResultV1> selectAttachmentV1({
    required SelectAttachmentParamsV1 params,
  }) async {
    const op = 'VaultUseCaseImpl.selectAttachmentV1():';
    final result = await captureResult<SelectAttachmentResultV1>(() async {
      final result = await _files.selectAttachmentV1();
      if (result.isError) throw result.error;
      return SelectAttachmentResultV1(attachment: result.value);
    }, mapToDomainError: (_, _) => const VaultUnexpectedErrorV1());
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.application,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<SelectCardDestinationResultV1> selectCardDestinationV1({
    required SelectCardDestinationParamsV1 params,
  }) async {
    const op = 'VaultUseCaseImpl.selectCardDestinationV1():';
    final result = await captureResult<SelectCardDestinationResultV1>(() async {
      final result = await _files.selectDestinationV1(params.name);
      if (result.isError) throw result.error;
      return SelectCardDestinationResultV1(destination: result.value);
    }, mapToDomainError: (_, _) => const VaultUnexpectedErrorV1());
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.application,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<ExportCardAttachmentResultV1> exportCardAttachmentV1({
    required ExportCardAttachmentParamsV1 params,
  }) async {
    const op = 'VaultUseCaseImpl.exportCardAttachmentV1():';
    final result = await captureResult<ExportCardAttachmentResultV1>(() async {
      final result = await _access.exportAttachmentV1(
        handle: params.handle,
        id: params.id,
        destination: params.destination,
        revision: params.revision,
      );
      if (result.isError) throw result.error;
      return const ExportCardAttachmentResultV1();
    }, mapToDomainError: (_, _) => const VaultUnexpectedErrorV1());
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.application,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }
}
