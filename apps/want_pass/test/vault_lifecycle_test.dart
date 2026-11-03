import 'dart:async';

import 'package:domain_error/domain_error.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:want_pass/src/feature/_common/presentation/_barrel.dart';
import 'package:want_pass/src/feature/startup/application/_barrel.dart';
import 'package:launch_mode/launch_mode.dart';
import 'package:want_pass/src/feature/vault/application/_barrel.dart';
import 'package:want_pass_core/want_pass_core.dart';

const _password = 'Synthetic lifecycle password 2026';
const _challenge = VaultRecoveryChallengeV1(
  words: ['one', 'two', 'three'],
  positions: [0, 1, 2],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  LaunchMode.initializeAutomatically();

  test(
    'password mismatch never reaches storage and domain errors keep identity',
    () async {
      final access = _Access();
      final useCase = VaultUseCaseImpl(access, const _Reporter());
      final mismatch = await useCase.prepareCreationV1(
        params: PrepareVaultCreationParamsV1(
          handle: access.handle,
          password: _password,
          confirmation: 'different',
        ),
      );
      expect(
        mismatch.error,
        const VaultRejectedErrorV1(VaultFailureKindV1.passwordMismatch),
      );
      expect(access.preparations, 0);
      const error = VaultRejectedErrorV1(VaultFailureKindV1.corrupt);
      access.failure = error;
      final result = await useCase.unlockV1(
        params: UnlockVaultParamsV1(handle: access.handle, password: _password),
      );
      expect(identical(result.error, error), isTrue);
    },
  );

  test(
    'close during initialization closes the late handle exactly once',
    () async {
      final access = _Access()
        ..opening = Completer<DomainResult<VaultHandleV1>>();
      final events = StreamController<VaultLockSignal>.broadcast();
      final controller = _controller(access, events.stream);
      final initialize = controller.init();
      final close = controller.close();
      expect(identical(close, controller.close()), isTrue);
      access.opening!.complete(Result.success(access.handle));
      await initialize;
      await close;
      expect(controller.isClosed, isTrue);
      expect(access.handle.closes, 1);
      await events.close();
    },
  );

  test('lock discards a late recovery challenge and repeated taps share no second operation', () async {
    final access = _Access()
      ..preparing = Completer<DomainResult<VaultRecoveryChallengeV1>>();
    final events = StreamController<VaultLockSignal>.broadcast();
    final controller = _controller(access, events.stream);
    await controller.init();
    final operation = controller.prepareCreation(
      password: _password,
      confirmation: _password,
    );
    await controller.prepareCreation(
      password: _password,
      confirmation: _password,
    );
    expect(access.preparations, 1);
    await controller.lock();
    access.preparing!.complete(const Result.success(_challenge));
    await operation;
    expect(controller.state.phase, VaultPhase.missing);
    expect(controller.state.challenge, isNull);
    await controller.close();
    await events.close();
  });

  testWidgets('five idle minutes lock; activity renews the deadline', (
    tester,
  ) async {
    final access = _Access();
    final events = StreamController<VaultLockSignal>.broadcast();
    final controller = _controller(access, events.stream);
    await tester.runAsync(controller.init);
    await controller.prepareCreation(
      password: _password,
      confirmation: _password,
    );
    expect(controller.state.phase, VaultPhase.confirmation);
    await tester.pump(const Duration(minutes: 4));
    controller.activity();
    await tester.pump(const Duration(minutes: 4));
    expect(controller.state.phase, VaultPhase.confirmation);
    await tester.pump(const Duration(minutes: 1));
    expect(controller.state.phase, VaultPhase.missing);
    expect(controller.state.challenge, isNull);
    expect(access.handle.invalidations, 1);
    await tester.runAsync(() async {
      await controller.close();
      await events.close();
    });
  });

  test(
    'native lock and monitor failure clear access and fail closed',
    () async {
      final access = _Access();
      final events = StreamController<VaultLockSignal>.broadcast();
      final controller = _controller(access, events.stream);
      await controller.init();
      await controller.unlock(_password);
      expect(controller.state.phase, VaultPhase.unlocked);
      final locked = controller.stream.firstWhere(
        (state) => state.phase == VaultPhase.missing,
      );
      events.add(VaultLockSignal.lock);
      await locked;
      final unavailable = controller.stream.firstWhere(
        (state) => state.phase == VaultPhase.unavailable,
      );
      events.addError(StateError('Synthetic monitor failure'));
      await unavailable;
      expect(access.handle.state, VaultAccessStateV1.missing);
      expect(controller.state.challenge, isNull);
      await controller.close();
      await events.close();
    },
  );

  testWidgets(
    'unlock retry submits the replacement text once after a rejected password',
    (tester) async {
      final access = _Access()
        ..failure = const VaultRejectedErrorV1(VaultFailureKindV1.credentials);
      access.handle.state = VaultAccessStateV1.locked;
      final events = StreamController<VaultLockSignal>.broadcast();
      final controller = _controller(access, events.stream);
      final startup = StartupController(_Startup(), const _Reporter());
      await tester.runAsync(() async {
        await startup.init();
        await controller.init();
      });
      await tester.pumpWidget(WantPassApp(startup: startup, vault: controller));
      await tester.pumpAndSettle();
      final field = find.descendant(
        of: find.byKey(const ValueKey('master-password')),
        matching: find.byType(EditableText),
      );
      await tester.enterText(field, 'Wrong synthetic password 2026');
      await tester.tap(find.byKey(const ValueKey('vault-unlock')));
      await tester.pumpAndSettle();
      expect(controller.state.error, isNotNull);
      access.failure = null;
      await tester.enterText(field, _password);
      await tester.pump();
      expect(tester.widget<EditableText>(field).controller.text, _password);
      await tester.tap(find.byKey(const ValueKey('vault-unlock')));
      await tester.pumpAndSettle();
      expect(controller.state.phase, VaultPhase.unlocked);
      expect(access.passwords, ['Wrong synthetic password 2026', _password]);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.runAsync(() async {
        await controller.close();
        await startup.close();
        await events.close();
      });
    },
  );

  test('background initialization does not open the vault', () async {
    final access = _Access();
    await LaunchMode.withBackgroundMode(() async {
      final controller = _controller(access, const Stream.empty());
      await controller.init();
      expect(controller.state.phase, VaultPhase.unavailable);
      expect(access.opens, 0);
      await controller.close();
    });
  });
}

VaultController _controller(_Access access, Stream<VaultLockSignal> events) =>
    VaultController(
      VaultUseCaseImpl(access, const _Reporter()),
      const _Reporter(),
      events,
    );

final class _Handle implements VaultHandleV1 {
  VaultAccessStateV1 state = VaultAccessStateV1.missing;
  int invalidations = 0;
  int closes = 0;
  @override
  void invalidateSync() {
    invalidations++;
    state = VaultAccessStateV1.missing;
  }

  @override
  Future<void> close() async {
    closes++;
    invalidateSync();
  }
}

final class _Access implements VaultAccessService {
  final handle = _Handle();
  int opens = 0;
  int preparations = 0;
  final passwords = <String>[];
  VaultErrorV1? failure;
  Completer<DomainResult<VaultHandleV1>>? opening;
  Completer<DomainResult<VaultRecoveryChallengeV1>>? preparing;
  @override
  FutureDomainResult<VaultHandleV1> openV1() {
    opens++;
    return opening?.future ?? Future.value(Result.success(handle));
  }

  @override
  FutureDomainResult<VaultAccessStateV1> statusV1({
    required VaultHandleV1 handle,
  }) async => Result.success(this.handle.state);
  @override
  FutureDomainResult<VaultRecoveryChallengeV1> prepareCreationV1({
    required VaultHandleV1 handle,
    required String password,
  }) {
    preparations++;
    this.handle.state = VaultAccessStateV1.confirmation;
    return preparing?.future ?? Future.value(const Result.success(_challenge));
  }

  @override
  FutureDomainResult<VaultRecoveryChallengeV1> prepareRecoveryV1({
    required VaultHandleV1 handle,
    required String phrase,
    required String password,
  }) => prepareCreationV1(handle: handle, password: password);
  @override
  FutureDomainResult<void> confirmV1({
    required VaultHandleV1 handle,
    required List<String> answers,
  }) async {
    this.handle.state = VaultAccessStateV1.unlocked;
    return const Result.success(null);
  }

  @override
  FutureDomainResult<void> unlockV1({
    required VaultHandleV1 handle,
    required String password,
  }) async {
    passwords.add(password);
    if (failure case final error?) return Result.error(error);
    this.handle.state = VaultAccessStateV1.unlocked;
    return const Result.success(null);
  }
}

final class _Reporter implements VaultReporter, StartupReporter {
  const _Reporter();
  @override
  void report({
    required StartupDiagnosticLayer layer,
    required String operation,
    required StartupDiagnosticEvent event,
    StartupErrorV1? error,
  }) {}
  @override
  void reportVault({
    required VaultDiagnosticLayer layer,
    required String operation,
    required VaultErrorV1 error,
  }) {}
}

final class _Startup implements StartupUseCase {
  @override
  FutureDomainResult<InitializeStartupResultV1> initializeV1({
    required InitializeStartupParamsV1 params,
  }) async => const Result.success(InitializeStartupResultV1());
}
