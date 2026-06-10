import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fluxter/features/auth/domain/user.dart';
import 'package:fluxter/features/auth/presentation/auth_controller.dart';
import 'package:fluxter/features/auth/presentation/login_screen.dart';
import 'package:fluxter/features/home/presentation/home_screen.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AsyncValue<User?>>(
      authControllerProvider,
      (_, _) => notifyListeners(),
    );
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final goRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: LoginScreen.routePath,
    refreshListenable: notifier,
    routes: [
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
});
