import 'package:material_ui/material_ui.dart';

import '../../foundations/feedback/seed_scale_feedback.dart';
import '../../foundations/motion/seed_motion.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';

/// Pressable shared by pagination controls.
///
/// SEED 3.4.0 replaced the fixed `scale.s97` press with the shared size-based
/// Scale Feedback (`pressed.root.scaleScope: self`), so the whole control uses
/// [SeedPressable]'s dynamic `(basis - 2) / basis` scale. Each control is
/// 40 x 40 px, giving `basis = 40` and a pressed scale of 0.95.
class SeedPaginationPressable extends StatelessWidget {
  /// Creates a focusable pagination surface with the official size-based press
  /// scale.
  ///
  /// [semanticsLabel] names the control, [enabled] gates interaction,
  /// [onTap] runs on activation, [builder] draws its pressed visual state,
  /// and [selected] optionally exposes the current-page state.
  /// An optional `key` preserves Flutter widget identity.
  const SeedPaginationPressable({
    super.key,
    required this.semanticsLabel,
    required this.enabled,
    required this.onTap,
    required this.builder,
    this.selected,
  });

  /// Accessible control name.
  final String semanticsLabel;
  /// Whether the control responds to input.
  final bool enabled;
  /// Optional selection state, as for the current page button.
  final bool? selected;
  /// Callback invoked when the control is activated.
  final VoidCallback onTap;
  /// Renders the control using its current engaged/pressed state.
  final Widget Function(BuildContext context, bool isEngaged) builder;

  @override
  /// Renders SEED press feedback and the supplied [builder].
  Widget build(BuildContext context) => SeedPressable(
    enabled: enabled,
    selected: selected,
    semanticsLabel: semanticsLabel,
    focusBorderRadius: SeedBorderRadius.r2,
    onTap: onTap,
    builder: builder,
  );
}

/// Previous/next control of [SeedPagination] and [SeedTablePagination].
class SeedPaginationNavButton extends StatelessWidget {
  /// Creates an accessible previous or next page navigation button.
  ///
  /// [icon] selects its chevron, [semanticsLabel] names the action,
  /// [enabled] controls interactivity, and [onTap] handles activation.
  /// An optional `key` preserves Flutter widget identity.
  const SeedPaginationNavButton({
    super.key,
    required this.icon,
    required this.semanticsLabel,
    required this.enabled,
    required this.onTap,
  });

  /// Icon glyph drawn at 16 logical pixels.
  final IconData icon;
  /// Accessible label, such as localized "previous page" text.
  final String semanticsLabel;
  /// Whether the page action is available.
  final bool enabled;
  /// Invoked when the navigation action is activated.
  final VoidCallback onTap;

  @override
  /// Builds the 40-pixel previous/next button.
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    return SeedPaginationPressable(
      semanticsLabel: semanticsLabel,
      enabled: enabled,
      onTap: onTap,
      builder: (context, isEngaged) => AnimatedContainer(
        duration: SeedDuration.colorTransition,
        curve: SeedCurves.easing,
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isEngaged
              ? colors.bg.transparentPressed
              : colors.bg.transparent,
          borderRadius: SeedBorderRadius.r2,
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? colors.fg.neutral : colors.fg.disabled,
        ),
      ),
    );
  }
}
