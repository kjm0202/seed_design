import 'package:material_ui/material_ui.dart';

import '../../foundations/colors/seed_color_scheme.dart';
import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
import '../../foundations/gradient/seed_gradient.dart';
import '../../foundations/motion/seed_motion.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';

/// Tone options for [SeedCallout].
enum SeedCalloutTone {
  neutral,
  informative,
  warning,
  critical,
  positive,
  magic,
}

/// Callout component of SEED Design System.
///
/// Delivers important announcements, tips, guidance, warnings, or magic AI alerts.
class SeedCallout extends StatefulWidget {
  final String? title;
  final String description;
  final String? linkText;
  final VoidCallback? onLinkTap;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final Widget? prefixIcon;
  final SeedCalloutTone tone;
  final bool underlineLink;
  final bool showIcon;

  /// Controls visibility externally when non-null.
  final bool? open;

  /// Initial visibility when [open] is not supplied.
  final bool defaultOpen;

  const SeedCallout({
    super.key,
    this.title,
    required this.description,
    this.linkText,
    this.onLinkTap,
    this.onTap,
    this.onDismiss,
    this.prefixIcon,
    this.tone = SeedCalloutTone.neutral,
    this.underlineLink = true,
    this.showIcon = false,
    this.open,
    this.defaultOpen = true,
  });

  @override
  State<SeedCallout> createState() => _SeedCalloutState();
}

class _SeedCalloutState extends State<SeedCallout> {
  late bool _open = widget.defaultOpen;

  void _dismiss() {
    if (widget.open == null) setState(() => _open = false);
    widget.onDismiss?.call();
  }

  bool get _isActionable => widget.onTap != null;

  @override
  Widget build(BuildContext context) {
    if (!(widget.open ?? _open)) return const SizedBox.shrink();
    final SeedCallout(
      :title,
      :description,
      :linkText,
      :onLinkTap,
      :onTap,
      :onDismiss,
      :prefixIcon,
      :tone,
      :underlineLink,
      :showIcon,
    ) = widget;
    final colors = context.seedColor;
    final typography = context.seedTypography;

    final (bgColor, fgColor, iconColor) = _resolveColors(colors, tone);

    Widget content(bool isPressed) => Container(
      constraints: const BoxConstraints(minHeight: 50),
      decoration: BoxDecoration(
        color: isPressed
            ? switch (tone) {
                SeedCalloutTone.neutral => colors.bg.neutralWeakPressed,
                SeedCalloutTone.informative => colors.bg.informativeWeakPressed,
                SeedCalloutTone.positive => colors.bg.positiveWeakPressed,
                SeedCalloutTone.warning => colors.bg.warningWeakPressed,
                SeedCalloutTone.critical => colors.bg.criticalWeakPressed,
                SeedCalloutTone.magic => bgColor,
              }
            : bgColor,
        gradient: tone == SeedCalloutTone.magic
            ? (isPressed
                  ? SeedGradients.glowMagicPressed(isDark: colors.isDark)
                  : SeedGradients.glowMagic(isDark: colors.isDark))
            : null,
        borderRadius: SeedBorderRadius.r2_5,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(SeedDimension.x3_5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (showIcon || prefixIcon != null) ...[
                  IconTheme(
                    data: IconThemeData(color: iconColor, size: 16.0),
                    child: prefixIcon ?? _defaultIcon(tone, iconColor),
                  ),
                  const SizedBox(width: SeedDimension.x3),
                ],
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        if (title != null)
                          TextSpan(
                            text: '$title  ',
                            style: typography.t4Bold.copyWith(color: fgColor),
                          ),
                        TextSpan(text: description),
                        if (linkText != null && !_isActionable) ...[
                          const TextSpan(text: '  '),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: SeedPressable(
                              semanticsLabel: linkText,
                              onTap: onLinkTap,
                              child: Text(
                                linkText,
                                style: typography.t4Regular.copyWith(
                                  color: fgColor,
                                  decoration: underlineLink
                                      ? TextDecoration.underline
                                      : TextDecoration.none,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    style: typography.t4Regular.copyWith(color: fgColor),
                  ),
                ),
                if (onDismiss != null)
                  // The 40px target occupies 16px plus the 12px root gap.
                  const SizedBox(width: 28)
                else if (_isActionable) ...[
                  const SizedBox(width: SeedDimension.x3),
                  Icon(Icons.chevron_right_rounded, size: 16.0, color: fgColor),
                ],
              ],
            ),
          ),
          if (onDismiss != null)
            PositionedDirectional(
              end: 2,
              top: 0,
              bottom: 0,
              child: Center(
                child: SeedPressable(
                  semanticsLabel: '닫기',
                  behavior: HitTestBehavior.opaque,
                  focusBorderRadius: SeedBorderRadius.r2,
                  onTap: _dismiss,
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
                        color: fgColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    if (_isActionable) {
      return SeedPressable(
        onTap: onTap,
        builder: (context, isPressed) => content(isPressed),
      );
    }

    return content(false);
  }

  Widget _defaultIcon(SeedCalloutTone tone, Color color) {
    IconData iconData;
    switch (tone) {
      case SeedCalloutTone.neutral:
        iconData = Icons.info_rounded;
        break;
      case SeedCalloutTone.informative:
        iconData = Icons.info_rounded;
        break;
      case SeedCalloutTone.warning:
        iconData = Icons.warning_rounded;
        break;
      case SeedCalloutTone.critical:
        iconData = Icons.error_rounded;
        break;
      case SeedCalloutTone.positive:
        iconData = Icons.check_circle_rounded;
        break;
      case SeedCalloutTone.magic:
        iconData = Icons.auto_awesome_rounded;
        break;
    }
    return Icon(iconData, color: color, size: 16.0);
  }

  (Color bg, Color fg, Color icon) _resolveColors(
    SeedColorScheme colors,
    SeedCalloutTone tone,
  ) {
    switch (tone) {
      case SeedCalloutTone.neutral:
        return (colors.bg.neutralWeak, colors.fg.neutral, colors.fg.neutral);
      case SeedCalloutTone.informative:
        return (
          colors.bg.informativeWeak,
          colors.fg.informativeContrast,
          colors.fg.informativeContrast,
        );
      case SeedCalloutTone.warning:
        return (
          colors.bg.warningWeak,
          colors.fg.warningContrast,
          colors.fg.warningContrast,
        );
      case SeedCalloutTone.critical:
        return (
          colors.bg.criticalWeak,
          colors.fg.criticalContrast,
          colors.fg.criticalContrast,
        );
      case SeedCalloutTone.positive:
        return (
          colors.bg.positiveWeak,
          colors.fg.positiveContrast,
          colors.fg.positiveContrast,
        );
      case SeedCalloutTone.magic:
        return (colors.bg.magicWeak, colors.fg.neutral, colors.fg.neutral);
    }
  }
}
