import 'package:material_ui/material_ui.dart';

import '../../foundations/colors/seed_palette.dart';
import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
import '../../foundations/motion/seed_motion.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';

/// Tone options for top navigation buttons.
enum SeedTopNavigationButtonTone { layer, transparent }

/// Dedicated icon button for top navigation bars adhering to SEED Design.
///
/// Features 44x44px touch area, 8px corner radius, 24px icon,
/// `bg.transparent-pressed` and self-scale tactile feedback.
class SeedTopNavigationIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback? onPressed;
  final SeedTopNavigationButtonTone tone;
  final bool enabled;
  final String? semanticsLabel;

  const SeedTopNavigationIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tone = SeedTopNavigationButtonTone.layer,
    this.enabled = true,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final interactive = enabled && onPressed != null;

    final Color iconColor = !interactive
        ? colors.fg.disabled
        : (tone == SeedTopNavigationButtonTone.layer
              ? colors.fg.neutral
              : SeedPalette.staticWhite);

    return SeedPressable(
      enabled: interactive,
      semanticsLabel: semanticsLabel,
      focusBorderRadius: SeedBorderRadius.r2,
      onTap: onPressed,
      builder: (context, isPressed) => AnimatedContainer(
        duration: SeedDuration.colorTransition,
        curve: SeedCurves.easing,
        width: 44.0,
        height: 44.0,
        decoration: BoxDecoration(
          color: isPressed
              ? colors.bg.transparentPressed
              : colors.bg.transparent,
          borderRadius: SeedBorderRadius.r2,
        ),
        child: Center(
          child: IconTheme(
            data: IconThemeData(size: 24.0, color: iconColor),
            child: icon,
          ),
        ),
      ),
    );
  }
}

/// Dedicated text button for top navigation bars adhering to SEED Design.
///
/// Features 44px height, 10px horizontal padding, 8px corner radius,
/// `t5Medium` typography, and `bg.transparent-pressed` feedback.
class SeedTopNavigationTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final SeedTopNavigationButtonTone tone;
  final bool enabled;
  final double? maxWidth;

  const SeedTopNavigationTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.tone = SeedTopNavigationButtonTone.layer,
    this.enabled = true,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;
    final interactive = enabled && onPressed != null;

    final Color labelColor = !interactive
        ? colors.fg.disabled
        : (tone == SeedTopNavigationButtonTone.layer
              ? colors.fg.neutral
              : SeedPalette.staticWhite);

    final textWidget = Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textScaler: const TextScaler.linear(1.0)
          .clamp(minScaleFactor: 1.0, maxScaleFactor: 1.2),
      style: typography.t5Medium.copyWith(color: labelColor),
    );

    return SeedPressable(
      enabled: interactive,
      semanticsLabel: text,
      focusBorderRadius: SeedBorderRadius.r2,
      onTap: onPressed,
      builder: (context, isPressed) => AnimatedContainer(
        duration: SeedDuration.colorTransition,
        curve: SeedCurves.easing,
        constraints: BoxConstraints(
          minHeight: 44.0,
          maxWidth: maxWidth ?? double.infinity,
        ),
        padding: const EdgeInsets.symmetric(horizontal: SeedDimension.x2_5),
        decoration: BoxDecoration(
          color: isPressed
              ? colors.bg.transparentPressed
              : colors.bg.transparent,
          borderRadius: SeedBorderRadius.r2,
        ),
        alignment: Alignment.center,
        child: textWidget,
      ),
    );
  }
}
