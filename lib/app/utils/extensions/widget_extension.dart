import 'package:flutter/material.dart';

extension WidgetExtension on Widget {
  // ── Alignment Wrappers ─────────────────────────────────────────────────

  /// Centers the widget inside its parent.
  Widget get center => Center(child: this);

  /// Aligns the widget within its parent.
  Widget align(Alignment alignment) => Align(alignment: alignment, child: this);

  // ── Scroll Wrappers ────────────────────────────────────────────────────

  /// Wraps the widget with a single child scroll view.
  Widget get toScrollable => SingleChildScrollView(child: this);

  // ── Padding Wrappers ───────────────────────────────────────────────────

  /// Adds symmetric padding to the widget.
  Widget paddingSymmetric({double horizontal = 0.0, double vertical = 0.0}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      child: this,
    );
  }

  /// Adds uniform padding to all sides of the widget.
  Widget paddingAll(double value) {
    return Padding(padding: EdgeInsets.all(value), child: this);
  }

  /// Adds selective padding to the widget.
  Widget paddingOnly({
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        left: left,
        top: top,
        right: right,
        bottom: bottom,
      ),
      child: this,
    );
  }

  // ── Margin Wrappers ────────────────────────────────────────────────────

  /// Adds symmetric margin to the widget.
  Widget marginSymmetric({double horizontal = 0.0, double vertical = 0.0}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      child: this,
    );
  }

  /// Adds uniform margin to all sides of the widget.
  Widget marginAll(double value) {
    return Container(margin: EdgeInsets.all(value), child: this);
  }

  /// Adds selective margin to the widget.
  Widget marginOnly({
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
  }) {
    return Container(
      margin: EdgeInsets.only(
        left: left,
        top: top,
        right: right,
        bottom: bottom,
      ),
      child: this,
    );
  }
}
