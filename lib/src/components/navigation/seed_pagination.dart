import 'package:material_ui/material_ui.dart';
import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';

/// A SEED Design Pagination component for multi-page list navigation.
class SeedPagination extends StatelessWidget {
  const SeedPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.maxVisibleSlots = 7,
  }) : assert(currentPage >= 1 && currentPage <= totalPages, 'currentPage must be within 1..totalPages');

  /// The currently active 1-indexed page.
  final int currentPage;

  /// The total number of pages.
  final int totalPages;

  /// Callback when a page number is clicked.
  final ValueChanged<int> onPageChanged;

  /// Maximum slots to show before inserting ellipses ('...'). Defaults to 7.
  final int maxVisibleSlots;

  List<dynamic> _buildPageNumbers() {
    if (totalPages <= maxVisibleSlots) {
      return List.generate(totalPages, (i) => i + 1);
    }

    final pages = <dynamic>[];
    pages.add(1);

    if (currentPage <= 4) {
      for (int i = 2; i <= 5; i++) {
        pages.add(i);
      }
      pages.add('...');
      pages.add(totalPages);
    } else if (currentPage >= totalPages - 3) {
      pages.add('...');
      for (int i = totalPages - 4; i <= totalPages; i++) {
        pages.add(i);
      }
    } else {
      pages.add('...');
      pages.add(currentPage - 1);
      pages.add(currentPage);
      pages.add(currentPage + 1);
      pages.add('...');
      pages.add(totalPages);
    }

    return pages;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;
    final pageItems = _buildPageNumbers();

    return Row(
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
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: InkWell(
                onTap: () => onPageChanged(item),
                borderRadius: SeedBorderRadius.r2,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isCurrent ? colors.bg.neutralSolid : Colors.transparent,
                    borderRadius: SeedBorderRadius.r2,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$item',
                    style: typography.t4Bold.copyWith(
                      color: isCurrent ? colors.fg.onNeutralSolid : colors.fg.neutral,
                    ),
                  ),
                ),
              ),
            );
          } else {
            return SizedBox(
              width: 32,
              height: 36,
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
        width: 36,
        height: 36,
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 20,
          color: enabled ? colors.fg.neutral : colors.fg.disabled,
        ),
      ),
    );
  }
}
