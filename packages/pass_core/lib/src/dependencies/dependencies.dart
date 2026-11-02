import 'package:package_context/package_context.dart';
import 'package:want_pass_core/src/application/_barrel.dart';

final class Dependencies extends PackageDependencies {
  final StartupReporter reporter;

  const Dependencies({required this.reporter});
}
