import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/semantics.dart' show SemanticsValidationResult;

import '../../foundations/colors/seed_palette.dart';
import '../../theme/seed_theme.dart';
import 'seed_field.dart';

enum SeedSliderTickWeight { thin, thick }

enum SeedValueIndicatorTrigger { auto, hover, active }

enum SeedSliderMarkerAlign { start, center, end }

class SeedSliderMarker {
  const SeedSliderMarker(
    this.value,
    this.label, {
    this.align = SeedSliderMarkerAlign.center,
  });
  final double value;
  final String label;
  final SeedSliderMarkerAlign align;
}

/// Single-thumb input. Values may be controlled or initialized with defaultValue.
class SeedSlider extends StatefulWidget {
  const SeedSlider({
    super.key,
    this.value,
    this.defaultValue,
    this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.min = 0,
    this.max = 100,
    this.divisions,
    this.label,
    this.isBrand = false,
    this.enabled = true,
    this.readOnly = false,
    this.invalid = false,
    this.step,
    this.allowedValues,
    this.ticks = const [],
    this.markers = const [],
    this.tickWeight = SeedSliderTickWeight.thin,
    this.showActiveTrack = true,
    this.hideValueIndicator = false,
    this.valueIndicatorTrigger = SeedValueIndicatorTrigger.auto,
    this.valueFormatter,
    this.semanticsValueFormatter,
    this.semanticsLabel,
    this.fieldLabel,
    this.description,
    this.errorMessage,
  }) : assert(min < max),
       assert(step == null || step > 0),
       assert(divisions == null || divisions > 0),
       rangeValues = null,
       defaultRangeValues = null,
       onRangeChanged = null,
       onRangeChangeStart = null,
       onRangeChangeEnd = null,
       minStepsBetweenThumbs = 0,
       _range = false;

  const SeedSlider.range({
    super.key,
    RangeValues? values,
    RangeValues? defaultValues,
    ValueChanged<RangeValues>? onChanged,
    ValueChanged<RangeValues>? onChangeStart,
    ValueChanged<RangeValues>? onChangeEnd,
    this.min = 0,
    this.max = 100,
    this.divisions,
    this.isBrand = false,
    this.enabled = true,
    this.readOnly = false,
    this.invalid = false,
    this.step,
    this.allowedValues,
    this.ticks = const [],
    this.markers = const [],
    this.tickWeight = SeedSliderTickWeight.thin,
    this.showActiveTrack = true,
    this.hideValueIndicator = false,
    this.valueIndicatorTrigger = SeedValueIndicatorTrigger.auto,
    this.valueFormatter,
    this.semanticsValueFormatter,
    this.semanticsLabel,
    this.fieldLabel,
    this.description,
    this.errorMessage,
    this.minStepsBetweenThumbs = 0,
  }) : assert(min < max),
       assert(step == null || step > 0),
       assert(divisions == null || divisions > 0),
       assert(minStepsBetweenThumbs >= 0),
       rangeValues = values,
       defaultRangeValues = defaultValues,
       onRangeChanged = onChanged,
       onRangeChangeStart = onChangeStart,
       onRangeChangeEnd = onChangeEnd,
       value = null,
       defaultValue = null,
       onChanged = null,
       onChangeStart = null,
       onChangeEnd = null,
       label = null,
       _range = true;

  final double? value;
  final double? defaultValue;
  final RangeValues? rangeValues;
  final RangeValues? defaultRangeValues;
  final ValueChanged<double>? onChanged, onChangeStart, onChangeEnd;
  final ValueChanged<RangeValues>? onRangeChanged,
      onRangeChangeStart,
      onRangeChangeEnd;
  final double min, max;
  final int? divisions;
  final String? label;
  final bool isBrand,
      enabled,
      readOnly,
      invalid,
      showActiveTrack,
      hideValueIndicator;
  final double? step;
  final List<double>? allowedValues;
  final List<double> ticks;
  final List<SeedSliderMarker> markers;
  final SeedSliderTickWeight tickWeight;
  final SeedValueIndicatorTrigger valueIndicatorTrigger;
  final String Function(double)? valueFormatter;
  final String Function(double, int)? semanticsValueFormatter;
  final String? semanticsLabel, fieldLabel, description, errorMessage;
  final int minStepsBetweenThumbs;
  final bool _range;
  @override
  State<SeedSlider> createState() => _SeedSliderState();
}

class SeedRangeSlider extends SeedSlider {
  const SeedRangeSlider({
    super.key,
    super.values,
    super.defaultValues,
    super.onChanged,
    super.onChangeStart,
    super.onChangeEnd,
    super.min,
    super.max,
    super.divisions,
    super.step,
    super.allowedValues,
    super.ticks,
    super.markers,
    super.tickWeight,
    super.enabled,
    super.readOnly,
    super.invalid,
    super.isBrand,
    super.showActiveTrack,
    super.hideValueIndicator,
    super.valueIndicatorTrigger,
    super.valueFormatter,
    super.semanticsValueFormatter,
    super.semanticsLabel,
    super.fieldLabel,
    super.description,
    super.errorMessage,
    super.minStepsBetweenThumbs,
  }) : super.range();
}

class _SeedSliderState extends State<SeedSlider> {
  late double _value = snap(
    widget.defaultValue ?? (widget.min + widget.max) / 2,
  );
  late RangeValues _range =
      widget.defaultRangeValues ?? RangeValues(widget.min, widget.max);
  RangeValues? _lastRange;
  bool _active = false, _hover = false, _focus = false;
  double get value => (widget.value ?? _value).clamp(widget.min, widget.max);
  RangeValues get range {
    final r = widget.rangeValues ?? _range;
    return RangeValues(
      r.start.clamp(widget.min, widget.max),
      r.end.clamp(widget.min, widget.max),
    );
  }

  String format(double value) =>
      widget.valueFormatter?.call(value) ??
      (value == value.roundToDouble()
          ? value.toInt().toString()
          : value.toStringAsFixed(1));
  double snap(double value) {
    final allowed = widget.allowedValues
        ?.where((v) => v >= widget.min && v <= widget.max)
        .toList();
    if (allowed != null && allowed.isNotEmpty) {
      return allowed.reduce(
        (a, b) => (a - value).abs() <= (b - value).abs() ? a : b,
      );
    }
    final step =
        widget.step ??
        (widget.divisions != null && widget.divisions! > 0
            ? (widget.max - widget.min) / widget.divisions!
            : 1.0);
    return (widget.min + ((value - widget.min) / step).round() * step).clamp(
      widget.min,
      widget.max,
    );
  }

  // Keep Material's keyboard and accessibility increments in the same units
  // as pointer snapping, rather than its continuous-slider default of 5%.
  int? get _effectiveDivisions {
    if (widget.allowedValues != null) return null;
    final step =
        widget.step ??
        (widget.divisions == null
            ? 1.0
            : (widget.max - widget.min) / widget.divisions!);
    final count = (widget.max - widget.min) / step;
    final rounded = count.round();
    return rounded > 0 && (count - rounded).abs() < 1e-8 ? rounded : null;
  }

  void change(double v) {
    if (widget.readOnly) return;
    final next = snap(v);
    if (next == value) return;
    if (widget.value == null) setState(() => _value = next);
    widget.onChanged?.call(next);
  }

  void changeRange(RangeValues v) {
    if (widget.readOnly) return;
    var start = snap(v.start), end = snap(v.end);
    final allowed =
        widget.allowedValues
            ?.where((val) => val >= widget.min && val <= widget.max)
            .toSet()
            .toList()
          ?..sort();
    if (allowed == null || allowed.isEmpty) {
      final gap =
          widget.minStepsBetweenThumbs *
          (widget.step ??
              (widget.divisions != null && widget.divisions! > 0
                  ? (widget.max - widget.min) / widget.divisions!
                  : 1.0));
      if (end - start < gap) {
        if (v.start != range.start) {
          start = math.max(widget.min, end - gap);
        } else {
          end = math.min(widget.max, start + gap);
        }
      }
    } else if (widget.minStepsBetweenThumbs > 0) {
      final gap = widget.minStepsBetweenThumbs
          .clamp(0, math.max(0, allowed.length - 1))
          .toInt();
      var startIndex = allowed.indexOf(start), endIndex = allowed.indexOf(end);
      if (startIndex >= 0 && endIndex >= 0 && endIndex - startIndex < gap) {
        if (v.start != range.start) {
          startIndex = (endIndex - gap).clamp(0, allowed.length - 1);
          endIndex = (startIndex + gap).clamp(0, allowed.length - 1);
        } else {
          endIndex = (startIndex + gap).clamp(0, allowed.length - 1);
          startIndex = (endIndex - gap).clamp(0, allowed.length - 1);
        }
        start = allowed[startIndex];
        end = allowed[endIndex];
      }
    }
    final next = RangeValues(math.min(start, end), math.max(start, end));
    _lastRange = next;
    if (next == range) return;
    if (widget.rangeValues == null) setState(() => _range = next);
    widget.onRangeChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final activeRange = widget.isBrand
        ? colors.bg.brandSolid
        : colors.fg.neutral;
    final activeThumb = widget.isBrand
        ? colors.bg.brandSolid
        : colors.bg.neutralSolid;
    final inactive = colors.isDark
        ? SeedPalette.gray400Dark
        : SeedPalette.gray400Light;
    final showTooltip =
        widget.enabled &&
        !widget.hideValueIndicator &&
        (_focus ||
            (widget.valueIndicatorTrigger != SeedValueIndicatorTrigger.hover &&
                _active) ||
            (widget.valueIndicatorTrigger != SeedValueIndicatorTrigger.active &&
                _hover));
    Widget control = LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final rtl = Directionality.of(context) == TextDirection.rtl;
        double fraction(double value) {
          final f = ((value - widget.min) / (widget.max - widget.min)).clamp(
            0.0,
            1.0,
          );
          return rtl ? 1 - f : f;
        }

        final values = widget._range ? [range.start, range.end] : [value];
        final slider = widget._range
            ? RangeSlider(
                values: range,
                min: widget.min,
                max: widget.max,
                divisions: _effectiveDivisions,
                labels: RangeLabels(format(range.start), format(range.end)),
                semanticFormatterCallback: (v) =>
                    widget.semanticsValueFormatter?.call(
                      v,
                      v == range.start ? 0 : 1,
                    ) ??
                    format(v),
                onChanged: widget.enabled
                    ? (v) {
                        if (!widget.readOnly) changeRange(v);
                      }
                    : null,
                onChangeStart: widget.enabled && !widget.readOnly
                    ? (v) {
                        setState(() => _active = true);
                        widget.onRangeChangeStart?.call(v);
                      }
                    : null,
                onChangeEnd: widget.enabled && !widget.readOnly
                    ? (v) {
                        setState(() => _active = false);
                        widget.onRangeChangeEnd?.call(_lastRange ?? range);
                      }
                    : null,
              )
            : Slider(
                value: value,
                min: widget.min,
                max: widget.max,
                divisions: _effectiveDivisions,
                label: widget.label ?? format(value),
                semanticFormatterCallback: (v) =>
                    widget.semanticsValueFormatter?.call(v, 0) ?? format(v),
                onChanged: widget.enabled
                    ? (v) {
                        if (!widget.readOnly) change(v);
                      }
                    : null,
                onChangeStart: widget.enabled && !widget.readOnly
                    ? (v) {
                        setState(() => _active = true);
                        widget.onChangeStart?.call(snap(v));
                      }
                    : null,
                onChangeEnd: widget.enabled && !widget.readOnly
                    ? (v) {
                        setState(() => _active = false);
                        widget.onChangeEnd?.call(snap(v));
                      }
                    : null,
              );
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MouseRegion(
              onHover: (event) {
                final overThumb = values.any(
                  (v) =>
                      (event.localPosition.dx -
                              (24 + fraction(v) * (width - 48)))
                          .abs() <=
                      16,
                );
                if (overThumb != _hover) setState(() => _hover = overThumb);
              },
              onExit: (_) {
                if (_hover) setState(() => _hover = false);
              },
              child: Focus(
                canRequestFocus: false,
                onFocusChange: (v) => setState(() => _focus = v),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    slider,
                    if (widget.ticks.isNotEmpty)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: _SeedSliderTicks(
                              widget.ticks.map(fraction).toList(),
                              widget.enabled
                                  ? colors.fg.onNeutralSolid
                                  : colors.fg.disabled,
                              widget.tickWeight == SeedSliderTickWeight.thick
                                  ? 4
                                  : 1,
                            ),
                          ),
                        ),
                      ),
                    if (showTooltip)
                      for (final v in values)
                        Positioned(
                          left: 24 + fraction(v) * (width - 48),
                          top: -28,
                          child: FractionalTranslation(
                            translation: const Offset(-0.5, 0),
                            child: ExcludeSemantics(
                              child: IgnorePointer(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        minWidth: 24,
                                      ),
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          color: colors.bg.neutralSolid,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          child: Text(
                                            widget.label ?? format(v),
                                            textAlign: TextAlign.center,
                                            style: context
                                                .seedTypography
                                                .t3Medium
                                                .copyWith(
                                                  color:
                                                      colors.fg.onNeutralSolid,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    CustomPaint(
                                      size: const Size(8, 6),
                                      painter: _SeedSliderIndicatorArrow(
                                        colors.bg.neutralSolid,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ),
            if (widget.markers.isNotEmpty)
              SizedBox(
                height: 28,
                child: ExcludeSemantics(
                  child: Stack(
                    children: [
                      for (final marker in widget.markers)
                        Positioned(
                          left: 24 + fraction(marker.value) * (width - 48),
                          top: 0,
                          bottom: 0,
                          child: FractionalTranslation(
                            translation: Offset(switch (marker.align) {
                              SeedSliderMarkerAlign.start => rtl ? -1 : 0,
                              SeedSliderMarkerAlign.center => -0.5,
                              SeedSliderMarkerAlign.end => rtl ? 0 : -1,
                            }, 0),
                            child: Center(
                              child: Text(
                                marker.label,
                                textAlign: switch (marker.align) {
                                  SeedSliderMarkerAlign.start =>
                                    TextAlign.start,
                                  SeedSliderMarkerAlign.center =>
                                    TextAlign.center,
                                  SeedSliderMarkerAlign.end => TextAlign.end,
                                },
                                style: context.seedTypography.t3Regular
                                    .copyWith(
                                      color: widget.enabled
                                          ? colors.fg.neutralMuted
                                          : colors.fg.disabled,
                                    ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
    control = Semantics(
      label: widget.semanticsLabel,
      readOnly: widget.readOnly,
      validationResult: widget.invalid || widget.errorMessage != null
          ? SemanticsValidationResult.invalid
          : SemanticsValidationResult.none,
      child: SliderTheme(
        data: SliderThemeData(
          trackHeight: 4,
          activeTrackColor: widget.showActiveTrack ? activeRange : inactive,
          inactiveTrackColor: inactive,
          disabledActiveTrackColor: widget.showActiveTrack
              ? colors.fg.disabled
              : colors.bg.disabled,
          disabledInactiveTrackColor: colors.bg.disabled,
          disabledThumbColor: colors.fg.disabled,
          thumbColor: activeThumb,
          overlayColor: activeThumb.withValues(alpha: 0.12),
          thumbShape: const RoundSliderThumbShape(
            enabledThumbRadius: 10,
            elevation: 0,
            pressedElevation: 0,
          ),
          rangeThumbShape: const RoundRangeSliderThumbShape(
            enabledThumbRadius: 10,
            elevation: 0,
            pressedElevation: 0,
          ),
          tickMarkShape: widget.divisions == null
              ? SliderTickMarkShape.noTickMark
              : const RoundSliderTickMarkShape(tickMarkRadius: 2),
          activeTickMarkColor: colors.fg.onNeutralSolid,
          inactiveTickMarkColor: colors.fg.onNeutralSolid,
          showValueIndicator: ShowValueIndicator.never,
        ),
        child: control,
      ),
    );
    return widget.fieldLabel != null ||
            widget.description != null ||
            widget.errorMessage != null
        ? SeedField(
            label: widget.fieldLabel,
            helperText: widget.description,
            errorMessage: widget.errorMessage,
            isInvalid: widget.invalid,
            child: control,
          )
        : control;
  }
}

class _SeedSliderIndicatorArrow extends CustomPainter {
  const _SeedSliderIndicatorArrow(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    const tipRadius = 2.0;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2 + tipRadius, size.height - tipRadius)
      ..quadraticBezierTo(
        size.width / 2,
        size.height,
        size.width / 2 - tipRadius,
        size.height - tipRadius,
      )
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_SeedSliderIndicatorArrow oldDelegate) =>
      color != oldDelegate.color;
}

class _SeedSliderTicks extends CustomPainter {
  _SeedSliderTicks(this.positions, this.color, this.width);
  final List<double> positions;
  final Color color;
  final double width;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;
    for (final f in positions) {
      final x = 24 + f * (size.width - 48);
      canvas.drawLine(
        Offset(x, size.height / 2 - 3),
        Offset(x, size.height / 2 + 3),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_SeedSliderTicks oldDelegate) =>
      positions != oldDelegate.positions ||
      color != oldDelegate.color ||
      width != oldDelegate.width;
}
