import '../input/seed_field.dart';
import '../../foundations/feedback/seed_control.dart';
import '../../foundations/state/seed_uncontrolled_value.dart';

import 'package:material_ui/material_ui.dart';

import 'package:flutter/semantics.dart' show SemanticsValidationResult;

import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/colors/seed_palette.dart';
import '../../foundations/motion/seed_motion.dart';
import '../../theme/seed_theme.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
import '../../foundations/feedback/seed_touch_target.dart';

/// Size of [SeedRadio].
enum SeedRadioSize {
  /// 20-pixel outer mark.
  medium,

  /// 24-pixel outer mark.
  large;

  /// Diameter of the outer radio ring.
  double get diameter => this == SeedRadioSize.medium ? 20.0 : 24.0;

  /// Diameter of the inner selected dot.
  double get innerDiameter => this == SeedRadioSize.medium ? 8.0 : 10.0;
}

/// Radio option for a [SeedRadioGroup] or a Flutter [RadioGroup].
///
/// Selection follows the group's shared value. The optional [rowBuilder]
/// lets a parent row own its pressed surface and touch area.
class SeedRadio<T> extends StatefulWidget {
  /// Value represented by this option; compared with the active group value.
  final T value;

  /// Legacy direct group selection; normally supplied by [SeedRadioGroup].
  final T? groupValue;

  /// Standalone value-change handler; group handling takes precedence.
  final ValueChanged<T?>? onChanged;

  /// Optional visible text beside the mark.
  final String? label;

  /// Mark size, medium by default.
  final SeedRadioSize size;

  /// Regular or bold label emphasis.
  final SeedLabelWeight weight;

  /// Optional custom widget in place of [label].
  final Widget? customLabel;

  /// Builds the whole row around the mark, so one row owns the padding and the
  /// pressed surface, as a React list item with a radio prefix does.
  final Widget Function(BuildContext context, Widget mark)? rowBuilder;

  /// Whether the option can receive selection, true by default.
  final bool enabled;

  /// Brand or neutral mark colors, brand by default.
  final SeedControlTone tone;

  /// Optional spoken option name.
  final String? semanticsLabel;

  /// Optional caller-owned focus node.
  final FocusNode? focusNode;

  /// Exposed to assistive technology, as the official hidden input does.
  final bool invalid, required;

  /// Creates a radio option with the required [value].
  ///
  /// [invalid] and [required] default to false and are exposed through
  /// accessibility semantics. [groupValue] and [onChanged] also support legacy
  /// standalone use outside a [SeedRadioGroup].
  const SeedRadio({
    super.key,
    required this.value,
    this.groupValue,
    this.onChanged,
    this.label,
    this.size = SeedRadioSize.medium,
    this.weight = SeedLabelWeight.regular,
    this.customLabel,
    this.rowBuilder,
    this.enabled = true,
    this.tone = SeedControlTone.brand,
    this.semanticsLabel,
    this.focusNode,
    this.invalid = false,
    this.required = false,
  });

  /// Creates state that registers with Flutter's radio-group traversal.
  @override
  State<SeedRadio<T>> createState() => _SeedRadioState<T>();
}

class _SeedRadioState<T> extends State<SeedRadio<T>> with RadioClient<T> {
  final FocusNode _internalFocusNode = FocusNode();
  @override
  FocusNode get focusNode => widget.focusNode ?? _internalFocusNode;
  @override
  T get radioValue => widget.value;
  @override
  bool get tristate => false;
  bool _scopeEnabled = true;
  @override
  bool get enabled =>
      widget.enabled &&
      _scopeEnabled &&
      (registry != null || widget.onChanged != null);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scopeEnabled = SeedControlScope.enabledOf(context);
    registry = RadioGroup.maybeOf<T>(context);
  }

  @override
  void dispose() {
    registry = null;
    _internalFocusNode.dispose();
    super.dispose();
  }

  bool get _isSelected =>
      widget.value ==
      (registry != null ? registry!.groupValue : widget.groupValue);
  void _handleTap() {
    if (!enabled) return;
    (registry?.onChanged ?? widget.onChanged)?.call(widget.value);
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
    final colors = context.seedColor;
    final typography = context.seedTypography;

    final gray300 = colors.isDark
        ? SeedPalette.gray300Dark
        : SeedPalette.gray300Light;
    final Color strokeColor = !enabled
        ? (_isSelected ? gray300 : colors.stroke.neutralWeak)
        : (_isSelected
              ? colors.stroke.neutralContrast
              : colors.stroke.neutralWeak);

    final Color innerColor = !enabled
        ? gray300
        : (widget.tone == SeedControlTone.brand
              ? colors.fg.onBrandSolid
              : colors.fg.onNeutralSolid);

    Widget mark(bool pressed, bool scalePressed) => AnimatedScale(
      scale: scalePressed
          ? SeedScaleCalculator.calculateScale(
              width: widget.size.diameter,
              height: widget.size.diameter,
              disableAnimations: MediaQuery.disableAnimationsOf(context),
            )
          : 1,
      duration: SeedDuration.pressedScale,
      curve: SeedCurves.pressedScale,
      child: Container(
        width: widget.size.diameter,
        height: widget.size.diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled && _isSelected
              ? (pressed
                    ? (widget.tone == SeedControlTone.brand
                          ? colors.bg.brandSolidPressed
                          : colors.bg.neutralSolidPressed)
                    : (widget.tone == SeedControlTone.brand
                          ? colors.bg.brandSolid
                          : colors.bg.neutralSolid))
              : pressed
              ? colors.bg.transparentPressed
              : !enabled && !_isSelected
              ? gray300
              : colors.bg.transparent,
          border: enabled && _isSelected
              ? null
              : Border.all(color: strokeColor),
        ),
        alignment: Alignment.center,
        child: _isSelected
            ? Container(
                width: widget.size.innerDiameter + (enabled ? 0 : 2),
                height: widget.size.innerDiameter + (enabled ? 0 : 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: innerColor,
                ),
              )
            : null,
      ),
    );

    if (widget.label == null &&
        widget.customLabel == null &&
        widget.rowBuilder == null) {
      // The control lays out at its official size with a 44px touch target.
      return SeedTouchTarget(
        visualSize: Size.square(widget.size.diameter),
        targetSize: const Size.square(44),
        child: SeedPressable(
          enabled: enabled,
          enableScale: false,
          semanticButton: false,
          activateOnEnter: false,
          paintFocusRing: false,
          semanticsLabel: widget.semanticsLabel,
          focusNode: focusNode,
          checked: _isSelected,
          inMutuallyExclusiveGroup: true,
          onTap: _handleTap,
          builder: (context, pressed) => Center(
            child: SeedControlFocusRing(
              borderRadius: BorderRadius.circular(999),
              child: mark(
                pressed,
                SeedInteractionState.maybeOf(context)?.pressed ?? false,
              ),
            ),
          ),
        ),
      );
    }

    final TextStyle textStyle =
        (widget.size == SeedRadioSize.medium
                ? typography.t4Regular
                : typography.t5Regular)
            .copyWith(
              color: enabled ? colors.fg.neutral : colors.fg.disabled,
              fontWeight: widget.weight == SeedLabelWeight.bold
                  ? FontWeight.bold
                  : FontWeight.normal,
            );

    return SeedPressable(
      enabled: enabled,
      enableScale: false,
      semanticButton: false,
      activateOnEnter: false,
      paintFocusRing: widget.rowBuilder != null,
      focusRingInside: widget.rowBuilder != null,
      semanticsLabel: widget.semanticsLabel,
      focusNode: focusNode,
      checked: _isSelected,
      inMutuallyExclusiveGroup: true,
      onTap: _handleTap,
      builder: (context, pressed) => widget.rowBuilder != null
          ? widget.rowBuilder!(
              context,
              mark(
                pressed,
                SeedInteractionState.maybeOf(context)?.pressed ?? false,
              ),
            )
          : _labelledRow(context, textStyle, pressed, mark),
    );
  }

  // Official radio recipe: the root is `align-items: flex-start`; the mark
  // and a text label each get a top margin that centers them on the first
  // line, so wrapped labels keep the mark on line one. A custom label keeps
  // the previous centered composition.
  Widget _labelledRow(
    BuildContext context,
    TextStyle textStyle,
    bool pressed,
    Widget Function(bool pressed, bool scalePressed) mark,
  ) {
    final rootHeight = widget.size == SeedRadioSize.medium
        ? SeedDimension.x8
        : SeedDimension.x9;
    final topAligned = widget.customLabel == null;
    final labelLineHeight =
        MediaQuery.textScalerOf(context).scale(textStyle.fontSize!) *
        (textStyle.height ?? 1);
    // CSS label margin-top may go negative at large text; shift the mark
    // instead so both stay centered on the first line.
    final labelShift = (rootHeight - labelLineHeight) / 2;
    final markTop =
        (rootHeight - widget.size.diameter) / 2 -
        (labelShift < 0 ? labelShift : 0);
    final labelTop = labelShift < 0 ? 0.0 : labelShift;
    final focusedMark = SeedControlFocusRing(
      borderRadius: BorderRadius.circular(999),
      child: mark(
        pressed,
        SeedInteractionState.maybeOf(context)?.pressed ?? false,
      ),
    );
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
          Flexible(
            child:
                widget.customLabel ??
                Padding(
                  padding: EdgeInsets.only(
                    top: labelTop,
                  ),
                  child: Text(widget.label!, style: textStyle),
                ),
          ),
        ],
      ),
    );
  }
}

/// Provides native radio-group arrow navigation and a single Tab stop.
/// Existing SeedRadio(groupValue:, onChanged:) usage remains supported.
class SeedRadioGroup<T> extends StatelessWidget {
  /// Deprecated alias for [value].
  @Deprecated('Use value instead.')
  final T? groupValue;

  /// Parent-controlled group choice when non-null.
  T? get value => groupValue;

  /// Deprecated alias for [onValueChange].
  @Deprecated('Use onValueChange instead.')
  final ValueChanged<T?>? onChanged;

  /// Receives proposed selections from a child radio.
  ValueChanged<T?>? get onValueChange => onChanged;

  /// Subtree containing the options in this group.
  final Widget child;

  /// Creates a mutually exclusive radio group with native arrow navigation.
  ///
  /// When [controlled] is true, null [value] means no selection. Otherwise
  /// null allows [defaultValue] to seed internal form state. The group emits
  /// [onValueChange] on user input; [onChanged] is a deprecated alias.
  const SeedRadioGroup({
    super.key,
    T? value,
    @Deprecated('Use value instead.') T? groupValue,
    this.defaultValue,
    this.controlled = false,
    ValueChanged<T?>? onValueChange,
    @Deprecated('Use onValueChange instead.') ValueChanged<T?>? onChanged,
    required this.child,
    this.label,
    this.labelWeight = SeedFieldLabelWeight.medium,
    this.description,
    this.indicator,
    this.showRequiredIndicator = false,
    this.enabled = true,
  }) : groupValue = value ?? groupValue,
       assert(value == null || groupValue == null),
       onChanged = onValueChange ?? onChanged,
       assert(onValueChange == null || onChanged == null);

  /// Optional group label and supporting description.
  final String? label, description;

  /// The official `labelWeight`.
  final SeedFieldLabelWeight labelWeight;

  /// Optional trailing field indicator.
  final Widget? indicator;

  /// The official `showRequiredIndicator`: shows the Field required mark
  /// after [label]. Defaults to false. Visual/semantic only; validation is
  /// the caller's responsibility.
  final bool showRequiredIndicator;

  /// Enables all nested options; true by default.
  final bool enabled;

  /// Initial value of an uncontrolled group.
  final T? defaultValue;

  /// Holds selection in the parent even when [value] is null.
  final bool controlled;
  @override
  Widget build(BuildContext context) => SeedUncontrolledValue<T?>(
    controlled: controlled || groupValue != null,
    value: groupValue,
    initialValue: defaultValue,
    builder: (context, value, setValue) => SeedFieldset(
      label: label,
      labelBold: labelWeight == SeedFieldLabelWeight.bold,
      description: description,
      indicator: indicator,
      required: showRequiredIndicator,
      enabled: enabled,
      child: RadioGroup<T>(
        groupValue: value,
        onChanged: (next) {
          setValue(next);
          onChanged?.call(next);
        },
        // RadioGroup already owns role="radiogroup"; this merges the official
        // aria-labelledby name into that node.
        child: Semantics(label: label, child: child),
      ),
    ),
  );
}
