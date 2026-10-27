import '../layout/seed_scroll_fog.dart';
import '../overlay/seed_anchored_overlay.dart';
import '../layout/seed_scroll_area.dart';

import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
import '../../foundations/motion/seed_motion.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';

/// Popover card container of SEED Design System.
///
/// Anchored overlay card featuring standard Header, Title, Description,
/// CloseButton (52px), Scrollable Body, and Footer/Action buttons.
class SeedPopover extends StatelessWidget {
  final Widget? title;
  final String? titleText;
  final Widget? description;
  final String? descriptionText;
  final Widget? body;
  final Widget? footer;
  final VoidCallback? onClose;
  final double minWidth;
  final double maxWidth;
  final double maxHeight;
  final bool scrollBody;
  final bool showScrollFog;
  final bool showCloseButton;

  const SeedPopover({
    super.key,
    this.title,
    this.titleText,
    this.description,
    this.descriptionText,
    this.body,
    this.footer,
    this.onClose,
    this.minWidth = 320.0,
    this.maxWidth = 480.0,
    this.maxHeight = 600.0,
    this.scrollBody = true,
    this.showScrollFog = true,
    this.showCloseButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;
    final shadows = context.seedShadows;
    final scope = SeedOverlayScope.maybeOf(context);
    final onClose =
        this.onClose ??
        (showCloseButton && scope != null
            ? () => scope.close(SeedOverlayDismissReason.closeButton)
            : null);

    final Widget? titleWidget =
        title ??
        (titleText != null
            ? Text(
                titleText!,
                style: typography.t7Bold.copyWith(color: colors.fg.neutral),
              )
            : null);

    final Widget? descriptionWidget =
        description ??
        (descriptionText != null
            ? Text(
                descriptionText!,
                style: typography.t4Regular.copyWith(
                  color: colors.fg.neutralMuted,
                ),
              )
            : null);

    final bool hasHeader =
        titleWidget != null || descriptionWidget != null || onClose != null;

    return Container(
      constraints: BoxConstraints(
        minWidth: minWidth,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      ),
      decoration: BoxDecoration(
        color: colors.bg.layerFloating,
        borderRadius: SeedBorderRadius.r5,
        boxShadow: shadows.s3,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasHeader)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                SeedDimension.x6,
                SeedDimension.x6,
                SeedDimension.x4,
                SeedDimension.x4,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ?titleWidget,
                        if (descriptionWidget != null) ...[
                          const SizedBox(height: SeedDimension.x1_5),
                          descriptionWidget,
                        ],
                      ],
                    ),
                  ),
                  if (onClose != null) ...[
                    const SizedBox(width: SeedDimension.x1_5),
                    SeedPressable(
                      semanticsLabel: '닫기',
                      focusBorderRadius: SeedBorderRadius.r3,
                      onTap: onClose,
                      builder: (context, isPressed) => AnimatedContainer(
                        duration: SeedDuration.colorTransition,
                        curve: SeedCurves.easing,
                        width: 52.0,
                        height: 52.0,
                        decoration: BoxDecoration(
                          color: isPressed
                              ? colors.bg.transparentPressed
                              : colors.bg.transparent,
                          borderRadius: SeedBorderRadius.r3,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.close_rounded,
                            size: 22.0,
                            color: colors.fg.neutralSubtle,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          if (body != null)
            Flexible(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  SeedDimension.x6,
                  0,
                  SeedDimension.x6,
                  footer != null ? 0 : SeedDimension.x12,
                ),
                child: scrollBody
                    ? SeedScrollArea(
                        placements: showScrollFog
                            ? const {SeedScrollFogPlacement.bottom}
                            : const {},
                        showScrolledDivider: true,
                        child: body!,
                      )
                    : body!,
              ),
            ),
          if (footer != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                SeedDimension.x6,
                SeedDimension.x4,
                SeedDimension.x6,
                SeedDimension.x6,
              ),
              child: footer!,
            ),
        ],
      ),
    );
  }
}

/// Helper function to show a [SeedPopover] anchored to a trigger target.
Future<T?> showSeedPopover<T>({
  required BuildContext context,
  required Rect anchorRect,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  return showDialog<T>(
    context: context,
    // Anchor rectangles use global coordinates. Apply safe-area bounds in the
    // layout delegate instead of offsetting the dialog's coordinate origin.
    useSafeArea: false,
    barrierDismissible: barrierDismissible,
    barrierColor: Colors.transparent,
    builder: (dialogContext) {
      final mediaQuery = MediaQuery.of(dialogContext);
      const overflowPadding = 16.0;
      final overlay =
          Navigator.of(dialogContext).overlay!.context.findRenderObject()!
              as RenderBox;
      final localAnchor =
          overlay.globalToLocal(anchorRect.topLeft) & anchorRect.size;

      return CustomSingleChildLayout(
        delegate: _SeedPopoverPositionDelegate(
          anchor: localAnchor,
          insets: EdgeInsets.fromLTRB(
            math.max(mediaQuery.padding.left, mediaQuery.viewInsets.left) +
                overflowPadding,
            math.max(mediaQuery.padding.top, mediaQuery.viewInsets.top) +
                overflowPadding,
            math.max(mediaQuery.padding.right, mediaQuery.viewInsets.right) +
                overflowPadding,
            math.max(mediaQuery.padding.bottom, mediaQuery.viewInsets.bottom) +
                overflowPadding,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: builder(dialogContext),
        ),
      );
    },
  );
}

class _SeedPopoverPositionDelegate extends SingleChildLayoutDelegate {
  const _SeedPopoverPositionDelegate({
    required this.anchor,
    required this.insets,
  });

  final Rect anchor;
  final EdgeInsets insets;
  static const _gutter = 8.0;

  Rect _bounds(Size size) => Rect.fromLTRB(
    math.min(insets.left, size.width),
    math.min(insets.top, size.height),
    math.max(math.min(insets.left, size.width), size.width - insets.right),
    math.max(math.min(insets.top, size.height), size.height - insets.bottom),
  );

  double _spaceBelow(Rect bounds) =>
      (bounds.bottom - anchor.bottom - _gutter).clamp(0.0, bounds.height);
  double _spaceAbove(Rect bounds) =>
      (anchor.top - _gutter - bounds.top).clamp(0.0, bounds.height);

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final bounds = _bounds(constraints.biggest);
    return BoxConstraints.loose(
      Size(bounds.width, math.max(_spaceBelow(bounds), _spaceAbove(bounds))),
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final bounds = _bounds(size);
    final below = _spaceBelow(bounds);
    final above = _spaceAbove(bounds);
    final placeBelow = childSize.height <= below || below >= above;
    return Offset(
      (anchor.center.dx - childSize.width / 2).clamp(
        bounds.left,
        bounds.right - childSize.width,
      ),
      (placeBelow
              ? anchor.bottom + _gutter
              : anchor.top - _gutter - childSize.height)
          .clamp(bounds.top, bounds.bottom - childSize.height),
    );
  }

  @override
  bool shouldRelayout(_SeedPopoverPositionDelegate oldDelegate) =>
      anchor != oldDelegate.anchor || insets != oldDelegate.insets;
}

/// Lifecycle-managed anchored popover. The card remains independently composable.
class SeedPopoverTrigger extends StatelessWidget {
  const SeedPopoverTrigger({
    super.key,
    required this.triggerBuilder,
    required this.builder,
    this.anchor,
    this.controller,
    this.open,
    this.defaultOpen = false,
    SeedOverlayOpenChanged? onOpenChange,
    SeedOverlayOpenChanged? onOpenChanged,
    this.side = SeedOverlaySide.bottom,
    this.align = SeedOverlayAlign.center,
    this.flip = true,
    this.autoFocus = true,
    this.closeOnInteractOutside = true,
    this.closeOnFocusOut = true,
    this.maxWidth = 480,
    this.maxHeight = 600,
  }) : onOpenChanged = onOpenChange ?? onOpenChanged,
       assert(onOpenChange == null || onOpenChanged == null);
  final Widget Function(BuildContext, bool, VoidCallback) triggerBuilder;
  final WidgetBuilder builder;
  final Widget? anchor;
  final SeedOverlayController? controller;
  final bool? open;
  final bool defaultOpen,
      flip,
      autoFocus,
      closeOnInteractOutside,
      closeOnFocusOut;
  final SeedOverlayOpenChanged? onOpenChanged;
  SeedOverlayOpenChanged? get onOpenChange => onOpenChanged;
  final SeedOverlaySide side;
  final SeedOverlayAlign align;
  final double maxWidth, maxHeight;
  @override
  Widget build(BuildContext context) => SeedAnchoredOverlay(
    triggerBuilder: triggerBuilder,
    overlayBuilder: builder,
    anchor: anchor,
    controller: controller,
    open: open,
    defaultOpen: defaultOpen,
    onOpenChanged: onOpenChanged,
    side: side,
    align: align,
    flip: flip,
    maxWidth: maxWidth,
    maxHeight: maxHeight,
    autoFocus: autoFocus,
    closeOnInteractOutside: closeOnInteractOutside,
    closeOnFocusOut: closeOnFocusOut,
  );
}
