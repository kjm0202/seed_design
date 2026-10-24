import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';
import '../layout/seed_scroll_fog.dart';

/// Size options for [SeedWheelPicker].
enum SeedWheelPickerSize {
  small(height: 180.0, itemExtent: 36.0),
  medium(height: 220.0, itemExtent: 44.0);

  const SeedWheelPickerSize({required this.height, required this.itemExtent});
  final double height;
  final double itemExtent;
}

/// Specification for a single column in [SeedWheelPicker].
abstract class SeedWheelColumn {
  const SeedWheelColumn();

  /// Creates a typed column specification for [SeedWheelPicker].
  static SeedWheelColumn typed<T>({
    required List<T> items,
    int initialIndex = 0,
    ValueChanged<int>? onChanged,
    Widget Function(BuildContext context, T item, bool isSelected)? itemBuilder,
    double itemExtent = 44.0,
    int flex = 1,
  }) {
    return _SeedWheelColumnImpl<T>(
      items: items,
      initialIndex: initialIndex,
      onChanged: onChanged,
      itemBuilder: itemBuilder,
      itemExtent: itemExtent,
      flex: flex,
    );
  }

  int get itemCount;
  int get initialIndex;
  ValueChanged<int>? get onChanged;
  double get itemExtent;
  int get flex;

  Widget buildItem(BuildContext context, int index, bool isSelected);
}

class _SeedWheelColumnImpl<T> extends SeedWheelColumn {
  const _SeedWheelColumnImpl({
    required this.items,
    this.initialIndex = 0,
    this.onChanged,
    this.itemBuilder,
    this.itemExtent = 44.0,
    this.flex = 1,
  });

  final List<T> items;
  @override
  final int initialIndex;
  @override
  final ValueChanged<int>? onChanged;
  final Widget Function(BuildContext context, T item, bool isSelected)?
  itemBuilder;
  @override
  final double itemExtent;
  @override
  final int flex;

  @override
  int get itemCount => items.length;

  @override
  Widget buildItem(BuildContext context, int index, bool isSelected) {
    final item = items[index];
    if (itemBuilder != null) {
      return itemBuilder!(context, item, isSelected);
    }
    final colors = context.seedColor;
    final typography = context.seedTypography;
    return Center(
      child: Text(
        item.toString(),
        style: isSelected
            ? typography.t10Medium.copyWith(color: colors.fg.neutral)
            : typography.t10Medium.copyWith(color: colors.fg.disabled),
      ),
    );
  }
}

/// A SEED Design multi-column vertical wheel picker.
///
/// Features:
/// - 44px item extent per SEED spec
/// - Centered selection indicator band with rounded corners
/// - Scroll fog overlays on top and bottom
/// - Haptic feedback on item snapping
class SeedWheelPicker extends StatefulWidget {
  const SeedWheelPicker({
    super.key,
    required this.columns,
    this.size = SeedWheelPickerSize.medium,
    this.height,
    this.showFog = true,
    this.showIndicator = true,
  });

  /// The columns of data to display in the wheel picker.
  final List<SeedWheelColumn> columns;

  /// The size variant of the wheel picker.
  final SeedWheelPickerSize size;

  /// Overall height of the picker. If null, defaults to [size.height].
  final double? height;

  /// Whether to show the top and bottom fade/fog gradients.
  final bool showFog;

  /// Whether to display the centered selection indicator.
  final bool showIndicator;

  double get effectiveHeight => height ?? size.height;

  @override
  State<SeedWheelPicker> createState() => _SeedWheelPickerState();
}

class _SeedWheelPickerState extends State<SeedWheelPicker> {
  late List<FixedExtentScrollController> _controllers;
  late List<int> _selectedIndices;

  @override
  void initState() {
    super.initState();
    _controllers = widget.columns.map((col) {
      return FixedExtentScrollController(initialItem: _validIndex(col));
    }).toList();
    _selectedIndices = widget.columns.map(_validIndex).toList();
  }

  int _validIndex(SeedWheelColumn col) =>
      col.itemCount == 0 ? 0 : col.initialIndex.clamp(0, col.itemCount - 1);

  @override
  void didUpdateWidget(SeedWheelPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldControllers = _controllers;
    final updatedControllers = <FixedExtentScrollController>[];
    final updatedSelections = <int>[];
    for (var i = 0; i < widget.columns.length; i++) {
      final column = widget.columns[i];
      final keepSelection =
          i < oldWidget.columns.length &&
          column.itemCount == oldWidget.columns[i].itemCount &&
          column.itemExtent == oldWidget.columns[i].itemExtent &&
          _validIndex(column) == _validIndex(oldWidget.columns[i]);

      if (keepSelection) {
        // Parent rebuilds must not reset another column's user selection.
        updatedControllers.add(oldControllers[i]);
        updatedSelections.add(_selectedIndices[i]);
      } else {
        updatedControllers.add(
          FixedExtentScrollController(initialItem: _validIndex(column)),
        );
        updatedSelections.add(_validIndex(column));
      }
    }

    // The previous ListWheelScrollView remains attached for this frame.
    for (final controller in oldControllers) {
      if (!updatedControllers.contains(controller)) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => controller.dispose(),
        );
      }
    }
    _controllers = updatedControllers;
    _selectedIndices = updatedSelections;
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final itemHeight = widget.columns.isNotEmpty
        ? widget.columns.first.itemExtent
        : widget.size.itemExtent;
    final pickerHeight = widget.effectiveHeight;
    final fogHeight = (pickerHeight * 0.4).clamp(0.0, 132.0);

    return Container(
      color: colors.bg.layerFloating,
      height: pickerHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Centered selection indicator band
          if (widget.showIndicator)
            Positioned(
              left: SeedDimension.x4,
              right: SeedDimension.x4,
              height: itemHeight,
              child: Container(
                decoration: BoxDecoration(
                  color: colors.bg.neutralWeak,
                  borderRadius: SeedBorderRadius.r2,
                ),
              ),
            ),

          // Columns
          Row(
            children: List.generate(widget.columns.length, (colIdx) {
              final col = widget.columns[colIdx];
              return Expanded(
                flex: col.flex,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is ScrollEndNotification) {
                      HapticFeedback.selectionClick();
                    }
                    return false;
                  },
                  child: ListWheelScrollView.useDelegate(
                    // A new controller means an externally supplied selection
                    // or item count changed. Reset the wheel's Scrollable state
                    // so its old scroll offset cannot override initialItem.
                    key: ObjectKey(_controllers[colIdx]),
                    controller: _controllers[colIdx],
                    itemExtent: col.itemExtent,
                    perspective: 0.003,
                    diameterRatio: 1.8,
                    physics: const FixedExtentScrollPhysics(),
                    onSelectedItemChanged: (index) {
                      setState(() {
                        _selectedIndices[colIdx] = index;
                      });
                      col.onChanged?.call(index);
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: col.itemCount,
                      builder: (context, index) {
                        final isSelected = _selectedIndices[colIdx] == index;
                        return col.buildItem(context, index, isSelected);
                      },
                    ),
                  ),
                ),
              );
            }),
          ),

          // Top scroll fog
          if (widget.showFog)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: fogHeight,
              child: IgnorePointer(
                child: SeedScrollFog(
                  placement: SeedScrollFogPlacement.top,
                  color: colors.bg.layerFloating,
                  size: fogHeight,
                ),
              ),
            ),

          // Bottom scroll fog
          if (widget.showFog)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: fogHeight,
              child: IgnorePointer(
                child: SeedScrollFog(
                  placement: SeedScrollFogPlacement.bottom,
                  color: colors.bg.layerFloating,
                  size: fogHeight,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
