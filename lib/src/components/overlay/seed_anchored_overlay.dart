import 'dart:math' as math;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/rendering.dart'
    show BoxParentData, RenderBox, RenderShiftedBox;
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../disclosure/seed_accordion.dart';
import '../../foundations/motion/seed_motion.dart';
import '../button/seed_button.dart';

enum SeedOverlaySide {
  top,
  bottom,
  left,
  right,
}

enum SeedOverlayAlign {
  start,
  center,
  end,
}

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
    this.flipFallbackSides,
    this.shift = true,
    this.maxWidth,
    this.maxHeight,
    this.fitMinExtent,
    this.autoFocus = true,
    this.contentFocusable = true,
    this.restoreFocus = true,
    this.closeOnInteractOutside = true,
    this.closeOnFocusOut = false,
    this.tabExitsContent = false,
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

  final List<SeedOverlaySide>? flipFallbackSides;

  final double? maxWidth, maxHeight;

  final double? fitMinExtent;

  /// Whether the overlay content can receive keyboard or accessibility focus.
  /// Disable for descriptive content such as a tooltip.
  final bool contentFocusable;
  final bool autoFocus,
      restoreFocus,
      closeOnInteractOutside,
      closeOnFocusOut,
      tabExitsContent,
      skipAnimation;
  final double enterScale;
  final double? exitScale;
  final Curve enterCurve, exitCurve;
  final bool scaleFromAnchor;
  final Duration enterDuration, exitDuration;
  @override
  State<SeedAnchoredOverlay> createState() => _SeedAnchoredOverlayState();
}

class _MenuEscapeScopeBinding {
  _MenuEscapeScopeBinding(this.previous);

  final KeyEventResult Function(FocusNode, KeyEvent)? previous;
  late final KeyEventResult Function(FocusNode, KeyEvent) handler;
  final List<_SeedAnchoredOverlayState> owners = [];
}

class _SeedAnchoredOverlayState extends State<SeedAnchoredOverlay>
    with SingleTickerProviderStateMixin {
  // Menu Escape is normally handled by the focused popup or trigger below.
  // A collapsed, controlled Accordion can exclude both from the focus tree
  // without unmounting its still-open floating Menu. Bind a fallback to that
  // Menu's own route FocusScope, never to the global keyboard dispatcher.
  static final Map<FocusScopeNode, _MenuEscapeScopeBinding> _menuEscapeScopes =
      {};
  FocusScopeNode? _menuEscapeScope;

  void _bindMenuEscapeScope() {
    if (!widget.tabExitsContent || !_open) return;
    final scope = _triggerFocus.nearestScope;
    if (scope == null || identical(_menuEscapeScope, scope)) return;
    _unbindMenuEscapeScope();
    final binding = _menuEscapeScopes.putIfAbsent(scope, () {
      final binding = _MenuEscapeScopeBinding(scope.onKeyEvent);
      binding.handler = (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          // Most recently opened child owns Escape. In normal focusable
          // states, its local CallbackShortcuts handle the event first.
          for (final overlay in binding.owners.reversed) {
            if (overlay.mounted &&
                overlay._open &&
                overlay.widget.tabExitsContent &&
                (!overlay._contentFocus.canRequestFocus ||
                    overlay._accordionContentHidden) &&
                !overlay._overlayFocus.hasFocus &&
                !overlay._triggerFocus.hasFocus) {
              overlay._request(false, SeedOverlayDismissReason.escapeKey);
              return KeyEventResult.handled;
            }
          }
        }
        return binding.previous?.call(node, event) ?? KeyEventResult.ignored;
      };
      scope.onKeyEvent = binding.handler;
      return binding;
    });
    binding.owners.add(this);
    _menuEscapeScope = scope;
  }

  void _unbindMenuEscapeScope() {
    final scope = _menuEscapeScope;
    if (scope == null) return;
    _menuEscapeScope = null;
    final binding = _menuEscapeScopes[scope];
    if (binding == null) return;
    binding.owners.remove(this);
    if (binding.owners.isEmpty) {
      if (identical(scope.onKeyEvent, binding.handler)) {
        scope.onKeyEvent = binding.previous;
      }
      _menuEscapeScopes.remove(scope);
    }
  }

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
  // OverlayPortal does not rebuild its overlay when only the anchor's render
  // position changes (e.g. AnimatedPositioned). React floating-ui observes
  // layout shifts through autoUpdate; sample after *existing* Flutter frames
  // while open. This callback never schedules frames merely to poll.
  Rect? _lastRenderedAnchorRect;
  bool _anchorCheckQueued = false;
  Rect? _readAnchorRect() {
    final anchor = _anchorKey.currentContext?.findRenderObject() as RenderBox?;
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (anchor == null ||
        overlay == null ||
        !anchor.attached ||
        !overlay.attached) {
      return null;
    }
    return overlay.globalToLocal(anchor.localToGlobal(Offset.zero)) &
        anchor.size;
  }

  void _observeAnchorAfterFrame() {
    if (_anchorCheckQueued || !_open || !mounted) return;
    _anchorCheckQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _anchorCheckQueued = false;
      if (!mounted || !_open) return;
      final rect = _readAnchorRect();
      if (rect != null && rect != _lastRenderedAnchorRect) {
        setState(() => _lastRenderedAnchorRect = rect);
      }
      _observeAnchorAfterFrame();
    });
  }

  bool _accordionContentHidden = false;
  bool _accordionWasHiddenWhileOpen = false;
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
    _accordionContentHidden =
        SeedAccordionContentFocusScope.maybeOf(context)?.hidden ?? false;
    if (_accordionContentHidden && _open && widget.tabExitsContent) {
      _accordionWasHiddenWhileOpen = true;
      // The Accordion removed its content from traversal, not from the focus
      // tree. Its floating Menu retains keyboard focus while visually hidden.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _open && _accordionContentHidden) {
          final owners = _menuEscapeScopes[_menuEscapeScope]?.owners;
          if (owners != null && owners.length > 1) {
            // Multiple simultaneously open child menus retain the route's
            // existing topmost-only Escape dispatcher, not competing popup
            // focus requests from sibling portals.
            _menuEscapeScope?.requestFocus();
          } else {
            _contentFocus.requestFocus();
          }
        }
      });
    }
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
    if (_accordionContentHidden) {
      for (final target in _triggerFocus.descendants) {
        if (target.canRequestFocus) {
          target.requestFocus();
          return true;
        }
      }
    }
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
    _accordionWasHiddenWhileOpen = false;
    _returnFocus = FocusManager.instance.primaryFocus;
    setState(() => _open = true);
    _portal.show();
    _observeAnchorAfterFrame();
    _bindMenuEscapeScope();
    _animation.duration =
        widget.skipAnimation || MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : widget.enterDuration;
    _animation.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_open) return;
      _bindMenuEscapeScope();
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
    _unbindMenuEscapeScope();
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
      // A Menu that outlived a temporarily collapsed Accordion should return
      // Escape focus to its original trigger even if the parent reopened in
      // the meantime. Ordinary overlays retain their existing return target.
      if (_accordionWasHiddenWhileOpen &&
          widget.tabExitsContent &&
          reason == SeedOverlayDismissReason.escapeKey) {
        for (final node in _triggerFocus.descendants) {
          if (node.canRequestFocus) {
            target = node;
            break;
          }
        }
      }
      // Touch activation need not focus a Flutter button before it opens the
      // overlay. Returning to a parent focus container loses the trigger's tab
      // stop; React Popover returns to its trigger in this path as well.
      // Preserve a previously focused control, including explicit external
      // focus, and use the trigger only when no control had focus on opening.
      if (target == null ||
          target is FocusScopeNode ||
          _triggerFocus.ancestors.contains(target)) {
        for (final node in _triggerFocus.descendants) {
          if (node.canRequestFocus &&
              (!node.skipTraversal || _accordionContentHidden)) {
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
    _unbindMenuEscapeScope();
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
      _lastRenderedAnchorRect = rect;
      // OverlayPortal builds in the root overlay, whose MediaQuery may not
      // include the anchor subtree's safe-area or keyboard insets. Collision
      // bounds belong to the reference viewport's MediaQuery, not a default
      // MediaQuery inherited by the portal's overlay child.
      final media = MediaQuery.of(context);
      return Positioned.fill(
        child: Offstage(
          offstage: !_open && !_animation.isAnimating,
          child: TickerMode(
            enabled: _open || _animation.isAnimating,
            child: _SeedFloatingLayout(
              delegate: SeedOverlayPositionDelegate(
                anchor: rect,
                side: widget.side,
                align: widget.align,
                gap: widget.gap,
                flip: widget.flip,
                flipFallbackSides: widget.flipFallbackSides,
                shift: widget.shift,
                textDirection: Directionality.of(context),
                maxWidth: widget.maxWidth,
                maxHeight: widget.maxHeight,
                fitMinExtent: widget.fitMinExtent,
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
                // Only the topmost official layer dismisses on an outside
                // press, so one tap on a modal's barrier closes just this.
                consumeOutsideTaps:
                    widget.closeOnInteractOutside &&
                    switch (ModalRoute.of(context)) {
                      final PopupRoute<dynamic> route =>
                        route.barrierDismissible,
                      _ => false,
                    },
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
                            // React Menu uses Tab to leave its roving menu
                            // items, closing the popup and continuing to the
                            // next control in the parent dialog. Ordinary
                            // Popovers retain their internal tab traversal.
                            if (widget.tabExitsContent) {
                              if (HardwareKeyboard.instance.isShiftPressed) {
                                // React reverse-Tab returns to MenuTrigger
                                // while keeping the popup open.
                                for (final target
                                    in _triggerFocus.descendants) {
                                  if (target.canRequestFocus &&
                                      (!target.skipTraversal ||
                                          _accordionContentHidden)) {
                                    target.requestFocus();
                                    return KeyEventResult.handled;
                                  }
                                }
                              } else if (_focusAtTriggerBoundary(
                                backwards: false,
                              )) {
                                _request(
                                  false,
                                  SeedOverlayDismissReason.focusOut,
                                );
                                return KeyEventResult.handled;
                              }
                            }
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
          // A single trigger must receive its parent's *vertical* constraints.
          // Wrapping it in a Column would measure it with an unbounded main
          // axis: a 50px intrinsic InputButton then overflows a 40px toolbar
          // (e.g. TablePagination at a large text scale). Only use a Column
          // when the caller explicitly supplies a separate anchor widget.
          child: widget.anchor == null
              ? KeyedSubtree(
                  key: _anchorKey,
                  child: widget.triggerBuilder(
                    context,
                    _open,
                    () => _request(!_open, SeedOverlayDismissReason.trigger),
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    KeyedSubtree(key: _anchorKey, child: widget.anchor!),
                    widget.triggerBuilder(
                      context,
                      _open,
                      () => _request(!_open, SeedOverlayDismissReason.trigger),
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
    this.flipFallbackSides,
    this.shift = true,
    this.textDirection = TextDirection.ltr,
    this.maxWidth,
    this.maxHeight,
    this.fitMinExtent,
    this.onResolved,
    this.onPosition,
  });
  final Rect anchor;
  final EdgeInsets insets;
  final SeedOverlaySide side;
  final SeedOverlayAlign align;
  final double gap;
  final bool flip, shift;

  final List<SeedOverlaySide>? flipFallbackSides;
  final TextDirection textDirection;
  final double? maxWidth, maxHeight, fitMinExtent;
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
    if (flip && flipFallbackSides != null) {
      // With perpendicular fallbacks, constraining width to the requested
      // horizontal side would crush the bubble before the vertical candidates
      // are evaluated. Measure within the viewport instead.
      return BoxConstraints.loose(
        Size(
          math.min(maxWidth ?? double.infinity, b.width),
          math.min(maxHeight ?? double.infinity, b.height),
        ),
      );
    }
    final fits = fitMinExtent != null && space(side, b) >= fitMinExtent!;
    final available = flip && !fits
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

  Offset _unshiftedPosition(SeedOverlaySide candidate, Size childSize) {
    final start = align == SeedOverlayAlign.start;
    final end = align == SeedOverlayAlign.end;
    final leading = textDirection == TextDirection.rtl
        ? anchor.right - childSize.width
        : anchor.left;
    final trailing = textDirection == TextDirection.rtl
        ? anchor.left
        : anchor.right - childSize.width;
    final vertical =
        candidate == SeedOverlaySide.top || candidate == SeedOverlaySide.bottom;
    final x = vertical
        ? (start
              ? leading
              : end
              ? trailing
              : anchor.center.dx - childSize.width / 2)
        : candidate == SeedOverlaySide.left
        ? anchor.left - gap - childSize.width
        : anchor.right + gap;
    final y = vertical
        ? (candidate == SeedOverlaySide.top
              ? anchor.top - gap - childSize.height
              : anchor.bottom + gap)
        : start
        ? anchor.top
        : end
        ? anchor.bottom - childSize.height
        : anchor.center.dy - childSize.height / 2;
    return Offset(x, y);
  }

  SeedOverlaySide _resolveSide(Size size, Size childSize) {
    final b = bounds(size);
    final SeedOverlaySide resolved;
    if (flip && flipFallbackSides != null) {
      final candidates = <SeedOverlaySide>{
        side,
        for (final candidate in flipFallbackSides!)
          if (candidate != side) candidate,
      }.toList();
      // React's floating-ui flip runs before shift and checks both the main
      // axis and cross-axis overflows. A candidate may have room on its side
      // but still project beyond the top/bottom (or left/right) edge.
      //
      // Preserve the caller's order for the first fully fitting candidate;
      // with no perfect candidate, use floating-ui's bestFit approach:
      // minimize the sum of positive overflow distances.
      var best = candidates.first;
      var leastOverflow = double.infinity;
      for (final candidate in candidates) {
        final vertical =
            candidate == SeedOverlaySide.top ||
            candidate == SeedOverlaySide.bottom;
        final requiredExtent =
            fitMinExtent ?? (vertical ? childSize.height : childSize.width);
        final mainOverflow = math.max(
          0.0,
          requiredExtent - space(candidate, b),
        );
        final raw = _unshiftedPosition(candidate, childSize);
        final crossOverflow = vertical
            ? math.max(0.0, b.left - raw.dx) +
                  math.max(0.0, raw.dx + childSize.width - b.right)
            : math.max(0.0, b.top - raw.dy) +
                  math.max(0.0, raw.dy + childSize.height - b.bottom);
        final totalOverflow = mainOverflow + crossOverflow;
        if (totalOverflow <= 0) {
          best = candidate;
          break;
        }
        if (totalOverflow < leastOverflow) {
          leastOverflow = totalOverflow;
          best = candidate;
        }
      }
      resolved = best;
    } else {
      final vertical =
          side == SeedOverlaySide.top || side == SeedOverlaySide.bottom;
      final extent = vertical ? childSize.height : childSize.width;
      // With fitMinExtent, React's size() first caps the content at
      // max(fitMinExtent, available). Content shorter than the requested
      // side's space never overflows, so flip() keeps that side.
      resolved =
          flip &&
              extent > space(side, b) &&
              (fitMinExtent == null || space(side, b) < fitMinExtent!) &&
              space(opposite(side), b) > space(side, b)
          ? opposite(side)
          : side;
    }
    return resolved;
  }

  Offset _positionForSide(Size size, Size childSize, SeedOverlaySide resolved) {
    final b = bounds(size);
    onResolved?.call(resolved);
    final vertical =
        resolved == SeedOverlaySide.top || resolved == SeedOverlaySide.bottom;
    final raw = _unshiftedPosition(resolved, childSize);
    var x = raw.dx;
    var y = raw.dy;
    if (shift) {
      // floating-ui's shift(mainAxis:true) is along the axis perpendicular
      // to placement. Clamping the placement axis instead would detach the
      // bubble from its anchor when even the best candidate has too little
      // room, breaking the directional arrow and requested gutter.
      // Its limitShift() limiter also prevents a viewport collision from
      // shifting the entire popup past the reference. During nested scrolling
      // the reference can be only partly visible: prefer attachment over
      // pushing the popup completely inside the viewport safe padding.
      if (vertical) {
        x = x.clamp(b.left, math.max(b.left, b.right - childSize.width));
        x = x.clamp(anchor.left - childSize.width, anchor.right);
      } else {
        y = y.clamp(b.top, math.max(b.top, b.bottom - childSize.height));
        y = y.clamp(anchor.top - childSize.height, anchor.bottom);
      }
    }
    onPosition?.call(Offset(x, y), childSize);
    return Offset(x, y);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) =>
      _positionForSide(size, childSize, _resolveSide(size, childSize));

  @override
  bool shouldRelayout(SeedOverlayPositionDelegate oldDelegate) =>
      anchor != oldDelegate.anchor ||
      insets != oldDelegate.insets ||
      side != oldDelegate.side ||
      align != oldDelegate.align ||
      textDirection != oldDelegate.textDirection ||
      gap != oldDelegate.gap ||
      flip != oldDelegate.flip ||
      !listEquals(flipFallbackSides, oldDelegate.flipFallbackSides) ||
      shift != oldDelegate.shift ||
      maxWidth != oldDelegate.maxWidth ||
      maxHeight != oldDelegate.maxHeight ||
      fitMinExtent != oldDelegate.fitMinExtent ||
      onResolved != oldDelegate.onResolved ||
      onPosition != oldDelegate.onPosition;
}

class _SeedFloatingLayout extends StatelessWidget {
  const _SeedFloatingLayout({required this.delegate, required this.child});

  final SeedOverlayPositionDelegate delegate;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      delegate.flip && delegate.flipFallbackSides != null
      ? _SeedAdaptiveFloatingLayout(delegate: delegate, child: child)
      : CustomSingleChildLayout(delegate: delegate, child: child);
}

class _SeedAdaptiveFloatingLayout extends SingleChildRenderObjectWidget {
  const _SeedAdaptiveFloatingLayout({
    required this.delegate,
    required super.child,
  });

  final SeedOverlayPositionDelegate delegate;

  @override
  _RenderSeedAdaptiveFloatingLayout createRenderObject(BuildContext context) =>
      _RenderSeedAdaptiveFloatingLayout(delegate);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderSeedAdaptiveFloatingLayout renderObject,
  ) {
    renderObject.delegate = delegate;
  }
}

class _RenderSeedAdaptiveFloatingLayout extends RenderShiftedBox {
  _RenderSeedAdaptiveFloatingLayout(this._delegate) : super(null);

  SeedOverlayPositionDelegate _delegate;
  set delegate(SeedOverlayPositionDelegate next) {
    if (!_delegate.shouldRelayout(next) && !next.shouldRelayout(_delegate)) {
      _delegate = next;
      return;
    }
    _delegate = next;
    markNeedsLayout();
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;

  @override
  void performLayout() {
    size = constraints.biggest;
    final content = child;
    if (content == null) return;

    final b = _delegate.bounds(size);
    final fullWidth = math.min(_delegate.maxWidth ?? double.infinity, b.width);
    final fullHeight = math.min(
      _delegate.maxHeight ?? double.infinity,
      b.height,
    );
    content.layout(
      BoxConstraints.loose(Size(fullWidth, fullHeight)),
      parentUsesSize: true,
    );
    final resolved = _delegate._resolveSide(size, content.size);
    final vertical =
        resolved == SeedOverlaySide.top || resolved == SeedOverlaySide.bottom;
    final remaining = _delegate.space(resolved, b);
    // Always use the measured placement, even when content shrinks enough
    // that a *different* placement could now fit. Re-flipping after size()
    // would reverse the middleware order and oscillate between sides.
    content.layout(
      BoxConstraints.loose(
        Size(
          vertical ? fullWidth : math.min(fullWidth, remaining),
          vertical ? math.min(fullHeight, remaining) : fullHeight,
        ),
      ),
      parentUsesSize: true,
    );
    (content.parentData! as BoxParentData).offset = _delegate._positionForSide(
      size,
      content.size,
      resolved,
    );
  }
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
