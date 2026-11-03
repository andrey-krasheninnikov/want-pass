import 'package:domain_error/domain_error.dart';
import 'package:injectable/injectable.dart';
import 'package:want_pass/src/feature/vault/application/_barrel.dart';
import 'package:want_pass_core/want_pass_core.dart';

@Singleton(as: VaultUseCase)
final class VaultUseCaseImpl implements VaultUseCase {
  final VaultAccessService _access;
  final VaultReporter _reporter;
  const VaultUseCaseImpl(this._access, this._reporter);
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
}
