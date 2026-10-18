import 'package:material_ui/material_ui.dart';
import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
import '../../theme/seed_theme.dart';
import '../feedback/seed_progress_circle.dart';

/// Size options for [SeedReactionButton].
enum SeedReactionButtonSize {
  xsmall,
  small;

  double get height => this == SeedReactionButtonSize.xsmall ? 28.0 : 36.0;
  double get iconSize => this == SeedReactionButtonSize.xsmall ? 14.0 : 16.0;
}

/// Reaction button component of SEED Design System.
///
/// Used for expressing emotional feedback (like, interest) with count and active state.
class SeedReactionButton extends StatelessWidget {
  final bool isReacted;
  final int count;
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
        : (isReacted ? colors.bg.brandWeak : colors.bg.neutralWeak);

    final Color fgColor = !enabled
        ? colors.fg.disabled
        : (isReacted ? colors.fg.brand : colors.fg.neutral);

    final TextStyle textStyle = (size == SeedReactionButtonSize.xsmall
            ? typography.t2Bold
            : typography.t3Bold)
        .copyWith(color: fgColor);

    return SeedPressable(
      enabled: enabled && !loading && onReactedChanged != null,
      toggled: isReacted,
      semanticsLabel: semanticsLabel,
      semanticsValue: '$count',
      onTap: () => onReactedChanged?.call(!isReacted),
      child: Container(
        height: size.height,
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: SeedBorderRadius.full,
          border: isReacted
              ? Border.all(color: colors.stroke.brandWeak, width: 1.0)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (loading)
              SeedProgressCircle(size: size.iconSize, color: fgColor)
            else
              prefixIcon ??
                  Icon(
                    isReacted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    size: size.iconSize,
                    color: fgColor,
                  ),
            if (count > 0) ...[
              const SizedBox(width: SeedDimension.x1),
              Text('$count', style: textStyle),
            ],
          ],
        ),
      ),
    );
  }
}
