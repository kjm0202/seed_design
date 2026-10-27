import 'package:material_ui/material_ui.dart';
import 'package:flutter/semantics.dart' show SemanticsRole;

import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';

enum SeedPageChangeReason { pageItem, previous, next, constraint }

class SeedPageChange {
  const SeedPageChange({
    required this.page,
    required this.previousPage,
    required this.reason,
  });
  final int page, previousPage;
  final SeedPageChangeReason reason;
}

class SeedPagination extends StatefulWidget {
  const SeedPagination({
    super.key,
    this.currentPage,
    this.defaultPage = 1,
    required this.totalPages,
    this.onPageChanged,
    this.onPageChange,
    this.maxVisibleSlots,
    this.semanticsLabel = '페이지 탐색',
    this.pageLabelBuilder,
    this.numberFormatter,
    this.disabled = false,
  }) : assert(totalPages >= 0),
       assert(maxVisibleSlots == null || maxVisibleSlots > 0);
  final int? currentPage;
  final int defaultPage, totalPages;
  final ValueChanged<int>? onPageChanged;
  final ValueChanged<SeedPageChange>? onPageChange;
  final int? maxVisibleSlots;
  final String semanticsLabel;
  final bool disabled;
  final String Function(int)? pageLabelBuilder, numberFormatter;
  @override
  State<SeedPagination> createState() => _SeedPaginationState();
}

class _SeedPaginationState extends State<SeedPagination> {
  static const double _controlSize = 40, _numberPadding = 2;
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
      label: widget.semanticsLabel,
      container: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Count conservatively for ellipses, whose slots have no padding.
          const navigationWidth = 2 * (_controlSize + SeedDimension.x1);
          const slotWidth = _controlSize + 2 * _numberPadding;
          final maxVisibleSlots =
              widget.maxVisibleSlots ?? (constraints.maxWidth >= 480 ? 7 : 5);
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
                label: '이전 페이지',
                enabled: currentPage > 1,
                onTap: () =>
                    _change(currentPage - 1, SeedPageChangeReason.previous),
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
                    child: Semantics(
                      button: true,
                      enabled: !widget.disabled,
                      selected: isCurrent,
                      label:
                          widget.pageLabelBuilder?.call(item) ??
                          '${widget.numberFormatter?.call(item) ?? item}페이지',
                      excludeSemantics: true,
                      onTap: widget.disabled
                          ? null
                          : () => _change(item, SeedPageChangeReason.pageItem),
                      child: InkWell(
                        onTap: widget.disabled
                            ? null
                            : () =>
                                  _change(item, SeedPageChangeReason.pageItem),
                        overlayColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.pressed) ||
                              states.contains(WidgetState.hovered)) {
                            return isCurrent
                                ? colors.bg.neutralSolidPressed
                                : colors.bg.transparentPressed;
                          }
                          return null;
                        }),
                        borderRadius: SeedBorderRadius.r2,
                        child: Container(
                          width: _controlSize,
                          height: _controlSize,
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? (widget.disabled
                                      ? colors.bg.disabled
                                      : colors.bg.neutralSolid)
                                : Colors.transparent,
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
                      ),
                    ),
                  );
                } else {
                  return ExcludeSemantics(
                    child: SizedBox(
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
                    ),
                  );
                }
              }),

              const SizedBox(width: SeedDimension.x1),
              // Next button
              _buildNavButton(
                context,
                icon: Icons.chevron_right,
                label: '다음 페이지',
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
    final colors = context.seedColor;
    return Visibility(
      visible: enabled,
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      child: Semantics(
        button: true,
        enabled: !widget.disabled,
        label: label,
        excludeSemantics: true,
        onTap: widget.disabled ? null : onTap,
        child: InkWell(
          onTap: enabled && !widget.disabled ? onTap : null,
          borderRadius: SeedBorderRadius.r2,
          child: Container(
            width: _controlSize,
            height: _controlSize,
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 16,
              color: !widget.disabled ? colors.fg.neutral : colors.fg.disabled,
            ),
          ),
        ),
      ),
    );
  }
}
