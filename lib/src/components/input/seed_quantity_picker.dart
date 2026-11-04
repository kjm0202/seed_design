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
  small,

  medium,

  large;

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

  double get buttonWidth => height;

  double get iconSize => switch (this) {
    SeedQuantityPickerSize.small => 16,
    SeedQuantityPickerSize.medium => 18,
    SeedQuantityPickerSize.large => 22,
  };
}

enum SeedQuantityPickerLayout {
  hug,

  fill,
}

/// Quantity picker component of SEED Design System.
///
/// Increments or decrements numerical values step by step with boundary constraints.
class SeedQuantityPicker extends StatelessWidget {
  final int? value;

  final int? defaultValue;

  @Deprecated('Use onValueChange instead.')
  final ValueChanged<int>? onChanged;

  ValueChanged<int>? get onValueChange => onChanged;

  final int min;

  final int max;

  final int step;

  final SeedQuantityPickerSize size;

  final bool enabled;

  final bool readOnly;

  @Deprecated('Use invalid instead.')
  final bool hasError;

  bool get invalid => hasError;

  final bool removable, loading, decrementLoading, incrementLoading;

  final VoidCallback? onRemove;

  final SeedQuantityPickerLayout layout;

  final String Function(int)? valueFormatter;

  final Widget? valueChild;
  final String? _removeSemanticsLabel;

  String get removeSemanticsLabel => _removeSemanticsLabel ?? '상품 삭제';

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
