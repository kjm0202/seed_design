import 'package:material_ui/material_ui.dart';

import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';
import '../input/seed_input_button.dart';
import '../input/seed_select.dart';

/// A SEED Design Table Pagination component.
///
/// Designed for data tables:
/// - Rows per page dropdown selector (`{n}개 씩 보기`)
/// - Page range label (`1–10 / 총 320개` or unknown total mode)
/// - Previous and Next navigation buttons
/// - Responsive layout wrapping cleanly at narrow widths
class SeedTablePagination extends StatelessWidget {
  const SeedTablePagination({
    super.key,
    required this.currentPage,
    this.totalItems,
    required this.rowsPerPage,
    this.rowsPerPageOptions = const [10, 25, 50],
    required this.onPageChanged,
    required this.onRowsPerPageChanged,
    this.hasPreviousPage,
    this.hasNextPage,
  });

  /// 1-indexed current page.
  final int currentPage;

  /// Total count of items across all pages. If null, operates in unknown total mode.
  final int? totalItems;

  /// Number of rows displayed per page.
  final int rowsPerPage;

  /// Selectable options for rows per page.
  final List<int> rowsPerPageOptions;

  /// Callback when page changes.
  final ValueChanged<int> onPageChanged;

  /// Callback when rows per page changes.
  final ValueChanged<int> onRowsPerPageChanged;

  /// Explicit flag whether previous page exists in unknown total mode.
  final bool? hasPreviousPage;

  /// Explicit flag whether next page exists in unknown total mode.
  final bool? hasNextPage;

  int get _totalPages => totalItems == null
      ? 999999
      : (totalItems! / rowsPerPage).ceil().clamp(1, 999999);

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;

    final startItem = totalItems == null
        ? (currentPage - 1) * rowsPerPage + 1
        : (totalItems == 0 ? 0 : (currentPage - 1) * rowsPerPage + 1);
    final endItem = totalItems == null
        ? currentPage * rowsPerPage
        : (currentPage * rowsPerPage).clamp(0, totalItems!);

    final canGoPrev = hasPreviousPage ?? (currentPage > 1);
    final canGoNext = hasNextPage ?? (currentPage < _totalPages);

    final rangeText = totalItems != null
        ? '$startItem–$endItem / 총 $totalItems개'
        : '$startItem–$endItem';

    return LayoutBuilder(
      builder: (context, constraints) => SizedBox(
        width: constraints.hasBoundedWidth ? constraints.maxWidth : null,
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: SeedDimension.x4,
          runSpacing: SeedDimension.x3,
          children: [
            // Left: Rows per page selector
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: SeedDimension.x2,
              runSpacing: SeedDimension.x2,
              children: [
                SizedBox(
                  width: 96,
                  child: SeedSelect<int>(
                    size: SeedInputButtonSize.small,
                    value: rowsPerPage,
                    groups: [
                      SeedSelectGroup<int>(
                        items: rowsPerPageOptions.map((opt) {
                          return SeedSelectItem<int>(
                            value: opt,
                            label: '$opt개',
                          );
                        }).toList(),
                      ),
                    ],
                    onChanged: (val) => onRowsPerPageChanged(val),
                  ),
                ),
                Text(
                  '씩 보기',
                  style: typography.t4Regular.copyWith(
                    color: colors.fg.neutral,
                  ),
                ),
              ],
            ),

            // Right: Range display & Next/Prev buttons
            Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: SeedDimension.x4,
              runSpacing: SeedDimension.x2,
              children: [
                Text(
                  rangeText,
                  style: typography.t4Regular.copyWith(
                    color: colors.fg.neutral,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: canGoPrev
                          ? () => onPageChanged(currentPage - 1)
                          : null,
                      borderRadius: SeedBorderRadius.r2,
                      child: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.chevron_left,
                          size: 16,
                          color: canGoPrev
                              ? colors.fg.neutral
                              : colors.fg.disabled,
                        ),
                      ),
                    ),
                    const SizedBox(width: SeedDimension.x1),
                    InkWell(
                      onTap: canGoNext
                          ? () => onPageChanged(currentPage + 1)
                          : null,
                      borderRadius: SeedBorderRadius.r2,
                      child: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: canGoNext
                              ? colors.fg.neutral
                              : colors.fg.disabled,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
