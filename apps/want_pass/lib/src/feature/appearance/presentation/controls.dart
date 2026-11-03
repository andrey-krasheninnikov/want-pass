import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:want_allure/want_allure.dart';
import 'package:want_pass/src/feature/appearance/application/_barrel.dart';

class AppearanceControls extends StatelessWidget {
  final AppearanceController controller;
  const AppearanceControls({super.key, required this.controller});
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<AppearanceController, AppearanceState>(
        bloc: controller,
        builder: (context, state) {
          final ru = Localizations.localeOf(context).languageCode == 'ru';
          final settings = state.settings;
          final language =
              settings.language ??
              (ru ? AppearanceLanguageV1.ru : AppearanceLanguageV1.en);
          void save({AppearanceThemeV1? theme, AppearanceLanguageV1? locale}) {
            unawaited(
              controller.save(
                AppearanceSettingsV1(
                  theme: theme ?? settings.theme,
                  language: locale ?? language,
                  configured: settings.configured,
                ),
              ),
            );
          }

          return Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Semantics(
                label: ru ? 'Тема' : 'Theme',
                child: WantDropdownMenu(
                  key: const ValueKey('appearance-theme'),
                  label: Icon(switch (settings.theme) {
                    AppearanceThemeV1.system =>
                      Theme.of(context).brightness == Brightness.dark
                          ? WantIcons.moon
                          : WantIcons.sun,
                    AppearanceThemeV1.light => WantIcons.sun,
                    AppearanceThemeV1.dark => WantIcons.moon,
                  }),
                  items: [
                    for (final theme in AppearanceThemeV1.values)
                      WantMenuItem(
                        label: Text(switch ((theme, ru)) {
                          (AppearanceThemeV1.system, true) => 'Системная',
                          (AppearanceThemeV1.system, false) => 'System',
                          (AppearanceThemeV1.light, true) => 'Светлая',
                          (AppearanceThemeV1.light, false) => 'Light',
                          (AppearanceThemeV1.dark, true) => 'Тёмная',
                          (AppearanceThemeV1.dark, false) => 'Dark',
                        }),
                        icon: settings.theme == theme
                            ? const Icon(WantIcons.circleCheck)
                            : null,
                        disabled: state.busy,
                        onPressed: () => save(theme: theme),
                      ),
                  ],
                ),
              ),
              Semantics(
                label: ru ? 'Язык' : 'Language',
                child: WantDropdownMenu(
                  key: const ValueKey('appearance-language'),
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 8,
                    children: [
                      ExcludeSemantics(
                        child: Text(
                          language == AppearanceLanguageV1.ru ? '🇷🇺' : '🇬🇧',
                        ),
                      ),
                      Text(language.name.toUpperCase()),
                      const Icon(WantIcons.chevronDown, size: 16),
                    ],
                  ),
                  items: [
                    WantMenuItem(
                      label: const Text('🇬🇧 English'),
                      disabled: state.busy,
                      onPressed: () => save(locale: AppearanceLanguageV1.en),
                    ),
                    WantMenuItem(
                      label: const Text('🇷🇺 Русский'),
                      disabled: state.busy,
                      onPressed: () => save(locale: AppearanceLanguageV1.ru),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );
}
