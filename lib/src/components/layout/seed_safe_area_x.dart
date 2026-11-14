// Internal support for React's `extendSafeAreaX` variant (React 3.1.0+).
//
// Not exported from the public library. Tabs, chip tabs, page banner and
// attachment input share these pieces so that their horizontal safe-area
// handling resolves the same insets and bleeds the same way.
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';

/// Physical left and right safe-area insets, matching CSS
/// `--seed-safe-area-left` / `--seed-safe-area-right`.
///
/// The CSS variables come from `env(safe-area-inset-*)`, which reports the
/// device insets whether or not an ancestor already padded for them. In
/// Flutter a [SafeArea] (or [MediaQuery.removePadding]) zeroes both
/// [MediaQueryData.padding] and [MediaQueryData.viewPadding] for its
/// descendants, so a component placed inside the safe area would read zero
/// from [MediaQuery] alone. [of] therefore takes, per side, the largest of
/// the enclosing [View]'s physical view padding and the ambient
/// [MediaQuery] padding and view padding. The [MediaQuery] terms keep
/// overridden media queries (device previews, tests) authoritative when they
/// report a larger inset than the view.
///
/// The values are physical: [left] is always the left edge, also in RTL.
@immutable
class SeedSafeAreaX {
  /// Creates insets of [left] and [right] logical pixels.
  const SeedSafeAreaX({this.left = 0, this.right = 0});

  /// No inset on either side.
  static const SeedSafeAreaX zero = SeedSafeAreaX();

  /// Physical [left] and [right] insets in logical pixels.
  final double left, right;

  /// Whether both insets are zero.
  bool get isZero => left == 0 && right == 0;

  /// Resolves the current insets and registers dependencies on the ambient
  /// and view-level [MediaQuery] so the caller rebuilds on metrics changes.
  static SeedSafeAreaX of(BuildContext context) {
    // A SafeArea can mask both MediaQuery aspects below it. Subscribe to the
    // view's outer MediaQuery too, so a metrics change still rebuilds callers
    // when the consumed padding remains zero.
    InheritedElement? viewMediaQuery;
    context.visitAncestorElements((element) {
      if (element.widget is View) return false;
      if (element.widget is MediaQuery) {
        viewMediaQuery = element as InheritedElement;
      }
      return true;
    });
    if (viewMediaQuery != null) {
      context.dependOnInheritedElement(viewMediaQuery!);
    }
    final viewPadding =
        MediaQuery.maybeViewPaddingOf(context) ?? EdgeInsets.zero;
    final padding = MediaQuery.maybePaddingOf(context) ?? EdgeInsets.zero;
    final view = View.maybeOf(context);
    var viewLeft = 0.0, viewRight = 0.0;
    if (view != null && view.devicePixelRatio > 0) {
      viewLeft = view.viewPadding.left / view.devicePixelRatio;
      viewRight = view.viewPadding.right / view.devicePixelRatio;
    }
    return SeedSafeAreaX(
      left: math.max(viewLeft, math.max(viewPadding.left, padding.left)),
      right: math.max(viewRight, math.max(viewPadding.right, padding.right)),
    );
  }

  /// [of] when [extend] is true, otherwise [zero] without any dependency.
  static SeedSafeAreaX resolve(BuildContext context, bool extend) =>
      extend ? of(context) : zero;

  /// Inset on the reading-start edge for [direction].
  double start(TextDirection direction) =>
      direction == TextDirection.rtl ? right : left;

  /// Inset on the reading-end edge for [direction].
  double end(TextDirection direction) =>
      direction == TextDirection.rtl ? left : right;

  /// The insets as physical horizontal padding.
  EdgeInsets get padding => EdgeInsets.only(left: left, right: right);

  @override
  bool operator ==(Object other) =>
      other is SeedSafeAreaX && other.left == left && other.right == right;

  @override
  int get hashCode => Object.hash(left, right);
}

/// Lays out [child] wider by [left] + [right] and shifts it left by [left],
/// while reporting the original width to the parent, like CSS
/// `margin-left: -left; margin-right: -right`.
///
/// Hit testing skips this box's own bounds so points in the bled strips can
/// reach the child when the parent forwards them. Ancestors above this
/// widget still apply their own bounds, so input that starts inside the
/// inset reaches the child only when every ancestor covers that strip.
///
/// With [SeedSafeAreaX.zero] the child gets this box's constraints, size and
/// origin unchanged. Components keep the bleed in the tree at zero insets
/// while `extendSafeAreaX` is false, so toggling the flag does not remount
/// (and reset) the subtree below it.
class SeedSafeAreaXBleed extends SingleChildRenderObjectWidget {
  /// Bleeds [child] by [insets].
  const SeedSafeAreaXBleed({
    super.key,
    required this.insets,
    required super.child,
  });

  /// How far the child extends past each side.
  final SeedSafeAreaX insets;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderSeedSafeAreaXBleed(insets);

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    (renderObject as _RenderSeedSafeAreaXBleed).insets = insets;
  }
}

class _RenderSeedSafeAreaXBleed extends RenderShiftedBox {
  _RenderSeedSafeAreaXBleed(this._insets) : super(null);
  SeedSafeAreaX _insets;

  set insets(SeedSafeAreaX value) {
    if (_insets == value) return;
    _insets = value;
    markNeedsLayout();
  }

  double get _extra => _insets.left + _insets.right;

  BoxConstraints _childConstraints(BoxConstraints constraints) =>
      constraints.copyWith(
        minWidth: constraints.minWidth + _extra,
        maxWidth: constraints.maxWidth + _extra,
      );

  double _inner(double width) => width.isFinite ? width + _extra : width;

  @override
  double computeMinIntrinsicWidth(double height) =>
      math.max(0, (child?.getMinIntrinsicWidth(height) ?? 0) - _extra);
  @override
  double computeMaxIntrinsicWidth(double height) =>
      math.max(0, (child?.getMaxIntrinsicWidth(height) ?? 0) - _extra);
  @override
  double computeMinIntrinsicHeight(double width) =>
      child?.getMinIntrinsicHeight(_inner(width)) ?? 0;
  @override
  double computeMaxIntrinsicHeight(double width) =>
      child?.getMaxIntrinsicHeight(_inner(width)) ?? 0;

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) =>
      child?.getDistanceToActualBaseline(baseline);

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final childSize =
        child?.getDryLayout(_childConstraints(constraints)) ?? Size.zero;
    return constraints.constrain(
      Size(math.max(0, childSize.width - _extra), childSize.height),
    );
  }

  @override
  void performLayout() {
    final child = this.child;
    if (child == null) {
      size = constraints.smallest;
      return;
    }
    child.layout(_childConstraints(constraints), parentUsesSize: true);
    size = constraints.constrain(
      Size(math.max(0, child.size.width - _extra), child.size.height),
    );
    (child.parentData! as BoxParentData).offset = Offset(-_insets.left, 0);
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (hitTestChildren(result, position: position)) {
      result.add(BoxHitTestEntry(this, position));
      return true;
    }
    return false;
  }
}

/// Scrolls the nearest [Scrollable] so that the box of [context] keeps
/// [leadingMargin] / [trailingMargin] from the viewport's leading and trailing
/// edges, like CSS `scroll-padding` on the scroll container.
///
/// Offsets are resolved by the viewport and are axis-direction aware, so the
/// margins apply to the reading start and end in both LTR and RTL.
/// [startGap] excludes that many pixels from the start side of the box, for
/// item boxes that also contain the gap before them.
void seedRevealWithin(
  BuildContext context, {
  required double leadingMargin,
  required double trailingMargin,
  double startGap = 0,
}) {
  final box = context.findRenderObject();
  if (box is! RenderBox || !box.attached || !box.hasSize) return;
  final scrollable = Scrollable.maybeOf(context);
  if (scrollable == null) return;
  final position = scrollable.position;
  if (!position.hasPixels || !position.hasContentDimensions) return;
  final viewport = RenderAbstractViewport.maybeOf(box);
  if (viewport == null) return;
  final rtl = Directionality.of(context) == TextDirection.rtl;
  final gap = math.min(startGap, box.size.width);
  final rect = Rect.fromLTWH(
    rtl ? 0 : gap,
    0,
    box.size.width - gap,
    box.size.height,
  );
  final leading = viewport.getOffsetToReveal(box, 0, rect: rect).offset;
  final trailing = viewport.getOffsetToReveal(box, 1, rect: rect).offset;
  var target = position.pixels;
  if (position.pixels > leading - leadingMargin) {
    target = leading - leadingMargin;
  } else if (position.pixels < trailing + trailingMargin) {
    target = trailing + trailingMargin;
  }
  target = target.clamp(position.minScrollExtent, position.maxScrollExtent);
  if ((target - position.pixels).abs() > 0.5) position.jumpTo(target);
}

/// After keyboard focus enters [child], keeps the child clear of the
/// horizontal safe-area [insets] inside its scroll view.
///
/// Flutter's focus traversal reveals a newly focused widget flush with the
/// viewport edge. React's `scroll-padding` keeps it inside the inset that an
/// `extendSafeAreaX` list extends into, so this re-reveals it one frame later
/// with the insets as margins.
class SeedSafeAreaXFocusReveal extends StatelessWidget {
  /// Re-reveals [child] inside [insets] whenever it gains focus.
  const SeedSafeAreaXFocusReveal({
    super.key,
    required this.insets,
    this.startGap = 0,
    required this.child,
  });

  /// Margins kept from the viewport edges.
  final SeedSafeAreaX insets;

  /// Pixels at the start of the child's box that are a gap, not the item.
  final double startGap;

  /// The focusable content.
  final Widget child;

  // Kept in the tree at zero insets too, so neither a rotation that changes
  // the insets nor toggling extendSafeAreaX rebuilds the child's subtree and
  // drops its focus. At zero insets it never scrolls.
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (boxContext) => Focus(
        canRequestFocus: false,
        skipTraversal: true,
        includeSemantics: false,
        onFocusChange: (focused) {
          if (!focused || insets.isZero) return;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!boxContext.mounted) return;
            final direction = Directionality.of(boxContext);
            seedRevealWithin(
              boxContext,
              leadingMargin: insets.start(direction),
              trailingMargin: insets.end(direction),
              startGap: startGap,
            );
          });
        },
        child: child,
      ),
    );
  }
}
