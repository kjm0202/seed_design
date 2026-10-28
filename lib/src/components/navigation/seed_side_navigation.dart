import 'dart:async';
import 'dart:ui' show SemanticsRole;

import 'package:flutter/services.dart';

import 'package:material_ui/material_ui.dart';

import '../../foundations/colors/seed_color_scheme.dart';
import '../../foundations/colors/seed_palette.dart';
import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../foundations/typography/seed_typography.dart';
import '../../theme/seed_theme.dart';
import '../badge/seed_badge.dart';
import '../layout/seed_divider.dart';
import '../layout/seed_scroll_fog.dart';

/// Surface tone for [SeedSideNavigation].
enum SeedSideNavTone { neutral, transparent }

/// A 2nd-level sub item in [SeedSideNavigation].
class SeedSideNavSubItem {
  const SeedSideNavSubItem({
    required this.id,
    required this.label,
    this.badge,
    this.onTap,
    this.enabled = true,
    this.disabled = false,
  });

  final String id;
  final String label;
  final String? badge;
  final VoidCallback? onTap;
  final bool enabled;
  final bool disabled;

  bool get isEnabled => enabled && !disabled;
}

/// A 1st-level menu item in [SeedSideNavigation].
class SeedSideNavItem {
  const SeedSideNavItem({
    required this.id,
    required this.label,
    this.icon,
    this.badge,
    this.subItems,
    this.onTap,
    this.enabled = true,
    this.disabled = false,
    this.open,
    this.defaultOpen = false,
    ValueChanged<bool>? onOpenChange,
    @Deprecated('Use onOpenChange instead.') ValueChanged<bool>? onOpenChanged,
  }) : onOpenChanged = onOpenChange ?? onOpenChanged,
       assert(onOpenChange == null || onOpenChanged == null);

  final String id;
  final String label;
  final IconData? icon;
  final String? badge;
  final List<SeedSideNavSubItem>? subItems;
  final VoidCallback? onTap;
  final bool enabled;
  final bool disabled;
  final bool? open;
  final bool defaultOpen;
  @Deprecated('Use onOpenChange instead.')
  final ValueChanged<bool>? onOpenChanged;
  ValueChanged<bool>? get onOpenChange => onOpenChanged;

  bool get isEnabled => enabled && !disabled;
}

/// A group of items in [SeedSideNavigation].
class SeedSideNavGroup {
  const SeedSideNavGroup({this.label, required this.items});

  final String? label;
  final List<SeedSideNavItem> items;
}

/// A SEED Design Side Navigation drawer/sidebar component for desktop and tablet.
class SeedSideNavigation extends StatefulWidget {
  const SeedSideNavigation({
    super.key,
    this.header,
    this.footer,
    required this.groups,
    this.selectedId,
    bool? collapsed,
    @Deprecated('Use collapsed instead.') bool? isCollapsed,
    this.defaultCollapsed = false,
    this.onToggleCollapsed,
    ValueChanged<bool>? onCollapsedChange,
    @Deprecated('Use onCollapsedChange instead.')
    ValueChanged<bool>? onCollapsedChanged,
    this.showCollapseButton = false,
    this.width = 240.0,
    this.collapsedWidth = 56.0,
    this.tone = SeedSideNavTone.neutral,
    this.backgroundColor,
    this.collapseBelow,
    // ignore: prefer_initializing_formals
  }) : _isCollapsed = collapsed ?? isCollapsed,
       onCollapsedChanged = onCollapsedChange ?? onCollapsedChanged,
       assert(collapsed == null || isCollapsed == null),
       assert(onCollapsedChange == null || onCollapsedChanged == null);

  /// Header widget (brand logo, user profile, workspace switcher).
  final Widget? header;

  /// Footer widget (external links, settings, help).
  final Widget? footer;

  /// Navigation item groups.
  final List<SeedSideNavGroup> groups;

  /// The currently active item or sub-item ID.
  final String? selectedId;

  final bool? _isCollapsed;

  /// Initial collapsed state when [isCollapsed] is omitted.
  final bool defaultCollapsed;

  /// Whether the sidebar is collapsed to icon-only mode.
  bool? get collapsed => _isCollapsed;
  @Deprecated('Use collapsed or defaultCollapsed instead.')
  bool get isCollapsed => _isCollapsed ?? defaultCollapsed;

  /// Callback when collapse toggle is clicked.
  final VoidCallback? onToggleCollapsed;

  /// Callback with the next collapsed state when toggled.
  @Deprecated('Use onCollapsedChange instead.')
  final ValueChanged<bool>? onCollapsedChanged;
  ValueChanged<bool>? get onCollapsedChange => onCollapsedChanged;

  /// Whether to show the built-in collapse toggle button even without [onToggleCollapsed].
  final bool showCollapseButton;

  /// Width when expanded. Defaults to 240.
  final double width;

  /// Width when collapsed. Defaults to 56.
  final double collapsedWidth;

  /// Surface tone of the sidebar (`neutral` or `transparent`).
  final SeedSideNavTone tone;

  final Color? backgroundColor;
  final double? collapseBelow;

  @override
  State<SeedSideNavigation> createState() => _SeedSideNavigationState();
}

class _SeedSideNavigationState extends State<SeedSideNavigation> {
  final Set<String> _expandedItemIds = {};
  final ScrollController _scrollController = ScrollController();
  late bool _uncontrolledCollapsed = widget.defaultCollapsed;
  bool _scrolled = false;

  bool get _collapsed =>
      (widget._isCollapsed ?? _uncontrolledCollapsed) ||
      (widget.collapseBelow != null &&
          MediaQuery.sizeOf(context).width < widget.collapseBelow!);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrolled);
    _initExpandedItems();
  }

  @override
  void didUpdateWidget(SeedSideNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    _expandSelectedParent();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrolled);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrolled() {
    final next = _scrollController.hasClients && _scrollController.offset > 0;
    if (_scrolled != next && mounted) {
      setState(() => _scrolled = next);
    }
  }

  void _initExpandedItems() {
    for (final group in widget.groups) {
      for (final item in group.items) {
        if (item.defaultOpen) {
          _expandedItemIds.add(item.id);
        }
      }
    }
    _expandSelectedParent();
  }

  void _expandSelectedParent() {
    for (final group in widget.groups) {
      for (final item in group.items) {
        if (item.subItems?.any((sub) => sub.id == widget.selectedId) ?? false) {
          _expandedItemIds.add(item.id);
        }
      }
    }
  }

  bool _isItemExpanded(SeedSideNavItem item) =>
      item.open ?? _expandedItemIds.contains(item.id);

  void _toggleExpand(SeedSideNavItem item) {
    if (!item.isEnabled) return;
    final next = !_isItemExpanded(item);
    if (item.open == null) {
      setState(() {
        if (next) {
          _expandedItemIds.add(item.id);
        } else {
          _expandedItemIds.remove(item.id);
        }
      });
    }
    item.onOpenChanged?.call(next);
  }

  void _handleToggleCollapse() {
    final next = !_collapsed;
    if (widget._isCollapsed == null) {
      setState(() => _uncontrolledCollapsed = next);
    }
    widget.onToggleCollapsed?.call();
    widget.onCollapsedChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;
    final currentWidth = _collapsed ? widget.collapsedWidth : widget.width;
    final hasCollapseTrigger =
        widget.onToggleCollapsed != null ||
        widget.onCollapsedChanged != null ||
        widget.showCollapseButton;
    final effectiveBgColor =
        widget.backgroundColor ??
        (widget.tone == SeedSideNavTone.transparent
            ? Colors.transparent
            : (colors.isDark
                  ? SeedPalette.gray100Dark
                  : SeedPalette.gray100Light));

    return Semantics(
      container: true,
      role: SemanticsRole.navigation,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: currentWidth,
        decoration: BoxDecoration(
          color: effectiveBgColor,
          border:
              widget.tone == SeedSideNavTone.transparent &&
                  widget.backgroundColor == null
              ? null
              : Border(right: BorderSide(color: colors.stroke.neutralMuted)),
        ),
        child: ClipRect(
          child: OverflowBox(
            alignment: AlignmentDirectional.centerStart,
            minWidth: currentWidth - 1,
            maxWidth: currentWidth - 1,
            child: Column(
              children: [
                // Header & Collapse trigger
                if (widget.header != null || hasCollapseTrigger)
                  Padding(
                    padding: const EdgeInsets.all(SeedDimension.x2),
                    child: Row(
                      mainAxisAlignment: _collapsed
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.end,
                      children: [
                        if (!_collapsed && widget.header != null)
                          Expanded(child: widget.header!),
                        if (hasCollapseTrigger)
                          SizedBox(
                            width: 39,
                            height: 40,
                            child: IconButton(
                              tooltip: _collapsed ? '펼치기' : '접기',
                              constraints: const BoxConstraints.tightFor(
                                width: 39,
                                height: 40,
                              ),
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                _collapsed ? Icons.menu : Icons.menu_open,
                                color: colors.fg.neutralSubtle,
                                size: 20,
                              ),
                              onPressed: _handleToggleCollapse,
                              splashRadius: 18,
                            ),
                          ),
                      ],
                    ),
                  ),

                if (widget.header != null) const SeedDivider(),

                // Scrollable navigation content
                Expanded(
                  child: Stack(
                    children: [
                      ListView.separated(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
                        itemCount: widget.groups.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: SeedDimension.x2),
                        itemBuilder: (context, groupIndex) {
                          final group = widget.groups[groupIndex];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!_collapsed && group.label != null)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: SeedDimension.x4,
                                    vertical: SeedDimension.x1,
                                  ),
                                  child: Text(
                                    group.label!,
                                    style: typography.t4Bold.copyWith(
                                      color: colors.fg.neutralMuted,
                                    ),
                                  ),
                                ),
                              ...group.items.map(
                                (item) => _buildMenuItem(
                                  context,
                                  item,
                                  colors,
                                  typography,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      if (_scrolled)
                        const Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: SeedDivider(
                            key: ValueKey('seed-side-nav-scroll-divider'),
                          ),
                        ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: SeedScrollFog(
                          placement: SeedScrollFogPlacement.bottom,
                          size: 24,
                          color: effectiveBgColor == Colors.transparent
                              ? colors.bg.layerDefault
                              : effectiveBgColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Footer
                if (widget.footer != null) ...[
                  const SeedDivider(),
                  Padding(
                    padding: const EdgeInsets.all(SeedDimension.x2),
                    child: widget.footer!,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    SeedSideNavItem item,
    SeedColorScheme colors,
    SeedTypography typography,
  ) {
    final isSelected = item.id == widget.selectedId;
    final hasSubItems = item.subItems != null && item.subItems!.isNotEmpty;
    final isExpanded = _isItemExpanded(item);
    final isItemEnabled = item.isEnabled;

    if (_collapsed) {
      final icon = SizedBox(
        height: 44,
        width: widget.collapsedWidth,
        child: Icon(
          item.icon ?? Icons.circle_outlined,
          size: 20,
          color: !isItemEnabled ? colors.fg.disabled : colors.fg.neutral,
        ),
      );
      if (hasSubItems && isItemEnabled) {
        return _SeedCollapsedSubmenu(
          item: item,
          selectedId: widget.selectedId,
          collapsedWidth: widget.collapsedWidth,
          child: icon,
        );
      }
      return Semantics(
        container: true,
        button: true,
        selected: isSelected,
        enabled: isItemEnabled,
        child: Tooltip(
          message: item.label,
          child: InkWell(onTap: isItemEnabled ? item.onTap : null, child: icon),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          container: true,
          button: true,
          selected: isSelected,
          enabled: isItemEnabled,
          expanded: hasSubItems ? isExpanded : null,
          child: InkWell(
            borderRadius: SeedBorderRadius.r2_5,
            overlayColor: WidgetStatePropertyAll(
              isSelected
                  ? colors.bg.transparentSelectedPressed
                  : colors.bg.transparentPressed,
            ),
            onTap: isItemEnabled
                ? () {
                    if (hasSubItems) {
                      _toggleExpand(item);
                    } else {
                      item.onTap?.call();
                    }
                  }
                : null,
            child: Container(
              constraints: const BoxConstraints(minHeight: 44),
              margin: const EdgeInsets.symmetric(
                horizontal: SeedDimension.x2,
                vertical: 0,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: _collapsed ? 10 : 8,
                vertical: SeedDimension.x3,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? colors.bg.transparentSelected
                    : Colors.transparent,
                borderRadius: SeedBorderRadius.r2_5,
              ),
              child: Row(
                mainAxisAlignment: _collapsed
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  if (item.icon != null)
                    Icon(
                      item.icon,
                      size: 20,
                      color: !isItemEnabled
                          ? colors.fg.disabled
                          : (isSelected
                                ? colors.fg.neutral
                                : (colors.isDark
                                      ? SeedPalette.gray600Dark
                                      : SeedPalette.gray600Light)),
                    ),
                  if (!_collapsed) ...[
                    if (item.icon != null)
                      const SizedBox(width: SeedDimension.x3),
                    Expanded(
                      child: Text(
                        item.label,
                        style: typography.t4Medium.copyWith(
                          color: !isItemEnabled
                              ? colors.fg.disabled
                              : (isSelected
                                    ? colors.fg.neutral
                                    : colors.fg.neutralMuted),
                        ),
                      ),
                    ),
                    if (item.badge != null) ...[
                      SeedBadge(
                        label: item.badge!,
                        tone: isSelected
                            ? SeedBadgeTone.brand
                            : SeedBadgeTone.neutral,
                      ),
                      const SizedBox(width: SeedDimension.x1),
                    ],
                    if (hasSubItems)
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 16,
                        color: !isItemEnabled
                            ? colors.fg.disabled
                            : colors.fg.neutralSubtle,
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),

        // Sub items
        if (!_collapsed && hasSubItems && isExpanded)
          ...item.subItems!.map((sub) {
            final isSubSelected = sub.id == widget.selectedId;
            final isSubEnabled = isItemEnabled && sub.isEnabled;
            return Semantics(
              container: true,
              button: true,
              selected: isSubSelected,
              enabled: isSubEnabled,
              child: InkWell(
                borderRadius: SeedBorderRadius.r2_5,
                overlayColor: WidgetStatePropertyAll(
                  isSubSelected
                      ? colors.bg.transparentSelectedPressed
                      : colors.bg.transparentPressed,
                ),
                onTap: isSubEnabled ? sub.onTap : null,
                child: Container(
                  constraints: const BoxConstraints(minHeight: 44),
                  margin: const EdgeInsets.symmetric(
                    horizontal: SeedDimension.x2,
                    vertical: 0,
                  ),
                  padding: const EdgeInsets.only(
                    left: SeedDimension.x10,
                    right: SeedDimension.x3,
                    top: SeedDimension.x1_5,
                    bottom: SeedDimension.x1_5,
                  ),
                  decoration: BoxDecoration(
                    color: isSubSelected
                        ? colors.bg.transparentSelected
                        : Colors.transparent,
                    borderRadius: SeedBorderRadius.r2_5,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          sub.label,
                          style: typography.t4Medium.copyWith(
                            color: !isSubEnabled
                                ? colors.fg.disabled
                                : (isSubSelected
                                      ? colors.fg.neutral
                                      : colors.fg.neutralMuted),
                          ),
                        ),
                      ),
                      if (sub.badge != null)
                        SeedBadge(
                          label: sub.badge!,
                          tone: isSubSelected
                              ? SeedBadgeTone.brand
                              : SeedBadgeTone.neutral,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}

class _SeedCollapsedSubmenu extends StatefulWidget {
  const _SeedCollapsedSubmenu({
    required this.item,
    required this.selectedId,
    required this.collapsedWidth,
    required this.child,
  });
  final SeedSideNavItem item;
  final String? selectedId;
  final double collapsedWidth;
  final Widget child;
  @override
  State<_SeedCollapsedSubmenu> createState() => _SeedCollapsedSubmenuState();
}

class _SeedCollapsedSubmenuState extends State<_SeedCollapsedSubmenu> {
  final MenuController _menu = MenuController();
  final FocusNode _trigger = FocusNode();
  final Map<String, FocusNode> _items = {};
  bool _restoring = false;
  void _focusFirst() {
    _enter();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _items.values.firstOrNull?.requestFocus();
    });
  }

  Timer? _timer;
  void _enter() {
    _timer?.cancel();
    if (!_menu.isOpen) _menu.open();
  }

  void _exit() {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 160), () {
      if (mounted) _menu.close();
    });
  }

  Widget _region(Widget child) => MouseRegion(
    onEnter: (_) => _enter(),
    onExit: (_) => _exit(),
    child: child,
  );
  @override
  void dispose() {
    _timer?.cancel();
    _trigger.dispose();
    for (final node in _items.values) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MenuAnchor(
    controller: _menu,
    childFocusNode: _trigger,
    onClose: () {
      _restoring = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _restoring = false);
    },
    alignmentOffset: Offset(widget.collapsedWidth, -44),
    menuChildren: [
      for (final sub in widget.item.subItems!)
        _region(
          MenuItemButton(
            focusNode: _items.putIfAbsent(sub.id, FocusNode.new),
            leadingIcon: sub.id == widget.selectedId
                ? const Icon(Icons.check)
                : null,
            onPressed: sub.isEnabled ? sub.onTap : null,
            child: Text(sub.label),
          ),
        ),
    ],
    builder: (context, controller, child) => _region(
      Focus(
        canRequestFocus: false,
        onKeyEvent: (_, event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.arrowDown) {
            _focusFirst();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        onFocusChange: (focused) {
          if (focused && !_restoring) {
            _enter();
          }
        },
        child: Tooltip(
          message: widget.item.label,
          child: InkWell(
            focusNode: _trigger,
            onTap: _focusFirst,
            child: widget.child,
          ),
        ),
      ),
    ),
  );
}
