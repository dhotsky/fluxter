import 'package:flutter/material.dart';

import 'package:fluxter/app/theme/app_color.dart';
import 'package:fluxter/app/utils/extensions/extensions.dart';

/// Loading component for use inside the UI (like ListView, etc)
class AppLoading extends StatelessWidget {
  final String? text;
  final double size;
  final double strokeWidth;
  final Color? color;

  const AppLoading({
    super.key,
    this.text,
    this.size = 24,
    this.strokeWidth = 2.5,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final indicator = SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        color: color ?? AppColor.primary,
      ),
    );

    if (text == null) {
      return Center(child: indicator);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        indicator,
        16.height,
        Text(
          text!,
          style: TextStyle(color: context.textSecondary, fontSize: 14),
        ),
      ],
    ).center;
  }
}

/// Utility class to show a Loading overlay (blocks user interaction)
class AppLoadingOverlay {
  AppLoadingOverlay._();

  /// Shows loading as a Dialog (centered popup)
  /// Use [hide] after the async process is finished to close it.
  static void showAsDialog(
    BuildContext context, {
    String text = 'Processing...',
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: context.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppLoading(size: 32, strokeWidth: 3),
                16.height,
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Shows loading as a Bottom Sheet (from the bottom)
  /// Use [hide] after the async process is finished to close it.
  static void showAsBottomSheet(
    BuildContext context, {
    String text = 'Processing...',
  }) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: context.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => PopScope(
        canPop: false,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppLoading(size: 32, strokeWidth: 3),
                16.height,
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Closes the currently active loading overlay (Dialog or Bottom Sheet)
  static void hide(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
}
