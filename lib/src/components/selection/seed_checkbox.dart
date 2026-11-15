import '../../foundations/feedback/seed_control.dart';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/semantics.dart' show SemanticsValidationResult;

import '../../foundations/colors/seed_palette.dart';
import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/motion/seed_motion.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
import '../../foundations/feedback/seed_touch_target.dart';

/// Visual style of the checkbox mark.
enum SeedCheckboxShape {
  /// Square bordered control.
  square,

  /// Borderless check glyph.
  ghost,
}

/// The official name of the checkbox style prop.
typedef SeedCheckboxVariant = SeedCheckboxShape;

/// Size of [SeedCheckbox].
enum SeedCheckboxSize {
  /// 20-pixel mark.
  medium,

  /// 24-pixel mark.
  large;

  /// Visual width and height of the checkbox mark.
  double get markSize => this == SeedCheckboxSize.medium ? 20.0 : 24.0;
}

/// Checkbox mark graphic component of SEED Design System.
class SeedCheckmark extends StatelessWidget {
  /// Mark state: true checked, false unchecked, null indeterminate.
  final bool? value;

  /// Visual style, square by default.
  final SeedCheckboxVariant variant;

  /// Deprecated alias of [variant].
  @Deprecated('Use variant instead.')
  SeedCheckboxShape get shape => variant;

  /// Mark dimensions, medium by default.
  final SeedCheckboxSize size;

  /// Whether the mark displays its enabled state.
  final bool enabled;

  /// Brand or neutral color treatment, brand by default.
  final SeedControlTone tone;

  /// Whether the pressed-state colors should be painted.
  final bool pressed;

  /// Creates only the checkbox graphic, without a touch or semantics wrapper.
  ///
  /// The [shape] input is a deprecated alias of [variant]. Prefer [SeedCheckbox]
  /// when a focusable, interactive control is needed.
  const SeedCheckmark({
    super.key,
    required this.value,
    SeedCheckboxVariant? variant,
    @Deprecated('Use variant instead.') SeedCheckboxShape? shape,
    this.size = SeedCheckboxSize.medium,
    this.enabled = true,
    this.tone = SeedControlTone.brand,
    this.pressed = false,
  }) : variant = variant ?? shape ?? SeedCheckboxShape.square,
       assert(variant == null || shape == null);

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

    if (variant == SeedCheckboxShape.ghost) {
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
      strokeColor = colors.stroke.neutralWeak;
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
        borderRadius: SeedBorderRadius.r1,
        border: variant == SeedCheckboxShape.square && !(enabled && isActive)
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
          : isChecked || variant == SeedCheckboxShape.ghost
          ? Icon(
              Icons.check_rounded,
              size: variant == SeedCheckboxShape.ghost
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
///
/// [checked] is parent-controlled when non-null. Otherwise the checkbox
/// starts at [defaultChecked]; [onCheckedChange] reports the next bool.
/// [indeterminate] is independent of checked state, as in React.
/// The deprecated [value] API preserves nullable Flutter tristate behavior.
class SeedCheckbox extends StatefulWidget {
  /// Builds an interactive checkbox, optionally with visible or custom text.
  ///
  /// [value] and [onChanged] are compatibility inputs. Legacy null [value]
  /// represents the mixed state, while omitting [value] selects the React
  /// checked/defaultChecked semantics. Use [tristate] only with legacy [value].
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
    SeedCheckboxVariant? variant,
    @Deprecated('Use variant instead.') SeedCheckboxShape? shape,
    this.size = SeedCheckboxSize.medium,
    this.enabled = true,
    this.tone = SeedControlTone.brand,
    this.semanticsLabel,
    this.focusNode,
    this.tristate = false,
    this.weight = SeedLabelWeight.regular,
    this.invalid = false,
    this.required = false,
  }) : _legacyValue = value,
       variant = variant ?? shape ?? SeedCheckboxShape.square,
       assert(variant == null || shape == null),
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

  /// Parent-controlled checked flag; null selects internal state.
  final bool? checked;

  /// Initial checked flag for an uncontrolled checkbox; false by default.
  final bool defaultChecked;

  /// Called with the proposed next checked flag.
  final ValueChanged<bool>? onCheckedChange;

  /// Shows the mixed-state dash without changing [checked].
  final bool indeterminate;
  final Object? _legacyValue;
  bool get _legacy => !identical(_legacyValue, _checkboxValueOmitted);
  /// Legacy tristate value: true, false or null (mixed).
  @Deprecated('Use checked and indeterminate instead.')
  bool? get value => _legacy
      ? _legacyValue as bool?
      : (indeterminate ? null : checked ?? defaultChecked);
  /// Legacy nullable callback supporting the tristate cycle.
  @Deprecated('Use onCheckedChange instead.')
  final ValueChanged<bool?>? onChanged;

  /// Optional visible label.
  final String? label;

  /// Custom label widget; overrides the plain [label] rendering.
  final Widget? customLabel;

  /// Checkbox visual style, square by default.
  final SeedCheckboxVariant variant;

  /// Deprecated spelling of [variant].
  @Deprecated('Use variant instead.')
  SeedCheckboxShape get shape => variant;

  /// Checkbox mark size; medium by default.
  final SeedCheckboxSize size;

  /// Whether interaction is enabled, true by default.
  final bool enabled;

  /// Brand or neutral checkbox colors, brand by default.
  final SeedControlTone tone;

  /// Optional accessible name for the control.
  final String? semanticsLabel;

  /// Optional caller-managed focus node.
  final FocusNode? focusNode;

  /// Exposed to assistive technology, as the official hidden input does.
  final bool invalid, required;

  /// Flutter compatibility mode; use independent indeterminate in new code.
  final bool tristate;
  /// Visible label weight, regular by default.
  final SeedLabelWeight weight;

  /// Creates state for checked value and mark interaction.
  @override
  State<SeedCheckbox> createState() => _SeedCheckboxState();
}

class _SeedCheckboxState extends State<SeedCheckbox> {
  late bool _checked = widget.defaultChecked;
  @override
  Widget build(BuildContext context) {
    final checked = widget.checked ?? _checked;
    final control = _SeedCheckboxControl(
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
      variant: widget.variant,
      size: widget.size,
      enabled: widget.enabled,
      tone: widget.tone,
      semanticsLabel: widget.semanticsLabel,
      focusNode: widget.focusNode,
      tristate: widget._legacy && widget.tristate,
      weight: widget.weight,
    );
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
}

/// Checkbox with label component of SEED Design System.
class _SeedCheckboxControl extends StatelessWidget {
  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final String? label;
  final Widget? customLabel;
  final SeedCheckboxVariant variant;
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
    this.variant = SeedCheckboxShape.square,
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
        variant: variant,
        tone: tone,
        size: size,
        enabled:
            enabled && onChanged != null && SeedControlScope.enabledOf(context),
        pressed: pressed,
      ),
    );

    if (label == null && customLabel == null) {
      // The control lays out at its official size with a 44px touch target.
      return SeedTouchTarget(
        visualSize: Size.square(size.markSize),
        targetSize: const Size.square(44),
        child: SeedPressable(
          enabled:
              enabled &&
              onChanged != null &&
              SeedControlScope.enabledOf(context),
          enableScale: false,
          semanticButton: false,
          activateOnEnter: false,
          paintFocusRing: false,
          semanticsLabel: semanticsLabel,
          focusNode: focusNode,
          checked: value,
          mixed: value == null,
          onTap: _handleTap,
          builder: (context, pressed) => Center(
            child: SeedControlFocusRing(
              borderRadius: SeedBorderRadius.r1,
              child: mark(
                pressed,
                SeedInteractionState.maybeOf(context)?.pressed ?? false,
              ),
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
      activateOnEnter: false,
      paintFocusRing: false,
      semanticsLabel: semanticsLabel,
      focusNode: focusNode,
      checked: value,
      mixed: value == null,
      onTap: _handleTap,
      builder: (context, pressed) {
        final rootHeight = size == SeedCheckboxSize.medium
            ? SeedDimension.x8
            : SeedDimension.x9;
        final focusedMark = SeedControlFocusRing(
          borderRadius: SeedBorderRadius.r1,
          child: mark(
            pressed,
            SeedInteractionState.maybeOf(context)?.pressed ?? false,
          ),
        );
        // Official checkbox recipe: the root is `align-items: flex-start`;
        // the mark and a text label each get a top margin that centers them
        // on the first line, so wrapped labels keep the mark on line one.
        final topAligned = customLabel == null;
        final labelLineHeight =
            MediaQuery.textScalerOf(context).scale(textStyle.fontSize!) *
            (textStyle.height ?? 1);
        // CSS label margin-top is `rootHeight / 2 - lineHeight / 2` and may
        // go negative at large text; moving the mark down by that amount
        // keeps both centered on the first line without overflowing the row.
        final labelShift = (rootHeight - labelLineHeight) / 2;
        final markTop =
            (rootHeight - size.markSize) / 2 - (labelShift < 0 ? labelShift : 0);
        final labelTop = labelShift < 0 ? 0.0 : labelShift;
        return ConstrainedBox(
          constraints: BoxConstraints(minHeight: rootHeight),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: topAligned
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              if (topAligned)
                Padding(
                  padding: EdgeInsets.only(
                    top: markTop,
                  ),
                  child: focusedMark,
                )
              else
                focusedMark,
              const SizedBox(width: SeedDimension.x2),
              if (customLabel != null)
                customLabel!
              else if (label != null)
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: labelTop,
                    ),
                    child: Text(label!, style: textStyle),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// The official `CheckboxGroup`: stacks checkboxes vertically with the
/// group's 4px gap.
///
/// It only lays the options out. For a labelled group with a description or
/// an error, wrap it in a [SeedFieldset].
class SeedCheckboxGroup extends StatelessWidget {
  /// Creates a vertical checkbox group from [children].
  const SeedCheckboxGroup({super.key, required this.children});

  /// The checkboxes, in order.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: SeedDimension.x1,
    children: children,
  );
}
