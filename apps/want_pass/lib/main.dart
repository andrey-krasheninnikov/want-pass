import 'package:flutter/material.dart';
import 'package:launch_mode/launch_mode.dart';
import 'package:want_allure/want_allure.dart';
import 'package:want_pass/src/core/_barrel.dart';
import 'package:want_pass/src/feature/_common/presentation/_barrel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LaunchMode.initializeAutomatically();
  try {
    final runtime = await AppRuntime.bootstrap();
    presentWantPass(
      WantPassApp(
        startup: runtime.startup,
        vault: runtime.vault,
        appearance: runtime.appearance,
      ),
    );
  } on Object {
    final ru =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode == 'ru';
    presentWantPass(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: WantTheme(
          data: WantThemeData.dark(),
          child: Material(
            color: WantThemeData.dark().color('background'),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: WantCard(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 16,
                    children: [
                      Image.asset(
                        'assets/brand/logo-dark.png',
                        width: 96,
                        height: 96,
                        excludeFromSemantics: true,
                      ),
                      WantTypography(
                        ru ? 'Запуск недоступен' : 'Startup unavailable',
                        variant: WantTypographyVariant.h2,
                      ),
                      Text(
                        ru
                            ? 'Перезапустите приложение и повторите попытку.'
                            : 'Restart the application and try again.',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
