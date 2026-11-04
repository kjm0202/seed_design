import '../../localization/seed_localizations.dart';

import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../foundations/dimensions/seed_dimension.dart';
import '../../theme/seed_theme.dart';
import '../input/seed_input_button.dart';
import '../input/seed_select.dart';
import 'seed_pagination_controls.dart';

/// Source of a [SeedTablePagination] value transition.
enum SeedTablePageChangeReason {
  /// User requested the preceding page.
  previous,
  /// User requested the following page.
  next,
  /// User selected a page through the range selector.
  pageRange,
  /// User changed the number of rows displayed per page.
  pageSize,
  /// Current page was clamped after inputs or total count changed.
  constraint,
}

/// Immutable pair of one-based page number and positive page size.
///
/// Matches the React Table Pagination `value: {page, pageSize}` shape.
class SeedTablePaginationValue {
  /// Creates a value with [page] and [pageSize] greater than or equal to one.
  const SeedTablePaginationValue({required this.page, required this.pageSize})
    : assert(page >= 1),
      assert(pageSize >= 1);
  /// One-based current page.
  final int page;
  /// Number of items per page.
  final int pageSize;

  @override
  /// Compares both [page] and [pageSize] for value equality.
  bool operator ==(Object other) =>
      other is SeedTablePaginationValue &&
      other.page == page &&
      other.pageSize == pageSize;

  @override
  /// Hash of the [page] and [pageSize] pair.
  int get hashCode => Object.hash(page, pageSize);
}

/// Previous and next values, with the reason for a table page change.
class SeedTablePaginationChange {
  /// Creates a change record containing [value], [previousValue], and [reason].
  const SeedTablePaginationChange({
    required this.value,
    required this.previousValue,
    required this.reason,
  });
  /// Requested page and page size after the change.
  final SeedTablePaginationValue value;
  /// Page and page size before the change.
  final SeedTablePaginationValue previousValue;
  /// Describes whether navigation, page size, or a constraint caused it.
  final SeedTablePageChangeReason reason;
}

/// A SEED Design Table Pagination component.
///
/// Designed for data tables:
/// - Rows per page dropdown selector (`{n}개 씩 보기`)
/// - Page range label (`1-10 / 총 320개` or unknown total mode)
/// - Previous and Next navigation buttons
/// - A single non-wrapping 40px row with horizontal overflow at narrow widths.
///   This matches the React root's `height=40px; minWidth=max-content;
///   wrap=nowrap`; its children are not allowed to move to a second line.
class SeedTablePagination extends StatefulWidget {
  /// Upper limit on automatically offered page-range options (200).
  ///
  /// Large tables show the first, last, and a window around the current page.
  static const int maxAutoPageOptions = 200;

  /// Creates a table footer for [totalItems] or an unknown total.
  ///
  /// [value] and [defaultValue] use the React `{page, pageSize}` model;
  /// [onValueChange] receives the next value and its change details. Legacy
  /// [currentPage], [rowsPerPage], [defaultPage], [defaultRowsPerPage],
  /// [onPageChanged], [onRowsPerPageChanged], and [onValueChanged] support
  /// Flutter callers with separate page fields. [value] cannot be combined
  /// with [currentPage] or [rowsPerPage]. Page numbers start at one.
  /// [rowsPerPageOptions] defaults to 10, 25, 50; [pageOptions] optionally
  /// overrides page-range choices. For an unknown [totalItems], use
  /// [hasPreviousPage], [hasNextPage], and [currentPageItemCount] to describe
  /// available data. [showRangeSelect] controls the range menu when total is
  /// known, [disabled] gates interaction, and [semanticsLabel] names the footer.
  /// An optional `key` preserves Flutter widget identity.
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
    String? semanticsLabel,
    // Preserve the public named parameter and getter.
    // ignore: prefer_initializing_formals
  }) : _semanticsLabel = semanticsLabel,
       assert(value == null || (currentPage == null && rowsPerPage == null)),
       assert(currentPage == null || currentPage >= 1),
       assert(defaultPage >= 1),
       assert(totalItems == null || totalItems >= 0),
       assert(rowsPerPage == null || rowsPerPage >= 1),
       assert(defaultRowsPerPage >= 1),
       assert(currentPageItemCount == null || currentPageItemCount >= 0);

  /// Flutter-style one-based current page, used when [value] is absent.
  ///
  /// When null, page state starts from [defaultValue] or [defaultPage].
  /// [currentPage] and [value] cannot be supplied together.
  final int? currentPage;
  /// React-style page and page-size pair.
  ///
  /// [value] controls both values when non-null. [defaultValue] initializes
  /// internally managed page and size, before the scalar defaults.
  /// Both hold a one-based page and a positive page size.
  final SeedTablePaginationValue? value, defaultValue;
  /// React-style change callback receiving the next [SeedTablePaginationValue]
  /// and [SeedTablePaginationChange] with its previous value and reason.
  final void Function(
    SeedTablePaginationValue value,
    SeedTablePaginationChange details,
  )?
  onValueChange;

  /// Fallback initial one-based page when [defaultValue] is absent.
  final int defaultPage;

  /// Total count of items across all pages. If null, operates in unknown total mode.
  final int? totalItems;

  /// Flutter-style controlled page size when [value] is absent.
  ///
  /// When null, page size starts from [defaultValue] or [defaultRowsPerPage].
  /// [rowsPerPage] and [value] cannot be supplied together.
  final int? rowsPerPage;

  /// Fallback initial rows per page when [defaultValue] is absent.
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

  /// Shows the page-range selector for a known total; defaults to true.
  final bool showRangeSelect;
  /// Disables selectors and navigation buttons; defaults to false.
  final bool disabled;
  final String? _semanticsLabel;
  /// Accessible footer name; defaults to "표 페이지 탐색" on the getter.
  /// Rendered semantics localize this label when the argument is absent.
  String get semanticsLabel => _semanticsLabel ?? '표 페이지 탐색';

  @override
  /// Creates state to manage pages, page sizes, and constraint changes.
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
    if (widget.totalItems == null || total == null) return const <int>[];
    final page = _effectivePage;
    // React keeps the current page as the single 0-0 option when empty.
    if (total <= 0) return <int>[page];
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

    final totalText = SeedLocalizations.label(
      context,
      SeedLabel.paginationTotal,
    ).replaceAll('{total}', '$total');
    final rangeText = total != null
        ? '$startItem-$endItem $totalText'
        : '$startItem-$endItem';

    final pageOptions = _resolvedPageOptions;
    String rangeLabel(int page) => total == 0
        ? '0-0'
        : '${(page - 1) * rows + 1}-${(page * rows).clamp(0, total!)}';
    final rowsLabel = Localizations.maybeLocaleOf(context)?.languageCode == 'ko'
        ? '$rows개'
        : '$rows';
    // React's triggers are `min-width: 96px; width: max-content`.
    double selectWidth(Iterable<String> labels) {
      final painter = TextPainter(
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
        maxLines: 1,
      );
      var widest = 0.0;
      for (final label in labels) {
        painter.text = TextSpan(text: label, style: typography.t4Regular);
        painter.layout();
        widest = math.max(widest, painter.width);
      }
      painter.dispose();
      // Padding, the gap and the chevron of a medium InputButton.
      return math.max(96.0, (widest + 14 * 2 + 8 + 16).ceilToDouble());
    }

    final prevEnabled = !widget.disabled && canGoPrev;
    final nextEnabled = !widget.disabled && canGoNext;

    return Semantics(
      container: true,
      enabled: !widget.disabled,
      label:
          widget._semanticsLabel ??
          SeedLocalizations.label(context, SeedLabel.tablePagination),
      child: LayoutBuilder(
        builder: (context, constraints) => SizedBox(
          width: constraints.hasBoundedWidth ? constraints.maxWidth : null,
          height: 40,
          // A normal Row forced into the narrow viewport would overflow and
          // lose the next/previous controls. React's enclosing demo uses
          // overflowX:auto while TablePagination itself keeps max-content
          // width, so expose the same horizontal scroll contract to standalone
          // Flutter consumers instead of wrapping controls onto new lines.
          child: SingleChildScrollView(
            key: const ValueKey('seed-table-pagination-horizontal-scroll'),
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: constraints.hasBoundedWidth
                    ? constraints.maxWidth
                    : 0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left: Rows per page selector
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _TablePaginationFocusReveal(
                        alignment: 0,
                        child: SizedBox(
                          width: selectWidth([rowsLabel]),
                          child: Semantics(
                            label: SeedLocalizations.label(
                              context,
                              SeedLabel.rowsPerPage,
                            ),
                            child: SeedSelect<int>(
                              size: SeedInputButtonSize.medium,
                              enabled: !widget.disabled,
                              value: [rows],
                              groups: [
                                SeedSelectGroup<int>(
                                  items: _resolvedRowsPerPageOptions.map((opt) {
                                    return SeedSelectItem<int>(
                                      value: opt,
                                      label:
                                          Localizations.maybeLocaleOf(context)
                                                  ?.languageCode ==
                                              'ko'
                                          ? '$opt개'
                                          : '$opt',
                                    );
                                  }).toList(),
                                ),
                              ],
                              onChanged: _changeRowsPerPage,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: SeedDimension.x2),
                      Text(
                        SeedLocalizations.label(
                          context,
                          SeedLabel.rowsPerPageSuffix,
                        ),
                        style: typography.t4Regular.copyWith(
                          color: widget.disabled
                              ? colors.fg.disabled
                              : colors.fg.neutral,
                        ),
                      ),
                    ],
                  ),

                  // Right: Range display & Next/Prev buttons
                  Padding(
                    padding: const EdgeInsets.only(left: SeedDimension.x4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (total != null && widget.showRangeSelect)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _TablePaginationFocusReveal(
                                alignment: 1,
                                child: SizedBox(
                                  width: selectWidth([rangeLabel(page)]),
                                  child: Semantics(
                                    label: SeedLocalizations.label(
                                      context,
                                      SeedLabel.range,
                                    ),
                                    child: SeedSelect<int>(
                                      size: SeedInputButtonSize.medium,
                                      maxMenuHeight: 240,
                                      enabled:
                                          !widget.disabled &&
                                          pageOptions.length > 1,
                                      value: [page],
                                      groups: [
                                        SeedSelectGroup(
                                          items: [
                                            for (final p in pageOptions)
                                              SeedSelectItem(
                                                value: p,
                                                label: rangeLabel(p),
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
                                ),
                              ),
                              const SizedBox(width: SeedDimension.x2),
                              Text(
                                totalText,
                                style: typography.t4Regular.copyWith(
                                  color: widget.disabled
                                      ? colors.fg.disabled
                                      : colors.fg.neutral,
                                ),
                              ),
                            ],
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
                        const SizedBox(width: SeedDimension.x4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _TablePaginationFocusReveal(
                              alignment: 1,
                              child: SeedPaginationNavButton(
                                icon: Icons.chevron_left,
                                semanticsLabel: SeedLocalizations.label(
                                  context,
                                  SeedLabel.previousPage,
                                ),
                                enabled: prevEnabled,
                                onTap: () => _changePage(
                                  page - 1,
                                  SeedTablePageChangeReason.previous,
                                ),
                              ),
                            ),
                            _TablePaginationFocusReveal(
                              alignment: 1,
                              child: SeedPaginationNavButton(
                                icon: Icons.chevron_right,
                                semanticsLabel: SeedLocalizations.label(
                                  context,
                                  SeedLabel.nextPage,
                                ),
                                enabled: nextEnabled,
                                onTap: () => _changePage(
                                  page + 1,
                                  SeedTablePageChangeReason.next,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// When keyboard traversal focuses a control beyond the horizontal clip,
/// reveal that control just as a browser scrolls focused elements into view.
/// Keeping the focus wrapper separate from the selectable/pressable child
/// preserves its real focus node, semantics and activation shortcuts.
class _TablePaginationFocusReveal extends StatefulWidget {
  const _TablePaginationFocusReveal({
    required this.child,
    required this.alignment,
  });

  final Widget child;
  final double alignment;

  @override
  State<_TablePaginationFocusReveal> createState() =>
      _TablePaginationFocusRevealState();
}

class _TablePaginationFocusRevealState
    extends State<_TablePaginationFocusReveal> {
  void _onFocusChange(bool hasFocus) {
    if (!hasFocus) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Scrollable.ensureVisible(
        context,
        alignment: widget.alignment,
        alignmentPolicy: widget.alignment == 0
            ? ScrollPositionAlignmentPolicy.keepVisibleAtStart
            : ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
        // Keyboard focus is an accessibility state change, not a carousel
        // transition. Reveal immediately rather than animating a hidden
        // control while the next key may already be arriving.
        duration: Duration.zero,
      );
    });
  }

  @override
  Widget build(BuildContext context) => Focus(
    canRequestFocus: false,
    skipTraversal: true,
    includeSemantics: false,
    onFocusChange: _onFocusChange,
    child: widget.child,
  );
}
