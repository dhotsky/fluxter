import 'package:flutter/material.dart';

/// A premium, customizable interactable widget that behaves like a [Container]
/// but features material ripple splash feedback ([InkWell]).
///
/// Ideal for list items, cards, custom buttons, etc.
class AppInkWell extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDoubleTap;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double? width;
  final double? height;
  final Color? splashColor;
  final Color? highlightColor;
  final Clip clipBehavior;

  const AppInkWell({
    super.key,
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    this.borderRadius,
    this.backgroundColor,
    this.border,
    this.boxShadow,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.width,
    this.height,
    this.splashColor,
    this.highlightColor,
    this.clipBehavior = Clip.none,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    Widget current = Ink(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.transparent,
        borderRadius: borderRadius,
        border: border,
        boxShadow: boxShadow,
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        onDoubleTap: onDoubleTap,
        borderRadius: borderRadius,
        splashColor: splashColor,
        highlightColor: highlightColor,
        child: Padding(padding: padding, child: child),
      ),
    );

    if (clipBehavior != Clip.none && borderRadius != null) {
      current = ClipRRect(
        borderRadius: borderRadius!,
        clipBehavior: clipBehavior,
        child: current,
      );
    }

    if (margin != EdgeInsets.zero) {
      current = Padding(padding: margin, child: current);
    }

    return Material(
      color: Colors.transparent,
      type: MaterialType.transparency,
      child: current,
    );
  }
}
