import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:awesome_dio_interceptor/awesome_dio_interceptor.dart';

import 'package:fluxter/app/config/app_config.dart';
import 'package:fluxter/core/network/api_response.dart';
import 'package:fluxter/core/network/api_token_interceptor.dart';
import 'package:fluxter/core/storage/local_storage.dart';
import 'package:fluxter/features/auth/domain/login_data.dart';
import 'package:fluxter/features/auth/presentation/auth_controller.dart';
import 'package:fluxter/features/auth/domain/user.dart';

part '../../gen/core/network/api_service.g.dart';

/// Retrofit API Service — define all endpoints here.
///
/// After adding/modifying endpoints, run:
/// ```bash
/// dart run build_runner build
/// ```
@RestApi()
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  // ── Auth ──────────────────────────────────────────

  @POST('/auth/login')
  Future<ApiResponse<LoginData>> login(@Body() Map<String, dynamic> body);

  @POST('/auth/register')
  Future<ApiResponse<User>> register(@Body() Map<String, dynamic> body);

  // ── User ──────────────────────────────────────────

  @GET('/user/profile')
  Future<ApiResponse<User>> getProfile();
}

@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: Duration(milliseconds: AppConfig.connectTimeout),
      receiveTimeout: Duration(milliseconds: AppConfig.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.addAll([
    ApiTokenInterceptor(
      ref.watch(localStorageProvider),
      onTokenExpired: () {
        ref.read(authControllerProvider.notifier).logout();
      },
    ),
    AwesomeDioInterceptor(),
  ]);

  return dio;
}

@Riverpod(keepAlive: true)
ApiService apiService(Ref ref) {
  final d = ref.watch(dioProvider);
  return ApiService(d);
}
