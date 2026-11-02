import 'package:flutter/material.dart';
import 'package:want_desyst/want_desyst.dart';

import '../application/startup_cubit.dart';

class WantPassApp extends StatelessWidget {
  final StartupCubit startup;

  const WantPassApp({super.key, required this.startup});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Want Pass',
    debugShowCheckedModeBanner: false,
    supportedLocales: const [Locale('en'), Locale('ru')],
    localizationsDelegates: FLocalizations.localizationsDelegates,
    builder: (context, child) => WantTheme(
      data: WantThemeData.dark(),
      child: WantToaster(child: child!),
    ),
    home: StreamBuilder<StartupState>(
      stream: startup.stream,
      initialData: startup.state,
      builder: (context, snapshot) {
        final russian = Localizations.localeOf(context).languageCode == 'ru';
        final state = snapshot.data ?? StartupState.loading;
        final (title, message) = switch ((state, russian)) {
          (StartupState.ready, true) => (
            'Личное место для ваших секретов.',
            'Создание сейфа пока недоступно в этой версии.',
          ),
          (StartupState.ready, false) => (
            'A private home for your secrets.',
            'Vault setup is not available in this build yet.',
          ),
          (StartupState.failed, true) => (
            'Не удалось запустить Want Pass.',
            'Перезапустите приложение и попробуйте ещё раз.',
          ),
          (StartupState.failed, false) => (
            'Want Pass could not start.',
            'Restart the application and try again.',
          ),
          (StartupState.loading, true) => ('Запуск Want Pass…', ''),
          (StartupState.loading, false) => ('Starting Want Pass…', ''),
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
                          liveRegion: state == StartupState.failed,
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
  );
}
