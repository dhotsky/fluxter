import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:fluxter/features/auth/domain/user.dart';
import 'package:fluxter/features/auth/presentation/auth_controller.dart';
import 'package:fluxter/features/auth/presentation/login_screen.dart';
import 'package:fluxter/features/home/presentation/home_screen.dart';
import 'package:fluxter/core/chucker/chucker.dart';
import 'package:fluxter/core/chucker/chucker_http_log.dart';
import 'package:fluxter/core/chucker/chucker_screen.dart';
import 'package:fluxter/core/chucker/chucker_detail_screen.dart';

part '../../gen/app/router/app_router.g.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AsyncValue<User?>>(
      authControllerProvider,
      (_, _) => notifyListeners(),
    );
  }
}

@riverpod
RouterNotifier routerNotifier(Ref ref) {
  return RouterNotifier(ref);
}

@riverpod
GoRouter goRouter(Ref ref) {
  final notifier = ref.watch(routerProvider);

  Chucker.navigatorKey = rootNavigatorKey;

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: LoginScreen.routePath,
    refreshListenable: notifier,
    routes: [
      // Chucker
      GoRoute(
        path: ChuckerScreen.routePath,
        builder: (context, state) => const ChuckerScreen(),
      ),
      GoRoute(
        path: ChuckerDetailScreen.routePath,
        builder: (context, state) {
          final log = state.extra as ChuckerHttpLog;
          return ChuckerDetailScreen(log: log);
        },
      ),

      // App
      GoRoute(
        path: LoginScreen.routePath,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: HomeScreen.routePath,
        builder: (context, state) => const HomeScreen(),
      ),
    ],
    redirect: (context, state) {
      // Allow access to Chucker inspector pages without auth checks
      if (state.uri.path.startsWith('/chucker')) return null;

      final authState = ref.read(authControllerProvider);

      // Avoid redirect logic while loading initial session status
      if (authState.isLoading) return null;

      final isLoggedIn = authState.value != null;
      final isLoggingIn = state.uri.path == LoginScreen.routePath;

      if (!isLoggedIn) {
        return isLoggingIn ? null : LoginScreen.routePath;
      }

      if (isLoggingIn) {
        return HomeScreen.routePath;
      }

      return null;
    },
  );
}
