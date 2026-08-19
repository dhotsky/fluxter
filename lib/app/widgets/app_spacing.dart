import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A widget that automatically provides spacing (gap) between widgets in a flex container
/// (Row, Column, Flex, etc.). It determines whether to apply width or height based on
/// its parent's layout direction.
class Spacing extends LeafRenderObjectWidget {
  final double size;

  const Spacing(this.size, {super.key});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSpacing(size);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderSpacing renderObject,
  ) {
    renderObject.extent = size;
  }
}

class RenderSpacing extends RenderBox {
  RenderSpacing(double extent) : _extent = extent;

  double _extent;

  double get extent => _extent;

  set extent(double value) {
    if (_extent != value) {
      _extent = value;
      markNeedsLayout();
    }
  }

  bool _isParentHorizontal() {
    final RenderObject? parentNode = parent;
    if (parentNode is RenderFlex) {
      return parentNode.direction == Axis.horizontal;
    }
    return false;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final RenderObject? parentNode = parent;

    if (parentNode is RenderFlex) {
      if (parentNode.direction == Axis.horizontal) {
        return constraints.constrain(Size(extent, 0));
      } else {
        return constraints.constrain(Size(0, extent));
      }
    } else {
      // Fallback if not inside a Flex container
      return constraints.constrain(Size(extent, extent));
    }
  }

  @override
  void performLayout() {
    size = computeDryLayout(constraints);
  }

  @override
  double computeMinIntrinsicWidth(double height) =>
      _isParentHorizontal() ? extent : 0.0;

  @override
  double computeMaxIntrinsicWidth(double height) =>
      _isParentHorizontal() ? extent : 0.0;

  @override
  double computeMinIntrinsicHeight(double width) =>
      _isParentHorizontal() ? 0.0 : extent;

  @override
  double computeMaxIntrinsicHeight(double width) =>
      _isParentHorizontal() ? 0.0 : extent;
}
