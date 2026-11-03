import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:domain_error/domain_error.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:launch_mode/launch_mode.dart';
import 'package:want_allure/want_allure.dart';
import 'package:want_pass/src/feature/vault/application/_barrel.dart';
import 'package:want_pass/src/feature/vault/infrastructure/_barrel.dart';
import 'package:want_pass/src/feature/vault/presentation/_barrel.dart';
import 'package:want_pass_core/want_pass_core.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  LaunchMode.initializeAutomatically();
  testWidgets('forms manage memberships, cancel deletion and close on lock', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final fixture = await tester.runAsync(
      () => _Fixture.create(logos: _FixedLogoService()),
    );
    final controller = fixture!.controller;
    addTearDown(() async {
      await _closeFixture(tester, fixture);
    });
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => WantTheme(
          data: WantThemeData.light(),
          child: WantToaster(child: child!),
        ),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: VaultContentView(controller: controller),
          ),
        ),
      ),
    );
    await _pump(tester);
    await _tap(tester, 'group-create');
    await _enter(tester, 'group-name', 'Fixture project');
    await _tap(tester, 'group-logo-select');
    await _idle(tester, controller);
    await _tap(tester, 'group-save');
    await _idle(tester, controller);
    final first = controller.state.content!.groups.single;
    expect(first.logo, _logo);
    await tester.runAsync(
      () => controller.saveGroup(const GroupDraftV1(name: 'Fixture company')),
    );
    await _pump(tester);
    final second = controller.state.content!.groups.last;
    await _tap(tester, 'account-create');
    await _enter(tester, 'account-name', 'Fixture account');
    await _tap(tester, 'card-service');
    await tester.tap(find.text('GitHub').last);
    await _pump(tester);
    await tester.tap(find.text('Details (optional)'));
    await _pump(tester);
    await _tap(tester, 'card-environment');
    await tester.ensureVisible(find.text('production').last);
    await tester.tap(find.text('production').last);
    await _pump(tester);
    await _enter(tester, 'account-login', 'fixture@example.invalid');
    await _togglePassword(tester);
    await _enter(tester, 'account-password', 'fixture\npassword');
    await _togglePassword(tester);
    expect(
      tester
          .widget<WantButton>(find.byKey(ValueKey('account-group-${first.id}')))
          .variant,
      WantButtonVariant.primary,
    );
    await _tap(tester, 'account-group-${second.id}');
    await _tap(tester, 'account-save');
    await _idle(tester, controller);
    final account = controller.state.content!.cards.single;
    expect(account.environment, EnvironmentV1.production);
    expect(account.service, 'github');
    final detail = await tester.runAsync(() => controller.readCard(account.id));
    expect(
      detail!.fields.firstWhere((f) => f.id == FieldIdV1.password).value,
      'fixture\npassword',
    );
    expect(account.groupIds.toSet(), {first.id, second.id});
    await _tap(tester, 'group-edit-${first.id}');
    await _tap(tester, 'group-delete');
    await _tap(tester, 'delete-cancel');
    expect(controller.state.content!.groups.length, 2);
    expect(controller.state.content!.cards.single.groupIds.length, 2);
    await _tap(tester, 'group-edit-${first.id}');
    await _tap(tester, 'group-delete');
    await _tap(tester, 'delete-confirm');
    await _idle(tester, controller);
    expect(controller.state.content!.cards.single.groupIds, [second.id]);
    await _tap(tester, 'account-${account.id}');
    await _tap(tester, 'card-edit');
    await _idle(tester, controller);
    expect(find.byKey(const ValueKey('account-password')), findsOneWidget);
    final field = tester.widget<EditableText>(
      find.descendant(
        of: find.byKey(const ValueKey('account-password')),
        matching: find.byType(EditableText),
      ),
    );
    expect(field.obscureText, isTrue);
    await tester.runAsync(controller.lock);
    await _pump(tester);
    expect(find.byKey(const ValueKey('account-password')), findsNothing);
    expect(find.text('Fixture account'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await _closeFixture(tester, fixture);
    await _pump(tester);
  });
  testWidgets(
    'developer preset fields remain concealed and omit account copy all',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final fixture = (await tester.runAsync(_Fixture.create))!;
      addTearDown(() async {
        await _closeFixture(tester, fixture);
      });
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => WantTheme(
            data: WantThemeData.light(),
            child: WantToaster(child: child!),
          ),
          home: Scaffold(
            body: VaultContentView(controller: fixture.controller),
          ),
        ),
      );
      await _pump(tester);
      await _tap(tester, 'account-create');
      await _tap(tester, 'card-type');
      await tester.ensureVisible(find.text('PAT').last);
      await tester.tap(find.text('PAT').last);
      await _pump(tester);
      await _enter(tester, 'account-name', 'Synthetic PAT');
      await _tap(tester, 'card-service');
      await tester.ensureVisible(find.text('GitHub').last);
      await tester.tap(find.text('GitHub').last);
      await _pump(tester);
      final toggle = find.descendant(
        of: find.byKey(const ValueKey('card-field-value')),
        matching: find.byType(FButton),
      );
      await tester.ensureVisible(toggle);
      await tester.tap(toggle);
      await _pump(tester);
      await _enter(tester, 'card-field-value', ' synthetic token ');
      await _tap(tester, 'account-save');
      await _idle(tester, fixture.controller);
      final card = fixture.controller.state.content!.cards.single;
      expect(card.cardType, CardTypeV1.pat);
      await _tap(tester, 'account-${card.id}');
      await _tap(tester, 'card-edit');
      await _idle(tester, fixture.controller);
      expect(find.byKey(const ValueKey('card-copy-all')), findsNothing);
      final input = tester.widget<EditableText>(
        find.descendant(
          of: find.byKey(const ValueKey('card-field-value')),
          matching: find.byType(EditableText),
        ),
      );
      expect(input.obscureText, isTrue);
      expect(input.autocorrect, isFalse);
      expect(input.enableSuggestions, isFalse);
      await tester.runAsync(fixture.controller.lock);
      await _pump(tester);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  testWidgets('lock discards a late secret file selection', (tester) async {
    final files = _PendingFileService();
    final fixture = (await tester.runAsync(
      () => _Fixture.create(files: files),
    ))!;
    addTearDown(() async {
      await _closeFixture(tester, fixture);
    });
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => WantTheme(
          data: WantThemeData.light(),
          child: WantToaster(child: child!),
        ),
        home: Scaffold(body: VaultContentView(controller: fixture.controller)),
      ),
    );
    await _pump(tester);
    await _tap(tester, 'account-create');
    await _tap(tester, 'card-type');
    await tester.ensureVisible(find.text('Secure file').last);
    await tester.tap(find.text('Secure file').last);
    await _pump(tester);
    await _tap(tester, 'card-file-select');
    expect(fixture.controller.state.busy, isTrue);
    await tester.runAsync(fixture.controller.lock);
    await _pump(tester);
    files.reply.complete(
      const Result.success(
        AttachmentDraftV1(name: 'synthetic.bin', bytes: [0, 1, 255]),
      ),
    );
    await _pump(tester);
    expect(find.byKey(const ValueKey('card-file-select')), findsNothing);
    expect(fixture.controller.state.content, isNull);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('narrow forms support large text and cancel without saving', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final fixture = (await tester.runAsync(_Fixture.create))!;
    addTearDown(() async {
      await _closeFixture(tester, fixture);
    });
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: WantTheme(
            data: WantThemeData.light(),
            child: WantToaster(child: child!),
          ),
        ),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: VaultContentView(controller: fixture.controller),
          ),
        ),
      ),
    );
    await _pump(tester);
    await _tap(tester, 'group-create');
    await _enter(tester, 'group-name', 'Narrow fixture');
    await _tap(tester, 'content-cancel');
    await _tap(tester, 'discard-changes');
    expect(fixture.controller.state.content!.groups, isEmpty);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await _closeFixture(tester, fixture);
    await _pump(tester);
  });

  testWidgets(
    'checked TOTP with an empty seed preserves the saved configuration',
    (tester) async {
      final fixture = (await tester.runAsync(_Fixture.create))!;
      addTearDown(() async {
        await _closeFixture(tester, fixture);
      });
      final controller = fixture.controller;
      const seed = 'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ';
      await tester.runAsync(
        () => controller.saveCard(
          const CardDraftV1(
            name: 'TOTP edit fixture',
            description: '',
            service: 'github',
            cardType: CardTypeV1.account,
            groupIds: [],
            fields: [
              CardFieldDraftV1(
                id: FieldIdV1.login,
                value: 'fixture@example.invalid',
              ),
              CardFieldDraftV1(
                id: FieldIdV1.password,
                value: 'Synthetic password',
              ),
              CardFieldDraftV1(id: FieldIdV1.totpSeed, value: seed),
            ],
          ),
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => WantTheme(
            data: WantThemeData.light(),
            child: WantToaster(child: child!),
          ),
          home: Scaffold(body: VaultContentView(controller: controller)),
        ),
      );
      await _pump(tester);
      final id = controller.state.content!.cards.single.id;
      await _tap(tester, 'account-$id');
      await _tap(tester, 'card-edit');
      await _idle(tester, controller);
      final toggle = find.descendant(
        of: find.byKey(const ValueKey('card-field-totpSeed')),
        matching: find.byType(FButton),
      );
      await tester.ensureVisible(toggle);
      await tester.tap(toggle);
      await _pump(tester);
      await _enter(tester, 'card-field-totpSeed', '');
      await _tap(tester, 'account-save');
      await _idle(tester, controller);
      final error = controller.state.error;
      final editing = find
          .byKey(const ValueKey('account-save'))
          .evaluate()
          .isNotEmpty;
      final saved = await tester.runAsync(() => controller.readCard(id));
      await tester.pumpWidget(const SizedBox.shrink());
      await _closeFixture(tester, fixture);
      expect(error, isA<VaultRejectedErrorV1>());
      expect(editing, isTrue);
      expect(
        saved!.fields
            .where((f) => f.id == FieldIdV1.totpSeed)
            .firstOrNull
            ?.value,
        seed,
      );
    },
  );

  testWidgets(
    'pending replacement attachment cannot export the previous file',
    (tester) async {
      final fixture = (await tester.runAsync(
        () => _Fixture.create(files: _ReplacementFileService()),
      ))!;
      addTearDown(() async {
        await _closeFixture(tester, fixture);
      });
      final controller = fixture.controller;
      await tester.runAsync(
        () => controller.saveCard(
          const CardDraftV1(
            name: 'File edit fixture',
            description: '',
            service: 'other',
            cardType: CardTypeV1.file,
            groupIds: [],
            fields: [],
            attachment: AttachmentDraftV1(name: 'saved.bin', bytes: [1, 2, 3]),
          ),
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => WantTheme(
            data: WantThemeData.light(),
            child: WantToaster(child: child!),
          ),
          home: Scaffold(body: VaultContentView(controller: controller)),
        ),
      );
      await _pump(tester);
      await _tap(
        tester,
        'account-${controller.state.content!.cards.single.id}',
      );
      await _tap(tester, 'card-edit');
      await _idle(tester, controller);
      final download = find.byKey(const ValueKey('card-file-download'));
      expect(tester.widget<WantButton>(download).onPressed, isNotNull);
      await _tap(tester, 'card-file-select');
      await _idle(tester, controller);
      expect(find.text('replacement.bin'), findsOneWidget);
      final action = tester.widget<WantButton>(download).onPressed;
      await tester.pumpWidget(const SizedBox.shrink());
      await _closeFixture(tester, fixture);
      expect(action, isNull);
    },
  );

  testWidgets('expired OTP is hidden before the next refresh', (tester) async {
    final fixture = (await tester.runAsync(_Fixture.create))!;
    addTearDown(() async {
      await _closeFixture(tester, fixture);
    });
    final controller = fixture.controller;
    await tester.runAsync(
      () => controller.saveCard(
        const CardDraftV1(
          name: 'OTP fixture',
          description: '',
          service: 'github',
          cardType: CardTypeV1.account,
          groupIds: [],
          fields: [
            CardFieldDraftV1(
              id: FieldIdV1.login,
              value: 'fixture@example.invalid',
            ),
            CardFieldDraftV1(
              id: FieldIdV1.password,
              value: 'Synthetic password',
            ),
            CardFieldDraftV1(
              id: FieldIdV1.totpSeed,
              value: 'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ',
            ),
            CardFieldDraftV1(id: FieldIdV1.totpPeriod, value: '1'),
          ],
        ),
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => WantTheme(
          data: WantThemeData.light(),
          child: WantToaster(child: child!),
        ),
        home: Scaffold(body: VaultContentView(controller: controller)),
      ),
    );
    await _pump(tester);
    final id = controller.state.content!.cards.single.id;
    await _tap(tester, 'account-$id');
    await _tap(tester, 'card-edit');
    await _idle(tester, controller);
    for (
      var i = 0;
      i < 300 && find.textContaining(RegExp(r'^\d{6}$')).evaluate().isEmpty;
      i++
    ) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump(const Duration(milliseconds: 10));
    }
    expect(find.textContaining(RegExp(r'^\d{6}$')), findsOneWidget);
    final code = (await tester.runAsync(() => controller.readTotp(id)))!;
    final until =
        code.validUntil.difference(DateTime.now().toUtc()) +
        const Duration(milliseconds: 100);
    if (until > Duration.zero) {
      await tester.runAsync(() => Future<void>.delayed(until));
    }
    await tester.enterText(
      find.descendant(
        of: find.byKey(const ValueKey('account-name')),
        matching: find.byType(EditableText),
      ),
      'Edited OTP fixture',
    );
    await tester.pump();
    final expired = find.textContaining(RegExp(r'^\d{6}$')).evaluate().length;
    await tester.pumpWidget(const SizedBox.shrink());
    await _closeFixture(tester, fixture);
    expect(expired, 0);
  });

  testWidgets('mouse activity inside an editor renews the idle deadline', (
    tester,
  ) async {
    final fixture = (await tester.runAsync(_Fixture.create))!;
    addTearDown(() async {
      await _closeFixture(tester, fixture);
    });
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => WantTheme(
          data: WantThemeData.light(),
          child: WantToaster(child: child!),
        ),
        home: Scaffold(body: VaultContentView(controller: fixture.controller)),
      ),
    );
    await _pump(tester);
    await _tap(tester, 'group-create');
    await _enter(tester, 'group-name', 'Active editor fixture');
    // Start the public idle timer in the widget clock.
    fixture.controller.activity();
    await tester.pump(const Duration(minutes: 4));
    await _tap(tester, 'group-name');
    await tester.pump(const Duration(minutes: 2));
    expect(fixture.controller.state.phase, VaultPhase.unlocked);
    expect(find.byKey(const ValueKey('group-name')), findsOneWidget);
    await _tap(tester, 'content-cancel');
    await _tap(tester, 'discard-changes');
    await tester.pumpWidget(const SizedBox.shrink());
    await _closeFixture(tester, fixture);
  });
  testWidgets('locking discards a late logo selection', (tester) async {
    final logos = _PendingLogoService();
    final fixture = (await tester.runAsync(
      () => _Fixture.create(logos: logos),
    ))!;
    addTearDown(() async {
      await _closeFixture(tester, fixture);
    });
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => WantTheme(
          data: WantThemeData.light(),
          child: WantToaster(child: child!),
        ),
        home: Scaffold(body: VaultContentView(controller: fixture.controller)),
      ),
    );
    await _pump(tester);
    await _tap(tester, 'group-create');
    await _tap(tester, 'group-logo-select');
    expect(fixture.controller.state.busy, isTrue);
    await tester.runAsync(fixture.controller.lock);
    await _pump(tester);
    logos.result.complete(const Result.success(<int>[]));
    await _pump(tester);
    expect(fixture.controller.state.phase, VaultPhase.locked);
    expect(fixture.controller.state.content, isNull);
    expect(find.byKey(const ValueKey('group-name')), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await _closeFixture(tester, fixture);
  });
  testWidgets('navigation waits for foreground and lock cancels it', (
    tester,
  ) async {
    final fixture = (await tester.runAsync(_Fixture.create))!;
    addTearDown(() => _closeFixture(tester, fixture));
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) =>
            WantTheme(data: WantThemeData.light(), child: child!),
        home: Scaffold(body: VaultContentView(controller: fixture.controller)),
      ),
    );
    await _pump(tester);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await _tap(tester, 'account-create');
    expect(find.byKey(const ValueKey('account-name')), findsNothing);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await _pump(tester);
    expect(find.byKey(const ValueKey('account-name')), findsOneWidget);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await _tap(tester, 'account-create');
    await tester.runAsync(fixture.controller.lock);
    await _pump(tester);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await _pump(tester);
    expect(find.byKey(const ValueKey('account-name')), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    await _closeFixture(tester, fixture);
    await _pump(tester);
  });

  testWidgets('multiline editor keeps arrow keys for the text caret', (
    tester,
  ) async {
    final fixture = (await tester.runAsync(_Fixture.create))!;
    addTearDown(() => _closeFixture(tester, fixture));
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) =>
            WantTheme(data: WantThemeData.light(), child: child!),
        home: Scaffold(body: VaultContentView(controller: fixture.controller)),
      ),
    );
    await _pump(tester);
    await _tap(tester, 'account-create');
    await _tap(tester, 'card-type');
    await tester.ensureVisible(find.text('Secure note').last);
    await tester.tap(find.text('Secure note').last);
    await _pump(tester);
    final toggle = find.descendant(
      of: find.byKey(const ValueKey('card-field-value')),
      matching: find.byType(FButton),
    );
    await tester.ensureVisible(toggle);
    await tester.tap(toggle);
    await _pump(tester);
    await _enter(tester, 'card-field-value', 'first line\nsecond line');
    final input = tester.widget<EditableText>(
      find.descendant(
        of: find.byKey(const ValueKey('card-field-value')),
        matching: find.byType(EditableText),
      ),
    );
    final before = input.controller.selection.extentOffset;
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await _pump(tester);
    expect(input.controller.selection.extentOffset, lessThan(before));
    expect(find.byKey(const ValueKey('account-save')), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await _closeFixture(tester, fixture);
    await _pump(tester);
  });

  testWidgets('dirty form survives resize and search requires a decision', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final fixture = (await tester.runAsync(_Fixture.create))!;
    addTearDown(() => _closeFixture(tester, fixture));
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) =>
            WantTheme(data: WantThemeData.dark(), child: child!),
        home: Scaffold(body: VaultContentView(controller: fixture.controller)),
      ),
    );
    await _pump(tester);
    await _tap(tester, 'account-create');
    await _enter(tester, 'account-name', 'Unsaved fixture');
    tester.view.physicalSize = const Size(375, 812);
    await _pump(tester);
    expect(find.text('Unsaved fixture'), findsOneWidget);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await _pump(tester);
    expect(find.text('Unsaved changes'), findsOneWidget);
    await tester.tap(find.text('Stay'));
    await _pump(tester);
    expect(find.text('Unsaved fixture'), findsOneWidget);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await _pump(tester);
    await _tap(tester, 'discard-changes');
    final replacement = tester.widget<EditableText>(
      find.descendant(
        of: find.byKey(const ValueKey('account-name')),
        matching: find.byType(EditableText),
      ),
    );
    expect(replacement.controller.text, isEmpty);
    await _enter(tester, 'account-name', 'Replacement draft');
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await _pump(tester);
    await _tap(tester, 'discard-changes');
    expect(find.byKey(const ValueKey('account-name')), findsNothing);
    final search = tester.widget<EditableText>(
      find.descendant(
        of: find.byKey(const ValueKey('vault-search')),
        matching: find.byType(EditableText),
      ),
    );
    expect(search.focusNode.hasFocus, isTrue);
    expect(fixture.controller.state.content!.cards, isEmpty);
    await _tap(tester, 'groups-open');
    await tester.runAsync(fixture.controller.lock);
    await _pump(tester);
    expect(find.byKey(const ValueKey('group-filter-all')), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'workspace searches concealed values, filters and copies from preview',
    (tester) async {
      String? clipboard;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            clipboard =
                (call.arguments as Map<Object?, Object?>)['text']! as String;
          }
          if (call.method == 'Clipboard.getData') {
            return clipboard == null ? null : {'text': clipboard};
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );

      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final fixture = (await tester.runAsync(_Fixture.create))!;
      addTearDown(() async {
        await _closeFixture(tester, fixture);
      });
      final controller = fixture.controller;
      await tester.runAsync(() async {
        await controller.saveGroup(const GroupDraftV1(name: 'Synthetic team'));
        await controller.saveCard(
          CardDraftV1(
            name: 'Synthetic account',
            service: 'github',
            cardType: CardTypeV1.account,
            groupIds: [controller.state.content!.groups.single.id],
            fields: const [
              CardFieldDraftV1(
                id: FieldIdV1.login,
                value: 'table@example.invalid',
              ),
              CardFieldDraftV1(
                id: FieldIdV1.password,
                value: 'Hidden synthetic password',
              ),
              CardFieldDraftV1(
                id: FieldIdV1.totpSeed,
                value: 'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ',
              ),
            ],
          ),
        );
        await controller.saveCard(
          const CardDraftV1(
            name: 'Synthetic token',
            service: 'gitlab',
            cardType: CardTypeV1.pat,
            fields: [
              CardFieldDraftV1(
                id: FieldIdV1.value,
                value: 'Hidden synthetic token',
              ),
            ],
          ),
        );
      });
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => WantTheme(
            data: WantThemeData.dark(),
            child: WantToaster(child: child!),
          ),
          home: Scaffold(body: VaultContentView(controller: controller)),
        ),
      );
      await _pump(tester);
      final group = controller.state.content!.groups.single.id;
      final card = controller.state.content!.cards.first.id;
      await _tap(tester, 'group-filter-$group');
      await _pump(tester);
      expect(find.text('table@example.invalid'), findsOneWidget);
      expect(find.text('Hidden synthetic password'), findsNothing);
      expect(find.text('GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ'), findsNothing);
      await _tap(tester, 'account-$card');
      await _tap(tester, 'preview-copy-password');
      await _idle(tester, controller);
      expect(
        (await tester.runAsync(() => Clipboard.getData(Clipboard.kTextPlain)))!
            .text,
        'Hidden synthetic password',
      );
      await _enter(tester, 'vault-search', 'HIDDEN SYNTHETIC PASSWORD');
      await _pump(tester);
      expect(find.byKey(ValueKey('account-$card')), findsOneWidget);
      expect(find.text('Synthetic token'), findsNothing);
      await _enter(tester, 'vault-search', '');
      await _pump(tester);
      await _tap(tester, 'vault-filters');
      await _tap(tester, 'filter-type');
      await tester.tap(find.text('PAT').last);
      await _pump(tester);
      await _pump(tester);
      for (
        var i = 0;
        i < 30 && find.byType(LinearProgressIndicator).evaluate().isNotEmpty;
        i++
      ) {
        await _pump(tester);
      }
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.byKey(ValueKey('account-$card')), findsNothing);
      await _tap(tester, 'group-filter-none');
      await _pump(tester);
      expect(find.text('Synthetic token'), findsOneWidget);
      await tester.runAsync(controller.lock);
      await _pump(tester);
      expect(find.byKey(const ValueKey('vault-search')), findsNothing);
      expect(find.text('table@example.invalid'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}

Future<void> _closeFixture(WidgetTester tester, _Fixture fixture) async {
  var done = false;
  final closing = fixture.close().whenComplete(() => done = true);
  for (var i = 0; i < 300 && !done; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump();
  }
  expect(done, isTrue, reason: 'Pending native reads did not drain');
  await closing;
}

Future<void> _pump(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 20)),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 350));
  await tester.pump();
}

Future<void> _idle(WidgetTester tester, VaultController controller) async {
  for (var attempt = 0; attempt < 300 && controller.state.busy; attempt++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump(const Duration(milliseconds: 10));
  }
  expect(
    controller.state.busy,
    isFalse,
    reason: 'Content operation did not finish',
  );
  await _pump(tester);
}

Future<void> _tap(WidgetTester tester, String key) async {
  var finder = find.byKey(ValueKey(key));
  if (key.startsWith('group-') &&
      key != 'groups-open' &&
      finder.evaluate().isEmpty) {
    await tester.tap(find.byKey(const ValueKey('groups-open')));
    await _pump(tester);
    finder = find.byKey(ValueKey(key));
  }
  for (var i = 0; i < 40 && finder.evaluate().isEmpty; i++) {
    await _pump(tester);
  }
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await _pump(tester);
}

Future<void> _togglePassword(WidgetTester tester) async {
  final button = find.descendant(
    of: find.byKey(const ValueKey('account-password')),
    matching: find.byType(FButton),
  );
  await tester.ensureVisible(button);
  await tester.tap(button);
  await _pump(tester);
}

Future<void> _enter(WidgetTester tester, String key, String value) async {
  final field = find.descendant(
    of: find.byKey(ValueKey(key)),
    matching: find.byType(EditableText),
  );
  await tester.ensureVisible(field);
  await tester.enterText(field, value);
  await _pump(tester);
}

final class _Fixture {
  final Directory directory;
  final StreamController<VaultLockSignal> events;
  final VaultController controller;
  const _Fixture(this.directory, this.events, this.controller);
  static Future<_Fixture> create({
    GroupLogoService? logos,
    CredentialFileService? files,
  }) async {
    final directory = await Directory.systemTemp.createTemp(
      'want-pass-content-ui-',
    );
    const reporter = _Reporter();
    final access = await initializeVaultAccess(
      directory: '${directory.path}/vault',
      reporter: reporter,
    );
    final events = StreamController<VaultLockSignal>.broadcast();
    final controller = VaultController(
      VaultUseCaseImpl(
        access,
        reporter,
        const PlatformRecoveryExportService(reporter),
        logos ?? const PlatformGroupLogoService(reporter),
        files ?? const PlatformCredentialFileService(reporter),
      ),
      reporter,
      events.stream,
    );
    await controller.init();
    const password = 'Synthetic UI password 2026!';
    await controller.prepareCreation(
      password: password,
      confirmation: password,
    );
    final challenge = controller.state.challenge!;
    await controller.confirm(
      challenge.positions.map((i) => challenge.words[i]).toList(),
    );
    return _Fixture(directory, events, controller);
  }

  Future<void> close() async {
    await controller.close();
    if (!events.isClosed) await events.close();
    if (await directory.exists()) await directory.delete(recursive: true);
  }
}

final class _Reporter implements VaultReporter {
  const _Reporter();
  @override
  void reportVault({
    required VaultDiagnosticLayer layer,
    required String operation,
    required VaultErrorV1 error,
  }) {}
}

final class _PendingLogoService implements GroupLogoService {
  final result = Completer<DomainResult<List<int>?>>();
  @override
  FutureDomainResult<List<int>?> selectV1() => result.future;
}

final _logo = List<int>.unmodifiable(
  base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR4nGP4z8DwHwAFAAH/iZk9HQAAAABJRU5ErkJggg==',
  ),
);

final class _FixedLogoService implements GroupLogoService {
  @override
  FutureDomainResult<List<int>?> selectV1() async => Result.success(_logo);
}

final class _PendingFileService implements CredentialFileService {
  final reply = Completer<DomainResult<AttachmentDraftV1?>>();
  @override
  FutureDomainResult<AttachmentDraftV1?> selectAttachmentV1() => reply.future;
  @override
  FutureDomainResult<String?> selectDestinationV1(String name) async =>
      const Result.success(null);
}

final class _ReplacementFileService implements CredentialFileService {
  @override
  FutureDomainResult<AttachmentDraftV1?> selectAttachmentV1() async =>
      const Result.success(
        AttachmentDraftV1(name: 'replacement.bin', bytes: [4, 5]),
      );
  @override
  FutureDomainResult<String?> selectDestinationV1(String name) async =>
      const Result.success(null);
}
