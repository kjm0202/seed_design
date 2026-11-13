import 'dart:async';
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/semantics.dart' show SemanticsValidationResult;
import 'package:flutter/services.dart';

import '../../foundations/colors/seed_palette.dart';
import '../../foundations/motion/seed_motion.dart';
import '../../theme/seed_theme.dart';
import 'seed_field.dart';

/// Thickness of scale marks along a [SeedSlider].
enum SeedSliderTickWeight {
  /// Subtle tick marks.
  thin,

  /// Emphasized tick marks.
  thick,
}

/// Conditions under which a slider's value indicator appears.
enum SeedValueIndicatorTrigger {
  /// Let the slider determine when to display the indicator.
  auto,

  /// Display the indicator when the control is hovered.
  hover,

  /// Display the indicator while a thumb is being manipulated.
  active,
}

/// Horizontal positioning of a [SeedSliderMarker] label.
enum SeedSliderMarkerAlign {
  /// Align the start of the label with its numeric position.
  start,

  /// Center the label over its numeric position.
  center,

  /// Align the end of the label with its numeric position.
  end,
}

/// Labeled reference mark positioned at a numeric value on a [SeedSlider].
class SeedSliderMarker {
  /// Creates a marker at [value] with the visible [label].
  ///
  /// When [align] is null (the default), the official slider snippet rule
  /// applies: a marker at `min` aligns to its start, one at `max` to its end,
  /// and any other marker is centered.
  const SeedSliderMarker(this.value, this.label, {this.align});

  /// Numeric location of the marker on the slider track.
  final double value;

  /// Text displayed at the marker.
  final String label;

  /// Positioning of [label] relative to [value]; null selects it by value.
  final SeedSliderMarkerAlign? align;

  /// The alignment used on a slider spanning [min]..[max].
  SeedSliderMarkerAlign resolveAlign(double min, double max) =>
      align ??
      (value <= min
          ? SeedSliderMarkerAlign.start
          : value >= max
          ? SeedSliderMarkerAlign.end
          : SeedSliderMarkerAlign.center);
}

/// One or two thumbs using React values/defaultValues and list callbacks.
/// Scalar inputs and callbacks are deprecated; RangeValues inputs remain adapters.
///
/// Values snap to [allowedValues] if supplied, otherwise to [step] (default
/// one) or [divisions]. [min] and [max] bound both thumbs; range mode enforces
/// [minStepsBetweenThumbs]. [onValuesChange] proposes values during interaction,
/// and [onValuesCommit] reports the completed gesture.
class SeedSlider extends StatefulWidget {
  /// Creates a slider with one or two values in the React-compatible list API.
  ///
  /// [values] controls the selection and [defaultValues] seeds local state.
  /// Without either, a single thumb starts midway between [min] and [max].
  /// [value], [defaultValue], and [onChanged] are legacy scalar alternatives
  /// and cannot be combined with their list counterparts.
  const SeedSlider({
    super.key,
    List<double>? values,
    List<double>? defaultValues,
    this.onValuesChange,
    this.onValuesCommit,
    this.minStepsBetweenThumbs = 0,
    this.jumpMultiplier = 10,
    @Deprecated('Use values: [value] instead.') this.value,
    @Deprecated('Use defaultValues: [value] instead.') this.defaultValue,
    @Deprecated('Use onValuesChange instead.') this.onChanged,
    this.onChangeStart,
    @Deprecated('Use onValuesCommit instead.') this.onChangeEnd,
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
    this.labelWeight = SeedFieldLabelWeight.medium,
    this.indicator,
    this.showRequiredIndicator = false,
    this.description,
    this.errorMessage,
  }) : _values = values,
       _defaultValues = defaultValues,
       assert(minStepsBetweenThumbs >= 0),
       assert(values == null || (values.length >= 1 && values.length <= 2)),
       assert(
         defaultValues == null ||
             (defaultValues.length >= 1 && defaultValues.length <= 2),
       ),
       assert(values == null || value == null),
       assert(defaultValues == null || defaultValue == null),
       assert(onValuesChange == null || onChanged == null),
       assert(onValuesCommit == null || onChangeEnd == null),
       assert(min < max),
       assert(step == null || step > 0),
       assert(divisions == null || divisions > 0),
       rangeValues = null,
       defaultRangeValues = null,
       onRangeChanged = null,
       onRangeChangeStart = null,
       onRangeChangeEnd = null,
       _rangeMode = false;

  /// Creates a two-thumb range slider using Flutter [RangeValues] inputs.
  ///
  /// [values] and [defaultValues] are range adapters; [onValuesChange] and
  /// [onValuesCommit] use the React-compatible list callbacks.
  /// The [SeedRangeSlider] subclass provides the same range behavior.
  const SeedSlider.range({
    super.key,
    RangeValues? values,
    RangeValues? defaultValues,
    this.onValuesChange,
    this.onValuesCommit,
    @Deprecated('Use onValuesChange instead.')
    ValueChanged<RangeValues>? onChanged,
    ValueChanged<RangeValues>? onChangeStart,
    @Deprecated('Use onValuesCommit instead.')
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
    this.labelWeight = SeedFieldLabelWeight.medium,
    this.indicator,
    this.showRequiredIndicator = false,
    this.description,
    this.errorMessage,
    this.minStepsBetweenThumbs = 0,
    this.jumpMultiplier = 10,
  }) : assert(min < max),
       assert(step == null || step > 0),
       assert(divisions == null || divisions > 0),
       assert(minStepsBetweenThumbs >= 0),
       assert(onValuesChange == null || onChanged == null),
       assert(onValuesCommit == null || onChangeEnd == null),
       _values = null,
       _defaultValues = null,
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
       _rangeMode = true;

  final List<double>? _values, _defaultValues;

  /// Controlled thumb values, as a list of one or two numbers.
  List<double>? get values =>
      _values ??
      (rangeValues == null
          ? null
          : List.unmodifiable([rangeValues!.start, rangeValues!.end]));

  /// Initial uncontrolled thumb values, as a list of one or two numbers.
  List<double>? get defaultValues =>
      _defaultValues ??
      (defaultRangeValues == null
          ? null
          : List.unmodifiable([
              defaultRangeValues!.start,
              defaultRangeValues!.end,
            ]));

  /// Callbacks for proposed thumb positions and final committed positions.
  ///
  /// Both receive a list of one or two values; commit occurs after a gesture.
  final ValueChanged<List<double>>? onValuesChange, onValuesCommit;

  /// Deprecated controlled scalar thumb position; prefer [values].
  @Deprecated('Use values instead.')
  final double? value;

  /// Deprecated uncontrolled scalar seed; prefer [defaultValues].
  @Deprecated('Use defaultValues instead.')
  final double? defaultValue;

  /// Deprecated range input; prefer [values] or [SeedSlider.range].
  @Deprecated('Use values instead.')
  final RangeValues? rangeValues;

  /// Deprecated range seed; prefer [defaultValues].
  @Deprecated('Use defaultValues instead.')
  final RangeValues? defaultRangeValues;

  /// Legacy scalar change callback; prefer [onValuesChange].
  @Deprecated('Use onValuesChange instead.')
  final ValueChanged<double>? onChanged;

  /// Legacy scalar callback invoked at the start of an interaction.
  final ValueChanged<double>? onChangeStart;

  /// Legacy scalar completion callback; prefer [onValuesCommit].
  @Deprecated('Use onValuesCommit instead.')
  final ValueChanged<double>? onChangeEnd;

  /// Deprecated range change callback; prefer [onValuesChange].
  @Deprecated('Use onValuesChange instead.')
  final ValueChanged<RangeValues>? onRangeChanged;

  /// Legacy callback invoked at the start of a range interaction.
  final ValueChanged<RangeValues>? onRangeChangeStart;

  /// Deprecated range completion callback; prefer [onValuesCommit].
  @Deprecated('Use onValuesCommit instead.')
  final ValueChanged<RangeValues>? onRangeChangeEnd;

  /// Minimum and maximum selectable numeric values (defaults 0 and 100).
  final double min, max;

  /// Flutter-compatible uniform division count, when specified.
  final int? divisions;

  /// Legacy value-indicator label for the scalar slider.
  final String? label;

  /// Respectively: brand color treatment, interactions enabled, read-only
  /// state, invalid styling, active-track visibility, and indicator hiding.
  /// Defaults: false, true, false, false, true, false.
  final bool isBrand,
      enabled,
      readOnly,
      invalid,
      showActiveTrack,
      hideValueIndicator;

  /// Numeric step size; if absent, the widget uses a step of one.
  final double? step;

  /// Explicit selectable values; when present they take precedence over [step].
  final List<double>? allowedValues;

  /// Tick positions drawn on the track (default empty).
  final List<double> ticks;

  /// Labeled marker positions drawn along the track (default empty).
  final List<SeedSliderMarker> markers;

  /// Tick visual weight (default [SeedSliderTickWeight.thin]).
  final SeedSliderTickWeight tickWeight;

  /// When value indicators appear (default [SeedValueIndicatorTrigger.auto]).
  final SeedValueIndicatorTrigger valueIndicatorTrigger;

  /// Converts a numeric thumb value to visible display text.
  final String Function(double)? valueFormatter;

  /// Formats an accessible value for the thumb at the given zero-based index.
  final String Function(double, int)? semanticsValueFormatter;

  /// Accessible thumb name, field label, field hint and error text.
  /// All default to null.
  final String? semanticsLabel, fieldLabel, description, errorMessage;

  /// The official `labelWeight`.
  final SeedFieldLabelWeight labelWeight;

  /// The official `indicator`: text after the field label, such as '선택'.
  final String? indicator;

  /// The official `showRequiredIndicator`: the Field required mark after the
  /// label (default false). Visual/semantic only.
  final bool showRequiredIndicator;

  /// Minimum distance between two thumbs expressed in step units (default 0).
  final int minStepsBetweenThumbs;

  /// Steps moved by PageUp, PageDown and Shift+Arrow keys.
  final int jumpMultiplier;
  final bool _rangeMode;
  bool get _range => _rangeMode || (values ?? defaultValues)?.length == 2;
  @override
  State<SeedSlider> createState() => _SeedSliderState();
}

/// Convenience two-thumb [SeedSlider] using range inputs and callbacks.
///
/// Prefer [SeedSlider.range] or the list-valued [SeedSlider] API for new code.
class SeedRangeSlider extends SeedSlider {
  /// Creates a range slider with the same options as [SeedSlider.range].
  const SeedRangeSlider({
    super.key,
    super.values,
    super.defaultValues,
    super.onValuesChange,
    super.onValuesCommit,
    @Deprecated('Use onValuesChange instead.') super.onChanged,
    super.onChangeStart,
    @Deprecated('Use onValuesCommit instead.') super.onChangeEnd,
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
    super.labelWeight,
    super.indicator,
    super.showRequiredIndicator,
    super.description,
    super.errorMessage,
    super.minStepsBetweenThumbs,
    super.jumpMultiplier,
  }) : super.range();
}

class _SeedSliderState extends State<SeedSlider> {
  late double _value = snap(
    widget.defaultValues?.first ??
        widget.defaultValue ??
        (widget.min + widget.max) / 2,
  );
  late RangeValues _range = widget.defaultValues?.length == 2
      ? RangeValues(widget.defaultValues![0], widget.defaultValues![1])
      : widget.defaultRangeValues ?? RangeValues(widget.min, widget.max);
  RangeValues? _lastRange;
  double? _lastValue;
  bool _active = false, _hover = false, _focus = false;
  int _activeThumb = 0;
  double get value => (widget.values?.first ?? widget.value ?? _value).clamp(
    widget.min,
    widget.max,
  );
  bool get _controlled =>
      widget.values != null ||
      widget.value != null ||
      widget.rangeValues != null;
  List<double> get _displayed =>
      widget._range ? [range.start, range.end] : [value];
  List<double>? _gestureStart;
  void _start() => _gestureStart = _displayed;
  void _commit(List<double> next) {
    final start = _gestureStart;
    _gestureStart = null;
    if (start != null &&
        (start.length != next.length ||
            start.asMap().entries.any((e) => e.value != next[e.key]))) {
      widget.onValuesCommit?.call(List.unmodifiable(next));
    }
  }

  RangeValues get range {
    final r = widget.values?.length == 2
        ? RangeValues(widget.values![0], widget.values![1])
        : widget.rangeValues ?? _range;
    return RangeValues(
      r.start.clamp(widget.min, widget.max),
      r.end.clamp(widget.min, widget.max),
    );
  }

  String format(double value) =>
      widget.valueFormatter?.call(value) ??
      (value == value.roundToDouble()
          ? value.toInt().toString()
          : value.toString());
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
    // React's roundValue: keep the step's precision to avoid float artifacts.
    final stepText = step.toString();
    final point = stepText.indexOf('.');
    final decimals = point < 0 || stepText.contains('e')
        ? 0
        : stepText.length - point - 1;
    final snapped = widget.min + ((value - widget.min) / step).round() * step;
    return double.parse(snapped.toStringAsFixed(decimals))
        .clamp(widget.min, widget.max);
  }

  // Material reports keyboard and accessibility steps as a value change.
  // Preserve an untouched range thumb, and translate continuous-slider
  // increments to React's step or next allowed value.
  bool _pointerActive = false;
  double _nextValue(double proposed, double current) {
    if (proposed == current) return current;
    if (_pointerActive) return snap(proposed);
    final allowed = widget.allowedValues
        ?.where((v) => v >= widget.min && v <= widget.max)
        .toSet()
        .toList();
    if (allowed == null || allowed.isEmpty) {
      if (_effectiveDivisions != null) return snap(proposed);
      return snap(current + (proposed > current ? _step : -_step));
    }
    allowed.sort();
    return _nextAllowed(current, proposed > current ? 1 : -1, allowed);
  }

  double _nextAllowed(double current, int direction, List<double> allowed) {
    var index = allowed.indexOf(current);
    final exact = index >= 0;
    if (!exact) {
      var closest = allowed.first;
      for (final candidate in allowed.skip(1)) {
        if ((candidate - current).abs() < (closest - current).abs()) {
          closest = candidate;
        }
      }
      index = allowed.indexOf(closest);
    }
    final nextIndex = index + direction;
    if (nextIndex >= 0 && nextIndex < allowed.length) {
      return allowed[nextIndex];
    }
    return exact ? current : allowed[index];
  }

  // Keep Material's keyboard and accessibility increments in the same units
  // as pointer snapping, rather than its continuous-slider default of 5%.
  int? get _effectiveDivisions {
    if (_sortedAllowed.isNotEmpty) return null;
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
    final next = _nextValue(v, value);
    _lastValue = next;
    if (next == value) return;
    if (!_controlled) setState(() => _value = next);
    widget.onValuesChange?.call(List.unmodifiable([next]));
    widget.onChanged?.call(next);
  }

  void changeRange(RangeValues v) {
    if (widget.readOnly) return;
    var start = _nextValue(v.start, range.start),
        end = _nextValue(v.end, range.end);
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
    }
    // React's updateValues skips minStepsBetweenThumbs with allowedValues.
    final next = RangeValues(math.min(start, end), math.max(start, end));
    _lastRange = next;
    if (next == range) return;
    _activeThumb = next.start != range.start ? 0 : 1;
    if (!_controlled) setState(() => _range = next);
    widget.onValuesChange?.call(List.unmodifiable([next.start, next.end]));
    widget.onRangeChanged?.call(next);
  }

  double get _step =>
      widget.step ??
      (widget.divisions != null && widget.divisions! > 0
          ? (widget.max - widget.min) / widget.divisions!
          : 1.0);

  List<double> get _sortedAllowed =>
      (widget.allowedValues ?? const <double>[])
          .where((v) => v >= widget.min && v <= widget.max)
          .toSet()
          .toList()
        ..sort();

  double _jump(double current, int direction) {
    final allowed = _sortedAllowed;
    if (allowed.isEmpty) {
      return snap(current + _step * widget.jumpMultiplier * direction);
    }
    var next = current;
    for (var i = 0; i < widget.jumpMultiplier; i++) {
      next = _nextAllowed(next, direction, allowed);
    }
    return next;
  }

  void _moveThumb(double Function(double current) target, {int? thumb}) {
    _start();
    if (widget._range) {
      final index = thumb ?? _activeThumb;
      final current = range;
      final next = target(index == 0 ? current.start : current.end);
      final updated = index == 0
          ? RangeValues(next, current.end)
          : RangeValues(current.start, next);
      // React checks the thumb gap only without allowedValues.
      final gap = _sortedAllowed.isEmpty
          ? widget.minStepsBetweenThumbs * _step
          : 0.0;
      if (updated.start > updated.end || updated.end - updated.start < gap) {
        _gestureStart = null;
        return;
      }
      _activeThumb = index;
      if (updated != current) {
        if (!_controlled) setState(() => _range = updated);
        widget.onValuesChange?.call(
          List.unmodifiable([updated.start, updated.end]),
        );
        widget.onRangeChanged?.call(updated);
      }
      _commit([updated.start, updated.end]);
      widget.onRangeChangeEnd?.call(updated);
      return;
    }
    final next = target(value);
    if (next != value) {
      if (!_controlled) setState(() => _value = next);
      widget.onValuesChange?.call(List.unmodifiable([next]));
      widget.onChanged?.call(next);
    }
    _commit([next]);
    widget.onChangeEnd?.call(next);
  }

  // Material handles plain arrows. The rest of React's slider keys reach here.
  KeyEventResult _handleKey(KeyEvent event, bool rtl) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (!widget.enabled || widget.readOnly) return KeyEventResult.ignored;
    final key = event.logicalKey;
    final allowed = _sortedAllowed;
    final count = widget._range ? 2 : 1;
    if (key == LogicalKeyboardKey.home) {
      _moveThumb((_) => allowed.isEmpty ? widget.min : allowed.first, thumb: 0);
    } else if (key == LogicalKeyboardKey.end) {
      _moveThumb(
        (_) => allowed.isEmpty ? widget.max : allowed.last,
        thumb: count - 1,
      );
    } else if (key == LogicalKeyboardKey.pageUp) {
      _moveThumb((current) => _jump(current, 1));
    } else if (key == LogicalKeyboardKey.pageDown) {
      _moveThumb((current) => _jump(current, -1));
    } else if (HardwareKeyboard.instance.isShiftPressed &&
        (key == LogicalKeyboardKey.arrowUp ||
            key == LogicalKeyboardKey.arrowDown ||
            key == LogicalKeyboardKey.arrowLeft ||
            key == LogicalKeyboardKey.arrowRight)) {
      final forward =
          key == LogicalKeyboardKey.arrowUp ||
          key ==
              (rtl
                  ? LogicalKeyboardKey.arrowLeft
                  : LogicalKeyboardKey.arrowRight);
      _moveThumb((current) => _jump(current, forward ? 1 : -1));
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
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
    // React shows one indicator: the keyboard-focused or dragged thumb, or the
    // hovered thumb unless the trigger is limited to active.
    final showIndicator =
        widget.enabled &&
        !widget.hideValueIndicator &&
        ((_focus &&
                FocusManager.instance.highlightMode ==
                    FocusHighlightMode.traditional) ||
            _active ||
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

        double thumbCenter(double value) =>
            _thumbInset + fraction(value) * (width - _thumbInset * 2);

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
                        _start();
                        setState(() => _active = true);
                        widget.onRangeChangeStart?.call(v);
                      }
                    : null,
                onChangeEnd: widget.enabled && !widget.readOnly
                    ? (v) {
                        setState(() => _active = false);
                        final next = _lastRange ?? range;
                        _commit([next.start, next.end]);
                        _lastRange = null;
                        widget.onRangeChangeEnd?.call(next);
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
                        _start();
                        setState(() => _active = true);
                        widget.onChangeStart?.call(snap(v));
                      }
                    : null,
                onChangeEnd: widget.enabled && !widget.readOnly
                    ? (v) {
                        setState(() => _active = false);
                        final next = _lastValue ?? snap(v);
                        _lastValue = null;
                        _commit([next]);
                        widget.onChangeEnd?.call(next);
                      }
                    : null,
              );
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MouseRegion(
              onHover: (event) {
                final hovered = values.indexWhere(
                  (v) =>
                      (event.localPosition.dx - thumbCenter(v)).abs() <=
                      _thumbInset,
                );
                final overThumb = hovered >= 0;
                if (overThumb != _hover ||
                    (overThumb && hovered != _activeThumb)) {
                  setState(() {
                    _hover = overThumb;
                    if (overThumb) _activeThumb = hovered;
                  });
                }
              },
              onExit: (_) {
                if (_hover) setState(() => _hover = false);
              },
              child: Focus(
                canRequestFocus: false,
                onFocusChange: (v) => setState(() => _focus = v),
                onKeyEvent: (_, event) => _handleKey(event, rtl),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Listener(
                      onPointerDown: (_) => _pointerActive = true,
                      // Gesture callbacks run after raw pointer dispatch, so a
                      // quick tap must still count as a pointer interaction.
                      onPointerUp: (_) =>
                          scheduleMicrotask(() => _pointerActive = false),
                      onPointerCancel: (_) =>
                          scheduleMicrotask(() => _pointerActive = false),
                      child: SizedBox(height: _controlHeight, child: slider),
                    ),
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
                    for (var i = 0; i < values.length; i++)
                      _SeedSliderValueIndicator(
                        label: widget.label ?? format(values[i]),
                        thumbCenter: thumbCenter(values[i]),
                        trackWidth: width,
                        shown:
                            showIndicator &&
                            (values.length == 1 || i == _activeThumb),
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
                          // React pins the end markers to the track's edges.
                          left: marker.value <= widget.min
                              ? (rtl ? width : 0)
                              : marker.value >= widget.max
                              ? (rtl ? 0 : width)
                              : thumbCenter(marker.value),
                          top: 0,
                          bottom: 0,
                          child: FractionalTranslation(
                            translation: Offset(switch (marker.resolveAlign(
                              widget.min,
                              widget.max,
                            )) {
                              SeedSliderMarkerAlign.start => rtl ? -1 : 0,
                              SeedSliderMarkerAlign.center => -0.5,
                              SeedSliderMarkerAlign.end => rtl ? 0 : -1,
                            }, 0),
                            child: Center(
                              child: Text(
                                marker.label,
                                textAlign: switch (marker.resolveAlign(
                                  widget.min,
                                  widget.max,
                                )) {
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
    final name = widget.semanticsLabel ?? widget.fieldLabel;
    control = Semantics(
      label: name,
      readOnly: widget.readOnly,
      validationResult: widget.invalid || widget.errorMessage != null
          ? SemanticsValidationResult.invalid
          : SemanticsValidationResult.none,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: _active ? 1.2 : 1.0),
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : SeedDuration.d3,
        curve: SeedCurves.easing,
        builder: (context, thumbScale, child) => SliderTheme(
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
            overlayShape: SliderComponentShape.noOverlay,
            trackShape: const _SeedSliderTrackShape(),
            rangeTrackShape: const _SeedRangeSliderTrackShape(),
            thumbShape: _SeedSliderThumbShape(thumbScale),
            rangeThumbShape: _SeedRangeSliderThumbShape(thumbScale),
            tickMarkShape: widget.divisions == null
                ? SliderTickMarkShape.noTickMark
                : const RoundSliderTickMarkShape(tickMarkRadius: 2),
            // RangeSlider reads its own tick shape. Without this, a stepped
            // range (e.g. step: 50000) shows Material's default step dots,
            // which the official slider never draws.
            rangeTickMarkShape: widget.divisions == null
                ? const _SeedNoRangeTickMarkShape()
                : const RoundRangeSliderTickMarkShape(tickMarkRadius: 2),
            activeTickMarkColor: colors.fg.onNeutralSolid,
            inactiveTickMarkColor: colors.fg.onNeutralSolid,
            showValueIndicator: ShowValueIndicator.never,
          ),
          child: child!,
        ),
        child: control,
      ),
    );
    // A single thumb is one role="slider" named by its label, like the
    // official <input type="range" aria-labelledby>.
    if (!widget._range && name != null) {
      control = MergeSemantics(child: control);
    }
    return widget.fieldLabel != null ||
            widget.indicator != null ||
            widget.description != null ||
            widget.errorMessage != null
        ? SeedField(
            label: widget.fieldLabel,
            labelWeight: widget.labelWeight,
            indicatorText: widget.indicator,
            required: widget.showRequiredIndicator,
            helperText: widget.description,
            errorMessage: widget.errorMessage,
            isInvalid: widget.invalid,
            child: control,
          )
        : control;
  }
}

/// Half of the official 20px thumb, which stays inside the full-width track.
const double _thumbInset = 10;
const double _controlHeight = 26;

Rect _sliderThumbTravel(RenderBox parentBox, Offset offset, double height) =>
    Rect.fromLTWH(
      offset.dx + _thumbInset,
      offset.dy + (parentBox.size.height - height) / 2,
      math.max(0, parentBox.size.width - _thumbInset * 2),
      height,
    );

void _paintSliderTrack(
  PaintingContext context,
  Rect travel,
  SliderThemeData theme,
  Animation<double> enableAnimation,
  double activeStart,
  double activeEnd,
) {
  final inactive = ColorTween(
    begin: theme.disabledInactiveTrackColor,
    end: theme.inactiveTrackColor,
  ).evaluate(enableAnimation)!;
  final active = ColorTween(
    begin: theme.disabledActiveTrackColor,
    end: theme.activeTrackColor,
  ).evaluate(enableAnimation)!;
  final radius = Radius.circular(travel.height / 2);
  final track = Rect.fromLTRB(
    travel.left - _thumbInset,
    travel.top,
    travel.right + _thumbInset,
    travel.bottom,
  );
  context.canvas.drawRRect(
    RRect.fromRectAndRadius(track, radius),
    Paint()..color = inactive,
  );
  context.canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTRB(activeStart, track.top, activeEnd, track.bottom),
      radius,
    ),
    Paint()..color = active,
  );
}

class _SeedSliderTrackShape extends SliderTrackShape {
  const _SeedSliderTrackShape();

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) => _sliderThumbTravel(parentBox, offset, sliderTheme.trackHeight!);

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isEnabled = false,
    bool isDiscrete = false,
    required TextDirection textDirection,
  }) {
    final travel = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
    );
    final ltr = textDirection == TextDirection.ltr;
    _paintSliderTrack(
      context,
      travel,
      sliderTheme,
      enableAnimation,
      ltr ? travel.left - _thumbInset : thumbCenter.dx,
      ltr ? thumbCenter.dx : travel.right + _thumbInset,
    );
  }
}

class _SeedRangeSliderTrackShape extends RangeSliderTrackShape {
  const _SeedRangeSliderTrackShape();

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) => _sliderThumbTravel(parentBox, offset, sliderTheme.trackHeight!);

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset startThumbCenter,
    required Offset endThumbCenter,
    bool isEnabled = false,
    bool isDiscrete = false,
    required TextDirection textDirection,
  }) {
    _paintSliderTrack(
      context,
      getPreferredRect(
        parentBox: parentBox,
        offset: offset,
        sliderTheme: sliderTheme,
      ),
      sliderTheme,
      enableAnimation,
      math.min(startThumbCenter.dx, endThumbCenter.dx),
      math.max(startThumbCenter.dx, endThumbCenter.dx),
    );
  }
}

class _SeedSliderThumbShape extends SliderComponentShape {
  const _SeedSliderThumbShape(this.scale);
  final double scale;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size.square(_thumbInset * 2);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    context.canvas.drawCircle(
      center,
      _thumbInset * scale,
      Paint()
        ..color = ColorTween(
          begin: sliderTheme.disabledThumbColor,
          end: sliderTheme.thumbColor,
        ).evaluate(enableAnimation)!,
    );
  }
}

class _SeedRangeSliderThumbShape extends RangeSliderThumbShape {
  const _SeedRangeSliderThumbShape(this.scale);
  final double scale;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size.square(_thumbInset * 2);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = false,
    bool isOnTop = false,
    TextDirection textDirection = TextDirection.ltr,
    required SliderThemeData sliderTheme,
    Thumb thumb = Thumb.start,
    bool isPressed = false,
  }) {
    context.canvas.drawCircle(
      center,
      _thumbInset * (isPressed ? scale : 1),
      Paint()
        ..color = ColorTween(
          begin: sliderTheme.disabledThumbColor,
          end: sliderTheme.thumbColor,
        ).evaluate(enableAnimation)!,
    );
  }
}

/// The official value bubble: it enters at 0.9 scale, exits by fading in place,
/// stays within the track, and points its arrow at the thumb.
class _SeedSliderValueIndicator extends StatefulWidget {
  const _SeedSliderValueIndicator({
    required this.label,
    required this.thumbCenter,
    required this.trackWidth,
    required this.shown,
  });
  final String label;
  final double thumbCenter, trackWidth;
  final bool shown;

  @override
  State<_SeedSliderValueIndicator> createState() =>
      _SeedSliderValueIndicatorState();
}

class _SeedSliderValueIndicatorState extends State<_SeedSliderValueIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: SeedDuration.d4,
    value: widget.shown ? 1 : 0,
  );

  @override
  void didUpdateWidget(_SeedSliderValueIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shown == oldWidget.shown) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = widget.shown ? 1 : 0;
    } else if (widget.shown) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final style = context.seedTypography.t3Medium.copyWith(
      color: colors.fg.onNeutralSolid,
    );
    final painter = TextPainter(
      text: TextSpan(text: widget.label, style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final labelWidth = math.max(24.0, painter.width + 16);
    painter.dispose();
    final left = (widget.thumbCenter - labelWidth / 2)
        .clamp(0.0, math.max(0.0, widget.trackWidth - labelWidth))
        .toDouble();
    return Positioned(
      left: left,
      // Bottom edge at the thumb's half height plus the official 12px offset.
      top: _controlHeight / 2 - _thumbInset - 12 - 26,
      child: ExcludeSemantics(
        child: IgnorePointer(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              if (_controller.value == 0) return const SizedBox.shrink();
              final entering = _controller.status != AnimationStatus.reverse;
              return Opacity(
                opacity: _controller.value,
                child: Transform.scale(
                  scale: entering
                      ? 0.9 +
                            0.1 * SeedCurves.enter.transform(_controller.value)
                      : 1,
                  child: child,
                ),
              );
            },
            child: SizedBox(
              width: labelWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.bg.neutralSolid,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: SizedBox(
                        width: labelWidth - 16,
                        child: Text(
                          widget.label,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          softWrap: false,
                          style: style,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.only(
                      start: math.max(0, widget.thumbCenter - left - 4),
                    ),
                    child: CustomPaint(
                      size: const Size(8, 6),
                      painter: _SeedSliderIndicatorArrow(
                        colors.bg.neutralSolid,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
      final x = _thumbInset + f * (size.width - _thumbInset * 2);
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

class _SeedNoRangeTickMarkShape extends RangeSliderTickMarkShape {
  const _SeedNoRangeTickMarkShape();

  @override
  Size getPreferredSize({
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
  }) => Size.zero;

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset startThumbCenter,
    required Offset endThumbCenter,
    bool isEnabled = false,
    required TextDirection textDirection,
  }) {}
}
