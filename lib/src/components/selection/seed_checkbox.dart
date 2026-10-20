import 'package:material_ui/material_ui.dart';

import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/motion/seed_motion.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';

/// Shape of [SeedCheckbox].
enum SeedCheckboxShape { square, ghost }

/// Size of [SeedCheckbox].
enum SeedCheckboxSize {
  medium,
  large;

  double get markSize => this == SeedCheckboxSize.medium ? 20.0 : 24.0;
}

/// Checkbox mark graphic component of SEED Design System.
class SeedCheckmark extends StatelessWidget {
  final bool? value;
  final SeedCheckboxShape shape;
  final SeedCheckboxSize size;
  final bool enabled;
  final bool pressed;

  const SeedCheckmark({
    super.key,
    required this.value,
    this.shape = SeedCheckboxShape.square,
    this.size = SeedCheckboxSize.medium,
    this.enabled = true,
    this.pressed = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final bool isChecked = value == true;
    final bool isIndeterminate = value == null;
    final bool isActive = isChecked || isIndeterminate;

    Color bgColor;
    Color strokeColor;
    Color iconColor;

    if (shape == SeedCheckboxShape.ghost) {
      bgColor = pressed
          ? (isActive ? colors.bg.neutralWeak : colors.bg.transparentPressed)
          : colors.bg.transparent;
      strokeColor = colors.bg.transparent;
      iconColor = !enabled
          ? colors.fg.disabled
          : isActive
          ? colors.fg.neutral
          : colors.fg.placeholder;
    } else if (!enabled) {
      bgColor = colors.bg.disabled;
      strokeColor = colors.stroke.neutralMuted;
      iconColor = colors.fg.disabled;
    } else {
      bgColor = isActive
          ? (pressed ? colors.bg.neutralSolidPressed : colors.bg.neutralSolid)
          : pressed
          ? colors.bg.transparentPressed
          : colors.bg.transparent;
      strokeColor = isActive
          ? colors.bg.transparent
          : colors.stroke.neutralWeak;
      iconColor = colors.fg.onNeutralSolid;
    }

    return Container(
      width: size.markSize,
      height: size.markSize,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: shape == SeedCheckboxShape.square
            ? SeedBorderRadius.r1
            : null,
        shape: shape == SeedCheckboxShape.ghost
            ? BoxShape.circle
            : BoxShape.rectangle,
        border: shape == SeedCheckboxShape.square && !(enabled && isActive)
            ? Border.all(color: strokeColor)
            : null,
      ),
      alignment: Alignment.center,
      child: isIndeterminate
          ? Container(
              width: size.markSize * 0.5,
              height: 2.0,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: SeedBorderRadius.full,
              ),
            )
          : isChecked || shape == SeedCheckboxShape.ghost
          ? Icon(
              Icons.check_rounded,
              size: shape == SeedCheckboxShape.ghost
                  ? (size == SeedCheckboxSize.medium ? 14 : 18)
                  : (size == SeedCheckboxSize.medium ? 12 : 14),
              color: iconColor,
            )
          : null,
    );
  }
}

/// Checkbox with label component of SEED Design System.
class SeedCheckbox extends StatelessWidget {
  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final String? label;
  final Widget? customLabel;
  final SeedCheckboxShape shape;
  final SeedCheckboxSize size;
  final bool enabled;
  final String? semanticsLabel;
  final FocusNode? focusNode;
  final bool tristate;

  const SeedCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.customLabel,
    this.shape = SeedCheckboxShape.square,
    this.size = SeedCheckboxSize.medium,
    this.enabled = true,
    this.semanticsLabel,
    this.focusNode,
    this.tristate = false,
  });

  void _handleTap() {
    if (!enabled || onChanged == null) return;
    if (tristate) {
      if (value == false) {
        onChanged!(true);
      } else if (value == true) {
        onChanged!(null);
      } else {
        onChanged!(false);
      }
    } else {
      onChanged!(value != true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;

    final TextStyle textStyle =
        (size == SeedCheckboxSize.medium
                ? typography.t4Regular
                : typography.t5Regular)
            .copyWith(
              color: enabled && onChanged != null
                  ? colors.fg.neutral
                  : colors.fg.disabled,
            );

    Widget mark(bool pressed) => AnimatedScale(
      scale: pressed
          ? SeedScaleCalculator.calculateScale(
              width: size.markSize,
              height: size.markSize,
              disableAnimations: MediaQuery.disableAnimationsOf(context),
            )
          : 1,
      duration: SeedDuration.pressedScale,
      curve: SeedCurves.pressedScale,
      child: SeedCheckmark(
        value: value,
        shape: shape,
        size: size,
        enabled: enabled && onChanged != null,
        pressed: pressed,
      ),
    );

    if (label == null && customLabel == null) {
      return SeedPressable(
        enabled: enabled && onChanged != null,
        enableScale: false,
        semanticButton: false,
        semanticsLabel: semanticsLabel,
        focusNode: focusNode,
        checked: value,
        mixed: value == null,
        onTap: _handleTap,
        builder: (context, pressed) => SizedBox(
          width: 44,
          height: 44,
          child: Center(child: mark(pressed)),
        ),
      );
    }

    return SeedPressable(
      enabled: enabled && onChanged != null,
      enableScale: false,
      semanticButton: false,
      semanticsLabel: semanticsLabel,
      focusNode: focusNode,
      checked: value,
      mixed: value == null,
      onTap: _handleTap,
      builder: (context, pressed) => ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            mark(pressed),
            const SizedBox(width: SeedDimension.x2),
            if (customLabel != null)
              customLabel!
            else if (label != null)
              Flexible(child: Text(label!, style: textStyle)),
          ],
        ),
      ),
    );
  }
}
