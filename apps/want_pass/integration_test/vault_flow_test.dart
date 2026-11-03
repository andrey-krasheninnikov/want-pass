import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:launch_mode/launch_mode.dart';
import 'package:path_provider/path_provider.dart';
import 'package:want_pass/src/core/_barrel.dart';
import 'package:want_pass/src/feature/_common/presentation/_barrel.dart';
import 'package:want_pass/src/feature/vault/application/_barrel.dart';
import 'package:want_pass_core/want_pass_core.dart';
import 'package:want_allure/want_allure.dart';

const password = 'Synthetic native UI\npassword 2026!';
const nextPassword = 'Synthetic recovered UI\npassword 2026!';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
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
    final runtime = await AppRuntime.bootstrap(
      vaultAccess: access,
      preferencesDirectory: '${directory.path}/preferences',
    );
    final productErrorHandler = FlutterError.onError;
    FlutterError.onError = testErrorHandler;
    var completed = false;
    final captureBoundary = GlobalKey();
    try {
      await tester.pumpWidget(
        RepaintBoundary(
          key: captureBoundary,
          child: WantPassApp(
            startup: runtime.startup,
            vault: runtime.vault,
            appearance: runtime.appearance,
          ),
        ),
      );
      await _settle(tester);
      expect(await signalWantPassFirstFrame(), isTrue);
      if (phase == 'create') {
        await _tap(tester, 'setup-next');
        await _until(
          tester,
          () => runtime.appearance.state.settings.configured,
        );
        await _settle(tester);
        await _enter(tester, 'master-password', password);
        await _enter(tester, 'password-confirmation', password);
        await _tap(tester, 'vault-create');
        await _until(
          tester,
          () => runtime.vault.state.phase == VaultPhase.confirmation,
        );
        final first = runtime.vault.state.setupChallenge!;
        await _enter(tester, 'password-hint', 'Synthetic password hint');
        await _tap(tester, 'password-saved');
        await _tap(tester, 'setup-back');
        await _tap(tester, 'vault-create');
        await _until(tester, () => !runtime.vault.state.busy);
        await _settle(tester);
        expect(runtime.vault.state.setupChallenge, first);
        await _tap(tester, 'setup-next');
        await _settle(tester);
        for (final word in first.words) {
          expect(find.text(word), findsWidgets);
        }
        await _tap(tester, 'recovery-qr');
        await _settle(tester);
        await _captureQr(tester, captureBoundary, first.json, directory.path);
        await _tap(tester, 'qr-saved');
        await _confirm(tester, first);

        await _until(
          tester,
          () => runtime.vault.state.phase == VaultPhase.unlocked,
        );
        await _tap(tester, 'vault-dial');
        await _until(
          tester,
          () => runtime.vault.state.phase == VaultPhase.locked,
        );
        await _tap(tester, 'vault-dial');
        await _settle(tester);
        await _enter(
          tester,
          'unlock-password',
          'Wrong synthetic UI password 2026!',
        );
        await _tap(tester, 'vault-unlock');
        await _until(tester, () => runtime.vault.state.error != null);
        expect(runtime.vault.state.phase, VaultPhase.locked);
        expect(find.text('Synthetic password hint'), findsNothing);
        await _tap(tester, 'vault-show-hint');
        expect(find.text('Synthetic password hint'), findsOneWidget);
        await _tap(tester, 'vault-recovery');
        await _settle(tester);
        await _enter(tester, 'recovery-phrase', first.json);
        await _tap(tester, 'setup-next');
        await _until(tester, () => !runtime.vault.state.busy);
        await _settle(tester);
        await _enter(tester, 'master-password', nextPassword);
        await _enter(tester, 'password-confirmation', nextPassword);
        await _tap(tester, 'vault-recover');
        await _until(
          tester,
          () => runtime.vault.state.phase == VaultPhase.confirmation,
        );
        final next = runtime.vault.state.setupChallenge!;
        await _enter(tester, 'password-hint', 'Synthetic renewed hint');
        await _tap(tester, 'password-saved');
        await _tap(tester, 'setup-next');
        await _settle(tester);
        await _confirm(tester, next);

        await _until(
          tester,
          () => runtime.vault.state.phase == VaultPhase.unlocked,
        );
      } else {
        await _tap(tester, 'vault-dial');
        await _settle(tester);
        await _enter(tester, 'unlock-password', password);
        await _tap(tester, 'vault-unlock');
        await _until(tester, () => runtime.vault.state.error != null);
        expect(runtime.vault.state.phase, VaultPhase.locked);
        await _enter(tester, 'unlock-password', nextPassword);
        await _tap(tester, 'vault-unlock');
        await _until(
          tester,
          () => runtime.vault.state.phase == VaultPhase.unlocked,
        );
        expect(find.byKey(const ValueKey('vault-dial')), findsOneWidget);
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
  await _settle(tester);
  await tester.tap(field);
  await tester.pump();
  expect(
    tester.state<EditableTextState>(field).widget.focusNode.hasFocus,
    isTrue,
  );
  tester.testTextInput.enterText(value);
  await tester.pump();
  expect(
    tester.widget<EditableText>(field).controller.text,
    key == 'recovery-phrase' ? value : value.replaceAll('\n', ''),
  );
}

Future<void> _confirm(
  WidgetTester tester,
  VaultRecoveryChallengeV3 challenge,
) async {
  await _tap(tester, 'setup-next');
  await _settle(tester);
  await _enter(tester, 'recovery-hint', 'Synthetic phrase location');
  final checkbox = find.byKey(const ValueKey('phrase-saved'));
  if (!(tester.widget<WantCheckbox>(checkbox).value)) {
    await _tap(tester, 'phrase-saved');
  }
  await _tap(tester, 'recovery-loss-accepted');
  await _tap(tester, 'setup-next');
  await _settle(tester);
  for (var i = 0; i < 3; i++) {
    final word = challenge.words[challenge.positions[i]];
    await _tap(tester, 'quiz-$i-$word');
    await _tap(tester, i == 2 ? 'vault-confirm' : 'setup-next');
    if (i < 2) await _settle(tester);
  }
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
  final label = key.startsWith('quiz-') ? 'quiz' : key;
  debugPrint('Native UI action: $label');
  final button = find.byKey(ValueKey(key));
  await tester.ensureVisible(button);
  await _settle(tester);
  await tester.tap(button);
  await tester.pump();
}

Future<void> _captureQr(
  WidgetTester tester,
  GlobalKey boundary,
  String json,
  String fixture,
) async {
  const capture = bool.fromEnvironment('VAULT_CAPTURE_QR');
  if (!capture) return;
  final directory = '$fixture/qr';
  await Directory(directory).create();
  final render =
      boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = await render.toImage(pixelRatio: 2);
  try {
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    await File('$directory/qr-json.png')
        .writeAsBytes(bytes!.buffer.asUint8List(), flush: true);
    await File('$directory/qr-json.json').writeAsString(json, flush: true);
  } finally {
    image.dispose();
  }
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pumpAndSettle(
    const Duration(milliseconds: 100),
    EnginePhase.sendSemanticsUpdate,
    const Duration(seconds: 10),
  );
}
