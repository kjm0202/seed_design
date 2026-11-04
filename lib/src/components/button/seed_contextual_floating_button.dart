import 'package:material_ui/material_ui.dart';

import '../../foundations/colors/seed_palette.dart';
import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
import '../../foundations/motion/seed_motion.dart';
import '../../theme/seed_theme.dart';
import '../feedback/seed_progress_circle.dart';

/// Style tone for [SeedContextualFloatingButton].
enum SeedContextualFloatingButtonTone {
  /// Opaque solid button surface.
  solid,

  /// Elevated floating layer surface.
  layer,
}

/// The official name of [SeedContextualFloatingButton]'s style prop.
typedef SeedContextualFloatingButtonVariant = SeedContextualFloatingButtonTone;

/// Contextual Floating Button component of SEED Design System.
///
/// A secondary floating button dynamically appearing above screen content
/// based on context (e.g. "새 글 5개 보기 ↑", "맨 위로").
class SeedContextualFloatingButton extends StatelessWidget {
  /// Leading symbol; required when [label] is absent.
  final Widget? icon;
  /// Optional action text; omit for an icon-only button.
  final String? label;
  /// Accessible name; required for an icon-only button.
  final String? semanticsLabel;
  /// Invoked on activation while [enabled] and not [loading].
  final VoidCallback onPressed;
  /// Visual treatment (solid by default), corresponding to React `variant`.
  final SeedContextualFloatingButtonVariant variant;
  /// Deprecated alias for [variant].
  @Deprecated('Use variant instead.')
  SeedContextualFloatingButtonTone get tone => variant;
  /// Uses brand foreground/background tokens where applicable (default false).
  final bool isBrand;
  /// Displays a spinner and temporarily prevents interaction.
  final bool loading;
  /// Whether user activation is allowed (true by default).
  final bool enabled;

  /// Creates a contextual action with an icon, label, or both.
  ///
  /// The deprecated [tone] constructor argument aliases [variant]; supplying
  /// both is invalid. Icon-only content requires [semanticsLabel].
  const SeedContextualFloatingButton({
    super.key,
    this.semanticsLabel,
    this.icon,
    this.label,
    required this.onPressed,
    SeedContextualFloatingButtonVariant? variant,
    @Deprecated('Use variant instead.') SeedContextualFloatingButtonTone? tone,
    this.isBrand = false,
    this.loading = false,
    this.enabled = true,
  }) : variant = variant ?? tone ?? SeedContextualFloatingButtonTone.solid,
       assert(variant == null || tone == null),
       assert(icon != null || label != null, 'Must provide icon or label.'),
       assert(
         label != null || (semanticsLabel != null && semanticsLabel != ''),
         'Icon-only buttons require a semanticsLabel.',
       );

  /// Creates a 44 px icon-only contextual button with an accessible label.
  /// The legacy [tone] parameter is an alias for [variant].
  const SeedContextualFloatingButton.iconOnly({
    super.key,
    required String this.semanticsLabel,
    required Widget this.icon,
    required this.onPressed,
    SeedContextualFloatingButtonVariant? variant,
    @Deprecated('Use variant instead.') SeedContextualFloatingButtonTone? tone,
    this.isBrand = false,
    this.loading = false,
    this.enabled = true,
  }) : variant = variant ?? tone ?? SeedContextualFloatingButtonTone.solid,
       assert(variant == null || tone == null),
       assert(semanticsLabel != ''),
       label = null;

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;
    final shadows = context.seedShadows;

    Color bgColor;
    Color fgColor;

    if (!enabled) {
      bgColor = colors.bg.disabled;
      fgColor = colors.fg.disabled;
    } else if (variant == SeedContextualFloatingButtonTone.solid) {
      bgColor = isBrand ? colors.bg.brandSolid : colors.bg.neutralSolid;
      fgColor = isBrand ? colors.fg.onBrandSolid : colors.fg.onNeutralSolid;
    } else {
      // Layer
      bgColor = colors.bg.layerFloating;
      fgColor = isBrand ? colors.fg.brand : colors.fg.neutral;
    }

    final TextStyle textStyle = typography.t4Medium.copyWith(color: fgColor);

    return SeedPressable(
      semanticsLabel: semanticsLabel ?? label,
      enabled: enabled && !loading,
      onTap: onPressed,
      builder: (context, isPressed) => AnimatedContainer(
        duration: SeedDuration.colorTransition,
        curve: SeedCurves.easing,
        constraints: BoxConstraints(
          minHeight: label == null ? 44 : 36,
          minWidth: label == null ? 44 : 0,
        ),

        padding: EdgeInsets.symmetric(
          horizontal: label == null ? 0 : SeedDimension.x3_5,
          vertical: label == null ? 0 : SeedDimension.x2,
        ),
        decoration: BoxDecoration(
          color: !enabled
              ? colors.bg.disabled
              : (isPressed || loading)
              ? (variant == SeedContextualFloatingButtonTone.solid
                    ? (isBrand
                          ? colors.bg.brandSolidPressed
                          : colors.bg.neutralSolidPressed)
                    : colors.bg.layerFloatingPressed)
              : bgColor,
          borderRadius: SeedBorderRadius.full,
          boxShadow: shadows.s3,
        ),
        // React's LoadingIndicator hides the content in place and overlays the
        // spinner, so the button keeps its size.
        child: Stack(
          alignment: Alignment.center,
          children: [
            Visibility(
              visible: !loading,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (icon != null)
                    IconTheme(
                      data: IconThemeData(
                        color: fgColor,
                        size: label == null ? 22 : 16,
                      ),
                      child: icon!,
                    ),
                  if (label != null) ...[
                    if (icon != null) const SizedBox(width: SeedDimension.x1),
                    Text(label!, style: textStyle),
                  ],
                ],
              ),
            ),
            if (loading)
              SeedProgressCircle(
                size: 16.0,
                strokeWidth: 2,
                color: fgColor,
                trackColor: variant == SeedContextualFloatingButtonTone.solid
                    ? (colors.isDark
                          ? SeedPalette.gray700Dark
                          : SeedPalette.gray700Light)
                    : (colors.isDark
                          ? SeedPalette.gray500Dark
                          : SeedPalette.gray500Light),
              ),
          ],
        ),
      ),
    );
  }
}
