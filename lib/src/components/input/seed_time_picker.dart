import 'package:material_ui/material_ui.dart';
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
    this.initialTime = const TimeOfDay(hour: 9, minute: 0),
    this.minuteStep = 1,
    this.onChanged,
    this.height = 220.0,
  });

  /// The initially selected time.
  final TimeOfDay initialTime;

  /// Interval between selectable minute values (e.g. 1, 5, 10, 15).
  final int minuteStep;

  /// Callback when the selected time changes.
  final ValueChanged<TimeOfDay>? onChanged;

  /// Overall height of the picker.
  final double height;

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
    _initValues();
  }

  void _initValues() {
    final h = widget.initialTime.hour;
    _period = h >= 12 ? SeedTimePeriod.pm : SeedTimePeriod.am;
    _hour = h % 12 == 0 ? 12 : h % 12;

    if (widget.minuteStep <= 0 || widget.minuteStep > 60) {
      throw ArgumentError.value(widget.minuteStep, 'minuteStep', 'Must be between 1 and 60');
    }
    _minutes = [];
    for (int i = 0; i < 60; i += widget.minuteStep) {
      _minutes.add(i);
    }

    final initialMin = widget.initialTime.minute;
    int closestMin = _minutes.first;
    int minDiff = 1000;
    for (final m in _minutes) {
      final diff = (m - initialMin).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closestMin = m;
      }
    }
    _minute = closestMin;
  }

  void _notifyChange() {
    int hour24;
    if (_period == SeedTimePeriod.am) {
      hour24 = _hour == 12 ? 0 : _hour;
    } else {
      hour24 = _hour == 12 ? 12 : _hour + 12;
    }
    widget.onChanged?.call(TimeOfDay(hour: hour24, minute: _minute));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;

    final periodIndex = _period == SeedTimePeriod.am ? 0 : 1;
    final hourIndex = _hour - 1; // 1..12 -> 0..11
    final minuteIndex = _minutes.indexOf(_minute).clamp(0, _minutes.length - 1);

    return SeedWheelPicker(
      height: widget.height,
      columns: [
        // Period column: 오전 / 오후
        SeedWheelColumn.typed<SeedTimePeriod>(
          items: SeedTimePeriod.values,
          initialIndex: periodIndex,
          flex: 2,
          onChanged: (idx) {
            setState(() {
              _period = SeedTimePeriod.values[idx];
            });
            _notifyChange();
          },
          itemBuilder: (context, item, isSelected) {
            return Text(
              item.label,
              style: isSelected
                  ? typography.t6Bold.copyWith(color: colors.fg.neutral)
                  : typography.t5Regular.copyWith(color: colors.fg.neutralSubtle),
            );
          },
        ),

        // Hour column: 1..12
        SeedWheelColumn.typed<int>(
          items: List.generate(12, (i) => i + 1),
          initialIndex: hourIndex,
          flex: 2,
          onChanged: (idx) {
            setState(() {
              _hour = idx + 1;
            });
            _notifyChange();
          },
          itemBuilder: (context, item, isSelected) {
            return Text(
              item.toString(),
              style: isSelected
                  ? typography.t6Bold.copyWith(color: colors.fg.neutral)
                  : typography.t5Regular.copyWith(color: colors.fg.neutralSubtle),
            );
          },
        ),

        // Minute column: 00..59
        SeedWheelColumn.typed<int>(
          items: _minutes,
          initialIndex: minuteIndex,
          flex: 2,
          onChanged: (idx) {
            setState(() {
              _minute = _minutes[idx];
            });
            _notifyChange();
          },
          itemBuilder: (context, item, isSelected) {
            return Text(
              item.toString().padLeft(2, '0'),
              style: isSelected
                  ? typography.t6Bold.copyWith(color: colors.fg.neutral)
                  : typography.t5Regular.copyWith(color: colors.fg.neutralSubtle),
            );
          },
        ),
      ],
    );
  }
}
