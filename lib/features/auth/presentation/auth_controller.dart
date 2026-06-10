import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fluxter/core/network/api_result.dart';
import 'package:fluxter/features/auth/data/auth_repository.dart';
import 'package:fluxter/features/auth/domain/user.dart';

part '../../../gen/features/auth/presentation/auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
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
