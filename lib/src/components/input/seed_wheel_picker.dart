import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../foundations/motion/seed_motion.dart';
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

/// React WheelPicker value-change details, independent of option type.
class SeedWheelPickerValueChangeDetails {
  const SeedWheelPickerValueChangeDetails({required this.stepDelta});
  final int stepDelta;
}

/// Specification for a single column in [SeedWheelPicker].
abstract class SeedWheelColumn {
  const SeedWheelColumn();

  /// Creates a typed column specification for [SeedWheelPicker].
  static SeedWheelColumn typed<T>({
    required List<T> items,
    int initialIndex = 0,
    int? index,
    ValueChanged<int>? onChanged,
    void Function(int index, int stepDelta)? onStepChanged,
    Widget Function(BuildContext context, T item, bool isSelected)? itemBuilder,
    double? itemExtent,
    double? width,
    AlignmentGeometry alignment = Alignment.center,
    int flex = 1,
    bool? loop,
    @Deprecated('Use loop instead.') bool? looping,
    bool enabled = true,
    bool readOnly = false,
    String? semanticsLabel,
    String Function(T)? semanticsValueFormatter,
    ValueChanged<int>? onIndexChanged,
  }) {
    assert(loop == null || looping == null);
    return _SeedWheelColumnImpl<T>(
      items: items,
      initialIndex: initialIndex,
      index: index,
      onChanged: onChanged,
      onStepChanged: onStepChanged,
      itemBuilder: itemBuilder,
      rowExtent: itemExtent,
      width: width,
      alignment: alignment,
      flex: flex,
      looping: loop ?? looping ?? false,
      enabled: enabled,
      readOnly: readOnly,
      semanticsLabel: semanticsLabel,
      semanticsValueFormatter: semanticsValueFormatter,
      onIndexChanged: onIndexChanged,
    );
  }

  static SeedWheelColumn value<T>({
    required List<T> items,
    T? value,
    T? defaultValue,
    void Function(T value, SeedWheelPickerValueChangeDetails details)?
    onValueChange,
    void Function(int index, T value)? onIndexChange,
    @Deprecated('Use onValueChange instead.') ValueChanged<T>? onValueChanged,
    @Deprecated('Use onValueChange(value, details) instead.')
    void Function(T value, int stepDelta)? onValueStepChanged,
    Widget Function(BuildContext, T, bool)? itemBuilder,
    double? width,
    AlignmentGeometry alignment = Alignment.center,
    int flex = 1,
    bool? loop,
    @Deprecated('Use loop instead.') bool? looping,
    bool enabled = true,
    bool readOnly = false,
    String? semanticsLabel,
    String Function(T)? semanticsValueFormatter,
  }) {
    assert(items.isNotEmpty);
    assert(value == null || items.contains(value));
    assert(defaultValue == null || items.contains(defaultValue));
    assert(
      onValueChange == null ||
          (onValueChanged == null && onValueStepChanged == null),
    );
    assert(loop == null || looping == null);
    return _SeedWheelColumnImpl<T>(
      preserveInitialSelection: true,
      items: items,
      index: value == null ? null : items.indexOf(value),
      initialIndex: defaultValue == null ? 0 : items.indexOf(defaultValue),
      onChanged: (index) => onValueChanged?.call(items[index]),
      onStepChanged: onValueChange == null && onValueStepChanged == null
          ? null
          : (index, stepDelta) {
              if (stepDelta % items.length != 0) {
                onValueChange?.call(
                  items[index],
                  SeedWheelPickerValueChangeDetails(stepDelta: stepDelta),
                );
              }
              onValueStepChanged?.call(items[index], stepDelta);
            },
      onIndexChanged: onIndexChange == null
          ? null
          : (index) => onIndexChange(index, items[index]),
      itemBuilder: itemBuilder,
      width: width,
      alignment: alignment,
      flex: flex,
      looping: loop ?? looping ?? false,
      enabled: enabled,
      readOnly: readOnly,
      semanticsLabel: semanticsLabel,
      semanticsValueFormatter: semanticsValueFormatter,
    );
  }

  int get itemCount;
  int get initialIndex;
  int? get index => null;

  /// Called once when scrolling settles on a different value.
  ValueChanged<int>? get onChanged;

  /// Called once when scrolling settles, providing both the resolved index and
  /// the signed step delta traversed on the wheel.
  void Function(int index, int stepDelta)? get onStepChanged => null;
  double get itemExtent;
  double? get width => null;
  AlignmentGeometry get alignment => Alignment.center;
  int get flex;

  /// Whether the column repeats across its first/last item boundary.
  /// Change callbacks still report indices in `0 .. itemCount - 1`.
  bool get loop => looping;
  @Deprecated('Use loop instead.')
  bool get looping => false;
  bool get _preserveInitialSelection => false;
  int? _indexPreservingValue(SeedWheelColumn previous, int previousIndex) =>
      null;
  bool get enabled => true;
  bool get readOnly => false;
  String? get semanticsLabel => null;
  ValueChanged<int>? get onIndexChanged => null;
  String semanticValue(int index) => '$index';

  Widget buildItem(BuildContext context, int index, bool isSelected);

  /// Resolves the row height, preserving custom column implementations.
  double effectiveItemExtent(SeedWheelPickerSize size) => itemExtent;

  Widget buildItemForSize(
    BuildContext context,
    int index,
    bool isSelected,
    SeedWheelPickerSize size,
  ) => buildItem(context, index, isSelected);
}

class _SeedWheelColumnImpl<T> extends SeedWheelColumn {
  const _SeedWheelColumnImpl({
    required this.items,
    this.initialIndex = 0,
    this.index,
    this.onChanged,
    this.onStepChanged,
    this.itemBuilder,
    this.rowExtent,
    this.width,
    this.alignment = Alignment.center,
    this.flex = 1,
    this.looping = false,
    this.enabled = true,
    this.readOnly = false,
    this.semanticsLabel,
    this.semanticsValueFormatter,
    this.onIndexChanged,
    this.preserveInitialSelection = false,
  });

  final bool preserveInitialSelection;
  @override
  bool get _preserveInitialSelection => preserveInitialSelection;
  @override
  int? _indexPreservingValue(SeedWheelColumn previous, int previousIndex) {
    if (previous is! _SeedWheelColumnImpl ||
        previousIndex >= previous.items.length) {
      return null;
    }
    final index = items.indexWhere(
      (item) => item == previous.items[previousIndex],
    );
    return index < 0 ? 0 : index;
  }

  final List<T> items;
  @override
  final int initialIndex;
  @override
  final int? index;
  @override
  final ValueChanged<int>? onChanged;
  @override
  final void Function(int index, int stepDelta)? onStepChanged;
  final Widget Function(BuildContext context, T item, bool isSelected)?
  itemBuilder;
  @override
  double get itemExtent => rowExtent ?? SeedWheelPickerSize.medium.itemExtent;
  final double? rowExtent;
  @override
  final double? width;
  @override
  final AlignmentGeometry alignment;

  @override
  double effectiveItemExtent(SeedWheelPickerSize size) =>
      rowExtent ?? size.itemExtent;
  @override
  final int flex;
  @override
  final bool looping;
  @override
  final bool enabled;
  @override
  final bool readOnly;
  @override
  final String? semanticsLabel;
  final String Function(T)? semanticsValueFormatter;
  @override
  final ValueChanged<int>? onIndexChanged;
  @override
  String semanticValue(int index) =>
      semanticsValueFormatter?.call(items[index]) ?? items[index].toString();

  @override
  int get itemCount => items.length;

  @override
  Widget buildItem(BuildContext context, int index, bool isSelected) =>
      buildItemForSize(context, index, isSelected, SeedWheelPickerSize.medium);

  @override
  Widget buildItemForSize(
    BuildContext context,
    int index,
    bool isSelected,
    SeedWheelPickerSize size,
  ) {
    final item = items[index];
    if (itemBuilder != null) {
      return itemBuilder!(context, item, isSelected);
    }
    final colors = context.seedColor;
    final typography = context.seedTypography;
    final style = size == SeedWheelPickerSize.small
        ? typography.t7Medium
        : typography.t10Medium;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SeedDimension.x4),
      child: Align(
        alignment: alignment,
        child: Text(
          item.toString(),
          textScaler: TextScaler.noScaling,
          style: isSelected
              ? style.copyWith(color: colors.fg.neutral)
              : style.copyWith(color: colors.fg.disabled),
        ),
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
    this.enabled = true,
    this.readOnly = false,
    this.semanticsLabel,
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

  /// Whether scrolling, item selection and focus are allowed.
  final bool enabled;
  final bool readOnly;
  final String? semanticsLabel;

  double get effectiveHeight => height ?? size.height;

  @override
  State<SeedWheelPicker> createState() => _SeedWheelPickerState();
}

class _SeedWheelPickerState extends State<SeedWheelPicker> {
  late List<FixedExtentScrollController> _controllers;
  late List<int> _selectedIndices;
  late List<int> _committedIndices;
  late List<int> _selectedScrollIndices;
  late List<int> _committedScrollIndices;
  final Map<FixedExtentScrollController, FocusNode> _focusNodes = {};

  @override
  void initState() {
    super.initState();
    _controllers = widget.columns.map((col) {
      return FixedExtentScrollController(initialItem: _validIndex(col));
    }).toList();
    _selectedIndices = widget.columns.map(_validIndex).toList();
    _committedIndices = List.of(_selectedIndices);
    _selectedScrollIndices = List.of(_selectedIndices);
    _committedScrollIndices = List.of(_selectedIndices);
  }

  int _validIndex(SeedWheelColumn col) => col.itemCount == 0
      ? 0
      : (col.index ?? col.initialIndex).clamp(0, col.itemCount - 1);

  @override
  void didUpdateWidget(SeedWheelPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldControllers = _controllers;
    final updatedControllers = <FixedExtentScrollController>[];
    final updatedSelections = <int>[];
    final updatedCommits = <int>[];
    final updatedScrollSelections = <int>[];
    final updatedScrollCommits = <int>[];
    for (var i = 0; i < widget.columns.length; i++) {
      final column = widget.columns[i];
      final preserveValue =
          column._preserveInitialSelection &&
          column.index == null &&
          i < oldWidget.columns.length &&
          oldWidget.columns[i].index == null;
      final targetIndex = preserveValue
          ? column._indexPreservingValue(
                  oldWidget.columns[i],
                  _selectedIndices[i],
                ) ??
                _validIndex(column)
          : _validIndex(column);
      final keepSelection =
          i < oldWidget.columns.length &&
          column.itemCount == oldWidget.columns[i].itemCount &&
          column.looping == oldWidget.columns[i].looping &&
          column.effectiveItemExtent(widget.size) ==
              oldWidget.columns[i].effectiveItemExtent(oldWidget.size) &&
          (preserveValue
              ? _selectedIndices[i] == targetIndex
              : ((_selectedIndices[i] == targetIndex &&
                        (column.index != null ||
                            targetIndex == _validIndex(oldWidget.columns[i]) ||
                            _committedIndices[i] == targetIndex)) ||
                    (targetIndex == _validIndex(oldWidget.columns[i]) &&
                        column.index == null) ||
                    (oldControllers[i].hasClients &&
                        oldControllers[i].position.isScrollingNotifier.value)));

      if (keepSelection) {
        // Parent rebuilds must not reset another column's user selection.
        updatedControllers.add(oldControllers[i]);
        updatedSelections.add(_selectedIndices[i]);
        updatedCommits.add(_committedIndices[i]);
        updatedScrollSelections.add(_selectedScrollIndices[i]);
        updatedScrollCommits.add(_committedScrollIndices[i]);
      } else {
        updatedControllers.add(
          FixedExtentScrollController(initialItem: targetIndex),
        );
        updatedSelections.add(targetIndex);
        updatedCommits.add(targetIndex);
        updatedScrollSelections.add(targetIndex);
        updatedScrollCommits.add(targetIndex);
      }
    }

    // The previous ListWheelScrollView remains attached for this frame.
    for (final controller in oldControllers) {
      if (!updatedControllers.contains(controller)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _focusNodes.remove(controller)?.dispose();
          controller.dispose();
        });
      }
    }
    _controllers = updatedControllers;
    _selectedIndices = updatedSelections;
    _committedIndices = updatedCommits;
    _selectedScrollIndices = updatedScrollSelections;
    _committedScrollIndices = updatedScrollCommits;
    if (oldWidget.enabled && !widget.enabled) {
      // Cancel any in-flight activity and restore the last confirmed value.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || widget.enabled) return;
        for (var i = 0; i < _controllers.length; i++) {
          if (_controllers[i].hasClients) {
            _controllers[i].jumpToItem(_committedScrollIndices[i]);
          }
        }
      });
      _selectedIndices = List.of(_committedIndices);
      _selectedScrollIndices = List.of(_committedScrollIndices);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final node in _focusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final itemHeight = widget.columns.isNotEmpty
        ? widget.columns.first.effectiveItemExtent(widget.size)
        : widget.size.itemExtent;
    final pickerHeight = widget.effectiveHeight;
    final fogHeight = (pickerHeight * 0.4).clamp(0.0, itemHeight * 3);

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
          Semantics(
            label: widget.semanticsLabel,
            enabled: widget.enabled,
            child: ExcludeFocus(
              excluding: !widget.enabled,
              child: IgnorePointer(
                ignoring: !widget.enabled,
                child: Row(
                  children: List.generate(widget.columns.length, (colIdx) {
                    final col = widget.columns[colIdx];
                    final enabled = widget.enabled && col.enabled;
                    final editable =
                        enabled && !widget.readOnly && !col.readOnly;
                    final controller = _controllers[colIdx];
                    final selected = _selectedIndices[colIdx];
                    final canIncrease =
                        editable &&
                        col.itemCount > 0 &&
                        (col.looping || selected < col.itemCount - 1);
                    final canDecrease =
                        editable &&
                        col.itemCount > 0 &&
                        (col.looping || selected > 0);
                    final focusNode = _focusNodes.putIfAbsent(
                      controller,
                      FocusNode.new,
                    );
                    void move(int target) {
                      if (!editable || col.itemCount == 0) return;
                      controller.animateToItem(
                        col.looping
                            ? target
                            : target.clamp(0, col.itemCount - 1),
                        duration: SeedDuration.d3,
                        curve: SeedCurves.easing,
                      );
                    }

                    final columnChild = Semantics(
                      label: col.semanticsLabel,
                      value: col.itemCount == 0
                          ? null
                          : col.semanticValue(_selectedIndices[colIdx]),
                      enabled: enabled,
                      readOnly: widget.readOnly || col.readOnly,
                      increasedValue: canIncrease
                          ? col.semanticValue((selected + 1) % col.itemCount)
                          : null,
                      decreasedValue: canDecrease
                          ? col.semanticValue((selected - 1) % col.itemCount)
                          : null,
                      onIncrease: canIncrease
                          ? () => move(controller.selectedItem + 1)
                          : null,
                      onDecrease: canDecrease
                          ? () => move(controller.selectedItem - 1)
                          : null,
                      child: Focus(
                        focusNode: focusNode,
                        canRequestFocus: enabled,
                        onKeyEvent: (_, event) {
                          if (!editable || event is! KeyDownEvent) {
                            return KeyEventResult.ignored;
                          }
                          final key = event.logicalKey;
                          if (key == LogicalKeyboardKey.arrowDown) {
                            move(controller.selectedItem + 1);
                          } else if (key == LogicalKeyboardKey.arrowUp) {
                            move(controller.selectedItem - 1);
                          } else if (key == LogicalKeyboardKey.home) {
                            move(0);
                          } else if (key == LogicalKeyboardKey.end) {
                            move(col.itemCount - 1);
                          } else {
                            return KeyEventResult.ignored;
                          }
                          return KeyEventResult.handled;
                        },
                        child: IgnorePointer(
                          ignoring: !editable,
                          child: NotificationListener<ScrollNotification>(
                            onNotification: (notification) {
                              final scrollMoved =
                                  _committedScrollIndices[colIdx] !=
                                  _selectedScrollIndices[colIdx];
                              final indexChanged =
                                  _committedIndices[colIdx] !=
                                  _selectedIndices[colIdx];
                              if (notification is ScrollEndNotification &&
                                  notification.depth == 0 &&
                                  editable &&
                                  (indexChanged ||
                                      (col.looping &&
                                          scrollMoved &&
                                          col.onStepChanged != null))) {
                                final index = _selectedIndices[colIdx];
                                final stepDelta =
                                    _selectedScrollIndices[colIdx] -
                                    _committedScrollIndices[colIdx];
                                _committedIndices[colIdx] = index;
                                _committedScrollIndices[colIdx] =
                                    _selectedScrollIndices[colIdx];
                                HapticFeedback.selectionClick();
                                col.onStepChanged?.call(index, stepDelta);
                                if (indexChanged || col.onStepChanged == null) {
                                  col.onChanged?.call(index);
                                }
                                if (col.index != null) {
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    if (!mounted ||
                                        colIdx >= widget.columns.length) {
                                      return;
                                    }
                                    final current = widget.columns[colIdx];
                                    final target = _validIndex(current);
                                    if (current.index != null &&
                                        _selectedIndices[colIdx] != target) {
                                      setState(() {
                                        _selectedIndices[colIdx] = target;
                                        _committedIndices[colIdx] = target;
                                        _selectedScrollIndices[colIdx] = target;
                                        _committedScrollIndices[colIdx] =
                                            target;
                                      });
                                      if (_controllers[colIdx].hasClients) {
                                        _controllers[colIdx].jumpToItem(target);
                                      }
                                    }
                                  });
                                }
                              }
                              return false;
                            },
                            child: ListWheelScrollView.useDelegate(
                              // A new controller means an externally supplied selection
                              // or item count changed. Reset the wheel's Scrollable state
                              // so its old scroll offset cannot override initialItem.
                              key: ObjectKey(_controllers[colIdx]),
                              controller: _controllers[colIdx],
                              itemExtent: col.effectiveItemExtent(widget.size),
                              perspective: 0.003,
                              diameterRatio: 1.8,
                              physics: editable
                                  ? const FixedExtentScrollPhysics()
                                  : const NeverScrollableScrollPhysics(),
                              onSelectedItemChanged: (scrollIndex) {
                                if (!editable) return;
                                final prevScrollIndex =
                                    _selectedScrollIndices[colIdx];
                                final nextIndex =
                                    col.looping && col.itemCount > 0
                                    ? scrollIndex % col.itemCount
                                    : scrollIndex;
                                setState(() {
                                  _selectedScrollIndices[colIdx] = scrollIndex;
                                  _selectedIndices[colIdx] = nextIndex;
                                });
                                if (col.onIndexChanged != null &&
                                    col.itemCount > 0) {
                                  final step = scrollIndex >= prevScrollIndex
                                      ? 1
                                      : -1;
                                  for (
                                    var s = prevScrollIndex + step;
                                    step > 0
                                        ? s <= scrollIndex
                                        : s >= scrollIndex;
                                    s += step
                                  ) {
                                    col.onIndexChanged!(
                                      col.looping ? s % col.itemCount : s,
                                    );
                                  }
                                }
                              },
                              childDelegate: ListWheelChildBuilderDelegate(
                                childCount: col.looping && col.itemCount > 0
                                    ? null
                                    : col.itemCount,
                                builder: (context, scrollIndex) {
                                  final index = col.looping
                                      ? scrollIndex % col.itemCount
                                      : scrollIndex;
                                  final isSelected =
                                      _selectedIndices[colIdx] == index;
                                  // Wheel slots have a tight itemExtent height. Center
                                  // custom content within the slot, just like defaults.
                                  return GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: editable
                                        ? () {
                                            final controller =
                                                _controllers[colIdx];
                                            if (controller
                                                .position
                                                .isScrollingNotifier
                                                .value) {
                                              return;
                                            }
                                            focusNode.requestFocus();
                                            controller.animateToItem(
                                              scrollIndex,
                                              duration: SeedDuration.d4,
                                              curve: SeedCurves.easing,
                                            );
                                          }
                                        : null,
                                    child: Center(
                                      child: col.buildItemForSize(
                                        context,
                                        index,
                                        enabled && isSelected,
                                        widget.size,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                    if (col.width != null) {
                      return SizedBox(width: col.width, child: columnChild);
                    }
                    return Expanded(flex: col.flex, child: columnChild);
                  }),
                ),
              ),
            ),
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
