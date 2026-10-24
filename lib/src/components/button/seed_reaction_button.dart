import 'package:material_ui/material_ui.dart';

import '../../foundations/colors/seed_palette.dart';
import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
import '../../theme/seed_theme.dart';
import '../feedback/seed_progress_circle.dart';

/// Size options for [SeedReactionButton].
enum SeedReactionButtonSize {
  xsmall,
  small;

  double get height => this == SeedReactionButtonSize.xsmall ? 32.0 : 36.0;
  double get iconSize => 18.0;
}

/// Reaction button component of SEED Design System.
///
/// Used for expressing emotional feedback (like, interest) with count and active state.
class SeedReactionButton extends StatelessWidget {
  final bool isReacted;
  final int count;
  final String? label;
  final ValueChanged<bool>? onReactedChanged;
  final Widget? prefixIcon;
  final SeedReactionButtonSize size;
  final bool loading;
  final bool enabled;
  final String semanticsLabel;

  const SeedReactionButton({
    super.key,
    this.isReacted = false,
    this.count = 0,
    this.label,
    this.onReactedChanged,
    this.prefixIcon,
    this.size = SeedReactionButtonSize.small,
    this.loading = false,
    this.enabled = true,
    this.semanticsLabel = '관심',
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;

    final Color bgColor = !enabled
        ? colors.bg.disabled
        : (loading
              ? (isReacted
                    ? colors.bg.transparentPressed
                    : colors.bg.neutralWeakPressed)
              : colors.bg.transparent);

    final Color fgColor = !enabled
        ? colors.fg.disabled
        : (isReacted ? colors.fg.brand : colors.fg.neutral);

    final TextStyle labelStyle = typography.t3Medium.copyWith(color: fgColor);
    final TextStyle countStyle = typography.t3Bold.copyWith(color: fgColor);

    return SeedPressable(
      enabled: enabled && !loading && onReactedChanged != null,
      toggled: isReacted,
      semanticsLabel: semanticsLabel,
      semanticsValue: '$count',
      onTap: () => onReactedChanged?.call(!isReacted),
      builder: (context, isPressed) => Container(
        constraints: BoxConstraints(minHeight: size.height),
        padding: EdgeInsets.symmetric(
          horizontal: size == SeedReactionButtonSize.xsmall
              ? SeedDimension.x3
              : SeedDimension.x3_5,
          vertical: size == SeedReactionButtonSize.xsmall
              ? SeedDimension.x1_5
              : SeedDimension.x2,
        ),
        decoration: BoxDecoration(
          color: enabled && isPressed ? colors.bg.transparentPressed : bgColor,
          borderRadius: SeedBorderRadius.full,
          border: enabled
              ? Border.all(
                  color: isReacted
                      ? colors.stroke.brandWeak
                      : colors.stroke.neutralMuted,
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (loading)
              SeedProgressCircle(
                size: 14,
                strokeWidth: 2,
                color: fgColor,
                trackColor: isReacted
                    ? (colors.isDark
                        ? SeedPalette.carrot200Dark
                        : SeedPalette.carrot200Light)
                    : (colors.isDark
                        ? SeedPalette.gray500Dark
                        : SeedPalette.gray500Light),
              )
            else
              IconTheme(
                data: IconThemeData(size: size.iconSize, color: fgColor),
                child:
                    prefixIcon ??
                    Icon(
                      isReacted
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: size.iconSize,
                      color: fgColor,
                    ),
              ),
            if (label != null) ...[
              const SizedBox(width: SeedDimension.x1),
              Text(label!, style: labelStyle),
            ],
            if (count > 0) ...[
              const SizedBox(width: SeedDimension.x1),
              Text('$count', style: countStyle),
            ],
          ],
        ),
      ),
    );
  }
}
