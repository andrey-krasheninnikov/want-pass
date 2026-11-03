import 'package:equatable/equatable.dart';

enum AppearanceThemeV1 { system, light, dark }

enum AppearanceLanguageV1 { en, ru }

final class AppearanceSettingsV1 extends Equatable {
  final AppearanceThemeV1 theme;
  final AppearanceLanguageV1? language;
  final bool configured;
  const AppearanceSettingsV1({
    this.theme = AppearanceThemeV1.system,
    this.language,
    this.configured = false,
  });
  @override
  List<Object?> get props => [theme, language, configured];
}

final class LoadAppearanceParamsV1 extends Equatable {
  const LoadAppearanceParamsV1();
  @override
  List<Object?> get props => [];
}

final class SaveAppearanceParamsV1 extends Equatable {
  final AppearanceSettingsV1 settings;
  const SaveAppearanceParamsV1({required this.settings});
  @override
  List<Object?> get props => [settings];
}

final class AppearanceResultV1 extends Equatable {
  final AppearanceSettingsV1 settings;
  const AppearanceResultV1({required this.settings});
  @override
  List<Object?> get props => [settings];
}
