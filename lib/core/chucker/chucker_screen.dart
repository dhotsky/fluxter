import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'chucker.dart';
import 'chucker_http_log.dart';

class ChuckerScreen extends StatefulWidget {
  const ChuckerScreen({super.key});

  static const String routePath = '/chucker';

  @override
  State<ChuckerScreen> createState() => _ChuckerScreenState();
}

class _ChuckerScreenState extends State<ChuckerScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _activeFilter = 'All'; // All, Success, Errors, Pending

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Premium dark developer console theme
    final darkBg = const Color(0xFF0F172A);
    final darkCard = const Color(0xFF1E293B);
    final darkText = const Color(0xFFF8FAFC);
    final darkSubText = const Color(0xFF94A3B8);
    final darkBorder = const Color(0xFF334155);

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
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Network Inspector'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.delete_sweep_outlined,
                color: Color(0xFFEF4444),
              ),
              tooltip: 'Clear Logs',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear all logs?'),
                    content: const Text(
                      'This action will delete all recorded HTTP network logs in this session.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Chucker.clearLogs();
                          Navigator.pop(ctx);
                        },
                        child: const Text(
                          'Clear',
                          style: TextStyle(color: Color(0xFFEF4444)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: darkCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: darkBorder),
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: darkText, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search by URL path, method, status...',
                    hintStyle: TextStyle(
                      color: darkSubText.withValues(alpha: 0.6),
                    ),
                    prefixIcon: Icon(Icons.search, color: darkSubText),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: darkSubText),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),

            // Filters
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 4.0,
              ),
              child: Row(
                children: [
                  _buildFilterChip('All', Colors.blue, darkCard, darkText),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Success',
                    const Color(0xFF10B981),
                    darkCard,
                    darkText,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Errors',
                    const Color(0xFFEF4444),
                    darkCard,
                    darkText,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Pending',
                    const Color(0xFF64748B),
                    darkCard,
                    darkText,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // List of Logs
            Expanded(
              child: StreamBuilder<List<ChuckerHttpLog>>(
                stream: Chucker.logsStream,
                initialData: Chucker.logs,
                builder: (context, snapshot) {
                  final allLogs = snapshot.data ?? [];

                  // Apply Filters & Search
                  final filteredLogs = allLogs.where((log) {
                    // Filter match
                    if (_activeFilter == 'Success' && log.isError) {
                      return false;
                    }
                    if (_activeFilter == 'Errors' && !log.isError) {
                      return false;
                    }
                    if (_activeFilter == 'Pending' && !log.isPending) {
                      return false;
                    }

                    // Search match
                    if (_searchQuery.isNotEmpty) {
                      final urlMatch = log.url.toLowerCase().contains(
                        _searchQuery,
                      );
                      final methodMatch = log.method.toLowerCase().contains(
                        _searchQuery,
                      );
                      final statusMatch =
                          log.statusCode?.toString().contains(_searchQuery) ??
                          false;
                      return urlMatch || methodMatch || statusMatch;
                    }
                    return true;
                  }).toList();

                  if (filteredLogs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.wifi_off_rounded,
                            size: 48,
                            color: darkSubText.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No network logs recorded'
                                : 'No logs match your search',
                            style: TextStyle(color: darkSubText, fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: filteredLogs.length,
                    separatorBuilder: (context, index) =>
                        Divider(height: 1, color: darkBorder),
                    itemBuilder: (context, index) {
                      final log = filteredLogs[index];
                      return _buildLogTile(
                        context,
                        log,
                        darkText,
                        darkSubText,
                        darkCard,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    Color activeColor,
    Color cardColor,
    Color textColor,
  ) {
    final isActive = _activeFilter == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _activeFilter = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? activeColor.withValues(alpha: 0.2) : cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive ? activeColor : const Color(0xFF334155),
              width: isActive ? 1.5 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isActive
                    ? activeColor
                    : textColor.withValues(alpha: 0.8),
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogTile(
    BuildContext context,
    ChuckerHttpLog log,
    Color textColor,
    Color subTextColor,
    Color cardColor,
  ) {
    Color statusColor;
    String statusStr = '---';

    if (log.isPending) {
      statusColor = const Color(0xFF64748B); // gray
      statusStr = 'PEND';
    } else if (log.statusCode != null) {
      statusStr = log.statusCode.toString();
      final code = log.statusCode!;
      if (code >= 200 && code < 300) {
        statusColor = const Color(0xFF10B981); // emerald green
      } else if (code >= 300 && code < 400) {
        statusColor = const Color(0xFFF59E0B); // amber orange
      } else if (code >= 400 && code < 500) {
        statusColor = const Color(0xFFEF4444); // red
      } else {
        statusColor = const Color(0xFFEC4899); // pink/purple for server error
      }
    } else {
      statusColor = const Color(0xFFEF4444);
      statusStr = 'ERR';
    }

    final methodBgColor = _getMethodColor(log.method).withValues(alpha: 0.15);
    final methodTextColor = _getMethodColor(log.method);

    final timeStr =
        '${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')}:${log.timestamp.second.toString().padLeft(2, '0')}';
    final durationMs = '${log.duration.inMilliseconds} ms';
    final sizeKb = log.responseSize > 0
        ? '${(log.responseSize / 1024).toStringAsFixed(2)} KB'
        : '${log.requestSize} B';

    return InkWell(
      onTap: () {
        context.push('/chucker/detail', extra: log);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Code Badge
            Container(
              width: 48,
              height: 32,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: statusColor.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  statusStr,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Method and URL Path
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // HTTP Method Tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: methodBgColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          log.method,
                          style: TextStyle(
                            color: methodTextColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Path
                      Expanded(
                        child: Text(
                          log.path.isEmpty ? '/' : log.path,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Courier',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Host
                  Text(
                    log.host,
                    style: TextStyle(
                      color: subTextColor.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  // Timestamp
                  Text(
                    timeStr,
                    style: TextStyle(
                      color: subTextColor.withValues(alpha: 0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Size & Time Info
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  durationMs,
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  sizeKb,
                  style: TextStyle(
                    color: subTextColor.withValues(alpha: 0.6),
                    fontSize: 11,
                  ),
                ),
                if (log.isError) ...[
                  const SizedBox(height: 4),
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 14,
                    color: Color(0xFFEF4444),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getMethodColor(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return const Color(0xFF3B82F6); // Blue
      case 'POST':
        return const Color(0xFF10B981); // Green
      case 'PUT':
        return const Color(0xFFF59E0B); // Orange
      case 'DELETE':
        return const Color(0xFFEF4444); // Red
      case 'PATCH':
        return const Color(0xFF8B5CF6); // Purple
      default:
        return const Color(0xFF64748B); // Slate
    }
  }
}
