import 'package:flutter/material.dart';
import 'package:fluxter/app/localization/translation_keys.dart';

extension ContextExtension on BuildContext {
  // ── Theme & Styling Shortcuts ──────────────────────────────────────────
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
  bool get isDarkMode => theme.brightness == Brightness.dark;

  // ── MediaQuery Shortcuts ──────────────────────────────────────────────
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get width => mediaQuery.size.width;
  double get height => mediaQuery.size.height;
  EdgeInsets get padding => mediaQuery.padding;

  // ── Navigation Shortcuts ──────────────────────────────────────────────
  void popUntil(bool Function(Route<dynamic>) predicate) {
    Navigator.of(this).popUntil(predicate);
  }

  Future<T?> popAndPushNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    TO? result,
    Object? arguments,
  }) {
    return Navigator.of(
      this,
    ).popAndPushNamed<T, TO>(routeName, result: result, arguments: arguments);
  }

  // ── Localization ────────────────────────────────────────────────────────
  AppTranslationsWrapper get tr => AppTranslationsWrapper(this);
}
