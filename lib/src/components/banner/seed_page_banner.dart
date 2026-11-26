import 'dart:math' as math;

import '../../localization/seed_localizations.dart';

import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
import '../../foundations/gradient/seed_gradient.dart';
import '../../foundations/motion/seed_motion.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../foundations/typography/seed_typography.dart';
import '../../theme/seed_theme.dart';
import '../layout/seed_safe_area_x.dart';

/// Tone options for [SeedPageBanner].
enum SeedPageBannerTone {
  /// Neutral system message.
  neutral,
  /// Informational message.
  informative,
  /// Success or positive outcome.
  positive,
  /// Warning requiring caution.
  warning,
  /// Critical or destructive message.
  critical,
  /// Special gradient promotion or magic/AI message; weak variant only.
  magic,
}

/// Variant options for [SeedPageBanner].
enum SeedPageBannerVariant {
  /// Subdued tonal background.
  weak,

  /// Strong filled background.
  solid,
}

/// Page Banner component of SEED Design System.
///
/// Prominently communicates high-level notifications, system alerts,
/// and promotions at the top of a page.
class SeedPageBanner extends StatefulWidget {
  /// Optional emphasized leading title, omitted when null.
  final String? title;
  /// Optional body text; shown after [title] when both are supplied.
  final String? description;
  /// Optional text action displayed beside the message.
  final String? linkText;
  /// Invoked when the [linkText] action is pressed.
  final VoidCallback? onLinkTap;
  /// Enables an actionable banner surface; tapping it invokes this callback.
  final VoidCallback? onTap;
  /// Invoked on dismissal; also enables the visible dismiss control.
  final VoidCallback? onDismiss;

  /// When supplied, visibility is owned by the parent.
  /// A parent must update this value after [onDismiss] to hide the banner.
  final bool? open;
  /// Initial visibility in internally managed mode (true by default).
  final bool defaultOpen;

  /// Shows a close button even when [onDismiss] is omitted.
  final bool dismissible;
  /// Optional leading icon, drawn at a fixed 16 logical pixels and vertically
  /// centered on the first text line.
  final Widget? prefixIcon;
  /// Semantic tone, default [SeedPageBannerTone.neutral].
  final SeedPageBannerTone tone;
  /// Color strength, default [SeedPageBannerVariant.weak].
  final SeedPageBannerVariant variant;

  /// Extends only the banner's background under the horizontal safe-area
  /// insets, like React `PageBanner` `extendSafeAreaX` (React 3.1.0+).
  /// Defaults to false, which keeps the existing layout.
  ///
  /// Place the banner inside the safe area as usual. When true, the tone
  /// background (including its pressed color and the magic gradient, redrawn
  /// across the full width) is painted from the left screen edge to the right
  /// one, by the device's physical left and right insets beyond the banner.
  /// The banner's own box, padding, content, focus ring and semantics stay
  /// where they are, as React bleeds a `::before` layer instead of the root.
  /// The insets are the largest of the view padding and the ambient
  /// [MediaQuery] padding and view padding, also when an ancestor [SafeArea]
  /// has consumed them.
  ///
  /// The bled strips are painted only; taps there do not reach [onTap],
  /// because Flutter hit testing stops at the banner's bounds.
  final bool extendSafeAreaX;

  /// Creates a page-level message bar.
  ///
  /// [title] and [description] are independently optional. [onTap] makes the
  /// entire banner actionable; [linkText]/[onLinkTap] add a separate text action.
  /// A dismiss control is shown for [dismissible] or [onDismiss]. The
  /// `magic` tone cannot be combined with the solid variant.
  /// [extendSafeAreaX] bleeds the background under the horizontal safe-area
  /// insets.
  const SeedPageBanner({
    super.key,
    this.title,
    this.description,
    this.linkText,
    this.onLinkTap,
    this.onTap,
    this.onDismiss,
    this.open,
    this.defaultOpen = true,
    this.dismissible = false,
    this.prefixIcon,
    this.tone = SeedPageBannerTone.neutral,
    this.variant = SeedPageBannerVariant.weak,
    this.extendSafeAreaX = false,
  }) : assert(
         tone != SeedPageBannerTone.magic ||
             variant != SeedPageBannerVariant.solid,
         'The magic tone only supports the weak variant.',
       );

  @override
  State<SeedPageBanner> createState() => _SeedPageBannerState();

  bool get _isActionable => onTap != null;

  /// (target height 40 - t3 line height 18) / 2, as in the official recipe.
  /// The link target extends this far above and below its line box, while the
  /// line box alone takes part in the layout.
  static const double _linkTargetBleed = 11;

  Widget _scaleContent(Widget child) =>
      _isActionable ? SeedContentScale(child: child) : child;

  Widget _build(BuildContext context, VoidCallback dismiss) {
    final colors = context.seedColor;
    final typography = context.seedTypography;

    final (bgColor, fgColor, iconColor) = _resolveColors(colors);

    final hasCloseButton = dismissible || onDismiss != null;

    Widget content(bool isPressed) {
      final decoration = BoxDecoration(
        color: isPressed
            ? switch (tone) {
                SeedPageBannerTone.neutral =>
                  variant == SeedPageBannerVariant.solid
                      ? colors.bg.neutralSolidPressed
                      : colors.bg.neutralWeakPressed,
                SeedPageBannerTone.informative =>
                  variant == SeedPageBannerVariant.solid
                      ? colors.bg.informativeSolidPressed
                      : colors.bg.informativeWeakPressed,
                SeedPageBannerTone.positive =>
                  variant == SeedPageBannerVariant.solid
                      ? colors.bg.positiveSolidPressed
                      : colors.bg.positiveWeakPressed,
                SeedPageBannerTone.warning =>
                  variant == SeedPageBannerVariant.solid
                      ? colors.bg.warningSolidPressed
                      : colors.bg.warningWeakPressed,
                SeedPageBannerTone.critical =>
                  variant == SeedPageBannerVariant.solid
                      ? colors.bg.criticalSolidPressed
                      : colors.bg.criticalWeakPressed,
                SeedPageBannerTone.magic => bgColor,
              }
            : bgColor,
        gradient: tone == SeedPageBannerTone.magic
            ? (isPressed
                  ? SeedGradients.glowMagicPressed(isDark: colors.isDark)
                  : SeedGradients.glowMagic(isDark: colors.isDark))
            : null,
      );
      final textScaler = MediaQuery.textScalerOf(context);
      final t4LineHeight =
          textScaler.scale(SeedFontSize.t4) *
          (SeedLineHeight.t4 / SeedFontSize.t4);
      // css 3.4.1 (#2776) keeps the prefix and suffix icons at 16px at every
      // text scale. The first line's center is the root's x2_5 paddingBlock
      // plus half the scaled t4 line height; the icons offset themselves from
      // it instead of centering on the whole banner.
      final firstLineCenter = SeedDimension.x2_5 + t4LineHeight / 2;

      // With neither close button nor chevron, the link's end bleed has no
      // reserved slot to run into, so the content box gives up 11px of the
      // end padding to hold it.
      final plainEnd = !hasCloseButton && !_isActionable;
      final body = Container(
        // React bleeds the 40px link and close targets over the root padding
        // with negative margins. Here the vertical padding lives on the text
        // and link line boxes instead, so the targets cannot make the banner
        // taller than its text, and the close target's 12px end bleed shrinks
        // the end padding to 4px. The link's 11px inline bleed takes 11px of
        // the start (and plain end) padding into the content box, which
        // spacers give back, so Flutter hit tests the bled target.
        padding: EdgeInsetsDirectional.only(
          start: SeedDimension.x4 - _linkTargetBleed,
          end: hasCloseButton
              ? SeedDimension.x1
              : (plainEnd
                    ? SeedDimension.x4 - _linkTargetBleed
                    : SeedDimension.x4),
        ),
        // Always decorated, with an empty decoration when the bled layer
        // below paints the background, so Container builds the same tree
        // whatever extendSafeAreaX is.
        decoration: extendSafeAreaX ? const BoxDecoration() : decoration,
        child: _scaleContent(
          Stack(
            // The targets bleed past the content box; Flutter confines their
            // hit testing to the banner anyway.
            clipBehavior: Clip.none,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: _linkTargetBleed),
                  if (prefixIcon != null) ...[
                    Padding(
                      // The 16px icon is centered on the first text line; it
                      // does not scale with the text (css 3.4.1).
                      padding: EdgeInsets.only(
                        top: firstLineCenter - SeedDimension.x4 / 2,
                      ),
                      child: IconTheme(
                        data: IconThemeData(
                          color: iconColor,
                          size: SeedDimension.x4,
                        ),
                        child: SizedBox.square(
                          dimension: SeedDimension.x4,
                          child: prefixIcon!,
                        ),
                      ),
                    ),
                    const SizedBox(width: SeedDimension.x2),
                  ],
                  Expanded(
                    // css `margin: -11px; padding: 11px` on the link: the
                    // Wrap runs 11px past both content edges, and every item
                    // pads 11px back inline, so text and line breaks stay
                    // where they were while the link target bleeds 11px.
                    child: _Bleed(
                      horizontal: _linkTargetBleed,
                      child: Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        // The official 6px gap, less both items' inline bleed.
                        spacing: SeedDimension.x1_5 - _linkTargetBleed * 2,
                        // The official 6px gap, less the vertical padding the
                        // text and link line boxes carry so their targets stay
                        // hittable without growing the banner.
                        runSpacing: SeedDimension.x1_5 - SeedDimension.x2_5 * 2,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: _linkTargetBleed,
                              vertical: SeedDimension.x2_5,
                            ),
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  if (title != null)
                                    TextSpan(
                                      text: title,
                                      style: typography.t4Bold.copyWith(
                                        color: fgColor,
                                      ),
                                    ),
                                  if (description != null)
                                    TextSpan(
                                      text: title == null
                                          ? description
                                          : '  $description',
                                      style: typography.t4Medium.copyWith(
                                        color: fgColor,
                                      ),
                                    ),
                                ],
                              ),
                              style: typography.t4Medium.copyWith(
                                color: fgColor,
                              ),
                            ),
                          ),
                          if (linkText != null)
                            // css pads the link 11px on every side, so its
                            // target is 40px per line and grows with the
                            // label's lines. Only the label plus the x2_5
                            // line padding joins the layout; the target bleeds
                            // the remaining 1px above and below.
                            _Bleed(
                              vertical:
                                  _linkTargetBleed - SeedDimension.x2_5,
                              child: SeedPressable(
                                semanticsLabel: linkText,
                                focusRingInside: true,
                                onTap: onLinkTap,
                                builder: (context, linkPressed) => Padding(
                                  padding: const EdgeInsets.all(
                                    _linkTargetBleed,
                                  ),
                                  child: Text(
                                    linkText!,
                                    style: typography.t3Bold.copyWith(
                                      color: fgColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  // The close and suffix targets are overlaid below; reserve
                  // their layout width so text does not run underneath them.
                  if (hasCloseButton)
                    const SizedBox(width: SeedDimension.x10 - SeedDimension.x1)
                  else if (_isActionable)
                    const SizedBox(width: SeedDimension.x2 + SeedDimension.x4)
                  else
                    const SizedBox(width: _linkTargetBleed),
                ],
              ),
              if (hasCloseButton)
                // React sets `margin: -12px` on the 40px target, which cancels
                // the root's 16px inline padding down to its 4px icon overhang,
                // so the target spans 4px to 44px inside the banner's end edge
                // and its icon ends 16px inside it. The content box already
                // ends 4px inside the banner, so the target sits flush with it.
                PositionedDirectional(
                  // css 3.4.1 (#2776) drops `align-self: center` and gives
                  // the 40px target `marginTop: (lineHeight - 40) / 2`, so its
                  // center sits on the first text line like the icons. A
                  // single-line banner at 100% text is 1px shorter than the
                  // target; it overflows by 0.5px, and taps outside the banner
                  // are not hit tested anyway.
                  top: firstLineCenter - SeedDimension.x10 / 2,
                  end: 0,
                  // Unlike css, where the later close target wins taps on the
                  // 4px it overlaps the content box, only the 36px past the
                  // content box hit tests, so the end of a link label stays
                  // the link's. The target still paints all 40px.
                  width: SeedDimension.x10 - SeedDimension.x1,
                  height: SeedDimension.x10,
                  child: OverflowBox(
                    alignment: AlignmentDirectional.centerEnd,
                    minWidth: SeedDimension.x10,
                    maxWidth: SeedDimension.x10,
                    child: SeedPressable(
                      semanticsLabel: SeedLocalizations.label(
                        context,
                        SeedLabel.close,
                      ),
                      behavior: HitTestBehavior.opaque,
                      focusBorderRadius: SeedBorderRadius.r2,
                      focusRingInside: true,
                      onTap: dismiss,
                      builder: (context, isClosePressed) => AnimatedContainer(
                        duration: SeedDuration.colorTransition,
                        curve: SeedCurves.easing,
                        width: SeedDimension.x10,
                        height: SeedDimension.x10,
                        decoration: BoxDecoration(
                          color: isClosePressed
                              ? colors.bg.transparentPressed
                              : colors.bg.transparent,
                          borderRadius: SeedBorderRadius.r2,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.close_rounded,
                            size: SeedDimension.x4,
                            color: iconColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              else if (_isActionable)
                // css 3.4.1 (#2776) drops `alignSelf: center` and offsets the
                // suffix icon like the prefix icon, so it centers on the first
                // text line rather than the whole banner.
                PositionedDirectional(
                  top: firstLineCenter - SeedDimension.x4 / 2,
                  end: 0,
                  width: SeedDimension.x4,
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: SeedDimension.x4,
                    color: iconColor,
                  ),
                ),
            ],
          ),
        ),
      );
      // React paints a `::before` layer from -left to -right behind the
      // unchanged root. The root's own box keeps its size and position.
      // Without extendSafeAreaX the layer stays, empty and at zero insets
      // (not read from MediaQuery), and the root paints the background
      // itself. One tree shape for both values means toggling the flag does
      // not remount the content.
      final insets = SeedSafeAreaX.resolve(context, extendSafeAreaX);
      return Stack(
        fit: StackFit.passthrough,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -insets.left,
            right: -insets.right,
            top: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: extendSafeAreaX ? decoration : const BoxDecoration(),
            ),
          ),
          body,
        ],
      );
    }

    if (_isActionable) {
      return SeedPressable(
        onTap: onTap,
        enableScale: false,
        builder: (context, isPressed) => content(isPressed),
      );
    }

    return content(false);
  }

  (Color bg, Color fg, Color icon) _resolveColors(dynamic colors) {
    if (variant == SeedPageBannerVariant.solid) {
      switch (tone) {
        case SeedPageBannerTone.neutral:
          return (
            colors.bg.neutralSolid,
            colors.fg.onNeutralSolid,
            colors.fg.onNeutralSolid,
          );
        case SeedPageBannerTone.informative:
          return (
            colors.bg.informativeSolid,
            colors.fg.onInformativeSolid,
            colors.fg.onInformativeSolid,
          );
        case SeedPageBannerTone.positive:
          return (
            colors.bg.positiveSolid,
            colors.fg.onPositiveSolid,
            colors.fg.onPositiveSolid,
          );
        case SeedPageBannerTone.warning:
          return (
            colors.bg.warningSolid,
            colors.fg.onWarningSolid,
            colors.fg.onWarningSolid,
          );
        case SeedPageBannerTone.critical:
          return (
            colors.bg.criticalSolid,
            colors.fg.onCriticalSolid,
            colors.fg.onCriticalSolid,
          );
        case SeedPageBannerTone.magic:
          return (
            colors.bg.brandSolid,
            colors.fg.onBrandSolid,
            colors.fg.onBrandSolid,
          );
      }
    } else {
      switch (tone) {
        case SeedPageBannerTone.neutral:
          return (colors.bg.neutralWeak, colors.fg.neutral, colors.fg.neutral);
        case SeedPageBannerTone.informative:
          return (
            colors.bg.informativeWeak,
            colors.fg.informativeContrast,
            colors.fg.informativeContrast,
          );
        case SeedPageBannerTone.positive:
          return (
            colors.bg.positiveWeak,
            colors.fg.positiveContrast,
            colors.fg.positiveContrast,
          );
        case SeedPageBannerTone.warning:
          return (
            colors.bg.warningWeak,
            colors.fg.warningContrast,
            colors.fg.warningContrast,
          );
        case SeedPageBannerTone.critical:
          return (
            colors.bg.criticalWeak,
            colors.fg.criticalContrast,
            colors.fg.criticalContrast,
          );
        case SeedPageBannerTone.magic:
          return (colors.bg.magicWeak, colors.fg.neutral, colors.fg.neutral);
      }
    }
  }
}

class _SeedPageBannerState extends State<SeedPageBanner> {
  late bool _open = widget.defaultOpen;

  void _dismiss() {
    if (!(widget.open ?? _open)) return;
    if (widget.open == null) setState(() => _open = false);
    widget.onDismiss?.call();
  }

  @override
  Widget build(BuildContext context) => (widget.open ?? _open)
      ? widget._build(context, _dismiss)
      : const SizedBox.shrink();
}

/// Lays its child out [horizontal] wider on both inline sides and [vertical]
/// taller on both block sides, and lets hit tests reach that overhang, like a
/// CSS negative margin.
///
/// Its own size, and so its parent's layout, is the child's less the bleed;
/// the parent must leave the bleed free for taps there to arrive.
class _Bleed extends SingleChildRenderObjectWidget {
  const _Bleed({this.horizontal = 0, this.vertical = 0, required super.child});

  final double horizontal;
  final double vertical;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderBleed(horizontal, vertical);

  @override
  void updateRenderObject(BuildContext context, _RenderBleed renderObject) {
    renderObject
      ..horizontal = horizontal
      ..vertical = vertical;
  }
}

class _RenderBleed extends RenderShiftedBox {
  _RenderBleed(this._horizontal, this._vertical) : super(null);

  double _horizontal;
  double get horizontal => _horizontal;
  set horizontal(double value) {
    if (value == _horizontal) return;
    _horizontal = value;
    markNeedsLayout();
  }

  double _vertical;
  double get vertical => _vertical;
  set vertical(double value) {
    if (value == _vertical) return;
    _vertical = value;
    markNeedsLayout();
  }

  BoxConstraints _childConstraints(BoxConstraints constraints) =>
      constraints.copyWith(
        minWidth: constraints.minWidth + _horizontal * 2,
        maxWidth: constraints.maxWidth + _horizontal * 2,
        minHeight: constraints.minHeight + _vertical * 2,
        maxHeight: constraints.maxHeight + _vertical * 2,
      );

  Size _shrink(BoxConstraints constraints, Size childSize) =>
      constraints.constrain(
        Size(
          math.max(0, childSize.width - _horizontal * 2),
          math.max(0, childSize.height - _vertical * 2),
        ),
      );

  @override
  double computeMinIntrinsicWidth(double height) => math.max(
    0,
    (child?.getMinIntrinsicWidth(height + _vertical * 2) ?? 0) -
        _horizontal * 2,
  );

  @override
  double computeMaxIntrinsicWidth(double height) => math.max(
    0,
    (child?.getMaxIntrinsicWidth(height + _vertical * 2) ?? 0) -
        _horizontal * 2,
  );

  @override
  double computeMinIntrinsicHeight(double width) => math.max(
    0,
    (child?.getMinIntrinsicHeight(width + _horizontal * 2) ?? 0) -
        _vertical * 2,
  );

  @override
  double computeMaxIntrinsicHeight(double width) => math.max(
    0,
    (child?.getMaxIntrinsicHeight(width + _horizontal * 2) ?? 0) -
        _vertical * 2,
  );

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final child = this.child;
    if (child == null) return constraints.smallest;
    return _shrink(
      constraints,
      child.getDryLayout(_childConstraints(constraints)),
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
    (child.parentData! as BoxParentData).offset = Offset(
      -_horizontal,
      -_vertical,
    );
    size = _shrink(constraints, child.size);
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    final bounds = Rect.fromLTRB(
      -_horizontal,
      -_vertical,
      size.width + _horizontal,
      size.height + _vertical,
    );
    if (bounds.contains(position) &&
        hitTestChildren(result, position: position)) {
      result.add(BoxHitTestEntry(this, position));
      return true;
    }
    return false;
  }
}
