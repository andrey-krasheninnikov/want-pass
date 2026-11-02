import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:injectable_generator/generators/injectable_config_generator.dart';
import 'package:source_gen/source_gen.dart';

Builder registrationBuilder(BuilderOptions options) => LibraryBuilder(
  InjectableConfigGenerator(),
  generatedExtension: '.config.dart',
  additionalOutputExtensions: ['.module.dart'],
  header: '',
  writeDescriptions: false,
  formatOutput: (code, version) =>
      DartFormatter(languageVersion: version)
          .format(normalizeRegistrationImports(code)),
);

// Keep registration imports on the application's public layer boundaries.
String normalizeRegistrationImports(String code) {
  final aliases = <String, String>{};
  final replacements = <String, String>{};
  final imports = RegExp(r"import\s+'([^']+)'\s+as\s+(\w+);");
  var normalized = code.replaceAllMapped(imports, (match) {
    final uri = match[1]!;
    final alias = match[2]!;
    final layer = RegExp(
      r'^(package:want_pass/src/feature/[^/]+/(?:application|domain|infrastructure|presentation))/',
    ).firstMatch(uri);
    final publicUri = layer == null ? uri : '${layer[1]}/_barrel.dart';
    final previous = aliases[publicUri];
    if (previous != null) {
      replacements[alias] = previous;
      return '';
    }
    aliases[publicUri] = alias;
    return "import '$publicUri' as $alias;";
  });
  for (final entry in replacements.entries) {
    normalized = normalized.replaceAll(
      RegExp('\\b${entry.key}\\.'),
      '${entry.value}.',
    );
  }
  return normalized;
}
