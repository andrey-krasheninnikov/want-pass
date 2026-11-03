import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:launch_mode/launch_mode.dart';
import 'package:want_pass/src/feature/vault/application/_barrel.dart';
import 'package:want_pass/src/feature/vault/infrastructure/_barrel.dart';
import 'package:want_pass_core/want_pass_core.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  LaunchMode.initializeAutomatically();
  test('controller preserves accounts when a group is removed and clears content on lock', () async {
    final directory = await Directory.systemTemp.createTemp(
      'want-pass-groups-controller-',
    );
    addTearDown(() => directory.delete(recursive: true));
    const reporter = _Reporter();
    final access = await initializeVaultAccess(
      directory: '${directory.path}/vault',
      reporter: reporter,
    );
    final events = StreamController<VaultLockSignal>.broadcast();
    addTearDown(events.close);
    final controller = VaultController(
      VaultUseCaseImpl(
        access,
        reporter,
        const PlatformRecoveryExportService(reporter),
        const PlatformGroupLogoService(reporter),
        const PlatformCredentialFileService(reporter),
      ),
      reporter,
      events.stream,
    );
    addTearDown(controller.close);
    await controller.init();
    const password = 'Synthetic controller password 2026!';
    await controller.prepareCreation(
      password: password,
      confirmation: password,
    );
    final challenge = controller.state.challenge!;
    await controller.confirm(
      challenge.positions.map((i) => challenge.words[i]).toList(),
    );
    await controller.loadContent();
    expect(
      await controller.saveGroup(const GroupDraftV1(name: 'Synthetic group')),
      isTrue,
    );
    final group = controller.state.content!.groups.single;
    expect(
      await controller.saveCard(
        CardDraftV1(
          name: 'Synthetic account',
          service: 'github',
          cardType: CardTypeV1.account,
          environment: EnvironmentV1.production,
          fields: const [
            CardFieldDraftV1(
              id: FieldIdV1.login,
              value: 'fixture@example.invalid',
            ),
            CardFieldDraftV1(id: FieldIdV1.password, value: 'fixture password'),
          ],
          groupIds: List.unmodifiable([group.id]),
        ),
      ),
      isTrue,
    );
    expect(await controller.deleteGroup(group.id), isTrue);
    final account = controller.state.content!.cards.single;
    expect(account.groupIds, isEmpty);
    expect(
      (await controller.readCard(account.id))!.fields
          .firstWhere((f) => f.id == FieldIdV1.password)
          .value,
      'fixture password',
    );
    await controller.lock();
    expect(controller.state.content, isNull);
    expect(await controller.readCard(account.id), isNull);
    await controller.unlock(password);
    expect(controller.state.content!.cards.single.id, account.id);
  });
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
