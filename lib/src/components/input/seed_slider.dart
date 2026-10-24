import 'package:material_ui/material_ui.dart';

import '../../foundations/colors/seed_palette.dart';
import '../../theme/seed_theme.dart';

/// Slider component of SEED Design System.
///
/// Features SEED brand/neutral active tracks, smooth dragging handle,
/// discrete step intervals, value indicator tooltip, and min/max constraints.
class SeedSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double>? onChangeEnd;
  final double min;
  final double max;
  final int? divisions;
  final String? label;
  final bool isBrand;
  final bool enabled;

  const SeedSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.min = 0.0,
    this.max = 100.0,
    this.divisions,
    this.label,
    this.isBrand = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;

    final Color activeColor =
        isBrand ? colors.fg.brand : colors.bg.neutralSolid;
    final Color inactiveColor = colors.isDark
        ? SeedPalette.gray400Dark
        : SeedPalette.gray400Light;
    final Color thumbColor = activeColor;

    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 4.0,
        activeTrackColor: enabled ? activeColor : colors.bg.disabled,
        inactiveTrackColor: enabled ? inactiveColor : colors.bg.disabled,
        disabledActiveTrackColor: colors.fg.disabled,
        disabledInactiveTrackColor: colors.bg.disabled,
        disabledThumbColor: colors.fg.disabled,
        thumbColor: enabled ? thumbColor : colors.fg.disabled,
        overlayColor: activeColor.withValues(alpha: 0.12),
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: 10.0,
          elevation: 0.0,
          pressedElevation: 0.0,
        ),
        trackShape: const RoundedRectSliderTrackShape(),
        tickMarkShape: divisions != null
            ? const RoundSliderTickMarkShape(tickMarkRadius: 2.0)
            : SliderTickMarkShape.noTickMark,
        activeTickMarkColor: colors.bg.layerDefault,
        inactiveTickMarkColor: colors.fg.neutralSubtle,
        valueIndicatorColor: colors.bg.neutralSolid,
        valueIndicatorTextStyle: typography.t3Medium.copyWith(
          color: colors.fg.onNeutralSolid,
        ),
        showValueIndicator: ShowValueIndicator.onlyForDiscrete,
      ),
      child: Slider(
        value: value.clamp(min, max),
        min: min,
        max: max,
        divisions: divisions,
        label: label,
        onChanged: enabled ? onChanged : null,
        onChangeStart: enabled ? onChangeStart : null,
        onChangeEnd: enabled ? onChangeEnd : null,
      ),
    );
  }
}
