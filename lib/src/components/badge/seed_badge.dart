import 'package:material_ui/material_ui.dart';

import '../../foundations/colors/seed_color_scheme.dart';
import '../../foundations/colors/seed_palette.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';

/// Tone options for [SeedBadge].
enum SeedBadgeTone { neutral, brand, informative, positive, warning, critical }

/// Visual variant options for [SeedBadge].
enum SeedBadgeVariant { solid, outline, weak }

/// Size options for [SeedBadge].
enum SeedBadgeSize {
  medium,
  large;

  double get height {
    switch (this) {
      case SeedBadgeSize.medium:
        return 20.0;
      case SeedBadgeSize.large:
        return 24.0;
    }
  }

  double get iconSize {
    switch (this) {
      case SeedBadgeSize.medium:
        return 12.0;
      case SeedBadgeSize.large:
        return 14.0;
    }
  }

  EdgeInsets get padding {
    switch (this) {
      case SeedBadgeSize.medium:
        return const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2);
      case SeedBadgeSize.large:
        return const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4);
    }
  }

  BorderRadius get borderRadius {
    switch (this) {
      case SeedBadgeSize.medium:
        return SeedBorderRadius.r1;
      case SeedBadgeSize.large:
        return SeedBorderRadius.r1_5;
    }
  }
}

/// Badge component of SEED Design System.
///
/// Communicates entity attributes, categories, and concise states.
/// Supports prefix icons, label, and action buttons.
class SeedBadge extends StatelessWidget {
  final String label;
  final Widget? prefix;
  final Widget? action;
  final SeedBadgeTone tone;
  final SeedBadgeVariant variant;
  final SeedBadgeSize size;
  final double? maxWidth;

  const SeedBadge({
    super.key,
    required this.label,
    this.prefix,
    this.action,
    this.tone = SeedBadgeTone.neutral,
    this.variant = SeedBadgeVariant.weak,
    this.size = SeedBadgeSize.medium,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;

    final TextStyle textStyle = size == SeedBadgeSize.medium
        ? (variant == SeedBadgeVariant.weak
              ? typography.t1Medium
              : typography.t1Bold)
        : (variant == SeedBadgeVariant.weak
              ? typography.t2Medium
              : typography.t2Bold);

    final (bgColor, fgColor, strokeColor) = _resolveColors(colors);

    Widget content;
    if (prefix != null || action != null) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (prefix != null) ...[
            IconTheme(
              data: IconThemeData(
                color: fgColor,
                size: size.iconSize,
              ),
              child: prefix!,
            ),
            const SizedBox(width: 2.0),
          ],
          Flexible(
            child: Text(
              label,
              style: textStyle.copyWith(color: fgColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (action != null) ...[
            const SizedBox(width: 2.0),
            IconTheme(
              data: IconThemeData(
                color: fgColor,
                size: size.iconSize,
              ),
              child: action!,
            ),
          ],
        ],
      );
    } else {
      content = Center(
        widthFactor: 1.0,
        heightFactor: 1.0,
        child: Text(
          label,
          style: textStyle.copyWith(color: fgColor),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    return Container(
      constraints: BoxConstraints(
        minHeight: size.height,
        maxWidth: maxWidth ?? double.infinity,
      ),
      padding:
          size.padding -
          (strokeColor != null ? const EdgeInsets.all(1) : EdgeInsets.zero),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: size.borderRadius,
        border: strokeColor != null
            ? Border.all(color: strokeColor, width: 1.0)
            : null,
      ),
      child: content,
    );
  }

  (Color bg, Color fg, Color? stroke) _resolveColors(SeedColorScheme colors) {
    switch (variant) {
      case SeedBadgeVariant.solid:
        switch (tone) {
          case SeedBadgeTone.neutral:
            return (
              colors.isDark
                  ? SeedPalette.gray800Dark
                  : SeedPalette.gray800Light,
              colors.fg.onNeutralSolid,
              null,
            );
          case SeedBadgeTone.brand:
            return (colors.bg.brandSolid, colors.fg.onBrandSolid, null);
          case SeedBadgeTone.informative:
            return (
              colors.bg.informativeSolid,
              colors.fg.onInformativeSolid,
              null,
            );
          case SeedBadgeTone.positive:
            return (colors.bg.positiveSolid, colors.fg.onPositiveSolid, null);
          case SeedBadgeTone.warning:
            return (colors.bg.warningSolid, colors.fg.onWarningSolid, null);
          case SeedBadgeTone.critical:
            return (colors.bg.criticalSolid, colors.fg.onCriticalSolid, null);
        }

      case SeedBadgeVariant.outline:
        switch (tone) {
          case SeedBadgeTone.neutral:
            return (
              colors.bg.transparent,
              colors.fg.neutralMuted,
              colors.stroke.neutralMuted,
            );
          case SeedBadgeTone.brand:
            return (
              colors.bg.transparent,
              colors.fg.brand,
              colors.stroke.brandWeak,
            );
          case SeedBadgeTone.informative:
            return (
              colors.bg.transparent,
              colors.fg.informative,
              colors.stroke.informativeWeak,
            );
          case SeedBadgeTone.positive:
            return (
              colors.bg.transparent,
              colors.fg.positive,
              colors.stroke.positiveWeak,
            );
          case SeedBadgeTone.warning:
            return (
              colors.bg.transparent,
              colors.fg.warning,
              colors.stroke.warningWeak,
            );
          case SeedBadgeTone.critical:
            return (
              colors.bg.transparent,
              colors.fg.critical,
              colors.stroke.criticalWeak,
            );
        }

      case SeedBadgeVariant.weak:
        switch (tone) {
          case SeedBadgeTone.neutral:
            return (colors.bg.neutralWeak, colors.fg.neutralMuted, null);
          case SeedBadgeTone.brand:
            return (colors.bg.brandWeak, colors.fg.brandContrast, null);
          case SeedBadgeTone.informative:
            return (
              colors.bg.informativeWeak,
              colors.fg.informativeContrast,
              null,
            );
          case SeedBadgeTone.positive:
            return (colors.bg.positiveWeak, colors.fg.positiveContrast, null);
          case SeedBadgeTone.warning:
            return (colors.bg.warningWeak, colors.fg.warningContrast, null);
          case SeedBadgeTone.critical:
            return (colors.bg.criticalWeak, colors.fg.criticalContrast, null);
        }
    }
  }
}
