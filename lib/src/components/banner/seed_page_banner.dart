import '../../localization/seed_localizations.dart';

import 'package:material_ui/material_ui.dart';

import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
import '../../foundations/gradient/seed_gradient.dart';
import '../../foundations/motion/seed_motion.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';

/// Tone options for [SeedPageBanner].
enum SeedPageBannerTone {
  /// Neutral system message.
  neutral,
  /// Informational message.
  informative,
  /// Success or positive outcome.
  positive,
  /// Warning requiring caution.
  warning,
  /// Critical or destructive message.
  critical,
  /// Special gradient promotion or magic/AI message; weak variant only.
  magic,
}

/// Variant options for [SeedPageBanner].
enum SeedPageBannerVariant {
  /// Subdued tonal background.
  weak,

  /// Strong filled background.
  solid,
}

/// Page Banner component of SEED Design System.
///
/// Prominently communicates high-level notifications, system alerts,
/// and promotions at the top of a page.
class SeedPageBanner extends StatefulWidget {
  /// Optional emphasized leading title, omitted when null.
  final String? title;
  /// Optional body text; shown after [title] when both are supplied.
  final String? description;
  /// Optional text action displayed beside the message.
  final String? linkText;
  /// Invoked when the [linkText] action is pressed.
  final VoidCallback? onLinkTap;
  /// Enables an actionable banner surface; tapping it invokes this callback.
  final VoidCallback? onTap;
  /// Invoked on dismissal; also enables the visible dismiss control.
  final VoidCallback? onDismiss;

  /// When supplied, visibility is owned by the parent.
  /// A parent must update this value after [onDismiss] to hide the banner.
  final bool? open;
  /// Initial visibility in internally managed mode (true by default).
  final bool defaultOpen;

  /// Shows a close button even when [onDismiss] is omitted.
  final bool dismissible;
  /// Optional leading icon, displayed at 16 logical pixels.
  final Widget? prefixIcon;
  /// Semantic tone, default [SeedPageBannerTone.neutral].
  final SeedPageBannerTone tone;
  /// Color strength, default [SeedPageBannerVariant.weak].
  final SeedPageBannerVariant variant;

  /// Creates a page-level message bar.
  ///
  /// [title] and [description] are independently optional. [onTap] makes the
  /// entire banner actionable; [linkText]/[onLinkTap] add a separate text action.
  /// A dismiss control is shown for [dismissible] or [onDismiss]. The
  /// `magic` tone cannot be combined with the solid variant.
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

  /// (target height 40 - t3 line height 18) / 2, as in the official recipe.
  static const double _linkTargetBleed = 11;

  Widget _scaleContent(Widget child) =>
      _isActionable ? SeedContentScale(child: child) : child;

  Widget _build(BuildContext context, VoidCallback dismiss) {
    final colors = context.seedColor;
    final typography = context.seedTypography;

    final (bgColor, fgColor, iconColor) = _resolveColors(colors);

    final hasCloseButton = dismissible || onDismiss != null;

    Widget content(bool isPressed) => Container(
      constraints: const BoxConstraints(minHeight: SeedDimension.x10),
      // React bleeds the 40px link and close targets over the root padding with
      // negative margins. Here the vertical padding belongs to the text and the
      // end padding shrinks by the close target's 12px bleed, so the targets stay
      // inside the root's hit-test bounds without growing the banner.
      padding: EdgeInsetsDirectional.only(
        start: SeedDimension.x4,
        end: hasCloseButton ? SeedDimension.x1 : SeedDimension.x4,
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
          // The official prefix icon sits on the first line of wrapped text;
          // the suffix stays centered (alignSelf).
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (prefixIcon != null) ...[
              Padding(
                padding: const EdgeInsets.only(
                  top: (SeedDimension.x10 - SeedDimension.x4) / 2,
                ),
                child: IconTheme(
                  data: IconThemeData(color: iconColor, size: 16.0),
                  child: prefixIcon!,
                ),
              ),
              const SizedBox(width: SeedDimension.x2),
            ],
            Expanded(
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: SeedDimension.x1_5,
                // The official 6px gap, less the text padding and link bleed
                // that overlap when the link wraps below the text.
                runSpacing:
                    SeedDimension.x1_5 - SeedDimension.x2_5 - _linkTargetBleed,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: SeedDimension.x2_5,
                    ),
                    child: Text.rich(
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
                              style: typography.t4Medium.copyWith(
                                color: fgColor,
                              ),
                            ),
                        ],
                      ),
                      style: typography.t4Medium.copyWith(color: fgColor),
                    ),
                  ),
                  if (linkText != null)
                    SeedPressable(
                      semanticsLabel: linkText,
                      focusRingInside: true,
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
            if (hasCloseButton)
              // Keeps the official 8px between the text and the 16px icon, with
              // the 40px target's start edge overlapping the text by 4px.
              SizedBox(
                width: SeedDimension.x10 - SeedDimension.x1,
                height: SeedDimension.x10,
                child: OverflowBox(
                  minWidth: SeedDimension.x10,
                  maxWidth: SeedDimension.x10,
                  alignment: AlignmentDirectional.centerEnd,
                  child: SeedPressable(
                    semanticsLabel: SeedLocalizations.label(
                      context,
                      SeedLabel.close,
                    ),
                    behavior: HitTestBehavior.opaque,
                    focusBorderRadius: SeedBorderRadius.r2,
                    focusRingInside: true,
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
                ),
              )
            else if (_isActionable) ...[
              const SizedBox(width: SeedDimension.x2),
              Align(
                alignment: Alignment.center,
                heightFactor: 1,
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 16.0,
                  color: iconColor,
                ),
              ),
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
