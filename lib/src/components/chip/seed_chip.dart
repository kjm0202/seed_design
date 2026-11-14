import 'dart:ui' show SemanticsRole;

import 'package:material_ui/material_ui.dart';

import '../../foundations/colors/seed_color_scheme.dart';
import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/motion/seed_motion.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
import '../../theme/seed_theme.dart';
import '../../foundations/feedback/seed_choice_group.dart';
import '../../foundations/feedback/seed_control.dart';
import '../../localization/seed_localizations.dart';

/// Variant options for [SeedChip].
enum SeedChipVariant {
  /// Filled selection styling.
  solid,

  /// Strong outline when unselected.
  outlineStrong,

  /// Subtle outline treatment.
  outlineWeak,
}

/// Size options for [SeedChip].
enum SeedChipSize {
  /// Compact 32 px chip.
  small,
  /// Standard 36 px chip.
  medium,
  /// Large 40 px chip.
  large;

  /// Minimum height of this chip preset.
  double get height {
    switch (this) {
      case SeedChipSize.small:
        return 32.0;
      case SeedChipSize.medium:
        return 36.0;
      case SeedChipSize.large:
        return 40.0;
    }
  }

  /// Recommended leading icon dimension.
  double get iconSize {
    switch (this) {
      case SeedChipSize.small:
        return 14.0;
      case SeedChipSize.medium:
        return 16.0;
      case SeedChipSize.large:
        return 16.0;
    }
  }

  /// Recommended trailing or delete icon dimension.
  double get suffixIconSize {
    switch (this) {
      case SeedChipSize.small:
        return 14.0;
      case SeedChipSize.medium:
        return 14.0;
      case SeedChipSize.large:
        return 16.0;
    }
  }

  /// Root's horizontal inset before slot-specific adjustments.
  double get rootPaddingX {
    switch (this) {
      case SeedChipSize.small:
        return SeedDimension.x1_5;
      case SeedChipSize.medium:
        return SeedDimension.x2;
      case SeedChipSize.large:
        return SeedDimension.x2_5;
    }
  }

  /// Legacy total horizontal content inset for this chip size.
  EdgeInsets get padding {
    switch (this) {
      case SeedChipSize.small:
        return const EdgeInsets.symmetric(horizontal: 12.0);
      case SeedChipSize.medium:
        return const EdgeInsets.symmetric(horizontal: 14.0);
      case SeedChipSize.large:
        return const EdgeInsets.symmetric(horizontal: 16.0);
    }
  }

  /// All chip sizes use a fully rounded pill.
  BorderRadius get borderRadius => SeedBorderRadius.full;
}

/// Button or checkbox-style toggle chip. Checked props opt into toggle mode.
class SeedChip extends StatefulWidget {
  /// Chip caption, or an empty string for [SeedChip.iconOnly].
  final String label;
  /// Controlled checkbox state; null leaves selection internally managed.
  /// Supplying any checked-related property activates toggle semantics.
  final bool? checked;
  /// Initial checkbox state for an uncontrolled toggle; null means no toggle
  /// mode unless another checked-related argument is supplied.
  final bool? defaultChecked;
  /// Reports the proposed next checked state following activation.
  final ValueChanged<bool>? onCheckedChange;
  /// Indicates a mixed checkbox state, independent of [checked].
  final bool indeterminate;
  final bool? _selected;
  /// Deprecated selection alias; reflects initial/controlled configuration.
  @Deprecated('Use checked instead.')
  bool get selected => _selected ?? checked ?? defaultChecked ?? false;
  /// Deprecated alias callback; use [onCheckedChange] for toggles.
  @Deprecated('Use onCheckedChange instead.')
  final ValueChanged<bool>? onSelected;
  /// Ordinary button activation when no selection callback is provided.
  final VoidCallback? onPressed;
  /// Shows a separate delete icon whose tap invokes this callback.
  final VoidCallback? onDeleted;
  /// Prefix icon, suffix icon, avatar and image slots, respectively.
  /// A [prefixAvatar] takes precedence over [prefixImage] and [prefix].
  /// [prefixImage] takes precedence over [prefix]; [suffix] is hidden if
  /// [onDeleted] supplies a deletion control.
  final Widget? prefix, suffix, prefixAvatar, prefixImage;
  /// Styling recipe, default [SeedChipVariant.solid].
  final SeedChipVariant variant;
  /// Size preset, default [SeedChipSize.medium].
  final SeedChipSize size;
  /// User interaction availability, true by default.
  final bool enabled;
  final bool _iconOnly;

  /// Set by [SeedChipRadioGroup]: role radio like the official Chip.RadioItem.
  final bool _radioItem;
  /// Screen-reader name override, especially required for icon-only chips.
  final String? semanticsLabel;
  /// External focus node used for keyboard navigation.
  final FocusNode? focusNode;
  bool get _toggle =>
      checked != null ||
      defaultChecked != null ||
      onCheckedChange != null ||
      indeterminate;
  /// Creates a label chip corresponding to React `Chip.Button` or `Chip.Toggle`.
  ///
  /// With no checked-related inputs, [onPressed] makes it a button. Supplying
  /// [checked], [defaultChecked], [onCheckedChange], or [indeterminate] enables
  /// toggle mode. Legacy [selected]/[onSelected] must not be combined with
  /// their respective official checked inputs.
  const SeedChip({
    super.key,
    required this.label,
    this.checked,
    this.defaultChecked,
    this.onCheckedChange,
    this.indeterminate = false,
    @Deprecated('Use checked instead.') bool? selected,
    @Deprecated('Use onCheckedChange instead.') this.onSelected,
    this.onPressed,
    this.onDeleted,
    this.prefix,
    this.suffix,
    this.variant = SeedChipVariant.solid,
    this.size = SeedChipSize.medium,
    this.enabled = true,
    this.semanticsLabel,
    this.focusNode,
    this.prefixAvatar,
    this.prefixImage,
  }) : _selected = selected,
       _iconOnly = false,
       _radioItem = false,
       assert(
         selected == null ||
             (checked == null && defaultChecked == null && !indeterminate),
       ),
       assert(onSelected == null || onCheckedChange == null);

  const SeedChip._radioItem({
    required this.label,
    required bool selected,
    required this.onSelected,
    this.prefix,
    this.enabled = true,
    this.focusNode,
    this.variant = SeedChipVariant.solid,
    this.size = SeedChipSize.medium,
    // Named parameters cannot be private initializing formals.
    // ignore: prefer_initializing_formals
  }) : _selected = selected,
       checked = null,
       defaultChecked = null,
       onCheckedChange = null,
       indeterminate = false,
       onPressed = null,
       onDeleted = null,
       suffix = null,
       prefixAvatar = null,
       prefixImage = null,
       semanticsLabel = null,
       _iconOnly = false,
       _radioItem = true;

  /// Creates a square icon-only chip with a required [semanticsLabel].
  ///
  /// [icon] is the leading visual; this constructor omits the label, suffix,
  /// avatar, image and delete action. Checked state follows [SeedChip].
  const SeedChip.iconOnly({
    super.key,
    required Widget icon,
    required String this.semanticsLabel,
    this.focusNode,
    this.checked,
    this.defaultChecked,
    this.onCheckedChange,
    this.indeterminate = false,
    @Deprecated('Use checked instead.') bool? selected,
    @Deprecated('Use onCheckedChange instead.') this.onSelected,
    this.onPressed,
    this.variant = SeedChipVariant.solid,
    this.size = SeedChipSize.medium,
    this.enabled = true,
  }) : _selected = selected,
       assert(
         selected == null ||
             (checked == null && defaultChecked == null && !indeterminate),
       ),
       assert(onSelected == null || onCheckedChange == null),
       prefix = icon,
       label = '',
       suffix = null,
       onDeleted = null,
       prefixAvatar = null,
       prefixImage = null,
       _iconOnly = true,
       _radioItem = false;

  @override
  State<SeedChip> createState() => _SeedChipState();
}

class _SeedChipState extends State<SeedChip> {
  late bool _checked = widget.defaultChecked ?? false;
  @override
  Widget build(BuildContext context) {
    final checked =
        widget._selected ??
        widget.checked ??
        (widget._toggle ? _checked : false);
    final onSelected = widget._toggle
        ? (bool next) {
            if (widget.checked == null && widget._selected == null) {
              setState(() => _checked = next);
            }
            widget.onCheckedChange?.call(next);
            widget.onSelected?.call(next);
          }
        : widget.onSelected;
    if (widget._iconOnly) {
      return _SeedChipControl.iconOnly(
        icon: widget.prefix!,
        semanticsLabel: widget.semanticsLabel!,
        focusNode: widget.focusNode,
        selected: checked,
        indeterminate: widget.indeterminate,
        checkboxSemantics: widget._toggle,
        onSelected: onSelected,
        onPressed: widget.onPressed,
        variant: widget.variant,
        size: widget.size,
        enabled: widget.enabled,
      );
    }
    return _SeedChipControl(
      label: widget.label,
      selected: checked,
      indeterminate: widget.indeterminate,
      checkboxSemantics: widget._toggle,
      radioSemantics: widget._radioItem,
      onSelected: onSelected,
      onPressed: widget.onPressed,
      onDeleted: widget.onDeleted,
      prefix: widget.prefix,
      suffix: widget.suffix,
      prefixAvatar: widget.prefixAvatar,
      prefixImage: widget.prefixImage,
      variant: widget.variant,
      size: widget.size,
      enabled: widget.enabled,
      semanticsLabel: widget.semanticsLabel,
      focusNode: widget.focusNode,
    );
  }
}

/// Chip component of SEED Design System.
///
/// Used for filtering, suggestions, selections, and user input tags.
class _SeedChipControl extends StatelessWidget {
  final String label;
  final bool selected;
  final bool indeterminate;
  final bool checkboxSemantics;

  /// Chip.RadioItem: role radio in a mutually exclusive group.
  final bool radioSemantics;
  final ValueChanged<bool>? onSelected;
  final VoidCallback? onPressed;
  final VoidCallback? onDeleted;
  final Widget? prefix;
  final Widget? suffix;
  final SeedChipVariant variant;
  final SeedChipSize size;
  final bool enabled;
  final bool _iconOnly;
  final String? semanticsLabel;
  final FocusNode? focusNode;
  final Widget? prefixAvatar, prefixImage;

  const _SeedChipControl({
    required this.label,
    this.selected = false,
    this.indeterminate = false,
    this.checkboxSemantics = false,
    this.radioSemantics = false,
    this.onSelected,
    this.onPressed,
    this.onDeleted,
    this.prefix,
    this.suffix,
    this.variant = SeedChipVariant.solid,
    this.size = SeedChipSize.medium,
    this.enabled = true,
    this.semanticsLabel,
    this.focusNode,
    this.prefixAvatar,
    this.prefixImage,
  }) : _iconOnly = false;

  const _SeedChipControl.iconOnly({
    required Widget icon,
    required String this.semanticsLabel,
    this.focusNode,
    this.selected = false,
    this.indeterminate = false,
    this.checkboxSemantics = false,
    this.onSelected,
    this.onPressed,
    this.variant = SeedChipVariant.solid,
    this.size = SeedChipSize.medium,
    this.enabled = true,
  }) : prefix = icon,
       label = '',
       suffix = null,
       onDeleted = null,
       prefixAvatar = null,
       prefixImage = null,
       radioSemantics = false,
       _iconOnly = true;

  bool get _isClickable => enabled && (onSelected != null || onPressed != null);

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;

    TextStyle textStyle;
    switch (size) {
      case SeedChipSize.small:
        textStyle = typography.t4Medium;
        break;
      case SeedChipSize.medium:
        textStyle = typography.t4Medium;
        break;
      case SeedChipSize.large:
        textStyle = typography.t4Medium;
        break;
    }

    final prefix = prefixAvatar ?? prefixImage ?? this.prefix;
    return SeedPressable(
      semanticsLabel: semanticsLabel,
      focusNode: focusNode,
      enabled: _isClickable,
      selected: !checkboxSemantics && !radioSemantics && onSelected != null
          ? selected
          : null,
      checked: (checkboxSemantics || radioSemantics) && onSelected != null
          ? selected
          : null,
      inMutuallyExclusiveGroup: radioSemantics ? true : null,
      semanticButton: !radioSemantics,
      mixed: checkboxSemantics && onSelected != null ? indeterminate : null,
      onTap: () {
        if (onSelected != null) {
          onSelected!(!selected);
        } else if (onPressed != null) {
          onPressed!();
        }
      },
      builder: (context, isPressed) {
        final (bgColor, fgColor, strokeColor) = _resolveColors(
          colors: colors,
          isPressed: isPressed,
        );

        return Opacity(
          opacity: enabled ? 1 : 0.5,
          child: AnimatedContainer(
            duration: SeedDuration.colorTransition,
            curve: SeedCurves.easing,
            constraints: BoxConstraints(
              minHeight: size.height,
              minWidth: _iconOnly
                  ? size.height
                  : switch (size) {
                      SeedChipSize.small => 44,
                      SeedChipSize.medium => 48,
                      SeedChipSize.large => 52,
                    },
            ),
            // prefixIcon, suffixIcon and label each carry x1_5 toward the root
            // edge; only an avatar and the wider delete target sit on it. React's
            // stroke is an inset shadow, so it must not add to the width.
            padding:
                EdgeInsets.only(
                  left: _iconOnly || prefixAvatar != null || prefixImage != null
                      ? size.rootPaddingX
                      : size.rootPaddingX + SeedDimension.x1_5,
                  right: _iconOnly || onDeleted != null
                      ? size.rootPaddingX
                      : size.rootPaddingX + SeedDimension.x1_5,
                ) -
                (strokeColor != null
                    ? const EdgeInsets.symmetric(horizontal: 1)
                    : EdgeInsets.zero),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: size.borderRadius,
              border: strokeColor != null
                  ? Border.all(color: strokeColor, width: 1.0)
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (prefix != null) ...[
                  IconTheme(
                    data: IconThemeData(color: fgColor, size: size.iconSize),
                    child: prefixAvatar != null || prefixImage != null
                        ? ClipRRect(
                            borderRadius: prefixAvatar != null
                                ? SeedBorderRadius.full
                                : SeedBorderRadius.r1,
                            child: SizedBox.square(
                              dimension: size == SeedChipSize.small
                                  ? 20
                                  : size == SeedChipSize.medium
                                  ? 24
                                  : 28,
                              child: prefix,
                            ),
                          )
                        : prefix,
                  ),
                  if (!_iconOnly) const SizedBox(width: SeedDimension.x1_5),
                ],
                if (!_iconOnly)
                  Text(
                    label,
                    style: textStyle.copyWith(color: fgColor),
                    maxLines: 1,
                  ),
                if (onDeleted != null) ...[
                  const SizedBox(width: SeedDimension.x1_5),
                  SeedPressable(
                    semanticsLabel: SeedLocalizations.label(
                      context,
                      SeedLabel.deleteChip,
                    ).replaceAll('{label}', label),
                    enableScale: false,
                    behavior: HitTestBehavior.opaque,
                    onTap: enabled ? onDeleted : null,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
                      child: Center(
                        widthFactor: 1,
                        heightFactor: 1,
                        child: Icon(
                          Icons.close_rounded,
                          size: size.suffixIconSize,
                          color: fgColor,
                        ),
                      ),
                    ),
                  ),
                ] else if (suffix != null) ...[
                  const SizedBox(width: SeedDimension.x1_5),
                  IconTheme(
                    data: IconThemeData(
                      color: fgColor,
                      size: size.suffixIconSize,
                    ),
                    child: suffix!,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  (Color bg, Color fg, Color? stroke) _resolveColors({
    required SeedColorScheme colors,
    required bool isPressed,
  }) {
    switch (variant) {
      case SeedChipVariant.solid:
        if (selected) {
          return (
            isPressed ? colors.bg.neutralSolidPressed : colors.bg.neutralSolid,
            colors.fg.onNeutralSolid,
            null,
          );
        } else {
          return (
            isPressed
                ? colors.bg.neutralWeakAlphaPressed
                : colors.bg.neutralWeakAlpha,
            colors.fg.neutral,
            null,
          );
        }

      case SeedChipVariant.outlineStrong:
        if (selected) {
          return (
            isPressed ? colors.bg.neutralSolidPressed : colors.bg.neutralSolid,
            colors.fg.onNeutralSolid,
            colors.stroke.neutralWeak,
          );
        } else {
          return (
            isPressed ? colors.bg.transparentPressed : colors.bg.transparent,
            colors.fg.neutral,
            colors.stroke.neutralWeak,
          );
        }

      case SeedChipVariant.outlineWeak:
        if (selected) {
          return (
            isPressed ? colors.bg.neutralWeakPressed : colors.bg.neutralWeak,
            colors.fg.neutral,
            colors.stroke.neutralContrast,
          );
        } else {
          return (
            isPressed ? colors.bg.transparentPressed : colors.bg.transparent,
            colors.fg.neutral,
            colors.stroke.neutralWeak,
          );
        }
    }
  }
}

/// One selectable value and its presentation in [SeedChipRadioGroup].
class SeedChipOption<T> {
  /// Creates an option with a stable [value] and visible [label].
  const SeedChipOption({
    required this.value,
    required this.label,
    this.prefix,
    this.enabled = true,
  });
  /// Unique selection identity compared using `==`.
  final T value;
  /// Visible chip text.
  final String label;
  /// Optional leading icon.
  final Widget? prefix;
  /// Whether this particular option can receive interaction (default true).
  final bool enabled;
}

/// Single-selection chip group with roving Tab focus and arrow navigation.
class SeedChipRadioGroup<T> extends StatefulWidget {
  /// Creates a single-choice radio group of [options].
  ///
  /// [value] controls selection when non-null; [controlled] also makes a null
  /// value mean no selection. Otherwise internal state begins at [defaultValue].
  /// [onValueChange] is the React-aligned callback; [onChanged] is its
  /// deprecated alias and cannot be supplied at the same time.
  const SeedChipRadioGroup({
    super.key,
    required this.options,
    this.value,
    this.defaultValue,
    ValueChanged<T>? onValueChange,
    @Deprecated('Use onValueChange instead.') ValueChanged<T>? onChanged,
    this.enabled = true,
    this.controlled = false,
    this.label,
    this.description,
    this.variant = SeedChipVariant.solid,
    this.size = SeedChipSize.medium,
    this.semanticsLabel,
  }) : onChanged = onValueChange ?? onChanged,
       assert(onValueChange == null || onChanged == null);
  /// Choice options displayed in a wrapped row with an 8 px gap.
  final List<SeedChipOption<T>> options;

  /// Accessible name of the radio group, like the official `aria-label`.
  final String? semanticsLabel;
  /// Controlled selection and initial uncontrolled selection, respectively.
  /// Passing [value] null and [controlled] true represents no selection.
  final T? value, defaultValue;
  /// Deprecated callback alias; use [onValueChange].
  @Deprecated('Use onValueChange instead.')
  final ValueChanged<T>? onChanged;
  /// Called with the newly selected option value.
  ValueChanged<T>? get onValueChange => onChanged;
  /// Global interaction flag and explicit parent-state ownership flag.
  /// [enabled] defaults true; [controlled] defaults false.
  final bool enabled, controlled;
  /// Visible group label and optional supporting description.
  final String? label, description;
  /// Chip style applied to every radio option.
  final SeedChipVariant variant;
  /// Chip size applied to every radio option.
  final SeedChipSize size;
  @override
  State<SeedChipRadioGroup<T>> createState() => _SeedChipRadioGroupState<T>();
}

class _SeedChipRadioGroupState<T> extends State<SeedChipRadioGroup<T>> {
  late T? _value = widget.defaultValue;
  T? get value => widget.controlled ? widget.value : widget.value ?? _value;
  void _change(T next) {
    if (value == next) return;
    if (!widget.controlled && widget.value == null) {
      setState(() => _value = next);
    }
    widget.onChanged?.call(next);
  }

  // Official Chip.RadioRoot renders role="radiogroup".
  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    role: SemanticsRole.radioGroup,
    label: widget.semanticsLabel ?? widget.label,
    child: SeedFieldset(
      label: widget.label,
      description: widget.description,
      enabled: widget.enabled,
      child: SeedChoiceGroup(
        selectedIndex: widget.options.indexWhere((item) => item.value == value),
        enabled: widget.options
            .map((item) => widget.enabled && item.enabled)
            .toList(),
        onSelected: (index) => _change(widget.options[index].value),
        builder: (context, nodes) => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < widget.options.length; i++)
              SeedChip._radioItem(
                label: widget.options[i].label,
                prefix: widget.options[i].prefix,
                enabled: widget.enabled && widget.options[i].enabled,
                focusNode: nodes[i],
                selected: widget.options[i].value == value,
                onSelected: (_) => _change(widget.options[i].value),
                variant: widget.variant,
                size: widget.size,
              ),
          ],
        ),
      ),
    ),
  );
}
