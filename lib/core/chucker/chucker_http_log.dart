class ChuckerHttpLog {
  final String id;
  final String url;
  final String method;
  final int? statusCode;
  final Map<String, dynamic> requestHeaders;
  final dynamic requestBody;
  final Map<String, dynamic>? responseHeaders;
  final dynamic responseBody;
  final String? errorMessage;
  final DateTime timestamp;
  final Duration duration;
  final int requestSize;
  final int responseSize;

  ChuckerHttpLog({
    required this.id,
    required this.url,
    required this.method,
    this.statusCode,
    required this.requestHeaders,
    this.requestBody,
    this.responseHeaders,
    this.responseBody,
    this.errorMessage,
    required this.timestamp,
    required this.duration,
    required this.requestSize,
    required this.responseSize,
  });

  bool get isError =>
      statusCode == null || statusCode! < 200 || statusCode! >= 400;

  bool get isPending => statusCode == null && errorMessage == null;

  String get path {
    try {
      final uri = Uri.parse(url);
      return uri.path;
    } catch (_) {
      return url;
    }
  }

  String get host {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (_) {
      return '';
    }
  }
}
