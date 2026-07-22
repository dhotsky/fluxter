import 'package:flutter/material.dart';

import 'package:fluxter/app/theme/app_color.dart';

/// Unified button component that replaces ElevatedButton, OutlinedButton,
/// TextButton, and other button variants with a single, consistent API.
///
/// Supports multiple variants, custom child widget, loading state, icons.
///
/// Usage:
/// ```dart
/// // Filled (default)
/// AppButton(text: 'Login', onPressed: () {})
///
/// // With fixed width and height
/// AppButton(text: 'Login', width: 200, height: 50, onPressed: () {})
///
/// // Custom widget inside
/// AppButton.custom(
///   onPressed: () {},
///   child: Row(children: [Icon(Icons.star), Text('Favorite')]),
/// )
/// ```
class AppButton extends StatelessWidget {
  final String? text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Widget? child;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final double? width;
  final double? height;
  final bool isLoading;
  final bool isDisabled;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;

  // ── Filled (Default) ────────────────────────────────
  const AppButton({
    super.key,
    required String this.text,
    this.fontSize,
    this.fontWeight,
    required this.onPressed,
    this.width,
    this.height,
    this.isLoading = false,
    this.isDisabled = false,
    this.prefixIcon,
    this.suffixIcon,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderRadius,
    this.padding,
  }) : variant = AppButtonVariant.filled,
       child = null;

  // ── Outlined ────────────────────────────────────────
  const AppButton.outlined({
    super.key,
    required String this.text,
    this.fontSize,
    this.fontWeight,
    required this.onPressed,
    this.width,
    this.height,
    this.isLoading = false,
    this.isDisabled = false,
    this.prefixIcon,
    this.suffixIcon,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderRadius,
    this.padding,
  }) : variant = AppButtonVariant.outlined,
       child = null;

  // ── Shadow (Elevated) ──────────────────────────────
  const AppButton.shadow({
    super.key,
    required String this.text,
    this.fontSize,
    this.fontWeight,
    required this.onPressed,
    this.width,
    this.height,
    this.isLoading = false,
    this.isDisabled = false,
    this.prefixIcon,
    this.suffixIcon,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderRadius,
    this.padding,
  }) : variant = AppButtonVariant.shadow,
       child = null;

  // ── Danger ─────────────────────────────────────────
  const AppButton.danger({
    super.key,
    required String this.text,
    this.fontSize,
    this.fontWeight,
    required this.onPressed,
    this.width,
    this.height,
    this.isLoading = false,
    this.isDisabled = false,
    this.prefixIcon,
    this.suffixIcon,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderRadius,
    this.padding,
  }) : variant = AppButtonVariant.danger,
       child = null;

  // ── Soft ───────────────────────────────────────────
  const AppButton.soft({
    super.key,
    required String this.text,
    this.fontSize,
    this.fontWeight,
    required this.onPressed,
    this.width,
    this.height,
    this.isLoading = false,
    this.isDisabled = false,
    this.prefixIcon,
    this.suffixIcon,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderRadius,
    this.padding,
  }) : variant = AppButtonVariant.soft,
       child = null;

  // ── Text ───────────────────────────────────────────
  const AppButton.text({
    super.key,
    required String this.text,
    this.fontSize,
    this.fontWeight,
    required this.onPressed,
    this.width,
    this.height,
    this.isLoading = false,
    this.isDisabled = false,
    this.prefixIcon,
    this.suffixIcon,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderRadius,
    this.padding,
  }) : variant = AppButtonVariant.text,
       child = null;

  // ── Custom ─────────────────────────────────────────
  const AppButton.custom({
    super.key,
    required Widget this.child,
    required this.onPressed,
    this.variant = AppButtonVariant.text,
    this.width,
    this.height,
    this.isLoading = false,
    this.isDisabled = false,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderRadius,
    this.padding,
  }) : text = null,
       fontSize = null,
       fontWeight = null,
       prefixIcon = null,
       suffixIcon = null;

  @override
  Widget build(BuildContext context) {
    final effectiveDisabled = isDisabled || isLoading;
    final config = _resolveConfig(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: variant == AppButtonVariant.shadow
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(
                borderRadius ?? config.borderRadius,
              ),
              boxShadow: effectiveDisabled
                  ? null
                  : [
                      BoxShadow(
                        color: (backgroundColor ?? config.background)
                            .withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
            )
          : null,
      width: width,
      height: height,
      child: _buildButton(config, effectiveDisabled),
    );
  }

  Widget _buildButton(_ButtonConfig config, bool effectiveDisabled) {
    final style = ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return (backgroundColor ?? config.background).withValues(alpha: 0.5);
        }
        return backgroundColor ?? config.background;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return (foregroundColor ?? config.foreground).withValues(alpha: 0.5);
        }
        return foregroundColor ?? config.foreground;
      }),
      overlayColor: WidgetStateProperty.all(
        (foregroundColor ?? config.foreground).withValues(alpha: 0.08),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            borderRadius ?? config.borderRadius,
          ),
          side: config.borderSide ?? BorderSide.none,
        ),
      ),
      elevation: WidgetStateProperty.all(0),
      padding: WidgetStateProperty.all(padding ?? config.padding),
      minimumSize: WidgetStateProperty.all(Size.zero),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    return ElevatedButton(
      onPressed: effectiveDisabled ? null : onPressed,
      style: style,
      child: _buildChild(config),
    );
  }

  Widget _buildChild(_ButtonConfig config) {
    if (isLoading) {
      return SizedBox(
        height: config.loaderSize,
        width: config.loaderSize,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: foregroundColor ?? config.foreground,
        ),
      );
    }

    if (child != null) {
      return child!;
    }

    if (text == null && prefixIcon != null) {
      return Icon(prefixIcon, size: config.iconSize);
    }

    final textWidget = Text(
      text ?? '',
      style: TextStyle(
        fontSize: fontSize ?? config.fontSize,
        fontWeight: fontWeight ?? FontWeight.w600,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    final content = prefixIcon == null && suffixIcon == null
        ? textWidget
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (prefixIcon != null) ...[
                Icon(prefixIcon, size: config.iconSize),
                SizedBox(width: config.iconSpacing),
              ],
              Flexible(child: textWidget),
              if (suffixIcon != null) ...[
                SizedBox(width: config.iconSpacing),
                Icon(suffixIcon, size: config.iconSize),
              ],
            ],
          );

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.center,
      child: content,
    );
  }

  _ButtonConfig _resolveConfig(BuildContext context) {
    // Default config values
    const fontSize = 15.0;
    const iconSize = 24.0;
    const iconSpacing = 8.0;
    const loaderSize = 20.0;
    const borderRadiusVal = 12.0;

    final resolvedPadding = text == null
        ? const EdgeInsets.all(8)
        : switch (variant) {
            AppButtonVariant.text => const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            _ => const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          };

    final (background, foreground, borderSide) = switch (variant) {
      AppButtonVariant.filled => (
        AppColor.primary,
        AppColor.white,
        null as BorderSide?,
      ),
      AppButtonVariant.outlined => (
        Colors.transparent,
        borderColor ?? AppColor.primary,
        BorderSide(color: borderColor ?? AppColor.primary, width: 1.5),
      ),
      AppButtonVariant.shadow => (
        AppColor.primary,
        AppColor.white,
        null as BorderSide?,
      ),
      AppButtonVariant.danger => (
        AppColor.error,
        AppColor.white,
        null as BorderSide?,
      ),
      AppButtonVariant.soft => (
        context.surface,
        AppColor.primary,
        null as BorderSide?,
      ),
      AppButtonVariant.text => (
        Colors.transparent,
        AppColor.primary,
        null as BorderSide?,
      ),
    };

    return _ButtonConfig(
      fontSize: fontSize,
      iconSize: iconSize,
      iconSpacing: iconSpacing,
      loaderSize: loaderSize,
      padding: resolvedPadding,
      borderRadius: borderRadiusVal,
      background: background,
      foreground: foreground,
      borderSide: borderSide,
    );
  }
}

// ── Enums ─────────────────────────────────────────────

enum AppButtonVariant { filled, outlined, shadow, danger, soft, text }

// ── Internal Config ───────────────────────────────────

class _ButtonConfig {
  final double fontSize;
  final double iconSize;
  final double iconSpacing;
  final double loaderSize;
  final EdgeInsets padding;
  final double borderRadius;
  final Color background;
  final Color foreground;
  final BorderSide? borderSide;

  const _ButtonConfig({
    required this.fontSize,
    required this.iconSize,
    required this.iconSpacing,
    required this.loaderSize,
    required this.padding,
    required this.borderRadius,
    required this.background,
    required this.foreground,
    this.borderSide,
  });
}
