import 'package:flutter/material.dart';

extension NumExtension on num {
  // ── Layout Spacing Helpers ─────────────────────────────────────────────
  Widget get height => SizedBox(height: toDouble());
  Widget get width => SizedBox(width: toDouble());
}
