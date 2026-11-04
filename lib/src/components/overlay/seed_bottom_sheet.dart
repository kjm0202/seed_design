import '../../localization/seed_localizations.dart';
import 'seed_anchored_overlay.dart';
import 'seed_sheet_drag.dart';

import 'dart:math' as math;

import 'package:flutter/foundation.dart' show listEquals, ValueListenable;
import 'package:flutter/rendering.dart';
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
///
/// Supply exactly one of [child] or [builder]. [useRootNavigator] defaults to
/// false; [routeSettings], [requestFocus], [anchorPoint], [constraints],
/// [useSafeArea], [barrierLabel] and [barrierColor] configure the Flutter route.
/// [modal] adds a scrim by default; [modalListenable] changes its visibility
/// while the route is open. [isDismissible] controls backdrop dismissal and
/// snap-to-close behavior; [enableDrag] enables downward drag gestures.
/// [snapPoints] enables fractional/pixel snapping, [initialSnapIndex] chooses
/// the initial stop, [fadeFromIndex] controls scrim fade, and [snapController]
/// drives indices programmatically; [onSnapChanged] observes index changes.
/// [isScrollControlled] defaults true, [handleOnly] limits snap dragging to
/// the handle, and [skipAnimation] disables the entrance/exit transition.
Future<T?> showSeedBottomSheet<T>({
  required BuildContext context,
  Widget? child,
  WidgetBuilder? builder,
  bool useRootNavigator = false,
  RouteSettings? routeSettings,
  bool? requestFocus,
  Offset? anchorPoint,
  BoxConstraints? constraints = const BoxConstraints(maxWidth: 480),
  bool useSafeArea = true,
  String? barrierLabel,
  Color? barrierColor,
  bool modal = true,
  ValueListenable<bool>? modalListenable,
  bool isDismissible = true,
  bool enableDrag = true,
  bool isScrollControlled = true,
  List<SeedSheetSnapPoint>? snapPoints,
  int initialSnapIndex = 0,
  int? fadeFromIndex,

  /// The maximum React content height as a fraction of the viewport. Its
  /// snap transforms still use the full viewport height.
  double snapContentHeightFraction = .9,

  /// Keep the sheet anchored while the keyboard reduces its usable height.
  bool fixed = false,

  /// Allow input focus to move the sheet above the on-screen keyboard.
  bool repositionInputs = true,
  bool handleOnly = false,
  SeedSheetController? snapController,
  ValueChanged<int>? onSnapChanged,
  bool skipAnimation = false,
}) {
  assert(
    (child == null) != (builder == null),
    'Provide exactly one of child or builder.',
  );
  assert(snapContentHeightFraction > 0 && snapContentHeightFraction <= 1);
  final navigator = Navigator.of(context, rootNavigator: useRootNavigator);
  final localizations = MaterialLocalizations.of(context);
  final reduceMotion = skipAnimation || MediaQuery.disableAnimationsOf(context);
  late final _SeedBottomSheetRoute<T> route;
  route = _SeedBottomSheetRoute<T>(
    capturedThemes: InheritedTheme.capture(
      from: context,
      to: navigator.context,
    ),
    settings: routeSettings,
    requestFocus: requestFocus,
    anchorPoint: anchorPoint,
    modal: modal,
    modalListenable: modalListenable,
    initialSnapFade:
        snapPoints == null ||
            initialSnapIndex >= (fadeFromIndex ?? snapPoints.length - 1)
        ? 1
        : 0,
    isDismissible: isDismissible,
    enableDrag: false,
    isScrollControlled: isScrollControlled,
    backgroundColor: Colors.transparent,
    elevation: 0,
    constraints: constraints,
    showDragHandle: false,
    useSafeArea: useSafeArea,
    modalBarrierColor: barrierColor ?? context.seedColor.bg.overlay,
    barrierLabel: barrierLabel ?? localizations.scrimLabel,
    barrierOnTapHint: localizations.scrimOnTapHint(
      localizations.bottomSheetLabel,
    ),
    sheetAnimationStyle: AnimationStyle(
      duration: reduceMotion ? Duration.zero : SeedDuration.d6,
      reverseDuration: reduceMotion ? Duration.zero : SeedDuration.d4,
      curve: SeedCurves.enterExpressive,
      reverseCurve: SeedCurves.exit.flipped,
    ),
    builder: (context) {
      final content = builder?.call(context) ?? child!;
      final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
      return Padding(
        padding: EdgeInsets.only(
          top: fixed ? keyboardInset : 0,
          bottom: !fixed && repositionInputs ? keyboardInset : 0,
        ),
        child: snapPoints == null
            ? (enableDrag
                  ? SeedSheetDragDismiss(
                      onProgress: route.setSnapFade,
                      onDismiss: () {
                        if (route.isCurrent) navigator.pop();
                      },
                      child: content,
                    )
                  : content)
            : SeedSnappingBottomSheet(
                sheet: content is SeedBottomSheet
                    ? content
                    : SeedBottomSheet(content: content, showHandle: true),
                snapPoints: snapPoints,
                initialSnapIndex: initialSnapIndex,
                controller: snapController,
                onSnapChanged: onSnapChanged,
                handleOnly: handleOnly,
                fadeFromIndex: fadeFromIndex ?? snapPoints.length - 1,
                contentHeightFraction: snapContentHeightFraction,
                onFadeChanged: route.setSnapFade,
                dismissible: isDismissible,
              ),
      );
    },
  );
  return navigator.push(route);
}

class _SeedBottomSheetRoute<T> extends ModalBottomSheetRoute<T> {
  _SeedBottomSheetRoute({
    super.settings,
    super.requestFocus,
    super.anchorPoint,
    required this.modal,
    required double initialSnapFade,
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
  }) : _snapFade = initialSnapFade {
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

  double _snapFade;
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

/// Alignment of the standard bottom-sheet header: `left` or `center`.
enum SeedBottomSheetHeaderAlign {
  /// Align title and description to the left.
  left,
  /// Center title and description.
  center,
}

/// Header placement for the Figma variants: `top` before body, or `bottom`
/// after body.
enum SeedBottomSheetHeaderPosition {
  /// Place the header before the body.
  top,
  /// Place the header after the body.
  bottom,
}

/// Bottom Sheet container component of SEED Design System.
///
/// The standard header defaults to left alignment. A custom [header] replaces
/// its title/description layout; the handle and close button remain independent.
/// Only the body scrolls; the header and footer stay in place.
/// Use SeedSnappingBottomSheet or showSeedBottomSheet(snapPoints:) for resizing.
///
/// This is a composable content surface: wrap it in [showSeedBottomSheet] or a
/// modal trigger for a route, Escape behavior, and backdrop dismissal.
class SeedBottomSheet extends StatefulWidget {
  /// Optional title above the main [content].
  final String? title;
  /// Optional description (requires [title] or a custom [header]).
  final String? description;
  /// Title/description alignment, left by default.
  final SeedBottomSheetHeaderAlign headerAlign;
  /// Header order relative to body, top by default.
  final SeedBottomSheetHeaderPosition headerPosition;
  /// Custom header replacing automatic title/description composition.
  final Widget? header;
  /// Required scrollable body content.
  final Widget content;
  /// Optional fixed footer below content.
  final Widget? footer;
  /// Whether to display the top drag-handle indicator (false by default).
  final bool showHandle;
  /// Whether to display the close button (true by default).
  final bool showCloseButton;

  /// Overrides the close button action. When null, uses the standard overlay
  /// or Navigator dismissal behavior.
  final VoidCallback? onClosePressed;
  /// Padding around the body; 16px horizontally by default.
  final EdgeInsetsGeometry contentPadding;
  /// Optional externally-owned body scroll controller.
  final ScrollController? scrollController;
  /// Fills available height when true; otherwise shrink-wraps up to 90vh.
  final bool expand;
  /// Optional explicit height cap in logical pixels.
  final double? maxHeight;
  /// Receives vertical handle drag deltas, in logical pixels.
  final ValueChanged<double>? onHandleDrag;
  /// Called when a handle drag gesture finishes.
  final VoidCallback? onHandleDragEnd;
  /// Called when the handle is tapped.
  final VoidCallback? onHandleTap;

  /// Creates sheet contents with independent header, body, footer and handle.
  ///
  /// [expand] defaults false; [maxHeight] can override the intrinsic height
  /// limit. [scrollController] remains owned by the caller when supplied.
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
    this.onClosePressed,
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
                          child: _SeedSheetSections(
                            // The body keeps at least one real text line so
                            // long headers/footers never consume its entire
                            // scrollport. No fixed viewport percentage.
                            minBodyHeight: mediaQuery.textScaler.scale(
                              (typography.t5Regular.fontSize ?? 16) *
                                  (typography.t5Regular.height ?? 1),
                            ),
                            hasHeader: sheetHeader != null,
                            headerAfterBody:
                                widget.headerPosition ==
                                SeedBottomSheetHeaderPosition.bottom,
                            header: sheetHeader == null
                                ? const SizedBox.shrink()
                                : CustomScrollView(
                                    shrinkWrap: true,
                                    primary: false,
                                    slivers: [
                                      SliverToBoxAdapter(child: sheetHeader),
                                    ],
                                  ),
                            body: Stack(
                              fit: StackFit.passthrough,
                              children: [
                                NotificationListener<ScrollMetricsNotification>(
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
                                      placement: SeedScrollFogPlacement.bottom,
                                      color: colors.bg.layerFloating,
                                    ),
                                  ),
                              ],
                            ),
                            footer: widget.footer == null
                                ? const SizedBox.shrink()
                                : CustomScrollView(
                                    shrinkWrap: true,
                                    primary: false,
                                    slivers: [
                                      SliverToBoxAdapter(
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            16,
                                            12,
                                            16,
                                            16,
                                          ),
                                          child: widget.footer!,
                                        ),
                                      ),
                                    ],
                                  ),
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
                              // The official handle is presentational; the
                              // sheet's own close action stays accessible.
                              excludeFromSemantics: true,
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
                          child: _SeedBottomSheetCloseButton(
                            onPressed: widget.onClosePressed,
                          ),
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

/// Measures the non-flexing footer first, then the header, and gives the body
/// the exact remaining space. The ordinary Column measures both fixed regions
/// without a height budget, so large text can overflow a 90vh sheet before
/// Flexible(body) is laid out. This uses no arbitrary fixed-height percentage.
///
/// Headers/footers smaller than their budget retain their intrinsic height.
/// Only when one is oversized does its containing shrink-wrap viewport scroll.
class _SeedSheetSections extends MultiChildRenderObjectWidget {
  _SeedSheetSections({
    required Widget header,
    required Widget body,
    required Widget footer,
    required this.hasHeader,
    required this.headerAfterBody,
    required this.minBodyHeight,
  }) : super(children: [header, body, footer]);

  final bool hasHeader;
  final bool headerAfterBody;
  final double minBodyHeight;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderSeedSheetSections(
        hasHeader: hasHeader,
        headerAfterBody: headerAfterBody,
        minBodyHeight: minBodyHeight,
      );

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderSeedSheetSections renderObject,
  ) {
    renderObject
      ..hasHeader = hasHeader
      ..headerAfterBody = headerAfterBody
      ..minBodyHeight = minBodyHeight;
  }
}

class _SeedSheetParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderSeedSheetSections extends RenderBox
    with
        ContainerRenderObjectMixin<
          RenderBox,
          ContainerBoxParentData<RenderBox>
        >,
        RenderBoxContainerDefaultsMixin<
          RenderBox,
          ContainerBoxParentData<RenderBox>
        > {
  _RenderSeedSheetSections({
    required this._hasHeader,
    required this._headerAfterBody,
    required this._minBodyHeight,
  });

  bool _hasHeader;
  bool get hasHeader => _hasHeader;
  set hasHeader(bool value) {
    if (_hasHeader == value) return;
    _hasHeader = value;
    markNeedsLayout();
  }

  bool _headerAfterBody;
  bool get headerAfterBody => _headerAfterBody;
  set headerAfterBody(bool value) {
    if (_headerAfterBody == value) return;
    _headerAfterBody = value;
    markNeedsLayout();
  }

  double _minBodyHeight;
  double get minBodyHeight => _minBodyHeight;
  set minBodyHeight(double value) {
    if (_minBodyHeight == value) return;
    _minBodyHeight = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _SeedSheetParentData) {
      child.parentData = _SeedSheetParentData();
    }
  }

  @override
  void performLayout() {
    final header = firstChild!;
    final body = childAfter(header)!;
    final footer = childAfter(body)!;
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;
    assert(width.isFinite && height.isFinite);

    final line = math.min(height, math.max(0, minBodyHeight));
    // Keep a readable body line even when both header and footer contain
    // multi-line text. A present header also needs a line when the footer
    // itself must scroll. Both reserves come from the current SEED type token.
    final headerReserve = hasHeader ? math.min(line, height - line) : 0.0;
    final footerLimit = math.max(0.0, height - line - headerReserve);
    void layoutSection(RenderBox child, double maxHeight) => child.layout(
      BoxConstraints(minWidth: width, maxWidth: width, maxHeight: maxHeight),
      parentUsesSize: true,
    );

    layoutSection(footer, footerLimit);
    layoutSection(header, math.max(0.0, height - footer.size.height - line));
    final bodyLimit = math.max(
      0.0,
      height - footer.size.height - header.size.height,
    );
    layoutSection(body, bodyLimit);
    final bodyHeight = body.size.height;
    // Expanded (snapping) sheets still fill their viewport, but like the
    // official recipe the body is not flex-grow: the footer follows the
    // content and any spare height stays below it.
    size = constraints.constrain(
      Size(width, header.size.height + bodyHeight + footer.size.height),
    );

    var top = 0.0;
    void place(RenderBox child) {
      (child.parentData! as ContainerBoxParentData<RenderBox>).offset = Offset(
        0,
        top,
      );
      top += child.size.height;
    }

    if (!headerAfterBody) place(header);
    place(body);
    if (headerAfterBody) place(header);
    place(footer);
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
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
  const _SeedBottomSheetCloseButton({this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    return SeedPressable(
      semanticsLabel: SeedLocalizations.label(context, SeedLabel.close),
      enableScale: false,
      onTap: () {
        if (onPressed != null) {
          onPressed!();
          return;
        }
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

/// One bottom-sheet snap stop, expressed as viewport fraction or pixel height.
///
/// Fraction values must be greater than zero and at most one; pixel values
/// must be positive. [resolve] converts a stop into a clamped viewport fraction.
class SeedSheetSnapPoint {
  /// Creates a stop at [value] of the viewport height (`0 < value <= 1`).
  const SeedSheetSnapPoint.fraction(double value)
    : assert(value > 0 && value <= 1),
      fraction = value,
      pixels = null;
  /// Creates a stop at positive [value] logical pixels from the bottom.
  const SeedSheetSnapPoint.pixels(double value)
    : assert(value > 0),
      pixels = value,
      fraction = null;
  /// Exactly one underlying representation, with the other member null.
  final double? fraction, pixels;
  /// Resolves the point against viewport [height] to a fraction in `[.01, 1]`.
  double resolve(double height) =>
      (fraction ?? pixels! / height).clamp(0.01, 1);
}

/// Imperative controller for a snapping sheet's selected stop.
///
/// The caller owns disposal. When connected to [SeedSnappingBottomSheet], the
/// controller stays synchronized with user-selected snap positions.
class SeedSheetController extends ChangeNotifier {
  /// Creates a controller starting at [initialIndex] (zero by default).
  SeedSheetController({int initialIndex = 0}) : _index = initialIndex;
  int _index;
  /// Current selected snap stop index.
  int get index => _index;
  /// Requests a snap to [index] and notifies listeners.
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
///
/// [snapPoints] defaults to 10%, 50%, and 90% of viewport height; the sheet
/// starts at [initialSnapIndex] unless [controller] selects a different stop.
/// [handleOnly] restricts resize gestures; [dismissible] controls dragging
/// below the smallest stop. [onSnapChanged] reports selected indices, while
/// [onFadeChanged] reports scrim opacity based on [fadeFromIndex].
class SeedSnappingBottomSheet extends StatefulWidget {
  /// Wraps a [sheet] in a draggable multi-stop bottom sheet.
  ///
  /// [contentHeightFraction] defaults to `1`; route helpers can use `.9`
  /// to preserve React's viewport-based snap offsets under a 90vh limit.
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
    this.contentHeightFraction = 1,
    this.onFadeChanged,
    this.dismissible = true,
  });
  /// Composed sheet surface to resize.
  final SeedBottomSheet sheet;
  /// Nonempty ordered snap stops (fractions or positive pixel heights).
  final List<SeedSheetSnapPoint> snapPoints;
  /// Initially selected stop, index zero by default.
  final int initialSnapIndex;
  /// Optional externally-owned snap controller.
  final SeedSheetController? controller;
  /// Notified when the resolved snap stop changes.
  final ValueChanged<int>? onSnapChanged;
  /// Whether only the handle can resize the sheet.
  final bool handleOnly;
  /// Whether dragging below the minimum stop can close the sheet.
  final bool dismissible;
  /// Index where backdrop fade reaches full strength; nullable to disable it.
  final int? fadeFromIndex;

  /// Offsets fraction snap positions for content capped below viewport height.
  /// A .9-height surface translated by React's viewport snap points reveals
  /// (fraction - .1) of the viewport.
  final double contentHeightFraction;
  /// Receives a fade fraction from 0 to 1 as the sheet moves across stops.
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
    assert(
      widget.contentHeightFraction > 0 && widget.contentHeightFraction <= 1,
    );
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
          .map(
            (point) =>
                (point.resolve(available) - (1 - widget.contentHeightFraction))
                    .clamp(.01, widget.contentHeightFraction),
          )
          .toList();
      final sortedPoints = points.toSet().toList()..sort();
      // DraggableScrollableSheet treats a new snapSizes list as a configuration
      // change and starts a ballistic snap. Keep it stable during our own snaps.
      if (!listEquals(_points, points)) {
        final previousSnap = _points.isNotEmpty && _index < _points.length
            ? _points[_index]
            : null;
        final wasAtSnap =
            previousSnap != null &&
            _fraction != null &&
            (_fraction! - previousSnap).abs() < .001;
        _points = points;
        // React resolves pixel points against the current viewport on resize.
        // A settled sheet must follow its logical snap index, not retain the
        // fractional extent calculated for the previous viewport height.
        if (!_draggingHandle && (wasAtSnap || _snappingTo != null)) {
          final next = _points[_index.clamp(0, _points.length - 1)];
          _fraction = next;
          if (!widget.handleOnly && _drag.isAttached) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _drag.isAttached && !_draggingHandle) {
                _drag.jumpTo(next);
              }
            });
          }
        }
      }
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
