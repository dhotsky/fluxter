// ignore_for_file: avoid_print

import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    print('❌ Please provide a repository name.');
    print('Usage:');
    print(
      '  dart run :fluxter_repository <name> [--<feature>] [--api-service] [--local-storage]',
    );
    print('');
    print('Flags:');
    print('  --api-service      → Inject ApiService dependency');
    print('  --local-storage    → Inject LocalStorage dependency');
    print(
      '  --<feature>        → Target feature folder (defaults to name itself)',
    );
    print('');
    print('Examples:');
    print('  dart run :fluxter_repository auth');
    print(
      '  dart run :fluxter_repository payment --api-service --local-storage',
    );
    print('  dart run :fluxter_repository user --profile --local-storage');
    exit(1);
  }

  final rawInput = args.first.replaceAll('\\', '/').split('/').last;

  // Read project name from pubspec.yaml
  final projectName = _getProjectName();
  if (projectName == null) {
    print('❌ Cannot read project name from pubspec.yaml.');
    print('   Make sure you are running this from the project root directory.');
    exit(1);
  }

  final repoName = _toSnakeCase(rawInput);

  if (repoName.isEmpty) {
    print('❌ Invalid repository name.');
    exit(1);
  }

  // Parse optional flags
  bool hasApiService = false;
  bool hasLocalStorage = false;
  String featureName = _toSnakeCase(
    args.first.replaceAll('\\', '/').split('/').first,
  );

  for (final arg in args.skip(1)) {
    if (arg == '--api-service') {
      hasApiService = true;
    } else if (arg == '--local-storage') {
      hasLocalStorage = true;
    } else if (arg.startsWith('--') && arg.length > 2) {
      featureName = arg.substring(2).toLowerCase();
    }
  }

  final className = '${_snakeToPascal(repoName)}Repository';
  final camelName = '${_snakeToCamel(repoName)}Repository';
  final snakeName = '${repoName}_repository';

  final dir = Directory('lib/features/$featureName/data');
  if (dir.existsSync() && File('${dir.path}/$snakeName.dart').existsSync()) {
    print(
      '❌ Repository "$repoName" already exists at ${dir.path}/$snakeName.dart',
    );
    exit(1);
  }

  dir.createSync(recursive: true);

  final file = File('${dir.path}/$snakeName.dart');
  file.writeAsStringSync(
    _getRepositoryTemplate(
      repoName,
      className,
      camelName,
      hasApiService,
      hasLocalStorage,
      projectName,
    ),
  );

  print('✅ Successfully created repository "$className" at ${file.path}');
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

String _getRepositoryTemplate(
  String snake,
  String pascal,
  String camel,
  bool apiService,
  bool localStorage,
  String projectName,
) {
  final buffer = StringBuffer();

  // Imports
  buffer.writeln("import 'package:flutter_riverpod/flutter_riverpod.dart';");
  if (apiService) {
    buffer.writeln("import 'package:$projectName/core/network/api_service.dart';");
  }
  if (localStorage) {
    buffer.writeln("import 'package:$projectName/core/storage/local_storage.dart';");
  }
  buffer.writeln();

  // Class Definition
  buffer.writeln("class $pascal {");
  if (apiService) {
    buffer.writeln("  final ApiService _apiService;");
  }
  if (localStorage) {
    buffer.writeln("  final LocalStorage _localStorage;");
  }
  if (apiService || localStorage) {
    buffer.writeln();
  }

  // Constructor
  buffer.write("  $pascal(");
  final params = <String>[];
  if (apiService) params.add("this._apiService");
  if (localStorage) params.add("this._localStorage");
  buffer.write(params.join(', '));
  buffer.writeln(");");
  buffer.writeln();

  buffer.writeln(
    "  // TODO: Add repository methods here (e.g. API requests, database queries)",
  );
  buffer.writeln("}");
  buffer.writeln();

  // Provider
  buffer.writeln("final ${camel}Provider = Provider<$pascal>((ref) {");
  if (apiService) {
    buffer.writeln("  final apiService = ref.watch(apiServiceProvider);");
  }
  if (localStorage) {
    buffer.writeln("  final localStorage = ref.watch(localStorageProvider);");
  }

  buffer.write("  return $pascal(");
  final callArgs = <String>[];
  if (apiService) callArgs.add("apiService");
  if (localStorage) callArgs.add("localStorage");
  buffer.write(callArgs.join(', '));
  buffer.writeln(");");
  buffer.writeln("});");

  return buffer.toString();
}

String? _getProjectName() {
  final pubspecFile = File('pubspec.yaml');
  if (!pubspecFile.existsSync()) return null;
  final lines = pubspecFile.readAsStringSync().split('\n');
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.startsWith('name:')) {
      return trimmed.substring(5).trim().replaceAll(RegExp(r"""['"]"""), '').trim();
    }
  }
  return null;
}
