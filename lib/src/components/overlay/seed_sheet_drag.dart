import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

import '../../foundations/motion/seed_motion.dart';

/// Applies the React Drawer release rules to a modal sheet: it follows the
/// pointer and closes past 25% of its height or above 0.4 px/ms. Material's
/// BottomSheet has a fixed 50% threshold, so the routes disable its drag.
class SeedSheetDragDismiss extends StatefulWidget {
  /// Wraps [child] with a vertical dismissal gesture.
  ///
  /// [onDismiss] runs when dragging exceeds 25% of sheet height or the
  /// gesture's vertical speed exceeds 0.4 logical pixels per millisecond.
  /// [onProgress] may update the backdrop's remaining-opacity fraction.
  const SeedSheetDragDismiss({
    super.key,
    required this.onDismiss,
    required this.child,
    this.onProgress,
  });

  /// Called after a completed downward drag crosses the dismiss threshold.
  final VoidCallback onDismiss;

  /// Reports the remaining share of the sheet, for fading its backdrop.
  final ValueChanged<double>? onProgress;

  /// Rendered sheet content translated during the drag.
  final Widget child;

  @override
  State<SeedSheetDragDismiss> createState() => _SeedSheetDragDismissState();
}

class _SeedSheetDragDismissState extends State<SeedSheetDragDismiss>
    with SingleTickerProviderStateMixin {
  static const double _closeThreshold = .25;
  static const double _velocityThreshold = .4;

  late final AnimationController _offset = AnimationController.unbounded(
    vsync: this,
  )..addListener(_reportProgress);
  Duration? _start, _last;

  // Animation ticks can run while the sheet is dirty for layout. Keep the
  // latest completed measurement instead of reading context.size in a tick.
  double _height = 0;

  void _reportProgress() {
    final height = _height;
    if (height <= 0) return;
    widget.onProgress?.call((1 - _offset.value / height).clamp(0.0, 1.0));
  }

  void _handleStart(DragStartDetails details) {
    _offset.stop();
    _start = details.sourceTimeStamp;
    _last = details.sourceTimeStamp;
  }

  void _handleUpdate(DragUpdateDetails details) {
    _last = details.sourceTimeStamp ?? _last;
    _offset.value = math.max(0, _offset.value + details.primaryDelta!);
  }

  void _handleEnd(DragEndDetails details) {
    final height = _height;
    final elapsed = _start == null || _last == null
        ? Duration.zero
        : _last! - _start!;
    // React divides the whole gesture's distance by its duration.
    final velocity = elapsed > Duration.zero
        ? _offset.value / (elapsed.inMicroseconds / 1000)
        : (details.primaryVelocity ?? 0) / 1000;
    if (height > 0 &&
        _offset.value > 0 &&
        (_offset.value / height >= _closeThreshold ||
            velocity > _velocityThreshold)) {
      widget.onDismiss();
      return;
    }
    if (MediaQuery.disableAnimationsOf(context)) {
      _offset.value = 0;
    } else {
      _offset.animateTo(
        0,
        duration: SeedDuration.d4,
        curve: SeedCurves.enterExpressive,
      );
    }
  }

  @override
  void dispose() {
    _offset.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    excludeFromSemantics: true,
    onVerticalDragStart: _handleStart,
    onVerticalDragUpdate: _handleUpdate,
    onVerticalDragEnd: _handleEnd,
    child: _SeedSheetMeasurer(
      onHeight: (height) => _height = height,
      child: AnimatedBuilder(
        animation: _offset,
        builder: (context, child) =>
            Transform.translate(offset: Offset(0, _offset.value), child: child),
        child: widget.child,
      ),
    ),
  );
}

class _SeedSheetMeasurer extends SingleChildRenderObjectWidget {
  const _SeedSheetMeasurer({required this.onHeight, required super.child});

  final ValueChanged<double> onHeight;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderSeedSheetMeasurer(onHeight);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderSeedSheetMeasurer renderObject,
  ) {
    renderObject.onHeight = onHeight;
  }
}

class _RenderSeedSheetMeasurer extends RenderProxyBox {
  _RenderSeedSheetMeasurer(this.onHeight);

  ValueChanged<double> onHeight;

  @override
  void performLayout() {
    super.performLayout();
    // This callback only caches the measurement; it must not rebuild widgets.
    onHeight(size.height);
  }
}
