import 'dart:ui' show SemanticsRole;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../../foundations/dimensions/seed_dimension.dart';
import 'seed_select_box.dart';

/// Internal inherited scope for [SeedSelectBoxGroup].
class SeedSelectBoxGroupScope extends InheritedWidget {
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

  final SeedSelectBoxLayout? defaultLayout;
  final bool isRadioGroup;
  final Object? selectedValue;
  final bool enabled;
  final bool readOnly;
  final ValueChanged<Object?> onSelect;
  final SeedSelectBoxFocusCoordinator? focusCoordinator;

  static SeedSelectBoxGroupScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SeedSelectBoxGroupScope>();

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
  final FocusNode root = FocusNode(canRequestFocus: false);
  final _items =
      <FocusNode, ({Object value, bool enabled, VoidCallback select})>{};
  Object? selectedValue;
  bool _scheduled = false;
  bool _disposed = false;

  List<FocusNode> get _ordered {
    final nodes = _items.keys.where((node) => node.context != null).toList();
    if (nodes.isEmpty) return nodes;
    return WidgetOrderTraversalPolicy().sortDescendants(nodes, root).toList();
  }

  void register(
    FocusNode node,
    Object value,
    bool enabled,
    VoidCallback select,
  ) {
    _items[node] = (value: value, enabled: enabled, select: select);
    syncTraversal();
  }

  void unregister(FocusNode node) {
    _items.remove(node);
    syncTraversal();
  }

  void syncTraversal() {
    if (_scheduled || _disposed) return;
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      if (_disposed) return;
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
  final List<Widget> children;
  final Axis direction;
  final int? columns;
  final WrapCrossAlignment crossAxisAlignment;
  final Object? value;
  final Object? defaultValue;

  /// Keeps [value], including null (no selection), under parent control.
  final bool controlled;
  final ValueChanged<Object?>? onValueChanged;
  final bool enabled;
  final bool readOnly;

  const SeedSelectBoxGroup({
    super.key,
    required this.children,
    this.direction = Axis.vertical,
    this.columns,
    this.crossAxisAlignment = WrapCrossAlignment.start,
    this.value,
    this.defaultValue,
    this.controlled = false,
    this.onValueChanged,
    this.enabled = true,
    this.readOnly = false,
  });

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
