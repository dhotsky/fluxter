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
