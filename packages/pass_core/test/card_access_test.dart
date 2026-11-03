import 'dart:io';

import 'package:test/test.dart';
import 'package:want_pass_core/want_pass_core.dart';

void main() {
  test('typed card port saves account metadata and generates OTP without returning a seed', () async {
    final directory = await Directory.systemTemp.createTemp(
      'want-pass-card-port-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final access = await initializeVaultAccess(
      directory: '${directory.path}/vault',
      reporter: const _Reporter(),
    );
    final handle = (await access.openV1()).value;
    addTearDown(handle.close);
    const password = 'Synthetic card port password 2026!';
    final challenge = (await access.prepareCreationV3(
      handle: handle,
      password: password,
    )).value;
    expect(
      (await access.confirmV3(
        handle: handle,
        answers: challenge.positions.map((i) => challenge.words[i]).toList(),
        password: password,
        hints: const VaultHintsDtoV2(),
        revision: challenge.revision,
      )).isSuccess,
      isTrue,
    );
    final catalog = (await access.cardCatalogV1()).value;
    expect(catalog.presets.length, 19);
    expect(catalog.services, contains('github'));
    final saved = await access.saveCardV1(
      handle: handle,
      revision: BigInt.zero,
      input: const CardDraftV1(
        name: 'Synthetic account',
        service: 'github',
        cardType: CardTypeV1.account,
        environment: EnvironmentV1.production,
        fields: [
          CardFieldDraftV1(
            id: FieldIdV1.login,
            value: 'fixture@example.invalid',
          ),
          CardFieldDraftV1(
            id: FieldIdV1.password,
            value: ' exact\nsynthetic password ',
          ),
          CardFieldDraftV1(
            id: FieldIdV1.totpSeed,
            value: 'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ',
          ),
        ],
      ),
    );
    expect(saved.isSuccess, isTrue);
    final summary = saved.value.cards.single;
    expect(summary.environment, EnvironmentV1.production);
    final otp = (await access.currentTotpV1(
      handle: handle,
      id: summary.id,
    )).value;
    expect(otp.code.length, 6);
    expect(otp.toString(), isNot(contains(otp.code)));
    handle.invalidateSync();
    expect((await access.contentV2(handle: handle)).isError, isTrue);
    await access.unlockV3(handle: handle, password: password);
    final card = (await access.cardV1(handle: handle, id: summary.id)).value;
    expect(
      card.fields.firstWhere((f) => f.id == FieldIdV1.password).value,
      ' exact\nsynthetic password ',
    );
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
