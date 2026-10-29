import 'dart:async';

import 'dart:ui' show SemanticsRole;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import 'seed_anchored_overlay.dart';

import '../../foundations/colors/seed_color_scheme.dart';
import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../foundations/typography/seed_typography.dart';
import '../../theme/seed_theme.dart';
import '../badge/seed_badge.dart';
import '../layout/seed_divider.dart';

enum SeedMenuSize { small, medium, responsive }

/// An individual action or selectable item in [SeedMenu].
class SeedMenuItemData {
  const SeedMenuItemData({
    required this.label,
    this.description,
    this.typeaheadLabel,
    this.prefixIcon,
    this.suffixIcon,
    this.badge,
    this.onTap,
    this.isDestructive = false,
    this.enabled = true,
  });

  final String label;
  final String? description;

  /// Search text for keyboard navigation; defaults to [label].
  final String? typeaheadLabel;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? badge;
  final VoidCallback? onTap;
  final bool isDestructive;
  final bool enabled;
}

/// A group of items in [SeedMenu].
class SeedMenuGroupData {
  const SeedMenuGroupData({this.label, required this.items});

  final String? label;
  final List<SeedMenuItemData> items;
}

/// A SEED Design Menu component providing a list of actions or options.
class SeedMenu extends StatefulWidget {
  const SeedMenu({
    super.key,
    required this.groups,
    this.width,
    this.size = SeedMenuSize.medium,
    this.closeOnSelect = true,
    this.maxHeight = 480,
  });
  final SeedMenuSize size;
  final bool closeOnSelect;
  final double maxHeight;

  /// The groups of items in the menu.
  final List<SeedMenuGroupData> groups;

  /// Width of the menu container.
  final double? width;

  @override
  State<SeedMenu> createState() => _SeedMenuState();
}

class _SeedMenuState extends State<SeedMenu> {
  final List<FocusNode> _nodes = [];
  String _search = '';
  Timer? _searchReset;
  List<SeedMenuItemData> get _items =>
      widget.groups.expand((group) => group.items).toList();
  SeedMenuSize get size => widget.size == SeedMenuSize.responsive
      ? (MediaQuery.sizeOf(context).width >= 1280
            ? SeedMenuSize.small
            : SeedMenuSize.medium)
      : widget.size;

  @override
  void initState() {
    super.initState();
    // The overlay itself initially receives keyboard focus. Advance it to the
    // first enabled action, matching React Menu's list-navigation entry point.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || SeedOverlayScope.maybeOf(context)?.isOpen != true) return;
      final index = _items.indexWhere((item) => item.enabled);
      if (index >= 0 && index < _nodes.length) {
        _nodes[index].requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _searchReset?.cancel();
    for (final node in _nodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _move(int delta, {bool edge = false}) {
    final items = _items;
    final enabled = [
      for (var i = 0; i < items.length; i++)
        if (items[i].enabled) i,
    ];
    if (enabled.isEmpty) return;
    final current = enabled.indexWhere((i) => _nodes[i].hasFocus);
    final index = edge
        ? (delta > 0 ? enabled.first : enabled.last)
        : enabled[(current < 0
                  ? (delta > 0 ? 0 : enabled.length - 1)
                  : current + delta) %
              enabled.length];
    _nodes[index].requestFocus();
    final target = _nodes[index].context;
    if (target != null) Scrollable.ensureVisible(target);
  }

  KeyEventResult _typeahead(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent ||
        HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed ||
        HardwareKeyboard.instance.isAltPressed) {
      return KeyEventResult.ignored;
    }
    final character = event.character?.toLowerCase();
    if (character == null || character.trim().isEmpty) {
      return KeyEventResult.ignored;
    }
    _searchReset?.cancel();
    _searchReset = Timer(const Duration(milliseconds: 500), () => _search = '');
    _search += character;
    // Repeated characters cycle through items with the same initial.
    final query = _search.split('').every((c) => c == character)
        ? character
        : _search;
    final items = _items;
    if (items.isEmpty) return KeyEventResult.ignored;
    final current = _nodes.indexWhere((node) => node.hasFocus);
    for (var step = query.length > 1 ? 0 : 1; step <= items.length; step++) {
      final index = (current + step) % items.length;
      if (items[index].enabled &&
          (items[index].typeaheadLabel ?? items[index].label)
              .toLowerCase()
              .startsWith(query)) {
        _nodes[index].requestFocus();
        final target = _nodes[index].context;
        if (target != null) Scrollable.ensureVisible(target);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;
    final shadows = context.seedShadows;

    final items = _items;
    while (_nodes.length < items.length) {
      _nodes.add(FocusNode());
    }
    while (_nodes.length > items.length) {
      _nodes.removeLast().dispose();
    }
    var itemIndex = 0;
    return Semantics(
      role: SemanticsRole.menu,
      child: Focus(
        onKeyEvent: _typeahead,
        child: Container(
          constraints: BoxConstraints(maxHeight: widget.maxHeight),
          width: widget.width ?? (size == SeedMenuSize.small ? 200 : 240),
          decoration: BoxDecoration(
            color: colors.bg.layerFloating,
            borderRadius: SeedBorderRadius.r5,
            boxShadow: shadows.s3,
          ),
          padding: const EdgeInsets.symmetric(vertical: SeedDimension.x2),
          child: CallbackShortcuts(
            bindings: {
              const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
                  _move(1),
              const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
                  _move(-1),
              const SingleActivator(LogicalKeyboardKey.home): () =>
                  _move(1, edge: true),
              const SingleActivator(LogicalKeyboardKey.end): () =>
                  _move(-1, edge: true),
            },
            child: SingleChildScrollView(
              primary: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (int g = 0; g < widget.groups.length; g++) ...[
                    if (g > 0)
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: SeedDimension.x4,
                        ),
                        child: SeedDivider(),
                      ),
                    if (widget.groups[g].label != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: SeedDimension.x4,
                          vertical: SeedDimension.x2_5,
                        ),
                        child: Text(
                          widget.groups[g].label!,
                          style:
                              (size == SeedMenuSize.small
                                      ? typography.t3Regular
                                      : typography.t4Medium)
                                  .copyWith(color: colors.fg.neutralSubtle),
                        ),
                      ),
                    ...widget.groups[g].items.map(
                      (item) => _buildMenuItem(
                        context,
                        item,
                        colors,
                        typography,
                        _nodes[itemIndex++],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    SeedMenuItemData item,
    SeedColorScheme colors,
    SeedTypography typography,
    FocusNode focusNode,
  ) {
    Color labelColor;
    if (!item.enabled) {
      labelColor = colors.fg.disabled;
    } else if (item.isDestructive) {
      labelColor = colors.fg.critical;
    } else {
      labelColor = colors.fg.neutral;
    }

    return Semantics(
      role: SemanticsRole.menuItem,
      enabled: item.enabled,
      child: InkWell(
        focusNode: focusNode,
        canRequestFocus: item.enabled,
        overlayColor: WidgetStatePropertyAll(colors.bg.transparentPressed),
        onTap: item.enabled
            ? () {
                item.onTap?.call();
                if (widget.closeOnSelect && context.mounted) {
                  SeedOverlayScope.maybeOf(context)
                      ?.close(SeedOverlayDismissReason.itemClick);
                }
              }
            : null,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: size == SeedMenuSize.small ? 10 : 12,
          ),
          child: Row(
            children: [
              if (item.prefixIcon != null) ...[
                IconTheme(
                  data: IconThemeData(
                    size: size == SeedMenuSize.small ? 18 : 22,
                    color: !item.enabled
                        ? colors.fg.disabled
                        : (item.isDestructive
                              ? colors.fg.critical
                              : colors.fg.neutral),
                  ),
                  child: item.prefixIcon!,
                ),
                SizedBox(
                  width: size == SeedMenuSize.small
                      ? SeedDimension.x2
                      : SeedDimension.x3,
                ),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.label,
                      style:
                          (size == SeedMenuSize.small
                                  ? typography.t4Regular
                                  : typography.t5Regular)
                              .copyWith(color: labelColor),
                    ),
                    if (item.description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.description!,
                        style:
                            (size == SeedMenuSize.small
                                    ? typography.t2Regular
                                    : typography.t3Regular)
                                .copyWith(
                                  color: item.enabled
                                      ? colors.fg.neutralSubtle
                                      : colors.fg.disabled,
                                ),
                      ),
                    ],
                  ],
                ),
              ),
              if (item.badge != null) ...[
                SeedBadge(
                  label: item.badge!,
                  tone: item.isDestructive
                      ? SeedBadgeTone.critical
                      : SeedBadgeTone.neutral,
                ),
                const SizedBox(width: SeedDimension.x2),
              ],
              if (item.suffixIcon != null)
                IconTheme(
                  data: IconThemeData(
                    size: size == SeedMenuSize.small ? 16 : 18,
                    color: item.enabled
                        ? (item.isDestructive
                              ? colors.fg.critical
                              : colors.fg.neutral)
                        : colors.fg.disabled,
                  ),
                  child: item.suffixIcon!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Anchored menu supporting controlled open, independent anchor and focus lifecycle.
class SeedMenuTrigger extends SeedAnchoredOverlay {
  const SeedMenuTrigger({
    super.key,
    required super.triggerBuilder,
    required WidgetBuilder builder,
    super.anchor,
    super.controller,
    super.open,
    super.defaultOpen,
    super.onOpenChange,
    @Deprecated('Use onOpenChange instead.') super.onOpenChanged,
    super.side,
    super.align,
    super.gap,
    super.overflowPadding = 8,
    super.flip,
    super.shift,
    super.maxWidth,
    super.maxHeight,
    super.skipAnimation,
  }) : super(overlayBuilder: builder);
}
