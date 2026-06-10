import 'package:flutter/material.dart';

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
}
