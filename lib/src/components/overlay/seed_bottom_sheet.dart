import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../foundations/colors/seed_palette.dart';
import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
import '../../foundations/motion/seed_motion.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';
import '../layout/seed_scroll_fog.dart';

/// Shows a standard SEED Bottom Sheet.
///
/// The keyboard reduces the available height and appears below the sheet.
Future<T?> showSeedBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  bool isDismissible = true,
  bool enableDrag = true,
  bool isScrollControlled = true,
}) {
  final navigator = Navigator.of(context);
  final localizations = MaterialLocalizations.of(context);
  final reduceMotion = MediaQuery.disableAnimationsOf(context);
  return navigator.push(
    _SeedBottomSheetRoute<T>(
      capturedThemes: InheritedTheme.capture(
        from: context,
        to: navigator.context,
      ),
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      elevation: 0,
      constraints: const BoxConstraints(maxWidth: 480),
      showDragHandle: false,
      useSafeArea: true,
      modalBarrierColor: context.seedColor.bg.overlay,
      barrierLabel: localizations.scrimLabel,
      barrierOnTapHint: localizations.scrimOnTapHint(
        localizations.bottomSheetLabel,
      ),
      sheetAnimationStyle: AnimationStyle(
        duration: reduceMotion ? Duration.zero : SeedDuration.d6,
        reverseDuration: reduceMotion ? Duration.zero : SeedDuration.d4,
        curve: SeedCurves.enterExpressive,
        reverseCurve: SeedCurves.exit.flipped,
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: child,
      ),
    ),
  );
}

class _SeedBottomSheetRoute<T> extends ModalBottomSheetRoute<T> {
  _SeedBottomSheetRoute({
    required super.builder,
    required super.isScrollControlled,
    super.capturedThemes,
    super.isDismissible,
    super.enableDrag,
    super.backgroundColor,
    super.elevation,
    super.constraints,
    super.showDragHandle,
    super.useSafeArea,
    super.modalBarrierColor,
    super.barrierLabel,
    super.barrierOnTapHint,
    super.sheetAnimationStyle,
  });

  @override
  Curve get barrierCurve => _SeedBarrierCurve(animation!);
}

class _SeedBarrierCurve extends Curve {
  const _SeedBarrierCurve(this.animation);

  final Animation<double> animation;

  @override
  double transformInternal(double t) =>
      (animation.status == AnimationStatus.reverse
              ? SeedCurves.exit.flipped
              : SeedCurves.enter)
          .transform(t);
}

/// Alignment of the standard bottom sheet title and description.
enum SeedBottomSheetHeaderAlign { left, center }

/// Placement of the header relative to the body (the Figma header layouts).
enum SeedBottomSheetHeaderPosition { top, bottom }

/// Bottom Sheet container component of SEED Design System.
///
/// The standard header defaults to left alignment. A custom [header] replaces
/// its title/description layout; the handle and close button remain independent.
/// Only the body scrolls; the header and footer stay in place.
/// Snap points are not currently supported.
class SeedBottomSheet extends StatefulWidget {
  final String? title;
  final String? description;
  final SeedBottomSheetHeaderAlign headerAlign;
  final SeedBottomSheetHeaderPosition headerPosition;
  final Widget? header;
  final Widget content;
  final Widget? footer;
  final bool showHandle;
  final bool showCloseButton;
  final EdgeInsetsGeometry contentPadding;

  const SeedBottomSheet({
    super.key,
    this.title,
    this.description,
    this.headerAlign = SeedBottomSheetHeaderAlign.left,
    this.headerPosition = SeedBottomSheetHeaderPosition.top,
    this.header,
    required this.content,
    this.footer,
    this.showHandle = false,
    this.showCloseButton = true,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: SeedDimension.x4,
    ),
  }) : assert(description == null || title != null || header != null);

  @override
  State<SeedBottomSheet> createState() => _SeedBottomSheetState();
}

class _SeedBottomSheetState extends State<SeedBottomSheet> {
  final ScrollController _scrollController = ScrollController();
  bool _showBottomFog = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateFog);
  }

  void _updateFog() {
    if (!mounted || !_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (!position.hasContentDimensions) return;
    final show = position.extentAfter > 0.5;
    if (show != _showBottomFog) setState(() => _showBottomFog = show);
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
    final centered = widget.headerAlign == SeedBottomSheetHeaderAlign.center;
    final textAlign = centered ? TextAlign.center : TextAlign.start;
    final titleLeft = centered && widget.showCloseButton ? 56.0 : 16.0;
    final titleRight = widget.showCloseButton ? 56.0 : 16.0;

    final sheetHeader =
        widget.header ??
        (widget.title == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        left: titleLeft,
                        right: titleRight,
                      ),
                      child: Text(
                        widget.title!,
                        textAlign: textAlign,
                        style: typography.t8Bold.copyWith(
                          color: colors.fg.neutral,
                        ),
                      ),
                    ),
                    if (widget.description != null) ...[
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          widget.description!,
                          textAlign: textAlign,
                          style: typography.t5Regular.copyWith(
                            color: colors.fg.neutralMuted,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ));

    return Align(
      alignment: Alignment.bottomCenter,
      widthFactor: 1,
      heightFactor: 1,
      child: SafeArea(
        top: false,
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxHeight = math.min(
              constraints.maxHeight,
              math.min(
                mediaQuery.size.height * 0.9,
                mediaQuery.size.height -
                    mediaQuery.padding.top -
                    mediaQuery.viewInsets.bottom,
              ),
            );
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: math.max(0, maxHeight),
                maxWidth: 480,
              ),
              child: SizedBox(
                width: double.infinity,
                // Paint the surface on Material so child ink effects remain visible.
                child: Material(
                  color: colors.bg.layerFloating,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(SeedRadius.r6),
                    topRight: Radius.circular(SeedRadius.r6),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: mediaQuery.padding.bottom,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (sheetHeader != null &&
                                widget.headerPosition ==
                                    SeedBottomSheetHeaderPosition.top)
                              sheetHeader,
                            Flexible(
                              child: Stack(
                                fit: StackFit.passthrough,
                                children: [
                                  NotificationListener<
                                    ScrollMetricsNotification
                                  >(
                                    onNotification: (_) {
                                      WidgetsBinding.instance
                                          .addPostFrameCallback(
                                            (_) => _updateFog(),
                                          );
                                      return false;
                                    },
                                    child: SingleChildScrollView(
                                      controller: _scrollController,
                                      primary: false,
                                      padding: widget.contentPadding,
                                      child: widget.content,
                                    ),
                                  ),
                                  if (_showBottomFog)
                                    Positioned(
                                      left: 0,
                                      right: 0,
                                      bottom: 0,
                                      child: SeedScrollFog(
                                        placement:
                                            SeedScrollFogPlacement.bottom,
                                        color: colors.bg.layerFloating,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (sheetHeader != null &&
                                widget.headerPosition ==
                                    SeedBottomSheetHeaderPosition.bottom)
                              sheetHeader,
                            if (widget.footer != null)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  12,
                                  16,
                                  16,
                                ),
                                child: widget.footer!,
                              ),
                          ],
                        ),
                      ),
                      if (widget.showHandle)
                        const Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Center(child: _SeedBottomSheetHandle()),
                        ),
                      if (widget.showCloseButton)
                        Positioned(
                          // The 44px touch target surrounds the 28px visual button.
                          top: 16,
                          right: 8,
                          child: _SeedBottomSheetCloseButton(),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SeedBottomSheetHandle extends StatefulWidget {
  const _SeedBottomSheetHandle();

  @override
  State<_SeedBottomSheetHandle> createState() => _SeedBottomSheetHandleState();
}

class _SeedBottomSheetHandleState extends State<_SeedBottomSheetHandle> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final dark = context.seedIsDark;
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: SizedBox(
        width: 44,
        height: 44,
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: AnimatedContainer(
              width: 36,
              height: 4,
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : SeedDuration.colorTransition,
              curve: SeedCurves.easing,
              decoration: BoxDecoration(
                color: _pressed
                    ? (dark
                          ? SeedPalette.gray500Dark
                          : SeedPalette.gray500Light)
                    : (dark
                          ? SeedPalette.gray400Dark
                          : SeedPalette.gray400Light),
                borderRadius: SeedBorderRadius.full,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SeedBottomSheetCloseButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    return SeedPressable(
      semanticsLabel: '닫기',
      enableScale: false,
      onTap: () => Navigator.of(context).pop(),
      builder: (context, pressed) => SizedBox.square(
        dimension: 44,
        child: Center(
          child: AnimatedScale(
            scale: pressed && !MediaQuery.disableAnimationsOf(context)
                ? 26 / 28
                : 1,
            duration: SeedDuration.pressedScale,
            curve: SeedCurves.pressedScale,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: pressed
                    ? colors.bg.neutralWeakPressed
                    : colors.bg.neutralWeak,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close_rounded,
                size: 14,
                color: colors.fg.neutral,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
