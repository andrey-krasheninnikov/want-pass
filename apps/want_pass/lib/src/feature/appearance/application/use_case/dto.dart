import 'package:equatable/equatable.dart';

enum AppearanceThemeV1 { system, light, dark }

enum AppearanceLanguageV1 { en, ru }

final class WorkspaceLayoutV1 extends Equatable {
  final double groupFraction, listFraction, dualListFraction;

  const WorkspaceLayoutV1({
    this.groupFraction = .2,
    this.listFraction = .3,
    this.dualListFraction = .4,
  });

  @override
  List<Object?> get props => [groupFraction, listFraction, dualListFraction];
}

final class AppearanceSettingsV1 extends Equatable {
  final AppearanceThemeV1 theme;
  final AppearanceLanguageV1? language;
  final bool configured;
  final WorkspaceLayoutV1 layout;
  const AppearanceSettingsV1({
    this.theme = AppearanceThemeV1.system,
    this.language,
    this.configured = false,
    this.layout = const WorkspaceLayoutV1(),
  });
  @override
  List<Object?> get props => [theme, language, configured, layout];
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
