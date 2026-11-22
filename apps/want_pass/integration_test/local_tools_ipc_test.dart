import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:domain_error/domain_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:launch_mode/launch_mode.dart';
import 'package:want_allure/want_allure.dart';
import 'package:want_pass/src/feature/vault/application/_barrel.dart';
import 'package:want_pass/src/feature/vault/infrastructure/_barrel.dart';
import 'package:want_pass/src/feature/vault/presentation/_barrel.dart';
import 'package:want_pass_core/want_pass_core.dart';

class _Reporter implements VaultReporter {
  const _Reporter();
  @override
  void reportVault({
    required VaultDiagnosticLayer layer,
    required String operation,
    required VaultErrorV1 error,
  }) {}
}

class _Files implements CredentialFileService {
  @override
  FutureDomainResult<String?> withBackupDestinationV1(
    Future<bool> Function(String) save,
  ) async => const Result.success(null);
  @override
  FutureDomainResult<List<String>?> selectAccountImportV1(
    AccountImportSourceV1 source, {
    required bool clipboard,
  }) async => const Result.success([
    'Title,URL,Username,Password\nTest,https://example.invalid/,example,synthetic-only\n',
  ]);
  @override
  FutureDomainResult<String?> selectBackupSourceV1() async =>
      const Result.success(null);
  @override
  FutureDomainResult<AttachmentDraftV1?> selectAttachmentV1() async =>
      const Result.success(null);
  @override
  FutureDomainResult<String?> selectDestinationV1(String name) async =>
      const Result.success(null);
}

Future<void> _sshFixture(
  WidgetTester tester,
  VaultController controller,
  String cli,
  String path,
) async {
  expect(
    RegExp(
      r'^/Users/[^/]+/Library/Containers/foundation\.want\.pass\.dev/Data/\.wpass-test-[a-z0-9]{12}$',
    ).hasMatch(path),
    isTrue,
  );
  final options =
      jsonDecode(await File('$path/server.json').readAsString()) as Map;
  final profile = await controller.localTool(LocalToolCommandV1.configure, {
    'alias': 'acceptance-loopback',
    'host': '127.0.0.1',
    'port': options['port'],
    'user': 'fixture',
    'environment': 'local',
    'host_key': options['public_key'],
  });
  expect(profile, isA<String>());
  final descriptor = File('$path/ready.json');
  final part = File('$path/ready.partial');
  await part.writeAsString(
    jsonEncode({'id': profile, 'cli': cli}),
    flush: true,
  );
  await part.rename(descriptor.path);
  var confirmations = 0;
  final done = File('$path/finished');
  final timer = Stopwatch()..start();
  while (!await done.exists() && timer.elapsed < const Duration(seconds: 65)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (find.text('Allow').evaluate().isNotEmpty) {
      await tester.tap(find.text('Allow'));
      await tester.pump(const Duration(milliseconds: 350));
      confirmations++;
    }
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
  expect(await done.exists(), isTrue);
  expect(await done.readAsString(), 'passed');
  expect(confirmations, 3);
  expect(
    await controller.localTool(LocalToolCommandV1.disconnect, profile!),
    isNotNull,
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  LaunchMode.initializeAutomatically();
  testWidgets(
    'signed wpass connects to the unlocked dev vault and honors revoke',
    (tester) async {
      final directory = await Directory.systemTemp.createTemp(
        'want-pass-ipc-test-',
      );
      const reporter = _Reporter();
      final access = await initializeVaultAccess(
        directory: '${directory.path}/data',
        reporter: reporter,
      );
      final events = StreamController<VaultLockSignal>.broadcast();
      final controller = VaultController(
        VaultUseCaseImpl(
          access,
          reporter,
          const PlatformRecoveryExportService(reporter),
          const PlatformGroupLogoService(reporter),
          _Files(),
        ),
        reporter,
        events.stream,
      );
      addTearDown(() async {
        await controller.close();
        await events.close();
        await directory.delete(recursive: true);
      });
      await controller.init();
      const password = 'Test-only local vault 2026!';
      await controller.prepareCreation(
        password: password,
        confirmation: password,
      );
      expect(controller.state.phase, VaultPhase.confirmation);
      final challenge = controller.state.challenge!;
      await controller.confirm(
        challenge.positions.map((p) => challenge.words[p]).toList(),
      );
      await controller.loadContent();
      final preview = await controller.prepareAccountImport(
        AccountImportSourceV1.applePasswords,
        clipboard: false,
      );
      expect(preview, isNotNull);
      expect(await controller.applyAccountImport(preview!.token, [0]), isTrue);
      final dashboard =
          await controller.localTool(LocalToolCommandV1.dashboard, {}) as Map;
      final binding =
          ((dashboard['bindings'] as List).single as Map)['id'] as String;

      final scope = {
        'client': 'wpass',
        'action': 'search',
        'target': binding,
        'resource': 'https://example.invalid/',
        'fields': ['name', 'service'],
        'environment': 'unassigned',
      };
      expect(
        await controller.localTool(
          LocalToolCommandV1.grant,
          scope,
          admitted: () async => false,
        ),
        isNull,
      );
      final deniedView =
          await controller.localTool(LocalToolCommandV1.dashboard, {}) as Map;
      expect(deniedView['grants'], isEmpty);
      final cli =
          '${File(Platform.resolvedExecutable).parent.parent.path}/Helpers/wpass';
      expect(await File(cli).exists(), isTrue);
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) =>
              WantTheme(data: WantThemeData.light(), child: child!),
          home: Scaffold(body: VaultContentView(controller: controller)),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      Future<ProcessResult> call(List<String> args) =>
          Process.run(cli, args).timeout(const Duration(seconds: 70));
      final denied = await call(['search', binding]);
      expect(denied.exitCode, isNot(0));
      ProcessResult? early;
      final pairing = call(['authorize', 'search', binding])
          .then((value) => early = value);
      for (
        var i = 0;
        i < 70 && early == null && find.text('Allow').evaluate().isEmpty;
        i++
      ) {
        await tester.pump(const Duration(milliseconds: 120));
        await Future<void>.delayed(const Duration(milliseconds: 80));
      }
      expect(
        find.text('Allow'),
        findsOneWidget,
        reason: early?.stderr.toString(),
      );
      await tester.tap(find.text('Allow'));
      await tester.pump(const Duration(milliseconds: 350));
      expect((await pairing).exitCode, 0);
      final found = await call(['search', binding, 'Test']);
      expect(found.exitCode, 0);
      expect((found.stdout as String).contains('"name":"Test"'), isTrue);
      expect(found.stdout.toString().contains('synthetic-only'), isFalse);
      final permissions =
          await controller.localTool(LocalToolCommandV1.dashboard, {}) as Map;
      final grant = (permissions['grants'] as List).single;
      await controller.localTool(LocalToolCommandV1.revoke, grant);
      expect((await call(['search', binding])).exitCode, isNot(0));
      const sshFixture = String.fromEnvironment('WPASS_SSH_FIXTURE');
      if (sshFixture.isNotEmpty) {
        await _sshFixture(tester, controller, cli, sshFixture);
      }
      await controller.lock();
      await tester.pumpWidget(const SizedBox.shrink());
      expect((await call(['search', binding])).exitCode, isNot(0));
    },
  );
}
