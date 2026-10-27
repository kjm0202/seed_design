import 'dart:math' as math;
import 'dart:ui' show SemanticsRole;

import 'package:material_ui/material_ui.dart';

import '../../foundations/feedback/seed_scale_feedback.dart';
import '../../foundations/motion/seed_motion.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';
import '../layout/seed_scroll_fog.dart';
import 'seed_anchored_overlay.dart';

/// Official width presets for [SeedSidePanel].
enum SeedSidePanelSize {
  small(480.0),
  medium(720.0),
  large(960.0);

  const SeedSidePanelSize(this.width);
  final double width;
}

/// Shows a slide-over SEED Side Panel from the right or left edge.
Future<T?> showSeedSidePanel<T>({
  required BuildContext context,
  required String title,
  Widget? titleWidget,
  String? description,
  Widget? descriptionWidget,
  required Widget body,
  EdgeInsetsGeometry? bodyPadding,
  Widget? footer,
  bool fromRight = true,
  SeedSidePanelSize size = SeedSidePanelSize.medium,
  double? width,
  double? maxWidth,
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
            titleWidget: titleWidget,
            description: description,
            descriptionWidget: descriptionWidget,
            body: body,
            bodyPadding: bodyPadding,
            footer: footer,
            size: size,
            width: width,
            maxWidth: maxWidth,
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
    this.titleWidget,
    this.description,
    this.descriptionWidget,
    required this.body,
    this.bodyPadding,
    this.footer,
    this.onClose,
    this.size = SeedSidePanelSize.medium,
    double? width,
    this.maxWidth,
    this.fromRight = true,
    this.showCloseButton = true,
  }) : _width = width,
       assert(width == null || width > 0),
       assert(maxWidth == null || maxWidth > 0);

  final String title;
  final Widget? titleWidget;
  final String? description;
  final Widget? descriptionWidget;
  final Widget body;
  final EdgeInsetsGeometry? bodyPadding;
  final Widget? footer;
  final VoidCallback? onClose;
  final SeedSidePanelSize size;
  final double? _width;
  final double? maxWidth;

  /// Preferred content width, capped at 80% of the available safe width on mobile.
  /// Official small, medium (default), and large widths are 480, 720, and 960.
  double get width => _width ?? size.width;
  final bool fromRight;
  final bool showCloseButton;

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

  void _handleClose(BuildContext context, SeedOverlayDismissReason reason) {
    if (widget.onClose != null) {
      widget.onClose!();
    } else {
      SeedOverlayScope.maybeOf(context)?.close(reason);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;
    final mediaQuery = MediaQuery.of(context);
    final insets = mediaQuery.padding;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      scopesRoute: true,
      namesRoute: true,
      role: SemanticsRole.dialog,
      label: widget.title,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = math.min(
            constraints.maxWidth,
            mediaQuery.size.width,
          );
          final safeWidth = math.max(0.0, availableWidth - insets.horizontal);
          final rawCap =
              mediaQuery.size.width < 768 ? safeWidth * 0.8 : safeWidth;
          final effectiveCap = widget.maxWidth != null
              ? math.min(widget.maxWidth!, safeWidth)
              : rawCap;
          final contentWidth = math.min(widget.width, effectiveCap);
          final edgeInset = widget.fromRight ? insets.right : insets.left;
          final resolvedBodyPadding =
              widget.bodyPadding?.resolve(Directionality.of(context)) ??
              const EdgeInsets.fromLTRB(24, 0, 24, 48);

          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragEnd: (details) {
              final velocity = details.primaryVelocity ?? 0;
              if ((widget.fromRight && velocity > 300) ||
                  (!widget.fromRight && velocity < -300)) {
                _handleClose(context, SeedOverlayDismissReason.outside);
              }
            },
            child: SizedBox(
              width: contentWidth + edgeInset,
              height: double.infinity,
              child: Material(
                color: colors.bg.layerFloating,
                child: DefaultTextStyle(
                  style: typography.t5Regular.copyWith(
                    color: colors.fg.neutral,
                  ),
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
                                  !widget.showCloseButton ? 24 : 52,
                                  16,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    DefaultTextStyle(
                                      style: typography.t8Bold.copyWith(
                                        color: colors.fg.neutral,
                                      ),
                                      child:
                                          widget.titleWidget ??
                                          Text(
                                            widget.title,
                                            style: typography.t8Bold.copyWith(
                                              color: colors.fg.neutral,
                                            ),
                                          ),
                                    ),
                                    if (widget.descriptionWidget != null ||
                                        widget.description != null) ...[
                                      const SizedBox(height: 6),
                                      DefaultTextStyle(
                                        style: typography.t5Regular.copyWith(
                                          color: colors.fg.neutralMuted,
                                        ),
                                        child:
                                            widget.descriptionWidget ??
                                            Text(
                                              widget.description!,
                                              style: typography.t5Regular
                                                  .copyWith(
                                                    color:
                                                        colors.fg.neutralMuted,
                                                  ),
                                            ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            if (widget.showCloseButton)
                              Positioned(
                                // The 52px target extends 15px around the 22px icon.
                                top: 13 + insets.top,
                                right: 9,
                                child: SeedPressable(
                                  semanticsLabel: '닫기',
                                  onTap: () => _handleClose(
                                    context,
                                    SeedOverlayDismissReason.closeButton,
                                  ),
                                  builder: (context, pressed) =>
                                      AnimatedContainer(
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
                                padding: resolvedBodyPadding,
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
            ),
          );
        },
      ),
    );
  }
}
