import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../foundations/feedback/seed_scale_feedback.dart';
import '../../foundations/motion/seed_motion.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';
import '../layout/seed_scroll_fog.dart';

/// Shows a slide-over SEED Side Panel from the right or left edge.
Future<T?> showSeedSidePanel<T>({
  required BuildContext context,
  required String title,
  String? description,
  required Widget body,
  Widget? footer,
  bool fromRight = true,
  double width = 720.0,
  bool barrierDismissible = true,
}) {
  final capturedThemes = InheritedTheme.capture(
    from: context,
    to: Navigator.of(context, rootNavigator: true).context,
  );
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: context.seedColor.bg.overlay,
    transitionDuration: MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : SeedDuration.d6,
    pageBuilder: (context, animation, secondaryAnimation) =>
        capturedThemes.wrap(
          SeedSidePanel(
            title: title,
            description: description,
            body: body,
            footer: footer,
            width: width,
            fromRight: fromRight,
            onClose: () => Navigator.of(context).pop(),
          ),
        ),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curve = animation.status == AnimationStatus.reverse
          ? SeedCurves.exitExpressive.flipped
          : SeedCurves.enterExpressive;
      return Align(
        alignment: fromRight ? Alignment.centerRight : Alignment.centerLeft,
        // Translate by the panel's own width, rather than the whole viewport.
        child: SlideTransition(
          position: animation
              .drive(CurveTween(curve: curve))
              .drive(
                Tween<Offset>(
                  begin: fromRight ? const Offset(1, 0) : const Offset(-1, 0),
                  end: Offset.zero,
                ),
              ),
          child: child,
        ),
      );
    },
  );
}

/// A modal SEED Side Panel with a fixed header/footer and scrolling body.
class SeedSidePanel extends StatefulWidget {
  const SeedSidePanel({
    super.key,
    required this.title,
    this.description,
    required this.body,
    this.footer,
    this.onClose,
    this.width = 720.0,
    this.fromRight = true,
  }) : assert(width > 0);

  final String title;
  final String? description;
  final Widget body;
  final Widget? footer;
  final VoidCallback? onClose;

  /// Preferred content width, capped at 80% of the available safe width.
  /// Official small, medium (default), and large widths are 480, 720, and 960.
  final double width;
  final bool fromRight;

  @override
  State<SeedSidePanel> createState() => _SeedSidePanelState();
}

class _SeedSidePanelState extends State<SeedSidePanel> {
  final ScrollController _scrollController = ScrollController();
  bool _scrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrolled);
  }

  void _updateScrolled() {
    final scrolled =
        _scrollController.hasClients && _scrollController.offset > 0;
    if (_scrolled != scrolled) setState(() => _scrolled = scrolled);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;
    final mediaQuery = MediaQuery.of(context);
    final insets = mediaQuery.padding;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = math.min(
          constraints.maxWidth,
          mediaQuery.size.width,
        );
        final safeWidth = math.max(0.0, availableWidth - insets.horizontal);
        final contentWidth = math.min(widget.width, safeWidth * 0.8);
        final edgeInset = widget.fromRight ? insets.right : insets.left;

        return SizedBox(
          width: contentWidth + edgeInset,
          height: double.infinity,
          child: Material(
            color: colors.bg.layerFloating,
            child: DefaultTextStyle(
              style: typography.t5Regular.copyWith(color: colors.fg.neutral),
              child: Padding(
                padding: EdgeInsets.only(
                  left: widget.fromRight ? 0 : edgeInset,
                  right: widget.fromRight ? edgeInset : 0,
                  bottom: insets.bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Stack(
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: 70 + insets.top,
                          ),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              24,
                              24 + insets.top,
                              widget.onClose == null ? 24 : 52,
                              16,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  widget.title,
                                  style: typography.t8Bold.copyWith(
                                    color: colors.fg.neutral,
                                  ),
                                ),
                                if (widget.description != null) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    widget.description!,
                                    style: typography.t5Regular.copyWith(
                                      color: colors.fg.neutralMuted,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        if (widget.onClose != null)
                          Positioned(
                            // The 52px target extends 15px around the 22px icon.
                            top: 13 + insets.top,
                            right: 9,
                            child: SeedPressable(
                              semanticsLabel: '닫기',
                              onTap: widget.onClose,
                              builder: (context, pressed) => AnimatedContainer(
                                width: 52,
                                height: 52,
                                duration: mediaQuery.disableAnimations
                                    ? Duration.zero
                                    : SeedDuration.colorTransition,
                                curve: SeedCurves.easing,
                                decoration: BoxDecoration(
                                  color: pressed
                                      ? colors.bg.transparentPressed
                                      : colors.bg.transparent,
                                  borderRadius: SeedBorderRadius.r3,
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.close,
                                    size: 22,
                                    color: colors.fg.neutralSubtle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    Expanded(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          SingleChildScrollView(
                            controller: _scrollController,
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
                            child: widget.body,
                          ),
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: IgnorePointer(
                              child: AnimatedContainer(
                                key: const ValueKey(
                                  'seed-side-panel-scroll-divider',
                                ),
                                height: 1,
                                duration: mediaQuery.disableAnimations
                                    ? Duration.zero
                                    : SeedDuration.colorTransition,
                                curve: SeedCurves.easing,
                                color: _scrolled
                                    ? colors.stroke.neutralMuted
                                    : Colors.transparent,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: SeedScrollFog(
                              placement: SeedScrollFogPlacement.bottom,
                              size: 48,
                              color: colors.bg.layerFloating,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.footer != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                        child: widget.footer,
                      ),
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
