import 'package:flutter/material.dart';
import 'package:fluxter/app/localization/app_translations.dart';

abstract class TranslationKeys {
  static const appName = 'appName';
  static const home = 'home';
  static const welcome = 'welcome';
  static const login = 'login';
  static const logout = 'logout';
  static const email = 'email';
  static const password = 'password';
  static const enterEmail = 'enterEmail';
  static const enterPassword = 'enterPassword';
  static const pleaseLogin = 'pleaseLogin';
  static const welcomeUser = 'welcomeUser';
  static const logoutConfirmTitle = 'logoutConfirmTitle';
  static const logoutConfirmMessage = 'logoutConfirmMessage';
  static const cancel = 'cancel';
  static const understand = 'understand';
  static const yes = 'yes';
  static const noDataFound = 'noDataFound';
  static const noDataMessage = 'noDataMessage';
  static const processing = 'processing';

  // Network Error Messages
  static const errTimeout = 'errTimeout';
  static const errNoInternet = 'errNoInternet';
  static const errServer = 'errServer';
  static const errUnknown = 'errUnknown';
  static const errUnauthorized = 'errUnauthorized';
  static const errBadRequest = 'errBadRequest';
  static const errNotFound = 'errNotFound';
}

class AppTranslationsWrapper {
  final BuildContext context;

  AppTranslationsWrapper(this.context) {
    Localizations.localeOf(context);
  }

  String get appName => AppTranslations.translate(TranslationKeys.appName);
  String get home => AppTranslations.translate(TranslationKeys.home);
  String get welcome => AppTranslations.translate(TranslationKeys.welcome);
  String get login => AppTranslations.translate(TranslationKeys.login);
  String get logout => AppTranslations.translate(TranslationKeys.logout);
  String get email => AppTranslations.translate(TranslationKeys.email);
  String get password => AppTranslations.translate(TranslationKeys.password);
  String get enterEmail => AppTranslations.translate(TranslationKeys.enterEmail);
  String get enterPassword => AppTranslations.translate(TranslationKeys.enterPassword);
  String get pleaseLogin => AppTranslations.translate(TranslationKeys.pleaseLogin);
  
  String welcomeUser(Map<String, String> params) {
    var text = AppTranslations.translate(TranslationKeys.welcomeUser);
    params.forEach((k, v) => text = text.replaceAll('@$k', v));
    return text;
  }

  String get logoutConfirmTitle => AppTranslations.translate(TranslationKeys.logoutConfirmTitle);
  String get logoutConfirmMessage => AppTranslations.translate(TranslationKeys.logoutConfirmMessage);
  String get cancel => AppTranslations.translate(TranslationKeys.cancel);
  String get understand => AppTranslations.translate(TranslationKeys.understand);
  String get yes => AppTranslations.translate(TranslationKeys.yes);
  String get noDataFound => AppTranslations.translate(TranslationKeys.noDataFound);
  String get noDataMessage => AppTranslations.translate(TranslationKeys.noDataMessage);
  String get processing => AppTranslations.translate(TranslationKeys.processing);

  // Network Error Messages
  String get errTimeout => AppTranslations.translate(TranslationKeys.errTimeout);
  String get errNoInternet => AppTranslations.translate(TranslationKeys.errNoInternet);
  String get errServer => AppTranslations.translate(TranslationKeys.errServer);
  String get errUnknown => AppTranslations.translate(TranslationKeys.errUnknown);
  String get errUnauthorized => AppTranslations.translate(TranslationKeys.errUnauthorized);
  String get errBadRequest => AppTranslations.translate(TranslationKeys.errBadRequest);
  String get errNotFound => AppTranslations.translate(TranslationKeys.errNotFound);
}
