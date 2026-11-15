import '../../localization/seed_localizations.dart';

import 'dart:ui' show SemanticsRole;

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
import '../overlay/seed_menu.dart' show SeedMenuSize;
import 'seed_navigation_menu.dart';

/// Surface tone for [SeedSideNavigation].
enum SeedSideNavTone {
  /// Standard neutral sidebar surface.
  neutral,

  /// Transparent sidebar surface that shows its parent background.
  transparent,
}

/// A 2nd-level sub item in [SeedSideNavigation].
class SeedSideNavSubItem {
  /// Creates a submenu destination identified by [id] and [label].
  ///
  /// [badge] supplies optional trailing status text, [onTap] runs when selected,
  /// and [enabled]/[disabled] jointly determine whether it accepts input.
  /// Both enable flags default to true/false respectively.
  const SeedSideNavSubItem({
    required this.id,
    required this.label,
    this.badge,
    this.onTap,
    this.enabled = true,
    this.disabled = false,
  });

  /// Stable submenu identity used for [SeedSideNavigation.selectedId].
  final String id;

  /// Visible and accessible destination text.
  final String label;

  /// Optional trailing status badge text.
  final String? badge;

  /// Optional activation callback for this destination.
  final VoidCallback? onTap;

  /// Positive enable flag, true by default.
  final bool enabled;

  /// Explicit disabled flag, false by default.
  final bool disabled;

  /// Effective enable state: [enabled] is true and [disabled] is false.
  bool get isEnabled => enabled && !disabled;
}

/// A 1st-level menu item in [SeedSideNavigation].
class SeedSideNavItem {
  /// Creates a top-level sidebar destination or collapsible submenu parent.
  ///
  /// [id] identifies selection, [label] names the destination, [icon] and
  /// [badge] add presentation, and [subItems] defines nested destinations.
  /// [onTap] handles direct activation; [enabled]/[disabled] gate interaction.
  /// [open] controls expanded state when non-null; [defaultOpen] initializes
  /// unmanaged expansion. [onOpenChange] receives the next expanded state;
  /// [onOpenChanged] is its deprecated compatibility alias.
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

  /// Stable item identity used by [SeedSideNavigation.selectedId].
  final String id;

  /// Visible and accessible main-menu label.
  final String label;

  /// Optional leading icon, used also in collapsed icon-only navigation.
  final IconData? icon;

  /// Optional trailing badge text.
  final String? badge;

  /// Optional submenu destinations; their presence enables expansion.
  final List<SeedSideNavSubItem>? subItems;

  /// Callback when a selectable item is activated.
  final VoidCallback? onTap;

  /// Positive enable flag; true by default.
  final bool enabled;

  /// Explicit disable flag; false by default.
  final bool disabled;

  /// Controlled expanded state when non-null; otherwise state is internal.
  final bool? open;

  /// Initial expansion for an unmanaged item; defaults to false.
  final bool defaultOpen;

  /// Deprecated alias of [onOpenChange].
  @Deprecated('Use onOpenChange instead.')
  final ValueChanged<bool>? onOpenChanged;

  /// React-style callback receiving the next expanded state.
  ///
  /// This getter aliases [onOpenChanged] for backwards compatibility.
  ValueChanged<bool>? get onOpenChange => onOpenChanged;

  /// Whether the item accepts input, combining [enabled] and [disabled].
  bool get isEnabled => enabled && !disabled;
}

/// A group of items in [SeedSideNavigation].
class SeedSideNavGroup {
  /// Groups the required [items] under an optional [label].
  const SeedSideNavGroup({this.label, required this.items});

  /// Optional section heading; a null value omits the heading.
  final String? label;

  /// First-level menu entries in display order.
  final List<SeedSideNavItem> items;
}

/// The official `useSideNavigationContext` value: the collapsed state of the
/// nearest side navigation and the means to change it.
///
/// Read it with [SeedSideNavigationProvider.of] or
/// [SeedSideNavigationProvider.maybeOf].
class SeedSideNavigationContextValue {
  const SeedSideNavigationContextValue._(this.collapsed, this._setCollapsed);

  /// Whether the side navigation is collapsed to its icon-only width.
  final bool collapsed;

  final ValueChanged<bool> _setCollapsed;

  /// Requests the given collapsed state. A parent-controlled navigation only
  /// reports the request through its `onCollapsedChange`.
  void setCollapsed(bool collapsed) => _setCollapsed(collapsed);

  /// Requests the opposite of the current [collapsed] state, as the official
  /// `SideNavigation.Trigger` does.
  void toggle() => _setCollapsed(!collapsed);
}

class _SeedSideNavigationScope extends InheritedWidget {
  const _SeedSideNavigationScope({required this.value, required super.child});

  final SeedSideNavigationContextValue value;

  @override
  bool updateShouldNotify(_SeedSideNavigationScope oldWidget) =>
      value.collapsed != oldWidget.value.collapsed;
}

/// The official `SideNavigation.Provider`: owns the collapsed state above a
/// [SeedSideNavigation] and its sibling content, so that a control outside
/// the navigation (for example a menu button in a [SeedSideNavigationInset])
/// can read and toggle it.
///
/// A [SeedSideNavigation] below a provider follows the provider's state
/// unless its own `collapsed` is set. Without a provider the navigation owns
/// its state as before, and still exposes it to its own `header` and
/// `footer` through [maybeOf].
class SeedSideNavigationProvider extends StatefulWidget {
  /// Creates a provider. [collapsed] is parent-controlled when non-null;
  /// otherwise [defaultCollapsed] (false) seeds internal state.
  /// [onCollapsedChange] receives each requested state.
  const SeedSideNavigationProvider({
    super.key,
    this.collapsed,
    this.defaultCollapsed = false,
    this.onCollapsedChange,
    required this.child,
  });

  /// Parent-controlled collapsed state, or null when managed here.
  final bool? collapsed;

  /// Initial collapsed state when [collapsed] is null.
  final bool defaultCollapsed;

  /// Receives the next collapsed state when a change is requested.
  final ValueChanged<bool>? onCollapsedChange;

  /// Subtree containing the navigation and the content beside it.
  final Widget child;

  /// The nearest side navigation state, or null outside a provider and a
  /// [SeedSideNavigation].
  static SeedSideNavigationContextValue? maybeOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<_SeedSideNavigationScope>()
          ?.value;

  /// The nearest side navigation state. Throws outside a provider and a
  /// [SeedSideNavigation], like the official strict hook.
  static SeedSideNavigationContextValue of(BuildContext context) {
    final value = maybeOf(context);
    assert(
      value != null,
      'SeedSideNavigationProvider.of() was called outside a '
      'SeedSideNavigationProvider or SeedSideNavigation.',
    );
    return value!;
  }

  @override
  State<SeedSideNavigationProvider> createState() =>
      _SeedSideNavigationProviderState();
}

class _SeedSideNavigationProviderState
    extends State<SeedSideNavigationProvider> {
  late bool _uncontrolled = widget.defaultCollapsed;

  bool get _collapsed => widget.collapsed ?? _uncontrolled;

  void _setCollapsed(bool next) {
    if (next == _collapsed) return;
    if (widget.collapsed == null) setState(() => _uncontrolled = next);
    widget.onCollapsedChange?.call(next);
  }

  @override
  Widget build(BuildContext context) => _SeedSideNavigationScope(
    value: SeedSideNavigationContextValue._(_collapsed, _setCollapsed),
    child: widget.child,
  );
}

/// The official `SideNavigation.Inset`: the content area beside a
/// [SeedSideNavigation]. It takes the remaining width of the enclosing [Row]
/// and, like the official `overflow-y: auto`, scrolls vertically.
///
/// Set [scrollable] to false when [child] brings its own scroll view (a
/// `ListView`, a `CustomScrollView`, a `Scaffold`); it then receives the
/// bounded height directly. This is a Flutter extension.
class SeedSideNavigationInset extends StatelessWidget {
  /// Creates the content area; must be a child of a [Row] or horizontal
  /// [Flex].
  const SeedSideNavigationInset({
    super.key,
    required this.child,
    this.scrollable = true,
  });

  /// Page content shown beside the navigation.
  final Widget child;

  /// Whether to wrap [child] in a vertical scroll view; true by default.
  final bool scrollable;

  @override
  Widget build(BuildContext context) =>
      Expanded(child: scrollable ? SingleChildScrollView(child: child) : child);
}

/// A SEED Design Side Navigation drawer/sidebar component for desktop and tablet.
class SeedSideNavigation extends StatefulWidget {
  /// Builds a sidebar with [groups], optional [header], and [footer].
  ///
  /// [selectedId] highlights an item or subitem. [collapsed] controls
  /// expansion from the parent; [defaultCollapsed] initializes local state.
  /// Deprecated [isCollapsed] is an alias of [collapsed]. [onCollapsedChange]
  /// receives the next collapsed state, [onCollapsedChanged] is deprecated,
  /// and [onToggleCollapsed] is a no-argument compatibility callback.
  /// [showCollapseButton] displays a built-in control; [width] defaults to
  /// 240px, [collapsedWidth] to 56px. [collapseBelow] forces icon-only mode
  /// below a viewport width. [tone] defaults to neutral and [backgroundColor]
  /// optionally overrides the surface color. An optional `key` preserves
  /// Flutter widget identity.
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
  ///
  /// Changing this value also expands the matching subitem's parent, but
  /// ordinary rebuilds do not reopen a parent that the user closed manually.
  final String? selectedId;

  final bool? _isCollapsed;

  /// Initial collapsed state when [collapsed] is null (defaults to false).
  final bool defaultCollapsed;

  /// Controlled collapsed state, or null when internally managed.
  bool? get collapsed => _isCollapsed;

  /// Legacy effective collapsed flag, including [defaultCollapsed].
  /// Prefer [collapsed] for controlled input.
  @Deprecated('Use collapsed or defaultCollapsed instead.')
  bool get isCollapsed => _isCollapsed ?? defaultCollapsed;

  /// Callback when collapse toggle is clicked.
  final VoidCallback? onToggleCollapsed;

  /// Callback with the next collapsed state when toggled.
  @Deprecated('Use onCollapsedChange instead.')
  final ValueChanged<bool>? onCollapsedChanged;

  /// React-style callback reporting the next collapsed state.
  /// This getter aliases [onCollapsedChanged].
  ValueChanged<bool>? get onCollapsedChange => onCollapsedChanged;

  /// Whether to show the built-in collapse toggle button even without [onToggleCollapsed].
  final bool showCollapseButton;

  /// Width when expanded. Defaults to 240.
  final double width;

  /// Width when collapsed. Defaults to 56.
  final double collapsedWidth;

  /// Surface tone of the sidebar (`neutral` or `transparent`).
  final SeedSideNavTone tone;

  /// Optional explicit surface color, overriding [tone]'s default background.
  final Color? backgroundColor;

  /// Viewport-width threshold below which collapsed mode is forced.
  ///
  /// Null disables this responsive Flutter extension; measured width is from
  /// [MediaQuery] and does not modify the controlled [collapsed] property.
  final double? collapseBelow;

  @override
  /// Creates state for local expansion, collapse, and scroll tracking.
  State<SeedSideNavigation> createState() => _SeedSideNavigationState();
}

class _SeedSideNavigationState extends State<SeedSideNavigation> {
  final Set<String> _expandedItemIds = {};
  final Set<String> _knownItemIds = {};
  final ScrollController _scrollController = ScrollController();
  late bool _uncontrolledCollapsed = widget.defaultCollapsed;
  bool _scrolled = false;
  bool? _previousCollapsed;
  double? _previousWidth;
  bool _transitioning = false;
  // Open collapsed-sidebar flyout (SeedNavigationMenu value).
  String? _flyout;

  // An enclosing SeedSideNavigationProvider owns the state unless this
  // widget is controlled directly.
  SeedSideNavigationContextValue? get _provider =>
      SeedSideNavigationProvider.maybeOf(context);

  bool get _collapsed =>
      (widget._isCollapsed ?? _provider?.collapsed ?? _uncontrolledCollapsed) ||
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
    // Initialize newly introduced identities without resetting prior choices.
    _initNewExpandedItems();
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
    _initNewExpandedItems();
    _expandSelectedParent();
  }

  void _initNewExpandedItems() {
    final currentIds = {
      for (final group in widget.groups)
        for (final item in group.items) item.id,
    };
    _knownItemIds.retainAll(currentIds);
    _expandedItemIds.retainAll(currentIds);
    for (final group in widget.groups) {
      for (final item in group.items) {
        if (_knownItemIds.add(item.id) && item.defaultOpen) {
          _expandedItemIds.add(item.id);
        }
      }
    }
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

  void _handleToggleCollapse() => _requestCollapsed(!_collapsed);

  void _requestCollapsed(bool next) {
    if (next == _collapsed) return;
    if (widget._isCollapsed == null) {
      final provider = _provider;
      if (provider != null) {
        provider.setCollapsed(next);
      } else {
        setState(() => _uncontrolledCollapsed = next);
      }
    }
    widget.onToggleCollapsed?.call();
    widget.onCollapsedChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;
    final currentWidth = _collapsed ? widget.collapsedWidth : widget.width;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    // The registry installs collapsed overlays only after the root transition.
    if (reduceMotion || !_collapsed) {
      _transitioning = false;
    } else if (_previousCollapsed == false) {
      _transitioning = _previousWidth != currentWidth;
    }
    _previousCollapsed = _collapsed;
    _previousWidth = currentWidth;
    // A flyout does not survive leaving collapsed mode.
    if (!_collapsed) _flyout = null;
    final rtl = Directionality.of(context) == TextDirection.rtl;
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

    // Header and footer widgets read the effective state, including a
    // collapse forced by [SeedSideNavigation.collapseBelow].
    return _SeedSideNavigationScope(
      value: SeedSideNavigationContextValue._(_collapsed, _requestCollapsed),
      child: _buildNavigation(
        context,
        colors: colors,
        typography: typography,
        currentWidth: currentWidth,
        reduceMotion: reduceMotion,
        rtl: rtl,
        hasCollapseTrigger: hasCollapseTrigger,
        effectiveBgColor: effectiveBgColor,
      ),
    );
  }

  Widget _buildNavigation(
    BuildContext context, {
    required SeedColorScheme colors,
    required SeedTypography typography,
    required double currentWidth,
    required bool reduceMotion,
    required bool rtl,
    required bool hasCollapseTrigger,
    required Color effectiveBgColor,
  }) {
    return Semantics(
      container: true,
      role: SemanticsRole.navigation,
      child: AnimatedContainer(
        duration: reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 200),
        onEnd: _transitioning
            ? () => setState(() => _transitioning = false)
            : null,
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
                  // Registry SideNavigationRoot: NavigationMenuProvider with
                  // placement right-start (toward the content, so left in
                  // RTL) and responsive size. Its delay group also covers
                  // the collapsed items' tooltips.
                  child: SeedNavigationMenu(
                    controlled: true,
                    value: _collapsed ? _flyout : null,
                    onValueChange: (value) {
                      if (mounted) setState(() => _flyout = value);
                    },
                    side: rtl ? SeedOverlaySide.left : SeedOverlaySide.right,
                    align: SeedOverlayAlign.start,
                    size: SeedMenuSize.responsive,
                    child: Stack(
                      children: [
                        ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
                          itemCount: widget.groups.length,
                          separatorBuilder: (_, _) => SizedBox(
                            height: _collapsed ? 0 : SeedDimension.x2,
                          ),
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
      if (!_transitioning && hasSubItems && isItemEnabled) {
        // Official registry: a NavigationMenuRoot whose trigger is the item
        // button (tooltip disabled) and whose flyout groups the sub items
        // under the item label.
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: SeedDimension.x2),
          child: SeedNavigationMenuRoot(
            value: item.id,
            trigger: SeedNavigationMenuTrigger(
              selected: isCurrent,
              semanticsLabel: item.label,
              focusRingInside: true,
              focusBorderRadius: SeedBorderRadius.r2_5,
              builder: (context, open, isEngaged) => surface(isEngaged),
            ),
            content: SeedNavigationMenuContent(
              children: [
                SeedNavigationMenuGroup(
                  label: item.label,
                  children: [
                    for (final sub in item.subItems!)
                      SeedNavigationMenuItem(
                        label: sub.label,
                        current: sub.id == widget.selectedId,
                        // Only an explicit disable disables it; a missing
                        // onTap stays enabled as when expanded (12-04).
                        disabled: !sub.isEnabled,
                        onTap: sub.onTap,
                        suffixIcon: sub.badge == null
                            ? null
                            : SeedBadge(
                                label: sub.badge!,
                                tone: sub.id == widget.selectedId
                                    ? SeedBadgeTone.brand
                                    : SeedBadgeTone.neutral,
                              ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      }
      final button = SeedPressable(
        enabled: isItemEnabled && !(_transitioning && hasSubItems),
        enableScale: false,
        selected: isCurrent,
        semanticsLabel: item.label,
        focusRingInside: true,
        focusBorderRadius: SeedBorderRadius.r2_5,
        onTap: item.onTap ?? () {},
        builder: (context, isEngaged) => surface(isEngaged),
      );
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: SeedDimension.x2),
        child: _transitioning
            ? button
            : SeedHelpBubbleTooltip(
                title: item.label,
                side: SeedOverlaySide.right,
                child: button,
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

/// Reveals a group label or sub-items over the official 200ms and removes them
/// from the tree once closed.
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

/// The item's own background: 44px tall with the official current and pressed
/// colors, inset from the panel by its parent's padding.
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
