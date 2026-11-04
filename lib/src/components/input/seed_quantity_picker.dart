import '../../localization/seed_localizations.dart';
import '../feedback/seed_progress_circle.dart';
import '../../foundations/state/seed_uncontrolled_value.dart';

import 'package:material_ui/material_ui.dart';

import '../../foundations/colors/seed_color_scheme.dart';
import '../../foundations/colors/seed_palette.dart';
import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
import '../../theme/seed_theme.dart';

/// Size options for [SeedQuantityPicker].
enum SeedQuantityPickerSize {
  /// Compact picker: 36px tall with 16px icons.
  small,

  /// Standard picker: 40px tall with 18px icons.
  medium,

  /// Spacious picker: 52px tall with 22px icons.
  large;

  /// Height of the picker and the width of each action button, in pixels.
  double get height {
    switch (this) {
      case SeedQuantityPickerSize.small:
        return 36.0;
      case SeedQuantityPickerSize.medium:
        return 40.0;
      case SeedQuantityPickerSize.large:
        return 52.0;
    }
  }

  /// Width of an increment or decrement button, equal to [height].
  double get buttonWidth => height;

  /// Size of the add and subtract icons, in pixels.
  double get iconSize => switch (this) {
    SeedQuantityPickerSize.small => 16,
    SeedQuantityPickerSize.medium => 18,
    SeedQuantityPickerSize.large => 22,
  };
}

/// Layout width policy for [SeedQuantityPicker].
enum SeedQuantityPickerLayout {
  /// Use the width required by the controls and quantity display.
  hug,

  /// Expand the picker to fill its available horizontal space.
  fill,
}

/// Quantity picker component of SEED Design System.
///
/// Increments or decrements numerical values step by step with boundary constraints.
/// React's `value`, `defaultValue`, and `onValueChange` are available.
/// The Flutter widget exposes `onChanged` as a deprecated callback alias.
class SeedQuantityPicker extends StatelessWidget {
  /// Current externally supplied quantity; null uses [defaultValue] or [min].
  final int? value;

  /// Initial uncontrolled value. Omitted values start at [min], as in React.
  final int? defaultValue;

  /// Previous name for [onValueChange], invoked with the proposed new quantity.
  @Deprecated('Use onValueChange instead.')
  final ValueChanged<int>? onChanged;

  /// Called with the next value after an increment or decrement.
  ///
  /// The next value is clamped to [min] and [max].
  ValueChanged<int>? get onValueChange => onChanged;

  /// Minimum quantity, inclusive (default 1).
  final int min;

  /// Maximum quantity, inclusive (default 99).
  final int max;

  /// Quantity added or subtracted per action (default 1; must be positive).
  final int step;

  /// Visual size of the controls (default [SeedQuantityPickerSize.medium]).
  final SeedQuantityPickerSize size;

  /// Whether interactions are enabled (default true).
  final bool enabled;

  /// Display the quantity without allowing changes (default false).
  final bool readOnly;

  /// Legacy error indicator; use [invalid] (default false).
  @Deprecated('Use invalid instead.')
  final bool hasError;

  /// Whether the value is in an invalid state.
  bool get invalid => hasError;

  /// Enables a remove action at [min]; [loading] blocks all actions, while
  /// [decrementLoading] and [incrementLoading] block only the named action.
  ///
  /// All four flags default to false.
  final bool removable, loading, decrementLoading, incrementLoading;

  /// Called when the decrement control is a remove control at [min].
  final VoidCallback? onRemove;

  /// Horizontal sizing strategy, defaulting to [SeedQuantityPickerLayout.hug].
  final SeedQuantityPickerLayout layout;

  /// Formats the quantity for display, for example with a unit suffix.
  final String Function(int)? valueFormatter;

  /// Flutter-specific widget to render instead of the formatted value text.
  final Widget? valueChild;
  final String? _removeSemanticsLabel;

  /// Accessibility label of the remove control (default `상품 삭제`).
  String get removeSemanticsLabel => _removeSemanticsLabel ?? '상품 삭제';

  /// Creates a quantity picker with inclusive bounds [min] and [max].
  ///
  /// [value] has priority over [defaultValue]; when both are absent the
  /// quantity begins at [min]. [onValueChange] reports increments and
  /// decrements; the deprecated [onChanged] is an alternative name.
  /// Use [invalid] instead of the deprecated [hasError].
  ///
  /// [min] must not exceed [max], [step] must be positive, and a supplied
  /// [value] must lie within the bounds. [removeSemanticsLabel] configures
  /// the removal button when [removable] and [onRemove] are set.
  const SeedQuantityPicker({
    super.key,
    this.value,
    this.defaultValue,
    ValueChanged<int>? onValueChange,
    @Deprecated('Use onValueChange instead.') ValueChanged<int>? onChanged,
    this.min = 1,
    this.max = 99,
    this.step = 1,
    this.size = SeedQuantityPickerSize.medium,
    this.enabled = true,
    this.readOnly = false,
    bool? invalid,
    @Deprecated('Use invalid instead.') bool? hasError,
    this.removable = false,
    this.onRemove,
    this.loading = false,
    this.decrementLoading = false,
    this.incrementLoading = false,
    this.layout = SeedQuantityPickerLayout.hug,
    this.valueFormatter,
    this.valueChild,
    String? removeSemanticsLabel,
    // Preserve the public named parameter and getter.
    // ignore: prefer_initializing_formals
  }) : _removeSemanticsLabel = removeSemanticsLabel,
       hasError = invalid ?? hasError ?? false,
       assert(invalid == null || hasError == null),
       onChanged = onValueChange ?? onChanged,
       assert(onValueChange == null || onChanged == null),
       assert(min <= max),
       assert(step > 0),
       assert(value == null || (value >= min && value <= max));

  int get _currentValue => value ?? defaultValue ?? min;
  bool get _canDecrement =>
      enabled &&
      !readOnly &&
      !loading &&
      !decrementLoading &&
      ((removable && _currentValue <= min && onRemove != null) ||
          (onChanged != null && step > 0 && _currentValue > min));
  bool get _canIncrement =>
      enabled &&
      !readOnly &&
      !loading &&
      !incrementLoading &&
      onChanged != null &&
      step > 0 &&
      _currentValue < max;

  @override
  Widget build(BuildContext context) {
    if (this.value == null) {
      return SeedUncontrolledValue<int>(
        initialValue: (defaultValue ?? min).clamp(min, max),
        builder: (context, value, setValue) => SeedQuantityPicker(
          value: value,
          onChanged: (next) {
            setValue(next);
            onChanged?.call(next);
          },
          min: min,
          max: max,
          step: step,
          size: size,
          enabled: enabled,
          readOnly: readOnly,
          hasError: hasError,
          removable: removable,
          onRemove: onRemove,
          loading: loading,
          decrementLoading: decrementLoading,
          incrementLoading: incrementLoading,
          layout: layout,
          valueFormatter: valueFormatter,
          valueChild: valueChild,
          removeSemanticsLabel: _removeSemanticsLabel,
        ),
      );
    }
    final value = this.value!;
    final colors = context.seedColor;
    final typography = context.seedTypography;

    final Color strokeColor = hasError
        ? colors.stroke.criticalSolid
        : colors.stroke.neutralWeak;

    final TextStyle textStyle =
        (size == SeedQuantityPickerSize.large
                ? typography.t6Medium
                : typography.t5Medium)
            .copyWith(color: enabled ? colors.fg.neutral : colors.fg.disabled);

    Widget display = Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: SeedDimension.x2),
        alignment: Alignment.center,
        child:
            valueChild ??
            Stack(
              alignment: Alignment.center,
              children: [
                // Reserve the widest value so buttons stay put as digits change.
                ExcludeSemantics(
                  child: Visibility(
                    visible: false,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: Text(
                      (valueFormatter?.call(max) ?? '$max').replaceAll(
                        RegExp(r'\d'),
                        '0',
                      ),
                      style: textStyle,
                    ),
                  ),
                ),
                Text(valueFormatter?.call(value) ?? '$value', style: textStyle),
              ],
            ),
      ),
    );
    if (layout == SeedQuantityPickerLayout.fill) {
      display = Expanded(child: display);
    }
    return Container(
      height: size.height,
      decoration: BoxDecoration(
        color: colors.bg.layerDefault,
        borderRadius: size == SeedQuantityPickerSize.large
            ? SeedBorderRadius.r3
            : SeedBorderRadius.r2,
      ),
      // The official stroke is painted over the content without moving it.
      foregroundDecoration: BoxDecoration(
        borderRadius: size == SeedQuantityPickerSize.large
            ? SeedBorderRadius.r3
            : SeedBorderRadius.r2,
        border: Border.all(color: strokeColor, width: hasError ? 2 : 1),
      ),
      child: Row(
        mainAxisSize: layout == SeedQuantityPickerLayout.fill
            ? MainAxisSize.max
            : MainAxisSize.min,
        children: [
          // Decrement Button
          _buildButton(
            icon: removable && value <= min
                ? Icons.delete_outline
                : Icons.remove_rounded,
            label: removable && value <= min
                ? (_removeSemanticsLabel ??
                      SeedLocalizations.label(context, SeedLabel.removeItem))
                : SeedLocalizations.label(context, SeedLabel.decreaseQuantity),
            loading: loading || decrementLoading,
            canAction: _canDecrement,
            onPressed: () {
              if (removable && value <= min) {
                onRemove?.call();
              } else {
                onChanged?.call((value - step).clamp(min, max));
              }
            },
            colors: colors,
            borderRadius: BorderRadiusDirectional.horizontal(
              start: Radius.circular(
                size == SeedQuantityPickerSize.large
                    ? SeedRadius.r3
                    : SeedRadius.r2,
              ),
            ).resolve(Directionality.of(context)),
          ),

          // Divider
          _buildDivider(colors),

          // Value display
          display,

          // Divider
          _buildDivider(colors),

          // Increment Button
          _buildButton(
            icon: Icons.add_rounded,
            label: SeedLocalizations.label(context, SeedLabel.increaseQuantity),
            loading: loading || incrementLoading,
            canAction: _canIncrement,
            onPressed: () => onChanged?.call((value + step).clamp(min, max)),
            colors: colors,
            borderRadius: BorderRadiusDirectional.horizontal(
              end: Radius.circular(
                size == SeedQuantityPickerSize.large
                    ? SeedRadius.r3
                    : SeedRadius.r2,
              ),
            ).resolve(Directionality.of(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(SeedColorScheme colors) {
    return Container(
      width: 1.0,
      height: SeedDimension.x4,
      color: colors.stroke.neutralSubtle,
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    required bool loading,
    required bool canAction,
    required VoidCallback onPressed,
    required SeedColorScheme colors,
    required BorderRadius borderRadius,
  }) {
    return SeedPressable(
      enabled: canAction,
      semanticsLabel: label,
      onTap: canAction ? onPressed : null,
      builder: (context, isPressed) {
        return Container(
          width: size.buttonWidth,
          height: size.height,
          decoration: BoxDecoration(
            color: isPressed || loading
                ? colors.bg.transparentPressed
                : colors.bg.transparent,
            borderRadius: borderRadius,
          ),
          child: Center(
            child: loading
                ? SeedProgressCircle(
                    size: size.iconSize,
                    strokeWidth: 2,
                    color: colors.fg.neutral,
                    trackColor: colors.isDark
                        ? SeedPalette.gray500Dark
                        : SeedPalette.gray500Light,
                  )
                : Icon(
                    icon,
                    size: size.iconSize,
                    color: canAction ? colors.fg.neutral : colors.fg.disabled,
                  ),
          ),
        );
      },
    );
  }
}
