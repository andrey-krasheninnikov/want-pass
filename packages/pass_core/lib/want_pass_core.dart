import 'package:domain_error/domain_error.dart';
import 'package:package_context/package_context.dart' as package_context;

final class Config extends package_context.PackageConfig {
  final bool isForeground;

  const Config({required this.isForeground});
}

final class Dependencies extends package_context.PackageDependencies {
  const Dependencies();
}

final _context = package_context.PackageContext<Config, Dependencies>();

void initPackage({required Config config, required Dependencies dependencies}) {
  _context.refresh(
    package_context.PackageGraph(config: config, dependencies: dependencies),
  );
}

enum StartupFailureKind { notInitialized, foregroundRequired }

final class StartupFailure extends DomainError {
  final StartupFailureKind kind;

  const StartupFailure(this.kind);

  @override
  String get typeIdentifier => switch (kind) {
    StartupFailureKind.notInitialized => 'application.not_initialized',
    StartupFailureKind.foregroundRequired => 'application.foreground_required',
  };

  @override
  List<Object?> get props => [...super.props, kind];
}

DomainResult<void> checkForegroundStartup() {
  if (!_context.isInitialized) {
    return const Result.error(
      StartupFailure(StartupFailureKind.notInitialized),
    );
  }
  if (!_context.config.isForeground) {
    return const Result.error(
      StartupFailure(StartupFailureKind.foregroundRequired),
    );
  }
  return const Result.success(null);
}
