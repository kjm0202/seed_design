import 'package:material_ui/material_ui.dart';

import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';

/// Badge presentation sizing; small is a dot and large displays text.
enum SeedNotificationBadgeSize {
  /// Six-pixel notification dot.
  small,

  /// Text or count pill (minimum 18 px).
  large,
}

/// Anchor kind used by [SeedNotificationBadgePositioner].
enum SeedNotificationBadgeAttach {
  /// Anchor at an icon corner.
  icon,

  /// Anchor at the text line end.
  text,
}

/// Notification Badge component of SEED Design System.
///
/// Attached to icons, navigation tabs, or list items to notify users
/// of unread counts or newly updated states.
class SeedNotificationBadge extends StatelessWidget {
  /// Unread count displayed when positive and the effective size is not small.
  ///
  /// With no [label] or positive count the badge is hidden unless a small
  /// effective [size] is selected or [showDot] enables the default dot.
  final int? count;

  /// Explicit visual size. When omitted, count/showDot keep their original behavior.
  final SeedNotificationBadgeSize? size;

  /// An explicit label, including "0" or a non-numeric status.
  final String? label;

  /// Requests a small dot for a null or zero [count] when no size is specified.
  ///
  /// An explicit or inherited [size] takes precedence over this option.
  final bool showDot;

  /// Maximum count shown without a trailing plus sign.
  ///
  /// For example, with the default limit of 99, 99 displays as `99` and
  /// 100 displays as `99+`.
  final int maxCount;

  /// Optional custom background color. Defaults to `colors.bg.brandSolid`.
  final Color? color;

  /// Optional custom text color. Defaults to `colors.fg.onBrandSolid`.
  final Color? textColor;

  /// Creates a count, label, or dot notification badge.
  ///
  /// [size] can force the six-pixel dot independently of [label], [count],
  /// and [showDot]. [label] takes precedence over numeric formatting.
  /// Without visible content, a non-dot badge is empty.
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

  /// Creates a six-pixel unread-status dot, optionally recolored with [color].
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
  /// Places [badge] at the appropriate corner of [child].
  /// Its overlay may paint outside the child's layout bounds.
  const SeedNotificationBadgePositioner({
    super.key,
    required this.child,
    required this.badge,
    this.attach = SeedNotificationBadgeAttach.icon,
    this.size,
  });
  /// Icon or text anchor that determines the layout footprint.
  final Widget child;
  /// Badge rendered above and at the logical end of [child].
  final SeedNotificationBadge badge;
  /// Positioning preset for an icon or text anchor (icon by default).
  final SeedNotificationBadgeAttach attach;
  /// Optional size override; otherwise the badge's size or content decides.
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
          // The official text attachment keeps its static position: the top
          // of the line, not its middle.
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
