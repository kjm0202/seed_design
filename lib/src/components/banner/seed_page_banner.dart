import 'package:material_ui/material_ui.dart';

import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
import '../../theme/seed_theme.dart';

/// Tone options for [SeedPageBanner].
enum SeedPageBannerTone {
  neutral,
  informative,
  positive,
  warning,
  critical,
  magic,
}

/// Variant options for [SeedPageBanner].
enum SeedPageBannerVariant { weak, solid }

/// Page Banner component of SEED Design System.
///
/// Prominently communicates high-level notifications, system alerts,
/// and promotions at the top of a page.
class SeedPageBanner extends StatelessWidget {
  final String title;
  final String? description;
  final String? linkText;
  final VoidCallback? onLinkTap;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final Widget? prefixIcon;
  final SeedPageBannerTone tone;
  final SeedPageBannerVariant variant;

  const SeedPageBanner({
    super.key,
    required this.title,
    this.description,
    this.linkText,
    this.onLinkTap,
    this.onTap,
    this.onDismiss,
    this.prefixIcon,
    this.tone = SeedPageBannerTone.neutral,
    this.variant = SeedPageBannerVariant.weak,
  });

  bool get _isActionable => onTap != null;

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;

    final (bgColor, fgColor, iconColor) = _resolveColors(colors);

    Widget content = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SeedDimension.x4,
        vertical: SeedDimension.x3,
      ),
      color: bgColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (prefixIcon != null) ...[
            IconTheme(
              data: IconThemeData(color: iconColor, size: 20.0),
              child: prefixIcon!,
            ),
            const SizedBox(width: SeedDimension.x2_5),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: typography.t4Bold.copyWith(color: fgColor),
                      ),
                    ),
                    if (linkText != null) ...[
                      const SizedBox(width: SeedDimension.x1_5),
                      SeedPressable(
                        semanticsLabel: linkText,
                        enableScale: false,
                        onTap: onLinkTap,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            minWidth: 24,
                            minHeight: 24,
                          ),
                          child: Center(
                            widthFactor: 1,
                            heightFactor: 1,
                            child: Text(
                              linkText!,
                              style: typography.t3Bold.copyWith(
                                color: colors.fg.brand,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (description != null) ...[
                  const SizedBox(height: SeedDimension.x0_5),
                  Text(
                    description!,
                    style: typography.t3Regular.copyWith(
                      color: fgColor.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: SeedDimension.x2),
            SeedPressable(
              semanticsLabel: '닫기',
              enableScale: false,
              behavior: HitTestBehavior.opaque,
              onTap: onDismiss,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                child: Center(
                  widthFactor: 1,
                  heightFactor: 1,
                  child: Icon(
                    Icons.close_rounded,
                    size: 18.0,
                    color: iconColor,
                  ),
                ),
              ),
            ),
          ] else if (_isActionable) ...[
            const SizedBox(width: SeedDimension.x2),
            Icon(Icons.chevron_right_rounded, size: 20.0, color: iconColor),
          ],
        ],
      ),
    );

    if (_isActionable) {
      return SeedPressable(onTap: onTap, enableScale: false, child: content);
    }

    return content;
  }

  (Color bg, Color fg, Color icon) _resolveColors(dynamic colors) {
    if (variant == SeedPageBannerVariant.solid) {
      switch (tone) {
        case SeedPageBannerTone.neutral:
          return (
            colors.bg.neutralSolid,
            colors.fg.onNeutralSolid,
            colors.fg.onNeutralSolid,
          );
        case SeedPageBannerTone.informative:
          return (
            colors.bg.informativeSolid,
            colors.fg.onInformativeSolid,
            colors.fg.onInformativeSolid,
          );
        case SeedPageBannerTone.positive:
          return (
            colors.bg.positiveSolid,
            colors.fg.onPositiveSolid,
            colors.fg.onPositiveSolid,
          );
        case SeedPageBannerTone.warning:
          return (
            colors.bg.warningSolid,
            colors.fg.onWarningSolid,
            colors.fg.onWarningSolid,
          );
        case SeedPageBannerTone.critical:
          return (
            colors.bg.criticalSolid,
            colors.fg.onCriticalSolid,
            colors.fg.onCriticalSolid,
          );
        case SeedPageBannerTone.magic:
          return (
            colors.bg.brandSolid,
            colors.fg.onBrandSolid,
            colors.fg.onBrandSolid,
          );
      }
    } else {
      switch (tone) {
        case SeedPageBannerTone.neutral:
          return (
            colors.bg.neutralWeak,
            colors.fg.neutral,
            colors.fg.neutralSubtle,
          );
        case SeedPageBannerTone.informative:
          return (
            colors.bg.informativeWeak,
            colors.fg.informativeContrast,
            colors.fg.informative,
          );
        case SeedPageBannerTone.positive:
          return (
            colors.bg.positiveWeak,
            colors.fg.positiveContrast,
            colors.fg.positive,
          );
        case SeedPageBannerTone.warning:
          return (
            colors.bg.warningWeak,
            colors.fg.warningContrast,
            colors.fg.warning,
          );
        case SeedPageBannerTone.critical:
          return (
            colors.bg.criticalWeak,
            colors.fg.criticalContrast,
            colors.fg.critical,
          );
        case SeedPageBannerTone.magic:
          return (colors.bg.magicWeak, colors.fg.neutral, colors.fg.brand);
      }
    }
  }
}
