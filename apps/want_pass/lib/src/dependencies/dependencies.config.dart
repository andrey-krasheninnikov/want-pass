// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:async' as _i687;

import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:want_pass/src/feature/startup/application/_barrel.dart'
    as _i121;

import 'package:want_pass/src/feature/vault/application/_barrel.dart' as _i849;

import 'package:want_pass_core/want_pass_core.dart' as _i73;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.singleton<_i849.VaultUseCase>(
      () => _i849.VaultUseCaseImpl(
        gh<_i73.VaultAccessService>(),
        gh<_i73.VaultReporter>(),
      ),
    );
    await gh.singletonAsync<_i849.VaultController>(
      () {
        final i = _i849.VaultController(
          gh<_i849.VaultUseCase>(),
          gh<_i73.VaultReporter>(),
          gh<_i687.Stream<_i849.VaultLockSignal>>(
            instanceName: 'vaultLockEvents',
          ),
        );
        return i.init().then((_) => i);
      },
      preResolve: true,
      dispose: (i) => i.close(),
    );
    gh.singleton<_i121.StartupUseCase>(
      () => _i121.StartupUseCaseImpl(
        gh<_i73.StartupAccessService>(),
        gh<_i73.StartupReporter>(),
      ),
    );
    await gh.singletonAsync<_i121.StartupController>(
      () {
        final i = _i121.StartupController(
          gh<_i121.StartupUseCase>(),
          gh<_i73.StartupReporter>(),
        );
        return i.init().then((_) => i);
      },
      preResolve: true,
      dispose: (i) => i.close(),
    );
    return this;
  }
}
