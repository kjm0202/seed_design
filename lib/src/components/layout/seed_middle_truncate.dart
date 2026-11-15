import 'package:material_ui/material_ui.dart';

/// The official headless `MiddleTruncate`: shortens text in the middle so that
/// it fits in [maxLines], keeping its start and the last [end] characters.
///
/// For file names, pass the extension length as [end] so that
/// `report-final-version.pdf` becomes `report-fi…on.pdf`. The text is fitted
/// again whenever the available width, the text or the style changes.
///
/// Characters are counted as user-perceived characters (grapheme clusters),
/// so an emoji or a combined Hangul syllable is never split.
class SeedMiddleTruncate extends StatefulWidget {
  /// Creates a middle-truncated [text].
  ///
  /// [end] defaults to 0, [ellipsis] to `…`, and [maxLines] to 1.
  const SeedMiddleTruncate(
    this.text, {
    super.key,
    this.end = 0,
    this.ellipsis = '…',
    this.maxLines = 1,
    this.onTruncate,
    this.style,
    this.textAlign,
    this.semanticsLabel,
  }) : assert(maxLines > 0);

  /// The full text, the official `children`.
  final String text;

  /// Number of characters kept from the end. When even the ellipsis and
  /// these characters do not fit, the end is shortened too.
  final int end;

  /// Inserted where characters were removed.
  final String ellipsis;

  /// Number of lines the shortened text may use.
  final int maxLines;

  /// Reports whether the text had to be shortened, after each fitting whose
  /// result differs from the previous one.
  final ValueChanged<bool>? onTruncate;

  /// Text style, merged with the ambient [DefaultTextStyle].
  final TextStyle? style;

  /// Alignment of the lines.
  final TextAlign? textAlign;

  /// Spoken text. Defaults to the full [text], so a screen reader hears what
  /// was shortened on screen. This is a Flutter extension; the official
  /// element exposes only the shortened text.
  final String? semanticsLabel;

  @override
  State<SeedMiddleTruncate> createState() => _SeedMiddleTruncateState();
}

class _SeedMiddleTruncateState extends State<SeedMiddleTruncate> {
  bool? _reported;

  void _report(bool truncated) {
    if (widget.onTruncate == null || truncated == _reported) return;
    _reported = truncated;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onTruncate?.call(truncated);
    });
  }

  String _fit(BuildContext context, double maxWidth) {
    final text = widget.text;
    if (text.isEmpty || !maxWidth.isFinite || maxWidth <= 0) {
      _report(false);
      return text;
    }
    final painter = TextPainter(
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      locale: Localizations.maybeLocaleOf(context),
      maxLines: widget.maxLines,
      textAlign: widget.textAlign ?? TextAlign.start,
    );
    final style = DefaultTextStyle.of(context).style.merge(widget.style);
    bool fits(String candidate) {
      painter.text = TextSpan(text: candidate, style: style);
      painter.layout(maxWidth: maxWidth);
      return !painter.didExceedMaxLines;
    }

    try {
      if (fits(text)) {
        _report(false);
        return text;
      }
      final characters = text.characters.toList();
      final keep = widget.end.abs().clamp(0, characters.length);
      final endPart = characters.sublist(characters.length - keep);
      final startPart = characters.sublist(0, characters.length - keep);
      String join(List<String> start, List<String> end) =>
          '${start.join()}${widget.ellipsis}${end.join()}';

      _report(true);
      // As in the official hook: when the ellipsis and the kept end alone
      // overflow, keep as much of the end as fits and drop the start.
      if (!fits(join(const [], endPart))) {
        var low = 0, high = endPart.length;
        while (low < high) {
          final mid = (low + high + 1) ~/ 2;
          if (fits(join(const [], endPart.sublist(endPart.length - mid)))) {
            low = mid;
          } else {
            high = mid - 1;
          }
        }
        return join(const [], endPart.sublist(endPart.length - low));
      }
      var low = 0, high = startPart.length;
      while (low < high) {
        final mid = (low + high + 1) ~/ 2;
        if (fits(join(startPart.sublist(0, mid), endPart))) {
          low = mid;
        } else {
          high = mid - 1;
        }
      }
      return join(startPart.sublist(0, low), endPart);
    } finally {
      painter.dispose();
    }
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Text(
      _fit(context, constraints.maxWidth),
      style: widget.style,
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      overflow: TextOverflow.clip,
      semanticsLabel: widget.semanticsLabel ?? widget.text,
    ),
  );
}
