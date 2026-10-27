import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';
import '../input/seed_input_button.dart';
import '../input/seed_select.dart';

enum SeedTablePageChangeReason {
  previous,
  next,
  pageRange,
  pageSize,
  constraint,
}

class SeedTablePaginationValue {
  const SeedTablePaginationValue({required this.page, required this.pageSize})
    : assert(page >= 1),
      assert(pageSize >= 1);
  final int page;
  final int pageSize;

  @override
  bool operator ==(Object other) =>
      other is SeedTablePaginationValue &&
      other.page == page &&
      other.pageSize == pageSize;

  @override
  int get hashCode => Object.hash(page, pageSize);
}

class SeedTablePaginationChange {
  const SeedTablePaginationChange({
    required this.value,
    required this.previousValue,
    required this.reason,
  });
  final SeedTablePaginationValue value;
  final SeedTablePaginationValue previousValue;
  final SeedTablePageChangeReason reason;
}

/// A SEED Design Table Pagination component.
///
/// Designed for data tables:
/// - Rows per page dropdown selector (`{n}개 씩 보기`)
/// - Page range label (`1–10 / 총 320개` or unknown total mode)
/// - Previous and Next navigation buttons
/// - Responsive layout wrapping cleanly at narrow widths
class SeedTablePagination extends StatefulWidget {
  static const int maxAutoPageOptions = 200;

  const SeedTablePagination({
    super.key,
    this.value,
    this.defaultValue,
    this.onValueChange,
    this.currentPage,
    this.defaultPage = 1,
    this.totalItems,
    this.rowsPerPage,
    this.defaultRowsPerPage = 10,
    this.rowsPerPageOptions = const [10, 25, 50],
    this.pageOptions,
    this.onPageChanged,
    this.onRowsPerPageChanged,
    this.onValueChanged,
    this.hasPreviousPage,
    this.hasNextPage,
    this.currentPageItemCount,
    this.showRangeSelect = true,
    this.disabled = false,
    this.semanticsLabel = '표 페이지 탐색',
  }) : assert(value == null || (currentPage == null && rowsPerPage == null)),
       assert(currentPage == null || currentPage >= 1),
       assert(defaultPage >= 1),
       assert(totalItems == null || totalItems >= 0),
       assert(rowsPerPage == null || rowsPerPage >= 1),
       assert(defaultRowsPerPage >= 1),
       assert(currentPageItemCount == null || currentPageItemCount >= 0);

  /// 1-indexed current page. If null, operates in uncontrolled mode starting at [defaultPage].
  final int? currentPage;
  final SeedTablePaginationValue? value, defaultValue;
  final void Function(
    SeedTablePaginationValue value,
    SeedTablePaginationChange details,
  )?
  onValueChange;

  /// Initial 1-indexed page when [currentPage] is null.
  final int defaultPage;

  /// Total count of items across all pages. If null, operates in unknown total mode.
  final int? totalItems;

  /// Number of rows displayed per page. If null, uses [defaultRowsPerPage].
  final int? rowsPerPage;

  /// Initial rows per page when [rowsPerPage] is null.
  final int defaultRowsPerPage;

  /// Selectable options for rows per page.
  final List<int> rowsPerPageOptions;

  /// Optional explicit list of pages to show in the page range dropdown.
  final List<int>? pageOptions;

  /// Callback when page changes.
  final ValueChanged<int>? onPageChanged;

  /// Callback when rows per page changes.
  final ValueChanged<int>? onRowsPerPageChanged;

  /// Callback with detailed change reason and previous value.
  final ValueChanged<SeedTablePaginationChange>? onValueChanged;

  /// Explicit flag whether previous page exists in unknown total mode.
  final bool? hasPreviousPage;

  /// Explicit flag whether next page exists in unknown total mode.
  final bool? hasNextPage;

  /// Actual number of items on the current page in unknown total mode.
  final int? currentPageItemCount;

  final bool showRangeSelect;
  final bool disabled;
  final String semanticsLabel;

  @override
  State<SeedTablePagination> createState() => _SeedTablePaginationState();
}

class _SeedTablePaginationState extends State<SeedTablePagination> {
  late int _page = widget.defaultValue?.page ?? widget.defaultPage;
  late int _rowsPerPage =
      widget.defaultValue?.pageSize ?? widget.defaultRowsPerPage;
  String? _lastConstraintKey;

  int get _effectiveRowsPerPage =>
      widget.value?.pageSize ?? widget.rowsPerPage ?? _rowsPerPage;

  int? get _totalPages => widget.totalItems == null
      ? null
      : (widget.totalItems! / _effectiveRowsPerPage).ceil();

  int get _rawPage => widget.value?.page ?? widget.currentPage ?? _page;

  int get _effectivePage {
    final total = _totalPages;
    if (total == null) return math.max(1, _rawPage);
    if (total <= 0) return 1;
    return _rawPage.clamp(1, total);
  }

  void _validateOptions(List<int> options, String name) {
    final seen = <int>{};
    for (final opt in options) {
      assert(
        opt >= 1,
        'SeedTablePagination: $name must contain positive integers.',
      );
      assert(
        seen.add(opt),
        'SeedTablePagination: $name cannot contain duplicates.',
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _validateOptions(widget.rowsPerPageOptions, 'rowsPerPageOptions');
    if (widget.pageOptions != null) {
      _validateOptions(widget.pageOptions!, 'pageOptions');
    }
    _constrain();
  }

  @override
  void didUpdateWidget(SeedTablePagination oldWidget) {
    super.didUpdateWidget(oldWidget);
    _validateOptions(widget.rowsPerPageOptions, 'rowsPerPageOptions');
    if (widget.pageOptions != null) {
      _validateOptions(widget.pageOptions!, 'pageOptions');
    }
    if (oldWidget.value != widget.value ||
        oldWidget.currentPage != widget.currentPage ||
        oldWidget.totalItems != widget.totalItems ||
        oldWidget.rowsPerPage != widget.rowsPerPage) {
      _constrain();
    }
  }

  void _notifyValue(SeedTablePaginationChange change) {
    widget.onValueChange?.call(change.value, change);
    widget.onValueChanged?.call(change);
  }

  void _constrain() {
    final raw = _rawPage;
    final clamped = _effectivePage;
    if (raw == clamped) {
      _lastConstraintKey = null;
      return;
    }
    final key = '$raw:$_effectiveRowsPerPage:$clamped';
    if (_lastConstraintKey == key) return;
    _lastConstraintKey = key;
    if ((widget.value == null && widget.currentPage == null)) _page = clamped;
    final rows = _effectiveRowsPerPage;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onPageChanged?.call(clamped);
      _notifyValue(
        SeedTablePaginationChange(
          value: SeedTablePaginationValue(page: clamped, pageSize: rows),
          previousValue: SeedTablePaginationValue(page: raw, pageSize: rows),
          reason: SeedTablePageChangeReason.constraint,
        ),
      );
    });
  }

  List<int> get _resolvedRowsPerPageOptions {
    final set = <int>{...widget.rowsPerPageOptions, _effectiveRowsPerPage};
    return set.toList()..sort();
  }

  List<int> _buildAutoPageOptions(int page, int totalPages) {
    if (totalPages <= SeedTablePagination.maxAutoPageOptions) {
      return List<int>.generate(totalPages, (i) => i + 1);
    }
    const windowSize = SeedTablePagination.maxAutoPageOptions - 2;
    final centeredStart = page - ((windowSize - 1) ~/ 2);
    final windowStart = centeredStart.clamp(2, totalPages - windowSize);
    return <int>[
      1,
      ...List<int>.generate(windowSize, (i) => windowStart + i),
      totalPages,
    ];
  }

  List<int> get _resolvedPageOptions {
    final total = _totalPages;
    if (widget.totalItems == null || total == null || total <= 0) {
      return const <int>[];
    }
    final page = _effectivePage;
    final candidates = widget.pageOptions ?? _buildAutoPageOptions(page, total);
    final pages = <int>{
      ...candidates.where((opt) => opt >= 1 && opt <= total),
      page,
    };
    return pages.toList()..sort();
  }

  void _changePage(int nextPage, SeedTablePageChangeReason reason) {
    if (widget.disabled) return;
    final total = _totalPages;
    final clamped = total == null
        ? math.max(1, nextPage)
        : (total <= 0 ? 1 : nextPage.clamp(1, total));
    final current = _effectivePage;
    if (clamped == current) return;
    final rows = _effectiveRowsPerPage;
    if ((widget.value == null && widget.currentPage == null)) {
      setState(() => _page = clamped);
    }
    widget.onPageChanged?.call(clamped);
    _notifyValue(
      SeedTablePaginationChange(
        value: SeedTablePaginationValue(page: clamped, pageSize: rows),
        previousValue: SeedTablePaginationValue(page: current, pageSize: rows),
        reason: reason,
      ),
    );
  }

  void _changeRowsPerPage(int nextRowsPerPage) {
    if (widget.disabled) return;
    final currentRows = _effectiveRowsPerPage;
    if (nextRowsPerPage == currentRows) return;
    final current = _effectivePage;
    if ((widget.value == null && widget.rowsPerPage == null) ||
        (widget.value == null && widget.currentPage == null)) {
      setState(() {
        if (widget.value == null && widget.rowsPerPage == null) {
          _rowsPerPage = nextRowsPerPage;
        }
        if (widget.value == null && widget.currentPage == null) _page = 1;
      });
    }
    if (current != 1) {
      widget.onPageChanged?.call(1);
    }
    widget.onRowsPerPageChanged?.call(nextRowsPerPage);
    _notifyValue(
      SeedTablePaginationChange(
        value: SeedTablePaginationValue(page: 1, pageSize: nextRowsPerPage),
        previousValue: SeedTablePaginationValue(
          page: current,
          pageSize: currentRows,
        ),
        reason: SeedTablePageChangeReason.pageSize,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;
    final page = _effectivePage;
    final rows = _effectiveRowsPerPage;
    final total = widget.totalItems;
    final totalPages = _totalPages;

    final int startItem;
    final int endItem;
    final bool canGoPrev;
    final bool canGoNext;

    if (total != null && totalPages != null) {
      if (total == 0) {
        startItem = 0;
        endItem = 0;
      } else {
        final offset = (page - 1) * rows;
        final count = math.min(rows, math.max(0, total - offset));
        startItem = count == 0 ? 0 : offset + 1;
        endItem = count == 0 ? 0 : offset + count;
      }
      canGoPrev = total > 0 && page > 1;
      canGoNext = total > 0 && page < totalPages;
    } else {
      final itemCount = (widget.currentPageItemCount ?? rows).clamp(0, rows);
      if (itemCount == 0) {
        startItem = 0;
        endItem = 0;
      } else {
        final offset = (page - 1) * rows;
        startItem = offset + 1;
        endItem = offset + itemCount;
      }
      canGoPrev = page > 1 && (widget.hasPreviousPage ?? true);
      canGoNext =
          widget.hasNextPage ??
          (widget.currentPageItemCount == null
              ? page < 999999
              : widget.currentPageItemCount! >= rows);
    }

    final rangeText = total != null
        ? '$startItem–$endItem / 총 $total개'
        : '$startItem–$endItem';

    final pageOptions = _resolvedPageOptions;
    final prevEnabled = !widget.disabled && canGoPrev;
    final nextEnabled = !widget.disabled && canGoNext;

    return Semantics(
      container: true,
      enabled: !widget.disabled,
      label: widget.semanticsLabel,
      child: LayoutBuilder(
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
                    child: Semantics(
                      label: '페이지당 표시 개수',
                      child: SeedSelect<int>(
                        size: SeedInputButtonSize.small,
                        enabled: !widget.disabled,
                        value: [rows],
                        groups: [
                          SeedSelectGroup<int>(
                            items: _resolvedRowsPerPageOptions.map((opt) {
                              return SeedSelectItem<int>(
                                value: opt,
                                label: '$opt개',
                              );
                            }).toList(),
                          ),
                        ],
                        onChanged: _changeRowsPerPage,
                      ),
                    ),
                  ),
                  Text(
                    '씩 보기',
                    style: typography.t4Regular.copyWith(
                      color: widget.disabled
                          ? colors.fg.disabled
                          : colors.fg.neutral,
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
                  if (total != null && widget.showRangeSelect && total > 0)
                    SizedBox(
                      width: 196,
                      child: Semantics(
                        label: '표시 범위',
                        child: SeedSelect<int>(
                          size: SeedInputButtonSize.small,
                          enabled: !widget.disabled && pageOptions.length > 1,
                          value: [page],
                          groups: [
                            SeedSelectGroup(
                              items: [
                                for (final p in pageOptions)
                                  SeedSelectItem(
                                    value: p,
                                    label:
                                        '${(p - 1) * rows + 1}–${(p * rows).clamp(0, total)} / 총 $total개',
                                  ),
                              ],
                            ),
                          ],
                          onChanged: (p) => _changePage(
                            p,
                            SeedTablePageChangeReason.pageRange,
                          ),
                        ),
                      ),
                    )
                  else
                    Text(
                      rangeText,
                      style: typography.t4Regular.copyWith(
                        color: widget.disabled
                            ? colors.fg.disabled
                            : colors.fg.neutral,
                      ),
                    ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Semantics(
                        button: true,
                        enabled: prevEnabled,
                        label: '이전 페이지',
                        excludeSemantics: true,
                        onTap: prevEnabled
                            ? () => _changePage(
                                page - 1,
                                SeedTablePageChangeReason.previous,
                              )
                            : null,
                        child: InkWell(
                          onTap: prevEnabled
                              ? () => _changePage(
                                  page - 1,
                                  SeedTablePageChangeReason.previous,
                                )
                              : null,
                          borderRadius: SeedBorderRadius.r2,
                          child: Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.chevron_left,
                              size: 16,
                              color: prevEnabled
                                  ? colors.fg.neutral
                                  : colors.fg.disabled,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: SeedDimension.x1),
                      Semantics(
                        button: true,
                        enabled: nextEnabled,
                        label: '다음 페이지',
                        excludeSemantics: true,
                        onTap: nextEnabled
                            ? () => _changePage(
                                page + 1,
                                SeedTablePageChangeReason.next,
                              )
                            : null,
                        child: InkWell(
                          onTap: nextEnabled
                              ? () => _changePage(
                                  page + 1,
                                  SeedTablePageChangeReason.next,
                                )
                              : null,
                          borderRadius: SeedBorderRadius.r2,
                          child: Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.chevron_right,
                              size: 16,
                              color: nextEnabled
                                  ? colors.fg.neutral
                                  : colors.fg.disabled,
                            ),
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
      ),
    );
  }
}
