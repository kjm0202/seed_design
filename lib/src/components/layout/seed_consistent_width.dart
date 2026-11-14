import 'package:material_ui/material_ui.dart';

import '../../foundations/typography/seed_typography.dart';

/// Text whose width does not change when its font weight switches between
/// regular and bold, like React `ConsistentWidth` (React 3.1.0+).
///
/// React renders the text with two hidden, zero-height copies in
/// `::before`/`::after`, one at the regular and one at the bold weight, so
/// the element is as wide as the wider of the two. Selected tabs, chips and
/// toggles that embolden their label therefore keep their size.
///
/// This widget does the same with real layout: two invisible single-line
/// copies of [text] (at [SeedFontWeight.regular] and [SeedFontWeight.bold],
/// otherwise in the same effective style) take part in layout with zero
/// height, and the visible text is drawn on top. The widget's width is the
/// widest of the three, limited by the incoming constraints; its height is the
/// visible text's height.
///
/// The copies use the same text scaler, locale and direction as the visible
/// text, so the reserved width follows large text scaling and RTL. They are
/// excluded from semantics, selection and painting, so screen readers read
/// the text once. When the constraints are narrower than the reserved width,
/// the widget takes the available width and the visible text wraps or
/// truncates with [overflow] and [maxLines] as a plain [Text] would; no
/// overflow is reported.
///
/// ```dart
/// SeedConsistentWidth(
///   '최신순',
///   style: context.seedTypography.t4Regular.copyWith(
///     fontWeight: selected ? SeedFontWeight.bold : SeedFontWeight.regular,
///   ),
/// )
/// ```
class SeedConsistentWidth extends StatelessWidget {
  /// Creates text that reserves the width of its regular and bold renderings.
  ///
  /// [text] corresponds to React's string `children`. [style] is merged with
  /// the ambient [DefaultTextStyle], as in [Text], and decides the visible
  /// weight. [textAlign] positions the visible text inside the reserved
  /// width and defaults to the start edge. [maxLines], [overflow], [softWrap]
  /// and [semanticsLabel] apply to the visible text.
  const SeedConsistentWidth(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.semanticsLabel,
  });

  /// The text to display and to measure in both weights.
  final String text;

  /// Style of the visible text; null uses the ambient [DefaultTextStyle].
  final TextStyle? style;

  /// Alignment of the visible text within the reserved width; null aligns
  /// to the start edge.
  final TextAlign? textAlign;

  /// Maximum number of visible lines; null uses the [DefaultTextStyle] value.
  final int? maxLines;

  /// Visible text overflow handling; null uses the [DefaultTextStyle] value.
  final TextOverflow? overflow;

  /// Whether the visible text wraps at soft line breaks; null uses the
  /// [DefaultTextStyle] value.
  final bool? softWrap;

  /// Alternative accessible label for the visible text.
  final String? semanticsLabel;

  AlignmentGeometry get _alignment {
    switch (textAlign) {
      case TextAlign.center:
        return Alignment.topCenter;
      case TextAlign.right:
        return Alignment.topRight;
      case TextAlign.left:
        return Alignment.topLeft;
      case TextAlign.end:
        return AlignmentDirectional.topEnd;
      case TextAlign.start:
      case TextAlign.justify:
      case null:
        return AlignmentDirectional.topStart;
    }
  }

  Widget _reserve(FontWeight weight) {
    final reserved = (style ?? const TextStyle()).copyWith(fontWeight: weight);
    // Zero height, intrinsic width (CSS `height: 0; display: block`).
    return Align(
      alignment: AlignmentDirectional.topStart,
      widthFactor: 1,
      heightFactor: 0,
      child: Text(
        text,
        style: reserved,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.clip,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: _alignment,
      children: [
        ExcludeSemantics(
          child: SelectionContainer.disabled(
            child: Opacity(
              opacity: 0,
              child: IgnorePointer(
                child: Stack(
                  children: [
                    _reserve(SeedFontWeight.regular),
                    _reserve(SeedFontWeight.bold),
                  ],
                ),
              ),
            ),
          ),
        ),
        Text(
          text,
          style: style,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
          softWrap: softWrap,
          semanticsLabel: semanticsLabel,
        ),
      ],
    );
  }
}
