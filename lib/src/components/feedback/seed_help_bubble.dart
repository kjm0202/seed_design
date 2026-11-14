import '../../localization/seed_localizations.dart';

import 'dart:async';
import 'dart:ui' show SemanticsRole;

import '../overlay/seed_anchored_overlay.dart';
import '../../foundations/motion/seed_motion.dart';

import 'package:material_ui/material_ui.dart';

import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';

/// Direction in which the help bubble's pointer projects.
enum SeedHelpBubbleArrowPlacement {
  /// Arrow along the top edge.
  top,

  /// Arrow along the bottom edge.
  bottom,

  /// Arrow along the left edge.
  left,

  /// Arrow along the right edge.
  right,

  /// No pointer arrow.
  none,
}

/// Help Bubble (Tooltip speech bubble) component of SEED Design System.
///
/// Highlights new features, provides contextual guidance, and supports
/// directional indicator arrows and close actions.
class SeedHelpBubble extends StatelessWidget {
  /// Required heading of the bubble.
  final String title;

  /// Optional supporting text below [title].
  final String? description;

  /// Displays a close action when supplied.
  final VoidCallback? onClose;

  /// Edge that holds the pointer arrow; defaults to top.
  final SeedHelpBubbleArrowPlacement arrowPlacement;

  /// Arrow position along its edge, in logical pixels.
  final double arrowOffset;

  /// Uses the brand surface instead of the neutral surface.
  final bool isBrand;

  /// Maximum content width (280 logical pixels by default).
  final double maxWidth;
  final bool _dialogSemantics;

  /// Creates the standalone help bubble card.
  ///
  /// [onClose] makes the close affordance visible. To anchor an interactive
  /// bubble to a trigger, use [SeedHelpBubbleTrigger].
  const SeedHelpBubble({
    super.key,
    required this.title,
    this.description,
    this.onClose,
    this.arrowPlacement = SeedHelpBubbleArrowPlacement.top,
    this.arrowOffset = 24.0,
    this.isBrand = false,
    this.maxWidth = 280,
  }) : _dialogSemantics = false;

  // Interactive HelpBubble.Content has a dialog role. Tooltip reuses the
  // painted card but must not inherit that role; keep this constructor private.
  const SeedHelpBubble._dialog({
    required this.title,
    this.description,
    this.onClose,
    this.arrowPlacement = SeedHelpBubbleArrowPlacement.top,
    this.arrowOffset = 24.0,
    this.isBrand = false,
    this.maxWidth = 280,
  }) : _dialogSemantics = true;

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;

    final Color bgColor = isBrand
        ? colors.bg.brandSolid
        : colors.bg.neutralSolid;
    final Color fgColor = isBrand
        ? colors.fg.onBrandSolid
        : colors.fg.onNeutralSolid;

    Widget arrow = CustomPaint(
      size: const Size(12.0, 8.0),
      painter: _TrianglePainter(
        color: bgColor,
        isPointingUp: arrowPlacement == SeedHelpBubbleArrowPlacement.top,
      ),
    );

    final card = Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: SeedBorderRadius.r3,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              12,
              10,
              onClose != null ? 30 : 12,
              10,
            ),
            // Ordinary tooltips keep their original intrinsic height and do
            // not introduce an extra scroll target. Only when scaled text
            // exceeds floating-ui's available height is the text scrollable;
            // the close button stays fixed outside that scrolling surface.
            child: LayoutBuilder(
              builder: (context, limits) {
                final titleStyle = typography.t3Bold.copyWith(color: fgColor);
                final descriptionStyle = typography.t3Regular.copyWith(
                  color: fgColor,
                );
                final content = Semantics(
                  label: title,
                  hint: description,
                  excludeSemantics: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title, style: titleStyle),
                      if (description != null) ...[
                        const SizedBox(height: SeedDimension.x0_5),
                        Text(description!, style: descriptionStyle),
                      ],
                    ],
                  ),
                );
                if (!limits.hasBoundedHeight) return content;
                double textHeight(String value, TextStyle style) {
                  final painter =
                      TextPainter(
                        text: TextSpan(text: value, style: style),
                        textDirection: Directionality.of(context),
                        textScaler: MediaQuery.textScalerOf(context),
                      )..layout(
                        maxWidth: limits.hasBoundedWidth
                            ? limits.maxWidth
                            : maxWidth,
                      );
                  final measured = painter.height;
                  painter.dispose();
                  return measured;
                }

                final contentHeight =
                    textHeight(title, titleStyle) +
                    (description == null
                        ? 0
                        : SeedDimension.x0_5 +
                              textHeight(description!, descriptionStyle));
                return contentHeight > limits.maxHeight + 0.5
                    ? SingleChildScrollView(child: content)
                    : content;
              },
            ),
          ),
          if (onClose != null)
            PositionedDirectional(
              top: 0,
              end: 0,
              child: SeedPressable(
                semanticsLabel: SeedLocalizations.label(
                  context,
                  SeedLabel.close,
                ),
                behavior: HitTestBehavior.opaque,
                onTap: onClose,
                child: SizedBox.square(
                  dimension: 38,
                  child: Center(
                    child: Icon(
                      Icons.close_rounded,
                      size: 14.0,
                      color: fgColor,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    final Widget bubbleBody = _dialogSemantics
        ? Semantics(
            // React gives role=dialog to HelpBubble.Content (the painted card),
            // while its separate arrow lives outside those semantic bounds.
            // A container keeps this node from merging into the parent that
            // also lays out the arrow.
            container: true,
            role: SemanticsRole.dialog,
            explicitChildNodes: true,
            namesRoute: true,
            label: title,
            child: card,
          )
        : card;

    if (arrowPlacement == SeedHelpBubbleArrowPlacement.none) {
      return bubbleBody;
    }

    if (arrowPlacement == SeedHelpBubbleArrowPlacement.left ||
        arrowPlacement == SeedHelpBubbleArrowPlacement.right) {
      final horizontalArrow = Padding(
        padding: EdgeInsets.only(top: arrowOffset),
        child: RotatedBox(
          quarterTurns: arrowPlacement == SeedHelpBubbleArrowPlacement.left
              ? 3
              : 1,
          child: CustomPaint(
            size: const Size(12, 8),
            painter: _TrianglePainter(color: bgColor, isPointingUp: true),
          ),
        ),
      );
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (arrowPlacement == SeedHelpBubbleArrowPlacement.left)
            horizontalArrow,
          Flexible(child: bubbleBody),
          if (arrowPlacement == SeedHelpBubbleArrowPlacement.right)
            horizontalArrow,
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (arrowPlacement == SeedHelpBubbleArrowPlacement.top) ...[
          Padding(
            padding: EdgeInsets.only(left: arrowOffset),
            child: arrow,
          ),
        ],
        Flexible(child: bubbleBody),
        if (arrowPlacement == SeedHelpBubbleArrowPlacement.bottom) ...[
          Padding(
            padding: EdgeInsets.only(left: arrowOffset),
            child: arrow,
          ),
        ],
      ],
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  final bool isPointingUp;

  _TrianglePainter({required this.color, required this.isPointingUp});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    // Same rounded 12 x 8 tip geometry as getHelpBubbleArrowTipPath.
    canvas.save();
    if (isPointingUp) {
      canvas.translate(0, size.height);
      canvas.scale(1, -1);
    }
    const radius = 2.0;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2 + radius, size.height - radius)
      ..quadraticBezierTo(
        size.width / 2,
        size.height,
        size.width / 2 - radius,
        size.height - radius,
      )
      ..close();
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.isPointingUp != isPointingUp;
  }
}

SeedHelpBubbleArrowPlacement _bubbleArrow(SeedOverlaySide side) =>
    switch (side) {
      SeedOverlaySide.top => SeedHelpBubbleArrowPlacement.bottom,
      SeedOverlaySide.bottom => SeedHelpBubbleArrowPlacement.top,
      SeedOverlaySide.left => SeedHelpBubbleArrowPlacement.right,
      SeedOverlaySide.right => SeedHelpBubbleArrowPlacement.left,
    };

double _bubbleArrowOffset(BuildContext context) {
  final scope = SeedOverlayScope.maybeOf(context)!;
  return (scope.side == SeedOverlaySide.top ||
              scope.side == SeedOverlaySide.bottom
          ? scope.anchorPoint?.dx
          : scope.anchorPoint?.dy) ??
      24;
}

/// Anchors an interactive help bubble to a trigger or custom [anchor].
///
/// Uses [SeedAnchoredOverlay] for dismissal, positioning and focus handling.
/// React's open/defaultOpen/onOpenChange inputs correspond to [open],
/// [defaultOpen] and [onOpenChange].
class SeedHelpBubbleTrigger extends StatelessWidget {
  /// Creates a trigger with controlled or internal open state.
  ///
  /// [triggerBuilder] receives the current open state and a toggle callback.
  /// [onOpenChange] receives open state and dismissal reason. The older
  /// [onOpenChanged] name is a deprecated alias.
  const SeedHelpBubbleTrigger({
    super.key,
    required this.triggerBuilder,
    required this.title,
    this.description,
    this.anchor,
    this.controller,
    this.open,
    this.defaultOpen = false,
    SeedOverlayOpenChanged? onOpenChange,
    @Deprecated('Use onOpenChange instead.')
    SeedOverlayOpenChanged? onOpenChanged,
    this.side = SeedOverlaySide.top,
    this.align = SeedOverlayAlign.center,
    this.flip = true,
    this.flipFallbackSides,
    this.maxWidth = 280,
    this.showCloseButton = true,
    this.closeOnInteractOutside = true,
    this.autoFocus = false,
    this.isBrand = false,
    this.skipAnimation = false,
  }) : onOpenChanged = onOpenChange ?? onOpenChanged,
       assert(onOpenChange == null || onOpenChanged == null);

  /// Builds the trigger with context, open flag and toggle callback.
  final Widget Function(BuildContext, bool, VoidCallback) triggerBuilder;

  /// Required bubble heading.
  final String title;

  /// Optional body copy.
  final String? description;

  /// Optional separate anchor widget; otherwise uses the trigger itself.
  final Widget? anchor;

  /// Flutter overlay controller for imperative opening and closing.
  final SeedOverlayController? controller;

  /// Parent-controlled visibility when non-null.
  final bool? open;

  /// Opening state and behavior options.
  ///
  /// [defaultOpen] is the initial uncontrolled state (false); [flip] moves
  /// the popup to another side when space is insufficient (true).
  /// [showCloseButton] and [closeOnInteractOutside] default to true,
  /// [autoFocus], [isBrand] and [skipAnimation] to false.
  final bool defaultOpen,
      flip,
      showCloseButton,
      closeOnInteractOutside,
      autoFocus,
      isBrand,
      skipAnimation;

  /// Ordered alternate sides (React `flip={['right', 'left', 'top', 'bottom']}`).
  ///
  /// Null keeps the established bool [flip] opposite-side behavior unchanged.
  final List<SeedOverlaySide>? flipFallbackSides;

  /// Maximum width of the bubble card, default 280 logical pixels.
  final double maxWidth;

  /// Deprecated spelling of [onOpenChange]; carries dismiss reason.
  @Deprecated('Use onOpenChange instead.')
  final SeedOverlayOpenChanged? onOpenChanged;

  /// Official spelling of the callback for open-state changes.
  SeedOverlayOpenChanged? get onOpenChange => onOpenChanged;

  /// Preferred side relative to the anchor (top by default).
  final SeedOverlaySide side;

  /// Alignment along the chosen side (center by default).
  final SeedOverlayAlign align;
  @override
  Widget build(BuildContext context) => SeedAnchoredOverlay(
    triggerBuilder: triggerBuilder,
    anchor: anchor,
    controller: controller,
    open: open,
    defaultOpen: defaultOpen,
    onOpenChanged: onOpenChanged,
    side: side,
    gap: 4,
    arrowPadding: 14,
    align: align,
    flip: flip,
    flipFallbackSides: flipFallbackSides,
    maxWidth: maxWidth,
    autoFocus: autoFocus,
    closeOnInteractOutside: closeOnInteractOutside,
    closeOnFocusOut: closeOnInteractOutside,
    enterScale: 0.9,
    exitScale: 1,
    enterCurve: SeedCurves.enter,
    exitCurve: SeedCurves.easing,
    scaleFromAnchor: true,
    enterDuration: SeedDuration.d4,
    exitDuration: SeedDuration.d4,
    skipAnimation: skipAnimation,
    overlayBuilder: (context) => SeedHelpBubble._dialog(
      title: title,
      description: description,
      isBrand: isBrand,
      maxWidth: maxWidth,
      arrowOffset: _bubbleArrowOffset(context),
      arrowPlacement: _bubbleArrow(SeedOverlayScope.maybeOf(context)!.side),
      onClose: showCloseButton
          ? () =>
                SeedOverlayScope.maybeOf(context)!
                    .close(SeedOverlayDismissReason.closeButton)
          : null,
    ),
  );
}

/// Shares tooltip delay configuration across descendant tooltips.
///
/// Recently closed tooltips may reopen without the full initial delay
/// during [skipDelay].
class SeedTooltipDelayGroup extends StatefulWidget {
  /// Configures hover delays for [child]'s tooltips.
  ///
  /// Defaults: [openDelay] 200 ms, [closeDelay] 100 ms, [skipDelay] 800 ms.
  const SeedTooltipDelayGroup({
    super.key,
    required this.child,
    this.openDelay = const Duration(milliseconds: 200),
    this.closeDelay = const Duration(milliseconds: 100),
    this.skipDelay = const Duration(milliseconds: 800),
  });

  /// Tooltip-bearing subtree.
  final Widget child;

  /// Initial hover delay, exit delay and recent-tooltip skip interval.
  final Duration openDelay, closeDelay, skipDelay;

  /// Creates state that remembers active tooltip and last close time.
  @override
  State<SeedTooltipDelayGroup> createState() => _SeedTooltipDelayGroupState();
}

class _SeedTooltipDelayGroupState extends State<SeedTooltipDelayGroup> {
  DateTime? lastClose;
  _SeedHelpBubbleTooltipState? active;
  // A non-tooltip disclosure sharing this group (SeedNavigationMenu).
  Object? member;
  VoidCallback? memberClose;

  void closeMember() {
    final close = memberClose;
    member = null;
    memberClose = null;
    close?.call();
  }

  @override
  Widget build(BuildContext context) =>
      _SeedTooltipGroupScope(state: this, child: widget.child);
}

/// Lets a hover disclosure other than [SeedHelpBubbleTooltip] share the
/// nearest [SeedTooltipDelayGroup], as React's navigation menu shares its
/// floating-ui delay group with `HelpBubbleTooltip`.
///
/// Package-internal; `seed_design.dart` does not export it.
class SeedTooltipDelayGroupLink {
  const SeedTooltipDelayGroupLink._(this._state);
  final _SeedTooltipDelayGroupState _state;

  /// The nearest group, registering a dependency on it; null without one.
  static SeedTooltipDelayGroupLink? maybeOf(BuildContext context) {
    final state = context
        .dependOnInheritedWidgetOfExactType<_SeedTooltipGroupScope>()
        ?.state;
    return state == null ? null : SeedTooltipDelayGroupLink._(state);
  }

  /// The group's initial open delay and its close delay.
  Duration get openDelay => _state.widget.openDelay;

  /// The group's close delay.
  Duration get closeDelay => _state.widget.closeDelay;

  /// Whether a tooltip or another member is open, so an opening skips delay.
  bool get hasOpenMember => _state.active != null || _state.member != null;

  /// Records [member] as open, closing the previously open tooltip or member.
  void open(Object member, VoidCallback close) {
    final tooltip = _state.active;
    if (tooltip != null) {
      tooltip._setOpen(false, SeedOverlayDismissReason.trigger);
      if (_state.active == tooltip) _state.active = null;
    }
    if (_state.member != null && _state.member != member) _state.closeMember();
    _state.member = member;
    _state.memberClose = close;
  }

  /// Forgets [member] if it is the open member.
  void close(Object member) {
    if (_state.member != member) return;
    _state.member = null;
    _state.memberClose = null;
  }

  @override
  bool operator ==(Object other) =>
      other is SeedTooltipDelayGroupLink && other._state == _state;

  @override
  int get hashCode => _state.hashCode;
}

class _SeedTooltipGroupScope extends InheritedWidget {
  const _SeedTooltipGroupScope({required this.state, required super.child});
  final _SeedTooltipDelayGroupState state;
  @override
  bool updateShouldNotify(_SeedTooltipGroupScope oldWidget) =>
      state != oldWidget.state;
}

/// Hover/focus help bubble with tooltip semantics and configurable delays.
///
/// Unlike [SeedHelpBubbleTrigger], this presents noninteractive tooltip
/// content. [onOpenChange] follows React's bool callback, while
/// [onOpenChanged] is a Flutter-specific callback including dismiss reason.
class SeedHelpBubbleTooltip extends StatefulWidget {
  /// Adds a tooltip to [child].
  ///
  /// [open] optionally controls visibility. When delay values are omitted,
  /// values come from [SeedTooltipDelayGroup] or 200/100 ms defaults.
  /// [keepOpenOnContentHover] defaults to false, following React.
  const SeedHelpBubbleTooltip({
    super.key,
    required this.child,
    required this.title,
    this.description,
    this.open,
    this.onOpenChange,
    this.onOpenChanged,
    this.openDelay,
    this.closeDelay,
    this.side = SeedOverlaySide.top,
    this.align = SeedOverlayAlign.center,
    this.flip = true,
    this.keepOpenOnContentHover = false,
    this.maxWidth = 280,
    this.isBrand = false,
  });

  /// Hoverable and focusable trigger subtree.
  final Widget child;

  /// Required tooltip heading.
  final String title;

  /// Optional supporting text.
  final String? description;

  /// Controlled open state; null uses internal interaction handling.
  final bool? open;

  /// React-style callback invoked with the next open flag.
  final ValueChanged<bool>? onOpenChange;

  /// Flutter callback reporting visibility and dismiss reason.
  final SeedOverlayOpenChanged? onOpenChanged;

  /// Optional delay overrides; null inherits the tooltip delay group.
  final Duration? openDelay, closeDelay;

  /// Preferred popup side relative to [child].
  final SeedOverlaySide side;

  /// Alignment along [side].
  final SeedOverlayAlign align;

  /// [flip] permits alternate positioning (true by default);
  /// [keepOpenOnContentHover] controls pointer transition (false by default);
  /// [isBrand] selects a brand-colored surface (false by default).
  final bool flip, keepOpenOnContentHover, isBrand;

  /// Maximum bubble width, 280 logical pixels by default.
  final double maxWidth;

  /// Creates state for hover timers and the anchored overlay controller.
  @override
  State<SeedHelpBubbleTooltip> createState() => _SeedHelpBubbleTooltipState();
}

class _SeedHelpBubbleTooltipState extends State<SeedHelpBubbleTooltip> {
  final SeedOverlayController _controller = SeedOverlayController();
  Timer? _timer;
  _SeedTooltipDelayGroupState? group;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final previous = group;
    group = context
        .dependOnInheritedWidgetOfExactType<_SeedTooltipGroupScope>()
        ?.state;
    if (previous != group) {
      if (previous?.active == this) previous!.active = null;
      _syncGroupAfterBuild();
    }
  }

  bool get _isOpen => widget.open ?? _controller.isOpen;

  void _syncGroupAfterBuild() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _updateGroup(_isOpen);
    });
  }

  void _updateGroup(bool open) {
    final g = group;
    if (g == null) return;
    if (open) {
      final previous = g.active;
      if (previous != null && previous != this) {
        previous._setOpen(false, SeedOverlayDismissReason.trigger);
      }
      if (g.member != null) g.closeMember();
      g.active = this;
    } else if (g.active == this) {
      g.active = null;
      g.lastClose = DateTime.now();
    }
  }

  @override
  void didUpdateWidget(covariant SeedHelpBubbleTooltip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.open != widget.open) _syncGroupAfterBuild();
  }

  void _setOpen(bool open, SeedOverlayDismissReason reason) {
    _timer?.cancel();
    if (!mounted || open == _isOpen) return;
    widget.onOpenChange?.call(open);
    widget.onOpenChanged?.call(open, reason);
    if (widget.open == null) {
      open ? _controller.open() : _controller.close(reason);
      _updateGroup(open);
    }
  }

  void _request(bool open) {
    _timer?.cancel();
    final g = group;
    final useGroupDelay = widget.openDelay == null && widget.closeDelay == null;
    final skip =
        g?.active != null ||
        g?.member != null ||
        (g?.lastClose != null &&
            DateTime.now().difference(g!.lastClose!) < g.widget.skipDelay);
    final delay = open
        ? (skip && useGroupDelay
              ? Duration.zero
              : widget.openDelay ??
                    (useGroupDelay ? g?.widget.openDelay : null) ??
                    const Duration(milliseconds: 200))
        : widget.closeDelay ??
              (useGroupDelay ? g?.widget.closeDelay : null) ??
              const Duration(milliseconds: 100);
    _timer = Timer(
      delay,
      () => _setOpen(open, SeedOverlayDismissReason.trigger),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (group?.active == this) {
      group!.active = null;
      group!.lastClose = DateTime.now();
    }
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SeedAnchoredOverlay(
    controller: _controller,
    open: widget.open,
    side: widget.side,
    gap: 4,
    arrowPadding: 14,
    enterScale: 0.9,
    exitScale: 1,
    enterCurve: SeedCurves.enter,
    exitCurve: SeedCurves.easing,
    scaleFromAnchor: true,
    enterDuration: SeedDuration.d4,
    exitDuration: SeedDuration.d4,
    align: widget.align,
    flip: widget.flip,
    maxWidth: widget.maxWidth,
    autoFocus: false,
    contentFocusable: false,
    restoreFocus: false,
    onOpenChange: (open, reason) {
      if (widget.open == null) _updateGroup(open);
      widget.onOpenChange?.call(open);
      widget.onOpenChanged?.call(open, reason);
    },
    triggerBuilder: (context, open, toggle) => MouseRegion(
      onEnter: (_) => _request(true),
      onExit: (_) => _request(false),
      child: Focus(
        canRequestFocus: false,
        onFocusChange: (focused) => _setOpen(
          focused,
          focused
              ? SeedOverlayDismissReason.trigger
              : SeedOverlayDismissReason.focusOut,
        ),
        child: widget.child,
      ),
    ),
    overlayBuilder: (context) => MouseRegion(
      onEnter: widget.keepOpenOnContentHover ? (_) => _timer?.cancel() : null,
      onExit: widget.keepOpenOnContentHover ? (_) => _request(false) : null,
      child: Semantics(
        tooltip: widget.description == null
            ? widget.title
            : '${widget.title}. ${widget.description}',
        child: SeedHelpBubble(
          title: widget.title,
          description: widget.description,
          maxWidth: widget.maxWidth,
          isBrand: widget.isBrand,
          arrowOffset: _bubbleArrowOffset(context),
          arrowPlacement: _bubbleArrow(SeedOverlayScope.maybeOf(context)!.side),
        ),
      ),
    ),
  );
}
