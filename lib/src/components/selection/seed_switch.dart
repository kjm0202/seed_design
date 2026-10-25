import 'package:material_ui/material_ui.dart';

import '../../foundations/colors/seed_palette.dart';
import '../../foundations/motion/seed_motion.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';

/// Size of [SeedSwitch].
enum SeedSwitchSize {
  size16,
  size24,
  size32;

  double get trackHeight {
    switch (this) {
      case SeedSwitchSize.size16:
        return 16.0;
      case SeedSwitchSize.size24:
        return 24.0;
      case SeedSwitchSize.size32:
        return 32.0;
    }
  }

  double get trackWidth {
    switch (this) {
      case SeedSwitchSize.size16:
        return 26.0;
      case SeedSwitchSize.size24:
        return 38.0;
      case SeedSwitchSize.size32:
        return 52.0;
    }
  }

  double get thumbSize {
    switch (this) {
      case SeedSwitchSize.size16:
        return 12.0;
      case SeedSwitchSize.size24:
        return 20.0;
      case SeedSwitchSize.size32:
        return 26.0;
    }
  }

  double get minTouchHeight =>
      this == SeedSwitchSize.size16 ? 24.0 : trackHeight;
}

/// Standalone interactive switch with a separate visual and touch target.
class SeedSwitchMark extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final SeedSwitchSize size;
  final bool enabled;
  final String? semanticsLabel;
  final FocusNode? focusNode;

  const SeedSwitchMark({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = SeedSwitchSize.size32,
    this.enabled = true,
    this.semanticsLabel,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) => SeedPressable(
    enabled: enabled && onChanged != null,
    semanticButton: false,
    toggled: value,
    semanticsLabel: semanticsLabel,
    focusNode: focusNode,
    enableScale: false,
    onTap: () => onChanged?.call(!value),
    builder: (context, pressed) => SizedBox(
      width: size.trackWidth < 44 ? 44 : size.trackWidth,
      height: 44,
      child: Center(
        child: _SeedSwitchGraphic(
          value: value,
          pressed: pressed,
          size: size,
          enabled: enabled && onChanged != null,
        ),
      ),
    ),
  );
}

class _SeedSwitchGraphic extends StatelessWidget {
  final bool value;
  final SeedSwitchSize size;
  final bool enabled;
  final bool pressed;
  const _SeedSwitchGraphic({
    required this.value,
    required this.size,
    required this.enabled,
    this.pressed = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : SeedDuration.d3;
    return AnimatedScale(
      duration: duration,
      curve: SeedCurves.pressedScale,
      scale: pressed
          ? SeedScaleCalculator.calculateScale(
              width: size.trackWidth,
              height: size.trackHeight,
              disableAnimations: MediaQuery.disableAnimationsOf(context),
            )
          : 1,
      child: Opacity(
        opacity: enabled ? 1 : 0.38,
        child: AnimatedContainer(
          duration: duration,
          curve: SeedCurves.easing,
          width: size.trackWidth,
          height: size.trackHeight,
          padding: EdgeInsets.all((size.trackHeight - size.thumbSize) / 2),
          decoration: BoxDecoration(
            color: value && enabled
                ? colors.bg.neutralSolid
                : (colors.isDark
                      ? SeedPalette.gray600Dark
                      : SeedPalette.gray600Light),
            borderRadius: SeedBorderRadius.full,
          ),
          child: AnimatedAlign(
            duration: duration,
            curve: SeedCurves.easing,
            alignment: value
                ? AlignmentDirectional.centerEnd
                : AlignmentDirectional.centerStart,
            child: AnimatedScale(
              scale: value ? 1 : 0.8,
              duration: duration,
              curve: SeedCurves.easing,
              child: Container(
                width: size.thumbSize,
                height: size.thumbSize,
                decoration: BoxDecoration(
                  color: enabled
                      ? colors.fg.onNeutralSolid
                      : SeedPalette.staticBlackAlpha700,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Switch whose label and mark form one focusable, accessible toggle.
class SeedSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final SeedSwitchSize size;
  final bool enabled;
  final String? semanticsLabel;
  final FocusNode? focusNode;

  const SeedSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.size = SeedSwitchSize.size32,
    this.enabled = true,
    this.semanticsLabel,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    if (label == null) {
      return SeedSwitchMark(
        value: value,
        onChanged: onChanged,
        size: size,
        enabled: enabled,
        semanticsLabel: semanticsLabel,
        focusNode: focusNode,
      );
    }
    final typography = context.seedTypography;
    final style = switch (size) {
      SeedSwitchSize.size16 => typography.t3Medium,
      SeedSwitchSize.size24 => typography.t4Medium,
      SeedSwitchSize.size32 => typography.t5Medium,
    };
    final interactive = enabled && onChanged != null;
    return SeedPressable(
      enabled: interactive,
      semanticButton: false,
      toggled: value,
      semanticsLabel: semanticsLabel,
      focusNode: focusNode,
      enableScale: false,
      onTap: () => onChanged?.call(!value),
      builder: (context, pressed) => ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SeedSwitchGraphic(
              value: value,
              size: size,
              enabled: interactive,
              pressed: pressed,
            ),
            SizedBox(
              width: switch (size) {
                SeedSwitchSize.size16 => 6,
                SeedSwitchSize.size24 => 8,
                SeedSwitchSize.size32 => 10,
              },
            ),
            Flexible(
              child: Text(
                label!,
                style: style.copyWith(
                  color: interactive
                      ? context.seedColor.fg.neutral
                      : context.seedColor.fg.neutral.withValues(
                          alpha: context.seedColor.fg.neutral.a * 0.58,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
