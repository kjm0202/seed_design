import 'package:intl/intl.dart' show DateFormat, Intl, NumberFormat;
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';

import '../../foundations/dimensions/seed_dimension.dart';
import '../../localization/seed_picker_locale.dart';
import '../../theme/seed_theme.dart';
import 'seed_wheel_picker.dart';

/// Period for 12-hour format: [am] (오전) or [pm] (오후).
enum SeedTimePeriod {
  /// Ante meridiem (오전), for hours before noon.
  am('오전'),

  /// Post meridiem (오후), for noon and later.
  pm('오후');

  /// Creates a period with its Korean display [label].
  const SeedTimePeriod(this.label);

  /// Korean short label of the day period.
  final String label;
}

/// A SEED Design Time Picker component.
///
/// Implements the 3-column wheel:
/// - Period Column (오전 / 오후)
/// - Hour Column (1 ~ 12)
/// - Minute Column (00 ~ 59 with optional [minuteStep])
///
/// Hour labels are end-aligned as in React 3.4.0, so one-digit hours line up
/// with "10".."12" on their trailing edge (the leading edge in RTL); the
/// period and minute labels remain centered.
///
/// Like React's TimePicker, the default time is 00:00 and [minuteStep] is five.
/// Flutter represents the value with [TimeOfDay] and follows the app locale
/// when [locale] is omitted.
class SeedTimePicker extends StatefulWidget {
  /// Creates a three-column [SeedWheelPicker]-based time selector.
  ///
  /// [value] controls the current time. [defaultValue] initializes local
  /// selection once and defaults to midnight; [initialTime] is deprecated.
  /// [onValueChange] reports a selected [TimeOfDay] after the wheel settles,
  /// while [onChanged] is a compatibility alias. Valid [minuteStep] values are
  /// 1, 5, 10, 15, and 30. The four semantics labels identify the full picker
  /// and its period, hour, and minute wheels, respectively.
  const SeedTimePicker({
    super.key,
    TimeOfDay? defaultValue,
    @Deprecated('Use defaultValue instead.') TimeOfDay? initialTime,
    this.minuteStep = 5,
    ValueChanged<TimeOfDay>? onValueChange,
    @Deprecated('Use onValueChange instead.')
    ValueChanged<TimeOfDay>? onChanged,
    this.height = 220.0,
    this.value,
    this.enabled = true,
    this.readOnly = false,
    this.locale,
    this.semanticsLabel,
    this.periodSemanticsLabel,
    this.hourSemanticsLabel,
    this.minuteSemanticsLabel,
  }) : onChanged = onValueChange ?? onChanged,
       assert(onValueChange == null || onChanged == null),
       initialTime =
           defaultValue ?? initialTime ?? const TimeOfDay(hour: 0, minute: 0),
       assert(defaultValue == null || initialTime == null);

  /// The initially selected time.
  @Deprecated('Use defaultValue instead.')
  final TimeOfDay initialTime;

  /// One-time uncontrolled seed; [initialTime] is a compatibility alias.
  TimeOfDay get defaultValue => initialTime;

  /// Interval between selectable minutes: 1, 5, 10, 15, or 30 (default 5).
  ///
  /// Unaligned initial minutes are snapped to the nearest available step.
  final int minuteStep;

  /// Deprecated callback for the selected time; use [onValueChange].
  @Deprecated('Use onValueChange instead.')
  final ValueChanged<TimeOfDay>? onChanged;

  /// Reports the selected 24-hour time when a wheel selection changes.
  ValueChanged<TimeOfDay>? get onValueChange => onChanged;

  /// Overall height of the picker.
  final double height;

  /// Controlled 24-hour time; null uses [defaultValue] as the local seed.
  final TimeOfDay? value;

  /// Whether interaction is enabled (default true), and whether the user may
  /// view but not change the time (default false).
  final bool enabled, readOnly;

  /// Locale for numerals, period labels, and column order. Null follows the
  /// app locale, with English (`en_US`) as the fallback when locale data is
  /// unavailable.
  final Locale? locale;

  /// Optional accessible name of the entire picker.
  final String? semanticsLabel;

  /// Accessible name of the AM/PM wheel.
  final String? periodSemanticsLabel;

  /// Accessible name of the hour wheel.
  final String? hourSemanticsLabel;

  /// Accessible name of the minute wheel.
  final String? minuteSemanticsLabel;

  @override
  State<SeedTimePicker> createState() => _SeedTimePickerState();
}

class _SeedTimePickerState extends State<SeedTimePicker> {
  late SeedTimePeriod _period;
  late int _hour; // 1 ~ 12
  late int _minute; // 0 ~ 59

  late List<int> _minutes;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    _initValues();
  }

  @override
  void didUpdateWidget(SeedTimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.minuteStep != widget.minuteStep ||
        (widget.value != null && oldWidget.value != widget.value)) {
      _initValues(widget.value ?? _currentTime);
    }
  }

  void _initValues([TimeOfDay? seed]) {
    if (!const {1, 5, 10, 15, 30}.contains(widget.minuteStep)) {
      throw ArgumentError.value(
        widget.minuteStep,
        'minuteStep',
        'Must be one of 1, 5, 10, 15, 30',
      );
    }
    _minutes = [];
    for (int i = 0; i < 60; i += widget.minuteStep) {
      _minutes.add(i);
    }

    final source = seed ?? widget.value ?? widget.defaultValue;
    // React's normalizeValueToMinuteStep: ties round up, across the hour and day.
    final totalMinutes = source.hour * 60 + source.minute;
    final rounded =
        (totalMinutes / widget.minuteStep).round() *
        widget.minuteStep %
        (24 * 60);
    final h = rounded ~/ 60;
    _period = h >= 12 ? SeedTimePeriod.pm : SeedTimePeriod.am;
    _hour = h % 12 == 0 ? 12 : h % 12;
    _minute = rounded % 60;
  }

  TimeOfDay get _currentTime {
    int hour24;
    if (_period == SeedTimePeriod.am) {
      hour24 = _hour == 12 ? 0 : _hour;
    } else {
      hour24 = _hour == 12 ? 12 : _hour + 12;
    }
    return TimeOfDay(hour: hour24, minute: _minute);
  }

  void _notifyChange() {
    widget.onChanged?.call(_currentTime);
  }

  bool _periodFollowsMinute(String locale) {
    try {
      final pattern = DateFormat.jm(locale).pattern ?? '';
      final aIndex = pattern.indexOf('a');
      final mIndex = pattern.indexOf('m');
      if (aIndex < 0 || mIndex < 0) {
        final language = Intl.shortLocale(locale);
        return language != 'ko' && language != 'ja' && language != 'zh';
      }
      return aIndex >= 0 && mIndex >= 0 && aIndex > mIndex;
    } catch (_) {
      final language = Intl.shortLocale(locale);
      return language != 'ko' && language != 'ja';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.value != null) _initValues();
    final locale = resolveSeedPickerLocale(context, widget.locale);
    final lang = Intl.shortLocale(locale);
    final korean = lang == 'ko';
    final japanese = lang == 'ja';
    final colors = context.seedColor;
    final typography = context.seedTypography;

    final periodIndex = _period == SeedTimePeriod.am ? 0 : 1;
    final hourIndex = _hour % 12; // 12, 1, …, 11
    final minuteIndex = _minutes.indexOf(_minute).clamp(0, _minutes.length - 1);

    final defaultRootLabel = korean
        ? '시간 선택'
        : japanese
        ? '時刻を選択'
        : 'Select time';
    final defaultPeriodLabel = korean
        ? '오전/오후'
        : japanese
        ? '午前/午後'
        : 'AM/PM';
    final defaultHourLabel = korean
        ? '시'
        : japanese
        ? '時'
        : 'Hour';
    final defaultMinuteLabel = korean
        ? '분'
        : japanese
        ? '分'
        : 'Minute';

    TextStyle itemStyle(bool isSelected) => typography.t10Medium.copyWith(
      color: isSelected ? colors.fg.neutral : colors.fg.disabled,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    // React's time-picker columns are `flex: 0 0 auto` / `width: max-content`,
    // while the root and selection indicator still fill 100% of the parent.
    // Measure the widest localized value instead of distributing three equal
    // fractions of the available width (which separates labels on desktop).
    double intrinsicColumnWidth(
      Iterable<String> labels, {
      required double minimumGlyphWidthRatio,
    }) {
      var widest = 0.0;
      for (final label in labels) {
        final painter = TextPainter(
          text: TextSpan(text: label, style: itemStyle(true)),
          textDirection: Directionality.of(context),
          textScaler: TextScaler.noScaling,
          maxLines: 1,
        )..layout();
        if (painter.width > widest) widest = painter.width;
        // On Flutter Web a downloadable font may not be ready during the
        // first build. Its initial fallback glyph advances are often narrower
        // than the final font, leaving a one-character wheel label wrapped.
        // A script-aware floor preserves the CSS max-content intent until the
        // actual font finishes loading, without expanding all three columns.
        final textFloor =
            label.runes.length *
            (itemStyle(true).fontSize ?? 26.0) *
            minimumGlyphWidthRatio;
        if (textFloor > widest) widest = textFloor;
      }
      return widest + SeedDimension.x4 * 2;
    }

    final periodFormatter = DateFormat('a', locale);
    final hourFormatter = NumberFormat('0', locale);
    final minuteFormatter = NumberFormat('00', locale);

    final periodColumn = SeedWheelColumn.typed<SeedTimePeriod>(
      items: SeedTimePeriod.values,
      semanticsLabel: widget.periodSemanticsLabel ?? defaultPeriodLabel,
      semanticsValueFormatter: (item) => DateFormat(
        'a',
        locale,
      ).format(DateTime(2020, 1, 1, item == SeedTimePeriod.am ? 0 : 12)),
      initialIndex: periodIndex,
      index: widget.value == null ? null : periodIndex,
      width: intrinsicColumnWidth([
        for (final period in SeedTimePeriod.values)
          periodFormatter.format(
            DateTime(2020, 1, 1, period == SeedTimePeriod.am ? 0 : 12),
          ),
      ], minimumGlyphWidthRatio: korean || japanese ? 1.0 : 0.65),
      onChanged: (idx) {
        setState(() {
          _period = SeedTimePeriod.values[idx];
        });
        _notifyChange();
      },
      itemBuilder: (context, item, isSelected) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: SeedDimension.x4),
          child: Text(
            DateFormat(
              'a',
              locale,
            ).format(DateTime(2020, 1, 1, item == SeedTimePeriod.am ? 0 : 12)),
            textScaler: TextScaler.noScaling,
            maxLines: 1,
            softWrap: false,
            style: itemStyle(isSelected),
          ),
        );
      },
    );

    final hourColumn = SeedWheelColumn.typed<int>(
      items: List.generate(12, (i) => i == 0 ? 12 : i),
      semanticsLabel: widget.hourSemanticsLabel ?? defaultHourLabel,
      initialIndex: hourIndex,
      index: widget.value == null ? null : hourIndex,
      looping: true,
      width: intrinsicColumnWidth([
        for (var hour = 1; hour <= 12; hour++) hourFormatter.format(hour),
      ], minimumGlyphWidthRatio: 0.65),
      // React 3.4.0 sets the hour column's item justify-content to flex-end,
      // so one-digit hours share a trailing edge with "10".."12". centerEnd
      // is the inline end, flipping to the left in RTL like the CSS recipe.
      alignment: AlignmentDirectional.centerEnd,
      onStepChanged: (idx, stepDelta) {
        final prevHourIdx = _hour % 12;
        final newScrollIndex = prevHourIdx + stepDelta;
        final cycleDelta = (newScrollIndex / 12).floor();
        setState(() {
          if (cycleDelta.isOdd) {
            _period = _period == SeedTimePeriod.am
                ? SeedTimePeriod.pm
                : SeedTimePeriod.am;
          }
          _hour = idx == 0 ? 12 : idx;
        });
        _notifyChange();
      },
      itemBuilder: (context, item, isSelected) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: SeedDimension.x4),
          child: Text(
            NumberFormat('0', locale).format(item),
            textScaler: TextScaler.noScaling,
            maxLines: 1,
            softWrap: false,
            style: itemStyle(isSelected),
          ),
        );
      },
    );

    final minuteColumn = SeedWheelColumn.typed<int>(
      items: _minutes,
      semanticsLabel: widget.minuteSemanticsLabel ?? defaultMinuteLabel,
      initialIndex: minuteIndex,
      index: widget.value == null ? null : minuteIndex,
      looping: _minutes.length > 1,
      width: intrinsicColumnWidth([
        for (final minute in _minutes) minuteFormatter.format(minute),
      ], minimumGlyphWidthRatio: 0.65),
      onChanged: (idx) {
        setState(() {
          _minute = _minutes[idx];
        });
        _notifyChange();
      },
      itemBuilder: (context, item, isSelected) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: SeedDimension.x4),
          child: Text(
            NumberFormat('00', locale).format(item),
            textScaler: TextScaler.noScaling,
            maxLines: 1,
            softWrap: false,
            style: itemStyle(isSelected),
          ),
        );
      },
    );

    final periodFollowsMinute = _periodFollowsMinute(locale);
    final orderedColumns = periodFollowsMinute
        ? [hourColumn, minuteColumn, periodColumn]
        : [periodColumn, hourColumn, minuteColumn];

    return SeedWheelPicker(
      key: ValueKey(periodFollowsMinute),
      height: widget.height,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      semanticsLabel: widget.semanticsLabel ?? defaultRootLabel,
      columns: orderedColumns,
    );
  }
}
