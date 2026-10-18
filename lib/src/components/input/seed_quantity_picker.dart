import 'package:material_ui/material_ui.dart';
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
        return 32.0;
      case SeedQuantityPickerSize.medium:
        return 40.0;
      case SeedQuantityPickerSize.large:
        return 48.0;
    }
  }

  double get buttonWidth => height;
  double get iconSize => height * 0.45;
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

  bool get _canDecrement => enabled && value - step >= min;
  bool get _canIncrement => enabled && value + step <= max;

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;

    final Color strokeColor = hasError
        ? colors.stroke.criticalSolid
        : colors.stroke.neutralWeak;

    final TextStyle textStyle = (size == SeedQuantityPickerSize.small
            ? typography.t3Bold
            : typography.t4Bold)
        .copyWith(
      color: enabled ? colors.fg.neutral : colors.fg.disabled,
    );

    return Container(
      height: size.height,
      decoration: BoxDecoration(
        color: colors.bg.layerDefault,
        borderRadius: SeedBorderRadius.r2_5,
        border: Border.all(color: strokeColor, width: 1.0),
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
          ),

          // Value display
          Container(
            constraints: BoxConstraints(minWidth: size.height * 1.1),
            padding: const EdgeInsets.symmetric(horizontal: SeedDimension.x2),
            alignment: Alignment.center,
            child: Text(
              '$value',
              style: textStyle,
            ),
          ),

          // Increment Button
          _buildButton(
            icon: Icons.add_rounded,
            canAction: _canIncrement,
            onPressed: () => onChanged?.call(value + step),
            colors: colors,
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required bool canAction,
    required VoidCallback onPressed,
    required dynamic colors,
  }) {
    return SeedPressable(
      enabled: canAction,
      onTap: canAction ? onPressed : null,
      child: SizedBox(
        width: size.buttonWidth,
        height: size.height,
        child: Center(
          child: Icon(
            icon,
            size: size.iconSize,
            color: canAction ? colors.fg.neutral : colors.fg.disabled,
          ),
        ),
      ),
    );
  }
}
