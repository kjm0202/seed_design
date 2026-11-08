import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

/// Internal keyboard policy shared by tabs, segments and bottom navigation.
/// Only the selected choice is in the Tab order; arrows wrap and skip disabled
/// items. Focus and selection always move together.
class SeedChoiceGroup extends StatefulWidget {
  /// Index of the active choice; an invalid or disabled index moves the Tab stop to the first enabled choice.
  final int selectedIndex;
  /// Per-choice enable flags; list length determines the number of focus nodes.
  final List<bool> enabled;
  /// Receives the new enabled index selected by arrow/Home/End keyboard navigation.
  final ValueChanged<int> onSelected;

  /// False when the group scrolls its selection into view itself, so moving
  /// focus never scrolls an enclosing page.
  final bool revealOnMove;
  /// Builds the group with one managed [FocusNode] for each entry in [enabled].
  final Widget Function(BuildContext, List<FocusNode>) builder;
  /// Direction of arrow-key navigation: horizontal, vertical, or null for both.
  final Axis? axis;
  /// Receives the index that keyboard navigation just focused, before
  /// [onSelected] proposes it. A controlled parent may reject the proposal.
  final ValueChanged<int>? onFocusMoved;

  /// Creates a roving-keyboard-focus selection group.
  ///
  /// [selectedIndex] selects the Tab stop, [enabled] specifies each item enabled state, and [onSelected]
  /// receives the chosen index. [builder] receives owned [FocusNode]s; [axis] limits arrow navigation
  /// (null accepts both axes). [revealOnMove] defaults to true.
  const SeedChoiceGroup({
    super.key,
    required this.selectedIndex,
    required this.enabled,
    required this.onSelected,
    this.revealOnMove = true,
    required this.builder,
    this.axis,
    this.onFocusMoved,
  });

  /// Creates the state that owns focus nodes and handles roving keyboard selection.
  @override
  State<SeedChoiceGroup> createState() => _SeedChoiceGroupState();
}

class _SeedChoiceGroupState extends State<SeedChoiceGroup> {
  final List<FocusNode> _nodes = [];

  @override
  void dispose() {
    for (final node in _nodes) {
      node.dispose();
    }
    super.dispose();
  }

  KeyEventResult _onKey(FocusNode _, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final current = _nodes.indexWhere((node) => node.hasPrimaryFocus);
    if (current < 0) return KeyEventResult.ignored;
    final key = event.logicalKey;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final allowHorizontal =
        widget.axis == null || widget.axis == Axis.horizontal;
    final allowVertical = widget.axis == null || widget.axis == Axis.vertical;
    final forward =
        (allowVertical && key == LogicalKeyboardKey.arrowDown) ||
        (allowHorizontal &&
            key ==
                (rtl
                    ? LogicalKeyboardKey.arrowLeft
                    : LogicalKeyboardKey.arrowRight));
    final backward =
        (allowVertical && key == LogicalKeyboardKey.arrowUp) ||
        (allowHorizontal &&
            key ==
                (rtl
                    ? LogicalKeyboardKey.arrowRight
                    : LogicalKeyboardKey.arrowLeft));
    if (!forward &&
        !backward &&
        key != LogicalKeyboardKey.home &&
        key != LogicalKeyboardKey.end) {
      return KeyEventResult.ignored;
    }
    var next = key == LogicalKeyboardKey.home
        ? -1
        : key == LogicalKeyboardKey.end
        ? 0
        : current;
    final direction = key == LogicalKeyboardKey.end || backward ? -1 : 1;
    for (var i = 0; i < _nodes.length; i++) {
      next = (next + direction) % _nodes.length;
      if (widget.enabled[next]) {
        _nodes[next].requestFocus();
        if (widget.revealOnMove) {
          Scrollable.ensureVisible(_nodes[next].context!);
        }
        widget.onFocusMoved?.call(next);
        widget.onSelected(next);
        break;
      }
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    while (_nodes.length < widget.enabled.length) {
      _nodes.add(FocusNode());
    }
    while (_nodes.length > widget.enabled.length) {
      final retired = _nodes.removeLast();
      WidgetsBinding.instance.addPostFrameCallback((_) => retired.dispose());
    }
    final entry =
        widget.selectedIndex >= 0 &&
            widget.selectedIndex < _nodes.length &&
            widget.enabled[widget.selectedIndex]
        ? widget.selectedIndex
        : widget.enabled.indexOf(true);
    for (var i = 0; i < _nodes.length; i++) {
      _nodes[i].skipTraversal = i != entry;
    }
    return FocusTraversalGroup(
      child: Focus(
        canRequestFocus: false,
        onKeyEvent: _onKey,
        child: widget.builder(context, _nodes),
      ),
    );
  }
}
