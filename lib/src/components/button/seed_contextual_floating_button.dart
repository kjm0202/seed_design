import 'package:material_ui/material_ui.dart';
import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
import '../../theme/seed_theme.dart';
import '../feedback/seed_progress_circle.dart';

/// Style tone for [SeedContextualFloatingButton].
enum SeedContextualFloatingButtonTone {
  solid,
  layer,
}

/// Contextual Floating Button component of SEED Design System.
///
/// A secondary floating button dynamically appearing above screen content
/// based on context (e.g. "새 글 5개 보기 ↑", "맨 위로").
class SeedContextualFloatingButton extends StatelessWidget {
  final Widget? icon;
  final String? label;
  final String? semanticsLabel;
  final VoidCallback onPressed;
  final SeedContextualFloatingButtonTone tone;
  final bool isBrand;
  final bool loading;
  final bool enabled;

  const SeedContextualFloatingButton({
    super.key,
    this.semanticsLabel,
    this.icon,
    this.label,
    required this.onPressed,
    this.tone = SeedContextualFloatingButtonTone.layer,
    this.isBrand = false,
    this.loading = false,
    this.enabled = true,
  }) : assert(icon != null || label != null, 'Must provide icon or label.');

  const SeedContextualFloatingButton.iconOnly({
    super.key,
    this.semanticsLabel,
    required Widget this.icon,
    required this.onPressed,
    this.tone = SeedContextualFloatingButtonTone.layer,
    this.isBrand = false,
    this.loading = false,
    this.enabled = true,
  }) : label = null;

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;
    final shadows = context.seedShadows;

    Color bgColor;
    Color fgColor;
    Border? border;

    if (!enabled) {
      bgColor = colors.bg.disabled;
      fgColor = colors.fg.disabled;
    } else if (tone == SeedContextualFloatingButtonTone.solid) {
      bgColor = isBrand ? colors.bg.brandSolid : colors.bg.neutralSolid;
      fgColor = isBrand ? colors.fg.onBrandSolid : colors.fg.onNeutralSolid;
    } else {
      // Layer
      bgColor = colors.bg.layerFloating;
      fgColor = isBrand ? colors.fg.brand : colors.fg.neutral;
      border = Border.all(color: colors.stroke.neutralWeak, width: 1.0);
    }

    final TextStyle textStyle = typography.t3Bold.copyWith(color: fgColor);

    return SeedPressable(
      semanticsLabel: semanticsLabel ?? label,
      enabled: enabled && !loading,
      onTap: onPressed,
      child: Container(
        height: 40.0,
        constraints: BoxConstraints(
          minWidth: label == null ? 40.0 : 0.0,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: label == null ? SeedDimension.x2 : SeedDimension.x4,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: SeedBorderRadius.full,
          border: border,
          boxShadow: shadows.s2,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (loading) ...[
              SeedProgressCircle(size: 16.0, color: fgColor),
            ] else if (icon != null) ...[
              IconTheme(
                data: IconThemeData(color: fgColor, size: 18.0),
                child: icon!,
              ),
            ],
            if (label != null) ...[
              if (icon != null || loading) const SizedBox(width: SeedDimension.x1_5),
              Text(label!, style: textStyle),
            ],
          ],
        ),
      ),
    );
  }
}
