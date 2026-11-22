import 'dart:convert';
import 'dart:io';

import 'package:domain_error/domain_error.dart';
import 'package:injectable/injectable.dart';
import 'package:want_pass/src/feature/appearance/application/_barrel.dart';
import 'package:want_pass_core/want_pass_core.dart';

@Singleton(as: AppearancePreferencesService)
final class FileAppearancePreferencesService
    implements AppearancePreferencesService {
  final String _directory;
  final StartupReporter _reporter;
  const FileAppearancePreferencesService(
    @Named('preferencesDirectory') this._directory,
    this._reporter,
  );
  @override
  FutureDomainResult<AppearanceSettingsV1> loadV1() async {
    const op = 'FileAppearancePreferencesService.loadV1():';
    final result = await captureResult<AppearanceSettingsV1>(() async {
      final file = File('$_directory/appearance.json');
      if (!await file.exists()) return const AppearanceSettingsV1();
      if (await FileSystemEntity.isLink(file.path) ||
          await file.length() > 4096) {
        throw const StartupUnexpectedErrorV1();
      }
      try {
        final raw =
            jsonDecode(await file.readAsString()) as Map<String, dynamic>;
        final theme = AppearanceThemeV1.values.byName(raw['theme'] as String);
        final language = raw['language'] == null
            ? null
            : AppearanceLanguageV1.values.byName(raw['language'] as String);
        final configured = raw['configured'] as bool;
        return AppearanceSettingsV1(
          theme: theme,
          language: language,
          configured: configured,
          layout: _readLayout(raw['workspaceLayout']),
        );
      } on FormatException {
        return const AppearanceSettingsV1();
      } on ArgumentError {
        return const AppearanceSettingsV1();
      } on TypeError {
        return const AppearanceSettingsV1();
      }
    }, mapToDomainError: (_, _) => const StartupUnexpectedErrorV1());
    if (result.isError) {
      reportStartupDiagnostic(
        _reporter,
        layer: StartupDiagnosticLayer.infrastructure,
        operation: op,
        event: StartupDiagnosticEvent.failure,
        error: const StartupUnexpectedErrorV1(),
      );
    }
    return result;
  }

  static WorkspaceLayoutV1 _readLayout(Object? value) {
    if (value case [final num groups, final num secrets, final num dual]
        when [
              groups,
              secrets,
              dual,
            ].every((v) => v.isFinite && v > 0 && v < 1) &&
            groups + secrets < 1) {
      return WorkspaceLayoutV1(
        groupFraction: groups.toDouble(),
        listFraction: secrets.toDouble(),
        dualListFraction: dual.toDouble(),
      );
    }
    return const WorkspaceLayoutV1();
  }

  @override
  FutureDomainResult<void> saveV1(AppearanceSettingsV1 settings) async {
    const op = 'FileAppearancePreferencesService.saveV1():';
    final result = await captureResult<void>(() async {
      final directory = Directory(_directory);
      if (await FileSystemEntity.isLink(directory.path)) {
        throw const StartupUnexpectedErrorV1();
      }
      await directory.create(recursive: true);
      if (await FileSystemEntity.type(
            '$_directory/vault/reset.pending',
            followLinks: false,
          ) !=
          FileSystemEntityType.notFound) {
        throw const StartupUnexpectedErrorV1();
      }
      final file = File('$_directory/appearance.json');
      final temporary = File('$_directory/appearance.tmp');
      if (await FileSystemEntity.isLink(file.path) ||
          await FileSystemEntity.isLink(temporary.path)) {
        throw const StartupUnexpectedErrorV1();
      }
      try {
        await temporary.writeAsString(
          jsonEncode({
            'theme': settings.theme.name,
            'language': settings.language?.name,
            'configured': settings.configured,
            'workspaceLayout': [
              settings.layout.groupFraction,
              settings.layout.listFraction,
              settings.layout.dualListFraction,
            ],
          }),
          flush: true,
        );
        await temporary.rename(file.path);
      } finally {
        if (await temporary.exists()) await temporary.delete();
      }
    }, mapToDomainError: (_, _) => const StartupUnexpectedErrorV1());
    if (result.isError) {
      reportStartupDiagnostic(
        _reporter,
        layer: StartupDiagnosticLayer.infrastructure,
        operation: op,
        event: StartupDiagnosticEvent.failure,
        error: const StartupUnexpectedErrorV1(),
      );
    }
    return result;
  }
}
