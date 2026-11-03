import 'dart:io';

import 'package:test/test.dart';
import 'package:want_pass_core/want_pass_core.dart';

void main() {
  test(
    'native vault operations create and reopen through the public Dart port',
    () async {
      final temporary = await Directory.systemTemp.createTemp(
        'want-pass-vault-test-',
      );
      addTearDown(() => temporary.delete(recursive: true));
      final access = await initializeVaultAccess(
        directory: '${temporary.path}/private-vault',
        reporter: const _Reporter(),
      );
      final opened = await access.openV1();
      expect(opened.isSuccess, isTrue);
      final handle = opened.value;
      addTearDown(handle.close);
      expect(
        (await access.validatePasswordV3(password: 'short')).value,
        isFalse,
      );
      expect(
        (await access.validatePasswordV3(
          password: 'Synthetic policy password 2026!',
        )).value,
        isTrue,
      );
      final prepared = await access.prepareCreationV1(
        handle: handle,
        password: 'Synthetic Dart test password 2026',
      );
      expect(prepared.isSuccess, isTrue);
      final challenge = prepared.value;
      expect(challenge.words, hasLength(24));
      final confirmed = await access.confirmV1(
        handle: handle,
        answers: challenge.positions.map((i) => challenge.words[i]).toList(),
      );
      expect(confirmed.isSuccess, isTrue);
      handle.invalidateSync();
      expect(
        (await access.statusV1(handle: handle)).value,
        VaultAccessStateV1.locked,
      );
      expect(
        (await access.unlockV3(
          handle: handle,
          password: 'Synthetic Dart test password 2026',
        )).error,
        const VaultRejectedErrorV1(VaultFailureKindV1.invalidPassword),
      );
      expect(
        (await access.unlockV1(
          handle: handle,
          password: 'Synthetic Dart test password 2026',
        )).isSuccess,
        isTrue,
      );
      expect(
        (await access.statusV1(handle: handle)).value,
        VaultAccessStateV1.unlocked,
      );
    },
  );
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
