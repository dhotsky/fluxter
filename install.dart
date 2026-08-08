// ignore_for_file: avoid_print

// Fluxter Installer
//
// Installs the Fluxter architecture template into an existing Flutter project.
//
// Usage (Mac/Linux):
//   curl -sO https://raw.githubusercontent.com/dhotsky/fluxter/main/install.dart && dart run install.dart [version] && rm install.dart
//
// Usage (Windows):
//   curl.exe -sO https://raw.githubusercontent.com/dhotsky/fluxter/main/install.dart ; dart run install.dart [version] ; del install.dart

import 'dart:convert';
import 'dart:io';

// ── Configuration ──────────────────────────────────────────────────────────
const _repoOwner = 'dhotsky';
const _repoName = 'fluxter';
var _branch = 'main';
const _templatePackageName = 'fluxter';

// GitHub API base URL for downloading repo contents
String get _apiBase => 'https://api.github.com/repos/$_repoOwner/$_repoName';
String get _rawBase =>
    'https://raw.githubusercontent.com/$_repoOwner/$_repoName/$_branch';

// ── Main ───────────────────────────────────────────────────────────────────

Future<void> main(List<String> args) async {
  if (args.isNotEmpty) {
    _branch = args.first;
  }

  _printBanner();

  var isNewProject = false;
  // Step 1: Validate that we're in a Flutter project
  var pubspecFile = File('pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    isNewProject = true;
    _warn(
      'pubspec.yaml not found in this directory.\n'
      '   It seems this is not a Flutter project yet.',
    );
    print('');
    _info('Fluxter can create a new Flutter project here for you.');
    print('');

    // Ask for project name
    stdout.write('   Enter project name (lowercase_with_underscores): ');
    final inputName = stdin.readLineSync()?.trim();

    if (inputName == null || inputName.isEmpty) {
      _error('Project name cannot be empty.');
      exit(1);
    }

    // Validate project name (Dart package naming rules)
    final validNameRegex = RegExp(r'^[a-z][a-z0-9_]*$');
    if (!validNameRegex.hasMatch(inputName)) {
      _error(
        'Invalid project name "$inputName".\n'
        '   Use only lowercase letters, numbers, and underscores.\n'
        '   Must start with a letter. Example: my_app',
      );
      exit(1);
    }

    print('');
    print('   Where would you like to create the project?');
    print('   1) In a new directory named "$inputName" (Recommended)');
    print('   2) In the current directory');
    stdout.write('   Choose option (1 or 2, default is 1): ');
    final folderOption = stdin.readLineSync()?.trim();
    final createInSubfolder = folderOption != '2';

    print('');
    if (createInSubfolder) {
      _step(
        0,
        'Creating Flutter project "$inputName" in directory "./$inputName"...',
      );
    } else {
      _step(0, 'Creating Flutter project "$inputName" in current directory...');
    }

    final createResult = Process.runSync(
      'flutter',
      createInSubfolder
          ? ['create', inputName]
          : ['create', '--project-name', inputName, '.'],
      runInShell: true,
    );

    if (createResult.exitCode != 0) {
      _error(
        'flutter create failed.\n'
        '   Make sure Flutter SDK is installed and available in PATH.\n'
        '   ${createResult.stderr}',
      );
      exit(1);
    }

    if (createInSubfolder) {
      Directory.current = Directory(inputName);
      _success(
        'Flutter project "$inputName" created successfully in "./$inputName"',
      );
    } else {
      _success(
        'Flutter project "$inputName" created successfully in current directory',
      );
    }
    print('');

    // Re-initialize pubspecFile path
    pubspecFile = File('pubspec.yaml');
  }

  final pubspecContent = pubspecFile.readAsStringSync();
  final projectName = _extractProjectName(pubspecContent);
  if (projectName == null || projectName.isEmpty) {
    _error('Cannot read "name" from pubspec.yaml.');
    exit(1);
  }

  _info('Project detected: $projectName');

  // Step 2: Confirm with user (only if not a newly created project)
  if (!isNewProject) {
    stdout.write(
      '\n⚠️  Installer will DELETE the entire contents of lib/ and replace it '
      'with Fluxter ($_branch).\n'
      '   Dependencies will be merged into pubspec.yaml.\n'
      '\n   Continue? (y/N): ',
    );
    final answer = stdin.readLineSync()?.trim().toLowerCase();
    if (answer != 'y' && answer != 'yes') {
      _info('Installation cancelled.');
      exit(0);
    }
  } else {
    _info(
      'New project detected. Skipping confirmation step for lib replacement.',
    );
  }

  print(
    '   Do you want to include dynamic dual-language localization (EN & ID)?',
  );
  stdout.write('   Include localization? (Y/n): ');
  final l10nAns = stdin.readLineSync()?.trim().toLowerCase();
  final includeL10n = l10nAns != 'n' && l10nAns != 'no';
  print('');

  print('   Do you want to support light & dark theme mode?');
  stdout.write('   Enable light & dark theme mode? (Y/n): ');
  final themeAns = stdin.readLineSync()?.trim().toLowerCase();
  final enableDarkMode = themeAns != 'n' && themeAns != 'no';
  print('');

  // Step 3: Download file tree from GitHub API
  _step(1, 'Downloading file list from GitHub (ref: $_branch)...');
  final fileList = await _fetchFileTree('lib');

  if (!includeL10n) {
    fileList.removeWhere(
      (path) =>
          path.startsWith('lib/app/localization/') ||
          path == 'lib/app/utils/helpers/locale_helper.dart' ||
          path == 'lib/gen/app/utils/helpers/locale_helper.g.dart',
    );
  }
  if (!enableDarkMode) {
    fileList.removeWhere(
      (path) =>
          path == 'lib/app/utils/helpers/theme_helper.dart' ||
          path == 'lib/gen/app/utils/helpers/theme_helper.g.dart',
    );
  }
  if (fileList.isEmpty) {
    _error(
      'Cannot download file list from the repository.\n'
      'Make sure the repository $_repoOwner/$_repoName is public.',
    );
    exit(1);
  }
  _success('Found ${fileList.length} files');

  // Step 4: Delete existing lib/
  _step(2, 'Deleting old lib/...');
  final libDir = Directory('lib');
  if (libDir.existsSync()) {
    libDir.deleteSync(recursive: true);
  }
  libDir.createSync();
  _success('lib/ cleared');

  // Step 5: Download all files
  _step(3, 'Downloading template files...');
  var downloaded = 0;
  for (final filePath in fileList) {
    await _downloadFile(filePath, filePath);
    downloaded++;
    // Progress indicator
    final percent = (downloaded / fileList.length * 100).toStringAsFixed(0);
    stdout.write('\r   📥 [$percent%] $downloaded/${fileList.length} files');
  }
  print('');
  // Download extra files
  final extraFiles = [
    'README.md',
    'build.yaml',
    'bin/fluxter_create.dart',
    'bin/fluxter_model.dart',
    'bin/fluxter_repository.dart',
    if (includeL10n) 'bin/fluxter_translate.dart',
  ];
  for (final extra in extraFiles) {
    stdout.write('   📥 Downloading $extra...');
    await _downloadFile(extra, extra);
    print('\r   📥 $extra downloaded successfully');
  }

  _success('All files downloaded successfully');

  // Step 6: Rename package imports in Dart files
  _step(
    4,
    'Replacing package:$_templatePackageName/ → package:$projectName/...',
  );
  final dartFiles = _findDartFiles(libDir);
  var renamedCount = 0;
  for (final file in dartFiles) {
    final content = file.readAsStringSync();
    final updated = content.replaceAll(
      'package:$_templatePackageName/',
      'package:$projectName/',
    );
    if (content != updated) {
      file.writeAsStringSync(updated);
      renamedCount++;
    }
  }
  _success('$renamedCount Dart files updated');

  // Step 6.5: Strip localization if not wanted
  if (!includeL10n) {
    _step(4, 'Stripping localization infrastructure...');
    _stripLocalization(projectName);
    _success('Localization infrastructure stripped (English only mode)');
  }

  // Step 6.6: Strip dark theme if not wanted
  if (!enableDarkMode) {
    _step(4, 'Stripping dark theme mode infrastructure...');
    _stripDarkMode(projectName);
    _success('Dark theme mode infrastructure stripped (Light theme only mode)');
  }

  // Step 7: Download and merge dependencies
  _step(5, 'Merging dependencies into pubspec.yaml...');
  final depsContent = await _downloadContent('fluxter_deps.yaml');
  if (depsContent == null) {
    _warn(
      'Cannot download fluxter_deps.yaml. '
      'Please add the dependencies manually.',
    );
  } else {
    final deps = _parseDepsFile(depsContent);
    if (includeL10n) {
      deps['dependencies']!['flutter_localizations'] = 'sdk: flutter';
    }
    _mergeDependencies(
      pubspecFile,
      deps['dependencies']!,
      deps['dev_dependencies']!,
    );
    _success('Dependencies successfully merged');
  }

  if (includeL10n) {
    _enableL10nGenerate(pubspecFile);
  }

  // Step 8: Add executables block to pubspec.yaml
  _step(5, 'Adding CLI executables to pubspec.yaml...');
  _mergeExecutables(pubspecFile, includeL10n);
  _success('Executables block added');

  // Step 8: Overwrite test/widget_test.dart
  _step(6, 'Updating test/widget_test.dart...');
  final testFile = File('test/widget_test.dart');
  if (testFile.existsSync()) {
    testFile.writeAsStringSync('''
// Placeholder test — update with proper widget tests as features are built.

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('placeholder test', () {
    expect(1 + 1, equals(2));
  });
}
''');
    _success('test/widget_test.dart updated');
  } else {
    _info('test/widget_test.dart not found, skipping');
  }

  // Step 9: Run flutter pub get
  _step(7, 'Running flutter pub get...');
  final pubGetResult = Process.runSync('flutter', [
    'pub',
    'get',
  ], runInShell: true);
  if (pubGetResult.exitCode == 0) {
    _success('flutter pub get successful');
  } else {
    _warn('flutter pub get failed. Run manually: flutter pub get');
  }

  // Done!
  print('');
  print('═' * 60);
  print('');
  _success('🎉 Fluxter successfully installed to project "$projectName"!');
  print('');
  print('   Next steps:');
  print('   1. Open lib/app/config/app_config.dart');
  print('   2. Change baseUrl to your API URL');
  print('   3. Configure the built-in Network Inspector in lib/main.dart:');
  print('      Chucker.enabled = true;');
  print('      Chucker.showInRelease = false;');
  print('   4. Run: flutter run');
  print('');
  print('═' * 60);
}

// ── GitHub API ─────────────────────────────────────────────────────────────

/// Fetch the full file tree under [path] from GitHub API or manifest.txt.
/// Returns a list of file paths relative to the repo root.
Future<List<String>> _fetchFileTree(String path) async {
  // First, try to fetch the list of files from manifest.txt to bypass GitHub API rate limit
  try {
    final manifestContent = await _downloadContent('manifest.txt');
    if (manifestContent != null && manifestContent.trim().isNotEmpty) {
      final files = manifestContent
          .split('\n')
          .map((line) => line.trim())
          .where(
            (line) =>
                line.isNotEmpty &&
                !line.startsWith('#') &&
                line.startsWith('$path/'),
          )
          .toList();
      if (files.isNotEmpty) {
        return files;
      }
    }
  } catch (_) {
    // Fail silently and fall back to GitHub API
  }

  // Fallback to GitHub API
  try {
    final client = HttpClient();
    final uri = Uri.parse('$_apiBase/git/trees/$_branch?recursive=1');
    final request = await client.getUrl(uri);
    request.headers.set('Accept', 'application/vnd.github.v3+json');
    request.headers.set('User-Agent', 'fluxter-installer');
    final response = await request.close();

    if (response.statusCode != 200) {
      return [];
    }

    final body = await response.transform(utf8.decoder).join();
    final json = jsonDecode(body) as Map<String, dynamic>;
    final tree = json['tree'] as List;

    final files = <String>[];
    for (final item in tree) {
      final itemPath = item['path'] as String;
      final itemType = item['type'] as String;
      if (itemType == 'blob' && itemPath.startsWith('$path/')) {
        files.add(itemPath);
      }
    }

    client.close();
    return files;
  } catch (e) {
    return [];
  }
}

/// Download a single file from the repo and save it locally.
Future<void> _downloadFile(String remotePath, String localPath) async {
  final content = await _downloadRawBytes(remotePath);
  if (content == null) {
    _warn('Failed to download: $remotePath');
    return;
  }

  final file = File(localPath);
  final dir = file.parent;
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }
  file.writeAsBytesSync(content);
}

/// Download raw file content as bytes from GitHub.
Future<List<int>?> _downloadRawBytes(String path) async {
  try {
    final client = HttpClient();
    final uri = Uri.parse('$_rawBase/$path');
    final request = await client.getUrl(uri);
    request.headers.set('User-Agent', 'fluxter-installer');
    final response = await request.close();

    if (response.statusCode != 200) {
      client.close();
      return null;
    }

    final bytes = <int>[];
    await for (final chunk in response) {
      bytes.addAll(chunk);
    }
    client.close();
    return bytes;
  } catch (_) {
    return null;
  }
}

/// Download raw file content as string from GitHub.
Future<String?> _downloadContent(String path) async {
  final bytes = await _downloadRawBytes(path);
  if (bytes == null) return null;
  return utf8.decode(bytes);
}

// ── Pubspec Parsing ────────────────────────────────────────────────────────

/// Extract the `name` field from pubspec.yaml content.
String? _extractProjectName(String pubspecContent) {
  final lines = pubspecContent.split('\n');
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.startsWith('name:')) {
      final value = trimmed.substring(5).trim();
      // Remove quotes if present
      return value.replaceAll(RegExp(r'''['"]'''), '').trim();
    }
  }
  return null;
}

/// Parse the fluxter_deps.yaml file into dependency maps.
Map<String, Map<String, String>> _parseDepsFile(String content) {
  final deps = <String, String>{};
  final devDeps = <String, String>{};

  var currentSection = '';

  for (final line in content.split('\n')) {
    final trimmed = line.trim();

    // Skip empty lines and comments
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;

    // Detect section headers
    if (trimmed == 'dependencies:') {
      currentSection = 'dependencies';
      continue;
    }
    if (trimmed == 'dev_dependencies:') {
      currentSection = 'dev_dependencies';
      continue;
    }

    // Parse dependency entries (format: "  package_name: ^version")
    if (currentSection.isNotEmpty && trimmed.contains(':')) {
      final parts = trimmed.split(':');
      if (parts.length >= 2) {
        final name = parts[0].trim();
        final version = parts.sublist(1).join(':').trim();
        if (name.isNotEmpty && version.isNotEmpty) {
          if (currentSection == 'dependencies') {
            deps[name] = version;
          } else {
            devDeps[name] = version;
          }
        }
      }
    }
  }

  return {'dependencies': deps, 'dev_dependencies': devDeps};
}

/// Merge dependencies into the user's pubspec.yaml.
///
/// Strategy:
/// - Find the `dependencies:` and `dev_dependencies:` sections
/// - For each dependency in our list, check if it already exists
/// - If not, add it at the end of the section
/// - If yes, update the version
void _mergeDependencies(
  File pubspecFile,
  Map<String, String> deps,
  Map<String, String> devDeps,
) {
  final lines = pubspecFile.readAsStringSync().split('\n');
  final result = <String>[];

  var i = 0;
  final addedDeps = <String>{};
  final addedDevDeps = <String>{};

  while (i < lines.length) {
    final line = lines[i];
    final trimmed = line.trim();

    // Detect section starts
    if (trimmed == 'dependencies:') {
      result.add(line);
      i++;
      while (i < lines.length) {
        final subLine = lines[i];
        final subTrimmed = subLine.trim();

        // Check if we've left the section (non-indented, non-empty line)
        if (subTrimmed.isNotEmpty &&
            !subLine.startsWith(' ') &&
            !subLine.startsWith('\t')) {
          break;
        }

        // Inject flutter_localizations right after flutter: sdk: flutter
        if (subTrimmed == 'sdk: flutter' &&
            i > 0 &&
            lines[i - 1].trim() == 'flutter:') {
          result.add(subLine);
          if (deps.containsKey('flutter_localizations') &&
              !addedDeps.contains('flutter_localizations')) {
            result.add('  flutter_localizations:');
            result.add('    sdk: flutter');
            addedDeps.add('flutter_localizations');
          }
          i++;
          continue;
        }

        // Check if this line is an existing dependency we want to update
        var replaced = false;
        for (final entry in deps.entries) {
          if (subTrimmed.startsWith('${entry.key}:')) {
            if (entry.value.startsWith('sdk:')) {
              result.add('  ${entry.key}:');
              result.add('    ${entry.value}');
            } else {
              result.add('  ${entry.key}: ${entry.value}');
            }
            addedDeps.add(entry.key);
            replaced = true;
            break;
          }
        }
        if (!replaced) {
          result.add(subLine);
        }

        i++;
      }

      // Add remaining deps that weren't already in the file
      for (final entry in deps.entries) {
        if (!addedDeps.contains(entry.key)) {
          if (entry.value.startsWith('sdk:')) {
            result.add('  ${entry.key}:');
            result.add('    ${entry.value}');
          } else {
            result.add('  ${entry.key}: ${entry.value}');
          }
          addedDeps.add(entry.key);
        }
      }
      result.add('');

      continue;
    }

    if (trimmed == 'dev_dependencies:') {
      result.add(line);
      i++;
      // Process existing entries in this section
      while (i < lines.length) {
        final subLine = lines[i];
        final subTrimmed = subLine.trim();

        // Check if we've left the section
        if (subTrimmed.isNotEmpty &&
            !subLine.startsWith(' ') &&
            !subLine.startsWith('\t')) {
          break;
        }

        // Check if this line is an existing dev dependency we want to update
        var replaced = false;
        for (final entry in devDeps.entries) {
          if (subTrimmed.startsWith('${entry.key}:')) {
            if (entry.value.startsWith('sdk:')) {
              result.add('  ${entry.key}:');
              result.add('    ${entry.value}');
            } else {
              result.add('  ${entry.key}: ${entry.value}');
            }
            addedDevDeps.add(entry.key);
            replaced = true;
            break;
          }
        }
        if (!replaced) {
          result.add(subLine);
        }

        i++;
      }

      // Add remaining dev deps that weren't already in the file
      for (final entry in devDeps.entries) {
        if (!addedDevDeps.contains(entry.key)) {
          if (entry.value.startsWith('sdk:')) {
            result.add('  ${entry.key}:');
            result.add('    ${entry.value}');
          } else {
            result.add('  ${entry.key}: ${entry.value}');
          }
          addedDevDeps.add(entry.key);
        }
      }
      result.add('');

      continue;
    }

    result.add(line);
    i++;
  }

  // If pubspec didn't have dependencies: section at all, add it
  if (addedDeps.isEmpty && deps.isNotEmpty) {
    result.add('');
    result.add('dependencies:');
    for (final entry in deps.entries) {
      if (entry.value.startsWith('sdk:')) {
        result.add('  ${entry.key}:');
        result.add('    ${entry.value}');
      } else {
        result.add('  ${entry.key}: ${entry.value}');
      }
    }
  }

  if (addedDevDeps.isEmpty && devDeps.isNotEmpty) {
    result.add('');
    result.add('dev_dependencies:');
    for (final entry in devDeps.entries) {
      if (entry.value.startsWith('sdk:')) {
        result.add('  ${entry.key}:');
        result.add('    ${entry.value}');
      } else {
        result.add('  ${entry.key}: ${entry.value}');
      }
    }
  }

  pubspecFile.writeAsStringSync(result.join('\n'));
}

/// Add the `executables:` block to pubspec.yaml if not already present.
void _mergeExecutables(File pubspecFile, bool includeL10n) {
  var content = pubspecFile.readAsStringSync();

  // Skip if executables block already exists
  if (content.contains('executables:')) return;

  final block =
      '\nexecutables:\n'
      '  fluxter_create: fluxter_create\n'
      '  fluxter_model: fluxter_model\n'
      '  fluxter_repository: fluxter_repository\n'
      '${includeL10n ? "  fluxter_translate: fluxter_translate\n" : ""}';

  content += block;
  pubspecFile.writeAsStringSync(content);
}

/// Enable generate: true in pubspec.yaml under flutter block.
void _enableL10nGenerate(File pubspecFile) {
  final content = pubspecFile.readAsStringSync();
  if (content.contains('generate: true')) return;

  final lines = content.split('\n');
  final result = <String>[];
  var updated = false;
  for (var line in lines) {
    result.add(line);
    if (line.trim() == 'flutter:' &&
        !line.startsWith(' ') &&
        !line.startsWith('\t') &&
        !updated) {
      result.add('  generate: true');
      updated = true;
    }
  }
  pubspecFile.writeAsStringSync(result.join('\n'));
}

/// Remove all dynamic localization files and references to keep the app English-only.
void _stripLocalization(String projectName) {
  // 1. Modify lib/app/fluxter_app.dart
  final appFile = File('lib/app/fluxter_app.dart');
  if (appFile.existsSync()) {
    var content = appFile.readAsStringSync().replaceAll('\r\n', '\n');
    content = content.replaceAll(
      "import 'package:flutter_localizations/flutter_localizations.dart';\n",
      "",
    );
    content = content.replaceAll(
      "import 'package:$projectName/app/utils/helpers/locale_helper.dart';\n",
      "",
    );
    content = content.replaceAll(
      "    final locale = ref.watch(localeProvider);\n",
      "",
    );
    content = content.replaceAll("      locale: locale,\n", "");
    content = content.replaceAll(
      "      supportedLocales: const [\n"
          "        Locale('en', 'US'),\n"
          "        Locale('id', 'ID'),\n"
          "      ],\n",
      "",
    );
    content = content.replaceAll(
      "      supportedLocales: const [Locale('en', 'US'), Locale('id', 'ID')],\n",
      "",
    );
    content = content.replaceAll(
      "      localizationsDelegates: const [\n"
          "        GlobalMaterialLocalizations.delegate,\n"
          "        GlobalWidgetsLocalizations.delegate,\n"
          "        GlobalCupertinoLocalizations.delegate,\n"
          "      ],\n",
      "",
    );
    appFile.writeAsStringSync(content);
  }

  // 2. Modify lib/app/widgets/app_alert.dart
  final alertFile = File('lib/app/widgets/app_alert.dart');
  if (alertFile.existsSync()) {
    var content = alertFile.readAsStringSync().replaceAll('\r\n', '\n');
    content = content.replaceAll(
      "import 'package:$projectName/app/localization/translation_keys.dart';\n",
      "",
    );
    content = content.replaceAll(
      "import 'package:$projectName/app/localization/app_translations.dart';\n",
      "",
    );
    content = content.replaceAll("context.tr.understand", "'I Understand'");
    content = content.replaceAll("context.tr.yes", "'Yes'");
    content = content.replaceAll("context.tr.cancel", "'Cancel'");
    alertFile.writeAsStringSync(content);
  }

  // 3. Modify lib/app/widgets/app_empty.dart
  final emptyFile = File('lib/app/widgets/app_empty.dart');
  if (emptyFile.existsSync()) {
    var content = emptyFile.readAsStringSync().replaceAll('\r\n', '\n');
    content = content.replaceAll(
      "import 'package:$projectName/app/localization/translation_keys.dart';\n",
      "",
    );
    content = content.replaceAll(
      "import 'package:$projectName/app/localization/app_translations.dart';\n",
      "",
    );
    content = content.replaceAll("context.tr.noDataFound", "'No Data Found'");
    content = content.replaceAll(
      "context.tr.noDataMessage",
      "'There is currently no data to display.'",
    );
    emptyFile.writeAsStringSync(content);
  }

  // 4. Modify lib/app/widgets/app_loading.dart
  final loadingFile = File('lib/app/widgets/app_loading.dart');
  if (loadingFile.existsSync()) {
    var content = loadingFile.readAsStringSync().replaceAll('\r\n', '\n');
    content = content.replaceAll(
      "import 'package:$projectName/app/localization/translation_keys.dart';\n",
      "",
    );
    content = content.replaceAll(
      "import 'package:$projectName/app/localization/app_translations.dart';\n",
      "",
    );
    content = content.replaceAll("context.tr.processing", "'Processing...'");
    loadingFile.writeAsStringSync(content);
  }

  // 5. Modify lib/core/network/api_manager.dart
  final apiManagerFile = File('lib/core/network/api_manager.dart');
  if (apiManagerFile.existsSync()) {
    var content = apiManagerFile.readAsStringSync().replaceAll('\r\n', '\n');
    content = content.replaceAll(
      "import 'package:$projectName/app/localization/translation_keys.dart';\n",
      "",
    );
    content = content.replaceAll(
      "import 'package:$projectName/app/localization/app_translations.dart';\n",
      "",
    );
    content = content.replaceAll(
      "AppTranslations.translate(TranslationKeys.errUnknown)",
      "'Unknown error'",
    );
    content = content.replaceAll(
      "AppTranslations.translate(TranslationKeys.errTimeout)",
      "'Connection timeout'",
    );
    content = content.replaceAll(
      "AppTranslations.translate(TranslationKeys.errBadRequest)",
      "'Bad request'",
    );
    content = content.replaceAll(
      "AppTranslations.translate(TranslationKeys.errUnauthorized)",
      "'Unauthorized access'",
    );
    content = content.replaceAll(
      "AppTranslations.translate(TranslationKeys.errNotFound)",
      "'Resource not found'",
    );
    content = content.replaceAll(
      "AppTranslations.translate(TranslationKeys.errServer)",
      "'Internal server error'",
    );
    content = content.replaceAll(
      "AppTranslations.translate(TranslationKeys.errNoInternet)",
      "'No internet connection'",
    );
    apiManagerFile.writeAsStringSync(content);
  }

  // 6. Modify lib/app/utils/extensions/context_extension.dart
  final contextExtFile = File(
    'lib/app/utils/extensions/context_extension.dart',
  );
  if (contextExtFile.existsSync()) {
    var content = contextExtFile.readAsStringSync().replaceAll('\r\n', '\n');
    content = content.replaceAll(
      "import 'package:$projectName/app/localization/translation_keys.dart';\n",
      "",
    );
    content = content.replaceAll(
      "import 'package:$projectName/app/localization/app_translations.dart';\n",
      "",
    );
    // Remove the localization section at the end
    content = content.replaceAll(
      "  // ── Localization ────────────────────────────────────────────────────────\n"
          "  AppTranslationsWrapper get tr => AppTranslationsWrapper(this);\n",
      "",
    );
    contextExtFile.writeAsStringSync(content);
  }

  // 2. Modify lib/features/auth/presentation/login_screen.dart
  final loginFile = File('lib/features/auth/presentation/login_screen.dart');
  if (loginFile.existsSync()) {
    var content = loginFile.readAsStringSync().replaceAll('\r\n', '\n');
    content = content.replaceAll(
      "import 'package:$projectName/app/localization/translation_keys.dart';\n",
      "",
    );
    content = content.replaceAll(
      "import 'package:$projectName/app/localization/app_translations.dart';\n",
      "",
    );
    content = content.replaceAll(
      "import 'package:$projectName/app/utils/helpers/locale_helper.dart';\n",
      "",
    );

    // Remove AppButton.custom locale switcher
    content = content.replaceAll(
      "                  AppButton.custom(\n"
          "                    foregroundColor: Colors.white,\n"
          "                    onPressed: () {\n"
          "                      final currentLocale = ref.read(localeProvider);\n"
          "                      final nextLang = currentLocale.languageCode == 'en'\n"
          "                          ? 'id'\n"
          "                          : 'en';\n"
          "                      ref.read(localeProvider.notifier).setLocale(nextLang);\n"
          "                    },\n"
          "                    child: const Icon(Icons.language),\n"
          "                  ),",
      "",
    );

    // Update localized strings to raw English
    content = content.replaceAll("context.tr.welcome", "'Welcome 👋'");
    content = content.replaceAll(
      "context.tr.pleaseLogin",
      "'Please log in to continue'",
    );
    content = content.replaceAll("context.tr.email", "'Email'");
    content = content.replaceAll("context.tr.enterEmail", "'Enter your email'");
    content = content.replaceAll("context.tr.password", "'Password'");
    content = content.replaceAll(
      "context.tr.enterPassword",
      "'Enter your password'",
    );
    content = content.replaceAll("context.tr.login", "'Log In'");
    loginFile.writeAsStringSync(content);
  }

  // 3. Modify lib/features/home/presentation/home_screen.dart
  final homeFile = File('lib/features/home/presentation/home_screen.dart');
  if (homeFile.existsSync()) {
    var content = homeFile.readAsStringSync().replaceAll('\r\n', '\n');
    content = content.replaceAll(
      "import 'package:$projectName/app/localization/translation_keys.dart';\n",
      "",
    );
    content = content.replaceAll(
      "import 'package:$projectName/app/localization/app_translations.dart';\n",
      "",
    );
    content = content.replaceAll(
      "import 'package:$projectName/app/utils/helpers/locale_helper.dart';\n",
      "",
    );

    // Remove AppButton.custom locale switcher
    content = content.replaceAll(
      "          AppButton.custom(\n"
          "            onPressed: () {\n"
          "              final currentLocale = ref.read(localeProvider);\n"
          "              final nextLang = currentLocale.languageCode == 'en' ? 'id' : 'en';\n"
          "              ref.read(localeProvider.notifier).setLocale(nextLang);\n"
          "            },\n"
          "            child: const Icon(Icons.language),\n"
          "          ),",
      "",
    );

    // Update logout confirmation dialog
    content = content.replaceAll(
      "TranslationKeys.logoutConfirmTitle.tr",
      "'Log Out'",
    );
    content = content.replaceAll(
      "TranslationKeys.logoutConfirmMessage.tr",
      "'Are you sure you want to log out?'",
    );
    content = content.replaceAll("TranslationKeys.cancel.tr", "'Cancel'");

    // Update homepage strings
    content = content.replaceAll("TranslationKeys.home.tr", "'Home'");
    content = content.replaceAll(
      "TranslationKeys.welcomeUser.trParams({'value': name})",
      "'Welcome, \$name'",
    );
    content = content.replaceAll("TranslationKeys.logout.tr", "'Logout'");
    homeFile.writeAsStringSync(content);
  }
}

/// Remove all dark theme mode references to keep the app Light-only.
void _stripDarkMode(String projectName) {
  // 1. Modify lib/app/fluxter_app.dart
  final appFile = File('lib/app/fluxter_app.dart');
  if (appFile.existsSync()) {
    var content = appFile.readAsStringSync().replaceAll('\r\n', '\n');
    content = content.replaceAll(
      "import 'package:$projectName/app/utils/helpers/theme_helper.dart';\n",
      "",
    );
    content = content.replaceAll(
      "    final themeMode = ref.watch(themeModeProvider);\n",
      "",
    );
    content = content.replaceAll("      darkTheme: AppTheme.dark,\n", "");
    content = content.replaceAll("      themeMode: themeMode,\n", "");
    appFile.writeAsStringSync(content);
  }

  // 2. Modify lib/features/home/presentation/home_screen.dart
  final homeFile = File('lib/features/home/presentation/home_screen.dart');
  if (homeFile.existsSync()) {
    var content = homeFile.readAsStringSync().replaceAll('\r\n', '\n');
    content = content.replaceAll(
      "import 'package:$projectName/app/utils/helpers/theme_helper.dart';\n",
      "",
    );

    // Remove AppButton.custom theme switcher
    content = content.replaceAll(
      "          AppButton.custom(\n"
          "            onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),\n"
          "            child: const Icon(Icons.brightness_6),\n"
          "          ),",
      "",
    );
    homeFile.writeAsStringSync(content);
  }

  // 3. Modify lib/app/theme/app_theme.dart
  final themeFile = File('lib/app/theme/app_theme.dart');
  if (themeFile.existsSync()) {
    var content = themeFile.readAsStringSync().replaceAll('\r\n', '\n');
    final startIdx = content.indexOf('static ThemeData get dark => ThemeData(');
    if (startIdx != -1) {
      final endIdx = content.lastIndexOf(');');
      if (endIdx != -1 && endIdx > startIdx) {
        content = content.replaceRange(startIdx, endIdx + 2, '');
      }
    }
    // Remove Light suffixes from AppColor properties in AppTheme
    content = content.replaceAll(
      "AppColor.primarySurfaceLight",
      "AppColor.primarySurface",
    );
    content = content.replaceAll(
      "AppColor.backgroundLight",
      "AppColor.background",
    );
    content = content.replaceAll("AppColor.surfaceLight", "AppColor.surface");
    content = content.replaceAll("AppColor.cardLight", "AppColor.card");
    content = content.replaceAll("AppColor.dividerLight", "AppColor.divider");
    content = content.replaceAll("AppColor.borderLight", "AppColor.border");
    content = content.replaceAll(
      "AppColor.textPrimaryLight",
      "AppColor.textPrimary",
    );
    content = content.replaceAll(
      "AppColor.textSecondaryLight",
      "AppColor.textSecondary",
    );
    content = content.replaceAll(
      "AppColor.textTertiaryLight",
      "AppColor.textTertiary",
    );
    themeFile.writeAsStringSync(content);
  }

  // 4. Overwrite lib/app/theme/app_color.dart with light-only static colors and NO extension
  final colorFile = File('lib/app/theme/app_color.dart');
  if (colorFile.existsSync()) {
    colorFile.writeAsStringSync('''import 'package:flutter/material.dart';

class AppColor {
  AppColor._();

  // ── Primary ────────────────────────────────────────
  static const Color primary = Color(0xFF2563EB);
  static const Color primarySurface = Color(0xFFEFF6FF);

  // ── Neutral ────────────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE2E8F0);
  static const Color border = Color(0xFFCBD5E1);

  // ── Text ───────────────────────────────────────────
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF94A3B8);

  // ── Semantic ───────────────────────────────────────
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFEAB308);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFF0EA5E9);
}
''');
  }

  // 5. Replace context.{color} with AppColor.{color} and AppColor.primarySurface(context) with AppColor.primarySurface in all Dart files
  final dartFiles = _findDartFiles(Directory('lib'));
  for (final file in dartFiles) {
    var content = file.readAsStringSync().replaceAll('\r\n', '\n');
    var updated = content;
    updated = updated.replaceAll('context.textPrimary', 'AppColor.textPrimary');
    updated = updated.replaceAll(
      'context.textSecondary',
      'AppColor.textSecondary',
    );
    updated = updated.replaceAll(
      'context.textTertiary',
      'AppColor.textTertiary',
    );
    updated = updated.replaceAll('context.background', 'AppColor.background');
    updated = updated.replaceAll('context.surface', 'AppColor.surface');
    updated = updated.replaceAll('context.card', 'AppColor.card');
    updated = updated.replaceAll('context.divider', 'AppColor.divider');
    updated = updated.replaceAll('context.border', 'AppColor.border');
    updated = updated.replaceAll(
      'context.primarySurface',
      'AppColor.primarySurface',
    );
    updated = updated.replaceAll(
      'AppColor.primarySurface(context)',
      'AppColor.primarySurface',
    );
    if (content != updated) {
      file.writeAsStringSync(updated);
    }
  }
}

// ── File Utilities ─────────────────────────────────────────────────────────

/// Find all .dart files recursively in [dir].
List<File> _findDartFiles(Directory dir) {
  final files = <File>[];
  for (final entity in dir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      files.add(entity);
    }
  }
  return files;
}

// ── Output Helpers ─────────────────────────────────────────────────────────

void _printBanner() {
  const width = 61;
  print('');
  print('╔${'═' * width}╗');
  print('║${' ' * width}║');

  final title = '   🚀 Fluxter Installer';
  final titlePad = width - title.length;
  print('║$title${' ' * titlePad}║');

  final subtitle = '   Scalable Flutter Architecture Template';
  final subtitlePad = width - subtitle.length;
  print('║$subtitle${' ' * subtitlePad}║');

  final version = '   Version: $_branch';
  final versionPad = width - version.length;
  print('║$version${' ' * versionPad}║');

  print('║${' ' * width}║');
  print('╚${'═' * width}╝');
  print('');
}

void _step(int n, String msg) => print('${n == 0 ? '[Pre]' : '[$n/7]'} $msg');
void _success(String msg) => print('   ✅ $msg');
void _info(String msg) => print('   ℹ️  $msg');
void _warn(String msg) => print('   ⚠️  $msg');
void _error(String msg) => print('   ❌ $msg');
