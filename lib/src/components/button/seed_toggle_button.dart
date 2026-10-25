import 'package:material_ui/material_ui.dart';

import '../../foundations/colors/seed_color_scheme.dart';
import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
import '../../foundations/motion/seed_motion.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';
import '../feedback/seed_progress_circle.dart';

/// Variant options for [SeedToggleButton].
enum SeedToggleButtonVariant {
  brandSolid,
  neutralWeak,
}

/// Size options for [SeedToggleButton].
enum SeedToggleButtonSize {
  xsmall,
  small;

  double get height => this == SeedToggleButtonSize.xsmall ? 32.0 : 36.0;

  double get iconSize => 14.0;

  EdgeInsets get padding {
    switch (this) {
      case SeedToggleButtonSize.xsmall:
        return const EdgeInsets.symmetric(
          horizontal: SeedDimension.x3_5,
          vertical: SeedDimension.x1_5,
        );
      case SeedToggleButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: SeedDimension.x4,
          vertical: SeedDimension.x2,
        );
    }
  }
}

/// Toggle Button component of SEED Design System.
///
/// Supports state toggle (`pressed` / `selected`), `brandSolid` and `neutralWeak`
/// variants, `xsmall` and `small` sizes, loading state, and native scale feedback.
class SeedToggleButton extends StatelessWidget {
  final bool selected;
  final ValueChanged<bool>? onSelectedChanged;
  final String? label;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final SeedToggleButtonVariant variant;
  final SeedToggleButtonSize size;
  final bool loading;
  final bool enabled;
  final String? semanticsLabel;

  const SeedToggleButton({
    super.key,
    required this.selected,
    required this.onSelectedChanged,
    this.label,
    this.prefixIcon,
    this.suffixIcon,
    this.variant = SeedToggleButtonVariant.brandSolid,
    this.size = SeedToggleButtonSize.small,
    this.loading = false,
    this.enabled = true,
    this.semanticsLabel,
  }) : assert(
         label != null || prefixIcon != null,
         'Either label or prefixIcon must be specified.',
       );

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;

    final TextStyle textStyle =
        (size == SeedToggleButtonSize.xsmall
                ? typography.t3Bold
                : typography.t4Bold);

    return SeedPressable(
      enabled: enabled && !loading && onSelectedChanged != null,
      toggled: selected,
      semanticsLabel: semanticsLabel ?? label,
      onTap: () => onSelectedChanged?.call(!selected),
      builder: (context, isPressed) {
        final (bgColor, fgColor) = _resolveColors(
          colors: colors,
          isPressed: isPressed || loading,
          selected: selected,
          enabled: enabled,
        );

        final content = Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (loading) ...[
              SeedProgressCircle(
                size: 14,
                strokeWidth: 2,
                color: fgColor,
              ),
              if (label != null) const SizedBox(width: SeedDimension.x1),
            ] else if (prefixIcon != null) ...[
              IconTheme(
                data: IconThemeData(
                  color: fgColor,
                  size: size.iconSize,
                ),
                child: prefixIcon!,
              ),
              if (label != null) const SizedBox(width: SeedDimension.x1),
            ],
            if (label != null)
              Text(
                label!,
                style: textStyle.copyWith(color: fgColor),
              ),
            if (suffixIcon != null && !loading) ...[
              const SizedBox(width: SeedDimension.x1),
              IconTheme(
                data: IconThemeData(
                  color: fgColor,
                  size: size.iconSize,
                ),
                child: suffixIcon!,
              ),
            ],
          ],
        );

        return AnimatedContainer(
          duration: SeedDuration.colorTransition,
          curve: SeedCurves.easing,
          constraints: BoxConstraints(minHeight: size.height),
          padding: size.padding,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: SeedBorderRadius.full,
          ),
          child: content,
        );
      },
    );
  }

  (Color bg, Color fg) _resolveColors({
    required SeedColorScheme colors,
    required bool isPressed,
    required bool selected,
    required bool enabled,
  }) {
    if (!enabled) {
      return (colors.bg.disabled, colors.fg.disabled);
    }

    switch (variant) {
      case SeedToggleButtonVariant.brandSolid:
        if (selected) {
          return (
            isPressed
                ? colors.bg.neutralWeakPressed
                : colors.bg.neutralWeak,
            colors.fg.neutral,
          );
        } else {
          return (
            isPressed
                ? colors.bg.brandSolidPressed
                : colors.bg.brandSolid,
            colors.fg.onBrandSolid,
          );
        }
      case SeedToggleButtonVariant.neutralWeak:
        return (
          isPressed
              ? colors.bg.neutralWeakPressed
              : colors.bg.neutralWeak,
          colors.fg.neutral,
        );
    }
  }
}
