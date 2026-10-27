import 'package:intl/intl.dart' show DateFormat, NumberFormat;
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';

import '../../foundations/dimensions/seed_dimension.dart';
import '../../theme/seed_theme.dart';
import 'seed_wheel_picker.dart';

/// Period for 12-hour format: [am] (오전) or [pm] (오후).
enum SeedTimePeriod {
  am('오전'),
  pm('오후');

  const SeedTimePeriod(this.label);
  final String label;
}

/// A SEED Design Time Picker component.
///
/// Implements the 3-column wheel:
/// - Period Column (오전 / 오후)
/// - Hour Column (1 ~ 12)
/// - Minute Column (00 ~ 59 with optional [minuteStep])
class SeedTimePicker extends StatefulWidget {
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
    this.locale = const Locale('ko', 'KR'),
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

  /// Interval between selectable minute values (e.g. 1, 5, 10, 15).
  final int minuteStep;

  /// Callback when the selected time changes.
  @Deprecated('Use onValueChange instead.')
  final ValueChanged<TimeOfDay>? onChanged;
  ValueChanged<TimeOfDay>? get onValueChange => onChanged;

  /// Overall height of the picker.
  final double height;
  final TimeOfDay? value;
  final bool enabled, readOnly;
  final Locale locale;
  final String? semanticsLabel;
  final String? periodSemanticsLabel;
  final String? hourSemanticsLabel;
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
    initializeDateFormatting(widget.locale.toString());
    _initValues();
  }

  @override
  void didUpdateWidget(SeedTimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.locale != widget.locale) {
      initializeDateFormatting(widget.locale.toString());
    }
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
    var h = source.hour;
    final initialMin = source.minute;
    int closestMin = _minutes.first;
    int minDiff = 1000;
    for (final m in _minutes) {
      final diff = (m - initialMin).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closestMin = m;
      }
    }
    if (60 - initialMin < minDiff) {
      closestMin = 0;
      h = (h + 1) % 24;
    }
    _period = h >= 12 ? SeedTimePeriod.pm : SeedTimePeriod.am;
    _hour = h % 12 == 0 ? 12 : h % 12;
    _minute = closestMin;
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
      return aIndex >= 0 && mIndex >= 0 && aIndex > mIndex;
    } catch (_) {
      return widget.locale.languageCode != 'ko' &&
          widget.locale.languageCode != 'ja';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.value != null) _initValues();
    final lang = widget.locale.languageCode;
    final korean = lang == 'ko';
    final japanese = lang == 'ja';
    final locale = widget.locale.toString();
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

    final periodColumn = SeedWheelColumn.typed<SeedTimePeriod>(
      items: SeedTimePeriod.values,
      semanticsLabel: widget.periodSemanticsLabel ?? defaultPeriodLabel,
      semanticsValueFormatter: (item) => DateFormat(
        'a',
        locale,
      ).format(DateTime(2020, 1, 1, item == SeedTimePeriod.am ? 0 : 12)),
      initialIndex: periodIndex,
      index: widget.value == null ? null : periodIndex,
      flex: 2,
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
      flex: 2,
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
      flex: 2,
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
            style: itemStyle(isSelected),
          ),
        );
      },
    );

    final orderedColumns = _periodFollowsMinute(locale)
        ? [hourColumn, minuteColumn, periodColumn]
        : [periodColumn, hourColumn, minuteColumn];

    return SeedWheelPicker(
      height: widget.height,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      semanticsLabel: widget.semanticsLabel ?? defaultRootLabel,
      columns: orderedColumns,
    );
  }
}
