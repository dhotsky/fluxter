import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluxter/core/storage/local_storage.dart';
import 'package:fluxter/app/localization/app_translations.dart';

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final localStorage = ref.watch(localStorageProvider);
    final langCode = localStorage.localeCode;
    final locale = Locale(langCode, langCode == 'id' ? 'ID' : 'US');

    // Initialize the static currentLocale for string translation extensions
    AppTranslations.currentLocale = locale;
    return locale;
  }

  Future<void> setLocale(String languageCode) async {
    final localStorage = ref.read(localStorageProvider);
    await localStorage.saveLocale(languageCode);

    final locale = Locale(languageCode, languageCode == 'id' ? 'ID' : 'US');
    AppTranslations.currentLocale = locale;

    state = locale;
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  () => LocaleNotifier(),
);
