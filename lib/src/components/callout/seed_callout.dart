import 'package:material_ui/material_ui.dart';

import '../../foundations/colors/seed_color_scheme.dart';
import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
import '../../theme/seed_theme.dart';
import '../../foundations/gradient/seed_gradient.dart';

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
class SeedCallout extends StatelessWidget {
  final String? title;
  final String description;
  final String? linkText;
  final VoidCallback? onLinkTap;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final Widget? prefixIcon;
  final SeedCalloutTone tone;

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
  });

  bool get _isActionable => onTap != null;

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;

    final (bgColor, fgColor, iconColor) = _resolveColors(colors);

    Widget content(bool isPressed) => Container(
      constraints: const BoxConstraints(minHeight: 50),
      padding: const EdgeInsets.all(SeedDimension.x3_5),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconTheme(
            data: IconThemeData(color: iconColor, size: 16.0),
            child: prefixIcon ?? _defaultIcon(tone, iconColor),
          ),
          const SizedBox(width: SeedDimension.x3),
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
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: SeedPressable(
                        semanticsLabel: linkText,
                        enableScale: false,
                        onTap: onLinkTap,
                        child: Text(
                          linkText!,
                          style: typography.t4Regular.copyWith(
                            color: fgColor,
                            decoration: TextDecoration.underline,
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
                  child: Icon(Icons.close_rounded, size: 16.0, color: fgColor),
                ),
              ),
            ),
          ] else if (_isActionable) ...[
            const SizedBox(width: SeedDimension.x2),
            Icon(Icons.chevron_right_rounded, size: 16.0, color: fgColor),
          ],
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

  (Color bg, Color fg, Color icon) _resolveColors(SeedColorScheme colors) {
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
        return (colors.bg.magicWeak, colors.fg.neutral, colors.fg.brand);
    }
  }
}
