// ignore_for_file: avoid_print

import 'dart:io';

void main(List<String> args) {
  final keysFile = File('lib/app/localization/translation_keys.dart');
  final enFile = File('lib/app/localization/en_us.dart');
  final idFile = File('lib/app/localization/id_id.dart');

  if (!keysFile.existsSync() || !enFile.existsSync() || !idFile.existsSync()) {
    print('❌ Localization files not found under lib/app/localization/');
    exit(1);
  }

  print('🌐 Fluxter Translation Generator');
  print('================================');

  String? keyArg = args.isNotEmpty ? args[0] : null;
  String? enArg;
  String? idArg;

  if (args.length > 1) {
    if (args.length > 3 || args[1].startsWith('--')) {
      final joinedArgs = args.skip(1).join(' ');
      final parts = joinedArgs
          .split(RegExp(r'\s*--'))
          .where((s) => s.trim().isNotEmpty)
          .toList();
      if (parts.isNotEmpty) enArg = parts[0].replaceAll('"', '').trim();
      if (parts.length > 1) idArg = parts[1].replaceAll('"', '').trim();
    } else {
      enArg = args[1].replaceAll('"', '').trim();
      if (args.length > 2) idArg = args[2].replaceAll('"', '').trim();
    }
  }

  // 1. Get Translation Key
  String? key;
  while (true) {
    String? input;
    if (keyArg != null) {
      input = keyArg;
      keyArg = null; // Clear so we prompt if invalid
    } else {
      stdout.write('🔑 Enter Translation Key (e.g. errorConnection): ');
      input = stdin.readLineSync()?.trim();
    }

    if (input == null || input.isEmpty) {
      print('❌ Key cannot be empty.');
      if (args.isNotEmpty) exit(1);
      continue;
    }
    if (!RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*$').hasMatch(input)) {
      print(
        '❌ Invalid format. Must start with a letter and contain only alphanumeric/underscore characters (no spaces).',
      );
      if (args.isNotEmpty) exit(1);
      continue;
    }

    // Check if key already exists
    final keysContent = keysFile.readAsStringSync();
    if (keysContent.contains('static const $input =') ||
        keysContent.contains('static const $input ')) {
      print('❌ Key "$input" already exists in translation_keys.dart.');
      if (args.isNotEmpty) exit(1);
      continue;
    }

    key = input;
    break;
  }

  // 2. Get English Translation
  String? enVal;
  while (true) {
    String? input;
    if (enArg != null) {
      input = enArg;
      enArg = null;
    } else {
      stdout.write('🇺🇸 Enter English (EN) string: ');
      input = stdin.readLineSync()?.trim();
    }

    if (input == null || input.isEmpty) {
      print('❌ English string cannot be empty.');
      if (args.isNotEmpty) exit(1);
      continue;
    }
    enVal = input;
    break;
  }

  // 3. Get Indonesian Translation
  String? idVal;
  while (true) {
    String? input;
    if (idArg != null) {
      input = idArg;
      idArg = null;
    } else {
      stdout.write('🇮🇩 Enter Indonesian (ID) string: ');
      input = stdin.readLineSync()?.trim();
    }

    if (input == null || input.isEmpty) {
      print('❌ Indonesian string cannot be empty.');
      if (args.isNotEmpty) exit(1);
      continue;
    }
    idVal = input;
    break;
  }

  // Escape single quotes for Dart string compatibility
  final enEscaped = enVal.replaceAll("'", "\\'");
  final idEscaped = idVal.replaceAll("'", "\\'");

  // Update translation_keys.dart
  final keysContent = keysFile.readAsStringSync().trim();

  // Find closing brace of TranslationKeys
  final translationKeysIndex = keysContent.indexOf('class TranslationKeys');
  if (translationKeysIndex == -1) {
    print(
      '❌ Failed to parse translation_keys.dart (TranslationKeys class not found).',
    );
    exit(1);
  }
  final keysBraceIndex = keysContent.indexOf('}', translationKeysIndex);

  // Insert static const key
  var updatedKeysContent =
      '${keysContent.substring(0, keysBraceIndex)}  static const $key = \'$key\';\n${keysContent.substring(keysBraceIndex)}';

  // Find closing brace of AppTranslationsWrapper
  final wrapperIndex = updatedKeysContent.indexOf(
    'class AppTranslationsWrapper',
  );
  if (wrapperIndex == -1) {
    print(
      '❌ Failed to parse translation_keys.dart (AppTranslationsWrapper class not found).',
    );
    exit(1);
  }
  final wrapperBraceIndex = updatedKeysContent.lastIndexOf('}');

  // Check if parameterized
  final hasParams = enVal.contains('@') || idVal.contains('@');
  String wrapperInsert;
  if (hasParams) {
    wrapperInsert =
        '''  String $key(Map<String, String> params) {
    var text = AppTranslations.translate(TranslationKeys.$key);
    params.forEach((k, v) => text = text.replaceAll('@\$k', v));
    return text;
  }
''';
  } else {
    wrapperInsert =
        '  String get $key => AppTranslations.translate(TranslationKeys.$key);\n';
  }

  final finalKeysContent =
      '${updatedKeysContent.substring(0, wrapperBraceIndex)}$wrapperInsert${updatedKeysContent.substring(wrapperBraceIndex)}';
  keysFile.writeAsStringSync('$finalKeysContent\n');

  // Update en_us.dart
  final enContent = enFile.readAsStringSync().trim();
  final lastEnMapCloser = enContent.lastIndexOf('};');
  if (lastEnMapCloser == -1) {
    print('❌ Failed to parse en_us.dart (closing "};" not found).');
    exit(1);
  }
  final newEnContent =
      '${enContent.substring(0, lastEnMapCloser)}  TranslationKeys.$key: \'$enEscaped\',\n${enContent.substring(lastEnMapCloser)}';
  enFile.writeAsStringSync('$newEnContent\n');

  // Update id_id.dart
  final idContent = idFile.readAsStringSync().trim();
  final lastIdMapCloser = idContent.lastIndexOf('};');
  if (lastIdMapCloser == -1) {
    print('❌ Failed to parse id_id.dart (closing "};" not found).');
    exit(1);
  }
  final newIdContent =
      '${idContent.substring(0, lastIdMapCloser)}  TranslationKeys.$key: \'$idEscaped\',\n${idContent.substring(lastIdMapCloser)}';
  idFile.writeAsStringSync('$newIdContent\n');

  print('\n✅ Localization keys and values added successfully!');
  print('   - Key: $key');
  print('   - EN: "$enVal"');
  print('   - ID: "$idVal"');
}
