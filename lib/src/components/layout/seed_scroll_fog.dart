import 'package:material_ui/material_ui.dart';

import '../../theme/seed_theme.dart';
import '../../foundations/gradient/seed_gradient.dart';

/// Placement of [SeedScrollFog].
/// [SeedScrollFogPlacement.top] and [SeedScrollFogPlacement.bottom] use a vertical
/// gradient; [SeedScrollFogPlacement.left] and
/// [SeedScrollFogPlacement.right] use a horizontal gradient.
enum SeedScrollFogPlacement {
  /// Upper edge.
  top,
  /// Lower edge.
  bottom,
  /// Physical left edge.
  left,
  /// Physical right edge.
  right,
}

/// Scroll Fog component of SEED Design System.
///
/// Overlays a subtle gradient fade at the edges of scrollable areas
/// indicating to the user that more content is available.
///
/// The fog stays visible at scroll boundaries. Give the scrollable content
/// padding at least as deep as [size] so endpoint items remain unobscured,
/// and set [color] to match the surface behind the scrollable area.
class SeedScrollFog extends StatelessWidget {
  /// Edge at which fading begins.
  final SeedScrollFogPlacement placement;
  /// Fade depth in logical pixels; null uses 20.
  final double? size;
  /// Solid surface color to fade into; null uses the themed layer background.
  final Color? color;

  /// Creates a noninteractive colored edge fade.
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
            // Covers what the official mask would hide: 1 - mask at each stop.
            colors: SeedGradients.fadeMask().colors
                .map(
                  (color) =>
                      fogColor.withValues(alpha: (1 - color.a) * fogColor.a),
                )
                .toList(),
            stops: SeedGradients.fadeMask().stops,
          ),
        ),
      ),
    );
  }
}

/// Fades the edges of [child] itself, as React's ScrollFog mask does, so no
/// surface color is needed and any background shows through.
class SeedScrollFogMask extends StatelessWidget {
  /// Masks [child] itself, allowing any background to show through.
  const SeedScrollFogMask({
    super.key,
    required this.child,
    this.placement = const {
      SeedScrollFogPlacement.top,
      SeedScrollFogPlacement.bottom,
    },
    this.size = 20,
    this.sizes = const {},
  });

  /// Content whose outer edges become transparent.
  final Widget child;
  /// Edges to fade; defaults to top and bottom.
  final Set<SeedScrollFogPlacement> placement;
  /// Default fade depth in logical pixels; defaults to 20.
  final double size;

  /// Per-placement sizes that override [size].
  final Map<SeedScrollFogPlacement, double> sizes;

  @override
  Widget build(BuildContext context) {
    final fade = SeedGradients.fadeMask();
    var masked = child;
    for (final side in placement) {
      final extent = sizes[side] ?? size;
      final vertical =
          side == SeedScrollFogPlacement.top ||
          side == SeedScrollFogPlacement.bottom;
      final start =
          side == SeedScrollFogPlacement.top ||
          side == SeedScrollFogPlacement.left;
      masked = ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (bounds) {
          final length = vertical ? bounds.height : bounds.width;
          final fraction = length <= 0
              ? 1.0
              : (extent / length).clamp(0.0, 1.0);
          return LinearGradient(
            begin: vertical
                ? (start ? Alignment.topCenter : Alignment.bottomCenter)
                : (start ? Alignment.centerLeft : Alignment.centerRight),
            end: vertical
                ? (start ? Alignment.bottomCenter : Alignment.topCenter)
                : (start ? Alignment.centerRight : Alignment.centerLeft),
            // Transparent at the edge, opaque once [extent] is reached.
            colors: [...fade.colors, const Color(0xFF000000)],
            stops: [for (final stop in fade.stops!) stop * fraction, 1],
          ).createShader(bounds);
        },
        child: masked,
      );
    }
    return masked;
  }
}
