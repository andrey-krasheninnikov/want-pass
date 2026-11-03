import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:launch_mode/launch_mode.dart';
import 'package:path_provider/path_provider.dart';
import 'package:want_pass/src/core/_barrel.dart';
import 'package:want_pass/src/feature/_common/presentation/_barrel.dart';
import 'package:want_pass/src/feature/vault/application/_barrel.dart';
import 'package:want_pass_core/want_pass_core.dart';

const password = 'Synthetic native UI\npassword 2026';
const nextPassword = 'Synthetic recovered UI\npassword 2026';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  LaunchMode.initializeAutomatically();
  const phase = String.fromEnvironment(
    'VAULT_TEST_PHASE',
    defaultValue: 'create',
  );
  const run = String.fromEnvironment('VAULT_TEST_RUN');

  testWidgets('native macOS vault flow: $phase', (tester) async {
    expect(RegExp(r'^[a-z0-9_]+$').hasMatch(run), isTrue);
    expect(phase, anyOf('create', 'reopen'));
    // Synthetic input must not race macOS keyboard editing-state replies.
    tester.testTextInput.register();
    addTearDown(tester.testTextInput.unregister);
    tester.platformDispatcher.localesTestValue = const [Locale('en')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    final support = await getApplicationSupportDirectory();
    final directory = Directory('${support.path}/integration-issue-3-$run');
    if (phase == 'create') {
      expect(await directory.exists(), isFalse);
    } else {
      expect(
        await File('${directory.path}/vault/vault.wpass').exists(),
        isTrue,
      );
    }
    final access = await initializeVaultAccess(
      directory: '${directory.path}/vault',
      reporter: const _Reporter(),
    );
    final testErrorHandler = FlutterError.onError;
    final runtime = await AppRuntime.bootstrap(vaultAccess: access);
    final productErrorHandler = FlutterError.onError;
    FlutterError.onError = testErrorHandler;
    var completed = false;
    try {
      await tester.pumpWidget(
        WantPassApp(startup: runtime.startup, vault: runtime.vault),
      );
      await tester.pumpAndSettle();
      if (phase == 'create') {
        await _enter(tester, 'master-password', password);
        await _enter(tester, 'password-confirmation', password);
        await _tap(tester, 'vault-create');
        await _until(
          tester,
          () => runtime.vault.state.phase == VaultPhase.confirmation,
        );
        final first = runtime.vault.state.challenge!;
        for (final word in first.words) {
          expect(find.text(word), findsWidgets);
        }
        for (var i = 0; i < 3; i++) {
          await _enter(
            tester,
            'recovery-confirm-$i',
            first.words[first.positions[i]],
          );
        }
        await _tap(tester, 'vault-confirm');
        await _until(
          tester,
          () => runtime.vault.state.phase == VaultPhase.unlocked,
        );
        await _tap(tester, 'vault-lock');
        await _until(
          tester,
          () => runtime.vault.state.phase == VaultPhase.locked,
        );
        await _enter(
          tester,
          'master-password',
          'Wrong synthetic UI password 2026',
        );
        await _tap(tester, 'vault-unlock');
        await _until(tester, () => runtime.vault.state.error != null);
        expect(runtime.vault.state.phase, VaultPhase.locked);
        await _tap(tester, 'vault-recovery');
        await _enter(tester, 'recovery-phrase', first.words.join(' '));
        await _enter(tester, 'master-password', nextPassword);
        await _enter(tester, 'password-confirmation', nextPassword);
        await _tap(tester, 'vault-recover');
        await _until(
          tester,
          () => runtime.vault.state.phase == VaultPhase.confirmation,
        );
        final next = runtime.vault.state.challenge!;
        for (var i = 0; i < 3; i++) {
          await _enter(
            tester,
            'recovery-confirm-$i',
            next.words[next.positions[i]],
          );
        }
        await _tap(tester, 'vault-confirm');
        await _until(
          tester,
          () => runtime.vault.state.phase == VaultPhase.unlocked,
        );
      } else {
        await _enter(tester, 'master-password', password);
        await _tap(tester, 'vault-unlock');
        await _until(tester, () => runtime.vault.state.error != null);
        expect(runtime.vault.state.phase, VaultPhase.locked);
        await _enter(tester, 'master-password', nextPassword);
        await _tap(tester, 'vault-unlock');
        await _until(
          tester,
          () => runtime.vault.state.phase == VaultPhase.unlocked,
        );
        expect(find.byKey(const ValueKey('vault-lock')), findsOneWidget);
      }
      completed = true;
    } finally {
      FlutterError.onError = productErrorHandler;
      await runtime.close();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      if ((!completed || phase == 'reopen') && await directory.exists()) {
        await directory.delete(recursive: true);
      }
    }
  });
}

Future<void> _enter(WidgetTester tester, String key, String value) async {
  final field = find.descendant(
    of: find.byKey(ValueKey(key)),
    matching: find.bySubtype<EditableText>(),
  );
  await tester.ensureVisible(field);
  await tester.tap(field);
  await tester.pump();
  expect(
    tester.state<EditableTextState>(field).widget.focusNode.hasFocus,
    isTrue,
  );
  tester.testTextInput.enterText(value);
  await tester.pump();
  expect(tester.widget<EditableText>(field).controller.text, value);
}

Future<void> _until(WidgetTester tester, bool Function() ready) async {
  for (var i = 0; i < 600; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (ready()) {
      await tester.pump();
      return;
    }
  }
  fail('The native vault operation did not finish in 60 seconds.');
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

Future<void> _tap(WidgetTester tester, String key) async {
  final button = find.byKey(ValueKey(key));
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pump();
}
