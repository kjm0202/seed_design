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

class SeedAspectRatio extends AspectRatio {
  const SeedAspectRatio({super.key, required double ratio, super.child})
    : super(aspectRatio: ratio);
}

/// Breakpoint-aware composition; updates when its actual available width changes.
class SeedResponsive extends StatelessWidget {
  const SeedResponsive({
    super.key,
    required this.small,
    required this.medium,
    this.large,
    this.mediumBreakpoint = 768,
    this.largeBreakpoint = 1024,
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
    this.offset = const EdgeInsets.all(16),
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
class SeedResponsivePair extends StatelessWidget {
  const SeedResponsivePair({super.key, required this.children, this.gap = 8});
  final List<Widget> children;
  final double gap;
  @override
  Widget build(BuildContext context) => OverflowBar(
    spacing: gap,
    overflowSpacing: gap,
    alignment: MainAxisAlignment.end,
    overflowAlignment: OverflowBarAlignment.end,
    children: children,
  );
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
