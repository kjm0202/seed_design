import 'package:material_ui/material_ui.dart';

import '../../foundations/colors/seed_color_scheme.dart';
import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
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

    Widget content = Container(
      padding: const EdgeInsets.all(SeedDimension.x4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: SeedBorderRadius.r3,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconTheme(
            data: IconThemeData(color: iconColor, size: 20.0),
            child: prefixIcon ?? _defaultIcon(tone, iconColor),
          ),
          const SizedBox(width: SeedDimension.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: typography.t4Bold.copyWith(color: fgColor),
                  ),
                  const SizedBox(height: SeedDimension.x1),
                ],
                Text(
                  description,
                  style: typography.t3Regular.copyWith(color: fgColor),
                ),
                if (linkText != null && !_isActionable) ...[
                  const SizedBox(height: SeedDimension.x1_5),
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
                    color: colors.fg.neutralSubtle,
                  ),
                ),
              ),
            ),
          ] else if (_isActionable) ...[
            const SizedBox(width: SeedDimension.x2),
            Icon(
              Icons.chevron_right_rounded,
              size: 20.0,
              color: colors.fg.neutralSubtle,
            ),
          ],
        ],
      ),
    );

    if (_isActionable) {
      return SeedPressable(onTap: onTap, child: content);
    }

    return content;
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
    return Icon(iconData, color: color, size: 20.0);
  }

  (Color bg, Color fg, Color icon) _resolveColors(SeedColorScheme colors) {
    switch (tone) {
      case SeedCalloutTone.neutral:
        return (
          colors.bg.neutralWeak,
          colors.fg.neutral,
          colors.fg.neutralSubtle,
        );
      case SeedCalloutTone.informative:
        return (
          colors.bg.informativeWeak,
          colors.fg.informativeContrast,
          colors.fg.informative,
        );
      case SeedCalloutTone.warning:
        return (
          colors.bg.warningWeak,
          colors.fg.warningContrast,
          colors.fg.warning,
        );
      case SeedCalloutTone.critical:
        return (
          colors.bg.criticalWeak,
          colors.fg.criticalContrast,
          colors.fg.critical,
        );
      case SeedCalloutTone.positive:
        return (
          colors.bg.positiveWeak,
          colors.fg.positiveContrast,
          colors.fg.positive,
        );
      case SeedCalloutTone.magic:
        return (colors.bg.magicWeak, colors.fg.neutral, colors.fg.brand);
    }
  }
}
