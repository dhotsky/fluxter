import 'package:flutter/material.dart';

import 'package:fluxter/app/theme/app_color.dart';
import 'package:fluxter/app/utils/extensions/extensions.dart';

/// Reusable Empty State Widget.
///
/// Can be used in ListViews or any place where data is empty.
class AppEmpty extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Widget? action;

  const AppEmpty({
    super.key,
    this.title = 'Data Tidak Ditemukan',
    this.message = 'Belum ada data untuk ditampilkan saat ini.',
    this.icon = Icons.inbox_outlined,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
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
        24.height,
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: context.textPrimary,
          ),
        ),
        8.height,
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: context.textSecondary),
        ),
        if (action != null) ...[24.height, action!],
      ],
    ).paddingAll(32.0).center;
  }
}
