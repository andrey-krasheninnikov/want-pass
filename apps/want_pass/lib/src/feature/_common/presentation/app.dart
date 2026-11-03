import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:want_allure/want_allure.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:want_pass/src/feature/startup/application/_barrel.dart';
import 'package:want_pass/src/feature/vault/application/_barrel.dart';
import 'package:want_pass/src/feature/vault/presentation/_barrel.dart';

class WantPassApp extends StatelessWidget {
  final StartupController startup;
  final VaultController vault;

  const WantPassApp({super.key, required this.startup, required this.vault});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Want Pass',
    debugShowCheckedModeBanner: false,
    supportedLocales: const [Locale('en'), Locale('ru')],
    localizationsDelegates: const [
      ...GlobalMaterialLocalizations.delegates,
      ...FLocalizations.localizationsDelegates,
    ],
    builder: (context, child) => WantTheme(
      data: WantThemeData.dark(),
      child: WantToaster(child: child!),
    ),
    home: BlocProvider.value(
      value: startup,
      child: BlocBuilder<StartupController, StartupState>(
        builder: (context, state) {
          if (state is StartupReady) return VaultPage(controller: vault);
          final russian = Localizations.localeOf(context).languageCode == 'ru';
          final (title, message) = switch ((state, russian)) {
            (StartupReady(), _) => ('', ''),
            (StartupFailed(), true) => (
              'Не удалось запустить Want Pass.',
              'Перезапустите приложение и попробуйте ещё раз.',
            ),
            (StartupFailed(), false) => (
              'Want Pass could not start.',
              'Restart the application and try again.',
            ),
            (StartupLoading(), true) => ('Запуск Want Pass…', ''),
            (StartupLoading(), false) => ('Starting Want Pass…', ''),
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 20,
                        children: [
                          const WantTypography(
                            'Want Pass',
                            variant: WantTypographyVariant.h1,
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
