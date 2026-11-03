import 'dart:io';
import 'dart:convert';

import 'package:test/test.dart';
import 'package:want_pass_core/want_pass_core.dart';

void main() {
  test(
    'public content port persists groups and returns no passwords in lists',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'want-pass-content-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final access = await initializeVaultAccess(
        directory: '${directory.path}/vault',
        reporter: const _Reporter(),
      );
      final handle = (await access.openV1()).value;
      addTearDown(handle.close);
      const password = 'Synthetic content port password 2026!';
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
      final empty = (await access.contentV1(handle: handle)).value;
      final saved = await access.saveGroupV1(
        handle: handle,
        input: GroupDraftV1(
          name: 'Synthetic project',
          logo: List.unmodifiable(
            base64Decode(
              'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR4nGP4z8DwHwAFAAH/iZk9HQAAAABJRU5ErkJggg==',
            ),
          ),
        ),
        revision: empty.revision,
      );
      expect(saved.isSuccess, isTrue);
      expect(saved.value.groups.single.name, 'Synthetic project');
      final logo = saved.value.groups.single.logo;
      expect(logo, isNotEmpty);
      expect(saved.value.toString(), isNot(contains('Synthetic project')));
      handle.invalidateSync();
      expect((await access.contentV1(handle: handle)).isError, isTrue);
      await access.unlockV3(handle: handle, password: password);
      expect(
        (await access.contentV1(handle: handle)).value.groups.single.name,
        'Synthetic project',
      );
      expect(
        (await access.contentV1(handle: handle)).value.groups.single.logo,
        logo,
      );
    },
  );
  test('content snapshots own immutable values and redact diagnostics', () {
    const id = '0123456789abcdef0123456789abcdef';
    final bytes = <int>[1, 2, 3];
    final group = GroupV1(
      id: id,
      name: 'Private fixture',
      description: 'Private description',
      icon: 'folder',
      logo: bytes,
    );
    bytes.add(4);
    expect(group.logo, [1, 2, 3]);
    expect(() => group.logo.add(4), throwsUnsupportedError);
    expect(group.copyWith(name: 'Renamed fixture'), isNot(group));
    expect(group.copyWith(logo: const []).logo, isEmpty);
    for (final output in [group.toString(), group.toDebugString()]) {
      expect(output, isNot(contains('Private fixture')));
      expect(output, isNot(contains('Private description')));
      expect(output, isNot(contains(id)));
    }
    expect(
      () => group.copyWith(name: '  '),
      throwsA(isA<VaultRejectedErrorV1>()),
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
