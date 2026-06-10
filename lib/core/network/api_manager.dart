import 'package:dio/dio.dart';
import 'package:fluxter/core/network/api_response.dart';
import 'package:fluxter/core/network/api_result.dart';
import 'package:fluxter/app/localization/translation_keys.dart';
import 'package:fluxter/app/localization/app_translations.dart';

/// Utility class to execute API calls and map exceptions automatically.
class ApiManager {
  ApiManager._();

  /// Executes an API call, unwraps the [ApiResponse], and catches all exceptions.
  /// Returns [ApiSuccess] with the data if successful.
  /// Returns [ApiError] with the error message and status code if failed.
  ///
  /// Usage in Repository:
  /// ```dart
  /// Future<ApiResult<User>> getProfile() async {
  ///   return ApiManager.request(() => _apiService.getProfile());
  /// }
  /// ```
  static Future<ApiResult<T>> request<T>(
    Future<ApiResponse<T>> Function() apiCall,
  ) async {
    try {
      final response = await apiCall();
      if (response.data != null) {
        return ApiSuccess(response.data as T);
      } else {
        // Handle cases where API indicates success but data is null
        return const ApiError('Empty response data');
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiError('${TranslationKeys.errUnknown.tr}: $e');
    }
  }

  static ApiError<T> _handleDioError<T>(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiError(TranslationKeys.errTimeout.tr, statusCode: 408);
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 500;
        final serverMessage = _parseErrorMessage(e.response);
        if (serverMessage != null) {
          return ApiError(serverMessage, statusCode: statusCode);
        }
        if (statusCode == 400) {
          return ApiError(
            TranslationKeys.errBadRequest.tr,
            statusCode: statusCode,
          );
        } else if (statusCode == 401) {
          return ApiError(
            TranslationKeys.errUnauthorized.tr,
            statusCode: statusCode,
          );
        } else if (statusCode == 404) {
          return ApiError(
            TranslationKeys.errNotFound.tr,
            statusCode: statusCode,
          );
        } else if (statusCode >= 500) {
          return ApiError(TranslationKeys.errServer.tr, statusCode: statusCode);
        }
        return ApiError(TranslationKeys.errUnknown.tr, statusCode: statusCode);
      case DioExceptionType.connectionError:
        return ApiError(TranslationKeys.errNoInternet.tr);
      default:
        return ApiError(TranslationKeys.errUnknown.tr);
    }
  }

  static String? _parseErrorMessage(Response? response) {
    if (response == null || response.data == null) {
      return null;
    }

    final data = response.data;
    if (data is Map<String, dynamic>) {
      // Adjust key based on your backend error format (e.g. 'message', 'error', 'msg')
      if (data.containsKey('message')) {
        return data['message'] as String;
      }
    }
    return null;
  }
}
