import 'package:material_ui/material_ui.dart';

import '../../foundations/colors/seed_color_scheme.dart';
import '../../foundations/colors/seed_palette.dart';
import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
import '../../foundations/motion/seed_motion.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';
import '../feedback/seed_progress_circle.dart';

/// Variant options for [SeedToggleButton].
enum SeedToggleButtonVariant {
  /// Filled brand background when off.
  brandSolid,

  /// Subdued neutral background.
  neutralWeak,
}

/// Size options for [SeedToggleButton].
enum SeedToggleButtonSize {
  /// 32 px high compact toggle.
  xsmall,
  /// 36 px high standard toggle.
  small;

  /// Minimum height for the size preset.
  double get height => this == SeedToggleButtonSize.xsmall ? 32.0 : 36.0;

  /// Icon dimensions (14 px) for both presets.
  double get iconSize => 14.0;

  /// Horizontal and vertical content insets for the size preset.
  EdgeInsets get padding {
    switch (this) {
      case SeedToggleButtonSize.xsmall:
        return const EdgeInsets.symmetric(
          horizontal: SeedDimension.x3_5,
          vertical: SeedDimension.x1_5,
        );
      case SeedToggleButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: SeedDimension.x4,
          vertical: SeedDimension.x2,
        );
    }
  }
}

/// Toggle Button component of SEED Design System.
///
/// Uses the official `pressed`, `defaultPressed` and `onPressedChange` state.
/// Supports `brandSolid` and `neutralWeak` variants, `xsmall` and `small` sizes,
/// loading state, and native scale feedback.
class SeedToggleButton extends StatefulWidget {
  /// Controlled pressed state; null uses the widget's internal state.
  final bool? pressed;
  /// Initial internal pressed value (false by default).
  final bool defaultPressed;
  /// Receives the next pressed value after user activation.
  final ValueChanged<bool>? onPressedChange;
  /// Optional text; when omitted [prefixIcon] must be supplied.
  final String? label;
  /// Icon displayed before [label].
  final Widget? prefixIcon;
  /// Icon displayed after [label].
  final Widget? suffixIcon;
  /// Visual treatment, defaulting to [SeedToggleButtonVariant.brandSolid].
  final SeedToggleButtonVariant variant;
  /// Size preset, defaulting to [SeedToggleButtonSize.small].
  final SeedToggleButtonSize size;
  /// Replaces visible content with a spinner.
  final bool loading;
  /// Blocks activation during loading when true (the default).
  final bool disableOnLoading;
  /// Allows interaction when true (the default).
  final bool enabled;
  /// Overrides the accessible name derived from [label].
  final String? semanticsLabel;

  /// Legacy selected-state getter; reports constructor configuration.
  @Deprecated('Use pressed or defaultPressed instead.')
  bool get selected => pressed ?? defaultPressed;
  /// Legacy callback getter; use [onPressedChange].
  @Deprecated('Use onPressedChange instead.')
  ValueChanged<bool>? get onSelectedChanged => onPressedChange;

  /// Creates a toggle button with controlled or internally managed state.
  ///
  /// [selected] and [onSelectedChanged] are deprecated constructor aliases
  /// for [pressed] and [onPressedChange], respectively. Alias pairs must not
  /// be passed together. The label or a leading icon is required.
  const SeedToggleButton({
    super.key,
    bool? pressed,
    @Deprecated('Use pressed instead.') bool? selected,
    this.defaultPressed = false,
    ValueChanged<bool>? onPressedChange,
    @Deprecated('Use onPressedChange instead.')
    ValueChanged<bool>? onSelectedChanged,
    this.label,
    this.prefixIcon,
    this.suffixIcon,
    this.variant = SeedToggleButtonVariant.brandSolid,
    this.size = SeedToggleButtonSize.small,
    this.loading = false,
    this.disableOnLoading = true,
    this.enabled = true,
    this.semanticsLabel,
  }) : pressed = pressed ?? selected,
       onPressedChange = onPressedChange ?? onSelectedChanged,
       assert(pressed == null || selected == null),
       assert(onPressedChange == null || onSelectedChanged == null),
       assert(
         label != null || prefixIcon != null,
         'Either label or prefixIcon must be specified.',
       );

  @override
  State<SeedToggleButton> createState() => _SeedToggleButtonState();
}

class _SeedToggleButtonState extends State<SeedToggleButton> {
  late bool _pressed = widget.defaultPressed;

  void _toggle(bool current) {
    final next = !current;
    if (widget.pressed == null) setState(() => _pressed = next);
    widget.onPressedChange?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;
    final selected = widget.pressed ?? _pressed;
    final size = widget.size;
    final label = widget.label;
    final loading = widget.loading;

    final TextStyle textStyle = (size == SeedToggleButtonSize.xsmall
        ? typography.t3Bold
        : typography.t4Bold);

    return SeedPressable(
      enabled:
          widget.enabled &&
          (!widget.disableOnLoading || !loading) &&
          (widget.pressed == null || widget.onPressedChange != null),
      toggled: selected,
      // The React toggle-button uses the full pill radius for both its body
      // and the focus-visible outline.
      focusBorderRadius: SeedBorderRadius.full,
      semanticsLabel: widget.semanticsLabel ?? label,
      onTap: () => _toggle(selected),
      builder: (context, isPressed) {
        final (bgColor, fgColor) = _resolveColors(
          colors: colors,
          isPressed: isPressed || loading,
          selected: selected,
          enabled: widget.enabled,
        );
        final gray500 = colors.isDark
            ? SeedPalette.gray500Dark
            : SeedPalette.gray500Light;

        final content = Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.prefixIcon != null) ...[
              IconTheme(
                data: IconThemeData(color: fgColor, size: size.iconSize),
                child: widget.prefixIcon!,
              ),
              if (label != null) const SizedBox(width: SeedDimension.x1),
            ],
            if (label != null)
              Text(label, style: textStyle.copyWith(color: fgColor)),
            if (widget.suffixIcon != null) ...[
              const SizedBox(width: SeedDimension.x1),
              IconTheme(
                data: IconThemeData(color: fgColor, size: size.iconSize),
                child: widget.suffixIcon!,
              ),
            ],
          ],
        );

        return AnimatedContainer(
          duration: SeedDuration.colorTransition,
          curve: SeedCurves.easing,
          constraints: BoxConstraints(minHeight: size.height),
          padding: size.padding,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: SeedBorderRadius.full,
          ),
          // React's LoadingIndicator hides the content in place and overlays
          // the spinner, so the button keeps its size.
          child: Stack(
            alignment: Alignment.center,
            children: [
              Visibility(
                visible: !loading,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: content,
              ),
              if (loading)
                SeedProgressCircle(
                  size: 14,
                  strokeWidth: 2,
                  color: fgColor,
                  trackColor:
                      widget.variant == SeedToggleButtonVariant.brandSolid &&
                          !selected
                      ? SeedPalette.staticWhiteAlpha300
                      : gray500,
                ),
            ],
          ),
        );
      },
    );
  }

  (Color bg, Color fg) _resolveColors({
    required SeedColorScheme colors,
    required bool isPressed,
    required bool selected,
    required bool enabled,
  }) {
    if (!enabled) {
      // The recipe's later loading rule overrides only the background.
      return (
        widget.loading
            ? (widget.variant == SeedToggleButtonVariant.brandSolid && !selected
                  ? colors.bg.brandSolidPressed
                  : colors.bg.neutralWeakPressed)
            : colors.bg.disabled,
        colors.fg.disabled,
      );
    }

    switch (widget.variant) {
      case SeedToggleButtonVariant.brandSolid:
        if (selected) {
          return (
            isPressed ? colors.bg.neutralWeakPressed : colors.bg.neutralWeak,
            colors.fg.neutral,
          );
        } else {
          return (
            isPressed ? colors.bg.brandSolidPressed : colors.bg.brandSolid,
            colors.fg.onBrandSolid,
          );
        }
      case SeedToggleButtonVariant.neutralWeak:
        return (
          isPressed ? colors.bg.neutralWeakPressed : colors.bg.neutralWeak,
          colors.fg.neutral,
        );
    }
  }
}
