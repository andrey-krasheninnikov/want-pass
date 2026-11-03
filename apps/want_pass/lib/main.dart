import 'package:flutter/widgets.dart';
import 'package:launch_mode/launch_mode.dart';
import 'package:want_pass/src/core/_barrel.dart';
import 'package:want_pass/src/feature/_common/presentation/_barrel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LaunchMode.initializeAutomatically();
  final runtime = await AppRuntime.bootstrap();
  runApp(WantPassApp(startup: runtime.startup, vault: runtime.vault));
}
