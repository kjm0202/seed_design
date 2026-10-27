import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';

/// Equal-width grid with intrinsic row heights and explicit row/column spans.
/// Grid line indices are zero-based; omitted indices use the next free cell.
class SeedGrid extends MultiChildRenderObjectWidget {
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
  final int? columns, rows;
  final Axis autoFlow;
  int get _columnCount =>
      columns ??
      (rows == null ? 1 : (children.length / rows!).ceil().clamp(1, 1000000));
  final double gap;
  final double? rowGap, columnGap;
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

class SeedGridItem extends ParentDataWidget<SeedGridParentData> {
  const SeedGridItem({
    super.key,
    required super.child,
    this.column,
    this.row,
    this.columnSpan = 1,
    this.rowSpan = 1,
  }) : assert(columnSpan > 0 && rowSpan > 0);
  final int? column, row;
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

class SeedGridParentData extends ContainerBoxParentData<RenderBox> {
  int? column, row;
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

class RenderSeedGrid extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, SeedGridParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, SeedGridParentData> {
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

  List<_SeedPlacement> _placements() {
    final occupied = <(int, int)>{};
    final placed = <_SeedPlacement>[];
    for (var child = firstChild; child != null; child = childAfter(child)) {
      final data = child.parentData! as SeedGridParentData;
      final span = data.columnSpan.clamp(1, _columns);
      var row = math.max(0, data.row ?? 0),
          column = (data.column ?? 0).clamp(0, _columns - span);
      bool available() {
        for (var y = row; y < row + data.rowSpan; y++) {
          for (var x = column; x < column + span; x++) {
            if (occupied.contains((y, x))) return false;
          }
        }
        return true;
      }

      if (data.row == null || data.column == null) {
        while (!available()) {
          if (_flow == Axis.vertical &&
              _rows != null &&
              data.row == null &&
              data.column == null &&
              row + data.rowSpan < _rows!) {
            row++;
          } else if (_flow == Axis.vertical &&
              _rows != null &&
              data.row == null &&
              data.column == null &&
              column + span < _columns) {
            column++;
            row = 0;
          } else if (data.column != null || column + span >= _columns) {
            row++;
            column = (data.column ?? 0).clamp(0, _columns - span);
          } else {
            column++;
          }
        }
      }
      for (var y = row; y < row + data.rowSpan; y++) {
        for (var x = column; x < column + span; x++) {
          occupied.add((y, x));
        }
      }
      placed.add(_SeedPlacement(child, row, column, data.rowSpan, span));
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
