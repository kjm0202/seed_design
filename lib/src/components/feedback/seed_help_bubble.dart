import 'dart:async';

import '../overlay/seed_anchored_overlay.dart';
import '../../foundations/motion/seed_motion.dart';

import 'package:material_ui/material_ui.dart';

import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';

/// Arrow orientation for [SeedHelpBubble].
enum SeedHelpBubbleArrowPlacement { top, bottom, left, right, none }

/// Help Bubble (Tooltip speech bubble) component of SEED Design System.
///
/// Highlights new features, provides contextual guidance, and supports
/// directional indicator arrows and close actions.
class SeedHelpBubble extends StatelessWidget {
  final String title;
  final String? description;
  final VoidCallback? onClose;
  final SeedHelpBubbleArrowPlacement arrowPlacement;
  final double arrowOffset;
  final bool isBrand;
  final double maxWidth;

  const SeedHelpBubble({
    super.key,
    required this.title,
    this.description,
    this.onClose,
    this.arrowPlacement = SeedHelpBubbleArrowPlacement.top,
    this.arrowOffset = 24.0,
    this.isBrand = false,
    this.maxWidth = 280,
  });

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

    Widget bubbleBody = Container(
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
            child: Semantics(
              label: title,
              hint: description,
              excludeSemantics: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: typography.t3Bold.copyWith(color: fgColor),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: SeedDimension.x0_5),
                    Text(
                      description!,
                      style: typography.t3Regular.copyWith(color: fgColor),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (onClose != null)
            PositionedDirectional(
              top: 0,
              end: 0,
              child: SeedPressable(
                semanticsLabel: '닫기',
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
        bubbleBody,
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

class SeedHelpBubbleTrigger extends StatelessWidget {
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
    this.maxWidth = 280,
    this.showCloseButton = true,
    this.closeOnInteractOutside = true,
    this.autoFocus = false,
    this.isBrand = false,
    this.skipAnimation = false,
  }) : onOpenChanged = onOpenChange ?? onOpenChanged,
       assert(onOpenChange == null || onOpenChanged == null);
  final Widget Function(BuildContext, bool, VoidCallback) triggerBuilder;
  final String title;
  final String? description;
  final Widget? anchor;
  final SeedOverlayController? controller;
  final bool? open;
  final bool defaultOpen,
      flip,
      showCloseButton,
      closeOnInteractOutside,
      autoFocus,
      isBrand,
      skipAnimation;
  final double maxWidth;
  @Deprecated('Use onOpenChange instead.')
  final SeedOverlayOpenChanged? onOpenChanged;
  SeedOverlayOpenChanged? get onOpenChange => onOpenChanged;
  final SeedOverlaySide side;
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
    maxWidth: maxWidth,
    autoFocus: autoFocus,
    closeOnInteractOutside: closeOnInteractOutside,
    enterScale: 0.9,
    exitScale: 1,
    enterCurve: SeedCurves.enter,
    exitCurve: SeedCurves.easing,
    scaleFromAnchor: true,
    enterDuration: SeedDuration.d4,
    exitDuration: SeedDuration.d4,
    skipAnimation: skipAnimation,
    overlayBuilder: (context) => SeedHelpBubble(
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

class SeedTooltipDelayGroup extends StatefulWidget {
  const SeedTooltipDelayGroup({
    super.key,
    required this.child,
    this.openDelay = const Duration(milliseconds: 200),
    this.closeDelay = const Duration(milliseconds: 100),
    this.skipDelay = const Duration(milliseconds: 800),
  });
  final Widget child;
  final Duration openDelay, closeDelay, skipDelay;
  @override
  State<SeedTooltipDelayGroup> createState() => _SeedTooltipDelayGroupState();
}

class _SeedTooltipDelayGroupState extends State<SeedTooltipDelayGroup> {
  DateTime? lastClose;
  SeedOverlayController? active;
  @override
  Widget build(BuildContext context) =>
      _SeedTooltipGroupScope(state: this, child: widget.child);
}

class _SeedTooltipGroupScope extends InheritedWidget {
  const _SeedTooltipGroupScope({required this.state, required super.child});
  final _SeedTooltipDelayGroupState state;
  @override
  bool updateShouldNotify(_SeedTooltipGroupScope oldWidget) =>
      state != oldWidget.state;
}

class SeedHelpBubbleTooltip extends StatefulWidget {
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
  final Widget child;
  final String title;
  final String? description;
  final bool? open;
  final ValueChanged<bool>? onOpenChange;
  final SeedOverlayOpenChanged? onOpenChanged;
  final Duration? openDelay, closeDelay;
  final SeedOverlaySide side;
  final SeedOverlayAlign align;
  final bool flip, keepOpenOnContentHover, isBrand;
  final double maxWidth;
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
    group = context
        .dependOnInheritedWidgetOfExactType<_SeedTooltipGroupScope>()
        ?.state;
  }

  void _request(bool open) {
    _timer?.cancel();
    final g = group;
    final skip =
        g?.lastClose != null &&
        DateTime.now().difference(g!.lastClose!) < g.widget.skipDelay;
    final delay = open
        ? (skip
              ? Duration.zero
              : widget.openDelay ??
                    g?.widget.openDelay ??
                    const Duration(milliseconds: 200))
        : widget.closeDelay ??
              g?.widget.closeDelay ??
              const Duration(milliseconds: 100);
    _timer = Timer(delay, () {
      if (!mounted || open == (widget.open ?? _controller.isOpen)) return;
      if (open) {
        g?.active?.close();
        if (g != null) g.active = _controller;
      } else if (g != null) {
        g.lastClose = DateTime.now();
      }
      widget.onOpenChange?.call(open);
      widget.onOpenChanged?.call(open, SeedOverlayDismissReason.trigger);
      if (widget.open == null) open ? _controller.open() : _controller.close();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (group?.active == _controller) {
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
      widget.onOpenChange?.call(open);
      widget.onOpenChanged?.call(open, reason);
    },
    triggerBuilder: (context, open, toggle) => MouseRegion(
      onEnter: (_) => _request(true),
      onExit: (_) => _request(false),
      child: Focus(
        canRequestFocus: false,
        onFocusChange: _request,
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
