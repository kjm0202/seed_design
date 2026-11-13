import 'package:material_ui/material_ui.dart';

import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
import '../../theme/seed_theme.dart';
import '../../foundations/motion/seed_motion.dart';
import '../overlay/seed_menu.dart';
import '../overlay/seed_anchored_overlay.dart';

/// Floating Action Button component of SEED Design System.
///
/// Prominently displays the screen's primary action floating above content.
class SeedFloatingActionButton extends StatelessWidget {
  /// Primary icon; uses 24 px in compact mode and 16 px with a label.
  final Widget icon;
  /// Optional text displayed by the extended button.
  final String? label;
  /// Explicit accessible name, defaulting to [label] when provided.
  final String? semanticsLabel;
  /// Activation callback; null disables the action.
  final VoidCallback? onPressed;
  /// Whether the label is eligible to appear; null uses `label != null`.
  final bool? extended;
  /// Optional scroll source; scrolling down hides the label, up shows it.
  /// The controller remains owned and disposed by the caller.
  final ScrollController? scrollController;
  /// Menu sections for the [SeedFloatingActionButton.menu] constructor.
  final List<SeedMenuGroupData>? menuGroups;
  /// Optional external controller for a menu-trigger floating button.
  final SeedOverlayController? menuController;
  /// Brand fill when true; neutral fill when false (default true).
  final bool isBrand;
  /// Flutter Hero transition tag; null disables Hero wrapping.
  final Object? heroTag;
  /// Optional Flutter Material tooltip.
  final String? tooltip;

  /// Creates a floating action, icon-only unless [label] is supplied.
  ///
  /// [extended] overrides the initial label visibility and [scrollController]
  /// collapses the label while scrolling down.
  const SeedFloatingActionButton({
    super.key,
    this.heroTag,
    this.tooltip,
    this.semanticsLabel,
    required this.icon,
    this.label,
    required this.onPressed,
    this.isBrand = true,
    this.extended,
    this.scrollController,
  }) : menuGroups = null,
       menuController = null;

  /// Creates a floating action with a required [label].
  /// Label visibility still follows [extended] and [scrollController].
  const SeedFloatingActionButton.extended({
    super.key,
    this.heroTag,
    this.tooltip,
    this.semanticsLabel,
    required this.icon,
    required String this.label,
    required this.onPressed,
    this.isBrand = true,
    this.extended,
    this.scrollController,
  }) : menuGroups = null,
       menuController = null;

  /// Creates a menu-trigger floating button from [groups].
  ///
  /// The menu opens above the button; [menuController] can manage its overlay.
  /// This variant uses brand styling and does not accept [onPressed].
  const SeedFloatingActionButton.menu({
    super.key,
    this.heroTag,
    this.tooltip,
    required this.icon,
    required String this.label,
    required List<SeedMenuGroupData> groups,
    this.semanticsLabel,
    this.extended,
    this.scrollController,
    this.menuController,
  }) : menuGroups = groups,
       onPressed = null,
       isBrand = true;

  @override
  Widget build(BuildContext context) {
    Widget content = _buildContent(context);
    if (tooltip != null) content = Tooltip(message: tooltip!, child: content);
    if (heroTag != null) content = Hero(tag: heroTag!, child: content);
    return content;
  }

  Widget _buildContent(BuildContext context) {
    if (menuGroups != null) {
      return SeedMenuTrigger(
        controller: menuController,
        side: SeedOverlaySide.top,
        align: SeedOverlayAlign.end,
        triggerBuilder: (context, open, toggle) => Semantics(
          expanded: open,
          child: SeedFloatingActionButton(
            icon: icon,
            label: label,
            semanticsLabel: semanticsLabel,
            onPressed: toggle,
            extended: extended,
            scrollController: scrollController,
          ),
        ),
        builder: (_) => SeedMenu(groups: menuGroups!),
      );
    }
    return _SeedFabVisibility(
      extended: extended ?? label != null,
      controller: scrollController,
      builder: (context, showLabel) {
        final label = showLabel ? this.label : null;
        final colors = context.seedColor;
        final typography = context.seedTypography;
        final shadows = context.seedShadows;

        final Color bgColor = isBrand
            ? colors.bg.brandSolid
            : colors.bg.neutralSolid;
        final Color fgColor = isBrand
            ? colors.fg.onBrandSolid
            : colors.fg.onNeutralSolid;

        return AnimatedSize(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : SeedDuration.d4,
          curve: SeedCurves.easing,
          child: SeedPressable(
            focusBorderRadius: SeedBorderRadius.full,
            semanticsLabel: semanticsLabel ?? this.label,
            onTap: onPressed,
            builder: (context, isPressed) => AnimatedContainer(
              duration: SeedDuration.colorTransition,
              curve: SeedCurves.easing,
              decoration: BoxDecoration(
                color: isPressed
                    ? (isBrand
                          ? colors.bg.brandSolidPressed
                          : colors.bg.neutralSolidPressed)
                    : bgColor,
                borderRadius: SeedBorderRadius.full,
                boxShadow: shadows.s3,
              ),
              child: Container(
                constraints: label == null
                    ? const BoxConstraints.tightFor(width: 56.0, height: 56.0)
                    : const BoxConstraints(minHeight: 48.0),
                padding: label != null
                    ? const EdgeInsets.symmetric(
                        horizontal: SeedDimension.x4_5,
                        vertical: SeedDimension.x3,
                      )
                    : EdgeInsets.zero,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconTheme(
                      data: IconThemeData(
                        color: fgColor,
                        size: label == null ? 24 : 16,
                      ),
                      child: icon,
                    ),
                    if (label != null) ...[
                      const SizedBox(width: SeedDimension.x1),
                      Text(
                        label,
                        style: typography.t5Bold.copyWith(color: fgColor),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SeedFabVisibility extends StatefulWidget {
  const _SeedFabVisibility({
    required this.extended,
    this.controller,
    required this.builder,
  });
  final bool extended;
  final ScrollController? controller;
  final Widget Function(BuildContext, bool) builder;
  @override
  State<_SeedFabVisibility> createState() => _SeedFabVisibilityState();
}

class _SeedFabVisibilityState extends State<_SeedFabVisibility> {
  bool _visible = true;
  double _last = 0;
  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_scroll);
  }

  void _scroll() {
    final position = widget.controller!.position.pixels;
    if ((position - _last).abs() < 2) return;
    final visible = position <= 0 || position < _last;
    _last = position;
    if (visible != _visible) setState(() => _visible = visible);
  }

  @override
  void didUpdateWidget(_SeedFabVisibility oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_scroll);
      widget.controller?.addListener(_scroll);
      _last = 0;
      _visible = true;
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_scroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, widget.extended && _visible);
}
