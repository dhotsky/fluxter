import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import 'package:fluxter/app/config/app_config.dart';
import 'package:fluxter/core/storage/local_storage.dart';
import 'package:fluxter/features/auth/domain/token.dart';

/// Interceptor that handles token-based authentication.
///
/// Extends [QueuedInterceptorsWrapper] so that when a 401 occurs, all subsequent
/// requests are queued until the token refresh completes. This prevents
/// multiple simultaneous refresh calls.
///
/// - Attaches Bearer access token to every outgoing request.
/// - Handles 401 responses by refreshing the token automatically.
/// - Forces logout when refresh fails.
class ApiTokenInterceptor extends QueuedInterceptorsWrapper {
  ApiTokenInterceptor(LocalStorage localStorage, {VoidCallback? onTokenExpired})
    : super(
        onRequest: (options, handler) {
          final token = localStorage.token;
          if (token != null) {
            options.headers['Authorization'] = 'Bearer ${token.accessToken}';
          }
          handler.next(options);
        },
        onError: (err, handler) async {
          if (err.response?.statusCode != 401) {
            return handler.next(err);
          }

          // The access token that was used for the failed request.
          final failedAuthHeader = err.requestOptions.headers['Authorization'];

          // Current token in storage (may have been refreshed by a previous queued request).
          final currentToken = localStorage.token;

          // ── Case 1: Token already refreshed by another request ──
          if (currentToken != null &&
              'Bearer ${currentToken.accessToken}' != failedAuthHeader) {
            // Token has changed since this request was made – just retry with the new token
            return _retryRequest(err.requestOptions, currentToken, handler);
          }

          // ── Case 2: Need to refresh ──
          if (currentToken?.refreshToken == null) {
            // No refresh token available → force logout.
            await localStorage.clear();
            onTokenExpired?.call();
            return handler.next(err);
          }

          try {
            // Use a separate Dio instance to avoid interceptor loop.
            final refreshDio = Dio(
              BaseOptions(
                baseUrl: AppConfig.baseUrl,
                connectTimeout: Duration(
                  milliseconds: AppConfig.connectTimeout,
                ),
                receiveTimeout: Duration(
                  milliseconds: AppConfig.receiveTimeout,
                ),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            );

            final response = await refreshDio.post(
              '/auth/refresh',
              data: {'refresh_token': currentToken!.refreshToken},
            );

            final newToken = Token.fromJson(
              response.data as Map<String, dynamic>,
            );
            await localStorage.saveToken(newToken);

            // Retry the original request with the new token.
            return _retryRequest(err.requestOptions, newToken, handler);
          } catch (_) {
            // Refresh failed → force logout and propagate the original error.
            await localStorage.clear();
            onTokenExpired?.call();
            return handler.next(err);
          }
        },
      );

  /// Retry the original request with an updated [token].
  static Future<void> _retryRequest(
    RequestOptions requestOptions,
    Token token,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      requestOptions.headers['Authorization'] = 'Bearer ${token.accessToken}';

      // Use a clean Dio to avoid going through interceptors again.
      final retryDio = Dio(
        BaseOptions(
          baseUrl: AppConfig.baseUrl,
          connectTimeout: Duration(milliseconds: AppConfig.connectTimeout),
          receiveTimeout: Duration(milliseconds: AppConfig.receiveTimeout),
        ),
      );

      dynamic data = requestOptions.data;
      if (data is FormData) {
        data = await _cloneFormData(data);
      }

      final retryResponse = await retryDio.fetch(
        requestOptions.copyWith(data: data),
      );
      handler.resolve(retryResponse);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  /// Clones FormData because multipart file streams can only be read once.
  static Future<FormData> _cloneFormData(FormData original) async {
    final newForm = FormData();

    for (final field in original.fields) {
      newForm.fields.add(MapEntry(field.key, field.value));
    }

    for (final file in original.files) {
      final mf = file.value;
      try {
        newForm.files.add(MapEntry(file.key, mf.clone()));
      } catch (e) {
        final bytes = await mf.finalize().expand((e) => e).toList();
        newForm.files.add(
          MapEntry(
            file.key,
            MultipartFile.fromBytes(
              bytes,
              filename: mf.filename,
              contentType: mf.contentType,
            ),
          ),
        );
      }
    }

    return newForm;
  }
}
