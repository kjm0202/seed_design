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
      return FixedExtentScrollController(initialItem: col.initialIndex);
    }).toList();
    _selectedIndices = widget.columns.map((col) => col.initialIndex).toList();
  }

  @override
  void didUpdateWidget(SeedWheelPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.columns.length != oldWidget.columns.length) {
      for (final c in _controllers) {
        c.dispose();
      }
      _controllers = widget.columns.map((col) {
        return FixedExtentScrollController(initialItem: col.initialIndex);
      }).toList();
      _selectedIndices = widget.columns.map((col) => col.initialIndex).toList();
    }
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
