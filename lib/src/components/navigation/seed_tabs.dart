import 'package:material_ui/material_ui.dart';

import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/motion/seed_motion.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
import '../../theme/seed_theme.dart';
import '../../foundations/feedback/seed_choice_group.dart';
import '../badge/seed_notification_badge.dart';

/// Style variants of [SeedTabs].
enum SeedTabsVariant { line, chipSolid, chipOutline }

/// Sizing options for [SeedTabs].
enum SeedTabsSize {
  small,
  medium,
  large;

  double get height {
    switch (this) {
      case SeedTabsSize.small:
        return 36.0;
      case SeedTabsSize.medium:
        return 44.0;
      case SeedTabsSize.large:
        return 48.0;
    }
  }
}

/// Represents an item in [SeedTabs].
class SeedTabItem {
  final String label;
  final int? notificationCount;
  final bool showNotificationDot;
  final bool enabled;

  const SeedTabItem({
    required this.label,
    this.notificationCount,
    this.showNotificationDot = false,
    this.enabled = true,
  });
}

/// Tabs component of SEED Design System.
///
/// Supports Line type (with Fill and Hug layouts) and Chip type (Solid & Outline),
/// with built-in notification badges and physical scale interactions.
class SeedTabs extends StatelessWidget {
  final List<SeedTabItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final SeedTabsVariant variant;
  final SeedTabsSize size;
  final bool fill;

  const SeedTabs({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTabSelected,
    this.variant = SeedTabsVariant.line,
    this.size = SeedTabsSize.medium,
    this.fill = false,
  });

  @override
  Widget build(BuildContext context) {
    return SeedChoiceGroup(
      selectedIndex: selectedIndex,
      enabled: items.map((item) => item.enabled).toList(),
      onSelected: onTabSelected,
      builder: (context, nodes) => variant == SeedTabsVariant.line
          ? _buildLineTabs(context, nodes)
          : _buildChipTabs(context, nodes),
    );
  }

  Widget _buildLineTabs(BuildContext context, List<FocusNode> nodes) {
    final colors = context.seedColor;

    return Container(
      height: size.height,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colors.stroke.neutralWeak, width: 1.0),
        ),
      ),
      child: fill
          ? Row(
              children: List.generate(items.length, (index) {
                return Expanded(
                  child: _buildLineTabItem(context, index, nodes[index]),
                );
              }),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(items.length, (index) {
                  return _buildLineTabItem(context, index, nodes[index]);
                }),
              ),
            ),
    );
  }

  Widget _buildLineTabItem(BuildContext context, int index, FocusNode node) {
    final colors = context.seedColor;
    final typography = context.seedTypography;
    final item = items[index];
    final bool isSelected = index == selectedIndex;

    final TextStyle textStyle =
        (size == SeedTabsSize.small
                ? (isSelected ? typography.t3Bold : typography.t3Regular)
                : (isSelected ? typography.t4Bold : typography.t4Regular))
            .copyWith(
              color: !item.enabled
                  ? colors.fg.disabled
                  : (isSelected ? colors.fg.neutral : colors.fg.neutralMuted),
            );

    return SeedPressable(
      enabled: item.enabled,
      selected: isSelected,
      focusNode: node,
      onTap: () => onTabSelected(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: SeedDimension.x4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: isSelected
              ? Border(bottom: BorderSide(color: colors.fg.neutral, width: 2.0))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(item.label, style: textStyle),
            if (item.notificationCount != null || item.showNotificationDot) ...[
              const SizedBox(width: SeedDimension.x1),
              SeedNotificationBadge(
                count: item.notificationCount,
                showDot: item.showNotificationDot,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChipTabs(BuildContext context, List<FocusNode> nodes) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final bool isSelected = index == selectedIndex;
          return Padding(
            padding: const EdgeInsets.only(right: SeedDimension.x2),
            child: _buildChipTabItem(
              context,
              index,
              item,
              isSelected,
              nodes[index],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildChipTabItem(
    BuildContext context,
    int index,
    SeedTabItem item,
    bool isSelected,
    FocusNode node,
  ) {
    final colors = context.seedColor;
    final typography = context.seedTypography;

    Color bgColor;
    Color fgColor;
    Color? strokeColor;

    if (!item.enabled) {
      bgColor = colors.bg.disabled;
      fgColor = colors.fg.disabled;
    } else if (variant == SeedTabsVariant.chipSolid) {
      if (isSelected) {
        bgColor = colors.bg.neutralSolid;
        fgColor = colors.fg.onNeutralSolid;
      } else {
        bgColor = colors.bg.neutralWeak;
        fgColor = colors.fg.neutral;
      }
    } else {
      // chipOutline
      if (isSelected) {
        bgColor = colors.bg.neutralWeak;
        fgColor = colors.fg.neutral;
        strokeColor = colors.stroke.neutralContrast;
      } else {
        bgColor = colors.bg.transparent;
        fgColor = colors.fg.neutral;
        strokeColor = colors.stroke.neutralWeak;
      }
    }

    final TextStyle textStyle =
        (size == SeedTabsSize.small
                ? (isSelected ? typography.t2Bold : typography.t2Medium)
                : (isSelected ? typography.t3Bold : typography.t3Medium))
            .copyWith(color: fgColor);

    return SeedPressable(
      enabled: item.enabled,
      selected: isSelected,
      focusNode: node,
      onTap: () => onTabSelected(index),
      builder: (context, isPressed) {
        return AnimatedContainer(
          duration: SeedDuration.colorTransition,
          curve: SeedCurves.easing,
          height: size == SeedTabsSize.small ? 32.0 : 38.0,
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: SeedBorderRadius.full,
            border: strokeColor != null
                ? Border.all(color: strokeColor, width: 1.0)
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(item.label, style: textStyle),
              if (item.notificationCount != null ||
                  item.showNotificationDot) ...[
                const SizedBox(width: SeedDimension.x1),
                SeedNotificationBadge(
                  count: item.notificationCount,
                  showDot: item.showNotificationDot,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
