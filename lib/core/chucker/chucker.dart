import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'chucker_http_log.dart';

class Chucker {
  static bool _enabled = false;
  static bool _showInRelease = false;

  static const int maxLogs = 100;

  static final ValueNotifier<bool> shouldShowNotifier = ValueNotifier<bool>(
    false,
  );

  static final List<ChuckerHttpLog> logs = [];

  static final StreamController<List<ChuckerHttpLog>> _logsStreamController =
      StreamController<List<ChuckerHttpLog>>.broadcast();

  static Stream<List<ChuckerHttpLog>> get logsStream =>
      _logsStreamController.stream;

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static bool get enabled => _enabled;
  static set enabled(bool value) {
    _enabled = value;
    _updateNotifier();
  }

  static bool get showInRelease => _showInRelease;
  static set showInRelease(bool value) {
    _showInRelease = value;
    _updateNotifier();
  }

  static bool get shouldShow => shouldShowNotifier.value;

  static void _updateNotifier() {
    shouldShowNotifier.value = _enabled && (!kReleaseMode || _showInRelease);
  }

  static void addLog(ChuckerHttpLog log) {
    if (!_enabled) return;

    // Add to the beginning of the list (newest first)
    logs.insert(0, log);

    // Enforce max logs limit for memory safety
    if (logs.length > maxLogs) {
      logs.removeLast();
    }

    _logsStreamController.add(List.unmodifiable(logs));
  }

  static void clearLogs() {
    logs.clear();
    _logsStreamController.add(List.unmodifiable(logs));
  }
}

// Alias for compatibility with User's spelling variation
typedef Chuxer = Chucker;
