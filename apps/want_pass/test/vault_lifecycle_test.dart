import 'package:want_pass/src/feature/vault/infrastructure/_barrel.dart';

import 'dart:async';
import 'dart:convert';

import 'package:domain_error/domain_error.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:flutter/material.dart';
import 'package:want_allure/want_allure.dart';

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:want_pass/src/feature/appearance/application/_barrel.dart';
import 'package:want_pass/src/feature/_common/presentation/_barrel.dart';
import 'package:want_pass/src/feature/startup/application/_barrel.dart';
import 'package:launch_mode/launch_mode.dart';
import 'package:want_pass/src/feature/vault/application/_barrel.dart';
import 'package:want_pass/src/feature/vault/presentation/_barrel.dart';
import 'package:want_pass_core/want_pass_core.dart';

const _password = 'Synthetic lifecycle password 2026!';
const _challenge = VaultRecoveryChallengeV1(
  words: ['one', 'two', 'three'],
  positions: [0, 1, 2],
);

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    binding.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
  });
  tearDown(binding.platformDispatcher.clearAccessibilityFeaturesTestValue);
  LaunchMode.initializeAutomatically();

  test(
    'password checks keep only the latest revision and never cross a lock',
    () async {
      final access = _Access();
      access.handle.state = VaultAccessStateV1.locked;
      final events = StreamController<VaultLockSignal>.broadcast();
      final controller = _controller(access, events.stream);
      await controller.init();
      final older = Completer<DomainResult<bool>>();
      access.passwordCheck = older;
      final first = controller.validatePassword(_password);
      final current = Completer<DomainResult<bool>>();
      access.passwordCheck = current;
      final second = controller.validatePassword('short');
      current.complete(const Result.success(false));
      expect(await second, isFalse);
      older.complete(const Result.success(true));
      expect(await first, isFalse);
      expect(controller.state.passwordValid, isFalse);
      final late = Completer<DomainResult<bool>>();
      access.passwordCheck = late;
      final pending = controller.validatePassword(_password);
      await controller.lock();
      late.complete(const Result.success(true));
      expect(await pending, isFalse);
      expect(controller.state.passwordValid, isNull);
      await controller.close();
      await events.close();
    },
  );

  testWidgets(
    'idle countdown follows the owner even with reduced motion and inactive views',
    (tester) async {
      var remaining = const Duration(minutes: 5);
      await tester.pumpWidget(
        MaterialApp(
          home: WantTheme(
            data: WantThemeData.dark(),
            reduceMotion: true,
            child: VaultIdleCountdown(remaining: () => remaining),
          ),
        ),
      );
      expect(find.text('05:00'), findsOneWidget);
      remaining = const Duration(minutes: 4, seconds: 59);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('04:59'), findsOneWidget);
      binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      remaining = const Duration(minutes: 3);
      await tester.pump(const Duration(seconds: 60));
      expect(find.text('04:59'), findsOneWidget);
      binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(find.text('03:00'), findsOneWidget);
      remaining = const Duration(minutes: 5);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('05:00'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  test(
    'password mismatch never reaches storage and domain errors keep identity',
    () async {
      final access = _Access();
      final useCase = VaultUseCaseImpl(
        access,
        const _Reporter(),
        const PlatformRecoveryExportService(_Reporter()),
        const PlatformGroupLogoService(_Reporter()),
      );
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
      await _loadFonts(tester);
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
      final notices = <VaultNoticeKind>[];
      final effects = controller.effectsStream.listen((effect) {
        if (effect is VaultNotice) notices.add(effect.kind);
      });
      final boundary = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundary,
          child: WantPassApp(startup: startup, vault: controller),
        ),
      );
      await tester.pumpAndSettle();
      await _tapKey(tester, 'vault-dial');
      expect(find.byKey(const ValueKey('vault-recovery')), findsNothing);
      expect(find.byKey(const ValueKey('vault-show-hint')), findsNothing);
      await _capture(tester, boundary, 'unlock-initial');
      final field = find.descendant(
        of: find.byKey(const ValueKey('unlock-password')),
        matching: find.bySubtype<EditableText>(),
      );
      final postfixButtons = find.descendant(
        of: find.byKey(const ValueKey('unlock-password')),
        matching: find.byType(FButton),
      );
      expect(postfixButtons, findsNWidgets(2));
      for (final element in postfixButtons.evaluate()) {
        final button = element.widget as FButton;
        final base = WantTheme.of(element).forui.buttonStyles
            .resolve({FButtonVariant.ghost})
            .resolve({FButtonSizeVariant.md});
        final decoration = button.style(base).decoration.resolve({
          FTappableVariant.hovered,
        }) as BoxDecoration;
        expect(decoration.color, isNull);
        expect(decoration.border, isNull);
        expect(element.size!.shortestSide, greaterThanOrEqualTo(44));
      }
      await _enter(tester, field, 'short');
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();
      expect(controller.state.passwordValid, isFalse);
      expect(
        tester
            .widget<VaultSecretInput>(
              find.byKey(const ValueKey('unlock-password')),
            )
            .invalid,
        isFalse,
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(access.passwords, isEmpty);
      expect(
        tester
            .widget<VaultSecretInput>(
              find.byKey(const ValueKey('unlock-password')),
            )
            .invalid,
        isTrue,
      );
      await _capture(tester, boundary, 'unlock-invalid');
      expect(find.byKey(const ValueKey('vault-recovery')), findsNothing);
      expect(find.byKey(const ValueKey('vault-show-hint')), findsNothing);
      await _enter(tester, field, 'Wrong synthetic password 2026!');
      await tester.tap(find.byKey(const ValueKey('vault-unlock')));
      await tester.pumpAndSettle();
      expect(controller.state.error, isNotNull);
      expect(find.byKey(const ValueKey('vault-recovery')), findsOneWidget);
      expect(find.byKey(const ValueKey('vault-show-hint')), findsOneWidget);
      expect(find.textContaining('Access could not be verified'), findsNothing);
      expect(find.text('No password hint was added.'), findsNothing);
      await _tapKey(tester, 'vault-show-hint');
      expect(find.text('No password hint was added.'), findsOneWidget);
      await _capture(tester, boundary, 'unlock-hint');
      await _tapKey(tester, 'vault-show-hint');
      expect(find.text('No password hint was added.'), findsNothing);
      await _capture(tester, boundary, 'unlock-rejected');
      expect(notices, isEmpty);
      access.failure = null;
      await _enter(tester, field, _password);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();
      final editor = tester.widget<EditableText>(field);
      expect(editor.controller.text, _password);
      expect(editor.focusNode.hasFocus, isTrue);
      final focus = editor.focusNode;
      final unlockButton = find.byKey(const ValueKey('vault-unlock'));
      final buttonElement = tester.element(unlockButton);
      expect(controller.state.passwordValid, isTrue);
      await _capture(tester, boundary, 'unlock-valid');
      expect(identical(tester.element(unlockButton), buttonElement), isTrue);
      expect(tester.widget<EditableText>(field).focusNode, same(focus));
      await tester.tap(find.byKey(const ValueKey('vault-unlock')));
      await tester.pumpAndSettle();
      expect(controller.state.phase, VaultPhase.unlocked);
      expect(notices, [VaultNoticeKind.unlocked]);
      expect(find.text('Access granted'), findsWidgets);
      expect(find.text('05:00'), findsOneWidget);
      final glows = find.byType(WantGlow);
      expect(glows, findsOneWidget);
      expect(
        find.ancestor(of: glows, matching: find.byType(VaultSafeDial)),
        findsOneWidget,
      );
      final dialSize = tester.getSize(find.byKey(const ValueKey('vault-dial')));
      expect(dialSize.width, dialSize.height);
      await _capture(tester, boundary, 'unlock-granted');
      expect(access.passwords, ['Wrong synthetic password 2026!', _password]);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.runAsync(() async {
        await effects.cancel();
        await controller.close();
        await startup.close();
        await events.close();
      });
    },
  );

  testWidgets(
    'unlock operational failures remain in the active dialog semantics',
    (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        final access = _Access();
        access.handle.state = VaultAccessStateV1.locked;
        final events = StreamController<VaultLockSignal>.broadcast();
        final controller = _controller(access, events.stream);
        final startup = StartupController(_Startup(), const _Reporter());
        await tester.runAsync(() async {
          await startup.init();
          await controller.init();
        });
        await tester.pumpWidget(
          WantPassApp(startup: startup, vault: controller),
        );
        await tester.pumpAndSettle();
        await _tapKey(tester, 'vault-dial');
        final field = find.descendant(
          of: find.byKey(const ValueKey('unlock-password')),
          matching: find.bySubtype<EditableText>(),
        );
        for (final (failure, message) in <(VaultErrorV1, String)>[
          (
            const VaultRejectedErrorV1(VaultFailureKindV1.storage),
            'The vault is unavailable. Restart Want Pass and try again. Your file has not been reset.',
          ),
          (
            const VaultRejectedErrorV1(VaultFailureKindV1.unsupported),
            'This vault format is not supported. The file has not been changed.',
          ),
          (
            const VaultUnexpectedErrorV1(),
            'The vault is unavailable. Restart Want Pass and try again. Your file has not been reset.',
          ),
        ]) {
          access.failure = failure;
          await _enter(tester, field, _password);
          await _tapKey(tester, 'vault-unlock');
          expect(controller.state.phase, VaultPhase.locked);
          expect(
            find.descendant(
              of: find.byType(VaultUnlockDialog),
              matching: find.text(message),
            ),
            findsOneWidget,
          );
          final errorNode = tester.getSemantics(
            find.descendant(
              of: find.byType(VaultUnlockDialog),
              matching: find.text(message),
            ),
          );
          expect(errorNode.getSemanticsData().label, message);
          expect(errorNode.flagsCollection.isLiveRegion, isTrue);
          expect(find.byKey(const ValueKey('vault-recovery')), findsNothing);
          expect(find.byKey(const ValueKey('vault-show-hint')), findsNothing);
        }
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.runAsync(() async {
          await controller.close();
          await startup.close();
          await events.close();
        });
      } finally {
        semantics.dispose();
      }
    },
  );

  test(
    'monitor loss blocks new access while earlier lock status is pending',
    () async {
      final access = _Access();
      access.handle.exists = true;
      access.handle.state = VaultAccessStateV1.unlocked;
      final events = StreamController<VaultLockSignal>.broadcast();
      final controller = _controller(access, events.stream);
      await controller.init();
      final firstStatus = Completer<DomainResult<VaultAccessStateV1>>();
      final nextStatus = Completer<DomainResult<VaultAccessStateV1>>();
      access.statusReplies.addAll([firstStatus, nextStatus]);
      final pending = controller.stream.firstWhere(
        (state) => state.phase == VaultPhase.loading,
      );
      events.addError(StateError('Synthetic monitor loss'));
      await pending;
      final nextLock = controller.lock();
      nextStatus.complete(const Result.success(VaultAccessStateV1.locked));
      await nextLock;
      expect(controller.state.phase, VaultPhase.unavailable);
      await controller.unlock(_password);
      expect(access.passwords, isEmpty);
      firstStatus.complete(const Result.success(VaultAccessStateV1.locked));
      await Future<void>.delayed(Duration.zero);
      expect(controller.state.phase, VaultPhase.unavailable);
      expect(access.handle.state, VaultAccessStateV1.locked);
      await controller.close();
      await events.close();
    },
  );

  test('older lock responses cannot replace a later unlock', () async {
    for (final oldResult in <DomainResult<VaultAccessStateV1>>[
      const Result.success(VaultAccessStateV1.locked),
      const Result.error(VaultRejectedErrorV1(VaultFailureKindV1.stale)),
    ]) {
      final access = _Access();
      access.handle.exists = true;
      access.handle.state = VaultAccessStateV1.unlocked;
      final events = StreamController<VaultLockSignal>.broadcast();
      final controller = _controller(access, events.stream);
      await controller.init();
      final firstStatus = Completer<DomainResult<VaultAccessStateV1>>();
      final nextStatus = Completer<DomainResult<VaultAccessStateV1>>();
      access.statusReplies.addAll([firstStatus, nextStatus]);
      final firstLock = controller.lock();
      final nextLock = controller.lock();
      nextStatus.complete(const Result.success(VaultAccessStateV1.locked));
      await nextLock;
      await controller.unlock(_password);
      expect(controller.state.phase, VaultPhase.unlocked);
      firstStatus.complete(oldResult);
      await firstLock;
      expect(controller.state.phase, VaultPhase.unlocked);
      await controller.close();
      await events.close();
    }
  });

  testWidgets(
    'branded password fields remove LF while preserving spaces and Unicode',
    (tester) async {
      const password = 'Synthetic exact\npassword 2026!';
      const acceptedPassword = 'Synthetic exactpassword 2026!';
      final semantics = tester.ensureSemantics();
      try {
        final access = _Access();
        final events = StreamController<VaultLockSignal>.broadcast();
        final controller = _controller(access, events.stream);
        final startup = StartupController(_Startup(), const _Reporter());
        await tester.runAsync(() async {
          await startup.init();
          await controller.init();
        });
        await tester.pumpWidget(
          WantPassApp(startup: startup, vault: controller),
        );
        await tester.pumpAndSettle();
        Finder input(String key) => find.descendant(
          of: find.byKey(ValueKey(key)),
          matching: find.bySubtype<EditableText>(),
        );
        await _enter(tester, input('master-password'), password);
        expect(
          tester.state<EditableTextState>(input('master-password')).copyEnabled,
          isFalse,
        );
        final data = tester
            .getSemantics(input('master-password'))
            .getSemanticsData();
        expect(data.label, contains('Master password'));
        expect(data.flagsCollection.isObscured, isTrue);
        expect(data.value, isNot(contains('Synthetic')));
        void expectPrivateInput(bool obscured) {
          final state = tester.state<EditableTextState>(
            input('master-password'),
          );
          expect(state.widget.obscureText, obscured);
          expect(state.widget.autofillHints, isNull);
          expect(state.widget.autocorrect, isFalse);
          expect(state.widget.enableSuggestions, isFalse);
          expect(state.widget.enableIMEPersonalizedLearning, isFalse);
          expect(
            state.textInputConfiguration.autofillConfiguration.enabled,
            isFalse,
          );
          expect(
            state.textInputConfiguration.toJson().containsKey('autofill'),
            isFalse,
          );
        }

        Future<void> toggle(String label) async {
          final button = find.descendant(
            of: find.byKey(const ValueKey('master-password')),
            matching: find.bySemanticsLabel(label),
          );
          await tester.ensureVisible(button);
          await tester.pumpAndSettle();
          await tester.tap(button);
          await tester.pumpAndSettle();
        }

        expectPrivateInput(true);
        await toggle('Show password');
        await _enter(tester, input('master-password'), password);
        expectPrivateInput(false);
        await toggle('Hide password');
        expectPrivateInput(true);

        await _enter(tester, input('password-confirmation'), password);
        await tester.tap(find.byKey(const ValueKey('vault-create')));
        await tester.pumpAndSettle();
        expect(access.preparedPasswords, [acceptedPassword]);
        await controller.confirm(['one', 'two', 'three']);
        await controller.lock();
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('vault-dial')));
        await tester.pumpAndSettle();
        await _enter(tester, input('unlock-password'), password);
        await tester.tap(find.byKey(const ValueKey('vault-unlock')));
        await tester.pumpAndSettle();
        expect(access.passwords, [acceptedPassword]);
        expect(controller.state.phase, VaultPhase.unlocked);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(milliseconds: 100));
        await tester.runAsync(() async {
          await controller.close();
          await startup.close();
          await events.close();
        });
      } finally {
        semantics.dispose();
      }
    },
  );

  test(
    'lock cancels a pending save chooser and prevents a later export',
    () async {
      final access = _Access();
      final export = _Export();
      final events = StreamController<VaultLockSignal>.broadcast();
      final controller = _controller(access, events.stream, export);
      await controller.init();
      await controller.prepareSetup(
        password: _password,
        confirmation: _password,
      );
      final saving = controller.downloadRecovery();
      await Future<void>.delayed(Duration.zero);
      await controller.lock();
      await saving;
      expect(access.exports, 0);
      export.selection.complete(
        const Result.success('/synthetic/recovery.txt'),
      );
      await Future<void>.delayed(Duration.zero);
      expect(access.exports, 0);
      await controller.close();
      await events.close();
    },
  );
  test(
    'lock clears keys immediately and waits for admitted export completion',
    () async {
      final access = _Access();
      access.handle.exists = true;
      access.handle.state = VaultAccessStateV1.unlocked;
      access.draining = Completer<DomainResult<void>>();
      final events = StreamController<VaultLockSignal>.broadcast();
      final controller = _controller(access, events.stream);
      await controller.init();
      final locking = controller.lock();
      await Future<void>.delayed(Duration.zero);
      expect(access.handle.invalidations, 1);
      expect(access.handle.state, VaultAccessStateV1.locked);
      expect(controller.state.phase, VaultPhase.loading);
      expect(controller.state.busy, isTrue);
      access.draining!.complete(const Result.success(null));
      await locking;
      expect(controller.state.phase, VaultPhase.locked);
      await controller.close();
      await events.close();
    },
  );

  test('close awaits clipboard cleanup already started by lock', () async {
    final access = _Access();
    final export = _Export();
    final events = StreamController<VaultLockSignal>.broadcast();
    final controller = _controller(access, events.stream, export);
    await controller.init();
    await controller.prepareSetup(password: _password, confirmation: _password);
    await controller.copyRecovery();
    final copied = export.clipboard;
    export.clearing = Completer<void>();
    await controller.lock();
    var closed = false;
    final closing = controller.close().then((_) => closed = true);
    await Future<void>.delayed(Duration.zero);
    expect(closed, isFalse);
    expect(export.clipboard, copied);
    export.clearing!.complete();
    await closing;
    expect(export.clipboard, isEmpty);
    expect(export.clears, 1);
    await events.close();
  });

  testWidgets(
    'cancel prepared recovery returns to unlock and invalidates exports',
    (tester) async {
      final access = _Access();
      access.handle.exists = true;
      access.handle.state = VaultAccessStateV1.locked;
      final export = _Export();
      final events = StreamController<VaultLockSignal>.broadcast();
      final controller = _controller(access, events.stream, export);
      final startup = StartupController(_Startup(), const _Reporter());
      await tester.runAsync(() async {
        await startup.init();
        await controller.init();
      });
      await tester.pumpWidget(WantPassApp(startup: startup, vault: controller));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('vault-dial')));
      await tester.pumpAndSettle();
      await _rejectUnlock(tester, access);
      await tester.tap(find.byKey(const ValueKey('vault-recovery')));
      await tester.pumpAndSettle();
      Finder field(String key) => find.descendant(
        of: find.byKey(ValueKey(key)),
        matching: find.bySubtype<EditableText>(),
      );
      await _enter(
        tester,
        field('recovery-phrase'),
        'synthetic recovery phrase',
      );
      await tester.tap(find.byKey(const ValueKey('setup-next')));
      await tester.pumpAndSettle();
      await _enter(tester, field('master-password'), _password);
      await _enter(tester, field('password-confirmation'), _password);
      await tester.tap(find.byKey(const ValueKey('vault-recover')));
      await tester.pumpAndSettle();
      expect(controller.state.setupChallenge, isNotNull);
      await controller.copyRecovery();
      final saving = controller.downloadRecovery();
      await tester.pump();
      for (var i = 0; i < 2; i++) {
        await tester.tap(find.byKey(const ValueKey('setup-back')));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('Back to unlock'));
      await tester.pumpAndSettle();
      await saving;
      expect(controller.state.phase, VaultPhase.locked);
      expect(controller.state.setupChallenge, isNull);
      expect(access.handle.invalidations, 1);
      expect(find.byKey(const ValueKey('vault-dial')), findsOneWidget);
      expect(find.text('Appearance'), findsNothing);
      expect(export.clipboard, isEmpty);
      export.selection.complete(
        const Result.success('/synthetic/recovery.txt'),
      );
      await tester.pump();
      expect(access.exports, 0);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.runAsync(() async {
        await controller.close();
        await startup.close();
        await events.close();
      });
    },
  );

  testWidgets('clipboard expires conditionally and lock clears our copy', (
    tester,
  ) async {
    final access = _Access();
    final export = _Export();
    final events = StreamController<VaultLockSignal>.broadcast();
    final controller = _controller(access, events.stream, export);
    await tester.runAsync(controller.init);
    await controller.prepareSetup(password: _password, confirmation: _password);
    await controller.copyRecovery();
    expect(export.clipboard, controller.state.setupChallenge!.json);
    await tester.pump(const Duration(seconds: 59));
    expect(export.clipboard, controller.state.setupChallenge!.json);
    export.clipboard = 'other application';
    await tester.pump(const Duration(seconds: 1));
    expect(export.clipboard, 'other application');
    await controller.copyRecovery();
    await controller.lock();
    await tester.pump();
    expect(export.clipboard, '');
    await tester.runAsync(() async {
      await controller.close();
      await events.close();
    });
  });
  testWidgets(
    'setup gates acknowledgments, preserves Back and replaces a failed quiz',
    (tester) async {
      final access = _Access();
      final events = StreamController<VaultLockSignal>.broadcast();
      final controller = _controller(access, events.stream);
      final startup = StartupController(_Startup(), const _Reporter());
      await tester.runAsync(() async {
        await startup.init();
        await controller.init();
      });
      await tester.pumpWidget(WantPassApp(startup: startup, vault: controller));
      await tester.pumpAndSettle();
      Finder field(String key) => find.descendant(
        of: find.byKey(ValueKey(key)),
        matching: find.bySubtype<EditableText>(),
      );
      await _enter(tester, field('master-password'), _password);
      await _enter(tester, field('password-confirmation'), _password);
      await _tapKey(tester, 'vault-create');
      final first = controller.state.setupChallenge;
      expect(find.text('Password hint'), findsOneWidget);
      expect(
        tester
            .widget<WantButton>(find.byKey(const ValueKey('setup-next')))
            .onPressed,
        isNull,
      );
      await _tapKey(tester, 'password-saved');
      await _tapKey(tester, 'setup-back');
      expect(
        tester.widget<EditableText>(field('master-password')).controller.text,
        _password,
      );
      final passwordField = tester
          .widget<EditableText>(field('master-password'))
          .controller;
      passwordField.selection = const TextSelection.collapsed(offset: 0);
      await tester.pump();
      expect(controller.state.passwordSaved, isTrue);
      await _tapKey(tester, 'vault-create');
      expect(controller.state.setupChallenge, first);
      expect(controller.state.passwordSaved, isTrue);
      await _tapKey(tester, 'setup-back');
      await _enter(tester, field('master-password'), '$_password changed');
      expect(controller.state.passwordSaved, isFalse);
      await _enter(tester, field('master-password'), _password);
      await _tapKey(tester, 'vault-create');
      expect(controller.state.setupChallenge, first);
      expect(controller.state.passwordSaved, isFalse);
      await _tapKey(tester, 'password-saved');
      await _tapKey(tester, 'setup-next');
      await _tapKey(tester, 'recovery-qr');
      expect(find.text('Recovery QR'), findsNothing);
      expect(find.byKey(const ValueKey('recovery-qr-image')), findsOneWidget);
      await controller.lock();
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('recovery-qr-image')), findsNothing);
      expect(controller.state.setupChallenge, isNull);
      await _enter(tester, field('master-password'), _password);
      await _enter(tester, field('password-confirmation'), _password);
      await _tapKey(tester, 'vault-create');
      await _tapKey(tester, 'password-saved');
      await _tapKey(tester, 'setup-next');
      await _tapKey(tester, 'recovery-qr');
      await _tapKey(tester, 'qr-saved');
      expect(controller.state.phraseSaved, isTrue);
      expect(controller.state.lossAccepted, isFalse);
      await _tapKey(tester, 'setup-next');
      expect(
        tester
            .widget<WantButton>(find.byKey(const ValueKey('setup-next')))
            .onPressed,
        isNull,
      );
      await _tapKey(tester, 'recovery-loss-accepted');
      await _tapKey(tester, 'setup-next');
      await _tapKey(tester, 'quiz-0-wrong-one');
      expect(controller.state.setupChallenge!.revision, isNot(first!.revision));
      expect(controller.state.passwordSaved, isTrue);
      expect(controller.state.phraseSaved, isFalse);
      expect(controller.state.lossAccepted, isFalse);
      expect(controller.state.quizPassed, everyElement(isFalse));
      expect(find.text('Save the new phrase'), findsOneWidget);
      await tester.tap(find.text('Continue').last);
      await tester.pumpAndSettle();
      await _tapKey(tester, 'setup-next');
      await _tapKey(tester, 'phrase-saved');
      await _tapKey(tester, 'recovery-loss-accepted');
      await _tapKey(tester, 'setup-next');
      for (var i = 0; i < 3; i++) {
        await _tapKey(tester, 'quiz-$i-${['one', 'two', 'three'][i]}');
        await _tapKey(tester, i == 2 ? 'vault-confirm' : 'setup-next');
      }
      expect(controller.state.phase, VaultPhase.unlocked);
      await _tapKey(tester, 'vault-dial');
      expect(controller.state.phase, VaultPhase.locked);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.runAsync(() async {
        await controller.close();
        await startup.close();
        await events.close();
      });
    },
  );

  test('all quiz failures clear acknowledgments and a failed regeneration blocks confirmation', () async {
    for (var index = 0; index < 3; index++) {
      final access = _Access();
      final events = StreamController<VaultLockSignal>.broadcast();
      final controller = _controller(access, events.stream);
      await controller.init();
      await controller.prepareSetup(
        password: _password,
        confirmation: _password,
      );
      controller.acknowledge(password: true, phrase: true, loss: true);
      for (var i = 0; i < index; i++) {
        await controller.chooseSetupWord(i, ['one', 'two', 'three'][i]);
      }
      final old = controller.state.setupChallenge!;
      await controller.chooseSetupWord(index, 'wrong-one');
      expect(controller.state.setupChallenge!.revision, isNot(old.revision));
      expect(controller.state.passwordSaved, isTrue);
      expect(controller.state.phraseSaved, isFalse);
      expect(controller.state.quizPassed, everyElement(isFalse));
      access.regenerationFailure = const VaultRejectedErrorV1(
        VaultFailureKindV1.unavailable,
      );
      await controller.chooseSetupWord(0, 'wrong-one');
      expect(controller.state.setupChallenge, isNull);
      expect(controller.state.error, isNotNull);
      await controller.confirmSetup(
        answers: const ['one', 'two', 'three'],
        password: _password,
        hints: const VaultHintsDtoV2(),
      );
      expect(access.handle.exists, isFalse);
      await controller.close();
      await events.close();
    }
  });

  testWidgets(
    'header appearance menus persist and fit narrow enlarged Russian layout',
    (tester) async {
      await _loadFonts(tester);

      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1024, 768);
      tester.platformDispatcher.localesTestValue = const [Locale('en')];
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final events = StreamController<VaultLockSignal>.broadcast();
      final controller = _controller(_Access(), events.stream);
      final startup = StartupController(_Startup(), const _Reporter());
      final preferences = _AppearancePreferences();
      final appearance = AppearanceController(
        AppearanceUseCaseImpl(preferences, const _Reporter()),
        const _Reporter(),
      );
      await tester.runAsync(() async {
        await startup.init();
        await controller.init();
        await appearance.init();
      });
      final boundary = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundary,
          child: WantPassApp(
            startup: startup,
            vault: controller,
            appearance: appearance,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Appearance'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('appearance-theme')));
      await tester.pumpAndSettle();
      expect(find.text('System'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();
      expect(appearance.state.settings.theme, AppearanceThemeV1.dark);
      final segmentWidth = tester
          .getSize(find.byKey(const ValueKey('setup-segment-0')))
          .width;
      for (var step = 1; step < 8; step++) {
        expect(
          tester.getSize(find.byKey(ValueKey('setup-segment-$step'))).width,
          closeTo(segmentWidth, .01),
        );
      }
      final future = tester.widget<AnimatedContainer>(
        find.byKey(const ValueKey('setup-segment-7')),
      );
      expect(
        (future.decoration! as BoxDecoration).color,
        WantThemeData.dark().color('muted-foreground'),
      );
      await _capture(tester, boundary, 'desktop-dark-en');
      // Cached asset callbacks must also run outside fake async.
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();
      expect(find.byType(WantSvg3D), findsOneWidget);
      expect(find.byType(WantGlow), findsNothing);
      for (final card in tester.widgetList<WantCard>(find.byType(WantCard))) {
        expect(card.hoverEffect, isFalse);
      }
      expect(
        find.descendant(
          of: find.byType(WantSvg3D),
          matching: find.byType(Image),
        ),
        findsNothing,
      );
      await tester.tap(find.byKey(const ValueKey('appearance-language')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('🇷🇺 Русский'));
      await tester.pumpAndSettle();
      expect(appearance.state.settings.language, AppearanceLanguageV1.ru);
      await tester.tap(find.byKey(const ValueKey('appearance-theme')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Светлая'));
      await tester.pumpAndSettle();
      expect(appearance.state.settings.theme, AppearanceThemeV1.light);
      await tester.tap(find.byKey(const ValueKey('setup-next')));
      await tester.pumpAndSettle();
      expect(appearance.state.settings.configured, isTrue);
      tester.view.physicalSize = const Size(320, 800);
      tester.platformDispatcher.textScaleFactorTestValue = 1.8;
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Мастер-пароль'), findsWidgets);
      await _capture(tester, boundary, 'narrow-light-ru');
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.runAsync(() async {
        await controller.close();
        await startup.close();
        await appearance.close();
        await events.close();
      });
      expect(preferences.saved.configured, isTrue);
    },
  );
  testWidgets(
    'recovery blocks empty input, waits for authentication and submits once',
    (tester) async {
      final access = _Access();
      access.handle.exists = true;
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
      await _tapKey(tester, 'vault-dial');
      await _rejectUnlock(tester, access);
      await _tapKey(tester, 'vault-recovery');
      expect(
        tester
            .widget<WantButton>(find.byKey(const ValueKey('setup-next')))
            .onPressed,
        isNull,
      );
      final field = find.descendant(
        of: find.byKey(const ValueKey('recovery-phrase')),
        matching: find.bySubtype<EditableText>(),
      );
      const input = '{\n"1":"one",\n"2":"two"\n}';
      await _enter(tester, field, input);
      expect(tester.widget<EditableText>(field).controller.text, input);
      access.validation = Completer<DomainResult<void>>();
      await tester.tap(find.byKey(const ValueKey('setup-next')));
      await tester.tap(find.byKey(const ValueKey('setup-next')));
      await tester.pump();
      expect(access.validations, 1);
      expect(controller.state.busy, isTrue);
      expect(find.text('Recovery phrase'), findsOneWidget);
      access.validation!.complete(
        const Result.error(
          VaultRejectedErrorV1(VaultFailureKindV1.invalidPhrase),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Recovery phrase'), findsOneWidget);
      access.validation = null;
      access.validationFailure = null;
      await _tapKey(tester, 'setup-next');
      expect(find.text('New master password'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(() async {
        await controller.close();
        await startup.close();
        await events.close();
      });
    },
  );

  test(
    'mutation lock errors preserve a pending automatic hints load',
    () async {
      final access = _Access();
      access.handle
        ..exists = true
        ..state = VaultAccessStateV1.unlocked;
      final events = StreamController<VaultLockSignal>.broadcast();
      addTearDown(events.close);
      final controller = _controller(access, events.stream);
      addTearDown(controller.close);
      await controller.init();
      expect(controller.state.phase, VaultPhase.unlocked);
      await controller.loadContent();
      access.contentFailure = const VaultRejectedErrorV1(
        VaultFailureKindV1.stale,
      );
      access.hintsReply = Completer<DomainResult<VaultHintsDtoV2>>();
      final subscription = controller.stream.listen((state) {
        if (state.phase == VaultPhase.locked && !state.busy) {
          unawaited(controller.readHints());
        }
      });
      addTearDown(() async {
        await subscription.cancel();
        if (!access.hintsReply!.isCompleted) {
          access.hintsReply!.complete(const Result.success(VaultHintsDtoV2()));
        }
      });
      await controller.saveGroup(const GroupDraftV1(name: 'Fixture group'));
      await Future<void>.delayed(Duration.zero);
      expect(controller.state.busy, isTrue);
      expect(controller.state.error, access.contentFailure);
      await subscription.cancel();
      access.hintsReply!.complete(const Result.success(VaultHintsDtoV2()));
      await Future<void>.delayed(Duration.zero);
    },
  );
  test(
    'a late mutation lock cannot attach errors to a newer session',
    () async {
      final access = _Access();
      access.handle
        ..exists = true
        ..state = VaultAccessStateV1.unlocked;
      final events = StreamController<VaultLockSignal>.broadcast();
      addTearDown(events.close);
      final controller = _controller(access, events.stream);
      addTearDown(controller.close);
      await controller.init();
      expect(controller.state.phase, VaultPhase.unlocked);
      await controller.loadContent();
      access.contentFailure = const VaultRejectedErrorV1(
        VaultFailureKindV1.stale,
      );
      final oldStatus = Completer<DomainResult<VaultAccessStateV1>>();
      addTearDown(() {
        if (!oldStatus.isCompleted) {
          oldStatus.complete(const Result.success(VaultAccessStateV1.locked));
        }
      });
      access.statusReplies.add(oldStatus);
      final oldSave = controller.saveGroup(
        const GroupDraftV1(name: 'Fixture group'),
      );
      for (var i = 0; i < 20 && access.statusReplies.isNotEmpty; i++) {
        await Future<void>.delayed(Duration.zero);
      }
      expect(access.statusReplies, isEmpty);
      await controller.lock();
      await controller.unlock(_password);
      oldStatus.complete(const Result.success(VaultAccessStateV1.locked));
      await oldSave;
      expect(controller.state.phase, VaultPhase.unlocked);
      expect(controller.state.error, isNull);
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

VaultController _controller(
  _Access access,
  Stream<VaultLockSignal> events, [
  RecoveryExportService? export,
]) => VaultController(
  VaultUseCaseImpl(
    access,
    const _Reporter(),
    export ?? const PlatformRecoveryExportService(_Reporter()),
    const PlatformGroupLogoService(_Reporter()),
  ),
  const _Reporter(),
  events,
);

final class _Handle implements VaultHandleV1 {
  VaultAccessStateV1 state = VaultAccessStateV1.missing;
  bool exists = false;
  int invalidations = 0;
  int closes = 0;
  @override
  void invalidateSync() {
    invalidations++;
    state = exists ? VaultAccessStateV1.locked : VaultAccessStateV1.missing;
  }

  @override
  Future<void> close() async {
    closes++;
    invalidateSync();
  }
}

final class _Access implements VaultAccessService {
  @override
  FutureDomainResult<ContentSnapshotV1> contentV1({
    required VaultHandleV1 handle,
  }) async => Result.success(
    ContentSnapshotV1(
      revision: BigInt.zero,
      groups: const [],
      accounts: const [],
    ),
  );
  @override
  FutureDomainResult<ContentSnapshotV1> saveGroupV1({
    required VaultHandleV1 handle,
    required GroupDraftV1 input,
    required BigInt revision,
  }) async => Result.error(
    contentFailure ??
        const VaultRejectedErrorV1(VaultFailureKindV1.unavailable),
  );
  @override
  FutureDomainResult<ContentSnapshotV1> deleteGroupV1({
    required VaultHandleV1 handle,
    required String id,
    required BigInt revision,
  }) async =>
      const Result.error(VaultRejectedErrorV1(VaultFailureKindV1.unavailable));
  @override
  FutureDomainResult<AccountV1> accountV1({
    required VaultHandleV1 handle,
    required String id,
  }) async =>
      const Result.error(VaultRejectedErrorV1(VaultFailureKindV1.unavailable));
  @override
  FutureDomainResult<ContentSnapshotV1> saveAccountV1({
    required VaultHandleV1 handle,
    required AccountDraftV1 input,
    required BigInt revision,
  }) async =>
      const Result.error(VaultRejectedErrorV1(VaultFailureKindV1.unavailable));
  @override
  FutureDomainResult<ContentSnapshotV1> deleteAccountV1({
    required VaultHandleV1 handle,
    required String id,
    required BigInt revision,
  }) async =>
      const Result.error(VaultRejectedErrorV1(VaultFailureKindV1.unavailable));

  VaultErrorV1? contentFailure;
  Completer<DomainResult<VaultHintsDtoV2>>? hintsReply;
  BigInt revision = BigInt.zero;
  VaultErrorV1? regenerationFailure;
  VaultErrorV1? validationFailure;
  Completer<DomainResult<void>>? validation;
  int validations = 0;
  @override
  FutureDomainResult<void> validateRecoveryV3({
    required VaultHandleV1 handle,
    required String phrase,
  }) {
    validations++;
    return validation?.future ??
        Future.value(
          validationFailure == null
              ? const Result.success(null)
              : Result.error(validationFailure!),
        );
  }

  @override
  FutureDomainResult<VaultRecoveryChallengeV3> prepareCreationV3({
    required VaultHandleV1 handle,
    required String password,
  }) async {
    final result = await prepareCreationV2(handle: handle, password: password);
    if (result.isError) return Result.error(result.error);
    final v = result.value;
    return Result.success(
      VaultRecoveryChallengeV3(
        words: v.words,
        positions: v.positions,
        choices: v.choices,
        json: jsonEncode({
          for (var i = 0; i < v.words.length; i++) '${i + 1}': v.words[i],
        }),
        revision: revision,
      ),
    );
  }

  @override
  FutureDomainResult<VaultRecoveryChallengeV3> prepareRecoveryV3({
    required VaultHandleV1 handle,
    required String phrase,
    required String password,
  }) => prepareCreationV3(handle: handle, password: password);
  @override
  FutureDomainResult<VaultRecoveryChallengeV3> regenerateRecoveryV3({
    required VaultHandleV1 handle,
  }) {
    revision += BigInt.one;
    if (regenerationFailure case final error?) {
      return Future.value(Result.error(error));
    }
    return prepareCreationV3(handle: handle, password: _password);
  }

  @override
  FutureDomainResult<void> confirmV3({
    required VaultHandleV1 handle,
    required List<String> answers,
    required String password,
    required VaultHintsDtoV2 hints,
    required BigInt revision,
  }) => confirmV2(
    handle: handle,
    answers: answers,
    password: password,
    hints: hints,
  );
  @override
  FutureDomainResult<void> exportRecoveryV3({
    required VaultHandleV1 handle,
    required String destination,
    required BigInt revision,
  }) => exportRecoveryV2(handle: handle, destination: destination);

  Completer<DomainResult<void>>? draining;
  @override
  FutureDomainResult<void> waitForExportsV2({required VaultHandleV1 handle}) =>
      draining?.future ?? Future.value(const Result.success(null));

  @override
  FutureDomainResult<VaultHintsDtoV2> hintsV2({
    required VaultHandleV1 handle,
  }) =>
      hintsReply?.future ??
      Future.value(const Result.success(VaultHintsDtoV2()));
  @override
  FutureDomainResult<VaultRecoveryChallengeV2> prepareCreationV2({
    required VaultHandleV1 handle,
    required String password,
  }) async {
    final result = await prepareCreationV1(handle: handle, password: password);
    if (result.isError) return Result.error(result.error);
    return Result.success(
      VaultRecoveryChallengeV2(
        words: result.value.words,
        positions: result.value.positions,
        choices: List.unmodifiable(
          result.value.positions.map(
            (i) => List<String>.unmodifiable([
              result.value.words[i],
              'wrong-one',
              'wrong-two',
            ]),
          ),
        ),
      ),
    );
  }

  @override
  FutureDomainResult<VaultRecoveryChallengeV2> prepareRecoveryV2({
    required VaultHandleV1 handle,
    required String phrase,
    required String password,
  }) => prepareCreationV2(handle: handle, password: password);
  @override
  FutureDomainResult<void> confirmV2({
    required VaultHandleV1 handle,
    required List<String> answers,
    required String password,
    required VaultHintsDtoV2 hints,
  }) => confirmV1(handle: handle, answers: answers);
  @override
  FutureDomainResult<void> exportRecoveryV2({
    required VaultHandleV1 handle,
    required String destination,
  }) async {
    exports++;
    return const Result.success(null);
  }

  final handle = _Handle();
  int opens = 0;
  int preparations = 0;
  int exports = 0;
  final passwords = <String>[];
  final preparedPasswords = <String>[];
  final statusReplies = <Completer<DomainResult<VaultAccessStateV1>>>[];
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
  }) => statusReplies.isEmpty
      ? Future.value(Result.success(this.handle.state))
      : statusReplies.removeAt(0).future;
  @override
  FutureDomainResult<VaultRecoveryChallengeV1> prepareCreationV1({
    required VaultHandleV1 handle,
    required String password,
  }) {
    preparations++;
    preparedPasswords.add(password);
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
    this.handle.exists = true;
    this.handle.state = VaultAccessStateV1.unlocked;
    return const Result.success(null);
  }

  Completer<DomainResult<bool>>? passwordCheck;
  @override
  FutureDomainResult<bool> validatePasswordV3({required String password}) =>
      passwordCheck?.future ??
      Future.value(
        Result.success(password.length >= 15 && password.contains('!')),
      );
  @override
  FutureDomainResult<void> unlockV3({
    required VaultHandleV1 handle,
    required String password,
  }) => unlockV1(handle: handle, password: password);

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

Future<void> _enter(WidgetTester tester, Finder field, String value) async {
  await tester.ensureVisible(field);
  await tester.tap(field);
  await tester.pump();
  expect(
    tester.state<EditableTextState>(field).widget.focusNode.hasFocus,
    isTrue,
  );
  // WidgetTester.showKeyboard matches only the exact EditableText runtime type.
  tester.testTextInput.enterText(value);
  await tester.pump();
}

final class _Export implements RecoveryExportService {
  final selection = Completer<DomainResult<String?>>();
  String clipboard = '';
  Completer<void>? clearing;
  int clears = 0;
  @override
  FutureDomainResult<String?> selectFileV1() => selection.future;
  @override
  FutureDomainResult<String?> selectFileV3() => selection.future;
  @override
  FutureDomainResult<void> copyV1(String phrase) async {
    clipboard = phrase;
    return const Result.success(null);
  }

  @override
  FutureDomainResult<void> clearClipboardV1(String expected) async {
    clears++;
    await clearing?.future;
    if (clipboard == expected) clipboard = '';
    return const Result.success(null);
  }
}

final class _AppearancePreferences implements AppearancePreferencesService {
  AppearanceSettingsV1 saved = const AppearanceSettingsV1();
  @override
  FutureDomainResult<AppearanceSettingsV1> loadV1() async =>
      Result.success(saved);
  @override
  FutureDomainResult<void> saveV1(AppearanceSettingsV1 settings) async {
    saved = settings;
    return const Result.success(null);
  }
}

Future<void> _capture(WidgetTester tester, GlobalKey key, String name) async {
  const directory = String.fromEnvironment('VAULT_VISUAL_DIR');
  if (directory.isEmpty) return;
  await tester.runAsync(() async {
    for (final path in [
      'assets/brand/logo-dark.png',
      'assets/brand/logo-light.png',
    ]) {
      await precacheImage(AssetImage(path), key.currentContext!);
    }
  });
  await tester.pump();
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    try {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await File('$directory/$name.png')
          .writeAsBytes(bytes!.buffer.asUint8List(), flush: true);
    } finally {
      image.dispose();
    }
  });
}

Future<void> _tapKey(WidgetTester tester, String key) async {
  final target = find.byKey(ValueKey(key));
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> _rejectUnlock(WidgetTester tester, _Access access) async {
  final previous = access.failure;
  access.failure = const VaultRejectedErrorV1(VaultFailureKindV1.credentials);
  try {
    final input = find.descendant(
      of: find.byKey(const ValueKey('unlock-password')),
      matching: find.bySubtype<EditableText>(),
    );
    await _enter(tester, input, _password);
    await _tapKey(tester, 'vault-unlock');
    expect(access.passwords.last, _password);
  } finally {
    access.failure = previous;
  }
}

Future<void> _loadFonts(WidgetTester tester) async {
  await tester.runAsync(() async {
    // Load outside fake async so asset futures cannot outlive an earlier test.
    rootBundle.evict('assets/brand/logo.svg');
    await rootBundle.loadString('assets/brand/logo.svg');
    for (final (family, asset) in [
      (
        'packages/want_allure/Days One',
        'packages/want_allure/assets/fonts/DaysOne-Regular.ttf',
      ),
      (
        'packages/want_allure/Manrope',
        'packages/want_allure/assets/fonts/Manrope.ttf',
      ),
      (
        'packages/phosphoricons_flutter/PhosphorRegular',
        'packages/phosphoricons_flutter/lib/fonts/Phosphor.ttf',
      ),
      (
        'packages/forui_lucide/ForuiLucideIcons',
        'packages/forui_lucide/assets/lucide.ttf',
      ),
    ]) {
      final loader = FontLoader(family)..addFont(rootBundle.load(asset));
      await loader.load();
    }
  });
}
