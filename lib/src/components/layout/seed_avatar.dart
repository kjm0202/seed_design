import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';

import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';
import 'seed_identity_placeholder.dart';

/// Size options for [SeedAvatar] corresponding to SEED Design specifications.
enum SeedAvatarSize {
  size20,
  size24,
  size36,
  small,
  size42,
  medium,
  size48,
  size56,
  large,
  size64,
  size80,
  xlarge,
  size96,
  size108;

  double get dimension {
    switch (this) {
      case SeedAvatarSize.size20:
        return 20.0;
      case SeedAvatarSize.size24:
        return 24.0;
      case SeedAvatarSize.size36:
      case SeedAvatarSize.small:
        return 36.0;
      case SeedAvatarSize.size42:
      case SeedAvatarSize.medium:
        return 42.0;
      case SeedAvatarSize.size48:
        return 48.0;
      case SeedAvatarSize.size56:
      case SeedAvatarSize.large:
        return 56.0;
      case SeedAvatarSize.size64:
        return 64.0;
      case SeedAvatarSize.size80:
      case SeedAvatarSize.xlarge:
        return 80.0;
      case SeedAvatarSize.size96:
        return 96.0;
      case SeedAvatarSize.size108:
        return 108.0;
    }
  }

  double get iconSize => dimension * 0.5;

  // badge size, badge offset, mask size, mask offset from Rootage.
  (double, double, double, double) get _badgeGeometry => switch (dimension) {
    24 => (10, 15, 12, 14),
    36 => (14, 22, 18, 20),
    42 => (16, 26, 20, 24),
    48 => (18, 30, 22, 28),
    56 => (20, 36, 24, 34),
    64 => (22, 42, 26, 40),
    80 => (28, 54, 32, 52),
    96 => (32, 65, 38, 62),
    108 => (36, 74, 44, 70),
    _ => (0, 0, 0, 0),
  };
}

enum SeedAvatarBadgeMask { circle, flower, shield }

/// Avatar component of SEED Design System.
///
/// Displays user profile pictures, store logos, or default placeholder graphics.
/// Supports 10 official sizes (20..108px) and badge attachments.
class SeedAvatar extends StatelessWidget {
  final ImageProvider? image;
  final Widget? placeholder;
  final SeedAvatarSize size;
  final BorderRadius? borderRadius;
  final Widget? badge;
  final AlignmentGeometry badgeAlignment;
  final SeedAvatarBadgeMask? badgeMask;

  /// Overrides the official badge dimensions.
  final double? badgeSize;

  /// Uses the official size-specific gap by default. A non-default value
  /// overrides the gap; custom [badgeSize] uses this value directly.
  final double badgeMaskPadding;

  const SeedAvatar({
    super.key,
    this.image,
    this.placeholder,
    this.size = SeedAvatarSize.size48,
    this.borderRadius,
    this.badge,
    this.badgeAlignment = Alignment.bottomRight,
    this.badgeMask,
    this.badgeSize,
    this.badgeMaskPadding = 2,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final effectiveRadius = borderRadius ?? SeedBorderRadius.full;

    final avatarBody = ClipRRect(
      borderRadius: effectiveRadius,
      child: Container(
        width: size.dimension,
        height: size.dimension,
        decoration: BoxDecoration(
          color: colors.bg.neutralWeak,
          borderRadius: effectiveRadius,
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: effectiveRadius,
          border: Border.all(color: colors.stroke.neutralSubtle),
        ),
        alignment: Alignment.center,
        child: image == null
            ? (placeholder ?? SeedIdentityPlaceholder(size: size.dimension))
            : ClipRRect(
                borderRadius: effectiveRadius,
                child: Image(
                  image: image!,
                  width: size.dimension,
                  height: size.dimension,
                  fit: BoxFit.cover,
                  frameBuilder:
                      (context, child, frame, wasSynchronouslyLoaded) =>
                          wasSynchronouslyLoaded || frame != null
                          ? child
                          : (placeholder ??
                                SeedIdentityPlaceholder(size: size.dimension)),
                  errorBuilder: (context, error, stackTrace) =>
                      placeholder ??
                      SeedIdentityPlaceholder(size: size.dimension),
                ),
              ),
      ),
    );

    if (badge != null && size != SeedAvatarSize.size20) {
      final (tokenSize, tokenOffset, maskSize, maskOffset) =
          size._badgeGeometry;
      final dimension = badgeSize ?? tokenSize;
      final alignment = badgeAlignment.resolve(Directionality.of(context));
      final offset = badgeSize == null
          ? tokenOffset - (size.dimension - dimension)
          : 0.0;
      final badgeRect = alignment
          .inscribe(
            Size.square(dimension),
            Offset.zero & Size.square(size.dimension),
          )
          .shift(Offset(alignment.x * offset, alignment.y * offset));
      final padding = badgeSize == null && badgeMaskPadding == 2
          ? tokenOffset - maskOffset
          : badgeMaskPadding;
      assert(
        badgeSize != null ||
            maskSize == tokenSize + (tokenOffset - maskOffset) * 2,
      );
      return SizedBox(
        width: size.dimension,
        height: size.dimension,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (badgeMask != null)
              ClipPath(
                clipper: _SeedAvatarMask(
                  badgeMask!,
                  badgeRect.inflate(padding),
                ),
                child: avatarBody,
              )
            else
              avatarBody,
            Positioned.fromRect(
              rect: badgeRect,
              child: Center(child: badge!),
            ),
          ],
        ),
      );
    }

    return avatarBody;
  }
}

class _SeedAvatarMask extends CustomClipper<Path> {
  const _SeedAvatarMask(this.mask, this.rect);
  final SeedAvatarBadgeMask mask;
  final Rect rect;
  @override
  Path getClip(Size size) {
    // Official SVG mask paths, expressed in their original 32 x 32 viewBox.
    final Path hole;
    switch (mask) {
      case SeedAvatarBadgeMask.circle:
        hole = Path()..addOval(rect);
      case SeedAvatarBadgeMask.flower:
        final source = Path()
          ..moveTo(29.9115, 8)
          ..cubicTo(28.4089, 5.42609, 25.682, 4.02087, 22.8994, 4.10435)
          ..cubicTo(21.5637, 1.68348, 19.0037, 0, 15.9985, 0)
          ..cubicTo(12.9933, 0, 10.4333, 1.65565, 9.09762, 4.10435)
          ..cubicTo(6.32893, 4.03478, 3.60197, 5.42609, 2.09936, 8)
          ..cubicTo(0.596754, 10.5739, 0.76371, 13.6348, 2.19675, 16)
          ..cubicTo(0.749797, 18.3652, 0.596754, 21.4261, 2.09936, 24)
          ..cubicTo(3.60197, 26.5739, 6.32893, 27.9791, 9.11154, 27.8957)
          ..cubicTo(10.4472, 30.3165, 13.0072, 32, 16.0124, 32)
          ..cubicTo(19.0176, 32, 21.5776, 30.3443, 22.9133, 27.8957)
          ..cubicTo(25.682, 27.9652, 28.4089, 26.5739, 29.9115, 24)
          ..cubicTo(31.4141, 21.4261, 31.2472, 18.3652, 29.8141, 16)
          ..cubicTo(31.2611, 13.6348, 31.4141, 10.5739, 29.9115, 8)
          ..close();
        hole = source.transform(
          Float64List.fromList([
            rect.width / 32,
            0,
            0,
            0,
            0,
            rect.height / 32,
            0,
            0,
            0,
            0,
            1,
            0,
            rect.left,
            rect.top,
            0,
            1,
          ]),
        );
      case SeedAvatarBadgeMask.shield:
        final source = Path()
          ..moveTo(18.137, 31.4527)
          ..cubicTo(18.1171, 31.4616, 18.0943, 31.4721, 18.0531, 31.491)
          ..cubicTo(18.046, 31.4943, 18.0356, 31.4994, 18.0221, 31.5059)
          ..cubicTo(17.8282, 31.5996, 16.9959, 32.0019, 16.0001, 32)
          ..cubicTo(15.0096, 32.002, 14.1895, 31.6075, 13.986, 31.5096)
          ..lineTo(13.8629, 31.4527)
          ..cubicTo(13.5452, 31.3105, 13.1039, 31.1059, 12.5795, 30.8436)
          ..cubicTo(11.541, 30.3242, 10.1273, 29.554, 8.68691, 28.5676)
          ..cubicTo(7.2706, 27.5976, 5.67543, 26.3154, 4.39746, 24.7323)
          ..cubicTo(3.12739, 23.159, 1.92743, 20.9794, 1.92743, 18.3179)
          ..lineTo(1.92743, 7.77468)
          ..cubicTo(1.92743, 6.02645, 3.02031, 4.4647, 4.66276, 3.86583)
          ..lineTo(14.5747, 0.25173)
          ..cubicTo(15.4953, -0.0839101, 16.5047, -0.0839101, 17.4252, 0.25173)
          ..lineTo(27.3372, 3.86583)
          ..cubicTo(28.9796, 4.4647, 30.0725, 6.02646, 30.0725, 7.77468)
          ..lineTo(30.0725, 18.3179)
          ..cubicTo(30.0725, 20.9794, 28.8726, 23.159, 27.6025, 24.7323)
          ..cubicTo(26.3245, 26.3154, 24.7294, 27.5976, 23.313, 28.5676)
          ..cubicTo(21.8727, 29.554, 20.4589, 30.3242, 19.4205, 30.8436)
          ..cubicTo(18.8961, 31.1059, 18.4547, 31.3106, 18.137, 31.4527)
          ..close();
        hole = source.transform(
          Float64List.fromList([
            rect.width / 32,
            0,
            0,
            0,
            0,
            rect.height / 32,
            0,
            0,
            0,
            0,
            1,
            0,
            rect.left,
            rect.top,
            0,
            1,
          ]),
        );
    }
    return Path.combine(
      PathOperation.difference,
      Path()..addRect(Offset.zero & size),
      hole,
    );
  }

  @override
  bool shouldReclip(_SeedAvatarMask oldClipper) =>
      oldClipper.mask != mask || oldClipper.rect != rect;
}
