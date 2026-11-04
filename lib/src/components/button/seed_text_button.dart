import 'package:material_ui/material_ui.dart';

import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
import '../../foundations/motion/seed_motion.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';

/// Text Button component of SEED Design System.
///
/// Features 36px height, 14px horizontal padding, 8px corner radius,
/// `t4Bold` typography in `fg.neutral-muted`, and `layerDefaultPressed` feedback.
class SeedTextButton extends StatelessWidget {
  /// Text shown in the button and used as the default accessible name.
  final String label;
  /// Invoked when activated; null disables the button.
  final VoidCallback? onPressed;
  /// Optional leading icon, sized to 16 logical pixels.
  final Widget? prefixIcon;
  /// Optional trailing icon, sized to 16 logical pixels.
  final Widget? suffixIcon;
  /// Whether user interaction is allowed; defaults to true.
  final bool enabled;
  /// Optional foreground override when the button is interactive.
  final Color? textColor;
  /// Accessible name override; defaults to [label].
  final String? semanticsLabel;

  /// Creates a text action with SEED text-button dimensions and feedback.
  ///
  /// [onPressed] is required syntactically but may be null to disable input.
  const SeedTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.textColor,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;
    final interactive = enabled && onPressed != null;

    final Color effectiveFg = !interactive
        ? colors.fg.disabled
        : (textColor ?? colors.fg.neutralMuted);

    return SeedPressable(
      enabled: interactive,
      semanticsLabel: semanticsLabel ?? label,
      focusBorderRadius: SeedBorderRadius.r2,
      onTap: onPressed,
      builder: (context, isPressed) => AnimatedContainer(
        duration: SeedDuration.colorTransition,
        curve: SeedCurves.easing,
        constraints: const BoxConstraints(minHeight: 36.0),
        padding: const EdgeInsets.symmetric(
          horizontal: SeedDimension.x3_5,
          vertical: SeedDimension.x2,
        ),
        decoration: BoxDecoration(
          color: isPressed
              ? colors.bg.layerDefaultPressed
              : colors.bg.transparent,
          borderRadius: SeedBorderRadius.r2,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (prefixIcon != null) ...[
              IconTheme(
                data: IconThemeData(size: 16.0, color: effectiveFg),
                child: prefixIcon!,
              ),
              const SizedBox(width: SeedDimension.x1),
            ],
            Text(label, style: typography.t4Bold.copyWith(color: effectiveFg)),
            if (suffixIcon != null) ...[
              const SizedBox(width: SeedDimension.x1),
              IconTheme(
                data: IconThemeData(size: 16.0, color: effectiveFg),
                child: suffixIcon!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
