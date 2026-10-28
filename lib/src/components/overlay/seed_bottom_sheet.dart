import 'seed_anchored_overlay.dart';

import 'dart:math' as math;

import 'package:flutter/foundation.dart' show listEquals, ValueListenable;
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
  bool modal = true,
  ValueListenable<bool>? modalListenable,
  bool isDismissible = true,
  bool enableDrag = true,
  bool isScrollControlled = true,
  List<SeedSheetSnapPoint>? snapPoints,
  int initialSnapIndex = 0,
  int? fadeFromIndex,
  bool handleOnly = false,
  SeedSheetController? snapController,
  ValueChanged<int>? onSnapChanged,
  bool skipAnimation = false,
}) {
  final navigator = Navigator.of(context);
  final localizations = MaterialLocalizations.of(context);
  final reduceMotion = skipAnimation || MediaQuery.disableAnimationsOf(context);
  late final _SeedBottomSheetRoute<T> route;
  route = _SeedBottomSheetRoute<T>(
    capturedThemes: InheritedTheme.capture(
      from: context,
      to: navigator.context,
    ),
    modal: modal,
    modalListenable: modalListenable,
    isDismissible: isDismissible,
    enableDrag: snapPoints == null && enableDrag,
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
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: snapPoints == null
          ? child
          : SeedSnappingBottomSheet(
              sheet: child is SeedBottomSheet
                  ? child
                  : SeedBottomSheet(content: child, showHandle: true),
              snapPoints: snapPoints,
              initialSnapIndex: initialSnapIndex,
              controller: snapController,
              onSnapChanged: onSnapChanged,
              handleOnly: handleOnly,
              fadeFromIndex: fadeFromIndex,
              onFadeChanged: route.setSnapFade,
              dismissible: isDismissible,
            ),
    ),
  );
  return navigator.push(route);
}

class _SeedBottomSheetRoute<T> extends ModalBottomSheetRoute<T> {
  _SeedBottomSheetRoute({
    required this.modal,
    this.modalListenable,
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
  }) {
    modalListenable?.addListener(_modalChanged);
  }

  final bool modal;
  final ValueListenable<bool>? modalListenable;
  bool get _modal => modalListenable?.value ?? modal;
  void _modalChanged() => changedInternalState();

  @override
  Widget buildModalBarrier() =>
      _modal ? super.buildModalBarrier() : const SizedBox.shrink();

  @override
  void dispose() {
    modalListenable?.removeListener(_modalChanged);
    super.dispose();
  }

  double _snapFade = 1;
  void setSnapFade(double value) {
    if (value == _snapFade) return;
    _snapFade = value;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isActive) changedInternalState();
    });
  }

  @override
  Color get barrierColor =>
      super.barrierColor.withValues(alpha: super.barrierColor.a * _snapFade);
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
/// Use SeedSnappingBottomSheet or showSeedBottomSheet(snapPoints:) for resizing.
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
  final ScrollController? scrollController;
  final bool expand;
  final double? maxHeight;
  final ValueChanged<double>? onHandleDrag;
  final VoidCallback? onHandleDragEnd;
  final VoidCallback? onHandleTap;

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
    this.scrollController,
    this.expand = false,
    this.maxHeight,
    this.onHandleDrag,
    this.onHandleDragEnd,
    this.onHandleTap,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: SeedDimension.x4,
    ),
  }) : assert(description == null || title != null || header != null);

  @override
  State<SeedBottomSheet> createState() => _SeedBottomSheetState();
}

class _SeedBottomSheetState extends State<SeedBottomSheet> {
  late ScrollController _scrollController =
      widget.scrollController ?? ScrollController();
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
  void didUpdateWidget(SeedBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      final old = _scrollController;
      old.removeListener(_updateFog);
      _scrollController = widget.scrollController ?? ScrollController();
      _scrollController.addListener(_updateFog);
      if (oldWidget.scrollController == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateFog);
    if (widget.scrollController == null) _scrollController.dispose();
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
                widget.maxHeight ??
                    (widget.expand
                        ? double.infinity
                        : mediaQuery.size.height * 0.9),
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
                height: widget.expand ? math.max(0, maxHeight) : null,
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
                      _SeedSheetViewport(
                        expand: widget.expand,
                        child: Padding(
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
                      ),
                      if (widget.showHandle)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: widget.onHandleTap,
                              // A long press must not cycle the snap points.
                              onLongPress: widget.onHandleTap == null
                                  ? null
                                  : () {},
                              onVerticalDragUpdate: widget.onHandleDrag == null
                                  ? null
                                  : (details) =>
                                        widget.onHandleDrag!(details.delta.dy),
                              onVerticalDragEnd: widget.onHandleDragEnd == null
                                  ? null
                                  : (_) => widget.onHandleDragEnd!(),
                              child: const _SeedBottomSheetHandle(),
                            ),
                          ),
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
      onTap: () {
        final scope = SeedOverlayScope.maybeOf(context);
        if (scope != null) {
          scope.close(SeedOverlayDismissReason.closeButton);
        } else {
          Navigator.of(context).pop();
        }
      },
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

class SeedSheetSnapPoint {
  const SeedSheetSnapPoint.fraction(double value)
    : assert(value > 0 && value <= 1),
      fraction = value,
      pixels = null;
  const SeedSheetSnapPoint.pixels(double value)
    : assert(value > 0),
      pixels = value,
      fraction = null;
  final double? fraction, pixels;
  double resolve(double height) =>
      (fraction ?? pixels! / height).clamp(0.01, 1);
}

class SeedSheetController extends ChangeNotifier {
  SeedSheetController({int initialIndex = 0}) : _index = initialIndex;
  int _index;
  int get index => _index;
  void snapTo(int index) {
    _index = index;
    notifyListeners();
  }

  void _synchronize(int index) {
    if (_index == index) return;
    _index = index;
    notifyListeners();
  }
}

/// Fraction/pixel snap points, scroll-to-expand, and handle-only resizing.
class SeedSnappingBottomSheet extends StatefulWidget {
  const SeedSnappingBottomSheet({
    super.key,
    required this.sheet,
    this.snapPoints = const [
      SeedSheetSnapPoint.fraction(0.1),
      SeedSheetSnapPoint.fraction(0.5),
      SeedSheetSnapPoint.fraction(0.9),
    ],
    this.initialSnapIndex = 0,
    this.controller,
    this.onSnapChanged,
    this.handleOnly = false,
    this.fadeFromIndex,
    this.onFadeChanged,
    this.dismissible = true,
  });
  final SeedBottomSheet sheet;
  final List<SeedSheetSnapPoint> snapPoints;
  final int initialSnapIndex;
  final SeedSheetController? controller;
  final ValueChanged<int>? onSnapChanged;
  final bool handleOnly;
  final bool dismissible;
  final int? fadeFromIndex;
  final ValueChanged<double>? onFadeChanged;
  @override
  State<SeedSnappingBottomSheet> createState() =>
      _SeedSnappingBottomSheetState();
}

class _SeedSnappingBottomSheetState extends State<SeedSnappingBottomSheet> {
  final DraggableScrollableController _drag = DraggableScrollableController();
  final ScrollController _body = ScrollController();
  late int _index = widget.controller?.index ?? widget.initialSnapIndex;
  double? _fraction;
  List<double> _points = [];
  List<double> _sortedPoints = [];
  double _belowMin = 0;
  bool _draggingHandle = false;
  bool _syncingController = false;
  int? _snappingTo;
  int _snapGeneration = 0;
  void _dismissDrag() {
    _belowMin = 0;
    if (!widget.dismissible) {
      _snap(_points.indexOf(_sortedPoints.first));
      return;
    }
    final scope = SeedOverlayScope.maybeOf(context);
    if (scope != null) {
      scope.close(SeedOverlayDismissReason.drag);
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  void initState() {
    super.initState();
    assert(widget.snapPoints.isNotEmpty);
    widget.controller?.addListener(_controllerChanged);
  }

  void _controllerChanged() {
    if (mounted && !_syncingController) _snap(widget.controller!.index);
  }

  void _synchronizeController() {
    _syncingController = true;
    try {
      widget.controller?._synchronize(_index);
    } finally {
      _syncingController = false;
    }
  }

  void _setIndex(int index) {
    final changed = _index != index;
    _index = index;
    _synchronizeController();
    if (changed) widget.onSnapChanged?.call(index);
  }

  void _settled() {
    if (_snappingTo != null || _draggingHandle || _fraction == null) return;
    if ((_points[_index] - _fraction!).abs() < .001) return;
    final index = _points.indexWhere(
      (point) => (point - _fraction!).abs() < .001,
    );
    if (index >= 0) _setIndex(index);
  }

  void _interruptSnap() {
    _snapGeneration++;
    _snappingTo = null;
  }

  void _snap(int index) async {
    if (_points.isEmpty) return;
    final target = index.clamp(0, _points.length - 1);
    final generation = ++_snapGeneration;
    _snappingTo = target;
    setState(() {
      _draggingHandle = false;
      _fraction = _points[target];
    });
    _setIndex(target);
    _reportFade();
    if (!widget.handleOnly && _drag.isAttached) {
      await _drag.animateTo(
        _fraction!,
        duration: MediaQuery.disableAnimationsOf(context)
            ? const Duration(milliseconds: 1)
            : SeedDuration.d4,
        curve: SeedCurves.easing,
      );
    }
    if (!mounted || generation != _snapGeneration) return;
    _snappingTo = null;
    if (!widget.handleOnly && _drag.isAttached) _fraction = _drag.size;
    _reportFade();
  }

  void _reportFade() {
    final index = widget.fadeFromIndex;
    if (index == null || _points.isEmpty || _fraction == null) return;
    final target = _points[index.clamp(0, _points.length - 1)];
    final fraction = target <= _sortedPoints.first
        ? 1.0
        : ((_fraction! - _sortedPoints.first) / (target - _sortedPoints.first))
              .clamp(0.0, 1.0);
    widget.onFadeChanged?.call(fraction);
  }

  void _finishDrag() {
    if (_belowMin > 48) {
      _dismissDrag();
      return;
    }
    _belowMin = 0;
    if (_fraction == null) return;
    var nearest = 0;
    for (var i = 1; i < _points.length; i++) {
      if ((_points[i] - _fraction!).abs() <
          (_points[nearest] - _fraction!).abs()) {
        nearest = i;
      }
    }
    _snap(nearest);
  }

  @override
  void didUpdateWidget(SeedSnappingBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_controllerChanged);
      widget.controller?.addListener(_controllerChanged);
      if (widget.controller != null) _controllerChanged();
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_controllerChanged);
    _drag.dispose();
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final available = constraints.hasBoundedHeight
          ? constraints.maxHeight
          : MediaQuery.sizeOf(context).height;
      // Public indices follow the caller's order. Only the physical snap sizes
      // passed to DraggableScrollableSheet must be sorted and unique.
      final points = widget.snapPoints
          .map((point) => point.resolve(available))
          .toList();
      final sortedPoints = points.toSet().toList()..sort();
      // DraggableScrollableSheet treats a new snapSizes list as a configuration
      // change and starts a ballistic snap. Keep it stable during our own snaps.
      if (!listEquals(_points, points)) _points = points;
      if (!listEquals(_sortedPoints, sortedPoints)) {
        _sortedPoints = sortedPoints;
      }
      _index = _index.clamp(0, _points.length - 1);
      _fraction ??= _points[_index];
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _synchronizeController();
          _reportFade();
        }
      });
      Widget sheet(ScrollController controller) {
        final source = widget.sheet;
        return SeedBottomSheet(
          key: source.key,
          title: source.title,
          maxHeight: source.maxHeight,
          description: source.description,
          headerAlign: source.headerAlign,
          headerPosition: source.headerPosition,
          header: source.header,
          content: source.content,
          footer: source.footer,
          showHandle: source.showHandle,
          showCloseButton: source.showCloseButton,
          contentPadding: source.contentPadding,
          expand: true,
          scrollController: controller,
          onHandleDrag: (delta) {
            _interruptSnap();
            final current = !widget.handleOnly && _drag.isAttached
                ? _drag.size
                : _fraction!;
            if (current <= _sortedPoints.first + .001 && delta > 0) {
              _belowMin += delta;
            } else {
              _belowMin = 0;
            }
            _draggingHandle = true;
            final next = (current - delta / available).clamp(
              _sortedPoints.first,
              _sortedPoints.last,
            );
            if (widget.handleOnly) {
              setState(() => _fraction = next);
            } else if (_drag.isAttached) {
              _drag.jumpTo(next);
              _fraction = next;
            }
            _reportFade();
          },
          onHandleDragEnd: _finishDrag,
          onHandleTap: () {
            if (_index + 1 < _points.length) {
              _snap(_index + 1);
            } else if (widget.dismissible) {
              final scope = SeedOverlayScope.maybeOf(context);
              if (scope != null) {
                scope.close(SeedOverlayDismissReason.action);
              } else {
                Navigator.of(context).maybePop();
              }
            }
          },
        );
      }

      if (widget.handleOnly) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
            duration: _draggingHandle || MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : SeedDuration.d4,
            curve: SeedCurves.easing,
            height: available * _fraction!,
            child: sheet(_body),
          ),
        );
      }
      return NotificationListener<DraggableScrollableNotification>(
        onNotification: (notification) {
          _fraction = notification.extent;
          _reportFade();
          return false;
        },
        child: NotificationListener<ScrollEndNotification>(
          onNotification: (notification) {
            _settled();
            return false;
          },
          child: Listener(
            onPointerDown: (_) => _interruptSnap(),
            child: DraggableScrollableSheet(
              controller: _drag,
              initialChildSize: _points[_index],
              minChildSize: _sortedPoints.first,
              maxChildSize: _sortedPoints.last,
              snap: true,
              snapSizes: _sortedPoints,
              shouldCloseOnMinExtent: false,
              expand: false,
              builder: (context, controller) => sheet(controller),
            ),
          ),
        ),
      );
    },
  );
}

// Keep the same viewport ancestors across snap heights. Reparenting the body at
// the minimum height detaches its scroll position and cancels resizing animations.
// The header/footer can exceed the exposed surface at the smallest snap point.
class _SeedSheetViewport extends StatelessWidget {
  const _SeedSheetViewport({required this.expand, required this.child});
  final bool expand;
  final Widget child;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (!expand) return child;
      final viewportHeight = math.max(240.0, constraints.maxHeight);
      return ClipRect(
        child: OverflowBox(
          alignment: Alignment.topCenter,
          minHeight: viewportHeight,
          maxHeight: viewportHeight,
          child: SizedBox(height: viewportHeight, child: child),
        ),
      );
    },
  );
}
