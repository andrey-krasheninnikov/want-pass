import 'package:flutter_test/flutter_test.dart';

import '../tool/registration_builder.dart';

void main() {
  test(
    'DI registration uses one root layer import and preserves external imports',
    () {
      const input =
          "import 'package:want_pass/src/feature/startup/application/controller/controller.dart' as _i1;\n"
          "import 'package:want_pass/src/feature/startup/application/use_case/use_case_impl.dart' as _i2;\n"
          "import 'package:want_pass_core/want_pass_core.dart' as _i3;\n"
          'final controller = _i1.StartupController(_i2.StartupUseCaseImpl());';
      final output = normalizeRegistrationImports(input);
      expect(
        output,
        contains(
          "import 'package:want_pass/src/feature/startup/application/_barrel.dart' as _i1;",
        ),
      );
      expect(output, isNot(contains('as _i2')));
      expect(output, contains('_i1.StartupUseCaseImpl()'));
      expect(
        output,
        contains("import 'package:want_pass_core/want_pass_core.dart' as _i3;"),
      );
      expect(normalizeRegistrationImports(output), output);
    },
  );
}
