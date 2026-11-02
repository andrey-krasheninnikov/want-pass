import 'package:domain_error/domain_error.dart';

sealed class StartupErrorV1 extends DomainError {
  const StartupErrorV1({super.cause, super.stackTrace});

  @override
  String get typeIdentifier => 'StartupErrorV1';
}

final class StartupNotInitializedErrorV1 extends StartupErrorV1 {
  const StartupNotInitializedErrorV1();

  @override
  String get typeIdentifier => 'StartupNotInitializedErrorV1';
}

final class StartupForegroundRequiredErrorV1 extends StartupErrorV1 {
  const StartupForegroundRequiredErrorV1();

  @override
  String get typeIdentifier => 'StartupForegroundRequiredErrorV1';
}

final class StartupConfigurationConflictErrorV1 extends StartupErrorV1 {
  const StartupConfigurationConflictErrorV1();

  @override
  String get typeIdentifier => 'StartupConfigurationConflictErrorV1';
}

final class StartupUnexpectedErrorV1 extends StartupErrorV1 {
  const StartupUnexpectedErrorV1({super.cause, super.stackTrace});

  @override
  String get typeIdentifier => 'StartupUnexpectedErrorV1';
}
