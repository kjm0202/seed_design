import 'package:material_ui/material_ui.dart';

import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/motion/seed_motion.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
import '../../theme/seed_theme.dart';
import '../layout/seed_divider.dart';

/// Vertical alignment for prefix and suffix in [SeedListItem].
enum SeedListItemAlign { center, top }

/// List Item component of SEED Design System.
///
/// Features prefix slot (avatar/icon), title, detail (subtitle),
/// suffix slot (chevron, switch, badge), highlighted state,
/// and pressed feedback.
class SeedListItem extends StatelessWidget {
  final Widget? title;
  final String? titleText;
  final Widget? detail;
  final String? detailText;
  final Widget? prefix;
  final Widget? suffix;
  final SeedListItemAlign align;
  final bool highlighted;
  final bool enabled;
  final bool showDivider;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  const SeedListItem({
    super.key,
    this.title,
    this.titleText,
    this.detail,
    this.detailText,
    this.prefix,
    this.suffix,
    this.align = SeedListItemAlign.center,
    this.highlighted = false,
    this.enabled = true,
    this.showDivider = true,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(
      horizontal: SeedDimension.x4,
      vertical: SeedDimension.x3,
    ),
  }) : assert(
         title == null || titleText == null,
         'Cannot provide both title and titleText',
       );

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;

    final Widget titleWidget =
        title ??
        Text(
          titleText ?? '',
          style: typography.t5Regular.copyWith(
            color: enabled ? colors.fg.neutral : colors.fg.disabled,
          ),
        );

    final Widget? detailWidget =
        detail ??
        (detailText != null
            ? Text(
                detailText!,
                style: typography.t3Regular.copyWith(
                  color: enabled ? colors.fg.neutralSubtle : colors.fg.disabled,
                ),
              )
            : null);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SeedPressable(
          enabled: enabled && onTap != null,
          enableScale: false, // In SEED list items, background pressed color is used without root scale distortion
          onTap: onTap,
          builder: (context, isPressed) {
            Color bgColor = colors.bg.transparent;
            if (highlighted) {
              bgColor = colors.bg.brandWeak;
            }
            if (isPressed) {
              bgColor = highlighted
                  ? colors.bg.brandWeakPressed
                  : colors.bg.transparentPressed;
            }

            return AnimatedContainer(
              duration: SeedDuration.colorTransition,
              curve: SeedCurves.easing,
              color: bgColor,
              padding: padding,
              child: Row(
                crossAxisAlignment: align == SeedListItemAlign.center
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                children: [
                  if (prefix != null) ...[
                    prefix!,
                    const SizedBox(width: SeedDimension.x3),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        titleWidget,
                        if (detailWidget != null) ...[
                          const SizedBox(height: SeedDimension.x0_5),
                          detailWidget,
                        ],
                      ],
                    ),
                  ),
                  if (suffix != null) ...[
                    const SizedBox(width: SeedDimension.x3),
                    suffix!,
                  ],
                ],
              ),
            );
          },
        ),
        if (showDivider) const SeedDivider(),
      ],
    );
  }
}

/// Container that groups multiple [SeedListItem] items with optional dividers.
class SeedList extends StatelessWidget {
  final List<Widget> children;
  final bool showDividers;

  const SeedList({super.key, required this.children, this.showDividers = true});

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;

    return Container(
      color: colors.bg.layerDefault,
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}
