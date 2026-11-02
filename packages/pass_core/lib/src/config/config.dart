import 'package:package_context/package_context.dart';

final class Config extends PackageConfig {
  final bool isForeground;

  const Config({required this.isForeground});
}
