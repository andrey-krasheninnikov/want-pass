import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:bloc_effects/bloc_effects.dart';
import 'package:flutter/widgets.dart';
import 'package:talker/talker.dart';
import 'package:talker_bloc_effects/talker_bloc_effects.dart';

import '../application/startup_cubit.dart';

final class SafeBlocObserver extends BlocObserver
    implements BlocWithEffectsObserver {
  SafeBlocObserver({required Talker talker})
    : _talker = talker,
      _effects = TalkerBlocEffectsObserver(
        talker: talker,
        settings: const TalkerBlocLoggerSettings(
          printEvents: false,
          printTransitions: false,
        ),
        effectsSettings: TalkerBlocEffectsSettings(
          effectFilter: (_, effect) => effect is DiagnosticEvent,
        ),
      );

  final Talker _talker;
  final TalkerBlocEffectsObserver _effects;

  // Only allowlisted effects reach the logger, without their source bloc.
  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    record(DiagnosticEvent.unexpectedError);
  }

  @override
  void onBlocEffect(BlocBase<dynamic> bloc, Object? effect) {
    onEffect(effect);
  }

  @override
  void onEffect<E>(E effect) {
    _effects.onEffect(effect);
  }

  void record(DiagnosticEvent event) {
    _talker.info(event.name);
  }
}

void configureErrorReporting(SafeBlocObserver observer) {
  FlutterError.onError = (_) =>
      observer.record(DiagnosticEvent.unexpectedError);
  PlatformDispatcher.instance.onError = (_, _) {
    observer.record(DiagnosticEvent.unexpectedError);
    return true;
  };
  ErrorWidget.builder = (_) => const Directionality(
    textDirection: TextDirection.ltr,
    child: ColoredBox(
      color: Color(0xFF1A1A1A),
      child: Center(
        child: Text(
          'Want Pass could not display this screen.',
          style: TextStyle(color: Color(0xFFFFFFFF)),
        ),
      ),
    ),
  );
}
