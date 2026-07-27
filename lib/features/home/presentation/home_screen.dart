import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluxter/app/utils/extensions/extensions.dart';
import 'package:fluxter/app/theme/app_color.dart';

import 'package:fluxter/app/utils/helpers/theme_helper.dart';
import 'package:fluxter/app/widgets/app_alert.dart';
import 'package:fluxter/app/widgets/app_button.dart';
import 'package:fluxter/app/utils/helpers/locale_helper.dart';
import 'package:fluxter/features/auth/presentation/auth_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const routePath = '/home';

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) async {
    final confirm = await AppAlert.showConfirmationBottomSheet(
      context: context,
      title: context.tr.logoutConfirmTitle,
      message: context.tr.logoutConfirmMessage,
      confirmText: context.tr.logoutConfirmTitle,
      cancelText: context.tr.cancel,
      isDanger: true,
    );

    if (confirm == true) {
      await ref.read(authControllerProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.value;
    final name = user?.name ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr.home),
        actions: [
          AppButton.custom(
            onPressed: () {
              final currentLocale = ref.read(localeProvider);
              final nextLang = currentLocale.languageCode == 'en' ? 'id' : 'en';
              ref.read(localeProvider.notifier).setLocale(nextLang);
            },
            child: const Icon(Icons.language),
          ),
          AppButton.custom(
            onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
            child: const Icon(Icons.brightness_6),
          ),
          8.width,
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.tr.welcomeUser({'value': name}),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            32.height,
            AppButton(
              width: double.infinity,
              text: context.tr.logout,
              isLoading: authState.isLoading,
              onPressed: () => _showLogoutConfirmation(context, ref),
            ),
          ],
        ).paddingAll(16).center,
      ),
    );
  }
}
