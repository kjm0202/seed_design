import 'package:material_ui/material_ui.dart';

import '../../foundations/radius/seed_radius.dart';
import '../../foundations/gradient/seed_gradient.dart';
import '../../foundations/motion/seed_motion.dart';
import '../../foundations/colors/seed_palette.dart';
import '../../theme/seed_theme.dart';

/// Skeleton component of SEED Design System.
///
/// Provides animated shimmer placeholders while content is loading.
class SeedSkeleton extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxShape shape;

  const SeedSkeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
  });

  const SeedSkeleton.circle({super.key, required double size})
    : width = size,
      height = size,
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

    final Color baseColor = colors.isDark
        ? SeedPalette.gray200Dark
        : SeedPalette.gray200Light;
    final shimmer = SeedGradients.shimmerNeutral(isDark: colors.isDark);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            shape: widget.shape,
            borderRadius: widget.shape == BoxShape.rectangle
                ? (widget.borderRadius ?? SeedBorderRadius.r2)
                : null,
            color: baseColor,
          ),
          foregroundDecoration: BoxDecoration(
            shape: widget.shape,
            borderRadius: widget.shape == BoxShape.rectangle
                ? (widget.borderRadius ?? SeedBorderRadius.r2)
                : null,
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
