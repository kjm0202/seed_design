import 'package:material_ui/material_ui.dart';

import '../../theme/seed_theme.dart';

/// Divider component of SEED Design System.
///
/// Provides visual separation between content sections and list items.
class SeedDivider extends StatelessWidget {
  /// Line thickness in logical pixels; defaults to 1.
  final double thickness;

  /// Explicit line color; null uses the themed muted stroke.
  final Color? color;

  /// Empty space before the line along its cross-axis edge.
  final double? indent;

  /// Empty space after the line along its cross-axis edge.
  final double? endIndent;

  /// Horizontal by default, or vertical when created with [SeedDivider.vertical].
  final Axis direction;

  /// Optional announcement for a meaningful section boundary.
  /// Leave null for a purely decorative divider.
  final String? semanticsLabel;

  /// Creates a horizontal separator by default.
  const SeedDivider({
    super.key,
    this.thickness = 1.0,
    this.color,
    this.semanticsLabel,
    this.indent,
    this.endIndent,
    this.direction = Axis.horizontal,
  });

  /// Creates a vertical separator; [indent] and [endIndent] become top/bottom margins.
  const SeedDivider.vertical({
    super.key,
    this.thickness = 1.0,
    this.color,
    this.semanticsLabel,
    this.indent,
    this.endIndent,
  }) : direction = Axis.vertical;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? context.seedColor.stroke.neutralMuted;

    final Widget line;
    if (direction == Axis.vertical) {
      line = Container(
        width: thickness,
        margin: EdgeInsets.only(top: indent ?? 0.0, bottom: endIndent ?? 0.0),
        color: effectiveColor,
      );
    } else {
      line = Container(
        height: thickness,
        margin: EdgeInsets.only(left: indent ?? 0.0, right: endIndent ?? 0.0),
        color: effectiveColor,
      );
    }
    return semanticsLabel == null
        ? line
        : Semantics(label: semanticsLabel, child: line);
  }
}
