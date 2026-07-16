import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fluxter/app/router/app_router.dart';
import 'package:fluxter/app/theme/app_theme.dart';
import 'package:fluxter/app/utils/helpers/theme_helper.dart';
import 'package:fluxter/app/utils/helpers/locale_helper.dart';
import 'package:fluxter/app/utils/helpers/snackbar_helper.dart';
import 'package:fluxter/core/chucker/chucker_overlay.dart';

class FluxterApp extends ConsumerWidget {
  const FluxterApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Fluxter',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: const [Locale('en', 'US'), Locale('id', 'ID')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
      scaffoldMessengerKey: scaffoldMessengerKey,
      builder: (context, child) => ChuckerOverlayWrapper(
        child: child ?? const SizedBox(),
      ),
    );
  }
}
