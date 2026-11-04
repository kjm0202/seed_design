import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

import '../../theme/seed_theme.dart';

/// Selectable article content. Text locale and scaling remain native.
class SeedArticle extends StatelessWidget {
  const SeedArticle({
    super.key,
    required this.child,
    this.selectable = true,
    this.locale,
  });
  final Widget child;
  final bool selectable;
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

class SeedAspectRatio extends StatelessWidget {
  const SeedAspectRatio({super.key, this.ratio = 4 / 3, this.child});

  final double ratio;
  final Widget? child;

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: ratio,
    child: ClipRect(child: child),
  );
}

/// Breakpoint-aware composition; updates when its actual available width changes.
class SeedResponsive extends StatelessWidget {
  const SeedResponsive({
    super.key,
    required this.small,
    required this.medium,
    this.large,
    this.mediumBreakpoint = 768,
    this.largeBreakpoint = 1280,
  });
  final Widget small, medium;
  final Widget? large;
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

enum SeedLayoutDensity {
  low,
  medium,
  high,
}

class SeedLayoutContent extends StatelessWidget {
  const SeedLayoutContent({
    super.key,
    required this.child,
    this.density = SeedLayoutDensity.medium,
  });
  final Widget child;
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

class SeedFlex extends StatelessWidget {
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
  final List<Widget> children;
  final Axis direction;
  final double gap;
  final bool wrap;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
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

class SeedHStack extends SeedFlex {
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

class SeedVStack extends SeedFlex {
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
  const SeedFloat({
    super.key,
    required this.child,
    this.alignment = AlignmentDirectional.bottomEnd,
    this.offset = EdgeInsets.zero,
  });
  final Widget child;
  final AlignmentGeometry alignment;
  final EdgeInsetsGeometry offset;
  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: Padding(
      padding: offset,
      child: Align(alignment: alignment, child: child),
    ),
  );
}

/// Automatic horizontal-to-vertical action layout based on measured child widths.
class SeedResponsivePair extends MultiChildRenderObjectWidget {
  const SeedResponsivePair({super.key, required super.children, this.gap = 8});
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

class SeedBox extends StatelessWidget {
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
  final Widget? child;
  final EdgeInsetsGeometry? padding, margin;
  final double? width, height;
  final BoxConstraints? constraints;
  final Color? color;
  final Gradient? gradient;
  final BoxBorder? border;
  final BorderRadiusGeometry? borderRadius;
  final AlignmentGeometry? alignment;
  final bool safeArea;
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

class SeedText extends StatelessWidget {
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
  final String data;
  final TextStyle? style;
  final Color? color;
  final double? fontSize, lineHeight;
  final FontWeight? fontWeight;
  final TextDecoration? decoration;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final bool softWrap, selectable;
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
