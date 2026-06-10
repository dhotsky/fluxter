/// Sealed class for wrapping API responses.
///
/// Usage:
/// ```dart
/// final result = await repository.fetchData();
/// result.when(
///   success: (data) => print(data),
///   error: (message, statusCode) => print('Error: $message'),
/// );
/// ```
sealed class ApiResult<T> {
  const ApiResult();

  R when<R>({
    required R Function(T data) success,
    required R Function(String message, int? statusCode) error,
  });
}

class ApiSuccess<T> extends ApiResult<T> {
  final T data;
  const ApiSuccess(this.data);

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(String message, int? statusCode) error,
  }) => success(data);
}

class ApiError<T> extends ApiResult<T> {
  final String message;
  final int? statusCode;
  const ApiError(this.message, {this.statusCode});

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(String message, int? statusCode) error,
  }) => error(message, statusCode);
}
