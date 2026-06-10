// ignore_for_file: avoid_print

import 'dart:io';

void main(List<String> args) {
  String? overrideFeature;
  String? rawInput;
  bool? isStateful;
  bool? includeController;
  bool? includeState;

  for (final arg in args) {
    if (arg.startsWith('--') && arg.length > 2) {
      final val = arg.substring(2).toLowerCase();
      if (val == 'stateful' || val == 'stful') {
        isStateful = true;
      } else if (val == 'stateless' || val == 'widget') {
        isStateful = false;
      } else if (val == 'controller') {
        includeController = true;
      } else if (val == 'no-controller') {
        includeController = false;
      } else if (val == 'state') {
        includeState = true;
        includeController = true;
      } else if (val == 'no-state') {
        includeState = false;
      } else {
        overrideFeature = val;
      }
    } else {
      rawInput ??= arg;
    }
  }

  if (rawInput == null || rawInput.isEmpty) {
    print('❌ Please provide a name.');
    print('Usage:');
    print(
      '  dart run fluxter_create <name>                           → creates in lib/features/<name>/presentation/',
    );
    print(
      '  dart run fluxter_create <name> --<feature>               → creates in lib/features/<feature>/presentation/',
    );
    print(
      '  dart run fluxter_create <name> --stateful / --stateless  → specifies screen widget type',
    );
    print('  dart run fluxter_create <name> --controller / --no-controller');
    print(
      '  dart run fluxter_create <name> --state / --no-state      → generate controller with custom Freezed state',
    );
    print('');
    print('Examples:');
    print('  dart run fluxter_create profile');
    print('  dart run fluxter_create detail --home --stateful --state');
    exit(1);
  }

  final segments = rawInput
      .replaceAll('\\', '/')
      .split('/')
      .map((s) => _toSnakeCase(s))
      .toList();
  final inputPath = segments.join('/');
  final featureName = segments.last;

  if (featureName.isEmpty) {
    print('❌ Invalid name.');
    exit(1);
  }

  final className = _snakeToPascal(featureName);
  final camelName = _snakeToCamel(featureName);

  final targetFeaturePath = overrideFeature ?? inputPath;
  final presentationDir = Directory(
    'lib/features/$targetFeaturePath/presentation',
  );
  final screenFile = File('${presentationDir.path}/${featureName}_screen.dart');
  final controllerFile = File(
    '${presentationDir.path}/${featureName}_controller.dart',
  );

  if (overrideFeature == null) {
    if (presentationDir.existsSync()) {
      print(
        '❌ Feature "$featureName" presentation folder already exists at ${presentationDir.path}',
      );
      exit(1);
    }
  } else {
    if (screenFile.existsSync() || controllerFile.existsSync()) {
      print(
        '❌ Screen or Controller for "$featureName" already exists in feature "$overrideFeature".',
      );
      exit(1);
    }
  }

  if (isStateful == null) {
    print('Choose screen type:');
    print('  1. ConsumerWidget (Stateless) [Default]');
    print('  2. ConsumerStatefulWidget (Stateful)');
    stdout.write('👉 Enter choice (1 or 2, default is 1): ');
    final choice = stdin.readLineSync()?.trim();
    if (choice == '2') {
      isStateful = true;
    } else {
      isStateful = false;
    }
    print('');
  }

  if (includeController == null) {
    print('Choose controller type:');
    print('  1. Simple Controller (without state model) [Default]');
    print('  2. Controller with Freezed State model (ProductState style)');
    print('  3. No controller');
    stdout.write('👉 Enter choice (1, 2, or 3, default is 1): ');
    final choice = stdin.readLineSync()?.trim();
    if (choice == '2') {
      includeController = true;
      includeState = true;
    } else if (choice == '3') {
      includeController = false;
      includeState = false;
    } else {
      includeController = true;
      includeState = false;
    }
    print('');
  }

  if (includeController == false && includeState == true) {
    print('⚠️  Warning: --state is ignored when --no-controller is specified.');
    includeState = false;
  }

  includeState ??= false;

  presentationDir.createSync(recursive: true);

  screenFile.writeAsStringSync(
    _getScreenTemplate(
      featureName,
      className,
      camelName,
      isStateful,
      includeController,
    ),
  );

  final depth = targetFeaturePath.split('/').length + 2;
  final genPrefix = '../' * depth;

  if (includeController) {
    if (includeState) {
      controllerFile.writeAsStringSync(
        _getControllerWithStateTemplate(
          featureName,
          className,
          camelName,
          genPrefix,
          targetFeaturePath,
        ),
      );
    } else {
      controllerFile.writeAsStringSync(
        _getControllerTemplate(
          featureName,
          className,
          camelName,
          genPrefix,
          targetFeaturePath,
        ),
      );
    }
  }

  print(
    '✅ Successfully created "$featureName" at lib/features/$targetFeaturePath',
  );
  print('   - ${screenFile.path}');
  if (includeController) {
    print('   - ${controllerFile.path}');
  }
  print('\n⚠️  Don\'t forget to:');
  print(
    '   1. Register your route for ${className}Screen in lib/app/router/app_router.dart',
  );
  if (includeController) {
    print(
      '   2. Run: dart run build_runner build --delete-conflicting-outputs',
    );
  }
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

String _snakeToTitle(String text) {
  return text
      .split('_')
      .map((e) => e.isNotEmpty ? '${e[0].toUpperCase()}${e.substring(1)}' : '')
      .join(' ');
}

String _getScreenTemplate(
  String snake,
  String pascal,
  String camel,
  bool isStateful,
  bool includeController,
) {
  final kebab = snake.replaceAll('_', '-');
  final title = _snakeToTitle(snake);
  final controllerImport = includeController
      ? "import '${snake}_controller.dart';\n"
      : "";
  final controllerWatch = includeController
      ? "    // ignore: unused_local_variable\n    final state = ref.watch(${camel}ControllerProvider);\n"
      : "";

  if (isStateful) {
    return '''import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
$controllerImport
class ${pascal}Screen extends ConsumerStatefulWidget {
  const ${pascal}Screen({super.key});

  static const routePath = '/$kebab';

  @override
  ConsumerState<${pascal}Screen> createState() => _${pascal}ScreenState();
}

class _${pascal}ScreenState extends ConsumerState<${pascal}Screen> {
  @override
  Widget build(BuildContext context) {
$controllerWatch
    return Scaffold(
      appBar: AppBar(
        title: const Text('$title'),
      ),
      body: const Text('$title Content'),
    );
  }
}
''';
  } else {
    return '''import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
$controllerImport
class ${pascal}Screen extends ConsumerWidget {
  const ${pascal}Screen({super.key});

  static const routePath = '/$kebab';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
$controllerWatch
    return Scaffold(
      appBar: AppBar(
        title: const Text('$title'),
      ),
      body: const Text('$title Content'),
    );
  }
}
''';
  }
}

String _getControllerTemplate(
  String snake,
  String pascal,
  String camel,
  String genPrefix,
  String targetFeaturePath,
) {
  return '''import 'package:riverpod_annotation/riverpod_annotation.dart';

part '${genPrefix}gen/features/$targetFeaturePath/presentation/${snake}_controller.g.dart';

@riverpod
class ${pascal}Controller extends _\$${pascal}Controller {
  @override
  void build() {
    // TODO: Initialize state
  }

  // TODO: Add variables and methods here
}
''';
}

String _getControllerWithStateTemplate(
  String snake,
  String pascal,
  String camel,
  String genPrefix,
  String targetFeaturePath,
) {
  return '''import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part '${genPrefix}gen/features/$targetFeaturePath/presentation/${snake}_controller.g.dart';
part '${genPrefix}gen/features/$targetFeaturePath/presentation/${snake}_controller.freezed.dart';

@freezed
abstract class ${pascal}State with _\$${pascal}State {
  const factory ${pascal}State({
    @Default(false) bool isLoading,
    String? errorMessage,
    // TODO: Add more state fields here
  }) = _${pascal}State;
}

@riverpod
class ${pascal}Controller extends _\$${pascal}Controller {
  @override
  ${pascal}State build() {
    return const ${pascal}State();
  }

  // TODO: Add methods to manipulate state here
}
''';
}
