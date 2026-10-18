import 'package:material_ui/material_ui.dart';

import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';

/// Arrow orientation for [SeedHelpBubble].
enum SeedHelpBubbleArrowPlacement { top, bottom, none }

/// Help Bubble (Tooltip speech bubble) component of SEED Design System.
///
/// Highlights new features, provides contextual guidance, and supports
/// directional indicator arrows and close actions.
class SeedHelpBubble extends StatelessWidget {
  final String title;
  final String? description;
  final VoidCallback? onClose;
  final SeedHelpBubbleArrowPlacement arrowPlacement;
  final double arrowOffset;
  final bool isBrand;

  const SeedHelpBubble({
    super.key,
    required this.title,
    this.description,
    this.onClose,
    this.arrowPlacement = SeedHelpBubbleArrowPlacement.top,
    this.arrowOffset = 24.0,
    this.isBrand = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;
    final shadows = context.seedShadows;

    final Color bgColor = isBrand
        ? colors.bg.brandSolid
        : colors.bg.neutralInverted;
    final Color fgColor = isBrand
        ? colors.fg.onBrandSolid
        : colors.fg.neutralInverted;

    Widget arrow = CustomPaint(
      size: const Size(14.0, 7.0),
      painter: _TrianglePainter(
        color: bgColor,
        isPointingUp: arrowPlacement == SeedHelpBubbleArrowPlacement.top,
      ),
    );

    Widget bubbleBody = Container(
      padding: const EdgeInsets.fromLTRB(
        SeedDimension.x4,
        SeedDimension.x3,
        SeedDimension.x3,
        SeedDimension.x3,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: SeedBorderRadius.r3,
        boxShadow: shadows.s2,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: typography.t3Bold.copyWith(color: fgColor)),
                if (description != null) ...[
                  const SizedBox(height: SeedDimension.x1),
                  Text(
                    description!,
                    style: typography.t2Regular.copyWith(
                      color: fgColor.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onClose != null) ...[
            const SizedBox(width: SeedDimension.x2),
            SeedPressable(
              semanticsLabel: '닫기',
              enableScale: false,
              behavior: HitTestBehavior.opaque,
              onTap: onClose,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                child: Center(
                  widthFactor: 1,
                  heightFactor: 1,
                  child: SizedBox(
                    width: 24.0,
                    height: 24.0,
                    child: Center(
                      child: Icon(
                        Icons.close_rounded,
                        size: 16.0,
                        color: fgColor.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );

    if (arrowPlacement == SeedHelpBubbleArrowPlacement.none) {
      return bubbleBody;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (arrowPlacement == SeedHelpBubbleArrowPlacement.top) ...[
          Padding(
            padding: EdgeInsets.only(left: arrowOffset),
            child: arrow,
          ),
        ],
        bubbleBody,
        if (arrowPlacement == SeedHelpBubbleArrowPlacement.bottom) ...[
          Padding(
            padding: EdgeInsets.only(left: arrowOffset),
            child: arrow,
          ),
        ],
      ],
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  final bool isPointingUp;

  _TrianglePainter({required this.color, required this.isPointingUp});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    if (isPointingUp) {
      path.moveTo(0, size.height);
      path.lineTo(size.width / 2, 0);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, 0);
      path.lineTo(size.width / 2, size.height);
      path.lineTo(size.width, 0);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.isPointingUp != isPointingUp;
  }
}
