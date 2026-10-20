import 'package:material_ui/material_ui.dart';

import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';

/// A SEED Design Pagination component for multi-page list navigation.
class SeedPagination extends StatelessWidget {
  static const double _controlSize = 40;
  static const double _numberPadding = 2;
  const SeedPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.maxVisibleSlots = 7,
  }) : assert(
         currentPage >= 1 && currentPage <= totalPages,
         'currentPage must be within 1..totalPages',
       ),
       assert(maxVisibleSlots > 0, 'maxVisibleSlots must be positive.');

  /// The currently active 1-indexed page.
  final int currentPage;

  /// The total number of pages.
  final int totalPages;

  /// Callback when a page number is clicked.
  final ValueChanged<int> onPageChanged;

  /// Upper limit on numbered and ellipsis slots. Defaults to 7.
  /// Fewer slots are shown when the available width cannot fit them all.
  final int maxVisibleSlots;

  List<Object> _buildPageNumbers(int slots) {
    if (totalPages <= slots) {
      return List.generate(totalPages, (i) => i + 1);
    }

    // In compact layouts, keep a contiguous window around the current page.
    // Previous/next remain available without shrinking the 40px controls.
    if (slots < 5) {
      final start = (currentPage - (slots - 1) ~/ 2).clamp(
        1,
        totalPages - slots + 1,
      );
      return List.generate(slots, (index) => start + index);
    }

    final edgeCount = slots - 2;
    if (currentPage <= edgeCount - 1) {
      return [
        ...List.generate(edgeCount, (index) => index + 1),
        '...',
        totalPages,
      ];
    }
    if (currentPage >= totalPages - edgeCount + 2) {
      return [
        1,
        '...',
        ...List.generate(
          edgeCount,
          (index) => totalPages - edgeCount + index + 1,
        ),
      ];
    }

    final middleCount = slots - 4;
    final start = currentPage - (middleCount - 1) ~/ 2;
    return [
      1,
      start == 3 ? 2 : '...',
      ...List.generate(middleCount, (index) => start + index),
      start + middleCount == totalPages - 1 ? totalPages - 1 : '...',
      totalPages,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;
    return LayoutBuilder(
      builder: (context, constraints) {
        // Count conservatively for ellipses, whose slots have no padding.
        const navigationWidth = 2 * (_controlSize + SeedDimension.x1);
        const slotWidth = _controlSize + 2 * _numberPadding;
        final slots = constraints.hasBoundedWidth
            ? ((constraints.maxWidth - navigationWidth) / slotWidth)
                  .floor()
                  .clamp(1, maxVisibleSlots)
            : maxVisibleSlots;
        final pageItems = _buildPageNumbers(slots);
        final content = Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Prev button
            _buildNavButton(
              context,
              icon: Icons.chevron_left,
              enabled: currentPage > 1,
              onTap: () => onPageChanged(currentPage - 1),
            ),
            const SizedBox(width: SeedDimension.x1),

            // Page buttons and ellipses
            ...pageItems.map((item) {
              if (item is int) {
                final isCurrent = item == currentPage;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _numberPadding,
                  ),
                  child: InkWell(
                    onTap: () => onPageChanged(item),
                    borderRadius: SeedBorderRadius.r2,
                    child: Container(
                      width: _controlSize,
                      height: _controlSize,
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? colors.bg.neutralSolid
                            : Colors.transparent,
                        borderRadius: SeedBorderRadius.r2,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$item',
                        style: typography.t4Bold.copyWith(
                          color: isCurrent
                              ? colors.fg.onNeutralSolid
                              : colors.fg.neutral,
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                return SizedBox(
                  width: _controlSize,
                  height: _controlSize,
                  child: Center(
                    child: Text(
                      '...',
                      style: typography.t4Regular.copyWith(
                        color: colors.fg.neutralSubtle,
                      ),
                    ),
                  ),
                );
              }
            }),

            const SizedBox(width: SeedDimension.x1),
            // Next button
            _buildNavButton(
              context,
              icon: Icons.chevron_right,
              enabled: currentPage < totalPages,
              onTap: () => onPageChanged(currentPage + 1),
            ),
          ],
        );
        if (constraints.hasBoundedWidth &&
            constraints.maxWidth < navigationWidth + slotWidth) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            primary: false,
            child: content,
          );
        }
        return content;
      },
    );
  }

  Widget _buildNavButton(
    BuildContext context, {
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    final colors = context.seedColor;
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: SeedBorderRadius.r2,
      child: Container(
        width: _controlSize,
        height: _controlSize,
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 16,
          color: enabled ? colors.fg.neutral : colors.fg.disabled,
        ),
      ),
    );
  }
}
