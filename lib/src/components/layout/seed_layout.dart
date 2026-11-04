import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

import '../../theme/seed_theme.dart';

/// Selectable article content. Text locale and scaling remain native.
class SeedArticle extends StatelessWidget {
  /// Creates article content with native Flutter selection and locale handling.
  const SeedArticle({
    super.key,
    required this.child,
    this.selectable = true,
    this.locale,
  });
  /// Text and media making up the article.
  final Widget child;
  /// Wraps the content in [SelectionArea] when true (the default).
  final bool selectable;
  /// Overrides the inherited locale for [child] when provided.
  final Locale? locale;
  @override
  Widget build(BuildContext context) {
    final content = locale == null
        ? child
        : Localizations.override(
            context: context,
            locale: locale,
            child: child,
          );
    return selectable ? SelectionArea(child: content) : content;
  }
}

/// Clips [child] to a proportional box, like SEED's AspectRatio primitive.
class SeedAspectRatio extends StatelessWidget {
  /// Creates a ratio box, defaulting to 4:3.
  const SeedAspectRatio({super.key, this.ratio = 4 / 3, this.child});

  /// Width / height. Defaults to 4 / 3, as in React.
  final double ratio;
  /// Content clipped to the ratio's bounds.
  final Widget? child;

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: ratio,
    child: ClipRect(child: child),
  );
}

/// Breakpoint-aware composition; updates when its actual available width changes.
class SeedResponsive extends StatelessWidget {
  /// Chooses content based on its own available width, not a global width.
  const SeedResponsive({
    super.key,
    required this.small,
    required this.medium,
    this.large,
    this.mediumBreakpoint = 768,
    this.largeBreakpoint = 1280,
  });
  /// Required widgets for widths below and from [mediumBreakpoint].
  final Widget small, medium;
  /// Content for widths at least [largeBreakpoint]; falls back to [medium].
  final Widget? large;
  /// Width thresholds in logical pixels: 768 for medium, 1280 for large.
  final double mediumBreakpoint, largeBreakpoint;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => constraints.maxWidth < mediumBreakpoint
        ? small
        : constraints.maxWidth < largeBreakpoint
        ? medium
        : large ?? medium,
  );
}

/// How much of a wide viewport [SeedLayoutContent] uses.
/// [SeedLayoutDensity.low] caps content at 720px from 768px,
/// [SeedLayoutDensity.medium] caps it at 720px then 1040px from 1280px,
/// and [SeedLayoutDensity.high] keeps it unconstrained.
enum SeedLayoutDensity {
  /// Narrow content up to 720px.
  low,
  /// Responsive 720px/1040px limits.
  medium,
  /// No maximum width.
  high,
}

/// Centers page content within the official widths: low stays at 720 from the
/// `md` breakpoint, medium grows to 1040 at `lg`, and high is unconstrained.
class SeedLayoutContent extends StatelessWidget {
  /// Creates centered, breakpoint-limited page content.
  const SeedLayoutContent({
    super.key,
    required this.child,
    this.density = SeedLayoutDensity.medium,
  });
  /// Page body to constrain and center.
  final Widget child;
  /// Width regime, defaulting to [SeedLayoutDensity.medium].
  final SeedLayoutDensity density;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final maxWidth = switch (density) {
      SeedLayoutDensity.high => double.infinity,
      _ when width < 768 => double.infinity,
      SeedLayoutDensity.low => 720.0,
      SeedLayoutDensity.medium => width < 1280 ? 720.0 : 1040.0,
    };
    return Center(
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// Row or column composition with spacing and optional wrapping.
///
/// [wrap] uses Flutter [Wrap], including the same [gap] on both axes;
/// otherwise it uses [Flex] with a main-axis gap.
class SeedFlex extends StatelessWidget {
  /// Creates horizontal flex content unless [direction] overrides the axis.
  const SeedFlex({
    super.key,
    required this.children,
    this.direction = Axis.horizontal,
    this.gap = 0,
    this.wrap = false,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.min,
  });
  /// Ordered children of the flex layout.
  final List<Widget> children;
  /// Main layout axis; horizontal by default.
  final Axis direction;
  /// Spacing between children in logical pixels, defaulting to zero.
  final double gap;
  /// Uses multi-line wrapping when true; defaults to false.
  final bool wrap;
  /// Main-axis distribution, defaulting to start.
  final MainAxisAlignment mainAxisAlignment;
  /// Cross-axis alignment, defaulting to center.
  final CrossAxisAlignment crossAxisAlignment;
  /// Main-axis size without wrapping, defaulting to [MainAxisSize.min].
  final MainAxisSize mainAxisSize;
  @override
  Widget build(BuildContext context) => wrap
      ? Wrap(
          direction: direction,
          spacing: gap,
          runSpacing: gap,
          alignment: switch (mainAxisAlignment) {
            MainAxisAlignment.start => WrapAlignment.start,
            MainAxisAlignment.end => WrapAlignment.end,
            MainAxisAlignment.center => WrapAlignment.center,
            MainAxisAlignment.spaceBetween => WrapAlignment.spaceBetween,
            MainAxisAlignment.spaceAround => WrapAlignment.spaceAround,
            MainAxisAlignment.spaceEvenly => WrapAlignment.spaceEvenly,
          },
          crossAxisAlignment: switch (crossAxisAlignment) {
            CrossAxisAlignment.end => WrapCrossAlignment.end,
            CrossAxisAlignment.center => WrapCrossAlignment.center,
            _ => WrapCrossAlignment.start,
          },
          children: children,
        )
      : Flex(
          direction: direction,
          mainAxisSize: mainAxisSize,
          spacing: gap,
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          children: children,
        );
}

/// Horizontal [SeedFlex] shorthand; defaults to start and center alignment.
class SeedHStack extends SeedFlex {
  /// Creates a horizontal sequence with optional [SeedFlex.gap] and wrapping.
  const SeedHStack({
    super.key,
    required super.children,
    super.gap,
    super.wrap,
    super.mainAxisAlignment,
    super.crossAxisAlignment,
    super.mainAxisSize,
  });
}

/// Vertical [SeedFlex] shorthand; defaults to start cross-axis alignment.
class SeedVStack extends SeedFlex {
  /// Creates a vertical sequence with optional spacing and wrapping.
  const SeedVStack({
    super.key,
    required super.children,
    super.gap,
    super.wrap,
    super.mainAxisAlignment,
    super.crossAxisAlignment = CrossAxisAlignment.start,
    super.mainAxisSize,
  }) : super(direction: Axis.vertical);
}

/// Positioned floating content. Place this as a child of Stack.
class SeedFloat extends StatelessWidget {
  /// Creates a [Positioned.fill] overlay aligned inside its [offset] insets.
  const SeedFloat({
    super.key,
    required this.child,
    this.alignment = AlignmentDirectional.bottomEnd,
    this.offset = EdgeInsets.zero,
  });
  /// Floating content, positioned relative to its enclosing Stack.
  final Widget child;
  /// Position within the available area, defaulting to bottom trailing.
  final AlignmentGeometry alignment;
  /// Insets applied before alignment; defaults to [EdgeInsets.zero].
  final EdgeInsetsGeometry offset;
  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: Padding(
      padding: offset,
      child: Align(alignment: alignment, child: child),
    ),
  );
}

/// Equal-width actions that fill the row, as React's ResponsivePair does with
/// `min-width: 50%` and `flex-grow`. When any action's content exceeds its share,
/// each takes the full width and the order reverses (`flex-wrap: wrap-reverse`).
class SeedResponsivePair extends MultiChildRenderObjectWidget {
  /// Creates equal-share action slots, stacking in reverse order when needed.
  const SeedResponsivePair({super.key, required super.children, this.gap = 8});
  /// Spacing between actions both horizontally and vertically (default 8).
  final double gap;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderSeedResponsivePair(gap, Directionality.of(context));

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderBox renderObject,
  ) => (renderObject as _RenderSeedResponsivePair).configure(
    gap,
    Directionality.of(context),
  );
}

class _SeedResponsivePairParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderSeedResponsivePair extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _SeedResponsivePairParentData>,
        RenderBoxContainerDefaultsMixin<
          RenderBox,
          _SeedResponsivePairParentData
        > {
  _RenderSeedResponsivePair(this._gap, this._direction);
  double _gap;
  TextDirection _direction;

  void configure(double gap, TextDirection direction) {
    if (_gap == gap && _direction == direction) return;
    _gap = gap;
    _direction = direction;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _SeedResponsivePairParentData) {
      child.parentData = _SeedResponsivePairParentData();
    }
  }

  double get _totalGap => _gap * math.max(0, childCount - 1);

  Size _layout(BoxConstraints constraints, {required bool dry}) {
    final children = getChildrenAsList();
    if (children.isEmpty) return constraints.smallest;
    final contentWidths = [
      for (final child in children) child.getMaxIntrinsicWidth(double.infinity),
    ];
    final width = constraints.hasBoundedWidth
        ? constraints.maxWidth
        : contentWidths.fold(0.0, math.max) * children.length + _totalGap;
    final share = math.max(0.0, (width - _totalGap) / children.length);
    final wrapped = contentWidths.any((content) => content > share);
    Size measure(RenderBox child, BoxConstraints childConstraints) {
      if (dry) return child.getDryLayout(childConstraints);
      child.layout(childConstraints, parentUsesSize: true);
      return child.size;
    }

    void position(RenderBox child, Offset offset) {
      if (!dry) {
        (child.parentData! as _SeedResponsivePairParentData).offset = offset;
      }
    }

    if (wrapped) {
      var y = 0.0;
      for (final child in children.reversed) {
        final size = measure(child, BoxConstraints.tightFor(width: width));
        position(child, Offset(0, y));
        y += size.height + _gap;
      }
      return constraints.constrain(Size(width, y - _gap));
    }
    var height = 0.0;
    for (final child in children) {
      height = math.max(
        height,
        measure(child, BoxConstraints.tightFor(width: share)).height,
      );
    }
    for (var i = 0; i < children.length; i++) {
      measure(children[i], BoxConstraints.tight(Size(share, height)));
      final x = i * (share + _gap);
      position(
        children[i],
        Offset(_direction == TextDirection.rtl ? width - x - share : x, 0),
      );
    }
    return constraints.constrain(Size(width, height));
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) =>
      _layout(constraints, dry: true);

  @override
  void performLayout() {
    size = _layout(constraints, dry: false);
  }

  @override
  double computeMinIntrinsicWidth(double height) => getChildrenAsList().fold(
    0.0,
    (width, child) => math.max(width, child.getMinIntrinsicWidth(height)),
  );

  @override
  double computeMaxIntrinsicWidth(double height) =>
      getChildrenAsList().fold(
            0.0,
            (width, child) =>
                math.max(width, child.getMaxIntrinsicWidth(height)),
          ) *
          childCount +
      _totalGap;

  double _intrinsicHeight(double width) {
    if (childCount == 0) return 0;
    final share = math.max(0.0, (width - _totalGap) / childCount);
    final children = getChildrenAsList();
    final wrapped = children.any(
      (child) => child.getMaxIntrinsicWidth(double.infinity) > share,
    );
    return wrapped
        ? children.fold(
                0.0,
                (sum, child) => sum + child.getMaxIntrinsicHeight(width),
              ) +
              _totalGap
        : children.fold(
            0.0,
            (tallest, child) =>
                math.max(tallest, child.getMaxIntrinsicHeight(share)),
          );
  }

  @override
  double computeMinIntrinsicHeight(double width) => _intrinsicHeight(width);

  @override
  double computeMaxIntrinsicHeight(double width) => _intrinsicHeight(width);

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}

/// Convenient themed page box with padding, decoration, and optional safe area.
class SeedBox extends StatelessWidget {
  /// Creates a decorated Flutter [Container] with optional [SafeArea] wrapping.
  const SeedBox({
    super.key,
    this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.constraints,
    this.color,
    this.gradient,
    this.border,
    this.borderRadius,
    this.alignment,
    this.safeArea = false,
    this.clipBehavior = Clip.none,
  });
  /// Inner contents of the box.
  final Widget? child;
  /// Internal [padding] and external [margin] around the box.
  final EdgeInsetsGeometry? padding, margin;
  /// Optional fixed [width] and [height] in logical pixels.
  final double? width, height;
  /// Additional layout limits, merged with explicit dimensions.
  final BoxConstraints? constraints;
  /// Solid decoration color; do not set together with [gradient].
  final Color? color;
  /// Optional gradient background.
  final Gradient? gradient;
  /// Optional decoration border.
  final BoxBorder? border;
  /// Optional decoration corner radii.
  final BorderRadiusGeometry? borderRadius;
  /// Placement of [child] inside the box.
  final AlignmentGeometry? alignment;
  /// Wraps the entire box in [SafeArea] when true (default false).
  final bool safeArea;
  /// Decoration clip behavior; defaults to [Clip.none].
  final Clip clipBehavior;
  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: width,
      height: height,
      constraints: constraints,
      padding: padding,
      margin: margin,
      alignment: alignment,
      decoration: BoxDecoration(
        color: color,
        gradient: gradient,
        border: border,
        borderRadius: borderRadius,
      ),
      clipBehavior: clipBehavior,
      child: child,
    );
    return safeArea ? SafeArea(child: box) : box;
  }
}

/// Themed text with optional style overrides and native text selection.
class SeedText extends StatelessWidget {
  /// Creates styled text, defaulting to the current t5 regular typography.
  const SeedText(
    this.data, {
    super.key,
    this.style,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.lineHeight,
    this.decoration,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.softWrap = true,
    this.selectable = false,
    this.locale,
  });
  /// Text to display.
  final String data;
  /// Base style; null uses the current SEED t5 regular typography.
  final TextStyle? style;
  /// Foreground override; null uses the SEED neutral foreground.
  final Color? color;
  /// Optional [fontSize] in logical pixels and [lineHeight] as a height multiplier.
  final double? fontSize, lineHeight;
  /// Font weight override applied after [style].
  final FontWeight? fontWeight;
  /// Text decoration override applied after [style].
  final TextDecoration? decoration;
  /// Maximum number of displayed lines, if constrained.
  final int? maxLines;
  /// Behavior when text exceeds its available extent.
  final TextOverflow? overflow;
  /// Alignment of text lines within the paragraph.
  final TextAlign? textAlign;
  /// [softWrap] defaults to true; [selectable] defaults to false and wraps
  /// the paragraph in a native [SelectionArea] when enabled.
  final bool softWrap, selectable;
  /// Optional text shaping locale, independent of selection.
  final Locale? locale;
  @override
  Widget build(BuildContext context) {
    final effectiveStyle = (style ?? context.seedTypography.t5Regular).copyWith(
      color: color ?? context.seedColor.fg.neutral,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: lineHeight,
      decoration: decoration,
    );
    final text = Text(
      data,
      style: effectiveStyle,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
      softWrap: softWrap,
      locale: locale,
    );
    return selectable ? SelectionArea(child: text) : text;
  }
}
