import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
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
    addTearDown(fixture.close);
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
    await _enter(tester, 'account-login', 'fixture@example.invalid');
    await _togglePassword(tester);
    await _enter(tester, 'account-password', 'fixture\npassword');
    await _togglePassword(tester);
    await _tap(tester, 'account-group-${first.id}');
    await _tap(tester, 'account-group-${second.id}');
    await _tap(tester, 'account-save');
    await _idle(tester, controller);
    final account = controller.state.content!.accounts.single;
    final detail = await tester.runAsync(
      () => controller.readAccount(account.id),
    );
    expect(detail!.password, 'fixture\npassword');
    expect(account.groupIds.toSet(), {first.id, second.id});
    await _tap(tester, 'group-edit-${first.id}');
    await _tap(tester, 'group-delete');
    await _tap(tester, 'delete-cancel');
    expect(controller.state.content!.groups.length, 2);
    expect(controller.state.content!.accounts.single.groupIds.length, 2);
    await _tap(tester, 'group-edit-${first.id}');
    await _tap(tester, 'group-delete');
    await _tap(tester, 'delete-confirm');
    await _idle(tester, controller);
    expect(controller.state.content!.accounts.single.groupIds, [second.id]);
    await _tap(tester, 'account-${account.id}');
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
    await tester.runAsync(fixture.close);
    await _pump(tester);
  });
  testWidgets('narrow forms support large text and cancel without saving', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final fixture = (await tester.runAsync(_Fixture.create))!;
    addTearDown(fixture.close);
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
    expect(fixture.controller.state.content!.groups, isEmpty);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.runAsync(fixture.close);
    await _pump(tester);
  });

  testWidgets('mouse activity inside an editor renews the idle deadline', (
    tester,
  ) async {
    final fixture = (await tester.runAsync(_Fixture.create))!;
    addTearDown(fixture.close);
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
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.runAsync(fixture.close);
  });
  testWidgets('locking discards a late logo selection', (tester) async {
    final logos = _PendingLogoService();
    final fixture = (await tester.runAsync(
      () => _Fixture.create(logos: logos),
    ))!;
    addTearDown(fixture.close);
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
    await tester.runAsync(fixture.close);
  });
}

Future<void> _pump(WidgetTester tester) async {
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
  final finder = find.byKey(ValueKey(key));
  await tester.ensureVisible(finder);
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
  static Future<_Fixture> create({GroupLogoService? logos}) async {
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
