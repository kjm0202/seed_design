// Portions adapted from daangn/seed-design, revision 0684acaa7012a68d9858c971c51db46b680978dd.
// Original material: Copyright 2025 주식회사 당근마켓, Apache License 2.0.
// Modifications: ported the temperature-level logic to Dart, used a boundary
// table, and added validation that rejects non-finite temperatures.
// See third_party/seed-design/LICENSE and NOTICE in the package root.

import 'package:material_ui/material_ui.dart';

import '../../foundations/colors/seed_color_scheme.dart';
import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';

String _formatTemperature(double value) =>
    '${value == value.truncateToDouble() ? value.toStringAsFixed(0) : value}°C';

/// Helper class to resolve temperature to SEED 10-level scale.
class SeedMannerTempLevel {
  const SeedMannerTempLevel._();

  static int fromTemperature(double temperature) {
    if (!temperature.isFinite) {
      throw ArgumentError.value(temperature, 'temperature', 'Must be finite');
    }
    // daangn/seed-design 0684acaa: docs/registry/react/lib/manner-temp-level.ts.
    const boundaries = [30.0, 36.0, 36.5, 37.0, 40.0, 45.0, 55.0, 65.0, 80.0];
    for (var i = 0; i < boundaries.length; i++) {
      if (temperature < boundaries[i]) return i + 1;
    }
    return 10;
  }

  static String getEmoji(int level) {
    switch (level.clamp(1, 10)) {
      case 1:
        return '🥶';
      case 2:
        return '🙁';
      case 3:
        return '🙂';
      case 4:
        return '😊';
      case 5:
        return '😄';
      case 6:
        return '🥰';
      case 7:
        return '🥳';
      case 8:
        return '🔥';
      case 9:
        return '👑';
      case 10:
      default:
        return '💎';
    }
  }
}

/// Manner Temp Badge component of SEED Design System.
///
/// Compact badge displaying Karrot manner temperature (e.g. 36.5°C)
/// with level-specific background and text color tokens.
class SeedMannerTempBadge extends StatelessWidget {
  final double temperature;

  /// Explicit React level (l1..l10), independent of the displayed temperature.
  /// Null preserves the temperature-derived level.
  final int? level;
  final bool showEmoji;

  const SeedMannerTempBadge({
    super.key,
    required this.temperature,
    this.level,
    this.showEmoji = false,
  }) : assert(level == null || (level >= 1 && level <= 10));

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;
    final int level =
        this.level ?? SeedMannerTempLevel.fromTemperature(temperature);
    final SeedMannerTempColor mannerColor = colors.mannerTemp.byLevel(level);

    return Container(
      constraints: const BoxConstraints(minHeight: 20),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: mannerColor.bg,
        borderRadius: SeedBorderRadius.full,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            _formatTemperature(temperature),
            style: typography.t1Bold.copyWith(color: mannerColor.text),
          ),
          if (showEmoji) ...[
            const SizedBox(width: SeedDimension.x0_5),
            ExcludeSemantics(
              child: Text(
                SeedMannerTempLevel.getEmoji(level),
                style: const TextStyle(fontSize: 11.0, height: 1.0),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Full Manner Temp display component of SEED Design System.
///
/// Shows temperature with progress bar gauge, level indicator,
/// and descriptive reliability level.
class SeedMannerTemp extends StatelessWidget {
  final double temperature;
  final String? subtitle;

  /// Supply the product's licensed emote asset. No network asset is fetched.
  final Widget Function(BuildContext context, int level)? emoteBuilder;

  /// Opt-in compatibility display; system emoji are not the official artwork.
  final bool showEmoji;
  final bool showProgress;

  const SeedMannerTemp({
    super.key,
    required this.temperature,
    this.subtitle,
    this.emoteBuilder,
    this.showEmoji = false,
    this.showProgress = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;
    final int level = SeedMannerTempLevel.fromTemperature(temperature);
    final SeedMannerTempColor mannerColor = colors.mannerTemp.byLevel(level);

    // Temperature clamped between 0 and 99°C for progress meter
    final double progress = (temperature / 99.0).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatTemperature(temperature),
                  style: typography.t5Bold.copyWith(color: mannerColor.text),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: typography.t1Regular.copyWith(
                      color: colors.fg.neutralMuted,
                    ),
                  ),
              ],
            ),
            if (emoteBuilder != null || showEmoji) ...[
              const SizedBox(width: SeedDimension.x1),
              ExcludeSemantics(
                child: SizedBox(
                  // The official 32px emote bleeds 4px outside its layout box.
                  width: 24,
                  height: 24,
                  child: OverflowBox(
                    minWidth: 32,
                    maxWidth: 32,
                    minHeight: 32,
                    maxHeight: 32,
                    child:
                        emoteBuilder?.call(context, level) ??
                        Center(
                          child: Text(
                            SeedMannerTempLevel.getEmoji(level),
                            style: const TextStyle(fontSize: 28, height: 1),
                          ),
                        ),
                  ),
                ),
              ),
            ],
          ],
        ),
        if (showProgress) ...[
          const SizedBox(height: SeedDimension.x1),
          SizedBox(
            width: 80.0,
            child: ClipRRect(
              borderRadius: SeedBorderRadius.full,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: colors.bg.neutralWeak,
                valueColor: AlwaysStoppedAnimation<Color>(mannerColor.text),
                minHeight: 4.0,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
