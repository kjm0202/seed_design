import 'package:material_ui/material_ui.dart';

import '../../foundations/colors/seed_color_scheme.dart';
import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/motion/seed_motion.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
import '../../theme/seed_theme.dart';

/// Variant options for [SeedChip].
enum SeedChipVariant { solid, outlineStrong, outlineWeak }

/// Size options for [SeedChip].
enum SeedChipSize {
  small,
  medium,
  large;

  double get height {
    switch (this) {
      case SeedChipSize.small:
        return 28.0;
      case SeedChipSize.medium:
        return 36.0;
      case SeedChipSize.large:
        return 44.0;
    }
  }

  double get iconSize {
    switch (this) {
      case SeedChipSize.small:
        return 14.0;
      case SeedChipSize.medium:
        return 16.0;
      case SeedChipSize.large:
        return 18.0;
    }
  }

  EdgeInsets get padding {
    switch (this) {
      case SeedChipSize.small:
        return const EdgeInsets.symmetric(horizontal: 10.0);
      case SeedChipSize.medium:
        return const EdgeInsets.symmetric(horizontal: 12.0);
      case SeedChipSize.large:
        return const EdgeInsets.symmetric(horizontal: 16.0);
    }
  }

  BorderRadius get borderRadius => SeedBorderRadius.full;
}

/// Chip component of SEED Design System.
///
/// Used for filtering, suggestions, selections, and user input tags.
class SeedChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final VoidCallback? onPressed;
  final VoidCallback? onDeleted;
  final Widget? prefix;
  final Widget? suffix;
  final SeedChipVariant variant;
  final SeedChipSize size;
  final bool enabled;

  const SeedChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onSelected,
    this.onPressed,
    this.onDeleted,
    this.prefix,
    this.suffix,
    this.variant = SeedChipVariant.outlineWeak,
    this.size = SeedChipSize.medium,
    this.enabled = true,
  });

  bool get _isClickable => enabled && (onSelected != null || onPressed != null);

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;

    TextStyle textStyle;
    switch (size) {
      case SeedChipSize.small:
        textStyle = selected ? typography.t2Bold : typography.t2Medium;
        break;
      case SeedChipSize.medium:
        textStyle = selected ? typography.t3Bold : typography.t3Medium;
        break;
      case SeedChipSize.large:
        textStyle = selected ? typography.t4Bold : typography.t4Medium;
        break;
    }

    return SeedPressable(
      enabled: _isClickable,
      selected: onSelected != null ? selected : null,
      onTap: () {
        if (onSelected != null) {
          onSelected!(!selected);
        } else if (onPressed != null) {
          onPressed!();
        }
      },
      builder: (context, isPressed) {
        final (bgColor, fgColor, strokeColor) = _resolveColors(
          colors: colors,
          isPressed: isPressed,
        );

        return AnimatedContainer(
          duration: SeedDuration.colorTransition,
          curve: SeedCurves.easing,
          height: size.height,
          padding: size.padding,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: size.borderRadius,
            border: strokeColor != null
                ? Border.all(color: strokeColor, width: 1.0)
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (prefix != null) ...[
                IconTheme(
                  data: IconThemeData(color: fgColor, size: size.iconSize),
                  child: prefix!,
                ),
                const SizedBox(width: SeedDimension.x1),
              ],
              Text(
                label,
                style: textStyle.copyWith(color: fgColor),
                maxLines: 1,
              ),
              if (onDeleted != null) ...[
                const SizedBox(width: SeedDimension.x1),
                SeedPressable(
                  semanticsLabel: '$label 삭제',
                  enableScale: false,
                  behavior: HitTestBehavior.opaque,
                  onTap: enabled ? onDeleted : null,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                    child: Center(
                      widthFactor: 1,
                      heightFactor: 1,
                      child: Icon(
                        Icons.close_rounded,
                        size: size.iconSize,
                        color: fgColor,
                      ),
                    ),
                  ),
                ),
              ] else if (suffix != null) ...[
                const SizedBox(width: SeedDimension.x1),
                IconTheme(
                  data: IconThemeData(color: fgColor, size: size.iconSize),
                  child: suffix!,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  (Color bg, Color fg, Color? stroke) _resolveColors({
    required SeedColorScheme colors,
    required bool isPressed,
  }) {
    if (!enabled) {
      return (
        variant == SeedChipVariant.solid
            ? colors.bg.disabled
            : colors.bg.transparent,
        colors.fg.disabled,
        variant != SeedChipVariant.solid ? colors.stroke.neutralWeak : null,
      );
    }

    switch (variant) {
      case SeedChipVariant.solid:
        if (selected) {
          return (
            isPressed ? colors.bg.neutralSolidPressed : colors.bg.neutralSolid,
            colors.fg.onNeutralSolid,
            null,
          );
        } else {
          return (
            isPressed ? colors.bg.neutralWeakPressed : colors.bg.neutralWeak,
            colors.fg.neutral,
            null,
          );
        }

      case SeedChipVariant.outlineStrong:
        if (selected) {
          return (
            isPressed ? colors.bg.brandWeakPressed : colors.bg.brandWeak,
            colors.fg.brand,
            colors.stroke.brandSolid,
          );
        } else {
          return (
            isPressed ? colors.bg.neutralWeakPressed : colors.bg.transparent,
            colors.fg.neutral,
            colors.stroke.neutralSolid,
          );
        }

      case SeedChipVariant.outlineWeak:
        if (selected) {
          return (
            isPressed ? colors.bg.neutralWeakPressed : colors.bg.neutralWeak,
            colors.fg.neutral,
            colors.stroke.neutralContrast,
          );
        } else {
          return (
            isPressed ? colors.bg.neutralWeakPressed : colors.bg.transparent,
            colors.fg.neutral,
            colors.stroke.neutralWeak,
          );
        }
    }
  }
}
