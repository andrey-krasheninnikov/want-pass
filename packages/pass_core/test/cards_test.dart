import 'package:test/test.dart';
import 'package:want_pass_core/want_pass_core.dart';

void main() {
  test('card snapshots own collections, preserve exact values and redact diagnostics', () {
    const id = '0123456789abcdef0123456789abcdef';
    final values = [
      CardValueV1(id: FieldIdV1.login, value: 'fixture@example.invalid'),
      CardValueV1(id: FieldIdV1.password, value: ' synthetic\npassword '),
    ];
    final groups = <String>[id];
    final summary = CardSummaryV1(
      id: id,
      name: 'Synthetic card',
      service: 'github',
      environment: EnvironmentV1.production,
      groupIds: groups,
      cardType: CardTypeV1.account,
      templateVersion: 1,
    );
    final card = CardV1(
      summary: summary,
      description: 'Synthetic description',
      fields: values,
      protectedContainer: false,
    );
    values.clear();
    groups.clear();
    expect(
      card.fields.firstWhere((f) => f.id == FieldIdV1.password).value,
      ' synthetic\npassword ',
    );
    expect(summary.groupIds, [id]);
    expect(() => card.fields.clear(), throwsUnsupportedError);
    expect(summary.copyWith(environment: () => null).environment, isNull);
    expect(card.copyWith(description: 'Changed'), isNot(card));
    for (final value in [
      card.toString(),
      card.toDebugString(),
      summary.toDebugString(),
      card.fields.firstWhere((f) => f.id == FieldIdV1.password).toString(),
    ]) {
      expect(value, isNot(contains('synthetic\npassword')));
      expect(value, isNot(contains('Synthetic card')));
    }
    expect(() => summary.copyWith(service: ''), throwsA(isA<VaultErrorV1>()));
    expect(() => card.copyWith(fields: const []), throwsA(isA<VaultErrorV1>()));
  });
}
