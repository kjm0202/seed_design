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

    final Color bgColor = isBrand
        ? colors.bg.brandSolid
        : colors.bg.neutralSolid;
    final Color fgColor = isBrand
        ? colors.fg.onBrandSolid
        : colors.fg.onNeutralSolid;

    return SeedPressable(
      semanticsLabel: semanticsLabel ?? label,
      onTap: onPressed,
      builder: (context, isPressed) => Container(
        constraints: label == null
            ? const BoxConstraints.tightFor(width: 56.0, height: 56.0)
            : const BoxConstraints(minHeight: 48.0),
        alignment: Alignment.center,
        padding: label != null
            ? const EdgeInsets.symmetric(
                horizontal: SeedDimension.x4_5,
                vertical: SeedDimension.x3,
              )
            : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: isPressed
              ? (isBrand
                    ? colors.bg.brandSolidPressed
                    : colors.bg.neutralSolidPressed)
              : bgColor,
          borderRadius: SeedBorderRadius.full,
          boxShadow: shadows.s3,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconTheme(
              data: IconThemeData(
                color: fgColor,
                size: label == null ? 24 : 16,
              ),
              child: icon,
            ),
            if (label != null) ...[
              const SizedBox(width: SeedDimension.x1),
              Text(label!, style: typography.t5Bold.copyWith(color: fgColor)),
            ],
          ],
        ),
      ),
    );
  }
}
