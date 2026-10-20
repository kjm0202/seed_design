import 'package:material_ui/material_ui.dart';

import '../../foundations/dimensions/seed_dimension.dart';
import '../../theme/seed_theme.dart';
import '../../foundations/feedback/seed_choice_group.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
import '../badge/seed_notification_badge.dart';
import '../layout/seed_divider.dart';

/// Item definition for [SeedBottomNavigation].
class SeedBottomNavigationItem {
  final Widget icon;
  final Widget? activeIcon;
  final String label;
  final int? notificationCount;
  final bool showNotificationDot;

  const SeedBottomNavigationItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.notificationCount,
    this.showNotificationDot = false,
  });
}

/// Bottom Navigation Bar component of SEED Design System.
///
/// Fixed at the bottom of the root screen providing navigation across up to 5 tabs,
/// with notification badge support and safe-area insets.
class SeedBottomNavigation extends StatelessWidget {
  final List<SeedBottomNavigationItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color? backgroundColor;

  const SeedBottomNavigation({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.backgroundColor,
  }) : assert(
         items.length >= 2 && items.length <= 5,
         'Items length must be between 2 and 5.',
       );

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;

    return SeedChoiceGroup(
      selectedIndex: currentIndex,
      enabled: List.filled(items.length, true),
      onSelected: onTap,
      builder: (context, nodes) => Container(
        color: backgroundColor ?? colors.bg.layerDefault,
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SeedDivider(
                thickness: Theme.of(context).platform == TargetPlatform.iOS
                    ? 1 / MediaQuery.devicePixelRatioOf(context)
                    : 1,
              ),
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: Theme.of(context).platform == TargetPlatform.iOS
                        ? double.infinity
                        : 480,
                  ),
                  child: SizedBox(
                    height: 56.0,
                    child: Row(
                      children: List.generate(items.length, (index) {
                        final item = items[index];
                        final bool isSelected = index == currentIndex;

                        final Color fgColor = isSelected
                            ? colors.fg.neutral
                            : colors.fg.neutralMuted;
                        final TextStyle textStyle =
                            (isSelected
                                    ? typography.t1Bold
                                    : typography.t1Medium)
                                .copyWith(color: fgColor);

                        final Widget effectiveIcon = isSelected
                            ? (item.activeIcon ?? item.icon)
                            : item.icon;

                        return Expanded(
                          child: SeedPressable(
                            selected: isSelected,
                            focusNode: nodes[index],
                            semanticsLabel: item.label,
                            enableScale: false,
                            onTap: () => onTap(index),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    IconTheme(
                                      data: IconThemeData(
                                        color: fgColor,
                                        size: 24.0,
                                      ),
                                      child: effectiveIcon,
                                    ),
                                    if (item.notificationCount != null ||
                                        item.showNotificationDot) ...[
                                      Positioned(
                                        top: -2.0,
                                        right: -6.0,
                                        child: SeedNotificationBadge(
                                          count: item.notificationCount,
                                          showDot: item.showNotificationDot,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: SeedDimension.x0_5),
                                Text(
                                  item.label,
                                  style: textStyle,
                                  maxLines: 1,
                                  textScaler: TextScaler.noScaling,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
