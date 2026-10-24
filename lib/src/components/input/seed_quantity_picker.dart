import 'package:material_ui/material_ui.dart';

import '../../foundations/colors/seed_color_scheme.dart';
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

/// Quantity picker component of SEED Design System.
///
/// Increments or decrements numerical values step by step with boundary constraints.
class SeedQuantityPicker extends StatelessWidget {
  final int value;
  final ValueChanged<int>? onChanged;
  final int min;
  final int max;
  final int step;
  final SeedQuantityPickerSize size;
  final bool enabled;
  final bool hasError;

  const SeedQuantityPicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 99,
    this.step = 1,
    this.size = SeedQuantityPickerSize.medium,
    this.enabled = true,
    this.hasError = false,
  });

  bool get _canDecrement =>
      enabled && onChanged != null && step > 0 && value - step >= min;
  bool get _canIncrement =>
      enabled && onChanged != null && step > 0 && value + step <= max;

  @override
  Widget build(BuildContext context) {
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

    return Container(
      height: size.height,
      decoration: BoxDecoration(
        color: colors.bg.layerDefault,
        borderRadius: size == SeedQuantityPickerSize.large
            ? SeedBorderRadius.r3
            : SeedBorderRadius.r2,
        border: Border.all(color: strokeColor, width: hasError ? 2 : 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrement Button
          _buildButton(
            icon: Icons.remove_rounded,
            canAction: _canDecrement,
            onPressed: () => onChanged?.call(value - step),
            colors: colors,
            borderRadius: BorderRadius.horizontal(
              left: Radius.circular(
                size == SeedQuantityPickerSize.large
                    ? SeedRadius.r3
                    : SeedRadius.r2,
              ),
            ),
          ),

          // Divider
          _buildDivider(colors),

          // Value display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: SeedDimension.x2),
            alignment: Alignment.center,
            child: Text('$value', style: textStyle),
          ),

          // Divider
          _buildDivider(colors),

          // Increment Button
          _buildButton(
            icon: Icons.add_rounded,
            canAction: _canIncrement,
            onPressed: () => onChanged?.call(value + step),
            colors: colors,
            borderRadius: BorderRadius.horizontal(
              right: Radius.circular(
                size == SeedQuantityPickerSize.large
                    ? SeedRadius.r3
                    : SeedRadius.r2,
              ),
            ),
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
    required bool canAction,
    required VoidCallback onPressed,
    required SeedColorScheme colors,
    required BorderRadius borderRadius,
  }) {
    return SeedPressable(
      enabled: canAction,
      onTap: canAction ? onPressed : null,
      builder: (context, isPressed) {
        return Container(
          width: size.buttonWidth,
          height: size.height,
          decoration: BoxDecoration(
            color: isPressed
                ? colors.bg.transparentPressed
                : colors.bg.transparent,
            borderRadius: borderRadius,
          ),
          child: Center(
            child: Icon(
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
