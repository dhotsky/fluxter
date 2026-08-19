import 'package:fluxter/app/widgets/app_spacing.dart';
import 'package:flutter/material.dart';

import 'package:fluxter/app/theme/app_color.dart';
import 'package:fluxter/app/utils/extensions/extensions.dart';

/// Reusable Empty State Widget.
///
/// Can be used in ListViews or any place where data is empty.
class AppEmpty extends StatelessWidget {
  final String? title;
  final String? message;
  final IconData icon;
  final Widget? action;

  const AppEmpty({
    super.key,
    this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final displayTitle = title ?? context.tr.noDataFound;
    final displayMessage = message ?? context.tr.noDataMessage;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.primarySurface,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 64, color: AppColor.primary),
        ),
        Spacing(24),
        Text(
          displayTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: context.textPrimary,
          ),
        ),
        Spacing(8),
        Text(
          displayMessage,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: context.textSecondary),
        ),
        if (action != null) ...[Spacing(24), action!],
      ],
    ).paddingAll(32.0).center;
  }
}
