import '../../foundations/feedback/seed_control.dart';

import 'package:material_ui/material_ui.dart';

import '../../foundations/colors/seed_palette.dart';
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
  final SeedControlTone tone;
  final bool pressed;

  const SeedCheckmark({
    super.key,
    required this.value,
    this.shape = SeedCheckboxShape.square,
    this.size = SeedCheckboxSize.medium,
    this.enabled = true,
    this.tone = SeedControlTone.brand,
    this.pressed = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = this.enabled && SeedControlScope.enabledOf(context);
    final colors = context.seedColor;
    final bool isChecked = value == true;
    final bool isIndeterminate = value == null;
    final bool isActive = isChecked || isIndeterminate;

    Color bgColor;
    Color strokeColor;
    Color iconColor;

    if (shape == SeedCheckboxShape.ghost) {
      bgColor = enabled && pressed
          ? (isActive
                ? (tone == SeedControlTone.brand
                      ? (colors.isDark
                            ? SeedPalette.carrot200Dark
                            : SeedPalette.carrot200Light)
                      : (colors.isDark
                            ? SeedPalette.gray200Dark
                            : SeedPalette.gray200Light))
                : colors.bg.transparentPressed)
          : colors.bg.transparent;
      strokeColor = colors.bg.transparent;
      iconColor = !enabled
          ? colors.fg.disabled
          : isActive
          ? (tone == SeedControlTone.brand
                ? colors.fg.brand
                : colors.fg.neutral)
          : colors.fg.placeholder;
    } else if (!enabled) {
      bgColor = colors.bg.disabled;
      strokeColor = colors.stroke.neutralMuted;
      iconColor = colors.fg.disabled;
    } else {
      bgColor = isActive
          ? (pressed
                ? (tone == SeedControlTone.brand
                      ? colors.bg.brandSolidPressed
                      : colors.bg.neutralSolidPressed)
                : (tone == SeedControlTone.brand
                      ? colors.bg.brandSolid
                      : colors.bg.neutralSolid))
          : pressed
          ? colors.bg.transparentPressed
          : colors.bg.transparent;
      strokeColor = isActive
          ? colors.bg.transparent
          : colors.stroke.neutralWeak;
      iconColor = tone == SeedControlTone.brand
          ? colors.fg.onBrandSolid
          : colors.fg.onNeutralSolid;
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

// Dart needs a sentinel to distinguish an omitted legacy value from explicit
// value: null, which has always meant indeterminate.
const _checkboxValueOmitted = Object();

/// Checkbox with React checked/defaultChecked ownership and independent mixed state.
/// The deprecated value API preserves nullable Flutter tristate behavior.
class SeedCheckbox extends StatefulWidget {
  const SeedCheckbox({
    super.key,
    this.checked,
    this.defaultChecked = false,
    this.onCheckedChange,
    this.indeterminate = false,
    @Deprecated('Use checked and indeterminate instead.')
    Object? value = _checkboxValueOmitted,
    @Deprecated('Use onCheckedChange instead.') this.onChanged,
    this.label,
    this.customLabel,
    this.shape = SeedCheckboxShape.square,
    this.size = SeedCheckboxSize.medium,
    this.enabled = true,
    this.tone = SeedControlTone.brand,
    this.semanticsLabel,
    this.focusNode,
    this.tristate = false,
    this.weight = SeedLabelWeight.regular,
  }) : _legacyValue = value,
       assert(
         identical(value, _checkboxValueOmitted) ||
             value == null ||
             value is bool,
       ),
       assert(
         identical(value, _checkboxValueOmitted) ||
             (checked == null &&
                 !defaultChecked &&
                 !indeterminate &&
                 onCheckedChange == null),
       ),
       assert(onChanged == null || onCheckedChange == null),
       assert(!tristate || !identical(value, _checkboxValueOmitted));

  final bool? checked;
  final bool defaultChecked;
  final ValueChanged<bool>? onCheckedChange;
  final bool indeterminate;
  final Object? _legacyValue;
  bool get _legacy => !identical(_legacyValue, _checkboxValueOmitted);
  @Deprecated('Use checked and indeterminate instead.')
  bool? get value => _legacy
      ? _legacyValue as bool?
      : (indeterminate ? null : checked ?? defaultChecked);
  @Deprecated('Use onCheckedChange instead.')
  final ValueChanged<bool?>? onChanged;
  final String? label;
  final Widget? customLabel;
  final SeedCheckboxShape shape;
  final SeedCheckboxSize size;
  final bool enabled;
  final SeedControlTone tone;
  final String? semanticsLabel;
  final FocusNode? focusNode;

  /// Flutter compatibility mode; use independent indeterminate in new code.
  final bool tristate;
  final SeedLabelWeight weight;

  @override
  State<SeedCheckbox> createState() => _SeedCheckboxState();
}

class _SeedCheckboxState extends State<SeedCheckbox> {
  late bool _checked = widget.defaultChecked;
  @override
  Widget build(BuildContext context) {
    final checked = widget.checked ?? _checked;
    return _SeedCheckboxControl(
      value: widget._legacy
          ? widget._legacyValue as bool?
          : (widget.indeterminate ? null : checked),
      onChanged: widget._legacy
          ? widget.onChanged
          : (_) {
              final next = !checked;
              if (widget.checked == null) setState(() => _checked = next);
              widget.onCheckedChange?.call(next);
              widget.onChanged?.call(next);
            },
      label: widget.label,
      customLabel: widget.customLabel,
      shape: widget.shape,
      size: widget.size,
      enabled: widget.enabled,
      tone: widget.tone,
      semanticsLabel: widget.semanticsLabel,
      focusNode: widget.focusNode,
      tristate: widget._legacy && widget.tristate,
      weight: widget.weight,
    );
  }
}

/// Checkbox with label component of SEED Design System.
class _SeedCheckboxControl extends StatelessWidget {
  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final String? label;
  final Widget? customLabel;
  final SeedCheckboxShape shape;
  final SeedCheckboxSize size;
  final bool enabled;
  final SeedControlTone tone;
  final String? semanticsLabel;
  final FocusNode? focusNode;
  final bool tristate;
  final SeedLabelWeight weight;

  const _SeedCheckboxControl({
    required this.value,
    required this.onChanged,
    this.label,
    this.customLabel,
    this.shape = SeedCheckboxShape.square,
    this.size = SeedCheckboxSize.medium,
    this.enabled = true,
    this.tone = SeedControlTone.brand,
    this.semanticsLabel,
    this.focusNode,
    this.tristate = false,
    this.weight = SeedLabelWeight.regular,
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
    final enabled = this.enabled && SeedControlScope.enabledOf(context);
    final colors = context.seedColor;
    final typography = context.seedTypography;

    final TextStyle textStyle =
        (size == SeedCheckboxSize.medium
                ? typography.t4Regular
                : typography.t5Regular)
            .copyWith(
              fontWeight: weight == SeedLabelWeight.bold
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: enabled && onChanged != null
                  ? colors.fg.neutral
                  : colors.fg.disabled,
            );

    Widget mark(bool pressed, bool scalePressed) => AnimatedScale(
      scale: scalePressed
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
        tone: tone,
        size: size,
        enabled:
            enabled && onChanged != null && SeedControlScope.enabledOf(context),
        pressed: pressed,
      ),
    );

    if (label == null && customLabel == null) {
      return SeedPressable(
        enabled:
            enabled && onChanged != null && SeedControlScope.enabledOf(context),
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
          child: Center(
            child: mark(
              pressed,
              SeedInteractionState.maybeOf(context)?.pressed ?? false,
            ),
          ),
        ),
      );
    }

    return SeedPressable(
      enabled:
          enabled && onChanged != null && SeedControlScope.enabledOf(context),
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
            mark(
              pressed,
              SeedInteractionState.maybeOf(context)?.pressed ?? false,
            ),
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
