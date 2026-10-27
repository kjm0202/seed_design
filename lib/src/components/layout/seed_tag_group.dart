import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';

import 'dart:math' as math;

import '../../foundations/dimensions/seed_dimension.dart';
import '../../theme/seed_theme.dart';
import '../../foundations/colors/seed_palette.dart';

/// Size of [SeedTagItem] and [SeedTagGroup].
enum SeedTagGroupSize {
  t2, // 12pt
  t3, // 13pt
  t4, // 14pt
}

/// Tone of [SeedTagItem].
enum SeedTagTone { neutralSubtle, neutral, brand }

/// An individual tag item in a [SeedTagGroup].
class SeedTagItem {
  final String label;
  final Widget? icon;
  final Widget? suffix;
  final Widget? labelWidget;
  final double flexShrink;
  final SeedTagGroupSize? size;
  final SeedTagTone? tone;
  final bool? bold;
  final String? semanticsLabel;

  const SeedTagItem({
    required this.label,
    this.icon,
    this.suffix,
    this.labelWidget,
    this.flexShrink = 1,
    this.size,
    this.tone,
    this.bold,
    this.semanticsLabel,
  });
}

/// Tag Group component of SEED Design System.
///
/// Displays metadata, summary tags, or entity attributes horizontally
/// separated by a bullet dot (`·`).
class SeedTagGroup extends StatelessWidget {
  final List<SeedTagItem> items;
  final SeedTagGroupSize size;
  final SeedTagTone tone;
  final bool bold;
  final String separator;
  final Widget? separatorWidget;
  final bool truncate;

  const SeedTagGroup({
    super.key,
    required this.items,
    this.size = SeedTagGroupSize.t2,
    this.tone = SeedTagTone.neutralSubtle,
    this.bold = false,
    this.separator = '·',
    this.separatorWidget,
    this.truncate = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;

    TextStyle baseStyleFor(SeedTagGroupSize targetSize) {
      switch (targetSize) {
        case SeedTagGroupSize.t2:
          return typography.t2Regular;
        case SeedTagGroupSize.t3:
          return typography.t3Regular;
        case SeedTagGroupSize.t4:
          return typography.t4Regular;
      }
    }

    double iconSizeFor(SeedTagGroupSize targetSize) =>
        targetSize == SeedTagGroupSize.t2
        ? 12.0
        : (targetSize == SeedTagGroupSize.t3 ? 13.0 : 14.0);

    final TextStyle groupBaseStyle = baseStyleFor(size);

    TextStyle style(SeedTagItem item) {
      final effectiveSize = item.size ?? size;
      final effectiveTone = item.tone ?? tone;
      final effectiveBold = item.bold ?? bold;
      return baseStyleFor(effectiveSize).copyWith(
        color: switch (effectiveTone) {
          SeedTagTone.neutralSubtle => colors.fg.neutralSubtle,
          SeedTagTone.neutral => colors.fg.neutral,
          SeedTagTone.brand => colors.fg.brand,
        },
        fontWeight: effectiveBold ? FontWeight.bold : FontWeight.normal,
      );
    }

    Widget tag(SeedTagItem item) {
      final itemStyle = style(item);
      final itemIconSize = iconSizeFor(item.size ?? size);
      final content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (item.icon != null) ...[
            IconTheme(
              data: IconThemeData(color: itemStyle.color, size: itemIconSize),
              child: item.icon!,
            ),
            const SizedBox(width: 2),
          ],
          Flexible(
            child:
                item.labelWidget ??
                Text(
                  item.label,
                  style: itemStyle,
                  maxLines: truncate ? 1 : null,
                  overflow: truncate ? TextOverflow.ellipsis : null,
                ),
          ),
          if (item.suffix != null) ...[
            const SizedBox(width: 2),
            IconTheme(
              data: IconThemeData(color: itemStyle.color, size: itemIconSize),
              child: item.suffix!,
            ),
          ],
        ],
      );
      if (item.semanticsLabel != null) {
        return Semantics(
          label: item.semanticsLabel,
          excludeSemantics: true,
          child: content,
        );
      }
      return content;
    }

    Widget buildSeparator() => ExcludeSemantics(
      child:
          separatorWidget ??
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SeedDimension.x1),
            child: Text(
              separator,
              style: groupBaseStyle.copyWith(
                color: colors.isDark
                    ? SeedPalette.gray600Dark
                    : SeedPalette.gray600Light,
              ),
            ),
          ),
    );
    if (!truncate) {
      return Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) buildSeparator(),
            tag(items[i]),
          ],
        ],
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        double measure(String text, TextStyle style) {
          final painter = TextPainter(
            text: TextSpan(text: text, style: style),
            textDirection: Directionality.of(context),
            textScaler: MediaQuery.textScalerOf(context),
          )..layout();
          final width = painter.width;
          painter.dispose();
          return width;
        }

        final affixes = [
          for (final item in items)
            (item.icon == null ? 0.0 : iconSizeFor(item.size ?? size) + 2) +
                (item.suffix == null
                    ? 0.0
                    : iconSizeFor(item.size ?? size) + 2),
        ];
        final widths = [
          for (var i = 0; i < items.length; i++)
            measure(items[i].label, style(items[i])) + affixes[i],
        ];
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          primary: false,
          physics: const NeverScrollableScrollPhysics(),
          child: _SeedTruncatedTags(
            availableWidth: constraints.maxWidth,
            preferredWidths: widths,
            minimumWidths: affixes,
            shrinkFactors: items.map((item) => item.flexShrink).toList(),
            direction: Directionality.of(context),
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) buildSeparator(),
                tag(items[i]),
              ],
            ],
          ),
        );
      },
    );
  }
}

// Lay out separators before allocating tag widths. Measuring them in the same
// layout pass also handles custom separators that resize after a rebuild.
class _SeedTruncatedTags extends MultiChildRenderObjectWidget {
  const _SeedTruncatedTags({
    required this.availableWidth,
    required this.preferredWidths,
    required this.minimumWidths,
    required this.shrinkFactors,
    required this.direction,
    required super.children,
  });
  final double availableWidth;
  final List<double> preferredWidths, minimumWidths, shrinkFactors;
  final TextDirection direction;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _SeedTruncatedTagsRender(
        availableWidth,
        preferredWidths,
        minimumWidths,
        shrinkFactors,
        direction,
      );

  @override
  void updateRenderObject(
    BuildContext context,
    _SeedTruncatedTagsRender renderObject,
  ) {
    renderObject
      ..availableWidth = availableWidth
      ..preferredWidths = preferredWidths
      ..minimumWidths = minimumWidths
      ..shrinkFactors = shrinkFactors
      ..direction = direction
      ..markNeedsLayout();
  }
}

class _SeedTagParentData extends ContainerBoxParentData<RenderBox> {}

class _SeedTruncatedTagsRender extends RenderBox
    with
        ContainerRenderObjectMixin<
          RenderBox,
          ContainerBoxParentData<RenderBox>
        >,
        RenderBoxContainerDefaultsMixin<
          RenderBox,
          ContainerBoxParentData<RenderBox>
        > {
  _SeedTruncatedTagsRender(
    this.availableWidth,
    this.preferredWidths,
    this.minimumWidths,
    this.shrinkFactors,
    this.direction,
  );
  double availableWidth;
  List<double> preferredWidths, minimumWidths, shrinkFactors;
  TextDirection direction;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! ContainerBoxParentData<RenderBox>) {
      child.parentData = _SeedTagParentData();
    }
  }

  @override
  void performLayout() {
    final children = getChildrenAsList();
    final widths = List<double>.of(preferredWidths);
    var separatorsWidth = 0.0;
    for (var i = 1; i < children.length; i += 2) {
      children[i].layout(
        BoxConstraints(
          maxWidth: availableWidth,
          maxHeight: constraints.maxHeight,
        ),
        parentUsesSize: true,
      );
      separatorsWidth += children[i].size.width;
    }
    var deficit =
        widths.fold(0.0, (a, b) => a + b) + separatorsWidth - availableWidth;
    for (var pass = 0; pass < widths.length && deficit > .01; pass++) {
      final weights = [
        for (var i = 0; i < widths.length; i++)
          widths[i] > minimumWidths[i] ? shrinkFactors[i] * widths[i] : 0.0,
      ];
      final sum = weights.fold(0.0, (a, b) => a + b);
      if (sum <= 0) break;
      var removed = 0.0;
      for (var i = 0; i < widths.length; i++) {
        final reduction = (deficit * weights[i] / sum).clamp(
          0.0,
          widths[i] - minimumWidths[i],
        );
        widths[i] -= reduction;
        removed += reduction;
      }
      deficit -= removed;
    }
    var height = 0.0;
    var totalWidth = 0.0;
    for (var i = 0; i < children.length; i++) {
      final child = children[i];
      if (i.isEven) {
        child.layout(
          BoxConstraints(
            minWidth: widths[i ~/ 2],
            maxWidth: widths[i ~/ 2],
            maxHeight: constraints.maxHeight,
          ),
          parentUsesSize: true,
        );
      }
      totalWidth += child.size.width;
      height = math.max(height, child.size.height);
    }
    size = constraints.constrain(Size(totalWidth, height));
    var x = 0.0;
    for (final child in children) {
      final data = child.parentData! as ContainerBoxParentData<RenderBox>;
      data.offset = Offset(
        direction == TextDirection.rtl ? size.width - x - child.size.width : x,
        (size.height - child.size.height) / 2,
      );
      x += child.size.width;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);
  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}
