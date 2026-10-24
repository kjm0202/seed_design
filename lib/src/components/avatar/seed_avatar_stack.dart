import 'package:material_ui/material_ui.dart';

import '../../theme/seed_theme.dart';
import '../layout/seed_avatar.dart';

/// Avatar Stack component of SEED Design System.
///
/// Renders an overlapping horizontal stack of avatars with official negative gaps
/// and layer background separator strokes.
class SeedAvatarStack extends StatelessWidget {
  final List<Widget> children;
  final SeedAvatarSize size;
  final int? maxVisible;
  final Widget? overflowBadge;
  final Color? strokeColor;

  const SeedAvatarStack({
    super.key,
    required this.children,
    this.size = SeedAvatarSize.medium,
    this.maxVisible,
    this.overflowBadge,
    this.strokeColor,
  });

  double get _gap {
    switch (size.dimension.toInt()) {
      case 20:
        return -5.0;
      case 24:
        return -6.0;
      case 36:
        return -8.0;
      case 42:
        return -10.0;
      case 48:
        return -12.0;
      case 56:
        return -13.0;
      case 64:
        return -16.0;
      case 80:
        return -20.0;
      case 96:
        return -24.0;
      case 108:
        return -27.0;
      default:
        return -(size.dimension * 0.25);
    }
  }

  double get _strokeWidth {
    switch (size.dimension.toInt()) {
      case 20:
      case 24:
        return 1.0;
      case 36:
      case 42:
      case 48:
        return 2.0;
      case 56:
      case 64:
        return 3.0;
      case 80:
        return 4.0;
      case 96:
      case 108:
        return 5.0;
      default:
        return 2.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final effectiveStrokeColor = strokeColor ?? colors.bg.layerDefault;

    final visibleCount = maxVisible != null
        ? children.length.clamp(0, maxVisible!)
        : children.length;
    final itemsToRender = children.take(visibleCount).toList();
    final remaining = children.length - visibleCount;

    final double itemSize = size.dimension;
    final double step = itemSize + _gap;
    final int totalCount = itemsToRender.length + (remaining > 0 ? 1 : 0);
    final double totalWidth = totalCount > 0
        ? (totalCount - 1) * step + itemSize
        : 0;

    return SizedBox(
      width: totalWidth,
      height: itemSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int i = 0; i < itemsToRender.length; i++)
            Positioned(
              left: i * step,
              top: 0,
              child: Container(
                width: itemSize,
                height: itemSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: effectiveStrokeColor,
                    width: _strokeWidth,
                  ),
                ),
                child: ClipOval(child: itemsToRender[i]),
              ),
            ),
          if (remaining > 0)
            Positioned(
              left: itemsToRender.length * step,
              top: 0,
              child: Container(
                width: itemSize,
                height: itemSize,
                decoration: BoxDecoration(
                  color: colors.bg.neutralWeak,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: effectiveStrokeColor,
                    width: _strokeWidth,
                  ),
                ),
                child: Center(
                  child:
                      overflowBadge ??
                      Text(
                        '+$remaining',
                        style: context.seedTypography.t2Bold.copyWith(
                          color: colors.fg.neutral,
                        ),
                      ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
