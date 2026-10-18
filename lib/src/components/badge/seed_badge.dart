import 'package:material_ui/material_ui.dart';
import '../../foundations/colors/seed_color_scheme.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';

/// Tone options for [SeedBadge].
enum SeedBadgeTone {
  neutral,
  brand,
  informative,
  positive,
  warning,
  critical,
}

/// Visual variant options for [SeedBadge].
enum SeedBadgeVariant {
  solid,
  outline,
  weak,
}

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

  EdgeInsets get padding {
    switch (this) {
      case SeedBadgeSize.medium:
        return const EdgeInsets.symmetric(horizontal: 6.0);
      case SeedBadgeSize.large:
        return const EdgeInsets.symmetric(horizontal: 8.0);
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
class SeedBadge extends StatelessWidget {
  final String label;
  final SeedBadgeTone tone;
  final SeedBadgeVariant variant;
  final SeedBadgeSize size;
  final double? maxWidth;

  const SeedBadge({
    super.key,
    required this.label,
    this.tone = SeedBadgeTone.neutral,
    this.variant = SeedBadgeVariant.weak,
    this.size = SeedBadgeSize.medium,
    this.maxWidth = 120.0,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;

    final TextStyle textStyle = size == SeedBadgeSize.medium
        ? typography.t1Bold
        : typography.t2Bold;

    final (bgColor, fgColor, strokeColor) = _resolveColors(colors);

    return Container(
      height: size.height,
      constraints: maxWidth != null ? BoxConstraints(maxWidth: maxWidth!) : null,
      padding: size.padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: size.borderRadius,
        border: strokeColor != null
            ? Border.all(color: strokeColor, width: 1.0)
            : null,
      ),
      child: Center(
        widthFactor: 1.0,
        child: Text(
          label,
          style: textStyle.copyWith(color: fgColor),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  (Color bg, Color fg, Color? stroke) _resolveColors(SeedColorScheme colors) {
    switch (variant) {
      case SeedBadgeVariant.solid:
        switch (tone) {
          case SeedBadgeTone.neutral:
            return (colors.bg.neutralSolid, colors.fg.onNeutralSolid, null);
          case SeedBadgeTone.brand:
            return (colors.bg.brandSolid, colors.fg.onBrandSolid, null);
          case SeedBadgeTone.informative:
            return (colors.bg.informativeSolid, colors.fg.onInformativeSolid, null);
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
            return (colors.bg.transparent, colors.fg.neutral, colors.stroke.neutralWeak);
          case SeedBadgeTone.brand:
            return (colors.bg.transparent, colors.fg.brand, colors.stroke.brandWeak);
          case SeedBadgeTone.informative:
            return (colors.bg.transparent, colors.fg.informative, colors.stroke.informativeWeak);
          case SeedBadgeTone.positive:
            return (colors.bg.transparent, colors.fg.positive, colors.stroke.positiveWeak);
          case SeedBadgeTone.warning:
            return (colors.bg.transparent, colors.fg.warning, colors.stroke.warningWeak);
          case SeedBadgeTone.critical:
            return (colors.bg.transparent, colors.fg.critical, colors.stroke.criticalWeak);
        }

      case SeedBadgeVariant.weak:
        switch (tone) {
          case SeedBadgeTone.neutral:
            return (colors.bg.neutralWeak, colors.fg.neutral, null);
          case SeedBadgeTone.brand:
            return (colors.bg.brandWeak, colors.fg.brand, null);
          case SeedBadgeTone.informative:
            return (colors.bg.informativeWeak, colors.fg.informative, null);
          case SeedBadgeTone.positive:
            return (colors.bg.positiveWeak, colors.fg.positive, null);
          case SeedBadgeTone.warning:
            return (colors.bg.warningWeak, colors.fg.warning, null);
          case SeedBadgeTone.critical:
            return (colors.bg.criticalWeak, colors.fg.critical, null);
        }
    }
  }
}
