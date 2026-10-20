import 'package:material_ui/material_ui.dart';

import '../../theme/seed_theme.dart';
import '../../foundations/colors/seed_palette.dart';

/// Progress Circle component of SEED Design System.
///
/// Indicates ongoing background tasks or pending actions.
class SeedProgressCircle extends StatelessWidget {
  final double size;
  final double? value;
  final Color? color;
  final Color? trackColor;
  final double strokeWidth;

  const SeedProgressCircle({
    super.key,
    this.size = 24.0,
    this.value,
    this.color,
    this.trackColor,
    double? strokeWidth,
  }) : strokeWidth = strokeWidth ?? size / 8;

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final effectiveColor =
        color ??
        (colors.isDark ? SeedPalette.gray500Dark : SeedPalette.gray500Light);
    final effectiveTrackColor =
        trackColor ??
        (colors.isDark ? SeedPalette.gray200Dark : SeedPalette.gray200Light);

    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        value: value,
        backgroundColor: effectiveTrackColor,
        valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
        strokeWidth: strokeWidth,
        strokeCap: StrokeCap.round,
      ),
    );
  }
}
