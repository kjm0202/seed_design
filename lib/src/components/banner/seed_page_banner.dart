import 'package:material_ui/material_ui.dart';

import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
import '../../foundations/gradient/seed_gradient.dart';
import '../../foundations/motion/seed_motion.dart';
import '../../foundations/radius/seed_radius.dart';
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
class SeedPageBanner extends StatefulWidget {
  final String? title;
  final String? description;
  final String? linkText;
  final VoidCallback? onLinkTap;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  /// When supplied, visibility is owned by the parent.
  final bool? open;
  final bool defaultOpen;

  /// Shows a close button even when [onDismiss] is omitted.
  final bool dismissible;
  final Widget? prefixIcon;
  final SeedPageBannerTone tone;
  final SeedPageBannerVariant variant;

  const SeedPageBanner({
    super.key,
    this.title,
    this.description,
    this.linkText,
    this.onLinkTap,
    this.onTap,
    this.onDismiss,
    this.open,
    this.defaultOpen = true,
    this.dismissible = false,
    this.prefixIcon,
    this.tone = SeedPageBannerTone.neutral,
    this.variant = SeedPageBannerVariant.weak,
  }) : assert(
         tone != SeedPageBannerTone.magic ||
             variant != SeedPageBannerVariant.solid,
         'The magic tone only supports the weak variant.',
       );

  @override
  State<SeedPageBanner> createState() => _SeedPageBannerState();

  bool get _isActionable => onTap != null;

  Widget _scaleContent(Widget child) =>
      _isActionable ? SeedContentScale(child: child) : child;

  Widget _build(BuildContext context, VoidCallback dismiss) {
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
      child: _scaleContent(
        Row(
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
                alignment: WrapAlignment.spaceBetween,
                spacing: 6,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        if (title != null)
                          TextSpan(
                            text: title,
                            style: typography.t4Bold.copyWith(color: fgColor),
                          ),
                        if (description != null)
                          TextSpan(
                            text: title == null
                                ? description
                                : '  $description',
                            style: typography.t4Medium.copyWith(color: fgColor),
                          ),
                      ],
                    ),
                    style: typography.t4Medium.copyWith(color: fgColor),
                  ),
                  if (linkText != null)
                    SeedPressable(
                      semanticsLabel: linkText,
                      onTap: onLinkTap,
                      builder: (context, linkPressed) => ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 40),
                        child: Center(
                          widthFactor: 1,
                          heightFactor: 1,
                          child: Text(
                            linkText!,
                            style: typography.t3Bold.copyWith(color: fgColor),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (dismissible || onDismiss != null) ...[
              const SizedBox(width: SeedDimension.x2),
              SeedPressable(
                semanticsLabel: '닫기',
                behavior: HitTestBehavior.opaque,
                focusBorderRadius: SeedBorderRadius.r2,
                onTap: dismiss,
                builder: (context, isClosePressed) => AnimatedContainer(
                  duration: SeedDuration.colorTransition,
                  curve: SeedCurves.easing,
                  width: SeedDimension.x10,
                  height: SeedDimension.x10,
                  decoration: BoxDecoration(
                    color: isClosePressed
                        ? colors.bg.transparentPressed
                        : colors.bg.transparent,
                    borderRadius: SeedBorderRadius.r2,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.close_rounded,
                      size: SeedDimension.x4,
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
          return (colors.bg.magicWeak, colors.fg.neutral, colors.fg.neutral);
      }
    }
  }
}

class _SeedPageBannerState extends State<SeedPageBanner> {
  late bool _open = widget.defaultOpen;

  void _dismiss() {
    if (!(widget.open ?? _open)) return;
    if (widget.open == null) setState(() => _open = false);
    widget.onDismiss?.call();
  }

  @override
  Widget build(BuildContext context) => (widget.open ?? _open)
      ? widget._build(context, _dismiss)
      : const SizedBox.shrink();
}
