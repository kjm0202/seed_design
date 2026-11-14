import 'package:material_ui/material_ui.dart';

import '../../foundations/colors/seed_palette.dart';
import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
import '../../foundations/motion/seed_motion.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';

/// Tone options for top navigation bars and buttons.
enum SeedTopNavigationButtonTone {
  /// Default layer surface with neutral foreground icons and text.
  layer,
  /// Transparent overlay surface with white foreground icons and text.
  transparent,
}

/// Inherited scope that shares the enclosing `SeedTopNavigation` [tone] with
/// child buttons.
class SeedTopNavigationScope extends InheritedWidget {
  /// Shares [tone] with descendant top-navigation buttons through [child].
  /// An optional `key` preserves Flutter widget identity.
  const SeedTopNavigationScope({
    super.key,
    required this.tone,
    required super.child,
  });

  /// Tone inherited by child navigation buttons unless they override it.
  final SeedTopNavigationButtonTone tone;

  /// Finds the closest scope and registers a dependency, or returns null.
  static SeedTopNavigationScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SeedTopNavigationScope>();

  @override
  /// Notifies dependents only when the inherited [tone] changes.
  bool updateShouldNotify(SeedTopNavigationScope oldWidget) =>
      tone != oldWidget.tone;
}

/// Dedicated icon button for top navigation bars adhering to SEED Design.
///
/// Features 44x44px touch area, 8px corner radius, 24px icon,
/// `bg.transparent-pressed` and self-scale tactile feedback.
class SeedTopNavigationIconButton extends StatelessWidget {
  /// The widget rendered inside the 24-pixel icon slot.
  final Widget icon;
  /// Activation callback; null makes the button non-interactive.
  final VoidCallback? onPressed;
  /// Optional override of the nearest [SeedTopNavigationScope] tone.
  final SeedTopNavigationButtonTone? tone;
  /// Explicit enable switch, true by default.
  final bool enabled;
  /// Accessible name for an icon-only button.
  final String? semanticsLabel;

  /// Creates a 44-pixel app-bar icon action.
  ///
  /// [icon] is required, [onPressed] handles activation, [tone] inherits from
  /// [SeedTopNavigationScope] when omitted, and [enabled] defaults to true.
  /// Provide [semanticsLabel] so assistive technology can name the action.
  /// An optional `key` preserves Flutter widget identity.
  const SeedTopNavigationIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tone,
    this.enabled = true,
    this.semanticsLabel,
  });

  @override
  /// Renders the accessible button and its pressed feedback.
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final interactive = enabled && onPressed != null;
    final effectiveTone =
        tone ??
        SeedTopNavigationScope.maybeOf(context)?.tone ??
        SeedTopNavigationButtonTone.layer;

    final Color iconColor = !interactive
        ? colors.fg.disabled
        : (effectiveTone == SeedTopNavigationButtonTone.layer
              ? colors.fg.neutral
              : SeedPalette.staticWhite);

    return SeedPressable(
      enabled: interactive,
      semanticsLabel: semanticsLabel,
      focusBorderRadius: SeedBorderRadius.r2,
      onTap: onPressed,
      builder: (context, isPressed) => AnimatedContainer(
        duration: SeedDuration.colorTransition,
        curve: SeedCurves.easing,
        width: 44.0,
        height: 44.0,
        decoration: BoxDecoration(
          color: isPressed
              ? colors.bg.transparentPressed
              : colors.bg.transparent,
          borderRadius: SeedBorderRadius.r2,
        ),
        child: Center(
          child: IconTheme(
            data: IconThemeData(size: 24.0, color: iconColor),
            child: icon,
          ),
        ),
      ),
    );
  }
}

/// Dedicated text button for top navigation bars adhering to SEED Design.
///
/// Features 44px height, 10px horizontal padding, 8px corner radius,
/// `t5Medium` typography, and `bg.transparent-pressed` feedback.
class SeedTopNavigationTextButton extends StatelessWidget {
  /// Visible action label, also used as its accessible name.
  final String text;
  /// Activation callback; null disables interactivity.
  final VoidCallback? onPressed;
  /// Optional tone override of the nearest [SeedTopNavigationScope].
  final SeedTopNavigationButtonTone? tone;
  /// Enables interaction when [onPressed] is also non-null; defaults to true.
  final bool enabled;
  /// Optional maximum button width; excess text is truncated with ellipsis.
  final double? maxWidth;

  /// Creates a top-navigation text action with a 44-pixel minimum height.
  ///
  /// [tone] inherits from [SeedTopNavigationScope] by default. [enabled]
  /// defaults to true and [maxWidth] defaults to unconstrained width.
  /// An optional `key` preserves Flutter widget identity.
  const SeedTopNavigationTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.tone,
    this.enabled = true,
    this.maxWidth,
  });

  @override
  /// Renders the labeled action with SEED pressed and disabled states.
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;
    final interactive = enabled && onPressed != null;
    final effectiveTone =
        tone ??
        SeedTopNavigationScope.maybeOf(context)?.tone ??
        SeedTopNavigationButtonTone.layer;

    final Color labelColor = !interactive
        ? colors.fg.disabled
        : (effectiveTone == SeedTopNavigationButtonTone.layer
              ? colors.fg.neutral
              : SeedPalette.staticWhite);

    final textWidget = Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      // React clamps the app bar label between 1.0x and 1.2x of its size.
      textScaler: MediaQuery.textScalerOf(context)
          .clamp(minScaleFactor: 1.0, maxScaleFactor: 1.2),
      style: typography.t5Medium.copyWith(color: labelColor),
    );

    return SeedPressable(
      enabled: interactive,
      semanticsLabel: text,
      focusBorderRadius: SeedBorderRadius.r2,
      onTap: onPressed,
      builder: (context, isPressed) => AnimatedContainer(
        duration: SeedDuration.colorTransition,
        curve: SeedCurves.easing,
        constraints: BoxConstraints(
          minHeight: 44.0,
          maxWidth: maxWidth ?? double.infinity,
        ),
        padding: const EdgeInsets.symmetric(horizontal: SeedDimension.x2_5),
        decoration: BoxDecoration(
          color: isPressed
              ? colors.bg.transparentPressed
              : colors.bg.transparent,
          borderRadius: SeedBorderRadius.r2,
        ),
        // Shrink-wrap the label. A container alignment would expand the
        // button to the full width of a loosely constrained slot.
        child: Align(widthFactor: 1.0, heightFactor: 1.0, child: textWidget),
      ),
    );
  }
}
