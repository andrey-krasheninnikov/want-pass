import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:want_pass_core/want_pass_core.dart';
import 'package:want_pass/src/feature/vault/application/_barrel.dart';

import 'package:want_pass/src/dependencies/_barrel.dart';

@InjectableInit(
  preferRelativeImports: false,
  throwOnMissingDependencies: true,
  ignoreUnregisteredTypes: [
    StartupAccessService,
    StartupReporter,
    VaultAccessService,
    VaultReporter,
    Stream<VaultLockSignal>,
  ],
)
Future<GetIt> configureDependencies(GetIt container) => container.init();
