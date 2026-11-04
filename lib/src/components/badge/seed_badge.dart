import 'package:material_ui/material_ui.dart';

import '../../foundations/colors/seed_color_scheme.dart';
import '../../foundations/colors/seed_palette.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';

/// Tone options for [SeedBadge].
enum SeedBadgeTone {
  /// Neutral status.
  neutral,

  /// Brand emphasis.
  brand,

  /// Informational status.
  informative,

  /// Successful status.
  positive,

  /// Cautionary status.
  warning,

  /// Error or danger status.
  critical,
}

/// Visual variant options for [SeedBadge].
enum SeedBadgeVariant {
  /// Opaque filled background.
  solid,

  /// Transparent fill with a stroke.
  outline,

  /// Muted tonal background.
  weak,
}

/// Size options for [SeedBadge].
enum SeedBadgeSize {
  /// 20 px high badge.
  medium,
  /// 24 px high badge.
  large;

  /// Minimum height for the size.
  double get height {
    switch (this) {
      case SeedBadgeSize.medium:
        return 20.0;
      case SeedBadgeSize.large:
        return 24.0;
    }
  }

  /// Prefix and action icon dimension for the size.
  double get iconSize {
    switch (this) {
      case SeedBadgeSize.medium:
        return 12.0;
      case SeedBadgeSize.large:
        return 14.0;
    }
  }

  /// Content padding for the size.
  EdgeInsets get padding {
    switch (this) {
      case SeedBadgeSize.medium:
        return const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2);
      case SeedBadgeSize.large:
        return const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4);
    }
  }

  /// Rounded corner shape for the size.
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
  /// Required short status or category text, truncated to one line.
  final String label;
  /// Optional leading icon, sized by [size].
  final Widget? prefix;
  /// Optional trailing action, typically a [SeedBadgeAction].
  final Widget? action;
  /// Semantic color intent; defaults to [SeedBadgeTone.neutral].
  final SeedBadgeTone tone;
  /// Fill treatment; defaults to [SeedBadgeVariant.solid].
  final SeedBadgeVariant variant;
  /// Badge dimension preset; defaults to [SeedBadgeSize.medium].
  final SeedBadgeSize size;
  /// Optional maximum width; long labels ellipsize at this boundary.
  final double? maxWidth;

  /// Creates a passive status badge with optional leading and action widgets.
  /// Use [SeedBadgeAction] to supply keyboard and screen-reader activation.
  const SeedBadge({
    super.key,
    required this.label,
    this.prefix,
    this.action,
    this.tone = SeedBadgeTone.neutral,
    this.variant = SeedBadgeVariant.solid,
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
              data: IconThemeData(color: fgColor, size: size.iconSize),
              child: SizedBox.square(dimension: size.iconSize, child: prefix!),
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
              data: IconThemeData(color: fgColor, size: size.iconSize),
              child: SizedBox.square(dimension: size.iconSize, child: action!),
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

/// Keyboard-accessible action for [SeedBadge.action].
///
/// Supply a label describing the action, such as 'Remove category'. The badge
/// supplies the icon dimensions and colors.
class SeedBadgeAction extends StatelessWidget {
  /// Creates a focusable action for placement in [SeedBadge.action].
  /// A null [onPressed] disables the action without removing its content.
  const SeedBadgeAction({
    super.key,
    required this.child,
    required this.onPressed,
    required this.semanticsLabel,
    this.focusNode,
  });

  /// Icon or other action content sized by the parent badge.
  final Widget child;
  /// Callback for activation; null disables interaction.
  final VoidCallback? onPressed;
  /// Required spoken label describing this action.
  final String semanticsLabel;
  /// Optional externally owned focus node for keyboard navigation.
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) => SeedPressable(
    onTap: onPressed,
    enabled: onPressed != null,
    semanticsLabel: semanticsLabel,
    focusNode: focusNode,
    focusBorderRadius: SeedBorderRadius.r1,
    focusRingInside: true,
    child: child,
  );
}
