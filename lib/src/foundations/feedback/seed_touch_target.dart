import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Keeps an icon's layout size while centering a larger interactive child on it.
/// Ancestors must leave the target inside their own hit-test bounds.
class SeedTouchTarget extends SingleChildRenderObjectWidget {
  const SeedTouchTarget({
    super.key,
    required this.visualSize,
    required this.targetSize,
    required super.child,
  });

  final Size visualSize, targetSize;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderSeedTouchTarget(visualSize, targetSize);

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderShiftedBox renderObject,
  ) => (renderObject as _RenderSeedTouchTarget).updateSizes(
    visualSize,
    targetSize,
  );
}

class _RenderSeedTouchTarget extends RenderShiftedBox {
  _RenderSeedTouchTarget(this._visualSize, this._targetSize) : super(null);
  Size _visualSize, _targetSize;

  void updateSizes(Size visual, Size target) {
    if (_visualSize == visual && _targetSize == target) return;
    _visualSize = visual;
    _targetSize = target;
    markNeedsLayout();
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) =>
      constraints.constrain(_visualSize);

  @override
  double computeMinIntrinsicWidth(double height) => _visualSize.width;
  @override
  double computeMaxIntrinsicWidth(double height) => _visualSize.width;
  @override
  double computeMinIntrinsicHeight(double width) => _visualSize.height;
  @override
  double computeMaxIntrinsicHeight(double width) => _visualSize.height;

  @override
  void performLayout() {
    size = computeDryLayout(constraints);
    child?.layout(
      BoxConstraints.tight(
        Size(
          math.max(size.width, _targetSize.width),
          math.max(size.height, _targetSize.height),
        ),
      ),
      parentUsesSize: true,
    );
    if (child != null) {
      (child!.parentData! as BoxParentData).offset = Offset(
        (size.width - child!.size.width) / 2,
        (size.height - child!.size.height) / 2,
      );
    }
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) =>
      hitTestChildren(result, position: position);
}
