import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:launch_mode/launch_mode.dart';
import 'package:talker/talker.dart';
import 'package:want_pass_core/want_pass_core.dart' as core;

import 'application/startup_cubit.dart';
import 'infrastructure/diagnostics.dart';
import 'presentation/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LaunchMode.initializeAutomatically();

  final observer = SafeBlocObserver(talker: Talker());
  Bloc.observer = observer;
  configureErrorReporting(observer);

  core.initPackage(
    config: core.Config(isForeground: LaunchMode.isForeground),
    dependencies: const core.Dependencies(),
  );
  final startup = StartupCubit()..start();
  runApp(WantPassApp(startup: startup));
}
