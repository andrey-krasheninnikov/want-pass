import 'package:want_pass/src/feature/vault/infrastructure/_barrel.dart';

import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:launch_mode/launch_mode.dart';
import 'package:want_pass/src/feature/vault/application/_barrel.dart';
import 'package:want_pass_core/want_pass_core.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  LaunchMode.initializeAutomatically();
  test(
    'owner completes creation through the shared application operations',
    () async {
      final temporary = await Directory.systemTemp.createTemp(
        'want-pass-application-test-',
      );
      addTearDown(() => temporary.delete(recursive: true));
      const reporter = _Reporter();
      final access = await initializeVaultAccess(
        directory: '${temporary.path}/vault',
        reporter: reporter,
      );
      final useCase = VaultUseCaseImpl(
        access,
        reporter,
        PlatformRecoveryExportService(reporter),
        const PlatformGroupLogoService(_Reporter()),
      );
      final initialized = await useCase.initializeV1(
        params: const InitializeVaultParamsV1(),
      );
      expect(initialized.isSuccess, isTrue);
      final handle = initialized.value.handle;
      addTearDown(handle.close);
      final prepared = await useCase.prepareCreationV1(
        params: PrepareVaultCreationParamsV1(
          handle: handle,
          password: 'Synthetic application password 2026',
          confirmation: 'Synthetic application password 2026',
        ),
      );
      expect(prepared.isSuccess, isTrue);
      final challenge = prepared.value.challenge;
      expect(
        await File('${temporary.path}/vault/vault.wpass').exists(),
        isFalse,
      );
      final confirmed = await useCase.confirmCreationV1(
        params: ConfirmVaultCreationParamsV1(
          handle: handle,
          answers: List.unmodifiable(
            challenge.positions.map((i) => challenge.words[i]),
          ),
        ),
      );
      expect(confirmed.value.state, VaultAccessStateV1.unlocked);
      expect(
        (await useCase.lockV1(params: LockVaultParamsV1(handle: handle)))
            .value
            .state,
        VaultAccessStateV1.locked,
      );
    },
  );
  test('controller owns confirmation, lock and resource closure', () async {
    final temporary = await Directory.systemTemp.createTemp(
      'want-pass-controller-test-',
    );
    addTearDown(() => temporary.delete(recursive: true));
    const reporter = _Reporter();
    final events = StreamController<VaultLockSignal>.broadcast();
    addTearDown(events.close);
    final access = await initializeVaultAccess(
      directory: '${temporary.path}/vault',
      reporter: reporter,
    );
    final controller = VaultController(
      VaultUseCaseImpl(
        access,
        reporter,
        PlatformRecoveryExportService(reporter),
        const PlatformGroupLogoService(_Reporter()),
      ),
      reporter,
      events.stream,
    );
    addTearDown(controller.close);
    await controller.init();
    expect(controller.state.phase, VaultPhase.missing);
    await controller.prepareCreation(
      password: 'Synthetic controller password 2026',
      confirmation: 'Synthetic controller password 2026',
    );
    expect(controller.state.phase, VaultPhase.confirmation);
    final challenge = controller.state.challenge!;
    await controller.confirm(
      challenge.positions.map((i) => challenge.words[i]).toList(),
    );
    expect(controller.state.phase, VaultPhase.unlocked);
    await controller.lock();
    expect(controller.state.phase, VaultPhase.locked);
    expect(controller.state.challenge, isNull);
    await controller.close();
    expect(controller.isClosed, isTrue);
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
