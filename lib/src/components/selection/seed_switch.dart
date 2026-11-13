import '../../foundations/feedback/seed_control.dart';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/semantics.dart' show SemanticsValidationResult;

import '../../foundations/colors/seed_palette.dart';
import '../../foundations/motion/seed_motion.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';
import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
import '../../foundations/feedback/seed_touch_target.dart';

/// Size of [SeedSwitch].
enum SeedSwitchSize {
  /// Compact track, 26 × 16 logical pixels.
  size16,

  /// Medium track, 38 × 24 logical pixels.
  size24,

  /// Large track, 52 × 32 logical pixels.
  size32;

  /// Visual height of the switch track.
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

  /// Visual width of the switch track.
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

  /// Diameter of the circular switch thumb.
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

  /// Minimum control height before the outer 44-pixel touch target.
  double get minTouchHeight =>
      this == SeedSwitchSize.size16 ? 24.0 : trackHeight;
}

/// Standalone switch mark with a 44-pixel touch target when interactive.
///
/// [checked], [defaultChecked] and [onCheckedChange] match the React Switch
/// contract. [value], [defaultValue] and [onChanged] remain deprecated aliases.
class SeedSwitchMark extends StatefulWidget {
  /// Deprecated alias of [checked].
  @Deprecated('Use checked instead.')
  final bool? value;

  /// Deprecated alias of [defaultChecked].
  @Deprecated('Use defaultChecked instead.')
  final bool defaultValue;

  /// Deprecated alias of [onCheckedChange].
  @Deprecated('Use onCheckedChange instead.')
  final ValueChanged<bool>? onChanged;

  /// Parent-controlled checked state, or null for internal state.
  bool? get checked => value;

  /// Initial checked state when uncontrolled; defaults to false.
  bool get defaultChecked => defaultValue;

  /// Notifies the proposed next checked state.
  ValueChanged<bool>? get onCheckedChange => onChanged;

  /// Visual size, default [SeedSwitchSize.size32].
  final SeedSwitchSize size;

  /// Whether interaction is allowed; defaults to true.
  final bool enabled;

  /// Brand or neutral color treatment, brand by default.
  final SeedControlTone tone;

  /// Accessible label for the standalone switch.
  final String? semanticsLabel;

  /// Optional externally managed keyboard focus node.
  final FocusNode? focusNode;

  /// False when a containing row owns interaction and accessibility.
  final bool interactive;

  /// Creates a switch mark, initially unchecked unless specified otherwise.
  ///
  /// Set [interactive] to false when another control owns focus and input.
  /// Supplying both official and deprecated forms of the same input is invalid.
  const SeedSwitchMark({
    super.key,
    bool? checked,
    @Deprecated('Use checked instead.') bool? value,
    bool? defaultChecked,
    @Deprecated('Use defaultChecked instead.') bool? defaultValue,
    ValueChanged<bool>? onCheckedChange,
    @Deprecated('Use onCheckedChange instead.') ValueChanged<bool>? onChanged,
    this.size = SeedSwitchSize.size32,
    this.enabled = true,
    this.tone = SeedControlTone.brand,
    this.semanticsLabel,
    this.focusNode,
    this.interactive = true,
  }) : value = checked ?? value,
       defaultValue = defaultChecked ?? defaultValue ?? false,
       onChanged = onCheckedChange ?? onChanged,
       assert(checked == null || value == null),
       assert(defaultChecked == null || defaultValue == null),
       assert(onCheckedChange == null || onChanged == null);

  /// Creates state for uncontrolled toggle handling.
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
      return SeedControlFocusRing(
        borderRadius: BorderRadius.circular(999),
        child: _SeedSwitchGraphic(
          value: _checked,
          tone: widget.tone,
          pressed: SeedInteractionState.maybeOf(context)?.pressed ?? false,
          size: widget.size,
          enabled: widget.enabled && SeedControlScope.enabledOf(context),
        ),
      );
    }
    // A controlled switch without a callback is still enabled and focusable,
    // as in React's SwitchRoot. Taps simply leave its controlled value intact.
    final interactive = widget.enabled && SeedControlScope.enabledOf(context);
    // The control lays out at its official size with a 44px touch target.
    return SeedTouchTarget(
      visualSize: Size(widget.size.trackWidth, widget.size.trackHeight),
      targetSize: Size(
        widget.size.trackWidth < 44 ? 44 : widget.size.trackWidth,
        44,
      ),
      child: SeedPressable(
        enabled: interactive,
        semanticButton: false,
        activateOnEnter: false,
        paintFocusRing: false,
        toggled: _checked,
        semanticsLabel: widget.semanticsLabel,
        focusNode: widget.focusNode,
        enableScale: false,
        onTap: _toggle,
        builder: (context, pressed) => Center(
          child: SeedControlFocusRing(
            borderRadius: BorderRadius.circular(999),
            child: _SeedSwitchGraphic(
              value: _checked,
              tone: widget.tone,
              pressed: pressed,
              size: widget.size,
              enabled: interactive,
            ),
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
            // The brand checked track keeps its brand color when disabled;
            // the disabled opacity above provides the muted appearance.
            // Neutral checked controls intentionally turn gray when disabled.
            color: value && (enabled || tone == SeedControlTone.brand)
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
///
/// Checked state is parent-owned when [checked] is non-null; otherwise it
/// starts at [defaultChecked] and changes internally on activation.
class SeedSwitch extends StatefulWidget {
  /// Deprecated Flutter spelling of [checked].
  @Deprecated('Use checked instead.')
  final bool? value;

  /// Deprecated Flutter spelling of [defaultChecked].
  @Deprecated('Use defaultChecked instead.')
  final bool defaultValue;

  /// Deprecated Flutter spelling of [onCheckedChange].
  @Deprecated('Use onCheckedChange instead.')
  final ValueChanged<bool>? onChanged;

  /// Controlled state, or null for internal state.
  bool? get checked => value;

  /// Initial uncontrolled state (false by default).
  bool get defaultChecked => defaultValue;

  /// Callback proposing the new checked flag.
  ValueChanged<bool>? get onCheckedChange => onChanged;

  /// Optional visible text beside the switch mark.
  final String? label;

  /// Visual dimensions; defaults to [SeedSwitchSize.size32].
  final SeedSwitchSize size;

  /// Whether the user can toggle this switch.
  final bool enabled;

  /// Color treatment for checked and unchecked states.
  final SeedControlTone tone;

  /// Spoken control name, independent of visible [label].
  final String? semanticsLabel;

  /// Caller-owned focus node for keyboard navigation.
  final FocusNode? focusNode;

  /// Exposed to assistive technology, as the official hidden input does.
  final bool invalid, required;

  /// Constructs a switch with optional [label] and accessible form state.
  ///
  /// [invalid] and [required] annotate native Flutter semantics, defaulting
  /// to false. Official inputs cannot be combined with their old aliases.
  const SeedSwitch({
    super.key,
    bool? checked,
    @Deprecated('Use checked instead.') bool? value,
    bool? defaultChecked,
    @Deprecated('Use defaultChecked instead.') bool? defaultValue,
    ValueChanged<bool>? onCheckedChange,
    @Deprecated('Use onCheckedChange instead.') ValueChanged<bool>? onChanged,
    this.label,
    this.size = SeedSwitchSize.size32,
    this.enabled = true,
    this.tone = SeedControlTone.brand,
    this.semanticsLabel,
    this.focusNode,
    this.invalid = false,
    this.required = false,
  }) : value = checked ?? value,
       defaultValue = defaultChecked ?? defaultValue ?? false,
       onChanged = onCheckedChange ?? onChanged,
       assert(checked == null || value == null),
       assert(defaultChecked == null || defaultValue == null),
       assert(onCheckedChange == null || onChanged == null);

  /// Creates state for internally managed checked value.
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
    final control = _buildControl(context);
    return !widget.invalid && !widget.required
        ? control
        : Semantics(
            isRequired: widget.required ? true : null,
            validationResult: widget.invalid
                ? SemanticsValidationResult.invalid
                : SemanticsValidationResult.none,
            child: control,
          );
  }

  Widget _buildControl(BuildContext context) {
    if (widget.label == null) {
      return SeedSwitchMark(
        checked: _checked,
        tone: widget.tone,
        onCheckedChange: (_) => _toggle(),
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
    final rootHeight = widget.size == SeedSwitchSize.size32
        ? SeedDimension.x8
        : SeedDimension.x6;
    final labelLineHeight =
        MediaQuery.textScalerOf(context).scale(style.fontSize!) * style.height!;
    // CSS label margin-top is `rootHeight / 2 - lineHeight / 2` and may go
    // negative at large text; shift the mark down instead so both stay
    // centered on the first line without overflowing the row.
    final labelShift = (rootHeight - labelLineHeight) / 2;
    final markTop =
        (rootHeight - widget.size.trackHeight) / 2 -
        (labelShift < 0 ? labelShift : 0);
    final labelTop = labelShift < 0 ? 0.0 : labelShift;
    final interactive = widget.enabled && SeedControlScope.enabledOf(context);
    return SeedPressable(
      enabled: interactive,
      semanticButton: false,
      activateOnEnter: false,
      paintFocusRing: false,
      toggled: _checked,
      semanticsLabel: widget.semanticsLabel,
      focusNode: widget.focusNode,
      enableScale: false,
      onTap: _toggle,
      builder: (context, pressed) => ConstrainedBox(
        constraints: BoxConstraints(minHeight: rootHeight),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: switch (widget.size) {
            SeedSwitchSize.size16 => 6,
            SeedSwitchSize.size24 => 8,
            SeedSwitchSize.size32 => 10,
          },
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: markTop,
              ),
              child: SeedControlFocusRing(
                borderRadius: BorderRadius.circular(999),
                child: _SeedSwitchGraphic(
                  value: _checked,
                  tone: widget.tone,
                  size: widget.size,
                  enabled: interactive,
                  pressed: pressed,
                ),
              ),
            ),
            Flexible(
              child: Padding(
                padding: EdgeInsets.only(
                  top: labelTop,
                ),
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
            ),
          ],
        ),
      ),
    );
  }
}
