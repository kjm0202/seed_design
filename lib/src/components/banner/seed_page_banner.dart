import 'package:material_ui/material_ui.dart';

import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
import '../../theme/seed_theme.dart';
import '../../foundations/gradient/seed_gradient.dart';

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

    Widget content(bool isPressed) => Container(
      constraints: const BoxConstraints(minHeight: 40),
      padding: const EdgeInsets.symmetric(
        horizontal: SeedDimension.x4,
        vertical: SeedDimension.x2_5,
      ),
      decoration: BoxDecoration(
        color: isPressed
            ? switch (tone) {
                SeedPageBannerTone.neutral =>
                  variant == SeedPageBannerVariant.solid
                      ? colors.bg.neutralSolidPressed
                      : colors.bg.neutralWeakPressed,
                SeedPageBannerTone.informative =>
                  variant == SeedPageBannerVariant.solid
                      ? colors.bg.informativeSolidPressed
                      : colors.bg.informativeWeakPressed,
                SeedPageBannerTone.positive =>
                  variant == SeedPageBannerVariant.solid
                      ? colors.bg.positiveSolidPressed
                      : colors.bg.positiveWeakPressed,
                SeedPageBannerTone.warning =>
                  variant == SeedPageBannerVariant.solid
                      ? colors.bg.warningSolidPressed
                      : colors.bg.warningWeakPressed,
                SeedPageBannerTone.critical =>
                  variant == SeedPageBannerVariant.solid
                      ? colors.bg.criticalSolidPressed
                      : colors.bg.criticalWeakPressed,
                SeedPageBannerTone.magic => bgColor,
              }
            : bgColor,
        gradient: tone == SeedPageBannerTone.magic
            ? (isPressed
                  ? SeedGradients.glowMagicPressed(isDark: colors.isDark)
                  : SeedGradients.glowMagic(isDark: colors.isDark))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (prefixIcon != null) ...[
            IconTheme(
              data: IconThemeData(color: iconColor, size: 16.0),
              child: prefixIcon!,
            ),
            const SizedBox(width: SeedDimension.x2),
          ],
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: title,
                        style: typography.t4Bold.copyWith(color: fgColor),
                      ),
                      if (description != null)
                        TextSpan(
                          text: '  $description',
                          style: typography.t4Medium.copyWith(color: fgColor),
                        ),
                    ],
                  ),
                  style: typography.t4Medium.copyWith(color: fgColor),
                ),
                if (linkText != null)
                  SeedPressable(
                    semanticsLabel: linkText,
                    enableScale: false,
                    onTap: onLinkTap,
                    child: Text(
                      linkText!,
                      style: typography.t3Bold.copyWith(color: fgColor),
                    ),
                  ),
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
                    size: 16.0,
                    color: iconColor,
                  ),
                ),
              ),
            ),
          ] else if (_isActionable) ...[
            const SizedBox(width: SeedDimension.x2),
            Icon(Icons.chevron_right_rounded, size: 16.0, color: iconColor),
          ],
        ],
      ),
    );

    if (_isActionable) {
      return SeedPressable(
        onTap: onTap,
        enableScale: false,
        builder: (context, isPressed) => content(isPressed),
      );
    }

    return content(false);
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
          return (colors.bg.neutralWeak, colors.fg.neutral, colors.fg.neutral);
        case SeedPageBannerTone.informative:
          return (
            colors.bg.informativeWeak,
            colors.fg.informativeContrast,
            colors.fg.informativeContrast,
          );
        case SeedPageBannerTone.positive:
          return (
            colors.bg.positiveWeak,
            colors.fg.positiveContrast,
            colors.fg.positiveContrast,
          );
        case SeedPageBannerTone.warning:
          return (
            colors.bg.warningWeak,
            colors.fg.warningContrast,
            colors.fg.warningContrast,
          );
        case SeedPageBannerTone.critical:
          return (
            colors.bg.criticalWeak,
            colors.fg.criticalContrast,
            colors.fg.criticalContrast,
          );
        case SeedPageBannerTone.magic:
          return (colors.bg.magicWeak, colors.fg.neutral, colors.fg.brand);
      }
    }
  }
}
