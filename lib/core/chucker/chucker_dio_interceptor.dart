// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:dio/dio.dart';
import 'chucker.dart';
import 'chucker_http_log.dart';

class ChuckerDioInterceptor extends Interceptor {
  static const String _startTimeKey = '_chucker_start_time';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startTimeKey] = DateTime.now();
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (Chucker.enabled) {
      try {
        final startTime = response.requestOptions.extra[_startTimeKey] as DateTime?;
        final timestamp = startTime ?? DateTime.now();
        final duration = DateTime.now().difference(timestamp);

        final requestBody = _parseBody(response.requestOptions.data);
        final responseBody = _parseBody(response.data);

        final log = ChuckerHttpLog(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          url: response.requestOptions.uri.toString(),
          method: response.requestOptions.method,
          statusCode: response.statusCode,
          requestHeaders: response.requestOptions.headers,
          requestBody: requestBody,
          responseHeaders: _parseHeaders(response.headers),
          responseBody: responseBody,
          timestamp: timestamp,
          duration: duration,
          requestSize: _estimateSize(response.requestOptions.data),
          responseSize: _estimateSize(response.data),
        );

        Chucker.addLog(log);
      } catch (e) {
        // Silently fail to avoid crashing the main app
        print('ChuckerDioInterceptor error (Response): $e');
      }
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (Chucker.enabled) {
      try {
        final startTime = err.requestOptions.extra[_startTimeKey] as DateTime?;
        final timestamp = startTime ?? DateTime.now();
        final duration = DateTime.now().difference(timestamp);

        final requestBody = _parseBody(err.requestOptions.data);
        final responseBody = _parseBody(err.response?.data);

        final log = ChuckerHttpLog(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          url: err.requestOptions.uri.toString(),
          method: err.requestOptions.method,
          statusCode: err.response?.statusCode,
          requestHeaders: err.requestOptions.headers,
          requestBody: requestBody,
          responseHeaders: err.response != null ? _parseHeaders(err.response!.headers) : null,
          responseBody: responseBody,
          errorMessage: err.message ?? err.toString(),
          timestamp: timestamp,
          duration: duration,
          requestSize: _estimateSize(err.requestOptions.data),
          responseSize: err.response != null ? _estimateSize(err.response!.data) : 0,
        );

        Chucker.addLog(log);
      } catch (e) {
        // Silently fail to avoid crashing the main app
        print('ChuckerDioInterceptor error (Error): $e');
      }
    }
    handler.next(err);
  }

  dynamic _parseBody(dynamic body) {
    if (body == null) return null;
    if (body is FormData) {
      final map = <String, dynamic>{};
      for (final entry in body.fields) {
        map[entry.key] = entry.value;
      }
      for (final entry in body.files) {
        map[entry.key] = '[File: ${entry.value.filename ?? 'unnamed'}, Size: ${entry.value.length} bytes]';
      }
      return map;
    }
    return body;
  }

  Map<String, dynamic> _parseHeaders(Headers headers) {
    final map = <String, dynamic>{};
    headers.forEach((key, values) {
      map[key] = values.length == 1 ? values.first : values;
    });
    return map;
  }

  int _estimateSize(dynamic data) {
    if (data == null) return 0;
    if (data is String) return data.length;
    if (data is List<int>) return data.length;
    if (data is FormData) {
      int size = 0;
      for (final entry in data.fields) {
        size += entry.key.length + entry.value.length;
      }
      for (final entry in data.files) {
        size += entry.key.length + entry.value.length;
      }
      return size;
    }
    try {
      return jsonEncode(data).length;
    } catch (_) {
      return 0;
    }
  }
}
