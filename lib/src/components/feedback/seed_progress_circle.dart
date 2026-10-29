import 'package:material_ui/material_ui.dart';

import '../../theme/seed_theme.dart';
import '../../foundations/colors/seed_palette.dart';

enum SeedProgressCircleTone { neutral, brand, staticWhite }

/// Progress Circle component of SEED Design System.
///
/// Indicates ongoing background tasks or pending actions.
class SeedProgressCircle extends StatelessWidget {
  final double size;

  /// Progress from 0 to 1, following Flutter's progress indicator convention.
  /// Omit to show indeterminate progress.
  final double? value;
  final Color? color;
  final Color? trackColor;
  final double strokeWidth;
  final SeedProgressCircleTone tone;
  final String? semanticsLabel;

  /// A numeric or percentage value for the native progress-bar semantics.
  /// When omitted, announces the percentage derived from [value], or
  /// `loading...` for indeterminate progress, as in SEED React.
  final String? semanticsValue;

  const SeedProgressCircle({
    super.key,
    this.size = 40.0,
    this.value,
    this.color,
    this.trackColor,
    this.tone = SeedProgressCircleTone.neutral,
    this.semanticsLabel,
    this.semanticsValue,
    double? strokeWidth,
  }) : strokeWidth = strokeWidth ?? size / 8;

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final effectiveColor =
        color ??
        (tone == SeedProgressCircleTone.brand
            ? colors.bg.brandSolid
            : tone == SeedProgressCircleTone.staticWhite
            ? Colors.white
            : (colors.isDark
                  ? SeedPalette.gray500Dark
                  : SeedPalette.gray500Light));
    final effectiveTrackColor =
        trackColor ??
        (tone == SeedProgressCircleTone.brand
            ? (colors.isDark
                  ? SeedPalette.carrot200Dark
                  : SeedPalette.carrot200Light)
            : tone == SeedProgressCircleTone.staticWhite
            ? SeedPalette.staticWhiteAlpha300
            : (colors.isDark
                  ? SeedPalette.gray200Dark
                  : SeedPalette.gray200Light));

    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        value: value,
        semanticsLabel: semanticsLabel,
        // The Web engine has no ARIA role for loadingSpinner yet. Keep a
        // textual loading state instead of leaving an unnamed, empty node.
        semanticsValue: semanticsValue ?? (value == null ? 'loading...' : null),
        backgroundColor: effectiveTrackColor,
        valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
        strokeWidth: strokeWidth,
        strokeCap: StrokeCap.round,
      ),
    );
  }
}
