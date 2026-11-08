import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';

/// Equal-width grid with intrinsic row heights and explicit row/column spans.
/// Flutter [SeedGridItem.column] / [SeedGridItem.row] indices are zero-based;
/// the React-compatible start/end grid lines are one-based. Omitted indices
/// use the next free cell with CSS sparse auto-placement.
class SeedGrid extends MultiChildRenderObjectWidget {
  /// Creates a sparse, equal-column grid with optional fixed rows and spans.
  const SeedGrid({
    super.key,
    super.children,
    this.columns,
    this.rows,
    this.autoFlow = Axis.horizontal,
    this.gap = 0,
    this.rowGap,
    this.columnGap,
    this.fillHeight = false,
  }) : assert(columns == null || columns > 0),
       assert(rows == null || rows > 0);
  /// [columns] fixes the column count; [rows] can fix the row count. Omitted
  /// columns default to one for row flow, or are inferred from rows in column
  /// flow. Both values, when supplied, must be positive.
  final int? columns, rows;
  /// Auto-placement direction; [Axis.horizontal] means CSS row flow (default).
  final Axis autoFlow;
  int get _columnCount =>
      columns ??
      // Row flow without columns is a single implicit column, as in CSS Grid.
      (rows == null || autoFlow == Axis.horizontal
          ? 1
          : (children.length / rows!).ceil().clamp(1, 1000000));
  /// Default spacing in logical pixels, used on both axes unless overridden.
  final double gap;
  /// Axis-specific spacing overrides for [gap], in logical pixels.
  final double? rowGap, columnGap;
  /// Distributes spare bounded height across rows when true; defaults to false.
  final bool fillHeight;
  @override
  RenderObject createRenderObject(BuildContext context) => RenderSeedGrid(
    _columnCount,
    rowGap ?? gap,
    columnGap ?? gap,
    fillHeight,
    Directionality.of(context),
    rows,
    autoFlow,
  );
  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderSeedGrid renderObject,
  ) {
    renderObject.configure(
      _columnCount,
      rowGap ?? gap,
      columnGap ?? gap,
      fillHeight,
      Directionality.of(context),
      rows,
      autoFlow,
    );
  }
}

/// Assigns CSS-style grid start/end lines or Flutter-style indices and spans.
/// The child must be placed directly under [SeedGrid].
class SeedGridItem extends ParentDataWidget<SeedGridParentData> {
  /// Span value for the whole grid, as React's `colSpan="full"`.
  static const int full = -1;

  /// `colSpan`, `rowSpan`, `colStart`, `colEnd`, `rowStart` and `rowEnd` follow
  /// React and CSS, with one-based grid lines. `column`, `row`, `columnSpan` and
  /// `rowSpan` are the zero-based Flutter equivalents.
  const SeedGridItem({
    super.key,
    required super.child,
    int? column,
    int? row,
    int? columnSpan,
    int? rowSpan,
    int? colSpan,
    int? colStart,
    int? colEnd,
    int? rowStart,
    int? rowEnd,
  }) : column = colSpan == full
           ? 0
           : colStart != null
           ? colStart - 1
           : column,
       row = rowSpan == full
           ? 0
           : rowStart != null
           ? rowStart - 1
           : row,
       columnSpan = colStart != null && colEnd != null
           ? colEnd - colStart
           : colSpan ?? columnSpan ?? 1,
       rowSpan = rowStart != null && rowEnd != null
           ? rowEnd - rowStart
           : rowSpan ?? 1;
  /// Zero-based [column] and [row] placement. Null leaves the axis to
  /// automatic placement; the constructor translates CSS grid lines.
  final int? column, row;
  /// Number of columns and rows occupied; [full] can indicate full span.
  final int columnSpan, rowSpan;
  @override
  void applyParentData(RenderObject renderObject) {
    final data = renderObject.parentData! as SeedGridParentData;
    if (data.column != column ||
        data.row != row ||
        data.columnSpan != columnSpan ||
        data.rowSpan != rowSpan) {
      data.column = column;
      data.row = row;
      data.columnSpan = columnSpan;
      data.rowSpan = rowSpan;
      renderObject.parent?.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => SeedGrid;
}

/// Render-side grid placement information set by [SeedGridItem].
class SeedGridParentData extends ContainerBoxParentData<RenderBox> {
  /// Optional zero-based column and row indices, or null for auto-placement.
  int? column, row;
  /// Column and row spans; each defaults to one.
  int columnSpan = 1, rowSpan = 1;
}

class _SeedPlacement {
  const _SeedPlacement(
    this.child,
    this.row,
    this.column,
    this.rowSpan,
    this.columnSpan,
  );
  final RenderBox child;
  final int row, column, rowSpan, columnSpan;
}

/// Render object implementing [SeedGrid] sparse placement and intrinsic row sizing.
class RenderSeedGrid extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, SeedGridParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, SeedGridParentData> {
  /// Creates a grid renderer configured with resolved columns, gaps, and flow.
  RenderSeedGrid(
    this._columns,
    this._rowGap,
    this._columnGap,
    this._fill,
    this._direction,
    this._rows,
    this._flow,
  );
  int _columns;
  int? _rows;
  Axis _flow;
  double _rowGap, _columnGap;
  bool _fill;
  TextDirection _direction;
  /// Updates layout configuration and marks the grid dirty when it changes.
  void configure(
    int columns,
    double rowGap,
    double columnGap,
    bool fill,
    TextDirection direction,
    int? rows,
    Axis flow,
  ) {
    if (_columns == columns &&
        _rowGap == rowGap &&
        _columnGap == columnGap &&
        _fill == fill &&
        _direction == direction &&
        _rows == rows &&
        _flow == flow) {
      return;
    }
    _rows = rows;
    _flow = flow;
    _columns = columns;
    _rowGap = rowGap;
    _columnGap = columnGap;
    _fill = fill;
    _direction = direction;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! SeedGridParentData) {
      child.parentData = SeedGridParentData();
    }
  }

  // CSS Grid auto-placement: definite items first, then the rest in order with a
  // sparse cursor that never goes back to fill earlier holes.
  List<_SeedPlacement> _placements() {
    final occupied = <(int, int)>{};
    final placed = <_SeedPlacement>[];
    int spanOf(SeedGridParentData data) => data.columnSpan == SeedGridItem.full
        ? _columns
        : data.columnSpan.clamp(1, _columns);
    int rowSpanOf(SeedGridParentData data) =>
        data.rowSpan == SeedGridItem.full ? (_rows ?? 1) : data.rowSpan;
    int columnOf(SeedGridParentData data) =>
        data.column!.clamp(0, _columns - spanOf(data));
    bool free(int row, int column, int rowSpan, int span) {
      for (var y = row; y < row + rowSpan; y++) {
        for (var x = column; x < column + span; x++) {
          if (occupied.contains((y, x))) return false;
        }
      }
      return true;
    }

    void place(RenderBox child, int row, int column) {
      final data = child.parentData! as SeedGridParentData;
      final span = spanOf(data);
      for (var y = row; y < row + rowSpanOf(data); y++) {
        for (var x = column; x < column + span; x++) {
          occupied.add((y, x));
        }
      }
      placed.add(_SeedPlacement(child, row, column, rowSpanOf(data), span));
    }

    final locked = <RenderBox>[], automatic = <RenderBox>[];
    final columnFlow = _flow == Axis.vertical && _rows != null;
    for (var child = firstChild; child != null; child = childAfter(child)) {
      final data = child.parentData! as SeedGridParentData;
      if (data.row != null && data.column != null) {
        place(child, math.max(0, data.row!), columnOf(data));
      } else if (columnFlow ? data.column != null : data.row != null) {
        locked.add(child);
      } else {
        automatic.add(child);
      }
    }

    // Items locked to the flow's major line keep a separate cursor per line.
    final lineCursors = <int, int>{};
    for (final child in locked) {
      final data = child.parentData! as SeedGridParentData;
      final span = spanOf(data);
      if (columnFlow) {
        final column = columnOf(data);
        var row = lineCursors[column] ?? 0;
        while (!free(row, column, rowSpanOf(data), span)) {
          row++;
        }
        place(child, row, column);
        lineCursors[column] = row + rowSpanOf(data);
      } else {
        var row = math.max(0, data.row!);
        var column = lineCursors[row] ?? 0;
        while (column + span > _columns ||
            !free(row, column, rowSpanOf(data), span)) {
          if (column + span >= _columns) {
            row++;
            column = lineCursors[row] ?? 0;
          } else {
            column++;
          }
        }
        place(child, row, column);
        lineCursors[row] = column + span;
      }
    }

    var cursorRow = 0, cursorColumn = 0;
    // Column flow continues in implicit rows once the fixed columns are full.
    var implicitRows = false;
    for (final child in automatic) {
      final data = child.parentData! as SeedGridParentData;
      final span = spanOf(data);
      if (columnFlow && !implicitRows && data.row != null) {
        // CSS column flow with a definite row: the cursor moves to that row,
        // advancing a column if the row is above the cursor.
        final row = math.max(0, data.row!);
        if (row < cursorRow) cursorColumn++;
        while (cursorColumn + span <= _columns &&
            !free(row, cursorColumn, rowSpanOf(data), span)) {
          cursorColumn++;
        }
        if (cursorColumn + span <= _columns) {
          place(child, row, cursorColumn);
          cursorRow = row + rowSpanOf(data);
          continue;
        }
        implicitRows = true;
        cursorRow = _rows!;
        cursorColumn = 0;
      }
      if (columnFlow && !implicitRows) {
        while (!implicitRows) {
          if (cursorRow + rowSpanOf(data) > _rows!) {
            cursorRow = 0;
            cursorColumn++;
          }
          if (cursorColumn + span > _columns) {
            implicitRows = true;
            cursorRow = _rows!;
            cursorColumn = 0;
          } else if (free(cursorRow, cursorColumn, rowSpanOf(data), span)) {
            break;
          } else {
            cursorRow++;
          }
        }
        if (!implicitRows) {
          place(child, cursorRow, cursorColumn);
          cursorRow += rowSpanOf(data);
          continue;
        }
      }
      if (data.column != null) {
        // Row flow with a definite column: the cursor moves to that column,
        // advancing a row if the column is behind the cursor.
        final column = columnOf(data);
        if (column < cursorColumn) cursorRow++;
        cursorColumn = column;
        while (!free(cursorRow, cursorColumn, rowSpanOf(data), span)) {
          cursorRow++;
        }
      } else {
        while (cursorColumn + span > _columns ||
            !free(cursorRow, cursorColumn, rowSpanOf(data), span)) {
          if (cursorColumn + span >= _columns) {
            cursorRow++;
            cursorColumn = 0;
          } else {
            cursorColumn++;
          }
        }
      }
      place(child, cursorRow, cursorColumn);
      cursorColumn += span;
    }
    return placed;
  }

  Size _measure(BoxConstraints constraints, {required bool dry}) {
    final placed = _placements();
    final columnsGap = (_columns - 1) * _columnGap;
    var width = constraints.maxWidth;
    if (!width.isFinite) {
      final intrinsic = placed.fold(
        0.0,
        (previous, item) => math.max(
          previous,
          item.child.getMaxIntrinsicWidth(double.infinity) / item.columnSpan,
        ),
      );
      width = intrinsic * _columns + columnsGap;
    }
    width = constraints.constrainWidth(width);
    final cellWidth = math.max(0.0, (width - columnsGap) / _columns);
    final rows = placed.fold(
      _rows ?? 0,
      (previous, item) => math.max(previous, item.row + item.rowSpan),
    );
    final heights = List<double>.filled(rows, 0);
    double itemWidth(_SeedPlacement item) =>
        cellWidth * item.columnSpan + _columnGap * (item.columnSpan - 1);
    for (final item in placed) {
      final childConstraints = BoxConstraints.tightFor(width: itemWidth(item));
      final Size childSize;
      if (dry) {
        childSize = item.child.getDryLayout(childConstraints);
      } else {
        item.child.layout(childConstraints, parentUsesSize: true);
        childSize = item.child.size;
      }
      final current =
          heights
              .sublist(item.row, item.row + item.rowSpan)
              .fold(0.0, (a, b) => a + b) +
          _rowGap * (item.rowSpan - 1);
      final deficit = math.max(0.0, childSize.height - current) / item.rowSpan;
      for (var row = item.row; row < item.row + item.rowSpan; row++) {
        heights[row] += deficit;
      }
    }
    final contentHeight =
        heights.fold(0.0, (a, b) => a + b) + math.max(0, rows - 1) * _rowGap;
    final height = constraints.constrainHeight(
      _fill && constraints.hasBoundedHeight
          ? constraints.maxHeight
          : contentHeight,
    );
    if (rows > 0 && height > contentHeight) {
      final extra = (height - contentHeight) / rows;
      for (var row = 0; row < rows; row++) {
        heights[row] += extra;
      }
    }
    if (!dry) {
      for (final item in placed) {
        final w = itemWidth(item);
        final h =
            heights
                .sublist(item.row, item.row + item.rowSpan)
                .fold(0.0, (a, b) => a + b) +
            _rowGap * (item.rowSpan - 1);
        item.child.layout(BoxConstraints.tight(Size(w, h)));
        final data = item.child.parentData! as SeedGridParentData;
        final x = item.column * (cellWidth + _columnGap);
        final y =
            heights.take(item.row).fold(0.0, (a, b) => a + b) +
            item.row * _rowGap;
        data.offset = Offset(
          _direction == TextDirection.rtl ? width - x - w : x,
          y,
        );
      }
    }
    return Size(width, height);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) =>
      _measure(constraints, dry: true);
  @override
  void performLayout() {
    size = _measure(constraints, dry: false);
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);
  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}
