import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:launch_mode/launch_mode.dart';
import 'package:want_pass/src/feature/appearance/application/_barrel.dart';
import 'package:want_pass/src/feature/appearance/infrastructure/_barrel.dart';
import 'package:want_pass_core/want_pass_core.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  LaunchMode.initializeAutomatically();
  test(
    'appearance persists theme, language and first-run completion',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'want-pass-appearance-',
      );
      addTearDown(() => directory.delete(recursive: true));
      const reporter = _Reporter();
      final service = FileAppearancePreferencesService(
        directory.path,
        reporter,
      );
      final useCase = AppearanceUseCaseImpl(service, reporter);
      final controller = AppearanceController(useCase, reporter);
      await Future.wait([controller.init(), controller.init()]);
      expect(controller.state.settings, const AppearanceSettingsV1());
      const selected = AppearanceSettingsV1(
        theme: AppearanceThemeV1.dark,
        language: AppearanceLanguageV1.ru,
        configured: true,
      );
      await controller.save(selected);
      expect(controller.state.settings, selected);
      await controller.close();
      final reopened = AppearanceController(useCase, reporter);
      addTearDown(reopened.close);
      await reopened.init();
      expect(reopened.state.settings, selected);
    },
  );
  test('corrupt preferences fall back; symlinks cannot be written', () async {
    final directory = await Directory.systemTemp.createTemp(
      'want-pass-appearance-invalid-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final service = FileAppearancePreferencesService(
      directory.path,
      const _Reporter(),
    );
    final file = File('${directory.path}/appearance.json');
    await file.writeAsString('{invalid');
    expect((await service.loadV1()).value, const AppearanceSettingsV1());
    await file.delete();
    await Link(file.path).create('${directory.path}/outside');
    expect(
      (await service.saveV1(const AppearanceSettingsV1())).isError,
      isTrue,
    );
    expect(await File('${directory.path}/outside').exists(), isFalse);
  });
}

final class _Reporter implements StartupReporter {
  const _Reporter();
  @override
  void report({
    required StartupDiagnosticLayer layer,
    required String operation,
    required StartupDiagnosticEvent event,
    StartupErrorV1? error,
  }) {}
}
