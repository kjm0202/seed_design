import '../../localization/seed_localizations.dart';

import 'package:material_ui/material_ui.dart';

import '../../foundations/dimensions/seed_dimension.dart';
import '../../theme/seed_theme.dart';
import '../../foundations/feedback/seed_choice_group.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
import '../badge/seed_notification_badge.dart';
import '../layout/seed_divider.dart';

/// Item definition for [SeedBottomNavigation].
class SeedBottomNavigationItem {
  /// Icon displayed when this destination is not selected.
  final Widget icon;
  /// Icon shown for the selected destination; falls back to [icon].
  final Widget? activeIcon;
  /// Visible, accessible destination name.
  final String label;
  /// Unread count displayed in a notification badge, when supplied.
  final int? notificationCount;
  /// Shows a notification dot without requiring a positive count.
  final bool showNotificationDot;
  /// Whether this destination can be focused and selected; defaults to true.
  final bool enabled;

  /// Override for localized notification information read by screen readers.
  final String? notificationSemanticsLabel;

  /// Defines a destination with an [icon], [label], and optional notifications.
  ///
  /// [activeIcon] replaces [icon] when selected. [notificationCount] and
  /// [showNotificationDot] control the badge; [enabled] defaults to true.
  /// [notificationSemanticsLabel] overrides the localized badge announcement.
  const SeedBottomNavigationItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.notificationCount,
    this.showNotificationDot = false,
    this.enabled = true,
    this.notificationSemanticsLabel,
  });

  String? _notificationValue(BuildContext context) {
    final count = notificationCount;
    if (count != null && count > 0) {
      return notificationSemanticsLabel ??
          SeedLocalizations.unreadNotifications(context, count);
    }
    if (showNotificationDot && (count == null || count == 0)) {
      return notificationSemanticsLabel ??
          SeedLocalizations.label(context, SeedLabel.newNotification);
    }
    return null;
  }
}

/// Bottom Navigation Bar component of SEED Design System.
///
/// Fixed at the bottom of the root screen providing navigation across up to 5 tabs,
/// with notification badge support and safe-area insets.
class SeedBottomNavigation extends StatelessWidget {
  /// Root destinations, limited to two through five items.
  final List<SeedBottomNavigationItem> items;
  /// Zero-based selected destination, controlled by the parent.
  final int currentIndex;
  /// Invoked with the tapped destination's zero-based index.
  final ValueChanged<int> onTap;
  /// Background override; defaults to the SEED layer surface color.
  final Color? backgroundColor;

  /// Displays [items] in a safe-area-aware bottom bar.
  ///
  /// The parent supplies [currentIndex] and handles [onTap] to update it.
  /// The bar requires two to five items and keeps their icons and labels in
  /// one row; [backgroundColor] overrides the default SEED surface.
  /// An optional `key` identifies this widget within Flutter's element tree.
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
  /// Builds the bottom navigation destinations and their selection semantics.
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;

    return SeedChoiceGroup(
      selectedIndex: currentIndex,
      enabled: items.map((item) => item.enabled).toList(),
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

                        final Color fgColor = !item.enabled
                            ? colors.fg.disabled
                            : isSelected
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
                            enabled: item.enabled,
                            selected: isSelected,
                            focusNode: nodes[index],
                            semanticsLabel: item.label,
                            semanticsValue: item._notificationValue(context),
                            enableScale: false,
                            onTap: () => onTap(index),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SeedNotificationBadgePositioner(
                                  badge: SeedNotificationBadge(
                                    count: item.notificationCount,
                                    showDot: item.showNotificationDot,
                                  ),
                                  child: IconTheme(
                                    data: IconThemeData(
                                      color: fgColor,
                                      size: 24,
                                    ),
                                    child: effectiveIcon,
                                  ),
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
