import 'package:flutter/material.dart';

import 'package:fluxter/app/theme/app_color.dart';
import 'package:fluxter/app/utils/extensions/extensions.dart';

import 'package:fluxter/app/widgets/app_button.dart';

/// Utility class for showing consistent alerts and confirmation dialogues
/// across the app. Supports both Dialog and BottomSheet formats using Flutter.
class AppAlert {
  AppAlert._();

  // ── Single Action Alerts ───────────────────────────────────────────────

  /// Show a simple alert as a popup Dialog.
  static Future<void> showDialogAlert({
    required BuildContext context,
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onPressed,
  }) async {
    final displayButtonText = buttonText ?? context.tr.understand;
    return showDialog<void>(
      context: context,
      useSafeArea: true,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(child: Text(message)),
        actions: [
          AppButton(
            text: displayButtonText,
            onPressed: () {
              Navigator.of(context).pop();
              onPressed?.call();
            },
          ),
        ],
      ),
    );
  }

  /// Show a simple alert as a Bottom Sheet.
  static Future<void> showBottomSheetAlert({
    required BuildContext context,
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onPressed,
  }) async {
    final displayButtonText = buttonText ?? context.tr.understand;
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                8.height,
                Flexible(
                  child: SingleChildScrollView(
                    child: Text(
                      message,
                      style: TextStyle(
                        fontSize: 14,
                        color: context.textSecondary,
                      ),
                    ),
                  ),
                ),
                24.height,
                AppButton(
                  text: displayButtonText,
                  onPressed: () {
                    Navigator.of(context).pop();
                    onPressed?.call();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Confirmation Alerts ────────────────────────────────────────────────

  /// Show a confirmation alert as a popup Dialog.
  /// Returns [true] if confirmed, [false] or [null] if canceled/dismissed.
  static Future<bool?> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    bool isDanger = false,
  }) async {
    final displayConfirmText = confirmText ?? context.tr.yes;
    final displayCancelText = cancelText ?? context.tr.cancel;
    return showDialog<bool>(
      context: context,
      useSafeArea: true,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(child: Text(message)),
        actions: [
          Row(
            children: [
              Expanded(
                child: AppButton.text(
                  text: displayCancelText,
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ),
              12.width,
              Expanded(
                child: isDanger
                    ? AppButton.danger(
                        text: displayConfirmText,
                        onPressed: () => Navigator.of(context).pop(true),
                      )
                    : AppButton(
                        text: displayConfirmText,
                        onPressed: () => Navigator.of(context).pop(true),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Show a confirmation alert as a Bottom Sheet.
  /// Returns [true] if confirmed, [false] or [null] if canceled/dismissed.
  static Future<bool?> showConfirmationBottomSheet({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    bool isDanger = false,
  }) async {
    final displayConfirmText = confirmText ?? context.tr.yes;
    final displayCancelText = cancelText ?? context.tr.cancel;
    return showModalBottomSheet<bool>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                8.height,
                Flexible(
                  child: SingleChildScrollView(
                    child: Text(
                      message,
                      style: TextStyle(
                        fontSize: 14,
                        color: context.textSecondary,
                      ),
                    ),
                  ),
                ),
                24.height,
                Row(
                  children: [
                    Expanded(
                      child: AppButton.outlined(
                        text: displayCancelText,
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                    ),
                    16.width,
                    Expanded(
                      child: isDanger
                          ? AppButton.danger(
                              text: displayConfirmText,
                              onPressed: () => Navigator.of(context).pop(true),
                            )
                          : AppButton(
                              text: displayConfirmText,
                              onPressed: () => Navigator.of(context).pop(true),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
