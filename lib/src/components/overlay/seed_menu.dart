import 'dart:async';

import 'dart:ui' show SemanticsRole;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import 'seed_anchored_overlay.dart';

import '../../foundations/colors/seed_color_scheme.dart';
import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
import '../../foundations/motion/seed_motion.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../foundations/typography/seed_typography.dart';
import '../../theme/seed_theme.dart';
import '../badge/seed_badge.dart';
import '../layout/seed_divider.dart';

/// Menu sizing policy: `small` is 200px, `medium` is 240px, and `responsive`
/// selects small at viewport widths of at least 1280px and medium otherwise.
enum SeedMenuSize {
  /// Compact 200px menu.
  small,
  /// Standard 240px menu.
  medium,
  /// Choose small at viewport width 1280px or more, medium otherwise.
  responsive,
}

/// An individual action or selectable item in [SeedMenu].
///
/// This immutable Flutter data object corresponds to a React Menu.Item and
/// its optional label, supporting content, and action. Disabled items are
/// omitted from keyboard traversal and cannot invoke [onTap].
class SeedMenuItemData {
  /// Creates a menu item with a required [label] and optional action.
  ///
  /// [typeaheadLabel] overrides the text matched by incremental typing;
  /// [enabled] is true and [isDestructive] is false by default.
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

  /// Visible primary label, also used for typeahead by default.
  final String label;
  /// Optional secondary line of explanatory text.
  final String? description;

  /// Search text for keyboard navigation; defaults to [label].
  final String? typeaheadLabel;
  /// Optional widget before the item label.
  final Widget? prefixIcon;
  /// Optional widget following the label.
  final Widget? suffixIcon;
  /// Optional trailing badge text.
  final String? badge;
  /// Invoked when the enabled item is activated.
  final VoidCallback? onTap;
  /// Whether the label/action uses critical styling.
  final bool isDestructive;
  /// Whether selection and keyboard focus are allowed; true by default.
  final bool enabled;
}

/// A group of items in [SeedMenu].
class SeedMenuGroupData {
  /// Creates an item group with an optional section [label].
  const SeedMenuGroupData({this.label, required this.items});

  /// Optional section heading above [items].
  final String? label;
  /// Ordered menu entries within this group.
  final List<SeedMenuItemData> items;
}

/// A SEED Design Menu component providing a list of actions or options.
///
/// Keyboard behavior follows React's menu navigation: Arrow Up/Down move
/// among enabled entries, Home/End jump to first/last, and typing searches
/// [SeedMenuItemData.typeaheadLabel] (or its label). Keyboard opening focuses
/// the first enabled item; pointer opening initially focuses the menu root.
/// Place this surface inside [SeedAnchoredOverlay] for outside/Escape handling.
class SeedMenu extends StatefulWidget {
  /// Creates a grouped menu whose [groups] provide its actions.
  ///
  /// [size] defaults to medium; [width] overrides the calculated width.
  /// [maxHeight] defaults to 480px and [closeOnSelect] defaults to true.
  const SeedMenu({
    super.key,
    required this.groups,
    this.semanticsLabel,
    this.width,
    this.size = SeedMenuSize.medium,
    this.closeOnSelect = true,
    this.maxHeight = 480,
  });
  /// Preferred menu width policy.
  final SeedMenuSize size;
  /// Whether item selection requests dismissal of its nearest overlay.
  final bool closeOnSelect;
  /// Maximum menu height before content scrolls, 480px by default.
  final double maxHeight;

  /// Accessible name for this menu, corresponding to the trigger's label
  /// (the React MenuContent aria-labelledby/aria-label contract).
  final String? semanticsLabel;

  /// The groups of items in the menu.
  final List<SeedMenuGroupData> groups;

  /// Width of the menu container.
  final double? width;

  @override
  State<SeedMenu> createState() => _SeedMenuState();
}

class _SeedMenuState extends State<SeedMenu> {
  final List<FocusNode> _nodes = [];
  final FocusNode _rootFocus = FocusNode(debugLabel: 'SeedMenu');
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
    // The overlay itself initially receives keyboard focus. As in React Menu's
    // list navigation, a keyboard open focuses the first enabled action while
    // a pointer open focuses the root, so the first arrow key lands on it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || SeedOverlayScope.maybeOf(context)?.isOpen != true) return;
      if (seedLastInputWasPointer) {
        _rootFocus.requestFocus();
        return;
      }
      final index = _items.indexWhere((item) => item.enabled);
      if (index >= 0 && index < _nodes.length) {
        _nodes[index].requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _searchReset?.cancel();
    _rootFocus.dispose();
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
      label: widget.semanticsLabel,
      // Above the root Focus so the keys also work before any item is active.
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.arrowDown): () => _move(1),
          const SingleActivator(LogicalKeyboardKey.arrowUp): () => _move(-1),
          const SingleActivator(LogicalKeyboardKey.home): () =>
              _move(1, edge: true),
          const SingleActivator(LogicalKeyboardKey.end): () =>
              _move(-1, edge: true),
        },
        child: Focus(
          focusNode: _rootFocus,
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

    return SeedPressable(
      focusNode: focusNode,
      enabled: item.enabled,
      enableScale: false,
      semanticButton: false,
      semanticsRole: SemanticsRole.menuItem,
      focusRingInside: true,
      focusBorderRadius: SeedBorderRadius.r3,
      onTap: () {
        item.onTap?.call();
        if (widget.closeOnSelect && context.mounted) {
          SeedOverlayScope.maybeOf(context)
              ?.close(SeedOverlayDismissReason.itemClick);
        }
      },
      builder: (context, engaged) => Stack(
        children: [
          // The official highlight insets from the menu while pressed.
          Positioned.fill(
            child: AnimatedContainer(
              duration: SeedDuration.d3,
              curve: SeedCurves.easing,
              margin: EdgeInsets.symmetric(
                horizontal: engaged ? SeedDimension.x2 : 0,
              ),
              decoration: BoxDecoration(
                color: engaged
                    ? colors.bg.transparentPressed
                    : colors.bg.transparent,
                borderRadius: SeedBorderRadius.r3,
              ),
            ),
          ),
          SeedContentScale(
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
        ],
      ),
    );
  }
}

/// Anchored menu supporting controlled open, independent anchor and focus lifecycle.
class SeedMenuTrigger extends SeedAnchoredOverlay {
  /// Builds a keyboard-navigable menu anchored to [triggerBuilder].
  ///
  /// [builder] creates menu content, usually [SeedMenu]. Escape and outside
  /// interaction request dismissal; [open] takes precedence over [controller].
  /// [defaultOpen] seeds local state when neither is provided. Focus may leave
  /// this menu with Tab, and its popup is mounted lazily by default.
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
  }) : super(
         overlayBuilder: builder,
         tabExitsContent: true,
         // MIN_HEIGHT in React's useMenu.
         fitMinExtent: 200,
       );
}
