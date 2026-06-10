import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fluxter/core/storage/local_storage.dart';

part '../../../gen/app/utils/helpers/theme_helper.g.dart';

@Riverpod(keepAlive: true)
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  ThemeMode build() {
    final localStorage = ref.watch(localStorageProvider);
    return localStorage.isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleTheme() async {
    final localStorage = ref.read(localStorageProvider);
    final isDark = state == ThemeMode.dark;
    await localStorage.saveDarkMode(!isDark);
    state = isDark ? ThemeMode.light : ThemeMode.dark;
  }
}
