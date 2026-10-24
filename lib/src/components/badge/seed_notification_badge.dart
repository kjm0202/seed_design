import 'package:material_ui/material_ui.dart';

import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';

/// Notification Badge component of SEED Design System.
///
/// Attached to icons, navigation tabs, or list items to notify users
/// of unread counts or newly updated states.
class SeedNotificationBadge extends StatelessWidget {
  /// Unread count. If null or 0, this widget renders nothing unless [showDot] is true.
  final int? count;

  /// If true and [count] is null or 0, renders a small dot badge.
  final bool showDot;

  /// Maximum count before showing "+", e.g. 99 -> "99+".
  final int maxCount;

  /// Optional custom background color. Defaults to `colors.bg.brandSolid`.
  final Color? color;

  /// Optional custom text color. Defaults to `colors.fg.onBrandSolid`.
  final Color? textColor;

  const SeedNotificationBadge({
    super.key,
    this.count,
    this.showDot = false,
    this.maxCount = 99,
    this.color,
    this.textColor,
  });

  /// Factory for a simple unread dot.
  const SeedNotificationBadge.dot({super.key, this.color})
    : count = null,
      showDot = true,
      maxCount = 99,
      textColor = null;

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;
    final bgColor = color ?? colors.bg.brandSolid;
    final fgColor = textColor ?? colors.fg.onBrandSolid;

    if (showDot && (count == null || count == 0)) {
      return Container(
        width: 6.0,
        height: 6.0,
        decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      );
    }

    if (count == null || count! <= 0) {
      return const SizedBox.shrink();
    }

    final String text = count! > maxCount ? '$maxCount+' : count.toString();

    return Container(
      height: 18.0,
      constraints: const BoxConstraints(minWidth: 18.0),
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: SeedBorderRadius.full,
      ),
      child: Center(
        widthFactor: 1.0,
        child: Text(
          text,
          textScaler: TextScaler.noScaling,
          style: typography.t1Bold.copyWith(
            color: fgColor,
            height: 15 / 11,
          ),
          maxLines: 1,
        ),
      ),
    );
  }
}
