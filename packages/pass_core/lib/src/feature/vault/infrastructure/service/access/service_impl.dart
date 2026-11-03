import 'dart:typed_data';

import 'package:domain_error/domain_error.dart';
import 'package:injectable/injectable.dart';
import 'package:want_pass_core/src/feature/vault/application/_barrel.dart';
import 'package:want_pass_core/src/feature/vault/domain/_barrel.dart';
import 'package:want_pass_core/src/feature/vault/infrastructure/_barrel.dart'
    as native;

@Singleton(as: VaultAccessService)
final class RustVaultAccessService implements VaultAccessService {
  final String _directory;
  final VaultReporter _reporter;
  const RustVaultAccessService(this._directory, this._reporter);
  @override
  FutureDomainResult<VaultHandleV1> openV1() async {
    const op = 'RustVaultAccessService.openV1():';
    final result = await captureResult<VaultHandleV1>(() async {
      final value = await native.Vault.open(directory: _directory);
      return _NativeVaultHandle(value, _reporter);
    }, mapToDomainError: _mapNativeError);
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.infrastructure,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<VaultAccessStateV1> statusV1({
    required VaultHandleV1 handle,
  }) async {
    const op = 'RustVaultAccessService.statusV1():';
    final result = await captureResult<VaultAccessStateV1>(() async {
      final value = await (handle as _NativeVaultHandle)._vault.status();
      return switch (value) {
        native.VaultStatus.missing => VaultAccessStateV1.missing,
        native.VaultStatus.locked => VaultAccessStateV1.locked,
        native.VaultStatus.unlocked => VaultAccessStateV1.unlocked,
        native.VaultStatus.confirmation => VaultAccessStateV1.confirmation,
      };
    }, mapToDomainError: _mapNativeError);
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.infrastructure,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<VaultRecoveryChallengeV1> prepareCreationV1({
    required VaultHandleV1 handle,
    required String password,
  }) async {
    const op = 'RustVaultAccessService.prepareCreationV1():';
    final result = await captureResult<VaultRecoveryChallengeV1>(() async {
      final value = await (handle as _NativeVaultHandle)._vault.prepareCreation(
        password: password,
        generation: (handle)._vault.generation(),
      );
      return VaultRecoveryChallengeV1(
        words: List.unmodifiable(value.words),
        positions: List.unmodifiable(value.positions),
      );
    }, mapToDomainError: _mapNativeError);
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.infrastructure,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<VaultRecoveryChallengeV1> prepareRecoveryV1({
    required VaultHandleV1 handle,
    required String phrase,
    required String password,
  }) async {
    const op = 'RustVaultAccessService.prepareRecoveryV1():';
    final result = await captureResult<VaultRecoveryChallengeV1>(() async {
      final value = await (handle as _NativeVaultHandle)._vault.prepareRecovery(
        phrase: phrase,
        password: password,
        generation: (handle)._vault.generation(),
      );
      return VaultRecoveryChallengeV1(
        words: List.unmodifiable(value.words),
        positions: List.unmodifiable(value.positions),
      );
    }, mapToDomainError: _mapNativeError);
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.infrastructure,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<void> confirmV1({
    required VaultHandleV1 handle,
    required List<String> answers,
  }) async {
    const op = 'RustVaultAccessService.confirmV1():';
    final result = await captureResult<void>(() async {
      await (handle as _NativeVaultHandle)._vault.confirm(
        answers: answers,
        generation: (handle)._vault.generation(),
      );
    }, mapToDomainError: _mapNativeError);
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.infrastructure,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<bool> validatePasswordV3({
    required String password,
  }) async {
    const op = 'RustVaultAccessService.validatePasswordV3():';
    final result = await captureResult<bool>(
      () => native.validatePasswordV3(password: password),
      mapToDomainError: _mapNativeError,
    );
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.infrastructure,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<void> unlockV3({
    required VaultHandleV1 handle,
    required String password,
  }) async {
    const op = 'RustVaultAccessService.unlockV3():';
    final result = await captureResult<void>(() async {
      await (handle as _NativeVaultHandle)._vault.unlockV3(
        password: password,
        generation: (handle)._vault.generation(),
      );
    }, mapToDomainError: _mapNativeError);
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.infrastructure,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<void> unlockV1({
    required VaultHandleV1 handle,
    required String password,
  }) async {
    const op = 'RustVaultAccessService.unlockV1():';
    final result = await captureResult<void>(() async {
      await (handle as _NativeVaultHandle)._vault.unlock(
        password: password,
        generation: (handle)._vault.generation(),
      );
    }, mapToDomainError: _mapNativeError);
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.infrastructure,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<VaultHintsDtoV2> hintsV2({
    required VaultHandleV1 handle,
  }) async {
    const op = 'RustVaultAccessService.hintsV2():';
    final result = await captureResult<VaultHintsDtoV2>(() async {
      final value = await (handle as _NativeVaultHandle)._vault.hintsV2();
      return VaultHintsDtoV2(
        password: value.password,
        recovery: value.recovery,
      );
    }, mapToDomainError: _mapNativeError);
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.infrastructure,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<void> validateRecoveryV3({
    required VaultHandleV1 handle,
    required String phrase,
  }) async {
    const op = 'RustVaultAccessService.validateRecoveryV3():';
    final result = await captureResult<void>(() async {
      await (handle as _NativeVaultHandle)._vault.validateRecoveryV3(
        phrase: phrase,
        generation: handle._vault.generation(),
      );
    }, mapToDomainError: _mapNativeError);
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.infrastructure,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<VaultRecoveryChallengeV3> prepareCreationV3({
    required VaultHandleV1 handle,
    required String password,
  }) async {
    const op = 'RustVaultAccessService.prepareCreationV3():';
    final result = await captureResult<VaultRecoveryChallengeV3>(() async {
      final value = await (handle as _NativeVaultHandle)._vault
          .prepareCreationV3(
            password: password,
            generation: handle._vault.generation(),
          );
      return VaultRecoveryChallengeV3(
        json: value.json,
        revision: value.revision,
        words: List.unmodifiable(value.words),
        positions: List.unmodifiable(value.positions),
        choices: List.unmodifiable(
          value.choices.map((v) => List<String>.unmodifiable(v)),
        ),
      );
    }, mapToDomainError: _mapNativeError);
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.infrastructure,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<VaultRecoveryChallengeV3> prepareRecoveryV3({
    required VaultHandleV1 handle,
    required String phrase,
    required String password,
  }) async {
    const op = 'RustVaultAccessService.prepareRecoveryV3():';
    final result = await captureResult<VaultRecoveryChallengeV3>(() async {
      final value = await (handle as _NativeVaultHandle)._vault
          .prepareRecoveryV3(
            phrase: phrase,
            password: password,
            generation: handle._vault.generation(),
          );
      return VaultRecoveryChallengeV3(
        json: value.json,
        revision: value.revision,
        words: List.unmodifiable(value.words),
        positions: List.unmodifiable(value.positions),
        choices: List.unmodifiable(
          value.choices.map((v) => List<String>.unmodifiable(v)),
        ),
      );
    }, mapToDomainError: _mapNativeError);
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.infrastructure,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<VaultRecoveryChallengeV3> regenerateRecoveryV3({
    required VaultHandleV1 handle,
  }) async {
    const op = 'RustVaultAccessService.regenerateRecoveryV3():';
    final result = await captureResult<VaultRecoveryChallengeV3>(() async {
      final value = await (handle as _NativeVaultHandle)._vault
          .regenerateRecoveryV3(generation: handle._vault.generation());
      return VaultRecoveryChallengeV3(
        json: value.json,
        revision: value.revision,
        words: List.unmodifiable(value.words),
        positions: List.unmodifiable(value.positions),
        choices: List.unmodifiable(
          value.choices.map((v) => List<String>.unmodifiable(v)),
        ),
      );
    }, mapToDomainError: _mapNativeError);
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.infrastructure,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<void> exportRecoveryV3({
    required VaultHandleV1 handle,
    required String destination,
    required BigInt revision,
  }) async {
    const op = 'RustVaultAccessService.exportRecoveryV3():';
    final result = await captureResult<void>(() async {
      await (handle as _NativeVaultHandle)._vault.exportRecoveryV3(
        destination: destination,
        revision: revision,
      );
    }, mapToDomainError: _mapNativeError);
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.infrastructure,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<void> confirmV3({
    required VaultHandleV1 handle,
    required List<String> answers,
    required String password,
    required VaultHintsDtoV2 hints,
    required BigInt revision,
  }) async {
    const op = 'RustVaultAccessService.confirmV3():';
    final result = await captureResult<void>(() async {
      await (handle as _NativeVaultHandle)._vault.confirmV3(
        answers: answers,
        password: password,
        passwordHint: hints.password,
        recoveryHint: hints.recovery,
        revision: revision,
      );
    }, mapToDomainError: _mapNativeError);
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.infrastructure,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<VaultRecoveryChallengeV2> prepareCreationV2({
    required VaultHandleV1 handle,
    required String password,
  }) async {
    const op = 'RustVaultAccessService.prepareCreationV2():';
    final result = await captureResult<VaultRecoveryChallengeV2>(() async {
      final value = await (handle as _NativeVaultHandle)._vault
          .prepareCreationV2(
            password: password,
            generation: handle._vault.generation(),
          );
      return VaultRecoveryChallengeV2(
        words: List.unmodifiable(value.words),
        positions: List.unmodifiable(value.positions),
        choices: List.unmodifiable(
          value.choices.map((v) => List<String>.unmodifiable(v)),
        ),
      );
    }, mapToDomainError: _mapNativeError);
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.infrastructure,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<VaultRecoveryChallengeV2> prepareRecoveryV2({
    required VaultHandleV1 handle,
    required String phrase,
    required String password,
  }) async {
    const op = 'RustVaultAccessService.prepareRecoveryV2():';
    final result = await captureResult<VaultRecoveryChallengeV2>(() async {
      final value = await (handle as _NativeVaultHandle)._vault
          .prepareRecoveryV2(
            phrase: phrase,
            password: password,
            generation: handle._vault.generation(),
          );
      return VaultRecoveryChallengeV2(
        words: List.unmodifiable(value.words),
        positions: List.unmodifiable(value.positions),
        choices: List.unmodifiable(
          value.choices.map((v) => List<String>.unmodifiable(v)),
        ),
      );
    }, mapToDomainError: _mapNativeError);
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.infrastructure,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<void> confirmV2({
    required VaultHandleV1 handle,
    required List<String> answers,
    required String password,
    required VaultHintsDtoV2 hints,
  }) async {
    const op = 'RustVaultAccessService.confirmV2():';
    final result = await captureResult<void>(() async {
      await (handle as _NativeVaultHandle)._vault.confirmV2(
        answers: answers,
        password: password,
        passwordHint: hints.password,
        recoveryHint: hints.recovery,
        generation: handle._vault.generation(),
      );
    }, mapToDomainError: _mapNativeError);
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.infrastructure,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<void> waitForExportsV2({
    required VaultHandleV1 handle,
  }) async {
    const op = 'RustVaultAccessService.waitForExportsV2():';
    final result = await captureResult<void>(() async {
      await (handle as _NativeVaultHandle)._vault.waitForExportsV2();
    }, mapToDomainError: _mapNativeError);
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.infrastructure,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<void> exportRecoveryV2({
    required VaultHandleV1 handle,
    required String destination,
  }) async {
    const op = 'RustVaultAccessService.exportRecoveryV2():';
    final result = await captureResult<void>(() async {
      await (handle as _NativeVaultHandle)._vault.exportRecoveryV2(
        destination: destination,
        generation: handle._vault.generation(),
      );
    }, mapToDomainError: _mapNativeError);
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.infrastructure,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<ContentSnapshotV1> contentV1({
    required VaultHandleV1 handle,
  }) async {
    const op = 'RustVaultAccessService.contentV1():';
    final result = await captureResult<ContentSnapshotV1>(() async {
      final vault = (handle as _NativeVaultHandle)._vault;
      final value = await vault.contentV1(generation: vault.generation());
      return _content(value);
    }, mapToDomainError: _mapNativeError);
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.infrastructure,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<ContentSnapshotV1> saveGroupV1({
    required VaultHandleV1 handle,
    required GroupDraftV1 input,
    required BigInt revision,
  }) async {
    const op = 'RustVaultAccessService.saveGroupV1():';
    final result = await captureResult<ContentSnapshotV1>(() async {
      final vault = (handle as _NativeVaultHandle)._vault;
      final value = await vault.saveGroupV1(
        input: native.GroupInputV1(
          id: input.id,
          name: input.name,
          description: input.description,
          icon: input.icon,
          logo: Uint8List.fromList(input.logo),
        ),
        revision: revision,
        generation: vault.generation(),
      );
      return _content(value);
    }, mapToDomainError: _mapNativeError);
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.infrastructure,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<ContentSnapshotV1> deleteGroupV1({
    required VaultHandleV1 handle,
    required String id,
    required BigInt revision,
  }) async {
    const op = 'RustVaultAccessService.deleteGroupV1():';
    final result = await captureResult<ContentSnapshotV1>(() async {
      final vault = (handle as _NativeVaultHandle)._vault;
      final value = await vault.deleteGroupV1(
        id: id,
        revision: revision,
        generation: vault.generation(),
      );
      return _content(value);
    }, mapToDomainError: _mapNativeError);
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.infrastructure,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<AccountV1> accountV1({
    required VaultHandleV1 handle,
    required String id,
  }) async {
    const op = 'RustVaultAccessService.accountV1():';
    final result = await captureResult<AccountV1>(() async {
      final vault = (handle as _NativeVaultHandle)._vault;
      final value = await vault.accountV1(
        id: id,
        generation: vault.generation(),
      );
      return AccountV1(
        id: value.id,
        name: value.name,
        description: value.description,
        login: value.login,
        password: value.password,
        groupIds: value.groupIds,
      );
    }, mapToDomainError: _mapNativeError);
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.infrastructure,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<ContentSnapshotV1> saveAccountV1({
    required VaultHandleV1 handle,
    required AccountDraftV1 input,
    required BigInt revision,
  }) async {
    const op = 'RustVaultAccessService.saveAccountV1():';
    final result = await captureResult<ContentSnapshotV1>(() async {
      final vault = (handle as _NativeVaultHandle)._vault;
      final value = await vault.saveAccountV1(
        input: native.AccountInputV1(
          id: input.id,
          name: input.name,
          description: input.description,
          login: input.login,
          password: input.password,
          groupIds: List.unmodifiable(input.groupIds),
        ),
        revision: revision,
        generation: vault.generation(),
      );
      return _content(value);
    }, mapToDomainError: _mapNativeError);
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.infrastructure,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  @override
  FutureDomainResult<ContentSnapshotV1> deleteAccountV1({
    required VaultHandleV1 handle,
    required String id,
    required BigInt revision,
  }) async {
    const op = 'RustVaultAccessService.deleteAccountV1():';
    final result = await captureResult<ContentSnapshotV1>(() async {
      final vault = (handle as _NativeVaultHandle)._vault;
      final value = await vault.deleteAccountV1(
        id: id,
        revision: revision,
        generation: vault.generation(),
      );
      return _content(value);
    }, mapToDomainError: _mapNativeError);
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.infrastructure,
        operation: op,
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }
}

final class _NativeVaultHandle implements VaultHandleV1 {
  final native.Vault _vault;
  final VaultReporter _reporter;
  const _NativeVaultHandle(this._vault, this._reporter);
  @override
  void invalidateSync() {
    const op = '_NativeVaultHandle.invalidateSync():';
    if (_vault.isDisposed) return;
    try {
      _vault.lock();
    } on Object catch (error, stack) {
      final mapped = _mapNativeError(error, stack);
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.infrastructure,
        operation: op,
        error: mapped,
      );
      Error.throwWithStackTrace(mapped, stack);
    }
  }

  @override
  Future<void> close() async {
    const op = '_NativeVaultHandle.close():';
    if (_vault.isDisposed) return;
    try {
      await _vault.close();
    } on Object catch (error, stack) {
      final mapped = _mapNativeError(error, stack);
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.infrastructure,
        operation: op,
        error: mapped,
      );
      Error.throwWithStackTrace(mapped, stack);
    } finally {
      _vault.dispose();
    }
  }

  @override
  String toString() => 'VaultHandleV1(<opaque>)';
}

VaultErrorV1 _mapNativeError(Object error, StackTrace stack) => switch (error) {
  native.VaultFailure.credentials => const VaultRejectedErrorV1(
    VaultFailureKindV1.credentials,
  ),
  native.VaultFailure.invalidPassword => const VaultRejectedErrorV1(
    VaultFailureKindV1.invalidPassword,
  ),
  native.VaultFailure.invalidPhrase => const VaultRejectedErrorV1(
    VaultFailureKindV1.invalidPhrase,
  ),
  native.VaultFailure.confirmation => const VaultRejectedErrorV1(
    VaultFailureKindV1.confirmation,
  ),
  native.VaultFailure.exists => const VaultRejectedErrorV1(
    VaultFailureKindV1.exists,
  ),
  native.VaultFailure.missing => const VaultRejectedErrorV1(
    VaultFailureKindV1.missing,
  ),
  native.VaultFailure.locked => const VaultRejectedErrorV1(
    VaultFailureKindV1.locked,
  ),
  native.VaultFailure.busy => const VaultRejectedErrorV1(
    VaultFailureKindV1.busy,
  ),
  native.VaultFailure.unsupported => const VaultRejectedErrorV1(
    VaultFailureKindV1.unsupported,
  ),
  native.VaultFailure.corrupt => const VaultRejectedErrorV1(
    VaultFailureKindV1.corrupt,
  ),
  native.VaultFailure.storage => const VaultRejectedErrorV1(
    VaultFailureKindV1.storage,
  ),
  native.VaultFailure.stale => const VaultRejectedErrorV1(
    VaultFailureKindV1.stale,
  ),
  native.VaultFailure.closed => const VaultRejectedErrorV1(
    VaultFailureKindV1.closed,
  ),
  native.VaultFailure.unavailable => const VaultRejectedErrorV1(
    VaultFailureKindV1.unavailable,
  ),
  native.VaultFailure.writeUncertain => const VaultRejectedErrorV1(
    VaultFailureKindV1.writeUncertain,
  ),
  _ => const VaultUnexpectedErrorV1(),
};

ContentSnapshotV1 _content(native.ContentSnapshotV1 value) => ContentSnapshotV1(
  revision: value.revision,
  groups: value.groups
      .map(
        (g) => GroupV1(
          id: g.id,
          name: g.name,
          description: g.description,
          icon: g.icon,
          logo: g.logo,
        ),
      )
      .toList(),
  accounts: value.accounts
      .map(
        (a) => AccountSummaryV1(id: a.id, name: a.name, groupIds: a.groupIds),
      )
      .toList(),
);
