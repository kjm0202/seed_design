import 'package:material_ui/material_ui.dart';

import '../../foundations/radius/seed_radius.dart';
import '../../foundations/gradient/seed_gradient.dart';
import '../../foundations/motion/seed_motion.dart';
import '../../foundations/colors/seed_palette.dart';
import '../../theme/seed_theme.dart';

enum SeedSkeletonTone { neutral, magic }

enum SeedSkeletonRadius {
  r0,
  r8,
  r16,
  full;

  BorderRadius get borderRadius => switch (this) {
    SeedSkeletonRadius.r0 => BorderRadius.zero,
    SeedSkeletonRadius.r8 => SeedBorderRadius.r2,
    SeedSkeletonRadius.r16 => SeedBorderRadius.r4,
    SeedSkeletonRadius.full => SeedBorderRadius.full,
  };
}

/// Skeleton component of SEED Design System.
///
/// Provides animated shimmer placeholders while content is loading.
class SeedSkeleton extends StatefulWidget {
  final double? width;
  final double? height;
  final SeedSkeletonRadius radius;
  final BorderRadius? borderRadius;
  final BoxShape shape;
  final SeedSkeletonTone tone;

  const SeedSkeleton({
    super.key,
    this.width,
    this.height,
    this.radius = SeedSkeletonRadius.r8,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    this.tone = SeedSkeletonTone.neutral,
  });

  const SeedSkeleton.circle({
    super.key,
    required double size,
    this.tone = SeedSkeletonTone.neutral,
  }) : width = size,
       height = size,
       radius = SeedSkeletonRadius.full,
       borderRadius = null,
       shape = BoxShape.circle;

  @override
  State<SeedSkeleton> createState() => _SeedSkeletonState();
}

class _SeedSkeletonState extends State<SeedSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;

    final Color baseColor = widget.tone == SeedSkeletonTone.magic
        ? colors.bg.magicWeak
        : colors.isDark
        ? SeedPalette.gray200Dark
        : SeedPalette.gray200Light;
    final shimmer = widget.tone == SeedSkeletonTone.magic
        ? SeedGradients.shimmerMagic(isDark: colors.isDark)
        : SeedGradients.shimmerNeutral(isDark: colors.isDark);

    final resolvedRadius = widget.shape == BoxShape.rectangle
        ? (widget.borderRadius ?? widget.radius.borderRadius)
        : null;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            shape: widget.shape,
            borderRadius: resolvedRadius,
            color: baseColor,
          ),
          foregroundDecoration: BoxDecoration(
            shape: widget.shape,
            borderRadius: resolvedRadius,
            gradient: LinearGradient(
              colors: shimmer.colors,
              stops: shimmer.stops,
              transform: _ShimmerTransform(
                SeedCurves.easing.transform(_controller.value),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ShimmerTransform extends GradientTransform {
  final double progress;
  const _ShimmerTransform(this.progress);
  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * (progress * 2 - 1), 0, 0);
}
