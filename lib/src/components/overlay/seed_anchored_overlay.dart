import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../../foundations/motion/seed_motion.dart';
import '../button/seed_button.dart';

enum SeedOverlaySide { top, bottom, left, right }

enum SeedOverlayAlign { start, center, end }

enum SeedOverlayDismissReason {
  trigger,
  closeButton,
  action,
  itemClick,
  escapeKey,
  outside,
  focusOut,
  parentClosed,
  programmatic,
  drag,
}

/// A user request to change overlay visibility, including its cause.
typedef SeedOverlayOpenChanged = void Function(
  bool open,
  SeedOverlayDismissReason reason,
);

class SeedOverlayController extends ChangeNotifier {
  SeedOverlayController({this._open = false});
  bool _open;
  SeedOverlayDismissReason reason = SeedOverlayDismissReason.programmatic;
  bool get isOpen => _open;
  void open() {
    if (!_open) {
      _open = true;
      reason = SeedOverlayDismissReason.programmatic;
      notifyListeners();
    }
  }

  void close([
    SeedOverlayDismissReason reason = SeedOverlayDismissReason.programmatic,
  ]) {
    if (_open) {
      _open = false;
      this.reason = reason;
      notifyListeners();
    }
  }

  void toggle() => _open ? close(SeedOverlayDismissReason.trigger) : open();
}

class SeedOverlayScope extends InheritedWidget {
  const SeedOverlayScope({
    super.key,
    required this.close,
    required this.side,
    this.tapGroup,
    this.isOpen = true,
    this.anchorPoint,
    required super.child,
  });
  final void Function(SeedOverlayDismissReason) close;
  final SeedOverlaySide side;
  final Object? tapGroup;
  final bool isOpen;
  final Offset? anchorPoint;
  static SeedOverlayScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SeedOverlayScope>();
  @override
  bool updateShouldNotify(SeedOverlayScope oldWidget) =>
      side != oldWidget.side ||
      isOpen != oldWidget.isOpen ||
      tapGroup != oldWidget.tapGroup ||
      anchorPoint != oldWidget.anchorPoint;
}

/// Anchored non-modal overlay with native focus, outside, Escape, flip and shift behavior.
class SeedAnchoredOverlay extends StatefulWidget {
  const SeedAnchoredOverlay({
    super.key,
    required this.triggerBuilder,
    required this.overlayBuilder,
    this.anchor,
    this.controller,
    this.open,
    this.defaultOpen = false,
    this.lazyMount = true,
    this.unmountOnExit = true,
    SeedOverlayOpenChanged? onOpenChange,
    @Deprecated('Use onOpenChange instead.')
    SeedOverlayOpenChanged? onOpenChanged,
    this.canClose,
    this.side = SeedOverlaySide.bottom,
    this.align = SeedOverlayAlign.center,
    this.gap = 8,
    this.overflowPadding = 16,
    this.arrowPadding = 12,
    this.flip = true,
    this.shift = true,
    this.maxWidth,
    this.maxHeight,
    this.autoFocus = true,
    this.contentFocusable = true,
    this.restoreFocus = true,
    this.closeOnInteractOutside = true,
    this.closeOnFocusOut = false,
    this.skipAnimation = false,
    this.enterScale = 0.95,
    this.exitScale,
    this.enterCurve = Curves.linear,
    this.exitCurve = Curves.linear,
    this.scaleFromAnchor = false,
    this.enterDuration = SeedDuration.d3,
    this.exitDuration = SeedDuration.d2,
  }) : onOpenChanged = onOpenChange ?? onOpenChanged,
       assert(onOpenChange == null || onOpenChanged == null);
  final Widget Function(BuildContext, bool, VoidCallback) triggerBuilder;
  final WidgetBuilder overlayBuilder;
  final Widget? anchor;
  final SeedOverlayController? controller;
  final bool? open;
  final bool defaultOpen;
  final bool lazyMount, unmountOnExit;
  @Deprecated('Use onOpenChange instead.')
  final SeedOverlayOpenChanged? onOpenChanged;
  SeedOverlayOpenChanged? get onOpenChange => onOpenChanged;
  final bool Function(SeedOverlayDismissReason)? canClose;
  final SeedOverlaySide side;
  final SeedOverlayAlign align;
  final double gap, overflowPadding, arrowPadding;
  final bool flip, shift;
  final double? maxWidth, maxHeight;

  /// Whether the overlay content can receive keyboard or accessibility focus.
  /// Disable for descriptive content such as a tooltip.
  final bool contentFocusable;
  final bool autoFocus,
      restoreFocus,
      closeOnInteractOutside,
      closeOnFocusOut,
      skipAnimation;
  final double enterScale;
  final double? exitScale;
  final Curve enterCurve, exitCurve;
  final bool scaleFromAnchor;
  final Duration enterDuration, exitDuration;
  @override
  State<SeedAnchoredOverlay> createState() => _SeedAnchoredOverlayState();
}

class _SeedAnchoredOverlayState extends State<SeedAnchoredOverlay>
    with SingleTickerProviderStateMixin {
  final OverlayPortalController _portal = OverlayPortalController();
  final GlobalKey _anchorKey = GlobalKey();
  final Object _ownTapGroup = Object();
  Object? _parentTapGroup;
  // Each overlay needs an independent dismissal boundary. Reusing the
  // ancestor's group makes a tap in the exposed parent count as INSIDE the
  // nested child, so the child never receives onTapOutside.
  Object get _tapGroup => _ownTapGroup;
  final FocusScopeNode _overlayFocus = FocusScopeNode();
  // React PopoverContent itself receives initial focus before its actions.
  final FocusNode _contentFocus = FocusNode(debugLabel: 'Seed overlay content');
  final FocusNode _triggerFocus = FocusNode();
  final List<ScrollPosition> _scrollPositions = [];
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: widget.enterDuration,
    reverseDuration: widget.exitDuration,
  );
  late final CurvedAnimation _curved = CurvedAnimation(
    parent: _animation,
    curve: widget.enterCurve,
    reverseCurve: widget.exitCurve,
  );
  Alignment _scaleAlignment = Alignment.center;
  Offset? _anchorPoint;
  bool _open = false;
  FocusNode? _returnFocus;
  SeedOverlayDismissReason? _requestedDismissReason;
  late SeedOverlaySide _resolvedSide = widget.side;
  bool get _desired => widget.open ?? widget.controller?.isOpen ?? _open;
  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_controllerChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted &&
          (widget.open ?? widget.controller?.isOpen ?? widget.defaultOpen)) {
        _show();
      } else if (mounted && !widget.lazyMount) {
        _portal.show();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final parent = SeedOverlayScope.maybeOf(context);
    _parentTapGroup = parent?.tapGroup;
    if (parent != null && !parent.isOpen && _open) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _request(false, SeedOverlayDismissReason.parentClosed);
      });
    }
    for (final position in _scrollPositions) {
      position.removeListener(_refresh);
    }
    _scrollPositions.clear();
    context.visitAncestorElements((element) {
      if (element is StatefulElement && element.state is ScrollableState) {
        final position = (element.state as ScrollableState).position;
        _scrollPositions.add(position);
        position.addListener(_refresh);
      }
      return true;
    });
  }

  void _refresh() {
    if (mounted && _open) setState(() {});
  }

  // A non-modal popover participates in the page's tab order directly after
  // its trigger. OverlayPortal descendants can be excluded from Flutter's
  // default traversal, so move to a real page focus target at the boundary.
  bool _focusAtTriggerBoundary({required bool backwards}) {
    final scope = _triggerFocus.nearestScope;
    if (scope == null) return false;
    final outside = scope.descendants
        .where(
          (node) =>
              node.canRequestFocus &&
              !node.skipTraversal &&
              !identical(node, _contentFocus) &&
              !node.ancestors.contains(_contentFocus),
        )
        .toList();
    final trigger = _triggerFocus.descendants.where(
      (node) => node.canRequestFocus && !node.skipTraversal,
    );
    if (trigger.isEmpty) return false;
    final index = outside.indexOf(trigger.first);
    if (index == -1) return false;
    final destination = backwards ? index : index + 1;
    if (destination >= outside.length) return false;
    outside[destination].requestFocus();
    return true;
  }

  @override
  void didUpdateWidget(SeedAnchoredOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    _curved.curve = widget.enterCurve;
    _curved.reverseCurve = widget.exitCurve;
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_controllerChanged);
      widget.controller?.addListener(_controllerChanged);
    }
    if (_desired != _open) {
      final reason =
          _requestedDismissReason ??
          widget.controller?.reason ??
          SeedOverlayDismissReason.programmatic;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _desired ? _show() : _hide(reason);
        }
      });
    }
  }

  void _controllerChanged() {
    if (!mounted || widget.open != null) return;
    widget.controller!.isOpen ? _show() : _hide(widget.controller!.reason);
  }

  void _request(bool open, SeedOverlayDismissReason reason) {
    if (!open && widget.canClose?.call(reason) == false) return;
    if (!open && widget.open != null) {
      _requestedDismissReason = reason;
      // A controlled parent commits its response during the next build. Keep
      // that request's reason through the build, but discard rejected requests.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _requestedDismissReason = null;
      });
    }
    widget.onOpenChanged?.call(open, reason);
    if (widget.open != null) return;
    if (widget.controller != null) {
      open ? widget.controller!.open() : widget.controller!.close(reason);
    } else {
      open ? _show() : _hide(reason);
    }
  }

  void _show() {
    if (_open) return;
    _returnFocus = FocusManager.instance.primaryFocus;
    setState(() => _open = true);
    _portal.show();
    _animation.duration =
        widget.skipAnimation || MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : widget.enterDuration;
    _animation.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_open) return;
      // SeedPressable requests focus before invoking its callback. Flutter
      // applies that request asynchronously, so the opening callback may still
      // see the outside control that was focused before the trigger was tapped.
      final focused = FocusManager.instance.primaryFocus;
      if (focused != null && focused.ancestors.contains(_triggerFocus)) {
        _returnFocus = focused;
      }
      if (widget.autoFocus && widget.contentFocusable) {
        _contentFocus.requestFocus();
      }
    });
  }

  Future<void> _hide(SeedOverlayDismissReason reason) async {
    if (!_open) return;
    setState(() => _open = false);
    _animation.reverseDuration =
        widget.skipAnimation || MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : widget.exitDuration;
    try {
      await _animation.reverse().orCancel;
    } on TickerCanceled {
      return;
    }
    if (!mounted || _open) return;
    if (widget.unmountOnExit) {
      _portal.hide();
    } else {
      setState(() {});
    }
    if (widget.restoreFocus &&
        reason != SeedOverlayDismissReason.outside &&
        reason != SeedOverlayDismissReason.focusOut &&
        reason != SeedOverlayDismissReason.parentClosed) {
      var target = _returnFocus;
      // Touch activation need not focus a Flutter button before it opens the
      // overlay. Returning to a parent focus container loses the trigger's tab
      // stop; React Popover returns to its trigger in this path as well.
      // Preserve a previously focused control, including explicit external
      // focus, and use the trigger only when no control had focus on opening.
      if (target == null ||
          target is FocusScopeNode ||
          _triggerFocus.ancestors.contains(target)) {
        for (final node in _triggerFocus.descendants) {
          if (node.canRequestFocus && !node.skipTraversal) {
            target = node;
            break;
          }
        }
      }
      if (target?.context != null) target!.requestFocus();
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_controllerChanged);
    for (final position in _scrollPositions) {
      position.removeListener(_refresh);
    }
    _curved.dispose();
    _animation.dispose();
    _overlayFocus.dispose();
    _contentFocus.dispose();
    _triggerFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => OverlayPortal(
    controller: _portal,
    overlayChildBuilder: (overlayContext) {
      final anchor =
          _anchorKey.currentContext?.findRenderObject() as RenderBox?;
      final overlay =
          Overlay.of(overlayContext).context.findRenderObject() as RenderBox?;
      if (anchor == null || overlay == null || !anchor.attached) {
        return const SizedBox.shrink();
      }
      final rect =
          overlay.globalToLocal(anchor.localToGlobal(Offset.zero)) &
          anchor.size;
      final media = MediaQuery.of(overlayContext);
      return Positioned.fill(
        child: Offstage(
          offstage: !_open && !_animation.isAnimating,
          child: TickerMode(
            enabled: _open || _animation.isAnimating,
            child: CustomSingleChildLayout(
              delegate: SeedOverlayPositionDelegate(
                anchor: rect,
                side: widget.side,
                align: widget.align,
                gap: widget.gap,
                flip: widget.flip,
                shift: widget.shift,
                textDirection: Directionality.of(context),
                maxWidth: widget.maxWidth,
                maxHeight: widget.maxHeight,
                insets: EdgeInsets.fromLTRB(
                  math.max(media.padding.left, media.viewInsets.left) +
                      widget.overflowPadding,
                  math.max(media.padding.top, media.viewInsets.top) +
                      widget.overflowPadding,
                  math.max(media.padding.right, media.viewInsets.right) +
                      widget.overflowPadding,
                  math.max(media.padding.bottom, media.viewInsets.bottom) +
                      widget.overflowPadding,
                ),
                onPosition: (offset, size) {
                  final point = Offset(
                    (rect.center.dx - offset.dx - 6).clamp(
                      widget.arrowPadding,
                      math.max(
                        widget.arrowPadding,
                        size.width - widget.arrowPadding - 12,
                      ),
                    ),
                    (rect.center.dy - offset.dy - 6).clamp(
                      widget.arrowPadding,
                      math.max(
                        widget.arrowPadding,
                        size.height - widget.arrowPadding - 12,
                      ),
                    ),
                  );
                  final x = size.width > 0
                      ? ((point.dx + 6) / size.width * 2 - 1).clamp(-1.0, 1.0)
                      : 0.0;
                  final y = size.height > 0
                      ? ((point.dy + 6) / size.height * 2 - 1).clamp(-1.0, 1.0)
                      : 0.0;
                  final origin = switch (_resolvedSide) {
                    SeedOverlaySide.top => Alignment(x, 1),
                    SeedOverlaySide.bottom => Alignment(x, -1),
                    SeedOverlaySide.left => Alignment(1, y),
                    SeedOverlaySide.right => Alignment(-1, y),
                  };
                  if (_anchorPoint != point || _scaleAlignment != origin) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted &&
                          (_anchorPoint != point ||
                              _scaleAlignment != origin)) {
                        setState(() {
                          _anchorPoint = point;
                          _scaleAlignment = origin;
                        });
                      }
                    });
                  }
                },
                onResolved: (side) {
                  if (side != _resolvedSide) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && _resolvedSide != side) {
                        setState(() => _resolvedSide = side);
                      }
                    });
                  }
                },
              ),
              child: TapRegion(
                enabled: _open,
                groupId: _tapGroup,
                onTapOutside: widget.closeOnInteractOutside
                    ? (_) => _request(false, SeedOverlayDismissReason.outside)
                    : null,
                child: TapRegion(
                  enabled: _open && _parentTapGroup != null,
                  // Also register the nested portal with its parent's group:
                  // clicking the child must not dismiss the parent, while
                  // clicking the parent must dismiss only the child.
                  groupId: _parentTapGroup,
                  child: CallbackShortcuts(
                    // Escape also reaches the scope itself when it is focused.
                    bindings: {
                      const SingleActivator(LogicalKeyboardKey.escape): () =>
                          _request(false, SeedOverlayDismissReason.escapeKey),
                    },
                    child: FocusScope(
                      canRequestFocus: _open && widget.contentFocusable,
                      descendantsAreFocusable: _open && widget.contentFocusable,
                      descendantsAreTraversable:
                          _open && widget.contentFocusable,
                      node: _overlayFocus,
                      onFocusChange: (focused) {
                        if (!focused && widget.closeOnFocusOut && _open) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted &&
                                _open &&
                                !_overlayFocus.hasFocus &&
                                !_triggerFocus.hasFocus) {
                              _request(
                                false,
                                SeedOverlayDismissReason.focusOut,
                              );
                            }
                          });
                        }
                      },
                      child: Focus(
                        focusNode: _contentFocus,
                        canRequestFocus: _open && widget.contentFocusable,
                        onKeyEvent: (node, event) {
                          // The content is the initial tab stop. Flutter may
                          // mark controls inside an OverlayPortal as skipped
                          // for traversal, even though they remain focusable.
                          // Move among those real controls explicitly.
                          if (event is KeyDownEvent &&
                              event.logicalKey == LogicalKeyboardKey.tab) {
                            final controls = _contentFocus.descendants
                                .where((focus) => focus.canRequestFocus)
                                .toList();
                            final current = FocusManager.instance.primaryFocus;
                            final index = current == node
                                ? -1
                                : controls.indexOf(current!);
                            if (current == node || index >= 0) {
                              final backwards =
                                  HardwareKeyboard.instance.isShiftPressed;
                              // The content is before its actions in the React
                              // ["floating", "content"] tab order. Reverse Tab
                              // at that initial stop must leave to the trigger,
                              // never wrap around to the final child action.
                              final next = backwards ? index - 1 : index + 1;
                              if (next >= 0 && next < controls.length) {
                                controls[next].requestFocus();
                                return KeyEventResult.handled;
                              }
                              if (backwards && current != node && index == 0) {
                                _contentFocus.requestFocus();
                                return KeyEventResult.handled;
                              }
                              if (_focusAtTriggerBoundary(
                                backwards: backwards,
                              )) {
                                return KeyEventResult.handled;
                              }
                            }
                          }
                          return KeyEventResult.ignored;
                        },
                        child: FadeTransition(
                          opacity: _curved,
                          child: AnimatedBuilder(
                            animation: _animation,
                            builder: (context, child) => Transform.scale(
                              alignment: widget.scaleFromAnchor
                                  ? _scaleAlignment
                                  : Alignment.center,
                              scale: Tween<double>(
                                begin:
                                    _animation.status == AnimationStatus.reverse
                                    ? widget.exitScale ?? widget.enterScale
                                    : widget.enterScale,
                                end: 1,
                              ).evaluate(_curved),
                              child: child,
                            ),
                            child: Material(
                              type: MaterialType.transparency,
                              child: SeedOverlayScope(
                                side: _resolvedSide,
                                isOpen: _open,
                                anchorPoint: _anchorPoint,
                                tapGroup: _tapGroup,
                                close: (reason) => _request(false, reason),
                                child: Builder(builder: widget.overlayBuilder),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
    child: CallbackShortcuts(
      // Tooltip / HelpBubble autoFocus=false retains focus at its trigger.
      bindings: _open
          ? {
              const SingleActivator(LogicalKeyboardKey.escape): () =>
                  _request(false, SeedOverlayDismissReason.escapeKey),
            }
          : const {},
      child: TapRegion(
        groupId: _tapGroup,
        child: Focus(
          focusNode: _triggerFocus,
          canRequestFocus: false,
          onKeyEvent: (node, event) {
            // An open React popover stays immediately after its trigger in the
            // keyboard tab order. Flutter Web can otherwise advance from the
            // trigger straight to the following page button after a reverse
            // Tab exits the portal, leaving the still-open popup behind.
            if (!_open ||
                !widget.autoFocus ||
                !widget.contentFocusable ||
                event is! KeyDownEvent ||
                event.logicalKey != LogicalKeyboardKey.tab ||
                HardwareKeyboard.instance.isShiftPressed) {
              return KeyEventResult.ignored;
            }
            final focused = FocusManager.instance.primaryFocus;
            if (focused == null || !focused.ancestors.contains(node)) {
              return KeyEventResult.ignored;
            }
            _contentFocus.requestFocus();
            return KeyEventResult.handled;
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.anchor != null)
                KeyedSubtree(key: _anchorKey, child: widget.anchor!),
              KeyedSubtree(
                key: widget.anchor == null ? _anchorKey : null,
                child: widget.triggerBuilder(
                  context,
                  _open,
                  () => _request(!_open, SeedOverlayDismissReason.trigger),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class SeedOverlayPositionDelegate extends SingleChildLayoutDelegate {
  SeedOverlayPositionDelegate({
    required this.anchor,
    required this.insets,
    this.side = SeedOverlaySide.bottom,
    this.align = SeedOverlayAlign.center,
    this.gap = 8,
    this.flip = true,
    this.shift = true,
    this.textDirection = TextDirection.ltr,
    this.maxWidth,
    this.maxHeight,
    this.onResolved,
    this.onPosition,
  });
  final Rect anchor;
  final EdgeInsets insets;
  final SeedOverlaySide side;
  final SeedOverlayAlign align;
  final double gap;
  final bool flip, shift;
  final TextDirection textDirection;
  final double? maxWidth, maxHeight;
  final ValueChanged<SeedOverlaySide>? onResolved;
  final void Function(Offset, Size)? onPosition;
  Rect bounds(Size size) {
    final left = insets.left.clamp(0.0, size.width);
    final top = insets.top.clamp(0.0, size.height);
    return Rect.fromLTRB(
      left,
      top,
      (size.width - insets.right).clamp(left, size.width),
      (size.height - insets.bottom).clamp(top, size.height),
    );
  }

  SeedOverlaySide opposite(SeedOverlaySide side) => switch (side) {
    SeedOverlaySide.top => SeedOverlaySide.bottom,
    SeedOverlaySide.bottom => SeedOverlaySide.top,
    SeedOverlaySide.left => SeedOverlaySide.right,
    SeedOverlaySide.right => SeedOverlaySide.left,
  };
  double space(SeedOverlaySide side, Rect b) => math.max(0, switch (side) {
    SeedOverlaySide.top => anchor.top - b.top - gap,
    SeedOverlaySide.bottom => b.bottom - anchor.bottom - gap,
    SeedOverlaySide.left => anchor.left - b.left - gap,
    SeedOverlaySide.right => b.right - anchor.right - gap,
  });
  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final b = bounds(constraints.biggest);
    final available = flip
        ? math.max(space(side, b), space(opposite(side), b))
        : space(side, b);
    final vertical =
        side == SeedOverlaySide.top || side == SeedOverlaySide.bottom;
    return BoxConstraints.loose(
      Size(
        math.min(maxWidth ?? double.infinity, vertical ? b.width : available),
        math.min(maxHeight ?? double.infinity, vertical ? available : b.height),
      ),
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final b = bounds(size);
    final vertical =
        side == SeedOverlaySide.top || side == SeedOverlaySide.bottom;
    final extent = vertical ? childSize.height : childSize.width;
    final resolved =
        flip &&
            extent > space(side, b) &&
            space(opposite(side), b) > space(side, b)
        ? opposite(side)
        : side;
    onResolved?.call(resolved);
    final start = align == SeedOverlayAlign.start;
    final end = align == SeedOverlayAlign.end;
    final leading = textDirection == TextDirection.rtl
        ? anchor.right - childSize.width
        : anchor.left;
    final trailing = textDirection == TextDirection.rtl
        ? anchor.left
        : anchor.right - childSize.width;
    var x = vertical
        ? (start
              ? leading
              : end
              ? trailing
              : anchor.center.dx - childSize.width / 2)
        : resolved == SeedOverlaySide.left
        ? anchor.left - gap - childSize.width
        : anchor.right + gap;
    var y = vertical
        ? (resolved == SeedOverlaySide.top
              ? anchor.top - gap - childSize.height
              : anchor.bottom + gap)
        : start
        ? anchor.top
        : end
        ? anchor.bottom - childSize.height
        : anchor.center.dy - childSize.height / 2;
    if (shift) {
      x = x.clamp(b.left, math.max(b.left, b.right - childSize.width));
      y = y.clamp(b.top, math.max(b.top, b.bottom - childSize.height));
    }
    onPosition?.call(Offset(x, y), childSize);
    return Offset(x, y);
  }

  @override
  bool shouldRelayout(SeedOverlayPositionDelegate oldDelegate) =>
      anchor != oldDelegate.anchor ||
      insets != oldDelegate.insets ||
      side != oldDelegate.side ||
      align != oldDelegate.align ||
      textDirection != oldDelegate.textDirection ||
      gap != oldDelegate.gap ||
      flip != oldDelegate.flip ||
      shift != oldDelegate.shift ||
      maxWidth != oldDelegate.maxWidth ||
      maxHeight != oldDelegate.maxHeight;
}

/// An action which participates in its nearest overlay's controlled close policy.
class SeedOverlayAction extends StatelessWidget {
  const SeedOverlayAction({
    super.key,
    required this.label,
    this.onPressed,
    this.onAction,
    this.closeOnPressed = true,
    this.enabled = true,
    this.loading = false,
    this.variant = SeedButtonVariant.neutralSolid,
    this.size = SeedButtonSize.medium,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool Function()? onAction;
  final bool closeOnPressed, enabled, loading;
  final SeedButtonVariant variant;
  final SeedButtonSize size;
  @override
  Widget build(BuildContext context) => SeedButton(
    label: label,
    variant: variant,
    size: size,
    enabled: enabled,
    loading: loading,
    onPressed: () {
      onPressed?.call();
      if (onAction?.call() == false) return;
      if (context.mounted && closeOnPressed) {
        SeedOverlayScope.maybeOf(context)
            ?.close(SeedOverlayDismissReason.action);
      }
    },
  );
}

typedef SeedDialogAction = SeedOverlayAction;
typedef SeedPopoverAction = SeedOverlayAction;
typedef SeedBottomSheetAction = SeedOverlayAction;
