// ignore_for_file: avoid_print

import 'dart:io';

void main() {
  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    print('❌ Error: lib/ directory not found. Make sure to run this script from the project root.');
    exit(1);
  }

  print('🔍 Scanning lib/ directory for files...');
  final files = <String>[];

  // Recursively list all files in lib/
  try {
    for (final entity in libDir.listSync(recursive: true)) {
      if (entity is File) {
        // Standardize path separators to forward slashes
        final path = entity.path.replaceAll('\\', '/');
        // Exclude hidden files or dotfiles if any
        if (!path.split('/').any((segment) => segment.startsWith('.'))) {
          files.add(path);
        }
      }
    }
  } catch (e) {
    print('❌ Error scanning directory: $e');
    exit(1);
  }

  // Sort files for deterministic and clean diffs
  files.sort();

  final manifestFile = File('manifest.txt');
  final content = '${files.join('\n')}\n';
  
  try {
    manifestFile.writeAsStringSync(content);
    print('✅ Successfully generated manifest.txt with ${files.length} files.');
  } catch (e) {
    print('❌ Error writing manifest.txt: $e');
    exit(1);
  }
}
