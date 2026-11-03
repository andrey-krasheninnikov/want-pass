import 'dart:async';

import 'package:domain_error/domain_error.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:launch_mode/launch_mode.dart';
import 'package:want_pass/src/feature/vault/application/_barrel.dart';
import 'package:want_pass_core/want_pass_core.dart';

part 'state.dart';

@singleton
final class VaultController extends Cubit<VaultState> {
  final VaultUseCase _useCase;
  final VaultReporter _reporter;
  final Stream<VaultLockSignal> _lockEvents;
  VaultHandleV1? _handle;
  StreamSubscription<VaultLockSignal>? _subscription;
  Timer? _idle;
  Timer? _clipboardExpiry;
  String? _clipboardContent;
  Future<void>? _exportOperation;
  Completer<void>? _fileSelectionCancelled;
  Future<void>? _initFuture;
  Future<void>? _closeFuture;
  Future<void>? _operation;
  bool _closing = false;
  bool _monitorAvailable = true;
  int _epoch = 0;

  VaultController(
    this._useCase,
    this._reporter,
    @Named('vaultLockEvents') this._lockEvents,
  ) : super(const VaultState(phase: VaultPhase.loading));

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
      (handle) => _useCase.prepareSetupV2(
        params: PrepareVaultSetupParamsV2(
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
          setupAnswers: state.setupChallenge == value.challenge
              ? state.setupAnswers
              : const [null, null, null],
          quizPassed: state.setupChallenge == value.challenge
              ? state.quizPassed
              : const [false, false, false],
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
    return _perform(
      op,
      (handle) => _useCase.confirmSetupV2(
        params: ConfirmVaultSetupParamsV2(
          handle: handle,
          answers: List.unmodifiable(answers),
          password: password,
          hints: hints,
        ),
      ),
      (value) => emit(VaultState(phase: _phase(value.state), hints: hints)),
    );
  }

  Future<void> readHints() {
    const op = 'VaultController.readHints():';
    return _perform(
      op,
      (handle) =>
          _useCase.readHintsV2(params: ReadVaultHintsParamsV2(handle: handle)),
      (value) => emit(state.copyWith(busy: false, hints: value.hints)),
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

  void chooseSetupWord(int index, String word) {
    const op = 'VaultController.chooseSetupWord():';
    final challenge = state.setupChallenge;
    if (_closing ||
        state.busy ||
        challenge == null ||
        index < 0 ||
        index >= 3 ||
        !challenge.choices[index].contains(word)) {
      return;
    }
    final answers = [...state.setupAnswers]..[index] = word;
    final passed = [...state.quizPassed]
      ..[index] = word == challenge.words[challenge.positions[index]];
    if (!passed[index]) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.controller,
        operation: op,
        error: const VaultRejectedErrorV1(VaultFailureKindV1.confirmation),
      );
    }
    emit(
      state.copyWith(
        setupAnswers: List.unmodifiable(answers),
        quizPassed: List.unmodifiable(passed),
        error: () => passed[index]
            ? null
            : const VaultRejectedErrorV1(VaultFailureKindV1.confirmation),
      ),
    );
    activity();
  }

  Future<void> downloadRecovery() {
    const op = 'VaultController.downloadRecovery():';
    if (_closing ||
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
            _useCase.selectRecoveryFileV1(
              params: const SelectRecoveryFileParamsV1(),
            ),
            cancelled.future.then((_) => null),
          ]);
      if (selected == null || _closing || epoch != _epoch) return;
      if (selected.isError) {
        _fail(op, _error(selected.error));
        return;
      }
      final destination = selected.value.destination;
      if (destination == null) return;
      final result = await _useCase.exportRecoveryV2(
        params: ExportRecoveryParamsV2(
          handle: _handle!,
          destination: destination,
        ),
      );
      if (!_closing && epoch == _epoch && result.isError) {
        _fail(op, _error(result.error));
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
    if (_closing ||
        state.busy ||
        state.setupChallenge == null ||
        _exportOperation != null) {
      return;
    }
    final epoch = _epoch;
    final phrase = state.setupChallenge!.words.join(' ');
    final operation = () async {
      await _clearClipboard();
      if (_closing || epoch != _epoch) return;
      final result = await _useCase.copyRecoveryV1(
        params: RecoveryClipboardParamsV1(phrase: phrase),
      );
      if (_closing || epoch != _epoch) {
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
      _clipboardExpiry = Timer(
        const Duration(seconds: 60),
        () => unawaited(_clearClipboard()),
      );
    }();
    _exportOperation = operation;
    await operation;
    if (identical(_exportOperation, operation)) _exportOperation = null;
  }

  Future<void> _clearClipboard() async {
    const op = 'VaultController._clearClipboard():';
    _clipboardExpiry?.cancel();
    final content = _clipboardContent;
    _clipboardContent = null;
    if (content == null) return;
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
  }

  Future<void> unlock(String password) {
    const op = 'VaultController.unlock():';
    return _perform(
      op,
      (handle) => _useCase.unlockV1(
        params: UnlockVaultParamsV1(handle: handle, password: password),
      ),
      (value) => emit(VaultState(phase: _phase(value.state))),
    );
  }

  Future<void> _perform<T>(
    String operation,
    FutureDomainResult<T> Function(VaultHandleV1) run,
    void Function(T) success,
  ) async {
    if (_closing ||
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
    emit(state.copyWith(busy: true, error: () => null));
    activity();
    final future = () async {
      try {
        final result = await run(_handle!);
        if (_closing || epoch != _epoch) return;
        if (result.isError) {
          _fail(operation, _error(result.error));
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
  }

  Future<void> lock() async {
    const op = 'VaultController.lock():';
    if (_closing || isClosed || _handle == null) return;
    final epoch = ++_epoch;
    if (_fileSelectionCancelled?.isCompleted == false) {
      _fileSelectionCancelled!.complete();
    }
    unawaited(_clearClipboard());
    _idle?.cancel();
    emit(const VaultState(phase: VaultPhase.loading, busy: true));
    try {
      final result = await _useCase.lockV1(
        params: LockVaultParamsV1(handle: _handle!),
      );
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
                ? null
                : const VaultRejectedErrorV1(VaultFailureKindV1.unavailable),
          ),
        );
      }
    } on Object {
      if (!_closing && epoch == _epoch) {
        _fail(op, const VaultUnexpectedErrorV1(), unavailable: true);
      }
    }
  }

  void activity() {
    const op = 'VaultController.activity():';
    if (_closing || isClosed) return;
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

  void _fail(String operation, VaultErrorV1 error, {bool unavailable = false}) {
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
            : state.copyWith(busy: false, error: () => error),
      );
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
