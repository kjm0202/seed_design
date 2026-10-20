import 'package:material_ui/material_ui.dart';

import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/colors/seed_palette.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
import 'seed_content_placeholder.dart';

/// Predefined aspect ratios for [SeedImageFrame].
enum SeedImageRatio {
  square(1.0),
  standard(4.0 / 3.0),
  wide(16.0 / 9.0);

  const SeedImageRatio(this.aspectRatio);
  final double aspectRatio;
}

/// A SEED Design Image Frame component.
///
/// Features:
/// - Predefined or custom aspect ratios
/// - Consistent rounded corners
/// - Built-in fallback placeholder if image is null or fails to load
/// - Overlay support (representative badge, number badge, close button)
class SeedImageFrame extends StatelessWidget {
  const SeedImageFrame({
    super.key,
    this.imageProvider,
    this.ratio = SeedImageRatio.square,
    this.customRatio,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.badge,
    this.onRemove,
    this.overlay,
    this.fallback,
  });

  /// The image provider to load.
  final ImageProvider? imageProvider;

  /// Aspect ratio preset (square 1:1, standard 4:3, wide 16:9).
  final SeedImageRatio ratio;

  /// Optional custom aspect ratio override.
  final double? customRatio;

  /// How the image should be inscribed into the frame.
  final BoxFit fit;

  /// Custom border radius. Defaults to [SeedBorderRadius.r3].
  final BorderRadius? borderRadius;

  /// An optional badge label displayed at the bottom of the image frame.
  final String? badge;

  /// An optional callback when the close/remove button is pressed.
  final VoidCallback? onRemove;

  /// An optional overlay widget placed on top of the image.
  final Widget? overlay;

  /// Fallback widget when image is absent. Defaults to [SeedContentPlaceholder].
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;
    final effectiveRadius = borderRadius ?? SeedBorderRadius.r3;
    final effectiveRatio = customRatio ?? ratio.aspectRatio;

    return AspectRatio(
      aspectRatio: effectiveRatio,
      child: ClipRRect(
        borderRadius: effectiveRadius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image or Fallback
            if (imageProvider != null)
              Image(
                image: imageProvider!,
                fit: fit,
                errorBuilder: (context, error, stackTrace) {
                  return fallback ?? const SeedContentPlaceholder();
                },
              )
            else
              fallback ?? const SeedContentPlaceholder(),

            ?overlay,

            // Bottom badge
            if (badge != null && badge!.isNotEmpty)
              Positioned(
                right: 6,
                bottom: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: SeedPalette.staticBlackAlpha800,
                    borderRadius: SeedBorderRadius.full,
                  ),
                  child: Text(
                    badge!,
                    textAlign: TextAlign.center,
                    style: typography.t1Medium.copyWith(
                      color: SeedPalette.staticWhite,
                    ),
                  ),
                ),
              ),

            // Top-right remove button
            if (onRemove != null)
              Positioned(
                top: SeedDimension.x1,
                right: SeedDimension.x1,
                child: SeedPressable(
                  semanticsLabel: '이미지 삭제',
                  enableScale: false,
                  onTap: onRemove,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                    child: Center(
                      widthFactor: 1,
                      heightFactor: 1,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colors.bg.neutralInverted.withValues(
                            alpha: 0.6,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: SeedPalette.staticWhite,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
