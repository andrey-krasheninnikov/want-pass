import 'package:flutter/material.dart';
import 'package:want_pass/src/feature/appearance/application/_barrel.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:want_allure/want_allure.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:want_pass/src/feature/startup/application/_barrel.dart';
import 'package:want_pass/src/feature/vault/application/_barrel.dart';
import 'package:want_pass/src/feature/vault/presentation/_barrel.dart';

class WantPassApp extends StatelessWidget {
  final StartupController startup;
  final VaultController vault;
  final AppearanceController? appearance;

  const WantPassApp({
    super.key,
    required this.startup,
    required this.vault,
    this.appearance,
  });

  @override
  Widget build(BuildContext context) {
    final preferences = appearance;
    if (preferences == null) return _application(const AppearanceState());
    return BlocBuilder<AppearanceController, AppearanceState>(
      bloc: preferences,
      builder: (context, state) => _application(state),
    );
  }

  Widget _application(AppearanceState appearanceState) => MaterialApp(
    title: 'Want Pass',
    debugShowCheckedModeBanner: false,
    locale: appearanceState.settings.language == null
        ? null
        : Locale(appearanceState.settings.language!.name),
    themeMode: switch (appearanceState.settings.theme) {
      AppearanceThemeV1.system => ThemeMode.system,
      AppearanceThemeV1.light => ThemeMode.light,
      AppearanceThemeV1.dark => ThemeMode.dark,
    },
    theme: ThemeData.light(),
    darkTheme: ThemeData.dark(),
    supportedLocales: const [Locale('en'), Locale('ru')],
    localizationsDelegates: const [
      ...GlobalMaterialLocalizations.delegates,
      ...FLocalizations.localizationsDelegates,
    ],
    builder: (context, child) => WantTheme(
      data: Theme.of(context).brightness == Brightness.dark
          ? WantThemeData.dark()
          : WantThemeData.light(),
      child: WantToaster(child: child!),
    ),
    home: BlocProvider.value(
      value: startup,
      child: BlocBuilder<StartupController, StartupState>(
        builder: (context, state) {
          if (state is StartupReady) {
            return VaultPage(controller: vault, appearance: appearance);
          }
          final russian = Localizations.localeOf(context).languageCode == 'ru';
          final (title, message) = switch ((state, russian)) {
            (StartupReady(), _) => ('', ''),
            (StartupFailed(), true) => (
              'Запуск недоступен',
              'Перезапустите приложение и попробуйте ещё раз.',
            ),
            (StartupFailed(), false) => (
              'Startup unavailable',
              'Restart the application and try again.',
            ),
            (StartupLoading(), true) => ('Запуск', ''),
            (StartupLoading(), false) => ('Starting', ''),
          };
          return ColoredBox(
            color: WantTheme.of(context).color('background'),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: WantCard(
                      hoverEffect: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 20,
                        children: [
                          Image.asset(
                            'assets/brand/logo-dark.png',
                            width: 72,
                            height: 72,
                            excludeFromSemantics: true,
                          ),
                          WantTypography(
                            title,
                            variant: WantTypographyVariant.lead,
                          ),
                          WantTypography(
                            message,
                            colorRole: 'muted-foreground',
                            liveRegion: state is StartupFailed,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}
