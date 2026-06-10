import 'package:flutter/material.dart';

class AppColor {
  AppColor._();

  // ── Primary ────────────────────────────────────────
  static const Color primary = Color(0xFF2563EB);
  static const Color primarySurfaceLight = Color(0xFFEFF6FF);
  static const Color primarySurfaceDark = Color(0xFF1E3A8A);

  // ── Neutral Light ──────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color dividerLight = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFCBD5E1);

  // ── Neutral Dark ───────────────────────────────────
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color dividerDark = Color(0xFF334155);
  static const Color borderDark = Color(0xFF334155);

  // ── Text Light ─────────────────────────────────────
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textTertiaryLight = Color(0xFF94A3B8);

  // ── Text Dark ──────────────────────────────────────
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textTertiaryDark = Color(0xFF64748B);

  // ── Semantic ───────────────────────────────────────
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFEAB308);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFF0EA5E9);
  static const Color transparent = Colors.transparent;

  // ── Dynamic Theme Color Resolver ───────────────────
  static Color themeColor(
    BuildContext context, {
    required Color darkModeColor,
    required Color lightModeColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkModeColor : lightModeColor;
  }

  static Color textPrimary(BuildContext context) => themeColor(
    context,
    darkModeColor: textPrimaryDark,
    lightModeColor: textPrimaryLight,
  );

  static Color textSecondary(BuildContext context) => themeColor(
    context,
    darkModeColor: textSecondaryDark,
    lightModeColor: textSecondaryLight,
  );

  static Color textTertiary(BuildContext context) => themeColor(
    context,
    darkModeColor: textTertiaryDark,
    lightModeColor: textTertiaryLight,
  );

  static Color background(BuildContext context) => themeColor(
    context,
    darkModeColor: backgroundDark,
    lightModeColor: backgroundLight,
  );

  static Color surface(BuildContext context) => themeColor(
    context,
    darkModeColor: surfaceDark,
    lightModeColor: surfaceLight,
  );

  static Color card(BuildContext context) =>
      themeColor(context, darkModeColor: cardDark, lightModeColor: cardLight);

  static Color divider(BuildContext context) => themeColor(
    context,
    darkModeColor: dividerDark,
    lightModeColor: dividerLight,
  );

  static Color border(BuildContext context) => themeColor(
    context,
    darkModeColor: borderDark,
    lightModeColor: borderLight,
  );

  static Color primarySurface(BuildContext context) => themeColor(
    context,
    darkModeColor: primarySurfaceDark,
    lightModeColor: primarySurfaceLight,
  );
}

extension AppColorContextExtension on BuildContext {
  Color get textPrimary => AppColor.textPrimary(this);
  Color get textSecondary => AppColor.textSecondary(this);
  Color get textTertiary => AppColor.textTertiary(this);
  Color get background => AppColor.background(this);
  Color get surface => AppColor.surface(this);
  Color get card => AppColor.card(this);
  Color get divider => AppColor.divider(this);
  Color get border => AppColor.border(this);
  Color get primarySurface => AppColor.primarySurface(this);
}
