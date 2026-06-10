import 'package:freezed_annotation/freezed_annotation.dart';

part '../../gen/core/network/api_response.freezed.dart';
part '../../gen/core/network/api_response.g.dart';

/// Generic API response wrapper.
///
/// Wraps the standard response structure from the backend so you don't
/// need to create a separate response model for every endpoint.
///
/// Assumes the backend returns a JSON structure like:
/// ```json
/// {
///   "message": "Login successful",
///   "data": { ... }
/// }
/// ```
///
/// Usage with Retrofit:
/// ```dart
/// @POST('/auth/login')
/// Future<ApiResponse<User>> login(@Body() Map<String, dynamic> body);
///
/// @GET('/user/profile')
/// Future<ApiResponse<User>> getProfile();
/// ```
///
/// Usage in repository:
/// ```dart
/// final response = await _apiService.login({...});
/// final user = response.data; // Already typed as User?
/// ```
@Freezed(genericArgumentFactories: true)
abstract class ApiResponse<T> with _$ApiResponse<T> {
  const factory ApiResponse({String? message, T? data}) = _ApiResponse;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) => _$ApiResponseFromJson(json, fromJsonT);
}
