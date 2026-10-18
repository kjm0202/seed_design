import 'package:material_ui/material_ui.dart';
import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
import '../../theme/seed_theme.dart';

/// Floating Action Button component of SEED Design System.
///
/// Prominently displays the screen's primary action floating above content.
class SeedFloatingActionButton extends StatelessWidget {
  final Widget icon;
  final String? label;
  final String? semanticsLabel;
  final VoidCallback onPressed;
  final bool isBrand;

  const SeedFloatingActionButton({
    super.key,
    this.semanticsLabel,
    required this.icon,
    this.label,
    required this.onPressed,
    this.isBrand = true,
  });

  const SeedFloatingActionButton.extended({
    super.key,
    this.semanticsLabel,
    required this.icon,
    required String this.label,
    required this.onPressed,
    this.isBrand = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;
    final shadows = context.seedShadows;

    final Color bgColor = isBrand ? colors.bg.brandSolid : colors.bg.neutralSolid;
    final Color fgColor = isBrand ? colors.fg.onBrandSolid : colors.fg.onNeutralSolid;

    return SeedPressable(
      semanticsLabel: semanticsLabel ?? label,
      onTap: onPressed,
      child: Container(
        width: label == null ? 52.0 : null,
        height: 52.0,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(
          horizontal: label != null ? SeedDimension.x5 : 0.0,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: SeedBorderRadius.full,
          boxShadow: shadows.s2,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconTheme(
              data: IconThemeData(color: fgColor, size: 22.0),
              child: icon,
            ),
            if (label != null) ...[
              const SizedBox(width: SeedDimension.x2),
              Text(
                label!,
                style: typography.t4Bold.copyWith(color: fgColor),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
