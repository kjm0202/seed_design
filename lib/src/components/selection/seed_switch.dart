import '../../foundations/feedback/seed_control.dart';

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
class SeedSwitchMark extends StatefulWidget {
  final bool? value;
  final bool defaultValue;
  final ValueChanged<bool>? onChanged;
  final SeedSwitchSize size;
  final bool enabled;
  final SeedControlTone tone;
  final String? semanticsLabel;
  final FocusNode? focusNode;

  /// False when a containing row owns interaction and accessibility.
  final bool interactive;

  const SeedSwitchMark({
    super.key,
    this.value,
    this.defaultValue = false,
    this.onChanged,
    this.size = SeedSwitchSize.size32,
    this.enabled = true,
    this.tone = SeedControlTone.brand,
    this.semanticsLabel,
    this.focusNode,
    this.interactive = true,
  });

  @override
  State<SeedSwitchMark> createState() => _SeedSwitchMarkState();
}

class _SeedSwitchMarkState extends State<SeedSwitchMark> {
  late bool _value = widget.defaultValue;
  bool get _checked => widget.value ?? _value;

  void _toggle() {
    final next = !_checked;
    if (widget.value == null) setState(() => _value = next);
    widget.onChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.interactive) {
      return _SeedSwitchGraphic(
        value: _checked,
        tone: widget.tone,
        pressed: SeedInteractionState.maybeOf(context)?.pressed ?? false,
        size: widget.size,
        enabled: widget.enabled && SeedControlScope.enabledOf(context),
      );
    }
    final interactive =
        widget.enabled &&
        (widget.value == null || widget.onChanged != null) &&
        SeedControlScope.enabledOf(context);
    return SeedPressable(
      enabled: interactive,
      semanticButton: false,
      toggled: _checked,
      semanticsLabel: widget.semanticsLabel,
      focusNode: widget.focusNode,
      enableScale: false,
      onTap: _toggle,
      builder: (context, pressed) => SizedBox(
        width: widget.size.trackWidth < 44 ? 44 : widget.size.trackWidth,
        height: 44,
        child: Center(
          child: _SeedSwitchGraphic(
            value: _checked,
            tone: widget.tone,
            pressed: pressed,
            size: widget.size,
            enabled: interactive,
          ),
        ),
      ),
    );
  }
}

class _SeedSwitchGraphic extends StatelessWidget {
  final bool value;
  final SeedSwitchSize size;
  final bool enabled;
  final SeedControlTone tone;
  final bool pressed;
  const _SeedSwitchGraphic({
    required this.value,
    required this.size,
    required this.enabled,
    this.tone = SeedControlTone.brand,
    this.pressed = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final reduce = MediaQuery.disableAnimationsOf(context);
    final duration = reduce ? Duration.zero : SeedDuration.d3;
    final colorDuration = reduce ? Duration.zero : SeedDuration.d1;
    final scaleDuration = reduce ? Duration.zero : SeedDuration.pressedScale;
    return AnimatedScale(
      duration: scaleDuration,
      curve: SeedCurves.pressedScale,
      scale: (SeedInteractionState.maybeOf(context)?.pressed ?? false)
          ? SeedScaleCalculator.calculateScale(
              width: size.trackWidth,
              height: size.trackHeight,
              disableAnimations: reduce,
            )
          : 1,
      child: Opacity(
        opacity: enabled ? 1 : 0.38,
        child: AnimatedContainer(
          duration: colorDuration,
          curve: SeedCurves.easing,
          width: size.trackWidth,
          height: size.trackHeight,
          padding: EdgeInsets.all((size.trackHeight - size.thumbSize) / 2),
          decoration: BoxDecoration(
            color: value && enabled
                ? (tone == SeedControlTone.brand
                      ? colors.bg.brandSolid
                      : colors.bg.neutralSolid)
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
                  color: tone == SeedControlTone.brand
                      ? (enabled && value
                            ? colors.fg.onBrandSolid
                            : SeedPalette.staticWhite)
                      : (enabled
                            ? colors.fg.onNeutralSolid
                            : SeedPalette.staticBlackAlpha700),
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
class SeedSwitch extends StatefulWidget {
  final bool? value;
  final bool defaultValue;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final SeedSwitchSize size;
  final bool enabled;
  final SeedControlTone tone;
  final String? semanticsLabel;
  final FocusNode? focusNode;

  const SeedSwitch({
    super.key,
    this.value,
    this.defaultValue = false,
    this.onChanged,
    this.label,
    this.size = SeedSwitchSize.size32,
    this.enabled = true,
    this.tone = SeedControlTone.brand,
    this.semanticsLabel,
    this.focusNode,
  });

  @override
  State<SeedSwitch> createState() => _SeedSwitchState();
}

class _SeedSwitchState extends State<SeedSwitch> {
  late bool _value = widget.defaultValue;
  bool get _checked => widget.value ?? _value;

  void _toggle() {
    final next = !_checked;
    if (widget.value == null) setState(() => _value = next);
    widget.onChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.label == null) {
      return SeedSwitchMark(
        value: widget.value,
        defaultValue: widget.defaultValue,
        tone: widget.tone,
        onChanged: widget.onChanged,
        size: widget.size,
        enabled: widget.enabled,
        semanticsLabel: widget.semanticsLabel,
        focusNode: widget.focusNode,
      );
    }
    final typography = context.seedTypography;
    final style = switch (widget.size) {
      SeedSwitchSize.size16 => typography.t3Medium,
      SeedSwitchSize.size24 => typography.t4Medium,
      SeedSwitchSize.size32 => typography.t5Medium,
    };
    final interactive =
        widget.enabled &&
        (widget.value == null || widget.onChanged != null) &&
        SeedControlScope.enabledOf(context);
    return SeedPressable(
      enabled: interactive,
      semanticButton: false,
      toggled: _checked,
      semanticsLabel: widget.semanticsLabel,
      focusNode: widget.focusNode,
      enableScale: false,
      onTap: _toggle,
      builder: (context, pressed) => ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SeedSwitchGraphic(
              value: _checked,
              tone: widget.tone,
              size: widget.size,
              enabled: interactive,
              pressed: pressed,
            ),
            SizedBox(
              width: switch (widget.size) {
                SeedSwitchSize.size16 => 6,
                SeedSwitchSize.size24 => 8,
                SeedSwitchSize.size32 => 10,
              },
            ),
            Flexible(
              child: Text(
                widget.label!,
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
