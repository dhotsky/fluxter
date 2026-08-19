import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluxter/app/theme/app_color.dart';
import 'package:fluxter/app/utils/extensions/extensions.dart';
import 'package:fluxter/app/widgets/app_button.dart';
import 'package:fluxter/app/widgets/app_spacing.dart';
import 'package:fluxter/app/widgets/app_text_field.dart';
import 'package:fluxter/app/utils/helpers/snackbar_helper.dart';
import 'package:fluxter/app/utils/helpers/locale_helper.dart';
import 'package:fluxter/features/auth/presentation/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  static const routePath = '/login';

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final result = await ref
        .read(authControllerProvider.notifier)
        .login(email, password);
    result.when(
      success: (user) {
        // Redirection is handled automatically by GoRouter!
      },
      error: (message, statusCode) {
        SnackbarHelper.showError(message);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColor.primary, Color(0xFF1E40AF)],
            stops: [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Fluxter',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Spacing(4),
                      const Text(
                        'Scalable Flutter Architecture',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                  AppButton.custom(
                    foregroundColor: Colors.white,
                    onPressed: () {
                      final currentLocale = ref.read(localeProvider);
                      final nextLang = currentLocale.languageCode == 'en'
                          ? 'id'
                          : 'en';
                      ref.read(localeProvider.notifier).setLocale(nextLang);
                    },
                    child: const Icon(Icons.language),
                  ),
                ],
              ).paddingSymmetric(horizontal: 32, vertical: 40),

              // ── Form Card ──
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: context.background,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Spacing(8),
                      Text(
                        context.tr.welcome,
                        style: TextStyle(
                          color: context.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Spacing(4),
                      Text(
                        context.tr.pleaseLogin,
                        style: TextStyle(
                          color: context.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      Spacing(32),

                      // ── Email Field ──
                      AppTextField.outlined(
                        title: context.tr.email,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        hintText: context.tr.enterEmail,
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                      Spacing(20),

                      // ── Password Field ──
                      AppTextField.outlined(
                        title: context.tr.password,
                        controller: _passwordController,
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        hintText: context.tr.enterPassword,
                        prefixIcon: const Icon(Icons.lock_outlined),
                      ),
                      Spacing(32),

                      // ── Login Button ──
                      AppButton(
                        text: context.tr.login,
                        width: double.infinity,
                        isLoading: isLoading,
                        onPressed: _handleLogin,
                      ),
                    ],
                  ).paddingAll(24).toScrollable,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
