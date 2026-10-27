import 'package:material_ui/material_ui.dart';

import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';

enum SeedNotificationBadgeSize { small, large }

enum SeedNotificationBadgeAttach { icon, text }

/// Notification Badge component of SEED Design System.
///
/// Attached to icons, navigation tabs, or list items to notify users
/// of unread counts or newly updated states.
class SeedNotificationBadge extends StatelessWidget {
  /// Unread count. If null or 0, this widget renders nothing unless [showDot] is true.
  final int? count;

  /// Explicit visual size. When omitted, count/showDot keep their original behavior.
  final SeedNotificationBadgeSize? size;

  /// An explicit label, including "0" or a non-numeric status.
  final String? label;

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
    this.size,
    this.label,
    this.showDot = false,
    this.maxCount = 99,
    this.color,
    this.textColor,
  });

  /// Factory for a simple unread dot.
  const SeedNotificationBadge.dot({super.key, this.color})
    : count = null,
      size = SeedNotificationBadgeSize.small,
      label = null,
      showDot = true,
      maxCount = 99,
      textColor = null;

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;
    final bgColor = color ?? colors.bg.brandSolid;
    final fgColor = textColor ?? colors.fg.onBrandSolid;

    final effectiveSize =
        _SeedNotificationBadgeScope.maybeOf(context)?.size ?? size;
    if (effectiveSize == SeedNotificationBadgeSize.small ||
        (effectiveSize == null && showDot && (count == null || count == 0))) {
      return Container(
        width: 6.0,
        height: 6.0,
        decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      );
    }

    if (label == null && (count == null || count! <= 0)) {
      return const SizedBox.shrink();
    }

    final String text =
        label ?? (count! > maxCount ? '$maxCount+' : count.toString());

    return Container(
      constraints: const BoxConstraints(minWidth: 18.0, minHeight: 18.0),
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: SeedBorderRadius.full,
      ),
      child: Center(
        widthFactor: 1.0,
        heightFactor: 1.0,
        child: Text(
          text,
          textScaler: TextScaler.noScaling,
          style: typography.t1Bold.copyWith(color: fgColor, height: 15 / 11),
          maxLines: 1,
        ),
      ),
    );
  }
}

/// Attaches a badge to an icon or text using the official inset/gap tokens.
/// The anchor determines layout size; the badge may paint outside its bounds.
class SeedNotificationBadgePositioner extends StatelessWidget {
  const SeedNotificationBadgePositioner({
    super.key,
    required this.child,
    required this.badge,
    this.attach = SeedNotificationBadgeAttach.icon,
    this.size,
  });
  final Widget child;
  final SeedNotificationBadge badge;
  final SeedNotificationBadgeAttach attach;
  final SeedNotificationBadgeSize? size;

  @override
  Widget build(BuildContext context) {
    final effectiveSize =
        size ??
        badge.size ??
        (badge.showDot && (badge.count == null || badge.count == 0)
            ? SeedNotificationBadgeSize.small
            : SeedNotificationBadgeSize.large);
    final small = effectiveSize == SeedNotificationBadgeSize.small;
    final icon = attach == SeedNotificationBadgeAttach.icon;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        PositionedDirectional(
          top: icon ? (small ? 7 : 14) : 0,
          bottom: icon ? null : 0,
          end: icon ? (small ? 7 : 8) : -2,
          child: FractionalTranslation(
            translation: Offset(rtl ? -1 : 1, icon ? -1 : 0),
            child: _SeedNotificationBadgeScope(
              size: effectiveSize,
              child: Center(widthFactor: 1, heightFactor: 1, child: badge),
            ),
          ),
        ),
      ],
    );
  }
}

class _SeedNotificationBadgeScope extends InheritedWidget {
  const _SeedNotificationBadgeScope({required this.size, required super.child});
  final SeedNotificationBadgeSize size;
  static _SeedNotificationBadgeScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_SeedNotificationBadgeScope>();
  @override
  bool updateShouldNotify(_SeedNotificationBadgeScope oldWidget) =>
      size != oldWidget.size;
}
