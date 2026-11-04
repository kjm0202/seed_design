import '../../localization/seed_localizations.dart';

import 'dart:math' as math;

import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/rendering.dart' show RenderStack;
import 'package:material_ui/material_ui.dart';

import '../../foundations/colors/seed_color_scheme.dart';
import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../foundations/typography/seed_typography.dart';
import '../../theme/seed_theme.dart';
import '../badge/seed_badge.dart';
import 'seed_bottom_sheet.dart';
import 'seed_menu.dart';
import 'seed_anchored_overlay.dart';

/// Shows a grouped SEED Menu Sheet using a bottom-sheet Navigator route.
///
/// [groups] supplies ordered actions and optional group labels. [title] and
/// [description] supply optional introductory text; [cancelLabel] defaults to
/// `닫기` and [showCancelButton] enables the cancel affordance. [closeOnSelect]
/// requests dismissal before calling the selected item action, and defaults
/// to true. [labelAlign] defaults to start; [groupLabelAlignments] overrides
/// individual groups. [isDismissible] controls route dismissal; [enableDrag]
/// enables dragging when dismissible; [showHandle] controls the visual handle.
Future<T?> showSeedMenuSheet<T>({
  required BuildContext context,
  String? title,
  String? description,
  required List<SeedMenuGroupData> groups,
  String? cancelLabel,
  bool showCancelButton = true,
  bool closeOnSelect = true,
  TextAlign labelAlign = TextAlign.start,
  bool isDismissible = true,
  bool enableDrag = true,
  bool showHandle = true,
  List<TextAlign>? groupLabelAlignments,
}) => showSeedBottomSheet<T>(
  context: context,
  isDismissible: isDismissible,
  enableDrag: enableDrag && isDismissible,
  child: SeedMenuSheet(
    title: title,
    description: description,
    groups: groups,
    cancelLabel: cancelLabel,
    showCancelButton: showCancelButton,
    closeOnSelect: closeOnSelect,
    labelAlign: labelAlign,
    showHandle: showHandle,
    swipeable: enableDrag,
    handleDragDismissible: isDismissible,
    groupLabelAlignments: groupLabelAlignments,
  ),
);

/// A grouped action sheet with fixed header/footer and scrollable menu items.
///
/// This widget renders the sheet and relies on its overlay scope or Navigator
/// for dismissal. [swipeable] and [handleDragDismissible] are Flutter-specific
/// composition options used by [showSeedMenuSheet], not React Root props.
class SeedMenuSheet extends StatelessWidget {
  /// Creates a menu-sheet surface from ordered [groups].
  ///
  /// [showCancelButton], [closeOnSelect], [showHandle], [swipeable] and
  /// [handleDragDismissible] are true by default. [cancelLabel] defaults to
  /// `닫기`. [labelAlign] is used unless an entry in [groupLabelAlignments]
  /// overrides the corresponding group.
  const SeedMenuSheet({
    super.key,
    this.title,
    this.description,
    required this.groups,
    String? cancelLabel,
    this.showCancelButton = true,
    this.closeOnSelect = true,
    this.labelAlign = TextAlign.start,
    this.showHandle = true,
    this.swipeable = true,
    this.handleDragDismissible = true,
    this.groupLabelAlignments,
    // Preserve the public named parameter and getter.
    // ignore: prefer_initializing_formals
  }) : _cancelLabel = cancelLabel;

  /// Optional heading centered above the groups.
  final String? title;
  /// Optional supporting paragraph below [title].
  final String? description;
  /// Ordered groups of action rows.
  final List<SeedMenuGroupData> groups;
  final String? _cancelLabel;
  /// Effective cancel action text; `닫기` when unspecified.
  String get cancelLabel => _cancelLabel ?? '닫기';
  /// Whether a fixed cancel action appears below the list.
  final bool showCancelButton;

  /// Keep the sheet open for multi-selection or asynchronous confirmation.
  final bool closeOnSelect;
  /// Default horizontal alignment for item labels.
  final TextAlign labelAlign;
  /// Whether the top drag-handle indicator is visible.
  final bool showHandle;

  /// The swipeable variant uses 24px header inset; the legacy non-drawer
  /// MenuSheet uses 16px. [showSeedMenuSheet] derives this from `enableDrag`.
  final bool swipeable;

  /// Whether the swipeable handle can dismiss the containing sheet.
  final bool handleDragDismissible;

  /// Optional per-group alignment matching MenuSheetGroup.labelAlign.
  final List<TextAlign>? groupLabelAlignments;

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;
    final mediaQuery = MediaQuery.of(context);

    return Align(
      alignment: Alignment.bottomCenter,
      widthFactor: 1,
      heightFactor: 1,
      child: SafeArea(
        top: false,
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) => ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 480,
              maxHeight: math.max(
                0,
                math.min(
                  constraints.maxHeight,
                  math.min(
                    mediaQuery.size.height * 0.9,
                    mediaQuery.size.height - mediaQuery.padding.top,
                  ),
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: Material(
                color: colors.bg.layerFloating,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(SeedRadius.r5),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        swipeable ? 24 : 16,
                        16,
                        16 + mediaQuery.padding.bottom,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (title != null || description != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Column(
                                children: [
                                  if (title != null)
                                    Semantics(
                                      header: true,
                                      child: Text(
                                        title!,
                                        style: typography.t6Bold.copyWith(
                                          color: colors.fg.neutral,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  if (description != null) ...[
                                    if (title != null)
                                      const SizedBox(height: 4),
                                    Text(
                                      description!,
                                      style: typography.t4Regular.copyWith(
                                        color: colors.fg.neutralMuted,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          Flexible(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  for (int g = 0; g < groups.length; g++) ...[
                                    if (g > 0) const SizedBox(height: 10),
                                    if (groups[g].label != null)
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          4,
                                          8,
                                          4,
                                          4,
                                        ),
                                        child: Text(
                                          groups[g].label!,
                                          style: typography.t3Bold.copyWith(
                                            color: colors.fg.neutralSubtle,
                                          ),
                                        ),
                                      ),
                                    Material(
                                      color: colors.bg.neutralWeak,
                                      borderRadius: SeedBorderRadius.r4,
                                      clipBehavior: Clip.antiAlias,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          for (
                                            int i = 0;
                                            i < groups[g].items.length;
                                            i++
                                          ) ...[
                                            if (i > 0)
                                              Divider(
                                                height: 1,
                                                thickness: 1,
                                                color:
                                                    colors.stroke.neutralMuted,
                                              ),
                                            _buildSheetItem(
                                              context,
                                              groups[g].items[i],
                                              colors,
                                              typography,
                                              groupLabelAlignments != null &&
                                                      g <
                                                          groupLabelAlignments!
                                                              .length
                                                  ? groupLabelAlignments![g]
                                                  : labelAlign,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          if (showCancelButton)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Material(
                                color: colors.bg.neutralWeak,
                                borderRadius: SeedBorderRadius.r3,
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  onTap: () => _close(
                                    context,
                                    SeedOverlayDismissReason.closeButton,
                                  ),
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      minHeight: 52,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 14,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      _cancelLabel ??
                                          SeedLocalizations.label(
                                            context,
                                            SeedLabel.close,
                                          ),
                                      style: typography.t5Medium.copyWith(
                                        color: colors.fg.neutral,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Official SwipeableMenuSheet keeps a VisuallyHidden
                    // CloseButton for assistive technology when no visible
                    // one is shown.
                    if (!showCancelButton)
                      Positioned(
                        left: 0,
                        bottom: 0,
                        width: 1,
                        height: 1,
                        child: Semantics(
                          button: true,
                          label:
                              _cancelLabel ??
                              SeedLocalizations.label(context, SeedLabel.close),
                          onTap: () => _close(
                            context,
                            SeedOverlayDismissReason.closeButton,
                          ),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    if (showHandle)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: _SeedMenuSheetHandle(
                            swipeable: swipeable,
                            dismissible: handleDragDismissible,
                            color: colors.stroke.neutralWeak,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSheetItem(
    BuildContext context,
    SeedMenuItemData item,
    SeedColorScheme colors,
    SeedTypography typography,
    TextAlign itemLabelAlign,
  ) {
    Color labelColor;
    if (!item.enabled) {
      labelColor = colors.fg.disabled;
    } else if (item.isDestructive) {
      labelColor = colors.fg.critical;
    } else {
      labelColor = colors.fg.neutral;
    }

    return InkWell(
      overlayColor: WidgetStatePropertyAll(colors.bg.neutralWeakPressed),
      onTap: item.enabled
          ? () {
              if (closeOnSelect) {
                _close(context, SeedOverlayDismissReason.action);
              }
              item.onTap?.call();
            }
          : null,
      // Official menu-sheet item: min-height 52px with 14px vertical padding.
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SeedDimension.x4,
            vertical: SeedDimension.x3_5,
          ),
          child: Row(
            children: [
              if (item.prefixIcon != null) ...[
                IconTheme(
                  data: IconThemeData(
                    size: 22,
                    color: !item.enabled
                        ? colors.fg.disabled
                        : (item.isDestructive
                              ? colors.fg.critical
                              : colors.fg.neutral),
                  ),
                  child: item.prefixIcon!,
                ),
                const SizedBox(width: SeedDimension.x3_5),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: itemLabelAlign == TextAlign.center
                      ? CrossAxisAlignment.center
                      : CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.label,
                      textAlign: itemLabelAlign,
                      style: typography.t5Regular.copyWith(
                        color: labelColor,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    if (item.description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.description!,
                        textAlign: itemLabelAlign,
                        style: typography.t3Medium.copyWith(
                          color: item.enabled
                              ? colors.fg.neutralSubtle
                              : colors.fg.disabled,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (item.badge != null)
                SeedBadge(
                  label: item.badge!,
                  tone: item.isDestructive
                      ? SeedBadgeTone.critical
                      : SeedBadgeTone.neutral,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The React swipeable sheet recognises a drag on the handle itself, including
/// a short, fast swipe. Flutter's enclosing ModalBottomSheetRoute uses a
/// different fling threshold, so this touch target applies the Drawer
/// release rules to handle gestures while the route keeps handling body drags.
class _SeedMenuSheetHandle extends StatefulWidget {
  const _SeedMenuSheetHandle({
    required this.swipeable,
    required this.dismissible,
    required this.color,
  });

  final bool swipeable;
  final bool dismissible;
  final Color color;

  @override
  State<_SeedMenuSheetHandle> createState() => _SeedMenuSheetHandleState();
}

class _SeedMenuSheetHandleState extends State<_SeedMenuSheetHandle> {
  int? _pointer;
  Offset? _start;
  Duration? _startTime;
  PointerDeviceKind? _kind;
  bool _moved = false;
  bool _dismissScheduled = false;

  void _resetPointer() {
    _pointer = null;
    _start = null;
    _startTime = null;
    _kind = null;
    _moved = false;
  }

  void _pointerDown(PointerDownEvent event) {
    if (_pointer != null) return;
    _pointer = event.pointer;
    _start = event.position;
    _startTime = event.timeStamp;
    _kind = event.kind;
    _moved = false;
  }

  void _pointerMove(PointerMoveEvent event) {
    if (event.pointer != _pointer || _start == null) return;
    final threshold = _kind == PointerDeviceKind.touch ? 10.0 : 2.0;
    if ((event.position - _start!).distance > threshold) _moved = true;
  }

  void _pointerUp(PointerUpEvent event) {
    if (event.pointer != _pointer || _start == null || _startTime == null) {
      return;
    }
    final dy = event.position.dy - _start!.dy;
    final elapsedMicros = (event.timeStamp - _startTime!).inMicroseconds;
    final shouldDismiss =
        _moved && dy > 0 && _shouldDismissDrag(dy, elapsedMicros);
    _resetPointer();
    if (!shouldDismiss || _dismissScheduled) return;

    // The surrounding bottom-sheet route recognises body swipes separately.
    // Defer dismissal to avoid popping its parent if the route already popped.
    _dismissScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _dismissScheduled = false;
      if (mounted && ModalRoute.of(context)?.isCurrent == true) {
        _close(context, SeedOverlayDismissReason.drag);
      }
    });
    // A pointer-up alone need not trigger another frame on Flutter Web.
    // Schedule one so the guarded close runs even without a concurrent fling.
    WidgetsBinding.instance.scheduleFrame();
  }

  bool _shouldDismissDrag(double dy, int elapsedMicros) {
    // React Drawer useDrawer.ts: velocity > 0.4 CSS px/ms, or distance >=
    // 25% of the actual visible sheet height. Using pointer event timestamps
    // matches rapid browser mouse/touch sequences that Flutter's fling tracker
    // may coalesce into one or fewer samples.
    final height = context
        .findAncestorRenderObjectOfType<RenderStack>()
        ?.size
        .height;
    final longEnough = height != null && dy >= height * .25;
    // React useDrawer.ts computes abs(distance) / timeTaken without a zero
    // guard. A down/up pair in the same millisecond therefore has +Infinity
    // velocity for a nonzero drag and crosses its 0.4 CSS px/ms threshold.
    // Flutter may report such input with identical PointerEvent timestamps;
    // reject a true slow drag only when elapsed time is positive and measured.
    final fastEnough =
        elapsedMicros == 0 ||
        (elapsedMicros > 0 && dy * 1000000 / elapsedMicros > 400);
    return longEnough || fastEnough;
  }

  @override
  Widget build(BuildContext context) {
    final visual = SizedBox(
      width: 44,
      // The official handle touch area is 44x44 centered on the bar at y=8.
      // The part inside the sheet spans y=0..30.
      height: widget.swipeable ? 30 : 10,
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: SeedBorderRadius.full,
            ),
          ),
        ),
      ),
    );
    if (!widget.swipeable || !widget.dismissible) return visual;
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _pointerDown,
      onPointerMove: _pointerMove,
      onPointerUp: _pointerUp,
      onPointerCancel: (_) => _resetPointer(),
      child: visual,
    );
  }
}

void _close(BuildContext context, SeedOverlayDismissReason reason) {
  final scope = SeedOverlayScope.maybeOf(context);
  if (scope != null) {
    scope.close(reason);
  } else {
    Navigator.of(context).pop();
  }
}
