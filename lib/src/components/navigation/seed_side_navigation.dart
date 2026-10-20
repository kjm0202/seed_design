import 'package:material_ui/material_ui.dart';

import '../../foundations/colors/seed_color_scheme.dart';
import '../../foundations/colors/seed_palette.dart';
import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../foundations/typography/seed_typography.dart';
import '../../theme/seed_theme.dart';
import '../badge/seed_badge.dart';
import '../layout/seed_divider.dart';

/// A 2nd-level sub item in [SeedSideNavigation].
class SeedSideNavSubItem {
  const SeedSideNavSubItem({
    required this.id,
    required this.label,
    this.badge,
    this.onTap,
  });

  final String id;
  final String label;
  final String? badge;
  final VoidCallback? onTap;
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
  });

  final String id;
  final String label;
  final IconData? icon;
  final String? badge;
  final List<SeedSideNavSubItem>? subItems;
  final VoidCallback? onTap;
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
    this.isCollapsed = false,
    this.onToggleCollapsed,
    this.width = 240.0,
    this.collapsedWidth = 56.0,
  });

  /// Header widget (brand logo, user profile, workspace switcher).
  final Widget? header;

  /// Footer widget (external links, settings, help).
  final Widget? footer;

  /// Navigation item groups.
  final List<SeedSideNavGroup> groups;

  /// The currently active item or sub-item ID.
  final String? selectedId;

  /// Whether the sidebar is collapsed to icon-only mode.
  final bool isCollapsed;

  /// Callback when collapse toggle is clicked.
  final VoidCallback? onToggleCollapsed;

  /// Width when expanded. Defaults to 240.
  final double width;

  /// Width when collapsed. Defaults to 56.
  final double collapsedWidth;

  @override
  State<SeedSideNavigation> createState() => _SeedSideNavigationState();
}

class _SeedSideNavigationState extends State<SeedSideNavigation> {
  final Set<String> _expandedItemIds = {};

  void _toggleExpand(String id) {
    setState(() {
      if (_expandedItemIds.contains(id)) {
        _expandedItemIds.remove(id);
      } else {
        _expandedItemIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;
    final currentWidth = widget.isCollapsed
        ? widget.collapsedWidth
        : widget.width;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: currentWidth,
      decoration: BoxDecoration(
        color: colors.isDark
            ? SeedPalette.gray100Dark
            : SeedPalette.gray100Light,
        border: Border(right: BorderSide(color: colors.stroke.neutralMuted)),
      ),
      child: Column(
        children: [
          // Header & Collapse trigger
          if (widget.header != null || widget.onToggleCollapsed != null)
            Padding(
              padding: const EdgeInsets.all(SeedDimension.x2),
              child: Row(
                children: [
                  if (!widget.isCollapsed && widget.header != null)
                    Expanded(child: widget.header!),
                  if (widget.onToggleCollapsed != null)
                    IconButton(
                      icon: Icon(
                        widget.isCollapsed ? Icons.menu : Icons.menu_open,
                        color: colors.fg.neutralSubtle,
                        size: 20,
                      ),
                      onPressed: widget.onToggleCollapsed,
                      splashRadius: 18,
                    ),
                ],
              ),
            ),

          if (widget.header != null) const SeedDivider(),

          // Scrollable navigation content
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
              itemCount: widget.groups.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: SeedDimension.x2),
              itemBuilder: (context, groupIndex) {
                final group = widget.groups[groupIndex];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!widget.isCollapsed && group.label != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: SeedDimension.x4,
                          vertical: SeedDimension.x1,
                        ),
                        child: Text(
                          group.label!,
                          style: typography.t4Bold.copyWith(
                            color: colors.fg.neutralSubtle,
                          ),
                        ),
                      ),
                    ...group.items.map(
                      (item) =>
                          _buildMenuItem(context, item, colors, typography),
                    ),
                  ],
                );
              },
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
    final isExpanded = _expandedItemIds.contains(item.id);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () {
            if (hasSubItems) {
              _toggleExpand(item.id);
            }
            item.onTap?.call();
          },
          child: Container(
            constraints: const BoxConstraints(minHeight: 44),
            margin: const EdgeInsets.symmetric(
              horizontal: SeedDimension.x2,
              vertical: 0,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: widget.isCollapsed ? 10 : 8,
              vertical: SeedDimension.x3,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? colors.bg.transparentSelected
                  : Colors.transparent,
              borderRadius: SeedBorderRadius.r2_5,
            ),
            child: Row(
              mainAxisAlignment: widget.isCollapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                if (item.icon != null)
                  Icon(
                    item.icon,
                    size: 20,
                    color: isSelected
                        ? colors.fg.neutral
                        : (colors.isDark
                              ? SeedPalette.gray600Dark
                              : SeedPalette.gray600Light),
                  ),
                if (!widget.isCollapsed) ...[
                  if (item.icon != null)
                    const SizedBox(width: SeedDimension.x3),
                  Expanded(
                    child: Text(
                      item.label,
                      style: typography.t4Medium.copyWith(
                        color: isSelected
                            ? colors.fg.neutral
                            : colors.fg.neutralMuted,
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
                      size: 18,
                      color: colors.fg.neutralMuted,
                    ),
                ],
              ],
            ),
          ),
        ),

        // Sub items
        if (!widget.isCollapsed && hasSubItems && isExpanded)
          ...item.subItems!.map((sub) {
            final isSubSelected = sub.id == widget.selectedId;
            return InkWell(
              onTap: sub.onTap,
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
                          color: isSubSelected
                              ? colors.fg.neutral
                              : colors.fg.neutralMuted,
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
            );
          }),
      ],
    );
  }
}
