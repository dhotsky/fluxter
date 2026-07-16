import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'chucker.dart';
import 'chucker_http_log.dart';

class ChuckerOverlayWrapper extends StatelessWidget {
  final Widget child;

  const ChuckerOverlayWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: Chucker.shouldShowNotifier,
      builder: (context, shouldShow, _) {
        if (!shouldShow) {
          return child;
        }
        return Stack(
          textDirection: TextDirection.ltr,
          children: [child, const ChuckerFloatingBubble()],
        );
      },
    );
  }
}

class ChuckerFloatingBubble extends StatefulWidget {
  const ChuckerFloatingBubble({super.key});

  @override
  State<ChuckerFloatingBubble> createState() => _ChuckerFloatingBubbleState();
}

class _ChuckerFloatingBubbleState extends State<ChuckerFloatingBubble> {
  static double _left = -1.0;
  static double _top = -1.0;
  static bool _isInitialized = false;

  bool _isDragging = false;
  bool _isOnChuckerScreen = false;

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navContext = Chucker.navigatorKey.currentContext;
      if (navContext != null) {
        try {
          final router = GoRouter.of(navContext);
          router.routerDelegate.addListener(_onRouteChanged);
          _checkIfChuckerRoute(router.routeInformationProvider.value.uri.path);
        } catch (_) {}
      }
    });
  }

  @override
  void dispose() {
    final navContext = Chucker.navigatorKey.currentContext;
    if (navContext != null) {
      try {
        GoRouter.of(navContext).routerDelegate.removeListener(_onRouteChanged);
      } catch (_) {}
    }
    super.dispose();
  }

  void _onRouteChanged() {
    final navContext = Chucker.navigatorKey.currentContext;
    if (navContext != null) {
      try {
        final path = GoRouter.of(navContext).routeInformationProvider.value.uri.path;
        _checkIfChuckerRoute(path);
      } catch (_) {}
    }
  }

  void _checkIfChuckerRoute(String path) {
    final isChucker = path.startsWith('/chucker');
    if (isChucker != _isOnChuckerScreen) {
      if (mounted) {
        setState(() {
          _isOnChuckerScreen = isChucker;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isOnChuckerScreen) {
      return const SizedBox.shrink();
    }

    final size = MediaQuery.of(context).size;
    final bubbleSize = 44.0; // Shrunk size from 56.0

    // Initialize position to bottom right of screen on first load
    if (!_isInitialized) {
      _left = size.width - bubbleSize - 16.0;
      _top = size.height - bubbleSize - 100.0;
      _isInitialized = true;
    }

    return AnimatedPositioned(
      duration: _isDragging ? Duration.zero : const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      left: _left,
      top: _top,
      child: Material(
        type: MaterialType.transparency,
        child: GestureDetector(
          onPanStart: (_) {
            setState(() {
              _isDragging = true;
            });
          },
          onPanUpdate: (details) {
            setState(() {
              _left = (_left + details.delta.dx).clamp(
                16.0,
                size.width - bubbleSize - 16.0,
              );
              _top = (_top + details.delta.dy).clamp(
                40.0,
                size.height - bubbleSize - 40.0,
              );
            });
          },
          onPanEnd: (_) {
            setState(() {
              _isDragging = false;
              // Snap to nearest horizontal edge
              if (_left < (size.width / 2)) {
                _left = 16.0;
              } else {
                _left = size.width - bubbleSize - 16.0;
              }
            });
          },
          onTap: () {
            // Open Chucker Log list screen using the root navigator context
            final context = Chucker.navigatorKey.currentContext;
            if (context != null) {
              context.push('/chucker');
            }
          },
          child: StreamBuilder<List<ChuckerHttpLog>>(
            stream: Chucker.logsStream,
            initialData: Chucker.logs,
            builder: (context, snapshot) {
              final logs = snapshot.data ?? [];
              final errorCount = logs.where((l) => l.isError).length;
              final hasErrors = errorCount > 0;

              return Container(
                width: bubbleSize,
                height: bubbleSize,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withValues(alpha: 0.9), // Glassy Slate
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: hasErrors
                        ? const Color(0xFFEF4444).withValues(alpha: 0.8)
                        : Colors.blue.withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Network symbol icon
                    Icon(
                      Icons.swap_vert_rounded,
                      color: hasErrors
                          ? const Color(0xFFEF4444)
                          : Colors.blue[300],
                      size: 22, // Reduced size from 28
                    ),
                    // Status Badge if logs are present
                    if (logs.isNotEmpty)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: hasErrors
                                ? const Color(0xFFEF4444)
                                : Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF1E293B),
                              width: 1,
                            ),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 14,
                            minHeight: 14,
                          ),
                          child: Center(
                            child: Text(
                              hasErrors
                                  ? errorCount.toString()
                                  : logs.length.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8, // Reduced from 9
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
