import '../../localization/seed_localizations.dart';

import 'dart:async';
import 'dart:ui' show SemanticsRole;

import 'package:flutter/services.dart';

import 'package:material_ui/material_ui.dart';

import '../../foundations/colors/seed_color_scheme.dart';
import '../../foundations/colors/seed_palette.dart';
import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../foundations/typography/seed_typography.dart';
import '../../theme/seed_theme.dart';
import '../feedback/seed_help_bubble.dart';
import '../overlay/seed_anchored_overlay.dart';
import '../badge/seed_badge.dart';
import '../layout/seed_divider.dart';
import '../layout/seed_scroll_fog.dart';

/// Surface tone for [SeedSideNavigation].
enum SeedSideNavTone {
  neutral,
  transparent,
}

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
    // Only a newly selected item reveals its parent. Rebuilds must not reopen a
    // parent the user closed.
    if (oldWidget.selectedId != widget.selectedId) _expandSelectedParent();
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
                  // The official trigger floats over a 64px header.
                  Stack(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 64),
                          child: Padding(
                            padding: EdgeInsetsDirectional.only(
                              start: SeedDimension.x2,
                              top: SeedDimension.x2,
                              bottom: SeedDimension.x2,
                              end: hasCollapseTrigger
                                  ? SeedDimension.x13
                                  : SeedDimension.x2,
                            ),
                            child: Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: !_collapsed && widget.header != null
                                  ? widget.header!
                                  : const SizedBox.shrink(),
                            ),
                          ),
                        ),
                      ),
                      if (hasCollapseTrigger)
                        PositionedDirectional(
                          top: SeedDimension.x3,
                          end: _collapsed ? SeedDimension.x2 : SeedDimension.x3,
                          child: Tooltip(
                            message: SeedLocalizations.label(
                              context,
                              _collapsed
                                  ? SeedLabel.openSideNavigation
                                  : SeedLabel.closeSideNavigation,
                            ),
                            child: SeedPressable(
                              enableScale: false,
                              focusRingInside: true,
                              focusBorderRadius: SeedBorderRadius.r2,
                              semanticsLabel: SeedLocalizations.label(
                                context,
                                _collapsed
                                    ? SeedLabel.openSideNavigation
                                    : SeedLabel.closeSideNavigation,
                              ),
                              onTap: _handleToggleCollapse,
                              builder: (context, isEngaged) => Container(
                                width: SeedDimension.x10,
                                height: SeedDimension.x10,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isEngaged
                                      ? colors.bg.transparentPressed
                                      : colors.bg.transparent,
                                  borderRadius: SeedBorderRadius.r2,
                                ),
                                child: Icon(
                                  _collapsed ? Icons.menu : Icons.menu_open,
                                  color: colors.fg.neutralSubtle,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                // Scrollable navigation content
                Expanded(
                  child: Stack(
                    children: [
                      ListView.separated(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
                        itemCount: widget.groups.length,
                        separatorBuilder: (_, _) =>
                            SizedBox(height: _collapsed ? 0 : SeedDimension.x2),
                        itemBuilder: (context, groupIndex) {
                          final group = widget.groups[groupIndex];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (group.label != null)
                                _SeedSideNavPanel(
                                  expanded: !_collapsed,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: SeedDimension.x1_5,
                                    ),
                                    child: Text(
                                      group.label!,
                                      maxLines: 1,
                                      softWrap: false,
                                      overflow: TextOverflow.ellipsis,
                                      style: typography.t4Bold.copyWith(
                                        color: colors.fg.neutralMuted,
                                      ),
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
                if (widget.footer != null)
                  Padding(
                    padding: const EdgeInsets.all(SeedDimension.x2),
                    child: widget.footer!,
                  ),
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
    final inactiveIconColor = colors.isDark
        ? SeedPalette.gray600Dark
        : SeedPalette.gray600Light;

    if (_collapsed) {
      // React marks a collapsed parent as current when a child is selected.
      final isCurrent =
          isSelected ||
          (item.subItems?.any((sub) => sub.id == widget.selectedId) ?? false);
      Widget surface(bool isEngaged) => _SeedSideNavItemSurface(
        selected: isCurrent,
        engaged: isEngaged,
        alignment: Alignment.center,
        child: Icon(
          item.icon ?? Icons.circle_outlined,
          size: 20,
          color: !isItemEnabled
              ? colors.fg.disabled
              : (isCurrent ? colors.fg.neutral : inactiveIconColor),
        ),
      );
      if (hasSubItems && isItemEnabled) {
        return _SeedCollapsedSubmenu(
          item: item,
          selected: isCurrent,
          selectedId: widget.selectedId,
          collapsedWidth: widget.collapsedWidth,
          surfaceBuilder: surface,
        );
      }
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: SeedDimension.x2),
        child: SeedHelpBubbleTooltip(
          title: item.label,
          side: SeedOverlaySide.right,
          child: SeedPressable(
            enabled: isItemEnabled,
            enableScale: false,
            selected: isCurrent,
            semanticsLabel: item.label,
            focusRingInside: true,
            focusBorderRadius: SeedBorderRadius.r2_5,
            onTap: item.onTap ?? () {},
            builder: (context, isEngaged) => surface(isEngaged),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: SeedDimension.x2),
          child: SeedPressable(
            enabled: isItemEnabled,
            enableScale: false,
            selected: isSelected,
            expanded: hasSubItems ? isExpanded : null,
            focusRingInside: true,
            focusBorderRadius: SeedBorderRadius.r2_5,
            onTap: () {
              if (hasSubItems) {
                _toggleExpand(item);
              } else {
                item.onTap?.call();
              }
            },
            builder: (context, isEngaged) => _SeedSideNavItemSurface(
              selected: isSelected,
              engaged: isEngaged,
              padding: const EdgeInsets.symmetric(
                horizontal: SeedDimension.x2,
                vertical: SeedDimension.x3,
              ),
              child: Row(
                children: [
                  if (item.icon != null) ...[
                    Icon(
                      item.icon,
                      size: 20,
                      color: !isItemEnabled
                          ? colors.fg.disabled
                          : (isSelected
                                ? colors.fg.neutral
                                : inactiveIconColor),
                    ),
                    const SizedBox(width: SeedDimension.x3),
                  ] else
                    // React's label always reserves the icon column and gap.
                    const SizedBox(width: SeedDimension.x8),
                  Expanded(
                    child: Text(
                      item.label,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
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
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: 16,
                        color: !isItemEnabled
                            ? colors.fg.disabled
                            : colors.fg.neutralSubtle,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        // Sub items
        if (hasSubItems)
          _SeedSideNavPanel(
            expanded: isExpanded,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: item.subItems!.map((sub) {
                final isSubSelected = sub.id == widget.selectedId;
                final isSubEnabled = isItemEnabled && sub.isEnabled;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SeedDimension.x2,
                  ),
                  child: SeedPressable(
                    enabled: isSubEnabled,
                    enableScale: false,
                    selected: isSubSelected,
                    focusRingInside: true,
                    focusBorderRadius: SeedBorderRadius.r2_5,
                    onTap: sub.onTap ?? () {},
                    builder: (context, isEngaged) => _SeedSideNavItemSurface(
                      selected: isSubSelected,
                      engaged: isEngaged,
                      padding: const EdgeInsets.only(
                        left: SeedDimension.x10,
                        right: SeedDimension.x3,
                        top: SeedDimension.x1_5,
                        bottom: SeedDimension.x1_5,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              sub.label,
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
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
              }).toList(),
            ),
          ),
      ],
    );
  }
}

class _SeedSideNavPanel extends StatefulWidget {
  const _SeedSideNavPanel({required this.expanded, required this.child});
  final bool expanded;
  final Widget child;

  @override
  State<_SeedSideNavPanel> createState() => _SeedSideNavPanelState();
}

class _SeedSideNavPanelState extends State<_SeedSideNavPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
    value: widget.expanded ? 1 : 0,
  );
  late final Animation<double> _size = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  );

  @override
  void didUpdateWidget(_SeedSideNavPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expanded == oldWidget.expanded) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = widget.expanded ? 1 : 0;
    } else if (widget.expanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, child) => _controller.isDismissed
        ? const SizedBox.shrink()
        : SizeTransition(
            sizeFactor: _size,
            alignment: AlignmentDirectional.topStart,
            child: child,
          ),
    child: widget.child,
  );
}

class _SeedSideNavItemSurface extends StatelessWidget {
  const _SeedSideNavItemSurface({
    required this.selected,
    required this.engaged,
    required this.child,
    this.padding,
    this.alignment,
  });
  final bool selected, engaged;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry? alignment;

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      constraints: const BoxConstraints(minHeight: 44),
      padding: padding,
      alignment: alignment,
      decoration: BoxDecoration(
        color: selected
            ? (engaged
                  ? colors.bg.transparentSelectedPressed
                  : colors.bg.transparentSelected)
            : (engaged ? colors.bg.transparentPressed : colors.bg.transparent),
        borderRadius: SeedBorderRadius.r2_5,
      ),
      child: child,
    );
  }
}

class _SeedCollapsedSubmenu extends StatefulWidget {
  const _SeedCollapsedSubmenu({
    required this.item,
    required this.selected,
    required this.selectedId,
    required this.collapsedWidth,
    required this.surfaceBuilder,
  });
  final SeedSideNavItem item;
  final bool selected;
  final String? selectedId;
  final double collapsedWidth;
  final Widget Function(bool isEngaged) surfaceBuilder;
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
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;
    return MenuAnchor(
      controller: _menu,
      childFocusNode: _trigger,
      crossAxisUnconstrained: false,
      style: MenuStyle(
        visualDensity: VisualDensity.standard,
        backgroundColor: WidgetStatePropertyAll(colors.bg.layerFloating),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        minimumSize: const WidgetStatePropertyAll(Size(240, 0)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(vertical: SeedDimension.x2),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: SeedBorderRadius.r5),
        ),
      ),
      onClose: () {
        _restoring = true;
        WidgetsBinding.instance.addPostFrameCallback((_) => _restoring = false);
      },
      alignmentOffset: Offset(widget.collapsedWidth, -44),
      menuChildren: [
        _region(
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SeedDimension.x4,
              vertical: SeedDimension.x2_5,
            ),
            child: Text(
              widget.item.label,
              style: typography.t4Medium.copyWith(
                color: colors.fg.neutralSubtle,
              ),
            ),
          ),
        ),
        for (final sub in widget.item.subItems!)
          _region(
            Semantics(
              selected: sub.id == widget.selectedId,
              child: MenuItemButton(
                focusNode: _items.putIfAbsent(sub.id, FocusNode.new),
                style: ButtonStyle(
                  visualDensity: VisualDensity.standard,
                  padding: const WidgetStatePropertyAll(
                    EdgeInsets.symmetric(
                      horizontal: SeedDimension.x4,
                      vertical: SeedDimension.x3,
                    ),
                  ),
                  minimumSize: const WidgetStatePropertyAll(Size.zero),
                  backgroundColor: WidgetStatePropertyAll(
                    sub.id == widget.selectedId
                        ? colors.bg.transparentSelected
                        : colors.bg.transparent,
                  ),
                  overlayColor: WidgetStatePropertyAll(
                    colors.bg.transparentPressed,
                  ),
                  shape: const WidgetStatePropertyAll(
                    RoundedRectangleBorder(borderRadius: SeedBorderRadius.r3),
                  ),
                ),
                onPressed: sub.isEnabled ? sub.onTap : null,
                child: Text(
                  sub.label,
                  style: typography.t5Regular.copyWith(
                    color: sub.isEnabled
                        ? colors.fg.neutral
                        : colors.fg.disabled,
                  ),
                ),
              ),
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
          // React sets disableTooltip here: the flyout already shows the label.
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: SeedDimension.x2),
            child: SeedPressable(
              focusNode: _trigger,
              enableScale: false,
              selected: widget.selected,
              semanticsLabel: widget.item.label,
              expanded: _menu.isOpen,
              focusRingInside: true,
              focusBorderRadius: SeedBorderRadius.r2_5,
              onTap: _focusFirst,
              builder: (context, isEngaged) => widget.surfaceBuilder(isEngaged),
            ),
          ),
        ),
      ),
    );
  }
}
