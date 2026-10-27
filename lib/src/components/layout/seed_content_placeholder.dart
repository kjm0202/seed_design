import 'package:material_ui/material_ui.dart';

import '../../foundations/colors/seed_palette.dart';
import '../../theme/seed_theme.dart';

part 'seed_content_placeholder_presets.dart';

/// Predefined domain types for [SeedContentPlaceholder] as specified by SEED Design.
enum SeedContentPlaceholderType {
  defaultType,
  buySell,
  car,
  commerce,
  coupon,
  food,
  group,
  image,
  jobs,
  business,
  post,
  realty,
}

/// A SEED Design Content Placeholder component.
///
/// Used as a fallback visual placeholder when images or media content
/// are absent or failed to load.
class SeedContentPlaceholder extends StatelessWidget {
  const SeedContentPlaceholder({
    super.key,
    this.type = SeedContentPlaceholderType.defaultType,
    this.width,
    this.height,
    this.icon,
    this.iconSize,
    this.borderRadius,
  });

  /// Predefined domain preset type. Defaults to [SeedContentPlaceholderType.defaultType].
  final SeedContentPlaceholderType type;

  /// Optional width. If null, expands to fill parent.
  final double? width;

  /// Optional height. If null, expands to fill parent.
  final double? height;

  /// Custom asset. Inherits the preset color and fits the same asset bounds.
  final Widget? icon;

  /// Square asset size override. Otherwise height is 50% of the parent and
  /// width is constrained to 16..160, with the drawing fitted inside.
  final double? iconSize;

  /// Border radius of the clipped placeholder box. Defaults to square corners.
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final bgColor = colors.isDark
        ? SeedPalette.gray200Dark
        : SeedPalette.gray200Light;
    final fgColor = colors.isDark
        ? SeedPalette.gray400Dark
        : SeedPalette.gray400Light;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: borderRadius ?? BorderRadius.zero,
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final assetHeight =
              iconSize ??
              (constraints.maxHeight.isFinite
                  ? constraints.maxHeight * 0.5
                  : 32.0);
          final assetWidth = iconSize ?? assetHeight.clamp(16.0, 160.0);
          return Center(
            child: SizedBox(
              width: assetWidth,
              height: assetHeight,
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox.square(
                  dimension: 64,
                  child: IconTheme(
                    data: IconThemeData(color: fgColor, size: 64),
                    child:
                        icon ??
                        CustomPaint(
                          painter: _SeedContentPlaceholderPainter(
                            type,
                            fgColor,
                          ),
                        ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SeedContentPlaceholderPainter extends CustomPainter {
  const _SeedContentPlaceholderPainter(this.type, this.color);
  final SeedContentPlaceholderType type;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 64, size.height / 64);
    final paint = Paint()..color = color;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke;
    for (final path in _contentPlaceholderPaths[type]!) {
      canvas.drawPath(path, paint);
      // The React asset recipe applies both fill and the default 1px stroke.
      canvas.drawPath(path, stroke);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SeedContentPlaceholderPainter oldDelegate) =>
      type != oldDelegate.type || color != oldDelegate.color;
}
