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
        return 32.0;
      case SeedChipSize.medium:
        return 36.0;
      case SeedChipSize.large:
        return 40.0;
    }
  }

  double get iconSize {
    switch (this) {
      case SeedChipSize.small:
        return 14.0;
      case SeedChipSize.medium:
        return 16.0;
      case SeedChipSize.large:
        return 16.0;
    }
  }

  double get suffixIconSize {
    switch (this) {
      case SeedChipSize.small:
        return 14.0;
      case SeedChipSize.medium:
        return 14.0;
      case SeedChipSize.large:
        return 16.0;
    }
  }

  double get rootPaddingX {
    switch (this) {
      case SeedChipSize.small:
        return SeedDimension.x1_5;
      case SeedChipSize.medium:
        return SeedDimension.x2;
      case SeedChipSize.large:
        return SeedDimension.x2_5;
    }
  }

  EdgeInsets get padding {
    switch (this) {
      case SeedChipSize.small:
        return const EdgeInsets.symmetric(horizontal: 12.0);
      case SeedChipSize.medium:
        return const EdgeInsets.symmetric(horizontal: 14.0);
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
        textStyle = typography.t4Medium;
        break;
      case SeedChipSize.medium:
        textStyle = typography.t4Medium;
        break;
      case SeedChipSize.large:
        textStyle = typography.t4Medium;
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

        return Opacity(
          opacity: enabled ? 1 : 0.5,
          child: AnimatedContainer(
            duration: SeedDuration.colorTransition,
            curve: SeedCurves.easing,
            constraints: BoxConstraints(
              minHeight: size.height,
              minWidth: switch (size) {
                SeedChipSize.small => 44,
                SeedChipSize.medium => 48,
                SeedChipSize.large => 52,
              },
            ),
            padding: EdgeInsets.only(
              left: prefix != null
                  ? size.rootPaddingX
                  : size.rootPaddingX + SeedDimension.x1_5,
              right: (suffix != null || onDeleted != null)
                  ? size.rootPaddingX
                  : size.rootPaddingX + SeedDimension.x1_5,
            ),
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
                  const SizedBox(width: SeedDimension.x1_5),
                ],
                Text(
                  label,
                  style: textStyle.copyWith(color: fgColor),
                  maxLines: 1,
                ),
                if (onDeleted != null) ...[
                  const SizedBox(width: SeedDimension.x1_5),
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
                          size: size.suffixIconSize,
                          color: fgColor,
                        ),
                      ),
                    ),
                  ),
                ] else if (suffix != null) ...[
                  const SizedBox(width: SeedDimension.x1_5),
                  IconTheme(
                    data: IconThemeData(color: fgColor, size: size.suffixIconSize),
                    child: suffix!,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  (Color bg, Color fg, Color? stroke) _resolveColors({
    required SeedColorScheme colors,
    required bool isPressed,
  }) {
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
            isPressed
                ? colors.bg.neutralWeakAlphaPressed
                : colors.bg.neutralWeakAlpha,
            colors.fg.neutral,
            null,
          );
        }

      case SeedChipVariant.outlineStrong:
        if (selected) {
          return (
            isPressed ? colors.bg.neutralSolidPressed : colors.bg.neutralSolid,
            colors.fg.onNeutralSolid,
            null,
          );
        } else {
          return (
            isPressed ? colors.bg.transparentPressed : colors.bg.transparent,
            colors.fg.neutral,
            colors.stroke.neutralMuted,
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
            isPressed ? colors.bg.transparentPressed : colors.bg.transparent,
            colors.fg.neutral,
            colors.stroke.neutralMuted,
          );
        }
    }
  }
}
