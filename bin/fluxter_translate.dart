// ignore_for_file: avoid_print

import 'dart:io';

void main() {
  final keysFile = File('lib/app/localization/translation_keys.dart');
  final enFile = File('lib/app/localization/en_us.dart');
  final idFile = File('lib/app/localization/id_id.dart');

  if (!keysFile.existsSync() || !enFile.existsSync() || !idFile.existsSync()) {
    print('❌ Localization files not found under lib/app/localization/');
    exit(1);
  }

  print('🌐 Fluxter Translation Generator');
  print('================================');

  // 1. Get Translation Key
  String? key;
  while (true) {
    stdout.write('🔑 Enter Translation Key (e.g. errorConnection): ');
    final input = stdin.readLineSync()?.trim();
    if (input == null || input.isEmpty) {
      print('❌ Key cannot be empty.');
      continue;
    }
    if (!RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*$').hasMatch(input)) {
      print(
        '❌ Invalid format. Must start with a letter and contain only alphanumeric/underscore characters (no spaces).',
      );
      continue;
    }

    // Check if key already exists
    final keysContent = keysFile.readAsStringSync();
    if (keysContent.contains('static const $input =') ||
        keysContent.contains('static const $input ')) {
      print('❌ Key "$input" already exists in translation_keys.dart.');
      continue;
    }

    key = input;
    break;
  }

  // 2. Get English Translation
  String? enVal;
  while (true) {
    stdout.write('🇺🇸 Enter English (EN) string: ');
    final input = stdin.readLineSync()?.trim();
    if (input == null || input.isEmpty) {
      print('❌ English string cannot be empty.');
      continue;
    }
    enVal = input;
    break;
  }

  // 3. Get Indonesian Translation
  String? idVal;
  while (true) {
    stdout.write('🇮🇩 Enter Indonesian (ID) string: ');
    final input = stdin.readLineSync()?.trim();
    if (input == null || input.isEmpty) {
      print('❌ Indonesian string cannot be empty.');
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
  final lastKeysBrace = keysContent.lastIndexOf('}');
  if (lastKeysBrace == -1) {
    print('❌ Failed to parse translation_keys.dart (closing brace not found).');
    exit(1);
  }
  final newKeysContent =
      '${keysContent.substring(0, lastKeysBrace)}  static const $key = \'$key\';\n${keysContent.substring(lastKeysBrace)}';
  keysFile.writeAsStringSync('$newKeysContent\n');

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
