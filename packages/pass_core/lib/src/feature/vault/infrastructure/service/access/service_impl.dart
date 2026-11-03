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

  @override
  FutureDomainResult<CardCatalogV1> cardCatalogV1() async {
    const op = 'RustVaultAccessService.cardCatalogV1():';
    final result = await captureResult<CardCatalogV1>(() async {
      return CardCatalogV1(
        services: await native.servicesV1(),
        presets: (await native.cardPresetsV1())
            .map(
              (p) => CardPresetV1(
                cardType: _cardType(p.cardType),
                fields: p.fields
                    .map(
                      (f) => FieldSpecV1(
                        id: _fieldId(f.id),
                        required: f.required_,
                        concealed: f.concealed,
                        multiline: f.multiline,
                        maxBytes: f.maxBytes,
                      ),
                    )
                    .toList(),
              ),
            )
            .toList(),
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
  FutureDomainResult<ContentSnapshotV2> contentV2({
    required VaultHandleV1 handle,
  }) async {
    const op = 'RustVaultAccessService.contentV2():';
    final result = await captureResult<ContentSnapshotV2>(() async {
      final vault = (handle as _NativeVaultHandle)._vault;
      return _cards(await vault.contentV2(generation: vault.generation()));
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
  FutureDomainResult<ContentSnapshotV2> saveGroupV2({
    required VaultHandleV1 handle,
    required GroupDraftV1 input,
    required BigInt revision,
  }) async {
    const op = 'RustVaultAccessService.saveGroupV2():';
    final result = await captureResult<ContentSnapshotV2>(() async {
      final vault = (handle as _NativeVaultHandle)._vault;
      return _cards(
        await vault.saveGroupV2(
          input: native.GroupInputV1(
            id: input.id,
            name: input.name,
            description: input.description,
            icon: input.icon,
            logo: Uint8List.fromList(input.logo),
          ),
          revision: revision,
          generation: vault.generation(),
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
  FutureDomainResult<ContentSnapshotV2> deleteGroupV2({
    required VaultHandleV1 handle,
    required String id,
    required BigInt revision,
  }) async {
    const op = 'RustVaultAccessService.deleteGroupV2():';
    final result = await captureResult<ContentSnapshotV2>(() async {
      final vault = (handle as _NativeVaultHandle)._vault;
      return _cards(
        await vault.deleteGroupV2(
          id: id,
          revision: revision,
          generation: vault.generation(),
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
  FutureDomainResult<CardMatchesV1> searchCardsV1({
    required VaultHandleV1 handle,
    required CardSearchV1 query,
    required BigInt revision,
  }) async {
    const op = 'RustVaultAccessService.searchCardsV1():';
    final result = await captureResult<CardMatchesV1>(() async {
      final vault = (handle as _NativeVaultHandle)._vault;
      final value = await vault.searchCardsV1(
        query: native.CardSearchV1(
          text: query.text,
          cardType: query.cardType == null
              ? null
              : _nativeCardType(query.cardType!),
          service: query.service,
          environment: query.environment == null
              ? null
              : _nativeEnvironment(query.environment!),
          withoutEnvironment: query.withoutEnvironment,
        ),
        revision: revision,
        generation: vault.generation(),
      );
      return CardMatchesV1(
        revision: value.revision,
        cardIds: List.unmodifiable(value.cardIds),
        groupIds: List.unmodifiable(value.groupIds),
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
  FutureDomainResult<List<CardListRowV1>> cardListRowsV1({
    required VaultHandleV1 handle,
    required List<String> ids,
    required BigInt revision,
  }) async {
    const op = 'RustVaultAccessService.cardListRowsV1():';
    final result = await captureResult<List<CardListRowV1>>(() async {
      final vault = (handle as _NativeVaultHandle)._vault;
      final rows = await vault.cardListRowsV1(
        ids: ids,
        revision: revision,
        generation: vault.generation(),
      );
      return List.unmodifiable(
        rows.map((row) => CardListRowV1(id: row.id, login: row.login)),
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
  FutureDomainResult<List<CardRowV1>> cardRowsV1({
    required VaultHandleV1 handle,
    required List<String> ids,
    required BigInt revision,
  }) async {
    const op = 'RustVaultAccessService.cardRowsV1():';
    final result = await captureResult<List<CardRowV1>>(() async {
      final vault = (handle as _NativeVaultHandle)._vault;
      final values = await vault.cardRowsV1(
        ids: ids,
        revision: revision,
        generation: vault.generation(),
      );
      return List.unmodifiable(
        values.map(
          (v) => CardRowV1(
            id: v.id,
            fields: List.unmodifiable(v.fields.map(_fieldId)),
            login: v.login,
            otp: v.otp == null
                ? null
                : TotpCodeV1(
                    code: v.otp!.code,
                    validUntil: DateTime.fromMillisecondsSinceEpoch(
                      v.otp!.validUntil.toInt() * 1000,
                      isUtc: true,
                    ),
                    period: Duration(seconds: v.otp!.period.toInt()),
                  ),
            attachment: v.attachment == null
                ? null
                : AttachmentV1(
                    name: v.attachment!.name,
                    size: v.attachment!.size,
                  ),
          ),
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
  FutureDomainResult<CardPreviewV1> cardPreviewV1({
    required VaultHandleV1 handle,
    required String id,
    required BigInt revision,
  }) async {
    const op = 'RustVaultAccessService.cardPreviewV1():';
    final result = await captureResult<CardPreviewV1>(() async {
      final vault = (handle as _NativeVaultHandle)._vault;
      final v = await vault.cardPreviewV1(
        id: id,
        revision: revision,
        generation: vault.generation(),
      );
      return CardPreviewV1(
        row: CardRowV1(
          id: v.row.id,
          fields: List.unmodifiable(v.row.fields.map(_fieldId)),
          login: v.row.login,
          otp: v.row.otp == null
              ? null
              : TotpCodeV1(
                  code: v.row.otp!.code,
                  validUntil: DateTime.fromMillisecondsSinceEpoch(
                    v.row.otp!.validUntil.toInt() * 1000,
                    isUtc: true,
                  ),
                  period: Duration(seconds: v.row.otp!.period.toInt()),
                ),
          attachment: v.row.attachment == null
              ? null
              : AttachmentV1(
                  name: v.row.attachment!.name,
                  size: v.row.attachment!.size,
                ),
        ),
        description: v.description,
        protectedContainer: v.protectedContainer,
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
  FutureDomainResult<CardV1> cardV1({
    required VaultHandleV1 handle,
    required String id,
  }) async {
    const op = 'RustVaultAccessService.cardV1():';
    final result = await captureResult<CardV1>(() async {
      final vault = (handle as _NativeVaultHandle)._vault;
      final value = await vault.cardV1(id: id, generation: vault.generation());
      return CardV1(
        summary: _cardSummary(value.summary),
        description: value.description,
        fields: value.fields
            .map((f) => CardValueV1(id: _fieldId(f.id), value: f.value))
            .toList(),
        attachment: value.attachment == null
            ? null
            : AttachmentV1(
                name: value.attachment!.name,
                size: value.attachment!.size,
              ),
        protectedContainer: value.protectedContainer,
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
  FutureDomainResult<ContentSnapshotV2> saveCardV1({
    required VaultHandleV1 handle,
    required CardDraftV1 input,
    required BigInt revision,
  }) async {
    const op = 'RustVaultAccessService.saveCardV1():';
    final result = await captureResult<ContentSnapshotV2>(() async {
      final vault = (handle as _NativeVaultHandle)._vault;
      return _cards(
        await vault.saveCardV1(
          input: native.CardInputV1(
            id: input.id,
            name: input.name,
            description: input.description,
            service: input.service,
            cardType: _nativeCardType(input.cardType),
            environment: input.environment == null
                ? null
                : _nativeEnvironment(input.environment!),
            groupIds: List.of(input.groupIds),
            fields: input.fields
                .map(
                  (f) => native.CardValueV1(
                    id: _nativeFieldId(f.id),
                    value: f.value,
                  ),
                )
                .toList(),
            attachment: input.attachment == null
                ? null
                : native.AttachmentInputV1(
                    name: input.attachment!.name,
                    bytes: Uint8List.fromList(input.attachment!.bytes),
                  ),
          ),
          revision: revision,
          generation: vault.generation(),
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
  FutureDomainResult<ContentSnapshotV2> deleteCardV1({
    required VaultHandleV1 handle,
    required String id,
    required BigInt revision,
  }) async {
    const op = 'RustVaultAccessService.deleteCardV1():';
    final result = await captureResult<ContentSnapshotV2>(() async {
      final vault = (handle as _NativeVaultHandle)._vault;
      return _cards(
        await vault.deleteCardV1(
          id: id,
          revision: revision,
          generation: vault.generation(),
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
  FutureDomainResult<TotpCodeV1> currentTotpV1({
    required VaultHandleV1 handle,
    required String id,
  }) async {
    const op = 'RustVaultAccessService.currentTotpV1():';
    final result = await captureResult<TotpCodeV1>(() async {
      final vault = (handle as _NativeVaultHandle)._vault;
      final value = await vault.currentTotpV1(
        id: id,
        generation: vault.generation(),
      );
      return TotpCodeV1(
        code: value.code,
        validUntil: DateTime.fromMillisecondsSinceEpoch(
          value.validUntil.toInt() * 1000,
          isUtc: true,
        ),
        period: Duration(seconds: value.period.toInt()),
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
  FutureDomainResult<String> copyCardFieldV1({
    required VaultHandleV1 handle,
    required String id,
    required FieldIdV1 field,
  }) async {
    const op = 'RustVaultAccessService.copyCardFieldV1():';
    final result = await captureResult<String>(() async {
      final vault = (handle as _NativeVaultHandle)._vault;
      return vault.copyCardFieldV1(
        id: id,
        field: _nativeFieldId(field),
        generation: vault.generation(),
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
  FutureDomainResult<String> copyAccountV1({
    required VaultHandleV1 handle,
    required String id,
  }) async {
    const op = 'RustVaultAccessService.copyAccountV1():';
    final result = await captureResult<String>(() async {
      final vault = (handle as _NativeVaultHandle)._vault;
      return vault.copyAccountV1(id: id, generation: vault.generation());
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
  FutureDomainResult<void> exportAttachmentV1({
    required VaultHandleV1 handle,
    required String id,
    required String destination,
    required BigInt revision,
  }) async {
    const op = 'RustVaultAccessService.exportAttachmentV1():';
    final result = await captureResult<void>(() async {
      final vault = (handle as _NativeVaultHandle)._vault;
      await vault.exportAttachmentV1(
        id: id,
        destination: destination,
        revision: revision,
        generation: vault.generation(),
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

ContentSnapshotV2 _cards(native.ContentSnapshotV2 value) => ContentSnapshotV2(
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
  cards: value.cards.map(_cardSummary).toList(),
);
CardSummaryV1 _cardSummary(native.CardSummaryV1 value) => CardSummaryV1(
  id: value.id,
  name: value.name,
  service: value.service,
  environment: value.environment == null
      ? null
      : _environment(value.environment!),
  groupIds: value.groupIds,
  cardType: _cardType(value.cardType),
  templateVersion: value.templateVersion,
);
CardTypeV1 _cardType(native.CardTypeV1 value) => switch (value) {
  native.CardTypeV1.account => CardTypeV1.account,
  native.CardTypeV1.pat => CardTypeV1.pat,
  native.CardTypeV1.rsa => CardTypeV1.rsa,
  native.CardTypeV1.ed25519 => CardTypeV1.ed25519,
  native.CardTypeV1.secretKey => CardTypeV1.secretKey,
  native.CardTypeV1.passphrase => CardTypeV1.passphrase,
  native.CardTypeV1.recoveryCodes => CardTypeV1.recoveryCodes,
  native.CardTypeV1.recoveryUrl => CardTypeV1.recoveryUrl,
  native.CardTypeV1.secretQa => CardTypeV1.secretQa,
  native.CardTypeV1.vless => CardTypeV1.vless,
  native.CardTypeV1.wireGuard => CardTypeV1.wireGuard,
  native.CardTypeV1.gpg => CardTypeV1.gpg,
  native.CardTypeV1.certificate => CardTypeV1.certificate,
  native.CardTypeV1.oAuth => CardTypeV1.oauth,
  native.CardTypeV1.dsn => CardTypeV1.dsn,
  native.CardTypeV1.kubeconfig => CardTypeV1.kubeconfig,
  native.CardTypeV1.webhookSecret => CardTypeV1.webhookSecret,
  native.CardTypeV1.secureNote => CardTypeV1.secureNote,
  native.CardTypeV1.file => CardTypeV1.file,
};
native.CardTypeV1 _nativeCardType(CardTypeV1 value) => switch (value) {
  CardTypeV1.account => native.CardTypeV1.account,
  CardTypeV1.pat => native.CardTypeV1.pat,
  CardTypeV1.rsa => native.CardTypeV1.rsa,
  CardTypeV1.ed25519 => native.CardTypeV1.ed25519,
  CardTypeV1.secretKey => native.CardTypeV1.secretKey,
  CardTypeV1.passphrase => native.CardTypeV1.passphrase,
  CardTypeV1.recoveryCodes => native.CardTypeV1.recoveryCodes,
  CardTypeV1.recoveryUrl => native.CardTypeV1.recoveryUrl,
  CardTypeV1.secretQa => native.CardTypeV1.secretQa,
  CardTypeV1.vless => native.CardTypeV1.vless,
  CardTypeV1.wireGuard => native.CardTypeV1.wireGuard,
  CardTypeV1.gpg => native.CardTypeV1.gpg,
  CardTypeV1.certificate => native.CardTypeV1.certificate,
  CardTypeV1.oauth => native.CardTypeV1.oAuth,
  CardTypeV1.dsn => native.CardTypeV1.dsn,
  CardTypeV1.kubeconfig => native.CardTypeV1.kubeconfig,
  CardTypeV1.webhookSecret => native.CardTypeV1.webhookSecret,
  CardTypeV1.secureNote => native.CardTypeV1.secureNote,
  CardTypeV1.file => native.CardTypeV1.file,
};
EnvironmentV1 _environment(native.EnvironmentV1 value) => switch (value) {
  native.EnvironmentV1.local => EnvironmentV1.local,
  native.EnvironmentV1.unitTests => EnvironmentV1.unitTests,
  native.EnvironmentV1.integrationTests => EnvironmentV1.integrationTests,
  native.EnvironmentV1.e2ETests => EnvironmentV1.e2eTests,
  native.EnvironmentV1.development => EnvironmentV1.development,
  native.EnvironmentV1.stand => EnvironmentV1.stand,
  native.EnvironmentV1.feature => EnvironmentV1.feature,
  native.EnvironmentV1.stage => EnvironmentV1.stage,
  native.EnvironmentV1.preRelease => EnvironmentV1.preRelease,
  native.EnvironmentV1.production => EnvironmentV1.production,
};
native.EnvironmentV1 _nativeEnvironment(EnvironmentV1 value) => switch (value) {
  EnvironmentV1.local => native.EnvironmentV1.local,
  EnvironmentV1.unitTests => native.EnvironmentV1.unitTests,
  EnvironmentV1.integrationTests => native.EnvironmentV1.integrationTests,
  EnvironmentV1.e2eTests => native.EnvironmentV1.e2ETests,
  EnvironmentV1.development => native.EnvironmentV1.development,
  EnvironmentV1.stand => native.EnvironmentV1.stand,
  EnvironmentV1.feature => native.EnvironmentV1.feature,
  EnvironmentV1.stage => native.EnvironmentV1.stage,
  EnvironmentV1.preRelease => native.EnvironmentV1.preRelease,
  EnvironmentV1.production => native.EnvironmentV1.production,
};
FieldIdV1 _fieldId(native.FieldIdV1 value) => switch (value) {
  native.FieldIdV1.login => FieldIdV1.login,
  native.FieldIdV1.password => FieldIdV1.password,
  native.FieldIdV1.totpSeed => FieldIdV1.totpSeed,
  native.FieldIdV1.totpAlgorithm => FieldIdV1.totpAlgorithm,
  native.FieldIdV1.totpDigits => FieldIdV1.totpDigits,
  native.FieldIdV1.totpPeriod => FieldIdV1.totpPeriod,
  native.FieldIdV1.recoveryCodes => FieldIdV1.recoveryCodes,
  native.FieldIdV1.reserveLogins => FieldIdV1.reserveLogins,
  native.FieldIdV1.value => FieldIdV1.value,
  native.FieldIdV1.publicKey => FieldIdV1.publicKey,
  native.FieldIdV1.privateKey => FieldIdV1.privateKey,
  native.FieldIdV1.certificate => FieldIdV1.certificate,
  native.FieldIdV1.clientId => FieldIdV1.clientId,
  native.FieldIdV1.clientSecret => FieldIdV1.clientSecret,
  native.FieldIdV1.accessToken => FieldIdV1.accessToken,
  native.FieldIdV1.refreshToken => FieldIdV1.refreshToken,
  native.FieldIdV1.question => FieldIdV1.question,
  native.FieldIdV1.answer => FieldIdV1.answer,
};
native.FieldIdV1 _nativeFieldId(FieldIdV1 value) => switch (value) {
  FieldIdV1.login => native.FieldIdV1.login,
  FieldIdV1.password => native.FieldIdV1.password,
  FieldIdV1.totpSeed => native.FieldIdV1.totpSeed,
  FieldIdV1.totpAlgorithm => native.FieldIdV1.totpAlgorithm,
  FieldIdV1.totpDigits => native.FieldIdV1.totpDigits,
  FieldIdV1.totpPeriod => native.FieldIdV1.totpPeriod,
  FieldIdV1.recoveryCodes => native.FieldIdV1.recoveryCodes,
  FieldIdV1.reserveLogins => native.FieldIdV1.reserveLogins,
  FieldIdV1.value => native.FieldIdV1.value,
  FieldIdV1.publicKey => native.FieldIdV1.publicKey,
  FieldIdV1.privateKey => native.FieldIdV1.privateKey,
  FieldIdV1.certificate => native.FieldIdV1.certificate,
  FieldIdV1.clientId => native.FieldIdV1.clientId,
  FieldIdV1.clientSecret => native.FieldIdV1.clientSecret,
  FieldIdV1.accessToken => native.FieldIdV1.accessToken,
  FieldIdV1.refreshToken => native.FieldIdV1.refreshToken,
  FieldIdV1.question => native.FieldIdV1.question,
  FieldIdV1.answer => native.FieldIdV1.answer,
};
