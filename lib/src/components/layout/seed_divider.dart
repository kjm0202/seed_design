import 'package:material_ui/material_ui.dart';
import '../../theme/seed_theme.dart';

/// Divider component of SEED Design System.
///
/// Provides visual separation between content sections and list items.
class SeedDivider extends StatelessWidget {
  final double thickness;
  final Color? color;
  final double? indent;
  final double? endIndent;
  final Axis direction;

  const SeedDivider({
    super.key,
    this.thickness = 1.0,
    this.color,
    this.indent,
    this.endIndent,
    this.direction = Axis.horizontal,
  });

  const SeedDivider.vertical({
    super.key,
    this.thickness = 1.0,
    this.color,
    this.indent,
    this.endIndent,
  }) : direction = Axis.vertical;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? context.seedColor.stroke.neutralWeak;

    if (direction == Axis.vertical) {
      return Container(
        width: thickness,
        margin: EdgeInsets.only(
          top: indent ?? 0.0,
          bottom: endIndent ?? 0.0,
        ),
        color: effectiveColor,
      );
    }

    return Container(
      height: thickness,
      margin: EdgeInsets.only(
        left: indent ?? 0.0,
        right: endIndent ?? 0.0,
      ),
      color: effectiveColor,
    );
  }
}
