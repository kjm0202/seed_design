import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

/// Internal keyboard policy shared by tabs, segments and bottom navigation.
/// Only the selected choice is in the Tab order; arrows wrap and skip disabled
/// items. Focus and selection always move together.
class SeedChoiceGroup extends StatefulWidget {
  final int selectedIndex;
  final List<bool> enabled;
  final ValueChanged<int> onSelected;
  final Widget Function(BuildContext, List<FocusNode>) builder;

  const SeedChoiceGroup({
    super.key,
    required this.selectedIndex,
    required this.enabled,
    required this.onSelected,
    required this.builder,
  });

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
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final current = _nodes.indexWhere((node) => node.hasPrimaryFocus);
    if (current < 0) return KeyEventResult.ignored;
    final key = event.logicalKey;
    final rtl = Directionality.of(context) == TextDirection.rtl;
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
        Scrollable.ensureVisible(_nodes[next].context!);
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
