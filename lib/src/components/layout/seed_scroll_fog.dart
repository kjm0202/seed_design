import 'package:material_ui/material_ui.dart';

import '../../theme/seed_theme.dart';
import '../../foundations/gradient/seed_gradient.dart';

/// Placement of [SeedScrollFog].
enum SeedScrollFogPlacement { top, bottom, left, right }

/// Scroll Fog component of SEED Design System.
///
/// Overlays a subtle gradient fade at the edges of scrollable areas
/// indicating to the user that more content is available.
class SeedScrollFog extends StatelessWidget {
  final SeedScrollFogPlacement placement;
  final double? size;
  final Color? color;

  const SeedScrollFog({
    super.key,
    required this.placement,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final Color fogColor = color ?? colors.bg.layerDefault;

    double effectiveSize;
    Alignment begin;
    Alignment end;

    switch (placement) {
      case SeedScrollFogPlacement.top:
        effectiveSize = size ?? 20.0;
        begin = Alignment.topCenter;
        end = Alignment.bottomCenter;
        break;
      case SeedScrollFogPlacement.bottom:
        effectiveSize = size ?? 20.0;
        begin = Alignment.bottomCenter;
        end = Alignment.topCenter;
        break;
      case SeedScrollFogPlacement.left:
        effectiveSize = size ?? 20.0;
        begin = Alignment.centerLeft;
        end = Alignment.centerRight;
        break;
      case SeedScrollFogPlacement.right:
        effectiveSize = size ?? 20.0;
        begin = Alignment.centerRight;
        end = Alignment.centerLeft;
        break;
    }

    final isVertical =
        placement == SeedScrollFogPlacement.top ||
        placement == SeedScrollFogPlacement.bottom;

    return IgnorePointer(
      child: Container(
        width: isVertical ? double.infinity : effectiveSize,
        height: isVertical ? effectiveSize : double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: begin,
            end: end,
            colors: SeedGradients.fadeMask().colors.reversed
                .map(
                  (color) => fogColor.withValues(alpha: color.a * fogColor.a),
                )
                .toList(),
            stops: SeedGradients.fadeMask().stops!.reversed
                .map((stop) => 1 - stop)
                .toList(),
          ),
        ),
      ),
    );
  }
}
