import 'package:package_context/package_context.dart';
import 'package:want_pass_core/src/config/_barrel.dart';
import 'package:want_pass_core/src/dependencies/_barrel.dart';
import 'package:want_pass_core/src/feature/startup/application/_barrel.dart';
import 'package:want_pass_core/src/feature/startup/domain/_barrel.dart';
import 'package:want_pass_core/src/feature/startup/infrastructure/_barrel.dart';

CoreRuntime? _runtime;

final class CoreRuntime {
  final Config _config;
  final Dependencies _dependencies;
  final StartupAccessService startupAccessService;

  const CoreRuntime._(
    this._config,
    this._dependencies,
    this.startupAccessService,
  );

  void close() {
    if (identical(_runtime, this)) {
      _runtime = null;
    }
  }
}

CoreRuntime initPackage({
  required Config config,
  required Dependencies dependencies,
}) {
  final existing = _runtime;
  if (existing != null) {
    if (existing._config.isForeground == config.isForeground &&
        identical(existing._dependencies.reporter, dependencies.reporter)) {
      return existing;
    }
    throw const StartupConfigurationConflictErrorV1();
  }
  final context = PackageContext<Config, Dependencies>()
    ..initialize(PackageGraph(config: config, dependencies: dependencies));
  return _runtime = CoreRuntime._(
    config,
    dependencies,
    StartupAccessServiceImpl(context, dependencies.reporter),
  );
}
