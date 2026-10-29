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
  final Set<int> _downPointers = {};
  bool _multiTouchBlocked = false;
  final Set<int> _preventedPointers = {};
  double _pointerY = 0;
  double _pointerDownY = 0;
  PointerDeviceKind _pointerDeviceKind = PointerDeviceKind.touch;
  double? _originY;
  double _offset = 0;
  double _scrollOvershoot = 0;
  bool _dragAccepted = false;
  bool _scrollAtTop = false;
  bool _rearmAfterDisable = false;
  bool _rearmAfterLoading = false;

  bool get _canPull => widget.enabled && !widget.preventPull;
  bool get _dragging =>
      _state == _PullState.pulling || _state == _PullState.ready;

  @override
  void didUpdateWidget(covariant SeedPullToRefresh oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_canPull && _state != _PullState.loading) {
      // React disableEvent aborts the visible pull without clearing
      // originRef. The held contact is released only by end/cancel, so it may
      // start another pull if re-enabled before the finger is lifted.
      if (_dragging) {
        _rearmAfterDisable = _pointer != null && _dragAccepted;
      }
      _originY = null;
      _offset = 0;
      _state = _PullState.idle;
    }
  }

  void _reset() {
    _pointer = null;
    _originY = null;
    _dragAccepted = false;
    _scrollAtTop = false;
    _rearmAfterDisable = false;
    _rearmAfterLoading = false;
    _offset = 0;
    _state = _PullState.idle;
  }

  void _down(PointerDownEvent event) {
    _downPointers.add(event.pointer);
    if (_downPointers.length > 1) {
      // A second physical finger invalidates this gesture until all contacts
      // have ended. It must not settle an already-running refresh.
      _multiTouchBlocked = true;
      if (_state == _PullState.loading) {
        _pointer = null;
        _originY = null;
        _dragAccepted = false;
        _rearmAfterLoading = false;
      } else {
        setState(_reset);
      }
      return;
    }
    if (_multiTouchBlocked) return;
    if (_preventedPointers.contains(event.pointer) ||
        event.buttons != kPrimaryButton) {
      return;
    }
    // React records the contact even while disabled. If enabled becomes true
    // before touchend, later moves of that same contact may start a pull.
    _pointer = event.pointer;
    _pointerY = event.position.dy;
    _pointerDownY = event.position.dy;
    _pointerDeviceKind = event.kind;
    // The translated content can lose its ScrollStart while the first
    // refresh's loading indicator is shown. Keep the last known scroll-top
    // state for a contact that begins during that loading interval.
    if (_state != _PullState.loading) _scrollAtTop = false;
  }

  void _move(PointerMoveEvent event) {
    if (event.pointer != _pointer) return;
    if (event.buttons != kPrimaryButton) {
      setState(_reset);
      return;
    }
    final previousY = _pointerY;
    _pointerY = event.position.dy;
    final canRearm = _rearmAfterLoading ? _scrollAtTop : _dragAccepted;
    if (_originY != null && _dragAccepted) {
      _updatePull();
    } else if (_canPull &&
        (_rearmAfterDisable || _rearmAfterLoading) &&
        canRearm &&
        _state == _PullState.idle &&
        _pointerY > previousY) {
      // React starts a fresh pull on the first positive move after either
      // disabled→enabled or a pending refresh settling mid-contact.
      setState(() {
        _rearmAfterDisable = false;
        // During loading Flutter's translated content may not receive a new
        // ScrollStart. A retained top-of-scroll owner can still resume on its
        // next move, as React's root touch handler does.
        if (_rearmAfterLoading && _scrollAtTop) _dragAccepted = true;
        _rearmAfterLoading = false;
        _originY = _pointerY;
        _offset = 0;
        _state = _PullState.pulling;
      });
    }
  }

  void _updatePull() {
    final origin = _originY;
    if (!_canPull || origin == null) return;
    final distance = (_pointerY - origin) * widget.displacementMultiplier;
    final ready = distance > widget.threshold;
    setState(() {
      // React keeps this contact in "pulling" and rebases y0 whenever the
      // displacement reaches zero or turns negative (usePullToRefresh.ts).
      // Clearing the origin here instead would require a fresh scroll
      // notification before the SAME finger could pull down again.
      if (distance <= 0) _originY = _pointerY;
      _offset = math.max(0, distance);
      _state = ready ? _PullState.ready : _PullState.pulling;
    });
    // React usePullToRefresh invokes onPtrReady for *every* delivered move
    // above the threshold, including moves while already in the ready state.
    if (ready) widget.onReady?.call();
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
    if (_pointer == null) {
      return false;
    }

    // A descendant scrollable must win the gesture arena first. This keeps
    // horizontal tabs, selectable text and local prevent-pull areas independent.
    if (notification is ScrollStartNotification &&
        notification.dragDetails != null) {
      _dragAccepted = true;
    }
    if (_dragAccepted) _scrollAtTop = metrics.extentBefore == 0;
    if (!_canPull) return false;
    if (_state == _PullState.loading) {
      // A fresh touch may begin during an unresolved refresh. Remember its
      // scroll arena ownership, but never pull or refresh until it settles.
      return false;
    }
    final details = switch (notification) {
      ScrollUpdateNotification(:final dragDetails) => dragDetails,
      OverscrollNotification(:final dragDetails) => dragDetails,
      _ => null,
    };
    if (_dragAccepted &&
        details != null &&
        _originY == null &&
        !_rearmAfterLoading &&
        metrics.extentBefore == 0 &&
        // On browsers React receives the first touchmove after the native
        // touch-slop interval. Flutter's scroll arena can issue an overscroll
        // on the *first* sub-slop move, making its PTR READY prematurely.
        // Match the native touch delivery boundary without delaying the
        // pointer/mouse path that React binds on non-touch platforms.
        (_pointerDeviceKind != PointerDeviceKind.touch ||
            details.globalPosition.dy - _pointerDownY > kTouchSlop) &&
        details.delta.dy > 0) {
      _originY = details.globalPosition.dy;
    }
    // ScrollEnd and ballistic updates are deliberately not release events.
    // In particular, bouncing scroll physics can emit them while still held.
    return false;
  }

  void _end(PointerEvent event, {bool cancelled = false}) {
    // A still-held pointer can be released after a parent switches tabs and
    // disposes this subtree. Ignore that late event; the old PTR no longer
    // owns a mounted state or a refresh callback.
    if (!mounted) return;
    _downPointers.remove(event.pointer);
    if (_downPointers.isEmpty) _multiTouchBlocked = false;
    _preventedPointers.remove(event.pointer);
    if (event.pointer != _pointer) return;
    if (_state == _PullState.loading) {
      // React clears the contact origin on end/cancel while an older refresh
      // stays loading. The outstanding Future must still control settlement.
      _pointer = null;
      _originY = null;
      _dragAccepted = false;
      _rearmAfterLoading = false;
      return;
    }
    final refresh = !cancelled && _canPull && _state == _PullState.ready;
    setState(() {
      _pointer = null;
      _originY = null;
      _dragAccepted = false;
      if (!refresh) _scrollAtTop = false;
      _rearmAfterDisable = false;
      _rearmAfterLoading = false;
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
      if (mounted) {
        setState(() {
          if (_pointer == null) {
            _reset();
          } else {
            // React startEvent retains a new origin even during loading;
            // after settle, the still-held contact may begin a new pull on
            // its next downward move, using that move as the new y0.
            _offset = 0;
            _originY = null;
            _state = _PullState.idle;
            _rearmAfterLoading = true;
          }
        });
      }
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
