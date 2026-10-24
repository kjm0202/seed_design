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
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;
    final shadows = context.seedShadows;

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
                child: body!,
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
    barrierDismissible: barrierDismissible,
    barrierColor: Colors.transparent,
    builder: (dialogContext) {
      final mediaQuery = MediaQuery.of(dialogContext);
      final screenSize = mediaQuery.size;
      const overflowPadding = 16.0;
      const gutter = 8.0;

      // Vertical placement: preference below anchor, fallback above
      final spaceBelow =
          screenSize.height - anchorRect.bottom - gutter - overflowPadding;
      final spaceAbove = anchorRect.top - gutter - overflowPadding;

      final bool placeBelow = spaceBelow >= 200 || spaceBelow >= spaceAbove;
      final top = placeBelow
          ? (anchorRect.bottom + gutter).clamp(
              overflowPadding,
              screenSize.height - 100,
            )
          : (anchorRect.top - gutter - 300).clamp(
              overflowPadding,
              screenSize.height - 100,
            );

      // Horizontal placement: align to anchor left, bounded by screen
      final left = anchorRect.left.clamp(
        overflowPadding,
        (screenSize.width - 320 - overflowPadding).clamp(
          overflowPadding,
          double.infinity,
        ),
      );

      return Stack(
        children: [
          Positioned(
            left: left,
            top: top,
            child: Material(
              type: MaterialType.transparency,
              child: builder(dialogContext),
            ),
          ),
        ],
      );
    },
  );
}
