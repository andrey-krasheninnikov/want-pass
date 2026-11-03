import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:want_allure/want_allure.dart';
import 'package:want_pass/src/feature/vault/presentation/_barrel.dart';

void main() {
  testWidgets('narrow logos never allocate an enlarged decoded image', (
    tester,
  ) async {
    final bytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAEACAYAAAByPhyYAAAAF0lEQVR4nGP4z8Dwn2GUGCVGiVFi5BEAT7X+EIge+qQAAAAASUVORK5CYII=',
    );
    await tester.pumpWidget(
      MaterialApp(
        home: WantTheme(
          data: WantThemeData.light(),
          child: Center(
            child: VaultGroupLogo(icon: 'folder', bytes: bytes),
          ),
        ),
      ),
    );
    for (
      var attempt = 0;
      attempt < 100 && find.byType(RawImage).evaluate().isEmpty;
      attempt++
    ) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump();
    }
    final image = tester.widget<RawImage>(find.byType(RawImage)).image!;
    expect((image.width, image.height), (1, 256));
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });
}
