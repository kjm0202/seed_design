import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../theme/seed_theme.dart';
import '../../foundations/colors/seed_palette.dart';

enum SeedIdentityType { person, business }

/// Original SEED identity artwork, filling its parent's bounded dimensions.
/// Clipping belongs to the parent (for example, [SeedAvatar]).
class SeedIdentityPlaceholder extends StatelessWidget {
  const SeedIdentityPlaceholder({
    super.key,
    this.type = SeedIdentityType.person,
    this.size,
    this.backgroundColor,
    this.iconColor,
    this.semanticsLabel = 'Identity placeholder',
  });
  final SeedIdentityType type;

  /// Explicit square size; unbounded axes fall back to 42 logical pixels.
  final double? size;
  final Color? backgroundColor, iconColor;

  /// Set to null when the artwork is decorative.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    return LayoutBuilder(
      builder: (context, constraints) => Semantics(
        container: semanticsLabel != null,
        image: semanticsLabel != null,
        label: semanticsLabel,
        excludeSemantics: true,
        child: SizedBox(
          width:
              size ?? (constraints.hasBoundedWidth ? constraints.maxWidth : 42),
          height:
              size ??
              (constraints.hasBoundedHeight ? constraints.maxHeight : 42),
          child: ColoredBox(
            color:
                backgroundColor ??
                (colors.isDark
                    ? SeedPalette.gray500Dark
                    : SeedPalette.gray500Light),
            child: CustomPaint(
              painter: _IdentityPainter(
                type,
                iconColor ?? SeedPalette.staticWhiteAlpha800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IdentityPainter extends CustomPainter {
  const _IdentityPainter(this.type, this.color);
  final SeedIdentityType type;
  final Color color;

  // Adapted from SEED Design IdentityPlaceholderImage, revision 14aa12a2.
  // Copyright 2025 주식회사 당근마켓, Apache-2.0.
  // Modification: SVG path commands converted to Flutter Path (640 x 640).
  // See THIRD_PARTY_NOTICES.md and third_party/seed-design/LICENSE.
  static final Path _business = Path()
    ..moveTo(512, 250)
    ..lineTo(483, 177)
    ..cubicTo(476, 160, 459, 148, 441, 148)
    ..lineTo(200, 148)
    ..cubicTo(182, 148, 165, 160, 158, 177)
    ..lineTo(129, 250)
    ..quadraticBezierTo(126, 257, 131, 264)
    ..cubicTo(148, 287, 173, 305, 202, 305)
    ..quadraticBezierTo(237, 303, 261, 279)
    ..quadraticBezierTo(286, 303, 320, 305)
    ..quadraticBezierTo(355, 303, 379, 279)
    ..quadraticBezierTo(404, 303, 438, 305)
    ..cubicTo(466, 305, 494, 287, 510, 264)
    ..cubicTo(512, 261, 513, 253, 512, 250)
    ..moveTo(439, 340)
    ..cubicTo(411, 340, 392, 328, 380, 317)
    ..arcToPoint(
      const Offset(321, 340),
      radius: const Radius.elliptical(86, 86),
      rotation: 0,
      largeArc: false,
      clockwise: true,
    )
    ..cubicTo(293, 340, 273, 328, 262, 317)
    ..arcToPoint(
      const Offset(202, 340),
      radius: const Radius.elliptical(86, 86),
      rotation: 0,
      largeArc: false,
      clockwise: true,
    )
    ..quadraticBezierTo(169, 338, 149, 323)
    ..lineTo(149, 442)
    ..cubicTo(149, 469, 171, 491, 198, 491)
    ..lineTo(336, 491)
    ..lineTo(443, 492)
    ..cubicTo(470, 492, 492, 470, 492, 442)
    ..lineTo(492, 323)
    ..quadraticBezierTo(472, 338, 439, 340)
    ..moveTo(296, 412)
    ..quadraticBezierTo(295, 423, 284, 424)
    ..lineTo(266, 424)
    ..quadraticBezierTo(255, 422, 254, 412)
    ..lineTo(254, 393)
    ..quadraticBezierTo(255, 383, 266, 382)
    ..lineTo(284, 382)
    ..quadraticBezierTo(295, 383, 296, 393)
    ..close()
    ..moveTo(387, 412)
    ..quadraticBezierTo(386, 423, 376, 424)
    ..lineTo(357, 424)
    ..quadraticBezierTo(346, 422, 345, 412)
    ..lineTo(345, 393)
    ..quadraticBezierTo(346, 383, 357, 382)
    ..lineTo(376, 382)
    ..quadraticBezierTo(386, 383, 387, 393)
    ..close();
  static final Path _person = Path()
    ..moveTo(496, 460)
    ..quadraticBezierTo(500, 465, 496, 471)
    ..cubicTo(454, 523, 399, 552, 320, 552)
    ..cubicTo(241, 552, 186, 523, 144, 471)
    ..quadraticBezierTo(141, 466, 143, 461)
    ..cubicTo(176, 411, 247, 387, 320, 387)
    ..cubicTo(393, 387, 464, 410, 496, 460)
    ..moveTo(222, 251)
    ..arcToPoint(
      const Offset(418, 251),
      radius: const Radius.elliptical(98, 98),
      rotation: 0,
      largeArc: false,
      clockwise: true,
    )
    ..cubicTo(418, 305, 374, 348, 320, 348)
    ..cubicTo(266, 348, 222, 305, 222, 251);

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width, size.height) / 640;
    canvas.save();
    canvas.translate(
      (size.width - 640 * scale) / 2,
      (size.height - 640 * scale) / 2,
    );
    canvas.scale(scale);
    canvas.drawPath(
      type == SeedIdentityType.person ? _person : _business,
      Paint()..color = color,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_IdentityPainter oldDelegate) =>
      type != oldDelegate.type || color != oldDelegate.color;
}
