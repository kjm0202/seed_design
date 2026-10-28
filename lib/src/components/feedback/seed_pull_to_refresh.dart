import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';

import 'seed_progress_circle.dart';

/// Pulls content down with a determinate indicator, then refreshes on release.
///
/// Like SEED React, the pull becomes ready above [threshold], after applying
/// [displacementMultiplier] to the pointer movement. Only releasing a ready
/// pull starts [onRefresh]; cancelling or retreating below the threshold does not.
class SeedPullToRefresh extends StatefulWidget {
  const SeedPullToRefresh({
    super.key,
    required this.child,
    required this.onRefresh,
    this.onReady,
    this.enabled = true,
    this.preventPull = false,
    this.threshold = 88,
    this.displacementMultiplier = 0.75,
    this.displacement = 40,
    this.edgeOffset = 0,
    this.notificationPredicate,
  }) : assert(threshold > 0),
       assert(displacementMultiplier > 0);

  final Widget child;
  final Future<void> Function() onRefresh;
  final VoidCallback? onReady;
  final bool enabled, preventPull;

  /// Distance in logical pixels required to become ready. React defaults to 88.
  final double threshold;

  /// Multiplier applied to pointer movement. React defaults to 0.75.
  final double displacementMultiplier;

  /// Flutter layout options: resting indicator center and top inset.
  /// These do not change the gesture's [threshold].
  final double displacement, edgeOffset;
  final ScrollNotificationPredicate? notificationPredicate;

  @override
  State<SeedPullToRefresh> createState() => _SeedPullToRefreshState();
}

enum _PullState { idle, pulling, ready, loading }

class _SeedPullToRefreshState extends State<SeedPullToRefresh> {
  _PullState _state = _PullState.idle;
  int? _pointer;
  final Set<int> _preventedPointers = {};
  double _pointerY = 0;
  double? _originY;
  double _offset = 0;
  double _scrollOvershoot = 0;
  bool _dragAccepted = false;

  bool get _canPull => widget.enabled && !widget.preventPull;
  bool get _dragging =>
      _state == _PullState.pulling || _state == _PullState.ready;

  @override
  void didUpdateWidget(covariant SeedPullToRefresh oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_canPull && _state != _PullState.loading) _reset();
  }

  void _reset() {
    _pointer = null;
    _originY = null;
    _dragAccepted = false;
    _offset = 0;
    _state = _PullState.idle;
  }

  void _down(PointerDownEvent event) {
    if (_pointer != null) {
      // A multi-touch interruption never commits a refresh.
      setState(_reset);
      return;
    }
    if (_preventedPointers.contains(event.pointer) ||
        !_canPull ||
        _state == _PullState.loading ||
        event.buttons != kPrimaryButton) {
      return;
    }
    _pointer = event.pointer;
    _pointerY = event.position.dy;
  }

  void _move(PointerMoveEvent event) {
    if (event.pointer != _pointer) return;
    if (event.buttons != kPrimaryButton) {
      setState(_reset);
      return;
    }
    _pointerY = event.position.dy;
    if (_originY != null && _dragAccepted) _updatePull();
  }

  void _updatePull() {
    final origin = _originY;
    if (!_canPull || origin == null) return;
    final distance = (_pointerY - origin) * widget.displacementMultiplier;
    final ready = distance > widget.threshold;
    final becameReady = ready && _state != _PullState.ready;
    setState(() {
      // Follow a retreating pointer rather than retaining a negative pull.
      if (distance < 0) _originY = null;
      _offset = math.max(0, distance);
      _state = distance < 0
          ? _PullState.idle
          : ready
          ? _PullState.ready
          : _PullState.pulling;
    });
    if (becameReady) widget.onReady?.call();
  }

  bool _scrollNotification(ScrollNotification notification) {
    if (!(widget.notificationPredicate?.call(notification) ??
            notification.depth == 0) ||
        notification.metrics.axisDirection != AxisDirection.down) {
      return false;
    }
    final metrics = notification.metrics;
    final overshoot = math.min(0.0, metrics.pixels - metrics.minScrollExtent);
    if (_scrollOvershoot != overshoot) {
      setState(() => _scrollOvershoot = overshoot);
    }
    if (!_canPull || _pointer == null || _state == _PullState.loading) {
      return false;
    }

    // A descendant scrollable must win the gesture arena first. This keeps
    // horizontal tabs, selectable text and local prevent-pull areas independent.
    if (notification is ScrollStartNotification &&
        notification.dragDetails != null) {
      _dragAccepted = true;
    }
    final details = switch (notification) {
      ScrollUpdateNotification(:final dragDetails) => dragDetails,
      OverscrollNotification(:final dragDetails) => dragDetails,
      _ => null,
    };
    if (_dragAccepted &&
        details != null &&
        _originY == null &&
        metrics.extentBefore == 0 &&
        details.delta.dy > 0) {
      _originY = details.globalPosition.dy;
    }
    // ScrollEnd and ballistic updates are deliberately not release events.
    // In particular, bouncing scroll physics can emit them while still held.
    return false;
  }

  void _end(PointerEvent event, {bool cancelled = false}) {
    _preventedPointers.remove(event.pointer);
    if (event.pointer != _pointer) return;
    final refresh = !cancelled && _canPull && _state == _PullState.ready;
    setState(() {
      _pointer = null;
      _originY = null;
      _dragAccepted = false;
      _state = refresh ? _PullState.loading : _PullState.idle;
      _offset = refresh ? widget.threshold : 0;
    });
    if (refresh) _refresh();
  }

  Future<void> _refresh() async {
    try {
      await widget.onRefresh();
    } catch (_) {
      // React also settles rejected refreshes back to idle.
    } finally {
      if (mounted) setState(_reset);
    }
  }

  @override
  Widget build(BuildContext context) {
    final behavior = ScrollConfiguration.of(context);
    final ratio = (_offset / widget.threshold).clamp(0.0, 1.0);
    final duration = _dragging
        ? Duration.zero
        : const Duration(milliseconds: 300);
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _down,
      onPointerMove: _move,
      onPointerUp: _end,
      onPointerCancel: (event) => _end(event, cancelled: true),
      child: ClipRect(
        child: Stack(
          children: [
            AnimatedContainer(
              duration: duration,
              curve: Curves.easeOut,
              // Compensate an explicitly bouncing child: content must move only
              // by our pull displacement, not by both it and native overscroll.
              transform: Matrix4.translationValues(
                0,
                _offset + (_offset > 0 ? _scrollOvershoot : 0),
                0,
              ),
              child: ScrollConfiguration(
                behavior: behavior.copyWith(
                  overscroll: false,
                  dragDevices: {
                    ...behavior.dragDevices,
                    PointerDeviceKind.mouse,
                  },
                  physics: _PullScrollPhysics(
                    hold: () => _offset > 0 && _dragging,
                    parent: const AlwaysScrollableScrollPhysics(
                      parent: ClampingScrollPhysics(),
                    ),
                  ),
                ),
                child: NotificationListener<ScrollNotification>(
                  onNotification: _scrollNotification,
                  child: widget.child,
                ),
              ),
            ),
            AnimatedPositioned(
              duration: duration,
              curve: Curves.easeOut,
              top:
                  widget.edgeOffset +
                  widget.displacement -
                  12 +
                  math.min(_offset - widget.threshold, 0),
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Opacity(
                  opacity: ratio,
                  child: Center(
                    child: SeedProgressCircle(
                      size: 24,
                      value: _state == _PullState.loading ? null : ratio,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Keep native scrolling from consuming the retreat of a pull. Once the pull
/// reaches zero, the same drag can scroll the content normally again.
class _PullScrollPhysics extends ScrollPhysics {
  const _PullScrollPhysics({required this.hold, super.parent});

  final bool Function() hold;

  @override
  _PullScrollPhysics applyTo(ScrollPhysics? ancestor) =>
      _PullScrollPhysics(hold: hold, parent: buildParent(ancestor));

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) =>
      hold() ? 0 : super.applyPhysicsToUserOffset(position, offset);
}

/// Excludes gestures starting in this subtree from pull-to-refresh while leaving
/// scrolling and text selection available, like React's prevent-pull marker.
class SeedPullToRefreshPreventPull extends StatelessWidget {
  const SeedPullToRefreshPreventPull({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Listener(
    onPointerDown: (event) => context
        .findAncestorStateOfType<_SeedPullToRefreshState>()
        ?._preventedPointers
        .add(event.pointer),
    child: child,
  );
}
