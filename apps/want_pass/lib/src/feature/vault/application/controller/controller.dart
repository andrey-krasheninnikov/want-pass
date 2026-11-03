import 'dart:async';

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
  final _idleClock = Stopwatch();
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
    if (!state.passwordSaved ||
        !state.phraseSaved ||
        !state.lossAccepted ||
        !state.quizPassed.every((v) => v) ||
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

  Future<void> chooseSetupWord(int index, String word) async {
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
    if (word != challenge.words[challenge.positions[index]]) {
      final epoch = ++_epoch;
      if (_fileSelectionCancelled?.isCompleted == false) {
        _fileSelectionCancelled!.complete();
      }
      emit(
        VaultState(
          phase: VaultPhase.confirmation,
          busy: true,
          recovering: state.recovering,
          hints: state.hints,
          passwordSaved: state.passwordSaved,
        ),
      );
      emitEffect(const VaultRecoveryReset());
      await _clearClipboard();
      if (_closing || epoch != _epoch) return;
      // The native scenario invalidates the old revision before draining admitted exports.
      emit(state.copyWith(busy: false));
      await _perform(
        op,
        (handle) => _useCase.regenerateRecoveryV3(
          params: RegenerateVaultRecoveryParamsV3(handle: handle),
        ),
        (value) {
          emit(
            VaultState(
              phase: VaultPhase.confirmation,
              setupChallenge: value.challenge,
              recovering: state.recovering,
              hints: state.hints,
              passwordSaved: state.passwordSaved,
            ),
          );
          emitEffect(const VaultRecoveryRegenerated());
        },
      );
      return;
    }
    final answers = [...state.setupAnswers]..[index] = word;
    final passed = [...state.quizPassed]..[index] = true;
    emit(
      state.copyWith(
        setupAnswers: List.unmodifiable(answers),
        quizPassed: List.unmodifiable(passed),
        error: () => null,
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
            _useCase.selectRecoveryFileV3(
              params: const SelectRecoveryFileParamsV3(),
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
    if (_closing ||
        state.busy ||
        state.setupChallenge == null ||
        _exportOperation != null) {
      return;
    }
    final epoch = _epoch;
    final phrase = state.setupChallenge!.json;
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
  }) async {
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
    emit(state.copyWith(busy: true, error: preserveError ? null : () => null));
    activity();
    final future = () async {
      try {
        final result = await run(_handle!);
        if (_closing || epoch != _epoch) return;
        if (result.isError) {
          final error = _error(result.error);
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

  Future<void> loadContent() {
    const op = 'VaultController.loadContent():';
    if (state.phase != VaultPhase.unlocked) return Future.value();
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
        state.phase != VaultPhase.unlocked ||
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
          state.phase != VaultPhase.unlocked) {
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
        state.phase != VaultPhase.unlocked ||
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
          state.phase != VaultPhase.unlocked) {
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
    if (state.phase != VaultPhase.unlocked) return null;
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

  Future<bool> saveGroup(GroupDraftV1 input, {BigInt? revision}) async {
    const op = 'VaultController.saveGroup():';
    final snapshot = state.content;
    if (state.phase != VaultPhase.unlocked || snapshot == null) return false;
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
    if (state.phase != VaultPhase.unlocked || snapshot == null) return false;
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
    if (state.phase != VaultPhase.unlocked || snapshot == null) return false;
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
    if (state.phase != VaultPhase.unlocked || snapshot == null) return false;
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
        state.phase != VaultPhase.unlocked ||
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
          state.phase != VaultPhase.unlocked) {
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

  Future<List<CardRowV1>?> readCardRows(List<String> ids) async {
    const op = 'VaultController.readCardRows():';
    if (_closing ||
        isClosed ||
        state.phase != VaultPhase.unlocked ||
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
      final result = await _useCase.readCardRowsV1(
        params: ReadCardRowsParamsV1(
          handle: _handle!,
          ids: List.unmodifiable(ids),
          revision: revision,
        ),
      );
      if (_closing ||
          epoch != _epoch ||
          state.content?.revision != revision ||
          state.phase != VaultPhase.unlocked) {
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

  Future<TotpCodeV1?> readTotp(String id) async {
    const op = 'VaultController.readTotp():';
    if (_closing ||
        isClosed ||
        state.phase != VaultPhase.unlocked ||
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
      if (_closing ||
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

  Future<void> copyCard(
    String id, {
    FieldIdV1? field,
    bool currentOtp = false,
  }) async {
    const op = 'VaultController.copyCard():';
    if (_closing ||
        isClosed ||
        state.phase != VaultPhase.unlocked ||
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
      if (_closing || epoch != _epoch) return;
      final params = field != null
          ? CopyCardParamsV1.field(handle: _handle!, id: id, field: field)
          : currentOtp
          ? CopyCardParamsV1.otp(handle: _handle!, id: id)
          : CopyCardParamsV1.account(handle: _handle!, id: id);
      final result = await _useCase.copyCardV1(params: params);
      if (_closing || epoch != _epoch) {
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
        state.phase != VaultPhase.unlocked ||
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

  Future<void> downloadAttachment(String id, String name) async {
    const op = 'VaultController.downloadAttachment():';
    if (_closing ||
        isClosed ||
        state.phase != VaultPhase.unlocked ||
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
      if (selected == null || _closing || epoch != _epoch) return;
      if (selected.isError) {
        _fail(op, _error(selected.error));
        return;
      }
      final path = selected.value.destination;
      if (path == null) return;
      emitEffect(const VaultNotice(VaultNoticeKind.exportStarted));
      final result = await _useCase.exportCardAttachmentV1(
        params: ExportCardAttachmentParamsV1(
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
        state.phase != VaultPhase.unlocked ||
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
