import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fluxter/core/storage/local_storage.dart';
import 'package:fluxter/app/localization/app_translations.dart';

part '../../../gen/app/utils/helpers/locale_helper.g.dart';

@Riverpod(keepAlive: true)
class LocaleNotifier extends _$LocaleNotifier {
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
