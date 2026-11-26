import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, listEquals, TargetPlatform;

import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../foundations/motion/seed_motion.dart';
import '../../theme/seed_theme.dart';
import '../layout/seed_scroll_fog.dart';

/// Size options for [SeedWheelPicker].
enum SeedWheelPickerSize {
  /// Compact wheel: 180px tall with 36px rows.
  small(height: 180.0, itemExtent: 36.0),

  /// Standard wheel: 220px tall with 44px rows.
  medium(height: 220.0, itemExtent: 44.0);

  /// Creates a wheel size with its [height] and [itemExtent].
  const SeedWheelPickerSize({required this.height, required this.itemExtent});

  /// Default total wheel height for this size.
  final double height;

  /// Default height of an individual option row.
  final double itemExtent;
}

/// React WheelPicker value-change details, independent of option type.
class SeedWheelPickerValueChangeDetails {
  /// Creates details recording the signed number of traversed [stepDelta] steps.
  const SeedWheelPickerValueChangeDetails({required this.stepDelta});

  /// Signed number of wheel steps traversed during this committed change.
  final int stepDelta;
}

/// Specification for a single column in [SeedWheelPicker].
///
/// Use [SeedWheelColumn.value] to mirror React's value/defaultValue callbacks,
/// or [SeedWheelColumn.typed] for Flutter's index-based API.
abstract class SeedWheelColumn {
  /// Creates a column specification for implementations that subclass it.
  const SeedWheelColumn();

  /// Creates a typed column specification for [SeedWheelPicker].
  ///
  /// [items] supplies rows and [itemBuilder] optionally renders custom widgets.
  /// [index] controls the current selection; [initialIndex] seeds an
  /// uncontrolled column (default zero). [onChanged] reports the settled index,
  /// [onStepChanged] includes signed travel steps, and [onIndexChanged] is an
  /// additional observer of index changes.
  ///
  /// [itemExtent] overrides the wheel's row height; [width] reserves an
  /// explicit width, otherwise [flex] (default one) allocates remaining space.
  /// [alignment] aligns row contents. [loop] wraps at both ends and defaults
  /// to false; [looping] is its deprecated name. [enabled] is true and
  /// [readOnly] false by default. The [semanticsLabel] and
  /// [semanticsValueFormatter] describe the accessible column.
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

  /// Creates a React-compatible value-based wheel column.
  ///
  /// [value] controls selection, whereas [defaultValue] initializes the local
  /// selection (first item by default). Both must occur in [items].
  /// [onValueChange] receives the selected item and
  /// [SeedWheelPickerValueChangeDetails.stepDelta] after wheel movement;
  /// [onIndexChange] observes its position. The deprecated [onValueChanged],
  /// [onValueStepChanged], and [looping] names remain compatibility options.
  /// [loop], [enabled], [readOnly], [width], [flex], [alignment], [itemBuilder],
  /// [semanticsLabel], and [semanticsValueFormatter] configure the column as
  /// in [SeedWheelColumn.typed]. [items] must not be empty.
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
    // Keep the previous widget's options available even if the caller mutates
    // its list in place before rebuilding.
    final options = List<T>.of(items);
    return _SeedWheelColumnImpl<T>(
      preserveInitialSelection: true,
      items: options,
      index: value == null ? null : options.indexOf(value),
      initialIndex: defaultValue == null ? 0 : options.indexOf(defaultValue),
      onChanged: (index) => onValueChanged?.call(options[index]),
      onStepChanged: onValueChange == null && onValueStepChanged == null
          ? null
          : (index, stepDelta) {
              if (stepDelta % options.length != 0) {
                onValueChange?.call(
                  options[index],
                  SeedWheelPickerValueChangeDetails(stepDelta: stepDelta),
                );
              }
              onValueStepChanged?.call(options[index], stepDelta);
            },
      onIndexChanged: onIndexChange == null
          ? null
          : (index) => onIndexChange(index, options[index]),
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

  /// Number of selectable items in this column.
  int get itemCount;

  /// Starting zero-based selection index of an uncontrolled column.
  int get initialIndex;

  /// Controlled zero-based index, or null for an uncontrolled column.
  int? get index => null;

  /// Called once when scrolling settles on a different value.
  ValueChanged<int>? get onChanged;

  /// Called once when scrolling settles, providing both the resolved index and
  /// the signed step delta traversed on the wheel.
  void Function(int index, int stepDelta)? get onStepChanged => null;

  /// Preferred height of one row in logical pixels.
  double get itemExtent;

  /// Fixed column width in logical pixels, or null to allocate flex space.
  double? get width => null;

  /// Content alignment within the column (default center).
  AlignmentGeometry get alignment => Alignment.center;

  /// Proportional share of remaining space when [width] is absent.
  int get flex;

  /// Whether the column repeats across its first/last item boundary.
  /// Change callbacks still report indices in `0 .. itemCount - 1`.
  bool get loop => looping;

  /// Deprecated wraparound alias; use [loop].
  @Deprecated('Use loop instead.')
  bool get looping => false;
  bool get _preserveInitialSelection => false;
  bool _hasSameOptions(SeedWheelColumn previous) => true;
  int? _indexPreservingValue(SeedWheelColumn previous, int previousIndex) =>
      null;

  /// Whether this column accepts interaction (default true).
  bool get enabled => true;

  /// Whether the column is viewable but cannot be changed (default false).
  bool get readOnly => false;

  /// Optional accessible label for this column.
  String? get semanticsLabel => null;

  /// Reports each zero-based index passed while the wheel moves, before
  /// the final [onChanged] or [onStepChanged] notification on scroll settle.
  ValueChanged<int>? get onIndexChanged => null;

  /// Text that assistive technologies announce for [index].
  String semanticValue(int index) => '$index';

  /// Builds the option at [index]; [isSelected] identifies the centered option.
  Widget buildItem(BuildContext context, int index, bool isSelected);

  /// Resolves the row height, preserving custom column implementations.
  double effectiveItemExtent(SeedWheelPickerSize size) => itemExtent;

  /// Builds an option for [size], delegating to [buildItem] by default.
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
  bool _hasSameOptions(SeedWheelColumn previous) =>
      previous is _SeedWheelColumnImpl && listEquals(items, previous.items);

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
      // React's wheel item is a full-width flex row whose `justify-content`
      // places the label on the inline axis (the TimePicker sets it to
      // flex-end for hours). Custom builders must honor the column alignment
      // too; the wheel otherwise wraps every item in `Center`.
      return Align(
        alignment: alignment,
        child: itemBuilder!(context, item, isSelected),
      );
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
  /// Creates a wheel containing one or more [columns].
  ///
  /// [size] defaults to [SeedWheelPickerSize.medium] (220px tall);
  /// [height] overrides the size's height. [showFog] and [showIndicator]
  /// default to true. [enabled] is true and [readOnly] false by default.
  /// [semanticsLabel] labels the overall wheel; each column may have its
  /// own [SeedWheelColumn.semanticsLabel].
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

  /// Overall height of the picker. If null, defaults to [SeedWheelPickerSize.height].
  final double? height;

  /// Whether to show the top and bottom fade/fog gradients.
  final bool showFog;

  /// Whether to display the centered selection indicator.
  final bool showIndicator;

  /// Whether scrolling, item selection and focus are allowed.
  final bool enabled;

  /// Whether the wheel remains visible while selection changes are blocked.
  ///
  /// Defaults to false and combines with each column's read-only state.
  final bool readOnly;

  /// Accessible name of the wheel containing all [columns].
  final String? semanticsLabel;

  /// Resolved picker height: explicit [height] or [size]'s default height.
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
  // A controlled value or option count can replace the scroll controller,
  // while the corresponding column remains the same keyboard focus target.
  final Map<int, FocusNode> _focusNodes = {};
  final Map<FixedExtentScrollController, int> _keyboardTargets = {};

  @override
  void initState() {
    super.initState();
    _controllers = widget.columns.map((col) {
      return FixedExtentScrollController(
        initialItem: _validIndex(col),
        keepScrollOffset: false,
      );
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
      final becameConstrained =
          i < oldWidget.columns.length &&
          oldWidget.enabled &&
          !oldWidget.readOnly &&
          oldWidget.columns[i].enabled &&
          !oldWidget.columns[i].readOnly &&
          (!widget.enabled ||
              widget.readOnly ||
              !column.enabled ||
              column.readOnly);
      final preserveValue =
          column._preserveInitialSelection &&
          column.index == null &&
          i < oldWidget.columns.length &&
          oldWidget.columns[i].index == null;
      final optionsChanged =
          preserveValue && !column._hasSameOptions(oldWidget.columns[i]);
      final targetIndex = preserveValue
          ? column._indexPreservingValue(
                  oldWidget.columns[i],
                  becameConstrained || optionsChanged
                      ? _committedIndices[i]
                      : _selectedIndices[i],
                ) ??
                _validIndex(column)
          : becameConstrained && column.index == null && column.itemCount > 0
          ? _committedIndices[i].clamp(0, column.itemCount - 1)
          : _validIndex(column);
      final keepSelection =
          !optionsChanged &&
          i < oldWidget.columns.length &&
          column.itemCount == oldWidget.columns[i].itemCount &&
          column.looping == oldWidget.columns[i].looping &&
          column.effectiveItemExtent(widget.size) ==
              oldWidget.columns[i].effectiveItemExtent(oldWidget.size) &&
          (becameConstrained
              ? _committedIndices[i] == targetIndex
              : (preserveValue
                    ? _selectedIndices[i] == targetIndex
                    : ((_selectedIndices[i] == targetIndex &&
                              (column.index != null ||
                                  targetIndex ==
                                      _validIndex(oldWidget.columns[i]) ||
                                  _committedIndices[i] == targetIndex)) ||
                          (targetIndex == _validIndex(oldWidget.columns[i]) &&
                              column.index == null) ||
                          (oldControllers[i].hasClients &&
                              oldControllers[i]
                                  .position
                                  .isScrollingNotifier
                                  .value))));

      if (keepSelection) {
        // Parent rebuilds must not reset another column's user selection.
        updatedControllers.add(oldControllers[i]);
        updatedSelections.add(_selectedIndices[i]);
        updatedCommits.add(_committedIndices[i]);
        updatedScrollSelections.add(_selectedScrollIndices[i]);
        updatedScrollCommits.add(_committedScrollIndices[i]);
      } else {
        updatedControllers.add(
          FixedExtentScrollController(
            initialItem: targetIndex,
            keepScrollOffset: false,
          ),
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
        _keyboardTargets.remove(controller);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.dispose();
        });
      }
    }
    _controllers = updatedControllers;
    _selectedIndices = updatedSelections;
    _committedIndices = updatedCommits;
    _selectedScrollIndices = updatedScrollSelections;
    _committedScrollIndices = updatedScrollCommits;
    for (var i = 0; i < widget.columns.length; i++) {
      if (!widget.enabled ||
          widget.readOnly ||
          !widget.columns[i].enabled ||
          widget.columns[i].readOnly) {
        _keyboardTargets.remove(_controllers[i]);
      }
    }
    for (final index in _focusNodes.keys.toList()) {
      if (index >= widget.columns.length) {
        final node = _focusNodes.remove(index)!;
        WidgetsBinding.instance.addPostFrameCallback((_) => node.dispose());
      }
    }
    for (
      var i = 0;
      i < widget.columns.length && i < oldWidget.columns.length;
      i++
    ) {
      final wasEditable =
          oldWidget.enabled &&
          !oldWidget.readOnly &&
          oldWidget.columns[i].enabled &&
          !oldWidget.columns[i].readOnly;
      final isEditable =
          widget.enabled &&
          !widget.readOnly &&
          widget.columns[i].enabled &&
          !widget.columns[i].readOnly;
      if (wasEditable && !isEditable) {
        // Cancel in-flight movement at the last committed selection.
        _selectedIndices[i] = _committedIndices[i];
        _selectedScrollIndices[i] = _committedScrollIndices[i];
        final controller = _controllers[i];
        final target = _committedScrollIndices[i];
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted ||
              i >= widget.columns.length ||
              _controllers[i] != controller) {
            return;
          }
          final current = widget.columns[i];
          if ((!widget.enabled ||
                  widget.readOnly ||
                  !current.enabled ||
                  current.readOnly) &&
              controller.hasClients) {
            controller.jumpToItem(target);
          }
        });
      }
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
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
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
          _maskFog(
            fogHeight,
            Semantics(
              label: widget.semanticsLabel,
              enabled: widget.enabled,
              child: ExcludeFocus(
                excluding: !widget.enabled,
                child: IgnorePointer(
                  ignoring: !widget.enabled,
                  child: _SeedWheelColumns(
                    columns: widget.columns,
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
                        colIdx,
                        FocusNode.new,
                      );
                      void move(
                        int target, {
                        bool keyboard = false,
                        bool repeat = false,
                      }) {
                        if (!editable || col.itemCount == 0) return;
                        final destination = col.looping
                            ? target
                            : target.clamp(0, col.itemCount - 1);
                        if (keyboard) {
                          _keyboardTargets[controller] = destination;
                        } else {
                          _keyboardTargets.remove(controller);
                        }
                        if (repeat || reduceMotion) {
                          // Repeated keys and reduced motion move immediately.
                          controller.jumpToItem(destination);
                          return;
                        }
                        controller.animateToItem(
                          destination,
                          duration: SeedDuration.d3,
                          curve: SeedCurves.easing,
                        );
                      }

                      final columnChild = Semantics(
                        container: true,
                        excludeSemantics: true,
                        slider: true,
                        label: col.semanticsLabel,
                        focusable: enabled,
                        focused: focusNode.hasFocus,
                        onFocus:
                            enabled &&
                                defaultTargetPlatform != TargetPlatform.iOS
                            ? focusNode.requestFocus
                            : null,
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
                          onFocusChange: (_) => setState(() {}),
                          onKeyEvent: (_, event) {
                            if (event is! KeyDownEvent &&
                                event is! KeyRepeatEvent) {
                              return KeyEventResult.ignored;
                            }
                            final key = event.logicalKey;
                            // React keeps the column focused for unhandled
                            // horizontal arrows and for readonly navigation.
                            // Do not let Flutter's directional traversal move
                            // focus to another column or a neighboring control.
                            if (key == LogicalKeyboardKey.arrowLeft ||
                                key == LogicalKeyboardKey.arrowRight) {
                              return KeyEventResult.handled;
                            }
                            if (!editable) {
                              return key == LogicalKeyboardKey.arrowDown ||
                                      key == LogicalKeyboardKey.arrowUp
                                  ? KeyEventResult.handled
                                  : KeyEventResult.ignored;
                            }
                            final current =
                                _keyboardTargets[controller] ??
                                controller.selectedItem;
                            int target;
                            if (key == LogicalKeyboardKey.arrowDown) {
                              target = current + 1;
                            } else if (key == LogicalKeyboardKey.arrowUp) {
                              target = current - 1;
                            } else if (key == LogicalKeyboardKey.pageDown) {
                              // React's column scrolls by its 4-row page here.
                              target = current + 4;
                            } else if (key == LogicalKeyboardKey.pageUp) {
                              target = current - 4;
                            } else if (key == LogicalKeyboardKey.home) {
                              target = 0;
                            } else if (key == LogicalKeyboardKey.end) {
                              target = col.itemCount - 1;
                            } else {
                              return KeyEventResult.ignored;
                            }
                            move(
                              target,
                              keyboard: true,
                              repeat: event is KeyRepeatEvent,
                            );
                            return KeyEventResult.handled;
                          },
                          child: IgnorePointer(
                            ignoring: !editable,
                            child: NotificationListener<ScrollNotification>(
                              onNotification: (notification) {
                                if (colIdx >= _controllers.length ||
                                    !identical(
                                      controller,
                                      _controllers[colIdx],
                                    )) {
                                  return false;
                                }
                                if (notification is ScrollEndNotification &&
                                    notification.depth == 0 &&
                                    controller.hasClients &&
                                    _keyboardTargets[controller] ==
                                        controller.selectedItem) {
                                  _keyboardTargets.remove(controller);
                                }
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
                                  if (indexChanged ||
                                      col.onStepChanged == null) {
                                    col.onChanged?.call(index);
                                  }
                                  if (col.index != null) {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                          if (!mounted ||
                                              colIdx >= widget.columns.length) {
                                            return;
                                          }
                                          final current =
                                              widget.columns[colIdx];
                                          final target = _validIndex(current);
                                          if (current.index != null &&
                                              _selectedIndices[colIdx] !=
                                                  target) {
                                            setState(() {
                                              _selectedIndices[colIdx] = target;
                                              _committedIndices[colIdx] =
                                                  target;
                                              _selectedScrollIndices[colIdx] =
                                                  target;
                                              _committedScrollIndices[colIdx] =
                                                  target;
                                            });
                                            if (_controllers[colIdx]
                                                .hasClients) {
                                              _controllers[colIdx].jumpToItem(
                                                target,
                                              );
                                            }
                                          }
                                        });
                                  }
                                }
                                return false;
                              },
                              child: Listener(
                                onPointerDown: (_) =>
                                    _keyboardTargets.remove(controller),
                                onPointerSignal: (_) =>
                                    _keyboardTargets.remove(controller),
                                child: ListWheelScrollView.useDelegate(
                                  // A new controller means an externally supplied selection
                                  // or item count changed. Reset the wheel's Scrollable state
                                  // so its old scroll offset cannot override initialItem.
                                  key: ObjectKey(_controllers[colIdx]),
                                  controller: _controllers[colIdx],
                                  itemExtent: col.effectiveItemExtent(
                                    widget.size,
                                  ),
                                  // The official pointer handling also takes mouse.
                                  scrollBehavior:
                                      ScrollConfiguration.of(context).copyWith(
                                        dragDevices: {
                                          ...ScrollConfiguration.of(context)
                                              .dragDevices,
                                          PointerDeviceKind.mouse,
                                        },
                                      ),
                                  // The official wheel is a flat scroller.
                                  perspective: 0.0001,
                                  diameterRatio: 1000,
                                  physics: editable
                                      ? const FixedExtentScrollPhysics()
                                      : const NeverScrollableScrollPhysics(),
                                  onSelectedItemChanged: (scrollIndex) {
                                    if (!editable ||
                                        colIdx >= _controllers.length ||
                                        !identical(
                                          controller,
                                          _controllers[colIdx],
                                        )) {
                                      return;
                                    }
                                    final prevScrollIndex =
                                        _selectedScrollIndices[colIdx];
                                    final nextIndex =
                                        col.looping && col.itemCount > 0
                                        ? scrollIndex % col.itemCount
                                        : scrollIndex;
                                    setState(() {
                                      _selectedScrollIndices[colIdx] =
                                          scrollIndex;
                                      _selectedIndices[colIdx] = nextIndex;
                                    });
                                    if (col.onIndexChanged != null &&
                                        col.itemCount > 0) {
                                      final step =
                                          scrollIndex >= prevScrollIndex
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
                                                if (reduceMotion) {
                                                  controller.jumpToItem(
                                                    scrollIndex,
                                                  );
                                                } else {
                                                  controller.animateToItem(
                                                    scrollIndex,
                                                    duration: SeedDuration.d4,
                                                    curve: SeedCurves.easing,
                                                  );
                                                }
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
                        ),
                      );
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          columnChild,
                          if (enabled &&
                              focusNode.hasPrimaryFocus &&
                              FocusManager.instance.highlightMode ==
                                  FocusHighlightMode.traditional)
                            Center(
                              child: IgnorePointer(
                                child: Container(
                                  height: itemHeight,
                                  decoration: BoxDecoration(
                                    borderRadius: SeedBorderRadius.r2,
                                    border: Border.all(
                                      color: colors.stroke.focusRing,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _maskFog(double size, Widget child) =>
      widget.showFog ? SeedScrollFogMask(size: size, child: child) : child;
}

/// Keeps explicit widths out of the flex pool, while retaining the centered
/// intrinsic group and proportional shrink required by the React TimePicker.
class _SeedWheelColumns extends StatelessWidget {
  const _SeedWheelColumns({required this.columns, required this.children});
  final List<SeedWheelColumn> columns;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final fixedWidth = columns.fold<double>(
        0,
        (sum, column) => sum + (column.width ?? 0),
      );
      final scale =
          constraints.hasBoundedWidth && fixedWidth > constraints.maxWidth
          ? constraints.maxWidth / fixedWidth
          : 1.0;
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < columns.length; i++)
            if (columns[i].width case final width?)
              SizedBox(width: width * scale, child: children[i])
            else
              Expanded(flex: columns[i].flex, child: children[i]),
        ],
      );
    },
  );
}
