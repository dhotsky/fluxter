import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluxter/core/network/api_result.dart';
import 'package:fluxter/features/auth/data/auth_repository.dart';
import 'package:fluxter/features/auth/domain/user.dart';

class AuthController extends AsyncNotifier<User?> {
  @override
  FutureOr<User?> build() {
    final repository = ref.watch(authRepositoryProvider);
    return repository.currentUser;
  }

  Future<ApiResult<User>> login(String email, String password) async {
    state = const AsyncLoading();
    final repository = ref.read(authRepositoryProvider);
    final result = await repository.login(email, password);

    result.when(
      success: (user) {
        state = AsyncData(user);
      },
      error: (message, statusCode) {
        state = AsyncError(Exception(message), StackTrace.current);
      },
    );
    return result;
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    final repository = ref.read(authRepositoryProvider);
    await repository.logout();
    state = const AsyncData(null);
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, User?>(
  () => AuthController(),
);
