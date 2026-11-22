import 'dart:async';
import 'dart:convert';

import 'package:domain_error/domain_error.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_effects/bloc_effects.dart';
import 'package:injectable/injectable.dart';
import 'package:launch_mode/launch_mode.dart';
import 'package:want_pass/src/feature/vault/application/_barrel.dart';
import 'package:want_pass_core/want_pass_core.dart';

part 'state.dart';
part 'effect.dart';

@singleton
final class VaultController extends CubitWithEffects<VaultState, VaultEffect> {
  final VaultUseCase _useCase;
  final VaultReporter _reporter;
  final Stream<VaultLockSignal> _lockEvents;
  VaultHandleV1? _handle;
  StreamSubscription<VaultLockSignal>? _subscription;
  Timer? _idle;
  final Stopwatch _idleClock;
  Duration get idleRemaining => Duration(
    microseconds:
        (const Duration(minutes: 5).inMicroseconds -
                _idleClock.elapsedMicroseconds)
            .clamp(0, const Duration(minutes: 5).inMicroseconds),
  );
  Timer? _clipboardExpiry;
  String? _clipboardContent;
  Future<void>? _exportOperation;
  Future<void>? _clipboardCleanup;
  Completer<void>? _fileSelectionCancelled;
  Future<void>? _initFuture;
  Future<void>? _closeFuture;
  Future<void>? _operation;
  Future<bool>? _resetOperation;
  Future<void>? _totpOperation;
  bool _closing = false;
  bool _monitorAvailable = true;
  final _browseOperations = <Future<void>>{};
  int _searchEpoch = 0;
  int _epoch = 0;
  int _passwordEpoch = 0;
  final _passwordOperations = <Future<bool>>{};

  VaultController(
    this._useCase,
    this._reporter,
    @Named('vaultLockEvents') this._lockEvents, {
    @ignoreParam Stopwatch? idleClock,
  }) : _idleClock = idleClock ?? Stopwatch(),
       super(const VaultState(phase: VaultPhase.loading));

  @PostConstruct(preResolve: true)
  Future<void> init() {
    const op = 'VaultController.init():';
    if (_closing || isClosed) return Future.value();
    return _initFuture ??= _initialize(op);
  }

  Future<void> _initialize(String operation) async {
    if (!LaunchMode.isInitialized || !LaunchMode.isForeground) {
      _fail(
        operation,
        const VaultRejectedErrorV1(VaultFailureKindV1.unavailable),
        unavailable: true,
      );
      return;
    }
    final result = await _useCase.initializeV1(
      params: const InitializeVaultParamsV1(),
    );
    if (_closing) {
      if (result.isSuccess) await result.value.handle.close();
      return;
    }
    if (result.isError) {
      _fail(operation, _error(result.error), unavailable: true);
      return;
    }
    _handle = result.value.handle;
    _subscription = _lockEvents.listen(
      (_) => unawaited(lock()),
      onError: (Object _, StackTrace _) => unawaited(_monitorLost()),
      onDone: () => unawaited(_monitorLost()),
    );
    if (_monitorAvailable) {
      emit(VaultState(phase: _phase(result.value.state)));
    }
  }

  Future<void> prepareCreation({
    required String password,
    required String confirmation,
  }) {
    const op = 'VaultController.prepareCreation():';
    return _perform(
      op,
      (handle) => _useCase.prepareCreationV1(
        params: PrepareVaultCreationParamsV1(
          handle: handle,
          password: password,
          confirmation: confirmation,
        ),
      ),
      (value) => emit(
        VaultState(phase: VaultPhase.confirmation, challenge: value.challenge),
      ),
    );
  }

  Future<void> prepareRecovery({
    required String phrase,
    required String password,
    required String confirmation,
  }) {
    const op = 'VaultController.prepareRecovery():';
    return _perform(
      op,
      (handle) => _useCase.prepareRecoveryV1(
        params: PrepareVaultRecoveryParamsV1(
          handle: handle,
          phrase: phrase,
          password: password,
          confirmation: confirmation,
        ),
      ),
      (value) => emit(
        VaultState(
          phase: VaultPhase.confirmation,
          challenge: value.challenge,
          recovering: true,
        ),
      ),
    );
  }

  Future<void> confirm(List<String> answers) {
    const op = 'VaultController.confirm():';
    if (state.recovering) {
      return _perform(
        op,
        (handle) => _useCase.confirmRecoveryV1(
          params: ConfirmVaultRecoveryParamsV1(
            handle: handle,
            answers: List.unmodifiable(answers),
          ),
        ),
        (value) => emit(VaultState(phase: _phase(value.state))),
      );
    }
    return _perform(
      op,
      (handle) => _useCase.confirmCreationV1(
        params: ConfirmVaultCreationParamsV1(
          handle: handle,
          answers: List.unmodifiable(answers),
        ),
      ),
      (value) => emit(VaultState(phase: _phase(value.state))),
    );
  }

  Future<void> prepareSetup({
    required String password,
    required String confirmation,
    String? phrase,
  }) {
    const op = 'VaultController.prepareSetup():';
    return _perform(
      op,
      (handle) => _useCase.prepareSetupV3(
        params: PrepareVaultSetupParamsV3(
          handle: handle,
          password: password,
          confirmation: confirmation,
          phrase: phrase,
        ),
      ),
      (value) => emit(
        VaultState(
          phase: VaultPhase.confirmation,
          setupChallenge: value.challenge,
          hints: state.hints,
          recovering: phrase != null,
          passwordSaved: state.passwordSaved,
          phraseSaved:
              state.setupChallenge == value.challenge && state.phraseSaved,
          lossAccepted:
              state.setupChallenge == value.challenge && state.lossAccepted,
          setupAnswers: state.setupChallenge == value.challenge
              ? state.setupAnswers
              : const [null, null, null],
          recoveryExportCompleted:
              state.setupChallenge == value.challenge &&
              state.recoveryExportCompleted,
        ),
      ),
    );
  }

  Future<void> confirmSetup({
    required List<String> answers,
    required String password,
    required VaultHintsDtoV2 hints,
  }) {
    const op = 'VaultController.confirmSetup():';
    if (!state.passwordSaved ||
        !state.phraseSaved ||
        !state.lossAccepted ||
        !state.recoveryExportCompleted ||
        _exportOperation != null ||
        !state.setupAnswers.every((v) => v != null) ||
        answers.length != state.setupAnswers.length ||
        Iterable<int>.generate(answers.length)
            .any((i) => answers[i] != state.setupAnswers[i]) ||
        state.setupChallenge == null) {
      return Future.value();
    }
    return _perform(
      op,
      (handle) => _useCase.confirmSetupV3(
        params: ConfirmVaultSetupParamsV3(
          handle: handle,
          answers: List.unmodifiable(answers),
          revision: state.setupChallenge!.revision,
          passwordSaved: state.passwordSaved,
          phraseSaved: state.phraseSaved,
          lossAccepted: state.lossAccepted,
          password: password,
          hints: hints,
        ),
      ),
      (value) {
        emit(VaultState(phase: _phase(value.state), hints: hints));
        if (state.phase == VaultPhase.unlocked) {
          emitEffect(const VaultSetupCompletedV1());
        }
      },
      handleFailure: (error) {
        if (error is! VaultRejectedErrorV1 ||
            error.kind != VaultFailureKindV1.confirmation) {
          return false;
        }
        emit(
          state.copyWith(
            busy: false,
            recoveryExportCompleted: false,
            phraseSaved: false,
            lossAccepted: false,
            setupAnswers: const [null, null, null],
          ),
        );
        emitEffect(const VaultRecoveryReset());
        return true;
      },
    );
  }

  Future<void> readHints() {
    const op = 'VaultController.readHints():';
    return _perform(
      op,
      (handle) =>
          _useCase.readHintsV2(params: ReadVaultHintsParamsV2(handle: handle)),
      (value) => emit(state.copyWith(busy: false, hints: value.hints)),
      preserveError: true,
    );
  }

  void dismissFailure() {
    const op = 'VaultController.dismissFailure():';
    if (_closing || isClosed || state.busy || state.error == null) return;
    if (!LaunchMode.isInitialized || !LaunchMode.isForeground) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.controller,
        operation: op,
        error: const VaultRejectedErrorV1(VaultFailureKindV1.unavailable),
      );
      return;
    }
    emit(state.copyWith(error: () => null));
  }

  void acknowledge({bool? password, bool? phrase, bool? loss}) {
    const op = 'VaultController.acknowledge():';
    if (_closing || isClosed || state.busy) return;
    if (!LaunchMode.isInitialized || !LaunchMode.isForeground) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.controller,
        operation: op,
        error: const VaultRejectedErrorV1(VaultFailureKindV1.unavailable),
      );
      return;
    }
    emit(
      state.copyWith(
        passwordSaved: password,
        phraseSaved: phrase,
        lossAccepted: loss,
      ),
    );
  }

  Future<bool> validateRecovery(String phrase) async {
    const op = 'VaultController.validateRecovery():';
    if (phrase.trim().isEmpty || state.busy) return false;
    var accepted = false;
    await _perform(
      op,
      (handle) => _useCase.validateRecoveryV3(
        params: ValidateVaultRecoveryParamsV3(handle: handle, phrase: phrase),
      ),
      (_) {
        accepted = true;
        emit(state.copyWith(busy: false));
      },
    );
    return accepted;
  }

  void chooseSetupWord(int index, String word) {
    final challenge = state.setupChallenge;
    if (_closing ||
        isClosed ||
        state.busy ||
        !LaunchMode.isInitialized ||
        !LaunchMode.isForeground ||
        state.phase != VaultPhase.confirmation ||
        state.error is VaultRejectedErrorV1 &&
            (state.error as VaultRejectedErrorV1).kind ==
                VaultFailureKindV1.writeUncertain ||
        challenge == null ||
        index < 0 ||
        index >= challenge.choices.length ||
        !challenge.choices[index].contains(word)) {
      return;
    }
    final answers = [...state.setupAnswers]..[index] = word;
    emit(
      state.copyWith(
        setupAnswers: List.unmodifiable(answers),
        error: () => null,
      ),
    );
    activity();
  }

  void confirmRecoveryQr(BigInt revision) {
    if (_closing ||
        isClosed ||
        state.busy ||
        !LaunchMode.isInitialized ||
        !LaunchMode.isForeground ||
        state.phase != VaultPhase.confirmation ||
        state.setupChallenge?.revision != revision) {
      return;
    }
    emit(state.copyWith(recoveryExportCompleted: true, phraseSaved: true));
  }

  Future<void> downloadRecovery() {
    const op = 'VaultController.downloadRecovery():';
    if (!_withinIdleDeadline ||
        _closing ||
        state.busy ||
        state.setupChallenge == null ||
        _exportOperation != null ||
        _handle == null) {
      return Future.value();
    }
    final epoch = _epoch;
    final cancelled = Completer<void>();
    _fileSelectionCancelled = cancelled;
    final operation = () async {
      final selected =
          await Future.any<DomainResult<SelectRecoveryFileResultV1>?>([
            _useCase.selectRecoveryFileV3(
              params: const SelectRecoveryFileParamsV3(),
            ),
            cancelled.future.then((_) => null),
          ]);
      if (selected == null ||
          _closing ||
          epoch != _epoch ||
          !_withinIdleDeadline) {
        return;
      }
      if (selected.isError) {
        _fail(op, _error(selected.error));
        return;
      }
      final destination = selected.value.destination;
      if (destination == null) return;
      emitEffect(const VaultNotice(VaultNoticeKind.exportStarted));
      final result = await _useCase.exportRecoveryV3(
        params: ExportRecoveryParamsV3(
          handle: _handle!,
          destination: destination,
          revision: state.setupChallenge!.revision,
        ),
      );
      if (!_closing && epoch == _epoch) {
        if (result.isError) {
          _fail(op, _error(result.error));
        } else {
          emit(state.copyWith(recoveryExportCompleted: true));
          emitEffect(const VaultNotice(VaultNoticeKind.exported));
        }
      }
    }();
    _exportOperation = operation;
    return operation.whenComplete(() {
      if (identical(_exportOperation, operation)) _exportOperation = null;
      if (identical(_fileSelectionCancelled, cancelled)) {
        _fileSelectionCancelled = null;
      }
    });
  }

  Future<void> copyRecovery() async {
    const op = 'VaultController.copyRecovery():';
    if (!_withinIdleDeadline ||
        _closing ||
        state.busy ||
        state.setupChallenge == null ||
        _exportOperation != null) {
      return;
    }
    final epoch = _epoch;
    final phrase = state.setupChallenge!.json;
    final operation = () async {
      await _clearClipboard();
      if (_closing || epoch != _epoch || !_withinIdleDeadline) return;
      final result = await _useCase.copyRecoveryV1(
        params: RecoveryClipboardParamsV1(phrase: phrase),
      );
      if (_closing || epoch != _epoch || !_withinIdleDeadline) {
        await _useCase.clearRecoveryClipboardV1(
          params: RecoveryClipboardParamsV1(phrase: phrase),
        );
        return;
      }
      if (result.isError) {
        _fail(op, _error(result.error));
        return;
      }
      _clipboardContent = phrase;
      emit(state.copyWith(recoveryExportCompleted: true));
      emitEffect(const VaultNotice(VaultNoticeKind.copied));
      _clipboardExpiry = Timer(
        const Duration(seconds: 60),
        () => unawaited(_clearClipboard()),
      );
    }();
    _exportOperation = operation;
    await operation;
    if (identical(_exportOperation, operation)) _exportOperation = null;
  }

  Future<bool> copyPasswordHint() async {
    const op = 'VaultController.copyPasswordHint():';
    final hint = state.hints.password;
    if (_closing ||
        isClosed ||
        !_monitorAvailable ||
        state.phase != VaultPhase.locked ||
        state.busy ||
        _exportOperation != null ||
        hint.trim().isEmpty ||
        !LaunchMode.isInitialized ||
        !LaunchMode.isForeground) {
      return false;
    }
    final epoch = _epoch;
    final operation = () async {
      await _clearClipboard();
      if (_closing || epoch != _epoch || state.phase != VaultPhase.locked) {
        return false;
      }
      final result = await _useCase.copyPasswordHintV1(hint: hint);
      if (result.isError) {
        reportVaultSafely(
          _reporter,
          layer: VaultDiagnosticLayer.controller,
          operation: op,
          error: _error(result.error),
        );
        return false;
      }
      _clipboardContent = hint;
      if (_closing || epoch != _epoch || state.phase != VaultPhase.locked) {
        await _clearClipboard();
        return false;
      }
      _clipboardExpiry = Timer(
        const Duration(seconds: 30),
        () => unawaited(_clearClipboard()),
      );
      return true;
    }();
    final pending = operation.then<void>((_) {});
    _exportOperation = pending;
    try {
      return await operation;
    } finally {
      if (identical(_exportOperation, pending)) _exportOperation = null;
    }
  }

  Future<void> _clearClipboard() async {
    const op = 'VaultController._clearClipboard():';
    _clipboardExpiry?.cancel();
    if (_clipboardCleanup case final pending?) {
      await pending;
      return;
    }
    final content = _clipboardContent;
    _clipboardContent = null;
    if (content == null) return;
    final operation = () async {
      final result = await _useCase.clearRecoveryClipboardV1(
        params: RecoveryClipboardParamsV1(phrase: content),
      );
      if (result.isError) {
        reportVaultSafely(
          _reporter,
          layer: VaultDiagnosticLayer.controller,
          operation: op,
          error: _error(result.error),
        );
      }
    }();
    _clipboardCleanup = operation;
    try {
      await operation;
    } finally {
      if (identical(_clipboardCleanup, operation)) _clipboardCleanup = null;
    }
  }

  Future<PasswordPolicyStatusV4?> checkSetupPassword(String password) {
    const op = 'VaultController.checkSetupPassword():';
    if (_closing ||
        isClosed ||
        !_monitorAvailable ||
        !LaunchMode.isInitialized ||
        !LaunchMode.isForeground ||
        state.phase == VaultPhase.loading ||
        state.phase == VaultPhase.unavailable ||
        state.phase == VaultPhase.unlocked) {
      return Future.value();
    }
    final epoch = _epoch;
    final settled = Completer<void>();
    _browseOperations.add(settled.future);
    return () async {
      try {
        final result = await _useCase.passwordPolicyV4(
          params: PasswordPolicyParamsV4(password: password),
        );
        if (_closing || isClosed || epoch != _epoch) return null;
        if (result.isError) {
          reportVaultSafely(
            _reporter,
            layer: VaultDiagnosticLayer.controller,
            operation: op,
            error: _error(result.error),
          );
          return null;
        }
        return result.value;
      } finally {
        settled.complete();
        _browseOperations.remove(settled.future);
      }
    }();
  }

  Future<bool> validatePassword(String password) {
    const op = 'VaultController.validatePassword():';
    final revision = ++_passwordEpoch;
    final epoch = _epoch;
    if (_closing || isClosed) return Future.value(false);
    if (password.isNotEmpty &&
        (!LaunchMode.isInitialized ||
            !LaunchMode.isForeground ||
            !_monitorAvailable)) {
      _fail(
        op,
        const VaultRejectedErrorV1(VaultFailureKindV1.unavailable),
        unavailable: true,
      );
      return Future.value(false);
    }
    final checking =
        password.isNotEmpty && state.phase == VaultPhase.locked && !state.busy;
    emit(state.copyWith(passwordValid: () => null, passwordChecking: checking));
    if (!checking) return Future.value(false);
    final operation = () async {
      try {
        final result = await _useCase.validatePasswordV3(
          params: ValidatePasswordParamsV3(password: password),
        );
        if (_closing ||
            epoch != _epoch ||
            revision != _passwordEpoch ||
            state.phase != VaultPhase.locked) {
          return false;
        }
        if (result.isError) {
          emit(state.copyWith(passwordChecking: false));
          _fail(op, _error(result.error));
          return false;
        }
        emit(
          state.copyWith(
            passwordValid: () => result.value.valid,
            passwordChecking: false,
          ),
        );
        return result.value.valid;
      } on Object {
        if (!_closing && epoch == _epoch && revision == _passwordEpoch) {
          emit(state.copyWith(passwordChecking: false));
          _fail(op, const VaultUnexpectedErrorV1());
        }
        return false;
      }
    }();
    _passwordOperations.add(operation);
    unawaited(
      operation.whenComplete(() => _passwordOperations.remove(operation)),
    );
    return operation;
  }

  Future<T?> _readProtection<T>(
    String name,
    FutureDomainResult<T> Function(VaultProtectionSessionV1 session) action,
  ) => _readCatalog(name, (handle, _) async {
    if (handle is! VaultProtectionSessionV1) {
      return Result.error(
        const VaultRejectedErrorV1(VaultFailureKindV1.unsupported),
      );
    }
    return action(handle as VaultProtectionSessionV1);
  });

  Future<ProtectionSettingsDtoV1?> readProtection() => _readProtection(
    'VaultController.readProtection():',
    (session) => session.protectionSettings(),
  );

  Future<String?> beginExternalFactor() => _readProtection(
    'VaultController.beginExternalFactor():',
    (session) => session.beginEnrollment(),
  );

  Future<bool> saveExternalFactor(
    String code,
    Set<ProtectedOperationV1> operations, {
    required bool enrolling,
    bool disable = false,
  }) async {
    var saved = false;
    if (!_hasUnlockedSession) return false;
    await _perform<void>(
      'VaultController.saveExternalFactor():',
      (handle) async {
        if (handle is! VaultProtectionSessionV1) {
          return Result.error(
            const VaultRejectedErrorV1(VaultFailureKindV1.unsupported),
          );
        }
        final session = handle as VaultProtectionSessionV1;
        return enrolling
            ? session.enroll(code, operations)
            : session.configureFactor(code, operations, disable: disable);
      },
      (_) {
        saved = true;
        emit(state.copyWith(busy: false));
      },
      contentMutation: true,
    );
    if (saved) await loadContent();
    return saved;
  }

  Future<({bool available, bool enabled})> biometricStatus() async {
    final handle = _handle, epoch = _epoch;
    if (_closing || isClosed || handle is! VaultProtectionSessionV1) {
      return (available: false, enabled: false);
    }
    final session = handle as VaultProtectionSessionV1;
    try {
      final available = await session.biometricAvailable();
      final enrolled = await session.biometricEnabled();
      if (_closing || epoch != _epoch) {
        return (available: false, enabled: false);
      }
      return (
        available: available,
        enabled: enrolled.isSuccess && enrolled.value,
      );
    } on Object {
      return (available: false, enabled: false);
    }
  }

  Future<bool> setBiometricEnabled(bool enable) async {
    if (!_hasUnlockedSession) return false;
    var saved = false;
    await _perform<void>(
      'VaultController.setBiometricEnabled():',
      (handle) async {
        if (handle is! VaultProtectionSessionV1) {
          return Result.error(
            const VaultRejectedErrorV1(VaultFailureKindV1.unsupported),
          );
        }
        return (handle as VaultProtectionSessionV1).configureBiometric(enable);
      },
      (_) {
        saved = true;
        emit(state.copyWith(busy: false));
      },
    );
    return saved;
  }

  Future<void> unlockWithBiometric() async {
    if (state.phase != VaultPhase.locked) return;
    await _perform<void>(
      'VaultController.unlockWithBiometric():',
      (handle) async {
        if (handle is! VaultProtectionSessionV1) {
          return Result.error(
            const VaultRejectedErrorV1(VaultFailureKindV1.unsupported),
          );
        }
        return (handle as VaultProtectionSessionV1).unlockBiometric();
      },
      (_) {
        emit(const VaultState(phase: VaultPhase.unlocked));
        emitEffect(const VaultNotice(VaultNoticeKind.unlocked));
      },
    );
  }

  Future<void> unlock(String password) {
    const op = 'VaultController.unlock():';
    _passwordEpoch++;
    return _perform(
      op,
      (handle) => _useCase.unlockV3(
        params: UnlockVaultParamsV3(handle: handle, password: password),
      ),
      (value) {
        emit(VaultState(phase: _phase(value.state)));
        if (state.phase == VaultPhase.unlocked) {
          emitEffect(const VaultNotice(VaultNoticeKind.unlocked));
        }
      },
    );
  }

  Future<void> _perform<T>(
    String operation,
    FutureDomainResult<T> Function(VaultHandleV1) run,
    void Function(T) success, {
    bool contentMutation = false,
    bool preserveError = false,
    bool Function(VaultErrorV1)? handleFailure,
  }) async {
    if (!_withinIdleDeadline ||
        _closing ||
        isClosed ||
        !_monitorAvailable ||
        state.busy ||
        _handle == null) {
      return;
    }
    if (!LaunchMode.isInitialized || !LaunchMode.isForeground) {
      _fail(
        operation,
        const VaultRejectedErrorV1(VaultFailureKindV1.unavailable),
        unavailable: true,
      );
      return;
    }
    final epoch = _epoch;
    emit(state.copyWith(busy: true, error: preserveError ? null : () => null));
    activity();
    final future = () async {
      try {
        final result = await run(_handle!);
        if (_closing || epoch != _epoch || !_withinIdleDeadline) return;
        if (result.isError) {
          final error = _error(result.error);
          if (handleFailure?.call(error) == true) return;
          if (contentMutation &&
              error is VaultRejectedErrorV1 &&
              (error.kind == VaultFailureKindV1.writeUncertain ||
                  error.kind == VaultFailureKindV1.stale)) {
            reportVaultSafely(
              _reporter,
              layer: VaultDiagnosticLayer.controller,
              operation: operation,
              error: error,
            );
            await lock(failure: error);
            return;
          }
          _fail(operation, error);
        } else {
          success(result.value);
          activity();
        }
      } on Object {
        if (!_closing && epoch == _epoch) {
          _fail(operation, const VaultUnexpectedErrorV1(), unavailable: true);
        }
      }
    }();
    _operation = future;
    await future;
    if (identical(_operation, future)) _operation = null;
    if (!_closing &&
        epoch == _epoch &&
        state.phase == VaultPhase.unlocked &&
        state.content == null &&
        state.error == null) {
      await loadContent();
    }
  }

  Future<bool> resetApplication(
    String phrase, {
    required void Function() onReset,
  }) async {
    const op = 'VaultController.resetApplication():';
    final handle = _handle;
    if (_closing ||
        !_monitorAvailable ||
        !_hasUnlockedSession ||
        state.busy ||
        handle == null ||
        !LaunchMode.isInitialized ||
        !LaunchMode.isForeground) {
      return false;
    }
    final epoch = _epoch;
    emit(state.copyWith(busy: true, error: () => null));
    activity();
    final operation = () async {
      try {
        final result = await _useCase.resetApplicationV1(
          params: ResetVaultApplicationParamsV1(handle: handle, phrase: phrase),
        );
        if (_closing) return false;
        if (result.isError) {
          if (epoch == _epoch) {
            final error = _error(result.error);
            _fail(
              op,
              error,
              unavailable:
                  error is VaultRejectedErrorV1 &&
                  error.kind == VaultFailureKindV1.writeUncertain,
            );
          }
          return false;
        }
        onReset();
        await _clearClipboard();
        if (!_closing && epoch == _epoch) {
          _epoch++;
          _idle?.cancel();
          _idleClock.stop();
          emit(const VaultState(phase: VaultPhase.missing));
        }
        return true;
      } on Object {
        if (!_closing && epoch == _epoch) {
          _fail(op, const VaultUnexpectedErrorV1(), unavailable: true);
        }
        return false;
      }
    }();
    _resetOperation = operation;
    try {
      return await operation;
    } finally {
      if (identical(_resetOperation, operation)) _resetOperation = null;
    }
  }

  Future<void> lock({bool notify = false, VaultErrorV1? failure}) async {
    const op = 'VaultController.lock():';
    if (_closing || isClosed || _handle == null) return;
    final epoch = ++_epoch;
    if (_fileSelectionCancelled?.isCompleted == false) {
      _fileSelectionCancelled!.complete();
    }
    unawaited(_clearClipboard());
    _idle?.cancel();
    _idleClock.stop();
    emit(const VaultState(phase: VaultPhase.loading, busy: true));
    try {
      final result = await _useCase.lockV1(
        params: LockVaultParamsV1(handle: _handle!),
      );
      await _resetOperation;
      await _exportOperation;
      await _clearClipboard();
      if (_closing || epoch != _epoch) return;
      if (result.isError) {
        _fail(op, _error(result.error), unavailable: true);
      } else {
        emit(
          VaultState(
            phase: _monitorAvailable
                ? _phase(result.value.state)
                : VaultPhase.unavailable,
            error: _monitorAvailable
                ? failure
                : const VaultRejectedErrorV1(VaultFailureKindV1.unavailable),
          ),
        );
      }
      if (notify && !_closing && epoch == _epoch && state.error == null) {
        emitEffect(const VaultNotice(VaultNoticeKind.locked));
      }
    } on Object {
      if (!_closing && epoch == _epoch) {
        _fail(op, const VaultUnexpectedErrorV1(), unavailable: true);
      }
    }
  }

  bool get _withinIdleDeadline {
    if (!_idleClock.isRunning || idleRemaining > Duration.zero) return true;
    unawaited(lock());
    return false;
  }

  bool get _hasUnlockedSession =>
      state.phase == VaultPhase.unlocked && _withinIdleDeadline;

  void activity() {
    const op = 'VaultController.activity():';
    if (_closing || isClosed || !_withinIdleDeadline) return;
    if (!LaunchMode.isInitialized || !LaunchMode.isForeground) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.controller,
        operation: op,
        error: const VaultRejectedErrorV1(VaultFailureKindV1.unavailable),
      );
      return;
    }
    _idle?.cancel();
    if (state.phase == VaultPhase.unlocked ||
        state.phase == VaultPhase.confirmation ||
        state.busy) {
      _idleClock
        ..reset()
        ..start();
      _idle = Timer(const Duration(minutes: 5), () => unawaited(lock()));
    }
  }

  Future<void> _monitorLost() async {
    const op = 'VaultController._monitorLost():';
    if (_closing || isClosed || !_monitorAvailable) return;
    _monitorAvailable = false;
    await lock();
    if (!_closing) {
      _fail(
        op,
        const VaultRejectedErrorV1(VaultFailureKindV1.unavailable),
        unavailable: true,
      );
    }
  }

  void _fail(
    String operation,
    VaultErrorV1 error, {
    bool unavailable = false,
    bool clearBusy = true,
  }) {
    reportVaultSafely(
      _reporter,
      layer: VaultDiagnosticLayer.controller,
      operation: operation,
      error: error,
    );
    if (!_closing && !isClosed) {
      emit(
        unavailable
            ? VaultState(phase: VaultPhase.unavailable, error: error)
            : state.copyWith(
                busy: clearBusy ? false : state.busy,
                error: () => error,
              ),
      );
    }
  }

  Future<AccountImportPreviewV1?> prepareAccountImport(
    AccountImportSourceV1 source, {
    required bool clipboard,
  }) async {
    const op = 'VaultController.prepareAccountImport():';
    final revision = state.content?.revision;
    final epoch = _epoch;
    if (_closing ||
        !_hasUnlockedSession ||
        state.busy ||
        revision == null ||
        _handle == null) {
      return null;
    }
    if (state.error != null) emit(state.copyWith(error: () => null));
    final input = await _useCase.selectAccountImportV1(
      source: source,
      clipboard: clipboard,
    );
    if (_closing ||
        isClosed ||
        _epoch != epoch ||
        !_hasUnlockedSession ||
        state.content?.revision != revision) {
      return null;
    }
    if (input.isError) {
      _fail(op, _error(input.error));
      return null;
    }
    final payloads = input.value;
    if (payloads == null) return null;
    AccountImportPreviewV1? preview;
    await _perform(
      op,
      (handle) => _useCase.prepareAccountImportV1(
        handle: handle,
        source: source,
        payloads: payloads,
        revision: revision,
      ),
      (value) {
        preview = value;
        emit(state.copyWith(busy: false));
      },
    );
    return preview;
  }

  Future<bool> applyAccountImport(String token, List<int> selected) async {
    if (!_hasUnlockedSession) return false;
    var applied = false;
    await _perform(
      'VaultController.applyAccountImport():',
      (handle) => _useCase.applyAccountImportV1(
        handle: handle,
        token: token,
        selected: selected,
      ),
      (value) {
        applied = true;
        emit(state.copyWith(content: () => value, busy: false));
      },
      contentMutation: true,
    );
    return applied;
  }

  Future<void> cancelAccountImport(String token) async {
    final handle = _handle;
    if (_closing || isClosed || handle == null || !_hasUnlockedSession) {
      return;
    }
    await _useCase.cancelAccountImportV1(handle: handle, token: token);
  }

  Future<RecoveryWordsV1?> inspectRecoveryWords(String text) async {
    final epoch = _epoch;
    final result = await _useCase.inspectRecoveryWordsV1(text);
    if (_closing || isClosed || epoch != _epoch || result.isError) return null;
    return result.value;
  }

  Future<String?> exportBackupToDirectory() async {
    final revision = state.content?.revision, epoch = _epoch;
    if (_closing ||
        isClosed ||
        !_hasUnlockedSession ||
        state.busy ||
        revision == null) {
      return null;
    }
    activity();
    final result = await _useCase.withBackupDestinationV1((path) async {
      if (_closing ||
          isClosed ||
          epoch != _epoch ||
          !_hasUnlockedSession ||
          state.content?.revision != revision) {
        return false;
      }
      return exportBackup(path, revision);
    });
    if (_closing || isClosed || epoch != _epoch || !_hasUnlockedSession) {
      return null;
    }
    if (result.isError) {
      _fail('VaultController.exportBackup():', _error(result.error));
      return null;
    }
    return result.value;
  }

  Future<String?> selectBackupSource() async {
    const op = 'VaultController.selectBackupPath():';
    final epoch = _epoch, revision = state.content?.revision;
    if (_closing ||
        isClosed ||
        !_hasUnlockedSession ||
        state.busy ||
        revision == null) {
      return null;
    }
    activity();
    final result = await _useCase.selectBackupSourceV1();
    if (_closing ||
        isClosed ||
        epoch != _epoch ||
        !_hasUnlockedSession ||
        state.content?.revision != revision) {
      return null;
    }
    if (result.isError) {
      _fail(op, _error(result.error));
      return null;
    }
    return result.value;
  }

  Future<bool> exportBackup(String destination, BigInt revision) async {
    if (!_hasUnlockedSession || state.content?.revision != revision) {
      return false;
    }
    var saved = false;
    await _perform(
      'VaultController.exportBackup():',
      (handle) => _useCase.exportBackupV1(
        handle: handle,
        destination: destination,
        revision: revision,
      ),
      (_) {
        saved = true;
        emit(state.copyWith(busy: false));
      },
    );
    return saved;
  }

  Future<BackupReviewV1?> previewBackup(
    String source,
    String phrase,
    BackupModeV1 mode,
    List<BackupSelectionV1> choices,
  ) async {
    if (!_hasUnlockedSession) return null;
    BackupReviewV1? preview;
    await _perform(
      'VaultController.previewBackup():',
      (handle) => _useCase.previewBackupV1(
        handle: handle,
        source: source,
        phrase: phrase,
        mode: mode,
        choices: choices,
      ),
      (value) {
        preview = value;
        emit(state.copyWith(busy: false));
      },
    );
    return preview;
  }

  Future<bool> applyBackup(
    String source,
    String phrase,
    BackupModeV1 mode,
    List<BackupSelectionV1> choices,
    BackupReviewV1 review,
  ) async {
    if (!_hasUnlockedSession ||
        !review.resolved ||
        state.content?.revision != review.revision) {
      return false;
    }
    var applied = false;
    await _perform(
      'VaultController.applyBackup():',
      (handle) => _useCase.applyBackupV1(
        handle: handle,
        source: source,
        phrase: phrase,
        mode: mode,
        choices: choices,
        review: review,
      ),
      (_) {
        applied = true;
        emit(state.copyWith(busy: false, content: () => null));
      },
      contentMutation: true,
    );
    return applied;
  }

  Future<Object?> localTool(
    LocalToolCommandV1 command,
    Object body, {
    Future<bool> Function()? admitted,
  }) async {
    final handle = _handle;
    final epoch = _epoch;
    if (_closing ||
        !_hasUnlockedSession ||
        handle is! VaultLocalToolsSessionV1) {
      return null;
    }
    final result = await (handle as VaultLocalToolsSessionV1).localTool(
      command,
      jsonEncode(body),
      admitted: admitted,
    );
    if (_closing ||
        isClosed ||
        _epoch != epoch ||
        !_hasUnlockedSession ||
        result.isError) {
      return null;
    }
    if (command == LocalToolCommandV1.configure ||
        command == LocalToolCommandV1.disconnect ||
        command == LocalToolCommandV1.request &&
            body is Map &&
            body['scope'] is Map &&
            (body['scope'] as Map)['action'] == 'store') {
      await loadContent();
    }
    return jsonDecode(result.value);
  }

  Future<void> loadContent() {
    const op = 'VaultController.loadContent():';
    if (!_hasUnlockedSession) return Future.value();
    return _perform(
      op,
      (handle) =>
          _useCase.loadContentV2(params: LoadContentParamsV2(handle: handle)),
      (value) => emit(
        state.copyWith(
          content: () => value.snapshot,
          catalog: () => value.catalog,
          busy: false,
        ),
      ),
    );
  }

  Future<CardPreviewV1?> readCardPreview(String id) async {
    const op = 'VaultController.readCardPreview():';
    if (_closing ||
        isClosed ||
        !_hasUnlockedSession ||
        state.busy ||
        _handle == null ||
        state.content == null ||
        !LaunchMode.isInitialized ||
        !LaunchMode.isForeground) {
      return null;
    }
    final epoch = _epoch, revision = state.content!.revision;
    final done = Completer<void>();
    _browseOperations.add(done.future);
    try {
      final result = await _useCase.readCardPreviewV1(
        params: ReadCardPreviewParamsV1(
          handle: _handle!,
          id: id,
          revision: revision,
        ),
      );
      if (_closing ||
          isClosed ||
          epoch != _epoch ||
          state.content?.revision != revision ||
          !_hasUnlockedSession) {
        return null;
      }
      if (result.isError) {
        _fail(op, _error(result.error), clearBusy: false);
        return null;
      }
      return result.value.preview;
    } finally {
      done.complete();
      _browseOperations.remove(done.future);
    }
  }

  Future<String?> revealCardField(String id, FieldIdV1 field) async {
    const op = 'VaultController.revealCardField():';
    if (_closing ||
        isClosed ||
        !_hasUnlockedSession ||
        state.busy ||
        _handle == null ||
        state.content == null ||
        !LaunchMode.isInitialized ||
        !LaunchMode.isForeground) {
      return null;
    }
    final epoch = _epoch, revision = state.content!.revision;
    final done = Completer<void>();
    _browseOperations.add(done.future);
    try {
      final result = await _useCase.readCardFieldV1(
        params: ReadCardFieldParamsV1(handle: _handle!, id: id, field: field),
      );
      if (_closing ||
          isClosed ||
          epoch != _epoch ||
          state.content?.revision != revision ||
          !_hasUnlockedSession) {
        return null;
      }
      if (result.isError) {
        _fail(op, _error(result.error), clearBusy: false);
        return null;
      }
      return result.value.value;
    } finally {
      done.complete();
      _browseOperations.remove(done.future);
    }
  }

  Future<CardV1?> readCard(String id) async {
    const op = 'VaultController.readCard():';
    if (!_hasUnlockedSession) return null;
    CardV1? card;
    await _perform(
      op,
      (handle) => _useCase.readCardV1(
        params: ReadCardParamsV1(handle: handle, id: id),
      ),
      (value) {
        card = value.card;
        emit(state.copyWith(busy: false));
      },
    );
    return card;
  }

  Future<T?> _readCatalog<T>(
    String operation,
    FutureDomainResult<T> Function(VaultHandleV1 handle, BigInt revision) read,
  ) async {
    final handle = _handle, revision = state.content?.revision, epoch = _epoch;
    if (_closing ||
        isClosed ||
        state.busy ||
        handle == null ||
        revision == null ||
        !_hasUnlockedSession ||
        !LaunchMode.isInitialized ||
        !LaunchMode.isForeground) {
      return null;
    }
    final done = Completer<void>();
    _browseOperations.add(done.future);
    try {
      final result = await read(handle, revision);
      if (_closing ||
          isClosed ||
          epoch != _epoch ||
          state.content?.revision != revision ||
          !_hasUnlockedSession) {
        return null;
      }
      if (result.isError) {
        _fail(operation, _error(result.error), clearBusy: false);
        return null;
      }
      return result.value;
    } finally {
      done.complete();
      _browseOperations.remove(done.future);
    }
  }

  Future<List<ResourceBindingV1>?> readBindings(String id) => _readCatalog(
    'VaultController.readBindings():',
    (h, r) => _useCase.bindingsV1(handle: h, revision: r, id: id),
  );

  Future<List<CustomValueViewV1>?> readCustomValues(String id) => _readCatalog(
    'VaultController.readCustomValues():',
    (h, r) => _useCase.customValuesV1(handle: h, revision: r, id: id),
  );

  Future<List<HistorySummaryV1>?> readHistory([String? cardId]) => _readCatalog(
    'VaultController.readHistory():',
    (h, r) => _useCase.historyV1(handle: h, revision: r, cardId: cardId),
  );

  Future<HistoricalCardV1?> readHistoricalCard(String id) => _readCatalog(
    'VaultController.readHistoricalCard():',
    (h, r) => _useCase.historicalCardV1(handle: h, revision: r, id: id),
  );

  Future<bool> editCatalog(CatalogEditV1 edit, BigInt revision) async {
    if (!_hasUnlockedSession || state.content?.revision != revision) {
      return false;
    }
    var saved = false;
    await _perform(
      'VaultController.editCatalog():',
      (handle) => _useCase.catalogEditV1(
        handle: handle,
        revision: revision,
        edit: edit,
      ),
      (snapshot) {
        saved = true;
        emit(state.copyWith(content: () => snapshot, busy: false));
      },
      contentMutation: true,
    );
    return saved;
  }

  Future<bool> saveGroup(GroupDraftV1 input, {BigInt? revision}) async {
    const op = 'VaultController.saveGroup():';
    final snapshot = state.content;
    if (!_hasUnlockedSession || snapshot == null) return false;
    var saved = false;
    await _perform(
      op,
      (handle) => _useCase.saveGroupV2(
        params: SaveGroupParamsV2(
          handle: handle,
          input: input,
          revision: revision ?? snapshot.revision,
        ),
      ),
      (value) {
        saved = true;
        emit(state.copyWith(content: () => value.snapshot, busy: false));
      },
      contentMutation: true,
    );
    return saved;
  }

  Future<bool> deleteGroup(String id, {BigInt? revision}) async {
    const op = 'VaultController.deleteGroup():';
    final snapshot = state.content;
    if (!_hasUnlockedSession || snapshot == null) return false;
    var saved = false;
    await _perform(
      op,
      (handle) => _useCase.deleteGroupV2(
        params: DeleteGroupParamsV2(
          handle: handle,
          id: id,
          revision: revision ?? snapshot.revision,
        ),
      ),
      (value) {
        saved = true;
        emit(state.copyWith(content: () => value.snapshot, busy: false));
      },
      contentMutation: true,
    );
    return saved;
  }

  Future<bool> saveCard(CardDraftV1 input, {BigInt? revision}) async {
    const op = 'VaultController.saveCard():';
    final snapshot = state.content;
    if (!_hasUnlockedSession || snapshot == null) return false;
    var saved = false;
    await _perform(
      op,
      (handle) => _useCase.saveCardV1(
        params: SaveCardParamsV1(
          handle: handle,
          input: input,
          revision: revision ?? snapshot.revision,
        ),
      ),
      (value) {
        saved = true;
        emit(state.copyWith(content: () => value.snapshot, busy: false));
      },
      contentMutation: true,
    );
    return saved;
  }

  Future<bool> deleteCard(String id, {BigInt? revision}) async {
    const op = 'VaultController.deleteCard():';
    final snapshot = state.content;
    if (!_hasUnlockedSession || snapshot == null) return false;
    var saved = false;
    await _perform(
      op,
      (handle) => _useCase.deleteCardV1(
        params: DeleteCardParamsV1(
          handle: handle,
          id: id,
          revision: revision ?? snapshot.revision,
        ),
      ),
      (value) {
        saved = true;
        emit(state.copyWith(content: () => value.snapshot, busy: false));
      },
      contentMutation: true,
    );
    return saved;
  }

  Future<CardMatchesV1?> searchCards(CardSearchV1 query) async {
    const op = 'VaultController.searchCards():';
    if (_closing ||
        isClosed ||
        !_hasUnlockedSession ||
        state.busy ||
        _handle == null ||
        state.content == null ||
        !LaunchMode.isInitialized ||
        !LaunchMode.isForeground) {
      return null;
    }
    final epoch = _epoch, search = ++_searchEpoch;
    final revision = state.content!.revision;
    final done = Completer<void>();
    _browseOperations.add(done.future);
    try {
      final result = await _useCase.searchCardsV1(
        params: SearchCardsParamsV1(
          handle: _handle!,
          query: query,
          revision: revision,
        ),
      );
      if (_closing ||
          epoch != _epoch ||
          search != _searchEpoch ||
          state.content?.revision != revision ||
          !_hasUnlockedSession) {
        return null;
      }
      if (result.isError) {
        _fail(op, _error(result.error), clearBusy: false);
        return null;
      }
      return result.value.matches;
    } finally {
      done.complete();
      _browseOperations.remove(done.future);
    }
  }

  Future<List<CardListRowV1>?> readCardListRows(List<String> ids) async {
    const op = 'VaultController.readCardListRows():';
    if (_closing ||
        isClosed ||
        !_hasUnlockedSession ||
        state.busy ||
        _handle == null ||
        state.content == null ||
        !LaunchMode.isInitialized ||
        !LaunchMode.isForeground) {
      return null;
    }
    final epoch = _epoch;
    final revision = state.content!.revision;
    final done = Completer<void>();
    _browseOperations.add(done.future);
    try {
      final result = await _useCase.readCardListRowsV1(
        params: ReadCardListRowsParamsV1(
          handle: _handle!,
          ids: List.unmodifiable(ids),
          revision: revision,
        ),
      );
      if (_closing ||
          epoch != _epoch ||
          state.content?.revision != revision ||
          !_hasUnlockedSession) {
        return null;
      }
      if (result.isError) {
        _fail(op, _error(result.error), clearBusy: false);
        return null;
      }
      return result.value.rows;
    } finally {
      done.complete();
      _browseOperations.remove(done.future);
    }
  }

  Future<HotpAdvanceV1?> nextHotp(String id, BigInt revision) async {
    if (!_hasUnlockedSession ||
        state.content?.revision != revision ||
        !LaunchMode.isInitialized ||
        !LaunchMode.isForeground) {
      return null;
    }
    HotpAdvanceV1? issued;
    await _perform(
      'VaultController.nextHotp():',
      (handle) => _useCase.nextHotpV1(
        params: NextHotpParamsV1(handle: handle, id: id, revision: revision),
      ),
      (value) {
        issued = value;
        emit(state.copyWith(content: () => value.snapshot, busy: false));
      },
      contentMutation: true,
    );
    return issued;
  }

  Future<TotpCodeV1?> readTotp(String id) async {
    const op = 'VaultController.readTotp():';
    if (_closing ||
        isClosed ||
        !_hasUnlockedSession ||
        state.busy ||
        _handle == null ||
        _totpOperation != null ||
        !LaunchMode.isInitialized ||
        !LaunchMode.isForeground) {
      return null;
    }
    final epoch = _epoch;
    final revision = state.content?.revision;
    final done = Completer<void>();
    _totpOperation = done.future;
    try {
      final result = await _useCase.readTotpV1(
        params: ReadTotpParamsV1(handle: _handle!, id: id),
      );
      if (!_hasUnlockedSession ||
          _closing ||
          epoch != _epoch ||
          state.content?.revision != revision ||
          state.busy) {
        return null;
      }
      if (result.isError) {
        _fail(op, _error(result.error));
        return null;
      }
      return result.value.code;
    } finally {
      done.complete();
      if (identical(_totpOperation, done.future)) _totpOperation = null;
    }
  }

  Future<String?> revealCustomField(String id, String fieldId) => _readCatalog(
    'VaultController.revealCustomField():',
    (h, r) => _useCase.customFieldV1(
      handle: h,
      revision: r,
      id: id,
      fieldId: fieldId,
      copy: false,
    ),
  );

  Future<void> copyCard(
    String id, {
    String? customField,
    void Function()? onCopied,
    FieldIdV1? field,
    bool currentOtp = false,
  }) => _copyCard(
    id,
    customField: customField,
    field: field,
    currentOtp: currentOtp,
    onCopied: onCopied,
  );

  Future<void> copyQuickCard(
    String id,
    BigInt revision, {
    required void Function() onCopied,
  }) => _copyCard(id, quickRevision: revision, onCopied: onCopied);

  Future<void> _copyCard(
    String id, {
    String? customField,
    void Function()? onCopied,
    FieldIdV1? field,
    bool currentOtp = false,
    BigInt? quickRevision,
  }) async {
    const op = 'VaultController.copyCard():';
    if (_closing ||
        isClosed ||
        !_hasUnlockedSession ||
        state.busy ||
        _handle == null ||
        _exportOperation != null) {
      return;
    }
    final epoch = _epoch;
    emit(state.copyWith(busy: true, error: () => null));
    activity();
    final operation = () async {
      await _clearClipboard();
      bool mayPublish() =>
          !_closing &&
          epoch == _epoch &&
          _hasUnlockedSession &&
          (quickRevision == null || state.content?.revision == quickRevision);
      if (!mayPublish()) return;
      final params = quickRevision != null
          ? CopyCardParamsV1.quickCard(
              handle: _handle!,
              id: id,
              revision: quickRevision,
            )
          : customField != null
          ? CopyCardParamsV1.custom(
              handle: _handle!,
              id: id,
              customField: customField,
              revision: state.content!.revision,
            )
          : field != null
          ? CopyCardParamsV1.field(handle: _handle!, id: id, field: field)
          : currentOtp
          ? CopyCardParamsV1.otp(handle: _handle!, id: id)
          : CopyCardParamsV1.account(handle: _handle!, id: id);
      final result = await _useCase.copyCardV1(
        params: params,
        mayPublish: mayPublish,
      );
      if (!mayPublish()) {
        if (result.isSuccess) {
          await _useCase.clearRecoveryClipboardV1(
            params: RecoveryClipboardParamsV1(phrase: result.value.text),
          );
        }
        return;
      }
      if (result.isError) {
        _fail(op, _error(result.error));
        return;
      }
      _clipboardContent = result.value.text;
      onCopied?.call();
      _clipboardExpiry = Timer(
        const Duration(seconds: 30),
        () => unawaited(_clearClipboard()),
      );
      emitEffect(
        VaultCredentialCopiedV1(cardId: id, kind: params.kind, field: field),
      );
      activity();
    }();
    _exportOperation = operation;
    try {
      await operation;
    } finally {
      if (identical(_exportOperation, operation)) _exportOperation = null;
      if (!_closing && !isClosed && epoch == _epoch) {
        emit(state.copyWith(busy: false));
      }
    }
  }

  Future<AttachmentDraftV1?> selectAttachment() async {
    const op = 'VaultController.selectAttachment():';
    if (_closing ||
        isClosed ||
        !_hasUnlockedSession ||
        state.busy ||
        _exportOperation != null) {
      return null;
    }
    final epoch = _epoch;
    final cancelled = Completer<void>();
    _fileSelectionCancelled = cancelled;
    emit(state.copyWith(busy: true, error: () => null));
    final operation = Future.any<DomainResult<SelectAttachmentResultV1>?>([
      _useCase.selectAttachmentV1(params: const SelectAttachmentParamsV1()),
      cancelled.future.then((_) => null),
    ]);
    final pending = operation.then<void>((_) {});
    _exportOperation = pending;
    try {
      final result = await operation;
      if (result == null || _closing || epoch != _epoch) return null;
      if (result.isError) {
        _fail(op, _error(result.error));
        return null;
      }
      return result.value.attachment;
    } finally {
      if (identical(_fileSelectionCancelled, cancelled)) {
        _fileSelectionCancelled = null;
      }
      if (identical(_exportOperation, pending)) _exportOperation = null;
      if (!_closing && !isClosed && epoch == _epoch) {
        emit(state.copyWith(busy: false));
      }
    }
  }

  Future<void> downloadAttachment(
    String id,
    String name, {
    String? fieldId,
  }) async {
    const op = 'VaultController.downloadAttachment():';
    if (_closing ||
        isClosed ||
        !_hasUnlockedSession ||
        state.busy ||
        _handle == null ||
        state.content == null ||
        _exportOperation != null) {
      return;
    }
    final epoch = _epoch;
    emit(state.copyWith(busy: true, error: () => null));
    activity();
    final revision = state.content!.revision;
    final cancelled = Completer<void>();
    _fileSelectionCancelled = cancelled;
    final operation = () async {
      final selected =
          await Future.any<DomainResult<SelectCardDestinationResultV1>?>([
            _useCase.selectCardDestinationV1(
              params: SelectCardDestinationParamsV1(name: name),
            ),
            cancelled.future.then((_) => null),
          ]);
      if (selected == null ||
          _closing ||
          epoch != _epoch ||
          !_withinIdleDeadline) {
        return;
      }
      if (selected.isError) {
        _fail(op, _error(selected.error));
        return;
      }
      final path = selected.value.destination;
      if (path == null) return;
      emitEffect(const VaultNotice(VaultNoticeKind.exportStarted));
      final result = await _useCase.exportCardAttachmentV1(
        params: ExportCardAttachmentParamsV1(
          fieldId: fieldId,
          handle: _handle!,
          id: id,
          destination: path,
          revision: revision,
        ),
      );
      if (_closing || epoch != _epoch) return;
      if (result.isError) {
        _fail(op, _error(result.error));
        return;
      }
      emitEffect(const VaultNotice(VaultNoticeKind.exported));
      activity();
    }();
    _exportOperation = operation;
    try {
      await operation;
    } finally {
      if (identical(_exportOperation, operation)) _exportOperation = null;
      if (!_closing && !isClosed && epoch == _epoch) {
        emit(state.copyWith(busy: false));
      }
      if (identical(_fileSelectionCancelled, cancelled)) {
        _fileSelectionCancelled = null;
      }
    }
  }

  Future<List<int>?> selectGroupLogo() async {
    const op = 'VaultController.selectGroupLogo():';
    if (_closing ||
        isClosed ||
        !_hasUnlockedSession ||
        state.busy ||
        _exportOperation != null ||
        !LaunchMode.isInitialized ||
        !LaunchMode.isForeground) {
      return null;
    }
    final epoch = _epoch;
    final cancelled = Completer<void>();
    _fileSelectionCancelled = cancelled;
    emit(state.copyWith(busy: true, error: () => null));
    final operation = Future.any<DomainResult<SelectGroupLogoResultV1>?>([
      _useCase.selectGroupLogoV1(params: const SelectGroupLogoParamsV1()),
      cancelled.future.then((_) => null),
    ]);
    _exportOperation = operation.then<void>((_) {});
    try {
      final result = await operation;
      if (result == null || _closing || epoch != _epoch) return null;
      if (result.isError) {
        _fail(op, _error(result.error));
        return null;
      }
      return result.value.bytes;
    } finally {
      if (identical(_fileSelectionCancelled, cancelled)) {
        _fileSelectionCancelled = null;
        _exportOperation = null;
      }
      if (!_closing && !isClosed && epoch == _epoch) {
        emit(state.copyWith(busy: false));
      }
    }
  }

  @disposeMethod
  @override
  Future<void> close() {
    const op = 'VaultController.close():';
    if (!_closing) {
      _closing = true;
      _epoch++;
      _idle?.cancel();
      _idleClock.stop();
      _clipboardExpiry?.cancel();
      if (_fileSelectionCancelled?.isCompleted == false) {
        _fileSelectionCancelled!.complete();
      }
      try {
        _handle?.invalidateSync();
      } on Object {
        reportVaultSafely(
          _reporter,
          layer: VaultDiagnosticLayer.controller,
          operation: op,
          error: const VaultUnexpectedErrorV1(),
        );
      }
    }
    return _closeFuture ??= () async {
      try {
        await _dispose(op);
      } finally {
        await super.close();
      }
    }();
  }

  Future<void> _dispose(String operation) async {
    await _clearClipboard();
    await _subscription?.cancel();
    await _initFuture;
    final handle = _handle;
    if (handle != null) {
      final result = await _useCase.closeV1(
        params: CloseVaultParamsV1(handle: handle),
      );
      if (result.isError) {
        reportVaultSafely(
          _reporter,
          layer: VaultDiagnosticLayer.controller,
          operation: operation,
          error: _error(result.error),
        );
      }
    }
    await _operation;
    await _resetOperation;
    await _totpOperation;
    await Future.wait(_browseOperations.toList());
    await Future.wait(_passwordOperations.toList());
    await _exportOperation;
    _handle = null;
  }

  static VaultErrorV1 _error(DomainError error) =>
      error is VaultErrorV1 ? error : const VaultUnexpectedErrorV1();
  static VaultPhase _phase(VaultAccessStateV1 state) => switch (state) {
    VaultAccessStateV1.missing => VaultPhase.missing,
    VaultAccessStateV1.locked => VaultPhase.locked,
    VaultAccessStateV1.unlocked => VaultPhase.unlocked,
    VaultAccessStateV1.confirmation => VaultPhase.confirmation,
  };
}
