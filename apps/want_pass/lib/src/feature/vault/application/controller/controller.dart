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
