import 'package:flutter/material.dart';
import 'package:forui/forui.dart'
    show FAccessibility, FAccessibilityMotion, FBasicTheme, FThemeData;
import 'package:want_pass/src/feature/appearance/application/_barrel.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:want_allure/want_allure.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:want_pass/src/feature/startup/application/_barrel.dart';
import 'package:want_pass/src/feature/vault/application/_barrel.dart';
import 'package:want_pass/src/feature/vault/presentation/_barrel.dart';

class WantPassApp extends StatefulWidget {
  final StartupController startup;
  final VaultController vault;
  final AppearanceController? appearance;
  final bool playStartupIntro;
  final GlobalKey<NavigatorState>? navigatorKey;

  const WantPassApp({
    super.key,
    required this.startup,
    required this.vault,
    this.appearance,
    this.playStartupIntro = false,
    this.navigatorKey,
  });

  @override
  State<WantPassApp> createState() => _WantPassAppState();
}

class _WantPassAppState extends State<WantPassApp> {
  late bool _intro = widget.playStartupIntro;
  final _light = WantThemeData.light(), _dark = WantThemeData.dark();
  final _materialLight = ThemeData.light(), _materialDark = ThemeData.dark();

  @override
  Widget build(BuildContext context) {
    final preferences = widget.appearance;
    if (preferences == null) return _application(const AppearanceState());
    return BlocBuilder<AppearanceController, AppearanceState>(
      bloc: preferences,
      builder: (context, state) => _application(state),
    );
  }

  Widget _application(AppearanceState appearanceState) => MaterialApp(
    title: 'Want Pass',
    navigatorKey: widget.navigatorKey,
    debugShowCheckedModeBanner: false,
    locale: appearanceState.settings.language == null
        ? null
        : Locale(appearanceState.settings.language!.name),
    themeMode: switch (appearanceState.settings.theme) {
      AppearanceThemeV1.system => ThemeMode.system,
      AppearanceThemeV1.light => ThemeMode.light,
      AppearanceThemeV1.dark => ThemeMode.dark,
    },
    theme: _materialLight,
    darkTheme: _materialDark,
    themeAnimationStyle: AnimationStyle.noAnimation,
    supportedLocales: const [Locale('en'), Locale('ru')],
    localizationsDelegates: const [
      ...GlobalMaterialLocalizations.delegates,
      ...FLocalizations.localizationsDelegates,
    ],
    builder: (context, child) {
      final target = Theme.of(context).brightness == Brightness.dark
          ? 1.0
          : 0.0;
      final reduced =
          MediaQuery.disableAnimationsOf(context) ||
          MediaQuery.accessibleNavigationOf(context) ||
          WidgetsBinding
              .instance
              .platformDispatcher
              .accessibilityFeatures
              .reduceMotion;
      final animate =
          !reduced &&
          TickerMode.valuesOf(context).enabled &&
          !MediaQuery.highContrastOf(context);
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: target, end: target),
        duration: animate ? const Duration(milliseconds: 360) : Duration.zero,
        curve: Curves.easeInOutCubic,
        child: WantToaster(child: child!),
        builder: (context, value, child) {
          final progress = animate ? value : target;
          final theme = switch (progress) {
            0 => _light,
            1 => _dark,
            _ => WantThemeData(
              colors: {
                for (final role in _light.colors.keys)
                  role: Color.lerp(
                    _light.color(role),
                    _dark.color(role),
                    progress,
                  )!,
              },
              forui: FThemeData.lerp(_light.forui, _dark.forui, progress),
            ),
          };
          return Theme(
            data: ThemeData.lerp(_materialLight, _materialDark, progress),
            child: WantTheme(
              data: theme,
              reduceMotion: reduced,
              child: FBasicTheme(
                data: theme.forui,
                accessibility: FAccessibility(
                  accessibleNavigation: MediaQuery.accessibleNavigationOf(
                    context,
                  ),
                  motion: reduced
                      ? FAccessibilityMotion.disabled
                      : FAccessibilityMotion.all,
                  focusHighlight: true,
                ),
                child: DefaultTextStyle(
                  style: theme.forui.typography.body.sm.copyWith(
                    fontSize: 16,
                    height: 1.7,
                  ),
                  child: child!,
                ),
              ),
            ),
          );
        },
      );
    },
    home: BlocProvider.value(
      value: widget.startup,
      child: BlocBuilder<StartupController, StartupState>(
        builder: (context, state) {
          if (state is StartupReady) {
            if (_intro) {
              return VaultMoment(
                startup: true,
                title: 'Want Pass',
                onComplete: () {
                  if (mounted) setState(() => _intro = false);
                },
              );
            }
            return VaultPage(
              controller: widget.vault,
              appearance: widget.appearance,
            );
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
