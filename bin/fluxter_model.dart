// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    print('❌ Please provide a model name.');
    print('Usage:');
    print(
      '  dart run :fluxter_model <model_name>              → creates in lib/features/shared/domain/',
    );
    print(
      '  dart run :fluxter_model <model_name> --<feature>  → creates in lib/features/<feature>/domain/',
    );
    print('');
    print('Examples:');
    print('  dart run :fluxter_model profile');
    print('  dart run :fluxter_model user --profile');
    exit(1);
  }

  final rawInput = args.first;

  if (rawInput.isEmpty) {
    print('❌ Invalid model name.');
    exit(1);
  }

  // Parse flags
  String featureName = 'shared';
  bool noBuild = false;
  for (final arg in args.skip(1)) {
    if (arg == '--no-build') {
      noBuild = true;
    } else if (arg.startsWith('--') && arg.length > 2) {
      featureName = arg.substring(2).toLowerCase();
    }
  }

  final snakeName = _toSnakeCase(rawInput);
  final className = _snakeToPascal(snakeName);

  final dir = Directory('lib/features/$featureName/domain');
  final modelFile = File('${dir.path}/$snakeName.dart');

  if (modelFile.existsSync()) {
    print(
      '❌ Model "$className" ($snakeName.dart) already exists at ${modelFile.path}',
    );
    exit(1);
  }

  print('📝 Please paste/enter your JSON string:');
  print(
    '💡 (Tip: Paste your JSON and press Enter. The script will automatically finish when it detects a complete, valid JSON.)',
  );
  print('---');

  final lines = <String>[];
  while (true) {
    final line = stdin.readLineSync();
    if (line == null) break;
    final trimmed = line.trim();
    if (trimmed == 'q' || trimmed == 'exit') {
      print('👋 Cancelled.');
      exit(0);
    }
    lines.add(line);

    // Auto-detect complete JSON
    final currentText = lines.join('\n').trim();
    if (currentText.isNotEmpty) {
      try {
        final decoded = json.decode(currentText);
        if (decoded is Map<String, dynamic> || decoded is List) {
          break; // Successfully parsed valid JSON, stop reading
        }
      } catch (_) {
        // Not a complete JSON yet, continue reading lines
      }
    }
  }

  final jsonStr = lines.join('\n').trim();
  if (jsonStr.isEmpty) {
    print('❌ Input JSON cannot be empty.');
    exit(1);
  }

  Map<String, dynamic> jsonMap;
  try {
    final decoded = json.decode(jsonStr);
    if (decoded is Map<String, dynamic>) {
      jsonMap = decoded;
    } else if (decoded is List &&
        decoded.isNotEmpty &&
        decoded.first is Map<String, dynamic>) {
      jsonMap = decoded.first as Map<String, dynamic>;
    } else {
      print(
        '❌ Invalid JSON format. It must be a Map or a List containing Maps.',
      );
      exit(1);
    }
  } catch (e) {
    print('❌ Failed to parse JSON: $e');
    exit(1);
  }

  dir.createSync(recursive: true);

  final templateContent = _generateFreezedTemplate(
    className,
    snakeName,
    featureName,
    jsonMap,
  );

  modelFile.writeAsStringSync(templateContent);

  print('---');
  print(
    '✅ Successfully created Freezed model "$className" at ${modelFile.path}',
  );

  if (!noBuild) {
    print('\n⏳ Running build_runner to generate code files...');
    try {
      final process = await Process.start('dart', [
        'run',
        'build_runner',
        'build',
      ], runInShell: true);

      await stdout.addStream(process.stdout);
      await stderr.addStream(process.stderr);

      final exitCode = await process.exitCode;
      if (exitCode == 0) {
        print('\n✅ Code generation completed successfully!');
      } else {
        print('\n❌ Code generation failed with exit code $exitCode');
      }
    } catch (e) {
      print('\n❌ Failed to run build_runner: $e');
    }
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

String _sanitizeKey(String key) {
  final clean = key.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
  return _snakeToCamel(clean);
}

class ClassDefinition {
  final String name;
  final Map<String, dynamic> jsonMap;
  ClassDefinition(this.name, this.jsonMap);
}

final List<ClassDefinition> _classesToGenerate = [];
final Set<String> _visitedClasses = {};

String _collectClasses(String className, Map<String, dynamic> jsonMap) {
  var uniqueName = className;
  var counter = 1;
  while (true) {
    final existing = _classesToGenerate.firstWhere(
      (c) => c.name == uniqueName,
      orElse: () => ClassDefinition('', {}),
    );
    if (existing.name.isEmpty) {
      break;
    }
    if (_hasSameStructure(existing.jsonMap, jsonMap)) {
      return uniqueName;
    }
    uniqueName = '$className$counter';
    counter++;
  }

  _classesToGenerate.add(ClassDefinition(uniqueName, jsonMap));
  return uniqueName;
}

void _collectAllClasses(String className, Map<String, dynamic> jsonMap) {
  final uniqueName = _collectClasses(className, jsonMap);
  if (_visitedClasses.contains(uniqueName)) {
    return;
  }
  _visitedClasses.add(uniqueName);

  jsonMap.forEach((key, val) {
    if (val is Map) {
      _collectAllClasses(_snakeToPascal(key), Map<String, dynamic>.from(val));
    } else if (val is List && val.isNotEmpty && val.first is Map) {
      _collectAllClasses(
        _snakeToPascal(key),
        Map<String, dynamic>.from(val.first),
      );
    }
  });
}

bool _hasSameStructure(Map<String, dynamic> a, Map<String, dynamic> b) {
  if (a.length != b.length) return false;
  for (final key in a.keys) {
    if (!b.containsKey(key)) return false;
    if (a[key].runtimeType != b[key].runtimeType) return false;
  }
  return true;
}

String _getClassNameFor(dynamic value, String fallbackName) {
  if (value is Map) {
    final mapVal = Map<String, dynamic>.from(value);
    final existing = _classesToGenerate.firstWhere(
      (c) => _hasSameStructure(c.jsonMap, mapVal),
      orElse: () => ClassDefinition('', {}),
    );
    if (existing.name.isNotEmpty) {
      return existing.name;
    }
  }
  if (value is List && value.isNotEmpty && value.first is Map) {
    final mapVal = Map<String, dynamic>.from(value.first);
    final existing = _classesToGenerate.firstWhere(
      (c) => _hasSameStructure(c.jsonMap, mapVal),
      orElse: () => ClassDefinition('', {}),
    );
    if (existing.name.isNotEmpty) {
      return existing.name;
    }
  }
  return fallbackName;
}

String _resolveFieldType(String parentClassName, String key, dynamic value) {
  if (value is Map) {
    final nestedClassName = _getClassNameFor(value, _snakeToPascal(key));
    return '$nestedClassName?';
  }
  if (value is List) {
    if (value.isEmpty) return 'List<dynamic>?';
    final first = value.first;
    if (first is Map) {
      final nestedClassName = _getClassNameFor(value, _snakeToPascal(key));
      return 'List<$nestedClassName>?';
    }
    if (first is int) return 'List<int>?';
    if (first is double) return 'List<double>?';
    if (first is bool) return 'List<bool>?';
    if (first is String) return 'List<String>?';
    return 'List<dynamic>?';
  }
  if (value is int) return 'int?';
  if (value is double) return 'double?';
  if (value is bool) return 'bool?';
  if (value is String) return 'String?';
  return 'dynamic';
}

String _generateClassTemplate(ClassDefinition def) {
  final className = def.name;
  final jsonMap = def.jsonMap;

  final buffer = StringBuffer();
  buffer.writeln("@freezed");
  buffer.writeln("abstract class $className with _\$$className {");
  buffer.writeln("  const factory $className({");

  jsonMap.forEach((key, val) {
    final type = _resolveFieldType(className, key, val);
    final propName = _sanitizeKey(key);
    buffer.writeln("    @JsonKey(name: '$key') $type $propName,");
  });

  buffer.writeln("  }) = _$className;");
  buffer.writeln();
  buffer.writeln(
    "  factory $className.fromJson(Map<String, dynamic> json) => _\$${className}FromJson(json);",
  );
  buffer.writeln("}");
  return buffer.toString();
}

String _generateFreezedTemplate(
  String className,
  String snakeName,
  String featureName,
  Map<String, dynamic> jsonMap,
) {
  _classesToGenerate.clear();
  _visitedClasses.clear();
  _collectAllClasses(className, jsonMap);

  final genRelativePath =
      '../../../gen/features/$featureName/domain/$snakeName';

  final buffer = StringBuffer();
  buffer.writeln(
    "import 'package:freezed_annotation/freezed_annotation.dart';",
  );
  buffer.writeln();
  buffer.writeln("part '$genRelativePath.freezed.dart';");
  buffer.writeln("part '$genRelativePath.g.dart';");
  buffer.writeln();

  for (final def in _classesToGenerate) {
    buffer.writeln(_generateClassTemplate(def));
    buffer.writeln();
  }

  return buffer.toString();
}
