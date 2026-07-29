// ignore_for_file: avoid_print

import 'dart:io';

void main(List<String> args) {
  String? overrideFeature;
  String? rawInput;
  bool? includeState;
  bool hasRepository = false;

  for (final arg in args) {
    if (arg.startsWith('--') && arg.length > 2) {
      final val = arg.substring(2).toLowerCase();
      if (val == 'state') {
        includeState = true;
      } else if (val == 'no-state') {
        includeState = false;
      } else if (val == 'repository') {
        hasRepository = true;
      } else {
        overrideFeature = val;
      }
    } else {
      rawInput ??= arg;
    }
  }

  if (rawInput == null || rawInput.isEmpty) {
    print('❌ Please provide a controller name.');
    print('Usage:');
    print(
      '  dart run :fluxter_controller <name> [--<feature>] [--state] [--repository]',
    );
    print('');
    print('Flags:');
    print(
      '  --state            → Include a Freezed state model in the controller',
    );
    print(
      '  --repository       → Inject repository dependency into the controller',
    );
    print(
      '  --<feature>        → Target feature folder (defaults to name itself)',
    );
    print('');
    print('Examples:');
    print('  dart run :fluxter_controller profile');
    print('  dart run :fluxter_controller earn_points --points --state');
    print(
      '  dart run :fluxter_controller payment --state --repository',
    );
    exit(1);
  }

  // Read project name from pubspec.yaml
  final projectName = _getProjectName();
  if (projectName == null) {
    print('❌ Cannot read project name from pubspec.yaml.');
    print('   Make sure you are running this from the project root directory.');
    exit(1);
  }

  final segments = rawInput
      .replaceAll('\\', '/')
      .split('/')
      .map((s) => _toSnakeCase(s))
      .toList();
  final controllerName = segments.last;

  if (controllerName.isEmpty) {
    print('❌ Invalid controller name.');
    exit(1);
  }

  final className = _snakeToPascal(controllerName);
  final camelName = _snakeToCamel(controllerName);

  final targetFeaturePath = overrideFeature ?? segments.join('/');
  final presentationDir = Directory(
    'lib/features/$targetFeaturePath/presentation',
  );
  final controllerFile = File(
    '${presentationDir.path}/${controllerName}_controller.dart',
  );

  if (controllerFile.existsSync()) {
    print(
      '❌ Controller "${controllerName}_controller.dart" already exists at ${controllerFile.path}',
    );
    exit(1);
  }

  if (includeState == null) {
    print('Choose controller type:');
    print('  1. Simple Controller (without state model) [Default]');
    print('  2. Controller with Freezed State model');
    stdout.write('👉 Enter choice (1 or 2, default is 1): ');
    final choice = stdin.readLineSync()?.trim();
    if (choice == '2') {
      includeState = true;
    } else {
      includeState = false;
    }
    print('');
  }

  presentationDir.createSync(recursive: true);

  final depth = targetFeaturePath.split('/').length + 2;
  final genPrefix = '../' * depth;

  if (includeState) {
    controllerFile.writeAsStringSync(
      _getControllerWithStateTemplate(
        controllerName,
        className,
        camelName,
        genPrefix,
        targetFeaturePath,
        hasRepository,
        projectName,
      ),
    );
  } else {
    controllerFile.writeAsStringSync(
      _getControllerTemplate(
        controllerName,
        className,
        camelName,
        genPrefix,
        targetFeaturePath,
        hasRepository,
        projectName,
      ),
    );
  }

  print(
    '✅ Successfully created "${className}Controller" at ${controllerFile.path}',
  );
  print('\n⚠️  Don\'t forget to run:');
  print('   dart run build_runner build --delete-conflicting-outputs');
}

String _toSnakeCase(String text) {
  final camelOrPascalPattern = RegExp(
    r'(?<=[a-z0-9])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])',
  );
  return text
      .replaceAll('_', ' ')
      .replaceAll('-', ' ')
      .split(camelOrPascalPattern)
      .expand((element) => element.split(' '))
      .where((element) => element.isNotEmpty)
      .map((w) => w.toLowerCase())
      .join('_');
}

String _snakeToPascal(String text) {
  return text
      .split('_')
      .map((e) => e.isNotEmpty ? '${e[0].toUpperCase()}${e.substring(1)}' : '')
      .join('');
}

String _snakeToCamel(String text) {
  final pascal = _snakeToPascal(text);
  return pascal.isNotEmpty
      ? '${pascal[0].toLowerCase()}${pascal.substring(1)}'
      : '';
}

String _getControllerTemplate(
  String snake,
  String pascal,
  String camel,
  String genPrefix,
  String targetFeaturePath,
  bool hasRepository,
  String projectName,
) {
  final buffer = StringBuffer();

  buffer.writeln("import 'package:riverpod_annotation/riverpod_annotation.dart';");
  if (hasRepository) {
    buffer.writeln(
      "import 'package:$projectName/features/$targetFeaturePath/data/${snake}_repository.dart';",
    );
  }
  buffer.writeln();

  buffer.writeln(
    "part '${genPrefix}gen/features/$targetFeaturePath/presentation/${snake}_controller.g.dart';",
  );
  buffer.writeln();

  buffer.writeln('@riverpod');
  buffer.writeln('class ${pascal}Controller extends _\$${pascal}Controller {');
  buffer.writeln('  @override');
  buffer.writeln('  void build() {');
  if (hasRepository) {
    buffer.writeln(
      '    // ignore: unused_local_variable',
    );
    buffer.writeln(
      '    final repository = ref.watch(${camel}RepositoryProvider);',
    );
  }
  buffer.writeln('    // TODO: Initialize state');
  buffer.writeln('  }');
  buffer.writeln();
  buffer.writeln('  // TODO: Add variables and methods here');
  buffer.writeln('}');

  return buffer.toString();
}

String _getControllerWithStateTemplate(
  String snake,
  String pascal,
  String camel,
  String genPrefix,
  String targetFeaturePath,
  bool hasRepository,
  String projectName,
) {
  final buffer = StringBuffer();

  buffer.writeln("import 'package:riverpod_annotation/riverpod_annotation.dart';");
  buffer.writeln("import 'package:freezed_annotation/freezed_annotation.dart';");
  if (hasRepository) {
    buffer.writeln(
      "import 'package:$projectName/features/$targetFeaturePath/data/${snake}_repository.dart';",
    );
  }
  buffer.writeln();

  buffer.writeln(
    "part '${genPrefix}gen/features/$targetFeaturePath/presentation/${snake}_controller.g.dart';",
  );
  buffer.writeln(
    "part '${genPrefix}gen/features/$targetFeaturePath/presentation/${snake}_controller.freezed.dart';",
  );
  buffer.writeln();

  buffer.writeln('@freezed');
  buffer.writeln('abstract class ${pascal}State with _\$${pascal}State {');
  buffer.writeln('  const factory ${pascal}State({');
  buffer.writeln('    @Default(false) bool isLoading,');
  buffer.writeln('    String? errorMessage,');
  buffer.writeln('    // TODO: Add more state fields here');
  buffer.writeln('  }) = _${pascal}State;');
  buffer.writeln('}');
  buffer.writeln();

  buffer.writeln('@riverpod');
  buffer.writeln('class ${pascal}Controller extends _\$${pascal}Controller {');
  buffer.writeln('  @override');
  buffer.writeln('  ${pascal}State build() {');
  if (hasRepository) {
    buffer.writeln(
      '    // ignore: unused_local_variable',
    );
    buffer.writeln(
      '    final repository = ref.watch(${camel}RepositoryProvider);',
    );
  }
  buffer.writeln('    return const ${pascal}State();');
  buffer.writeln('  }');
  buffer.writeln();
  buffer.writeln('  // TODO: Add methods to manipulate state here');
  buffer.writeln('}');

  return buffer.toString();
}

String? _getProjectName() {
  final pubspecFile = File('pubspec.yaml');
  if (!pubspecFile.existsSync()) return null;
  final lines = pubspecFile.readAsStringSync().split('\n');
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.startsWith('name:')) {
      return trimmed
          .substring(5)
          .trim()
          .replaceAll(RegExp(r"""['"]"""), '')
          .trim();
    }
  }
  return null;
}
