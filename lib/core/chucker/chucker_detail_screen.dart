import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'chucker_http_log.dart';

class ChuckerDetailScreen extends StatelessWidget {
  final ChuckerHttpLog log;

  const ChuckerDetailScreen({super.key, required this.log});

  static const String routePath = '/chucker/detail';

  @override
  Widget build(BuildContext context) {
    final darkBg = const Color(0xFF0F172A);
    final darkCard = const Color(0xFF1E293B);
    final darkText = const Color(0xFFF8FAFC);
    final darkSubText = const Color(0xFF94A3B8);
    final darkBorder = const Color(0xFF334155);

    final showErrTab = log.errorMessage != null || log.isError;

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: darkBg,
        cardColor: darkCard,
        dividerColor: darkBorder,
        appBarTheme: AppBarTheme(
          backgroundColor: darkBg,
          elevation: 0,
          iconTheme: IconThemeData(color: darkText),
          titleTextStyle: TextStyle(
            color: darkText,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      child: DefaultTabController(
        length: showErrTab ? 4 : 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Transaction Details'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.code),
                tooltip: 'Copy as cURL',
                onPressed: () {
                  final curl = _toCurl(log);
                  Clipboard.setData(ClipboardData(text: curl));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Copied request as cURL command!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.copy_all),
                tooltip: 'Copy Full Log',
                onPressed: () {
                  final fullLog = _toFullLogJson(log);
                  Clipboard.setData(ClipboardData(text: fullLog));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Copied full transaction log to clipboard!',
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
            bottom: TabBar(
              isScrollable: false,
              indicatorColor: Colors.blue,
              labelColor: Colors.blue,
              unselectedLabelColor: darkSubText,
              tabs: [
                const Tab(text: 'Overview'),
                const Tab(text: 'Request'),
                const Tab(text: 'Response'),
                if (showErrTab) const Tab(text: 'Error'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _buildOverviewTab(
                context,
                darkCard,
                darkBorder,
                darkText,
                darkSubText,
              ),
              _buildRequestTab(
                context,
                darkCard,
                darkBorder,
                darkText,
                darkSubText,
              ),
              _buildResponseTab(
                context,
                darkCard,
                darkBorder,
                darkText,
                darkSubText,
              ),
              if (showErrTab)
                _buildErrorTab(
                  context,
                  darkCard,
                  darkBorder,
                  darkText,
                  darkSubText,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(
    BuildContext context,
    Color cardColor,
    Color borderColor,
    Color textColor,
    Color subTextColor,
  ) {
    Color statusColor = const Color(0xFF10B981);
    if (log.isPending) {
      statusColor = const Color(0xFF64748B);
    } else if (log.statusCode != null) {
      final code = log.statusCode!;
      if (code >= 300 && code < 400) statusColor = const Color(0xFFF59E0B);
      if (code >= 400) statusColor = const Color(0xFFEF4444);
    } else {
      statusColor = const Color(0xFFEF4444);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // URL Info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'FULL URL',
                      style: TextStyle(
                        color: subTextColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: log.url));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('URL copied!'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Icon(Icons.copy, size: 12, color: Colors.blue[300]),
                          const SizedBox(width: 4),
                          Text(
                            'Copy',
                            style: TextStyle(
                              color: Colors.blue[300],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  log.url,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13,
                    fontFamily: 'Courier',
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Metadata Grid
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                _buildOverviewRow(
                  'Method',
                  log.method,
                  valColor: _getMethodColor(log.method),
                ),
                const Divider(),
                _buildOverviewRow(
                  'Status',
                  log.isPending
                      ? 'PENDING'
                      : (log.statusCode?.toString() ?? 'ERROR'),
                  valColor: statusColor,
                ),
                const Divider(),
                _buildOverviewRow(
                  'Timestamp',
                  log.timestamp.toLocal().toString(),
                ),
                const Divider(),
                _buildOverviewRow(
                  'Duration',
                  '${log.duration.inMilliseconds} ms',
                ),
                const Divider(),
                _buildOverviewRow('Request Size', '${log.requestSize} Bytes'),
                const Divider(),
                _buildOverviewRow(
                  'Response Size',
                  log.responseSize > 0
                      ? '${(log.responseSize / 1024).toStringAsFixed(2)} KB (${log.responseSize} B)'
                      : '0 B',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestTab(
    BuildContext context,
    Color cardColor,
    Color borderColor,
    Color textColor,
    Color subTextColor,
  ) {
    final uri = Uri.parse(log.url);
    final queryParams = uri.queryParameters;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Query Params (if any)
          if (queryParams.isNotEmpty) ...[
            _buildSectionHeader('Query Parameters'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: queryParams.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 120,
                          child: Text(
                            entry.key,
                            style: TextStyle(
                              color: subTextColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Courier',
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 13,
                              fontFamily: 'Courier',
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Request Headers
          _buildSectionHeader('Headers'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: log.requestHeaders.isEmpty
                ? Center(
                    child: Text(
                      'No Headers',
                      style: TextStyle(color: subTextColor, fontSize: 13),
                    ),
                  )
                : Column(
                    children: log.requestHeaders.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 140,
                              child: Text(
                                entry.key,
                                style: TextStyle(
                                  color: subTextColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Courier',
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                entry.value.toString(),
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 13,
                                  fontFamily: 'Courier',
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
          const SizedBox(height: 16),

          // Request Body
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionHeader('Body'),
              if (log.requestBody != null)
                IconButton(
                  icon: const Icon(Icons.copy, size: 16, color: Colors.blue),
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: _formatJson(log.requestBody)),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Request body copied!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 8),
          _buildBodyContainer(
            log.requestBody,
            cardColor,
            borderColor,
            textColor,
            subTextColor,
          ),
        ],
      ),
    );
  }

  Widget _buildResponseTab(
    BuildContext context,
    Color cardColor,
    Color borderColor,
    Color textColor,
    Color subTextColor,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Response Headers
          _buildSectionHeader('Headers'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: log.responseHeaders == null || log.responseHeaders!.isEmpty
                ? Center(
                    child: Text(
                      'No Headers',
                      style: TextStyle(color: subTextColor, fontSize: 13),
                    ),
                  )
                : Column(
                    children: log.responseHeaders!.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 140,
                              child: Text(
                                entry.key,
                                style: TextStyle(
                                  color: subTextColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Courier',
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                entry.value.toString(),
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 13,
                                  fontFamily: 'Courier',
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
          const SizedBox(height: 16),

          // Response Body
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionHeader('Body'),
              if (log.responseBody != null)
                IconButton(
                  icon: const Icon(Icons.copy, size: 16, color: Colors.blue),
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: _formatJson(log.responseBody)),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Response body copied!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 8),
          _buildBodyContainer(
            log.responseBody,
            cardColor,
            borderColor,
            textColor,
            subTextColor,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorTab(
    BuildContext context,
    Color cardColor,
    Color borderColor,
    Color textColor,
    Color subTextColor,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Error Details'),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFEF4444).withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ERROR MESSAGE',
                      style: TextStyle(
                        color: Color(0xFFEF4444),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.copy,
                        size: 16,
                        color: Color(0xFFEF4444),
                      ),
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(
                            text: log.errorMessage ?? 'Unknown Error',
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Error copied!'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  log.errorMessage ??
                      'An unknown error occurred during HTTP transaction (possibly empty response or connection issue).',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13,
                    fontFamily: 'Courier',
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: Color(0xFF64748B),
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildOverviewRow(String label, String value, {Color? valColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
          ),
          Text(
            value,
            style: TextStyle(
              color: valColor ?? const Color(0xFFF8FAFC),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyContainer(
    dynamic body,
    Color cardColor,
    Color borderColor,
    Color textColor,
    Color subTextColor,
  ) {
    if (body == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Center(
          child: Text(
            'Empty Body',
            style: TextStyle(color: subTextColor, fontSize: 13),
          ),
        ),
      );
    }

    final formatted = _formatJson(body);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(
          formatted,
          style: TextStyle(
            color: textColor,
            fontFamily: 'Courier',
            fontSize: 12,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  String _formatJson(dynamic jsonObject) {
    if (jsonObject == null) return '';
    try {
      if (jsonObject is Map || jsonObject is List) {
        const encoder = JsonEncoder.withIndent('  ');
        return encoder.convert(jsonObject);
      }
      return jsonObject.toString();
    } catch (_) {
      return jsonObject.toString();
    }
  }

  String _toCurl(ChuckerHttpLog log) {
    final buffer = StringBuffer('curl -X ${log.method} "${log.url}"');
    log.requestHeaders.forEach((key, value) {
      buffer.write(' -H "$key: $value"');
    });
    if (log.requestBody != null) {
      try {
        final data = log.requestBody is Map || log.requestBody is List
            ? jsonEncode(log.requestBody)
            : log.requestBody.toString();
        // Escape double quotes
        final escapedData = data.replaceAll('"', '\\"');
        buffer.write(' -d "$escapedData"');
      } catch (_) {}
    }
    return buffer.toString();
  }

  String _toFullLogJson(ChuckerHttpLog log) {
    final map = <String, dynamic>{
      'url': log.url,
      'method': log.method,
      'status_code': log.statusCode,
      'timestamp': log.timestamp.toIso8601String(),
      'duration_ms': log.duration.inMilliseconds,
      'request_headers': log.requestHeaders,
      'request_body': log.requestBody,
      'response_headers': log.responseHeaders,
      'response_body': log.responseBody,
      'error_message': log.errorMessage,
    };
    try {
      return const JsonEncoder.withIndent('  ').convert(map);
    } catch (_) {
      return map.toString();
    }
  }

  Color _getMethodColor(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return const Color(0xFF3B82F6);
      case 'POST':
        return const Color(0xFF10B981);
      case 'PUT':
        return const Color(0xFFF59E0B);
      case 'DELETE':
        return const Color(0xFFEF4444);
      case 'PATCH':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF64748B);
    }
  }
}
