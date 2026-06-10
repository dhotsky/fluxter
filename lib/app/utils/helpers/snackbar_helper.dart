import 'package:flutter/material.dart';

import 'package:fluxter/app/theme/app_color.dart';

final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class SnackbarHelper {
  SnackbarHelper._();

  static void showSuccess(String message) {
    _show(
      message: message,
      backgroundColor: AppColor.success,
      icon: Icons.check_circle_rounded,
    );
  }

  static void showError(String message) {
    _show(
      message: message,
      backgroundColor: AppColor.error,
      icon: Icons.error_rounded,
    );
  }

  static void showInfo(String message) {
    _show(
      message: message,
      backgroundColor: AppColor.info,
      icon: Icons.info_rounded,
    );
  }

  static void showWarning(String message) {
    _show(
      message: message,
      backgroundColor: AppColor.warning,
      icon: Icons.warning_rounded,
    );
  }

  static void _show({
    required String message,
    required Color backgroundColor,
    required IconData icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    final state = scaffoldMessengerKey.currentState;
    if (state == null) return;

    state.clearSnackBars();
    state.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
