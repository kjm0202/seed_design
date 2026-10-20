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

    final Color bgColor = isBrand
        ? colors.bg.brandSolid
        : colors.bg.neutralSolid;
    final Color fgColor = isBrand
        ? colors.fg.onBrandSolid
        : colors.fg.onNeutralSolid;

    Widget arrow = CustomPaint(
      size: const Size(12.0, 8.0),
      painter: _TrianglePainter(
        color: bgColor,
        isPointingUp: arrowPlacement == SeedHelpBubbleArrowPlacement.top,
      ),
    );

    Widget bubbleBody = Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: SeedBorderRadius.r3,
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
                  const SizedBox(height: SeedDimension.x0_5),
                  Text(
                    description!,
                    style: typography.t3Regular.copyWith(color: fgColor),
                  ),
                ],
              ],
            ),
          ),
          if (onClose != null) ...[
            const SizedBox(width: SeedDimension.x1),
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
                    width: 38.0,
                    height: 38.0,
                    child: Center(
                      child: Icon(
                        Icons.close_rounded,
                        size: 14.0,
                        color: fgColor,
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
