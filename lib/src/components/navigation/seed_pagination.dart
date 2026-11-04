import '../../localization/seed_localizations.dart';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/semantics.dart' show SemanticsRole;

import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';
import 'seed_pagination_controls.dart';

/// Why [SeedPagination] requested or normalized a page change.
enum SeedPageChangeReason {
  /// The user selected an explicit numbered page.
  pageItem,
  /// The user activated the previous-page control.
  previous,
  /// The user activated the next-page control.
  next,
  /// A new page count or input required clamping the current page.
  constraint,
}

/// Describes a [SeedPagination] page transition and its origin.
class SeedPageChange {
  /// Captures the requested [page], [previousPage], and [reason].
  const SeedPageChange({
    required this.page,
    required this.previousPage,
    required this.reason,
  });
  /// [page] is the resulting 1-based page and [previousPage] is the value
  /// before the change; clamping may be reported with [reason] constraint.
  final int page, previousPage;
  /// User action or constraint adjustment responsible for the change.
  final SeedPageChangeReason reason;
}

/// Numbered pagination for sequentially browsing pages of content.
///
/// Unlike `SeedTablePagination`, this shows page links with compact ellipses.
/// Pages are one-based, and page counts of zero or one hide the component.
class SeedPagination extends StatefulWidget {
  /// Creates pagination with a required [totalPages] count.
  ///
  /// [page] is parent-controlled; [defaultPage] defaults to 1 when unmanaged.
  /// Deprecated [currentPage] is an alias for [page] and cannot be supplied
  /// simultaneously. [onPageChanged] reports just the new page, while
  /// [onPageChange] supplies [SeedPageChange] details including the reason.
  /// [visibleItemCount] is 7 or 9 including arrow controls, with responsive
  /// defaults; [maxVisibleSlots] is a Flutter extension counting just numbered
  /// slots. [semanticsLabel] names the navigation landmark, [pageLabelBuilder]
  /// customizes each accessible page name, and [numberFormatter] changes
  /// displayed digits. [disabled] prevents interaction. An optional `key`
  /// preserves Flutter widget identity.
  const SeedPagination({
    super.key,
    int? page,
    @Deprecated('Use page instead.') int? currentPage,
    this.defaultPage = 1,
    required this.totalPages,
    this.onPageChanged,
    this.onPageChange,
    this.visibleItemCount,
    this.maxVisibleSlots,
    String? semanticsLabel,
    this.pageLabelBuilder,
    this.numberFormatter,
    this.disabled = false,
    // Preserve the public named parameter and getter.
    // ignore: prefer_initializing_formals
  }) : _semanticsLabel = semanticsLabel,
       currentPage = page ?? currentPage,
       assert(page == null || currentPage == null),
       assert(
         visibleItemCount == null ||
             visibleItemCount == 7 ||
             visibleItemCount == 9,
       ),
       assert(visibleItemCount == null || maxVisibleSlots == null),
       assert(totalPages >= 0),
       assert(maxVisibleSlots == null || maxVisibleSlots > 0);
  @Deprecated('Use page instead.')
  /// Deprecated controlled page input, replaced by [page].
  final int? currentPage;
  /// React-compatible one-based controlled page, or null when uncontrolled.
  int? get page => currentPage;
  /// [defaultPage] initializes uncontrolled selection (default 1), and
  /// [totalPages] gives the nonnegative page count.
  final int defaultPage, totalPages;
  /// Legacy simple callback with the next one-based page.
  final ValueChanged<int>? onPageChanged;
  /// Detailed page-change callback with previous page and reason.
  final ValueChanged<SeedPageChange>? onPageChange;

  /// Total slots including previous and next: 7 or 9, as in React.
  /// Omitted values follow the official breakpoint (9 from 480px).
  final int? visibleItemCount;

  /// Flutter extension counting page slots only.
  final int? maxVisibleSlots;
  final String? _semanticsLabel;
  /// Accessible navigation name; defaults to "페이지 탐색" for the getter.
  /// Rendered semantics use the localized pagination label when unspecified.
  String get semanticsLabel => _semanticsLabel ?? '페이지 탐색';
  /// Disables page selection and arrow actions when true; defaults to false.
  final bool disabled;
  /// [pageLabelBuilder] supplies each page's accessible label, while
  /// [numberFormatter] changes the digits in page links and default labels.
  final String Function(int)? pageLabelBuilder, numberFormatter;
  @override
  /// Creates state that manages an uncontrolled page and clamps page counts.
  State<SeedPagination> createState() => _SeedPaginationState();
}

class _SeedPaginationState extends State<SeedPagination> {
  static const double _controlSize = 40;
  late int _page = widget.defaultPage;
  int get totalPages => widget.totalPages;
  int get currentPage =>
      (widget.currentPage ?? _page).clamp(1, totalPages < 1 ? 1 : totalPages);
  @override
  void initState() {
    super.initState();
    _constrain();
  }

  @override
  void didUpdateWidget(SeedPagination oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPage != widget.currentPage ||
        oldWidget.totalPages != totalPages) {
      _constrain();
    }
  }

  void _constrain() {
    final previous = widget.currentPage ?? _page;
    final next = currentPage;
    if (next == previous) return;
    if (widget.currentPage == null) _page = next;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onPageChanged?.call(next);
      widget.onPageChange?.call(
        SeedPageChange(
          page: next,
          previousPage: previous,
          reason: SeedPageChangeReason.constraint,
        ),
      );
    });
  }

  void _change(int next, SeedPageChangeReason reason) {
    if (widget.disabled) return;
    final previous = currentPage;
    if (next == previous) return;
    if (widget.currentPage == null) setState(() => _page = next);
    widget.onPageChanged?.call(next);
    widget.onPageChange?.call(
      SeedPageChange(page: next, previousPage: previous, reason: reason),
    );
  }

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

    // The official compact layout prioritizes adjacent pages over fixed
    // endpoints, so selecting an edge page never hides its previous neighbor.
    if (slots == 5) {
      if (currentPage <= 3) return [1, 2, 3, 4, '...'];
      if (currentPage >= totalPages - 2) {
        return ['...', ...List.generate(4, (index) => totalPages - 3 + index)];
      }
      return ['...', currentPage - 1, currentPage, currentPage + 1, '...'];
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
    if (totalPages <= 1) return const SizedBox.shrink();
    final colors = context.seedColor;
    final typography = context.seedTypography;
    return Semantics(
      role: SemanticsRole.navigation,
      label:
          widget._semanticsLabel ??
          SeedLocalizations.label(context, SeedLabel.pagination),
      container: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const navigationWidth = 2 * _controlSize;
          const slotWidth = _controlSize;
          final maxVisibleSlots =
              widget.maxVisibleSlots ??
              (widget.visibleItemCount == null
                  ? (constraints.maxWidth >= 480 ? 7 : 5)
                  : widget.visibleItemCount! - 2);
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
                label: SeedLocalizations.label(context, SeedLabel.previousPage),
                enabled: currentPage > 1,
                onTap: () =>
                    _change(currentPage - 1, SeedPageChangeReason.previous),
              ),
              // Page buttons and ellipses
              ...pageItems.map((item) {
                if (item is int) {
                  final isCurrent = item == currentPage;
                  return SeedPaginationPressable(
                    enabled: !widget.disabled,
                    selected: isCurrent,
                    semanticsLabel:
                        widget.pageLabelBuilder?.call(item) ??
                        SeedLocalizations.label(
                          context,
                          SeedLabel.pageNumber,
                        ).replaceAll(
                          '{page}',
                          '${widget.numberFormatter?.call(item) ?? item}',
                        ),
                    onTap: () => _change(item, SeedPageChangeReason.pageItem),
                    builder: (context, isEngaged) => Container(
                      width: _controlSize,
                      height: _controlSize,
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? (widget.disabled
                                  ? colors.bg.disabled
                                  : isEngaged
                                  ? colors.bg.neutralSolidPressed
                                  : colors.bg.neutralSolid)
                            : isEngaged
                            ? colors.bg.transparentPressed
                            : colors.bg.transparent,
                        borderRadius: SeedBorderRadius.r2,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        widget.numberFormatter?.call(item) ?? '$item',
                        style: typography.t4Bold.copyWith(
                          color: widget.disabled
                              ? colors.fg.disabled
                              : isCurrent
                              ? colors.fg.onNeutralSolid
                              : colors.fg.neutral,
                        ),
                      ),
                    ),
                  );
                } else {
                  return ExcludeSemantics(
                    child: SizedBox(
                      width: _controlSize,
                      height: _controlSize,
                      child: Center(
                        child: Icon(
                          Icons.more_horiz,
                          size: SeedDimension.x4,
                          color: colors.fg.neutral,
                        ),
                      ),
                    ),
                  );
                }
              }),

              // Next button
              _buildNavButton(
                context,
                icon: Icons.chevron_right,
                label: SeedLocalizations.label(context, SeedLabel.nextPage),
                enabled: currentPage < totalPages,
                onTap: () =>
                    _change(currentPage + 1, SeedPageChangeReason.next),
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
      ),
    );
  }

  Widget _buildNavButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Visibility(
      visible: enabled,
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      child: SeedPaginationNavButton(
        icon: icon,
        semanticsLabel: label,
        enabled: enabled && !widget.disabled,
        onTap: onTap,
      ),
    );
  }
}
