import 'package:material_ui/material_ui.dart';

import '../../foundations/dimensions/seed_dimension.dart';

/// Container that groups multiple [SeedSelectBox] items with official SEED Design spacing.
///
/// Features `gapX: 12px` and `gapY: 12px` (`componentDefault`).
class SeedSelectBoxGroup extends StatelessWidget {
  final List<Widget> children;
  final Axis direction;
  final WrapCrossAlignment crossAxisAlignment;

  const SeedSelectBoxGroup({
    super.key,
    required this.children,
    this.direction = Axis.vertical,
    this.crossAxisAlignment = WrapCrossAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    if (direction == Axis.vertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: SeedSpacingY.componentDefault),
            children[i],
          ],
        ],
      );
    }

    return Wrap(
      direction: direction,
      spacing: SeedDimension.x3,
      runSpacing: SeedSpacingY.componentDefault,
      crossAxisAlignment: crossAxisAlignment,
      children: children,
    );
  }
}
