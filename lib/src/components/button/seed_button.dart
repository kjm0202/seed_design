import 'package:material_ui/material_ui.dart';

import '../../foundations/colors/seed_color_scheme.dart';
import '../../foundations/colors/seed_palette.dart';
import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
import '../../foundations/motion/seed_motion.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';
import '../feedback/seed_progress_circle.dart';

/// Variant options for [SeedButton] / [SeedActionButton].
enum SeedButtonVariant {
  brandSolid,
  neutralSolid,
  neutralWeak,
  brandOutline,
  neutralOutline,
  criticalSolid,
  ghost,
}

/// Size options for [SeedButton] / [SeedActionButton].
enum SeedButtonSize {
  xsmall,
  small,
  medium,
  large;

  double get height {
    switch (this) {
      case SeedButtonSize.xsmall:
        return 32.0;
      case SeedButtonSize.small:
        return 36.0;
      case SeedButtonSize.medium:
        return 40.0;
      case SeedButtonSize.large:
        return 52.0;
    }
  }

  /// Icon size for icon-only buttons as defined by SEED Design.
  double get iconOnlySize {
    switch (this) {
      case SeedButtonSize.xsmall:
        return 14.0;
      case SeedButtonSize.small:
        return 16.0;
      case SeedButtonSize.medium:
        return 18.0;
      case SeedButtonSize.large:
        return 22.0;
    }
  }

  /// Icon size for buttons with text as defined by SEED Design Rootage.
  double get withTextIconSize {
    switch (this) {
      case SeedButtonSize.xsmall:
        return 14.0;
      case SeedButtonSize.small:
        return 14.0;
      case SeedButtonSize.medium:
        return 16.0;
      case SeedButtonSize.large:
        return 22.0;
    }
  }

  /// Default icon size (defaults to [iconOnlySize] for backward compatibility).
  double get iconSize => iconOnlySize;

  EdgeInsets get padding {
    switch (this) {
      case SeedButtonSize.xsmall:
        return const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0);
      case SeedButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0);
      case SeedButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0);
      case SeedButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0);
    }
  }

  BorderRadius get borderRadius {
    switch (this) {
      case SeedButtonSize.xsmall:
        return SeedBorderRadius.full;
      case SeedButtonSize.small:
        return SeedBorderRadius.r2;
      case SeedButtonSize.medium:
        return SeedBorderRadius.r2;
      case SeedButtonSize.large:
        return SeedBorderRadius.r3;
    }
  }
}

/// Action Button component of SEED Design System.
///
/// Supports all 7 standard variants, 4 sizes, prefix/suffix icons,
/// loading state, and native SEED physical scale feedback.
class SeedButton extends StatelessWidget {
  final String? label;
  final Widget? icon;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onPressed;
  final SeedButtonVariant variant;
  final SeedButtonSize size;
  final bool isFullWidth;
  final bool loading;
  final bool enabled;
  final bool disableOnLoading;
  final bool bleed;
  final Color? textColor;
  final FontWeight? fontWeight;
  final String? semanticsLabel;
  final FocusNode? focusNode;
  final bool autofocus;

  const SeedButton({
    super.key,
    this.label,
    this.icon,
    this.prefixIcon,
    this.suffixIcon,
    required this.onPressed,
    this.variant = SeedButtonVariant.brandSolid,
    this.size = SeedButtonSize.medium,
    this.isFullWidth = false,
    this.loading = false,
    this.enabled = true,
    this.disableOnLoading = true,
    this.bleed = false,
    this.textColor,
    this.fontWeight,
    this.semanticsLabel,
    this.focusNode,
    this.autofocus = false,
  }) : assert(
         label != null || icon != null,
         'Either label or icon must be specified.',
       );

  /// Factory for Icon-Only button.
  const SeedButton.iconOnly({
    super.key,
    required Widget this.icon,
    required this.onPressed,
    this.variant = SeedButtonVariant.brandSolid,
    this.size = SeedButtonSize.medium,
    this.loading = false,
    this.enabled = true,
    this.disableOnLoading = true,
    this.bleed = false,
    this.textColor,
    this.fontWeight,
    this.semanticsLabel,
    this.focusNode,
    this.autofocus = false,
  }) : label = null,
       prefixIcon = null,
       suffixIcon = null,
       isFullWidth = false;

  bool get _effectiveEnabled =>
      enabled && (!disableOnLoading || !loading) && onPressed != null;

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;

    TextStyle textStyle;
    switch (size) {
      case SeedButtonSize.xsmall:
        textStyle = typography.t3Bold;
        break;
      case SeedButtonSize.small:
        textStyle = typography.t4Bold;
        break;
      case SeedButtonSize.medium:
        textStyle = typography.t4Bold;
        break;
      case SeedButtonSize.large:
        textStyle = typography.t6Bold;
        break;
    }

    if (fontWeight != null) {
      textStyle = textStyle.copyWith(fontWeight: fontWeight);
    }

    return SeedPressable(
      enabled: _effectiveEnabled,
      semanticsLabel: semanticsLabel ?? label,
      focusNode: focusNode,
      autofocus: autofocus,
      focusBorderRadius: size.borderRadius,
      onTap: _effectiveEnabled ? onPressed : null,
      builder: (context, isPressed) {
        final (bgColor, fgColor, strokeColor) = _resolveColors(
          colors: colors,
          isPressed:
              isPressed ||
              (loading &&
                  variant != SeedButtonVariant.brandOutline &&
                  variant != SeedButtonVariant.neutralOutline),
          enabled: enabled && (onPressed != null || loading),
        );

        final effectiveFg = textColor ?? fgColor;
        final isIconOnly = icon != null && label == null;
        final normalContent = _buildContent(effectiveFg, textStyle);
        final content = Stack(
          alignment: Alignment.center,
          children: [
            Visibility(
              visible: !loading,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: normalContent,
            ),
            if (loading)
              SeedProgressCircle(
                size: switch (size) {
                  SeedButtonSize.xsmall || SeedButtonSize.small => 14,
                  SeedButtonSize.medium => 16,
                  SeedButtonSize.large => 18,
                },
                strokeWidth: 2,
                color: effectiveFg,
                trackColor: switch (variant) {
                  SeedButtonVariant.brandSolid ||
                  SeedButtonVariant.neutralSolid ||
                  SeedButtonVariant.criticalSolid =>
                    SeedPalette.staticWhiteAlpha300,
                  SeedButtonVariant.brandOutline =>
                    colors.isDark
                        ? SeedPalette.carrot200Dark
                        : SeedPalette.carrot200Light,
                  _ =>
                    colors.isDark
                        ? SeedPalette.gray500Dark
                        : SeedPalette.gray500Light,
                },
              ),
          ],
        );

        final basePadding = bleed
            ? EdgeInsets.symmetric(vertical: size.padding.vertical / 2)
            : size.padding;

        final container = AnimatedContainer(
          duration: SeedDuration.colorTransition,
          curve: SeedCurves.easing,
          constraints: BoxConstraints(
            minHeight: size.height,
            minWidth: isIconOnly ? size.height : 0,
          ),
          padding: isIconOnly
              ? EdgeInsets.zero
              : basePadding -
                    (strokeColor != null
                        ? const EdgeInsets.all(1)
                        : EdgeInsets.zero),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: size.borderRadius,
            border: strokeColor != null ? Border.all(color: strokeColor) : null,
          ),
          child: isIconOnly
              ? SizedBox(
                  width: size.height,
                  height: size.height,
                  child: Center(child: content),
                )
              : content,
        );

        if (isFullWidth) {
          return SizedBox(width: double.infinity, child: container);
        }

        return container;
      },
    );
  }

  Widget _buildContent(Color fgColor, TextStyle textStyle) {
    final effectiveStyle = textStyle.copyWith(color: fgColor);

    if (icon != null && label == null) {
      return IconTheme(
        data: IconThemeData(color: fgColor, size: size.iconOnlySize),
        child: icon!,
      );
    }

    final iconSize = size.withTextIconSize;

    return Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (prefixIcon != null) ...[
          IconTheme(
            data: IconThemeData(color: fgColor, size: iconSize),
            child: prefixIcon!,
          ),
          SizedBox(
            width: size == SeedButtonSize.large
                ? SeedDimension.x2
                : size == SeedButtonSize.medium
                ? SeedDimension.x1_5
                : SeedDimension.x1,
          ),
        ],
        if (label != null)
          Flexible(
            child: Text(
              label!,
              style: effectiveStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        if (suffixIcon != null) ...[
          SizedBox(
            width: size == SeedButtonSize.large
                ? SeedDimension.x2
                : size == SeedButtonSize.medium
                ? SeedDimension.x1_5
                : SeedDimension.x1,
          ),
          IconTheme(
            data: IconThemeData(color: fgColor, size: iconSize),
            child: suffixIcon!,
          ),
        ],
      ],
    );
  }

  (Color bg, Color fg, Color? stroke) _resolveColors({
    required SeedColorScheme colors,
    required bool isPressed,
    required bool enabled,
  }) {
    if (!enabled) {
      return (
        variant == SeedButtonVariant.brandOutline ||
                variant == SeedButtonVariant.neutralOutline ||
                variant == SeedButtonVariant.ghost
            ? colors.bg.transparent
            : colors.bg.disabled,
        colors.fg.disabled,
        variant == SeedButtonVariant.brandOutline ||
                variant == SeedButtonVariant.neutralOutline
            ? colors.stroke.neutralMuted
            : null,
      );
    }

    switch (variant) {
      case SeedButtonVariant.brandSolid:
        return (
          isPressed ? colors.bg.brandSolidPressed : colors.bg.brandSolid,
          colors.fg.onBrandSolid,
          null,
        );
      case SeedButtonVariant.neutralSolid:
        return (
          isPressed ? colors.bg.neutralSolidPressed : colors.bg.neutralSolid,
          colors.fg.onNeutralSolid,
          null,
        );
      case SeedButtonVariant.neutralWeak:
        return (
          isPressed ? colors.bg.neutralWeakPressed : colors.bg.neutralWeak,
          colors.fg.neutral,
          null,
        );
      case SeedButtonVariant.brandOutline:
        return (
          isPressed ? colors.bg.transparentPressed : colors.bg.transparent,
          colors.fg.brand,
          colors.stroke.neutralMuted,
        );
      case SeedButtonVariant.neutralOutline:
        return (
          isPressed ? colors.bg.transparentPressed : colors.bg.transparent,
          colors.fg.neutral,
          colors.stroke.neutralMuted,
        );
      case SeedButtonVariant.criticalSolid:
        return (
          isPressed ? colors.bg.criticalSolidPressed : colors.bg.criticalSolid,
          colors.fg.onCriticalSolid,
          null,
        );
      case SeedButtonVariant.ghost:
        return (
          isPressed ? colors.bg.transparentPressed : colors.bg.transparent,
          colors.fg.neutral,
          null,
        );
    }
  }
}
