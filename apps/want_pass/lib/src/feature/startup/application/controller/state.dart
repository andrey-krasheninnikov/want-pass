part of 'controller.dart';

sealed class StartupState extends Equatable {
  const StartupState();

  @override
  List<Object?> get props => const [];
}

final class StartupLoading extends StartupState {
  const StartupLoading();
}

final class StartupReady extends StartupState {
  const StartupReady();
}

final class StartupFailed extends StartupState {
  final StartupErrorV1 error;

  const StartupFailed(this.error);

  @override
  List<Object?> get props => [error];
}
