import 'dart:ui' show SemanticsRole;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../../foundations/dimensions/seed_dimension.dart';
import 'seed_select_box.dart';

/// Internal inherited scope for [SeedSelectBoxGroup].
class SeedSelectBoxGroupScope extends InheritedWidget {
  /// Passes group configuration and focus coordination to descendant cards.
  const SeedSelectBoxGroupScope({
    super.key,
    required this.defaultLayout,
    required this.isRadioGroup,
    required this.selectedValue,
    required this.enabled,
    required this.readOnly,
    required this.onSelect,
    this.focusCoordinator,
    required super.child,
  });

  /// Default layout for descendant cards, if the card does not override it.
  final SeedSelectBoxLayout? defaultLayout;

  /// Whether items use mutually exclusive radio semantics.
  final bool isRadioGroup;

  /// Active card identifier, or null for no selection.
  final Object? selectedValue;

  /// Whether interaction is allowed in the group.
  final bool enabled;

  /// Whether the group permits focus but suppresses selection changes.
  final bool readOnly;

  /// Called by a descendant when the user proposes another identifier.
  final ValueChanged<Object?> onSelect;

  /// Optional keyboard coordinator for radio-style cards.
  final SeedSelectBoxFocusCoordinator? focusCoordinator;

  /// Returns the nearest group scope, or null outside a group.
  static SeedSelectBoxGroupScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SeedSelectBoxGroupScope>();

  /// Notifies descendants when layout, selection or interaction policy changes.
  @override
  bool updateShouldNotify(SeedSelectBoxGroupScope oldWidget) =>
      defaultLayout != oldWidget.defaultLayout ||
      isRadioGroup != oldWidget.isRadioGroup ||
      selectedValue != oldWidget.selectedValue ||
      enabled != oldWidget.enabled ||
      readOnly != oldWidget.readOnly ||
      focusCoordinator != oldWidget.focusCoordinator;
}

/// Internal radio focus policy. Cards register themselves so wrappers such as
/// Padding do not break group keyboard navigation.
class SeedSelectBoxFocusCoordinator {
  /// Non-focusable root used to determine widget traversal order.
  final FocusNode root = FocusNode(canRequestFocus: false);
  final _items =
      <FocusNode, ({Object value, bool enabled, VoidCallback select})>{};

  /// Currently selected identifier; influences the group's single Tab stop.
  Object? selectedValue;
  bool _scheduled = false;
  bool _disposed = false;

  List<FocusNode> get _ordered {
    final nodes = _items.keys.where((node) => node.context != null).toList();
    if (nodes.isEmpty) return nodes;
    return WidgetOrderTraversalPolicy().sortDescendants(nodes, root).toList();
  }

  /// Registers a card's [node], its [value] and its activation callback.
  ///
  /// [enabled] excludes disabled entries from keyboard traversal, while
  /// [select] is invoked after arrow/Home/End navigation changes focus.
  void register(
    FocusNode node,
    Object value,
    bool enabled,
    VoidCallback select,
  ) {
    _items[node] = (value: value, enabled: enabled, select: select);
    syncTraversal();
  }

  /// Removes a card's focus node and recalculates the group's Tab stop.
  void unregister(FocusNode node) {
    _items.remove(node);
    syncTraversal();
  }

  /// Schedules a post-frame update of eligible [FocusNode.skipTraversal] flags.
  ///
  /// Only the selected enabled item (or first enabled item) participates in
  /// the Tab order. Arrow navigation can still move between registered items.
  void syncTraversal() {
    if (_scheduled || _disposed) return;
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      if (_disposed) return;
      assert(() {
        final values = _items.values.map((item) => item.value).toList();
        assert(
          values.toSet().length == values.length,
          'Radio select boxes must have unique values within a group.',
        );
        return true;
      }());
      final enabled = _ordered.where((node) => _items[node]!.enabled).toList();
      final entry =
          enabled
              .where((node) => _items[node]!.value == selectedValue)
              .firstOrNull ??
          enabled.firstOrNull;
      for (final node in _items.keys) {
        node.skipTraversal = node != entry;
      }
    });
  }

  /// Handles arrow, Home and End keys for the registered [node].
  ///
  /// Horizontal arrows respect text direction. Returns handled only when an
  /// eligible item is focused and a supported navigation key is pressed.
  KeyEventResult onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final nodes = _ordered.where((node) => _items[node]!.enabled).toList();
    final current = nodes.indexWhere((node) => node.hasPrimaryFocus);
    if (current < 0) return KeyEventResult.ignored;
    final rtl = Directionality.of(node.context!) == TextDirection.rtl;
    final key = event.logicalKey;
    final forward =
        key == LogicalKeyboardKey.arrowDown ||
        key ==
            (rtl
                ? LogicalKeyboardKey.arrowLeft
                : LogicalKeyboardKey.arrowRight);
    final backward =
        key == LogicalKeyboardKey.arrowUp ||
        key ==
            (rtl
                ? LogicalKeyboardKey.arrowRight
                : LogicalKeyboardKey.arrowLeft);
    final int next;
    if (key == LogicalKeyboardKey.home) {
      next = 0;
    } else if (key == LogicalKeyboardKey.end) {
      next = nodes.length - 1;
    } else if (forward || backward) {
      next = (current + (forward ? 1 : -1)) % nodes.length;
    } else {
      return KeyEventResult.ignored;
    }
    nodes[next].requestFocus();
    Scrollable.ensureVisible(nodes[next].context!);
    _items[nodes[next]]!.select();
    return KeyEventResult.handled;
  }

  /// Clears registered entries and disposes the coordinator-owned [root].
  void dispose() {
    _disposed = true;
    _items.clear();
    root.dispose();
  }
}

/// Container that groups multiple [SeedSelectBox] items with official SEED Design spacing.
///
/// Features `gapX: 12px` and `gapY: 12px` (`componentDefault`).
/// When [controlled] is true or [value], [defaultValue], or [onValueChanged] is
/// provided, manages
/// mutually exclusive radio selection for child [SeedSelectBox] items that
/// specify a [SeedSelectBox.value].
class SeedSelectBoxGroup extends StatefulWidget {
  /// Cards or other widgets laid out by the group.
  final List<Widget> children;

  /// Layout axis, vertical by default.
  final Axis direction;

  /// Optional number of wrap columns.
  final int? columns;

  /// Alignment of wrapped rows along their cross axis.
  final WrapCrossAlignment crossAxisAlignment;

  /// Parent-controlled radio selection when non-null.
  final Object? value;

  /// Initial radio selection when uncontrolled.
  final Object? defaultValue;

  /// Keeps [value], including null (no selection), under parent control.
  final bool controlled;

  final bool _explicitRadio;

  /// Deprecated spelling of [onValueChange].
  @Deprecated('Use onValueChange instead.')
  final ValueChanged<Object?>? onValueChanged;

  /// Reports proposed radio selection changes.
  ValueChanged<Object?>? get onValueChange => onValueChanged;

  /// Enables all descendant controls, true by default.
  final bool enabled;

  /// Allows navigation while preventing selection changes.
  final bool readOnly;

  /// Accessible name of the radio group, like the official Root `label`
  /// when the visible label comes from a surrounding [SeedField].
  final String? semanticsLabel;

  /// Creates a group, arranging [children] along [direction].
  ///
  /// [columns] sets a wrapped grid count when present. A non-null [value],
  /// [defaultValue], [onValueChange] or explicit [controlled] enables radio
  /// selection for cards carrying identifiers. The default is an ungrouped
  /// selection layout. Use [controlled] to keep a null selection parent-owned.
  const SeedSelectBoxGroup({
    super.key,
    required this.children,
    this.direction = Axis.vertical,
    this.columns,
    this.crossAxisAlignment = WrapCrossAlignment.start,
    this.value,
    this.defaultValue,
    this.controlled = false,
    ValueChanged<Object?>? onValueChange,
    @Deprecated('Use onValueChange instead.')
    ValueChanged<Object?>? onValueChanged,
    this.enabled = true,
    this.readOnly = false,
    this.semanticsLabel,
  }) : onValueChanged = onValueChange ?? onValueChanged,
       _explicitRadio = false,
       assert(onValueChange == null || onValueChanged == null);

  /// Creates a radio group even when the initial selection and callback are null.
  ///
  /// Each descendant card must have a unique non-null value, and its selection
  /// is owned by the group. The default constructor retains layout-only mode.
  const SeedSelectBoxGroup.radio({
    super.key,
    required this.children,
    this.direction = Axis.vertical,
    this.columns,
    this.crossAxisAlignment = WrapCrossAlignment.start,
    this.value,
    this.defaultValue,
    this.controlled = false,
    ValueChanged<Object?>? onValueChange,
    @Deprecated('Use onValueChange instead.')
    ValueChanged<Object?>? onValueChanged,
    this.enabled = true,
    this.readOnly = false,
    this.semanticsLabel,
  }) : onValueChanged = onValueChange ?? onValueChanged,
       _explicitRadio = true,
       assert(onValueChange == null || onValueChanged == null);

  /// Creates state for group selection and keyboard focus coordination.
  @override
  State<SeedSelectBoxGroup> createState() => _SeedSelectBoxGroupState();
}

class _SeedSelectBoxGroupState extends State<SeedSelectBoxGroup> {
  late Object? _uncontrolledValue = widget.defaultValue;
  final _focusCoordinator = SeedSelectBoxFocusCoordinator();

  @override
  void dispose() {
    _focusCoordinator.dispose();
    super.dispose();
  }

  bool get _isRadioGroup =>
      widget._explicitRadio ||
      widget.controlled ||
      widget.value != null ||
      widget.defaultValue != null ||
      widget.onValueChanged != null;

  bool get _isControlled => widget.controlled || widget.value != null;
  Object? get _effectiveValue =>
      _isControlled ? widget.value : _uncontrolledValue;

  void _handleSelect(Object? next) {
    if (!widget.enabled || widget.readOnly) return;
    final prev = _effectiveValue;
    if (!_isControlled && _uncontrolledValue != next) {
      setState(() => _uncontrolledValue = next);
    }
    if (prev != next) {
      widget.onValueChanged?.call(next);
    }
  }

  @override
  Widget build(BuildContext context) {
    _focusCoordinator.selectedValue = _effectiveValue;
    _focusCoordinator.syncTraversal();
    final columns = widget.columns;
    final defaultLayout = columns == null
        ? null
        : (columns == 1
              ? SeedSelectBoxLayout.horizontal
              : SeedSelectBoxLayout.vertical);

    Widget content;
    if (columns != null) {
      assert(columns > 0);
      content = LayoutBuilder(
        builder: (context, constraints) {
          final width = (constraints.maxWidth - 12 * (columns - 1)) / columns;
          if (columns == 1) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int i = 0; i < widget.children.length; i++) ...[
                  if (i > 0) const SizedBox(height: 12),
                  SizedBox(width: width, child: widget.children[i]),
                ],
              ],
            );
          }
          final rows = <Widget>[];
          for (int i = 0; i < widget.children.length; i += columns) {
            if (rows.isNotEmpty) {
              rows.add(const SizedBox(height: 12));
            }
            final end = (i + columns < widget.children.length)
                ? i + columns
                : widget.children.length;
            rows.add(
              IntrinsicHeight(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (int j = i; j < end; j++) ...[
                      if (j > i) const SizedBox(width: 12),
                      SizedBox(width: width, child: widget.children[j]),
                    ],
                  ],
                ),
              ),
            );
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rows,
          );
        },
      );
    } else if (widget.direction == Axis.vertical) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < widget.children.length; i++) ...[
            if (i > 0) const SizedBox(height: SeedSpacingY.componentDefault),
            widget.children[i],
          ],
        ],
      );
    } else {
      content = Wrap(
        direction: widget.direction,
        spacing: SeedDimension.x3,
        runSpacing: SeedSpacingY.componentDefault,
        crossAxisAlignment: widget.crossAxisAlignment,
        children: widget.children,
      );
    }

    Widget result = SeedSelectBoxGroupScope(
      defaultLayout: defaultLayout,
      isRadioGroup: _isRadioGroup,
      selectedValue: _effectiveValue,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      onSelect: _handleSelect,
      focusCoordinator: _isRadioGroup ? _focusCoordinator : null,
      child: content,
    );

    if (_isRadioGroup) {
      result = Semantics(
        container: true,
        role: SemanticsRole.radioGroup,
        label: widget.semanticsLabel,
        child: FocusTraversalGroup(
          child: Focus(
            focusNode: _focusCoordinator.root,
            includeSemantics: false,
            onKeyEvent: _focusCoordinator.onKey,
            child: result,
          ),
        ),
      );
    }

    return result;
  }
}
