import 'package:flutter/material.dart';
import 'en_us.dart';
import 'id_id.dart';

class AppTranslations {
  // Static reference to the active locale, updated by the locale notifier.
  static Locale currentLocale = const Locale('en', 'US');

  static final Map<String, Map<String, String>> keys = {
    'en_US': enUs,
    'id_ID': idId,
  };

  static String translate(String key) {
    final country =
        currentLocale.countryCode ??
        (currentLocale.languageCode == 'id' ? 'ID' : 'US');
    final localeKey = '${currentLocale.languageCode}_$country';
    final translationMap = keys[localeKey] ?? keys['en_US'] ?? {};
    return translationMap[key] ?? key;
  }
}

extension TranslationExtension on String {
  /// Translates the string based on the active locale.
  /// Example: `TranslationKeys.welcome.tr`
  String get tr => AppTranslations.translate(this);

  /// Translates the string and replaces placeholder parameters.
  /// Example: `TranslationKeys.welcomeUser.trParams({'value': 'John'})`
  String trParams(Map<String, String> params) {
    var translated = tr;
    params.forEach((key, value) {
      translated = translated.replaceAll('@$key', value);
    });
    return translated;
  }
}
