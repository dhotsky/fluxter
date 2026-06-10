import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluxter/core/network/api_manager.dart';
import 'package:fluxter/core/network/api_service.dart';
import 'package:fluxter/core/network/api_result.dart';
import 'package:fluxter/core/storage/local_storage.dart';
import 'package:fluxter/features/auth/domain/user.dart';
import 'package:fluxter/features/auth/domain/token.dart';

class AuthRepository {
  final ApiService _apiService;
  final LocalStorage _localStorage;

  AuthRepository(this._apiService, this._localStorage);

  Future<ApiResult<User>> login(String email, String password) async {
    // Simulate API call as in the original LoginViewModel
    await Future.delayed(const Duration(seconds: 2));

    if (email.isEmpty || password.isEmpty) {
      return const ApiError('Email and password cannot be empty');
    }

    const user = User(id: 1, name: 'John Doe', email: 'john@example.com');
    const token = Token(
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
      expiresIn: 3600,
    );

    await _localStorage.saveToken(token);
    await _localStorage.saveUser(user);

    return const ApiSuccess(user);
  }

  Future<ApiResult<User>> register(
    String name,
    String email,
    String password,
  ) async {
    return ApiManager.request(
      () => _apiService.register({
        'name': name,
        'email': email,
        'password': password,
      }),
    );
  }

  Future<void> logout() async {
    await _localStorage.clear();
  }

  User? get currentUser => _localStorage.user;
  bool get isLoggedIn => _localStorage.isLoggedIn;
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final localStorage = ref.watch(localStorageProvider);
  return AuthRepository(apiService, localStorage);
});
