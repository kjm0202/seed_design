import 'package:material_ui/material_ui.dart';

DateTime seedDateOnly(DateTime date) =>
    DateTime(date.year, date.month, date.day);
int seedCalendarDayCount(DateTime start, DateTime end) =>
    DateTime.utc(
      end.year,
      end.month,
      end.day,
    ).difference(DateTime.utc(start.year, start.month, start.day)).inDays +
    1;

class SeedDateRange {
  const SeedDateRange({required this.start, this.end});
  final DateTime start;
  final DateTime? end;
}

/// Proposed selection passed to date constraints before the change is accepted.
class SeedDateSelection {
  const SeedDateSelection({
    this.date,
    this.start,
    this.end,
    this.dates = const [],
  });
  final DateTime? date, start, end;
  final List<DateTime> dates;
}

enum SeedExcludeDatesScope { selection, range }

typedef SeedDateConstraint = bool Function(
  DateTime date,
  SeedDateSelection selection,
);
SeedDateConstraint seedDateOnOrAfter(DateTime first) =>
    (date, _) => !seedDateOnly(date).isBefore(seedDateOnly(first));
SeedDateConstraint seedDateOnOrBefore(DateTime last) =>
    (date, _) => !seedDateOnly(date).isAfter(seedDateOnly(last));
SeedDateConstraint seedExcludeDates(
  bool Function(DateTime) excluded, {
  SeedExcludeDatesScope scope = SeedExcludeDatesScope.range,
}) =>
    (date, selection) {
      if (excluded(date)) return false;
      if (scope == SeedExcludeDatesScope.range &&
          selection.start != null &&
          selection.end != null) {
        for (
          var day = seedDateOnly(selection.start!);
          !day.isAfter(selection.end!);
          day = DateTime(day.year, day.month, day.day + 1)
        ) {
          if (excluded(day)) return false;
        }
      }
      return true;
    };
SeedDateConstraint seedRangeDayCountAtLeast(int count) {
  if (count < 1) {
    throw RangeError.value(count, 'count', 'Must be at least 1');
  }
  return (date, selection) =>
      selection.start == null ||
      selection.end == null ||
      seedCalendarDayCount(selection.start!, selection.end!) >= count;
}

SeedDateConstraint seedRangeDayCountAtMost(int count) {
  if (count < 1) {
    throw RangeError.value(count, 'count', 'Must be at least 1');
  }
  return (date, selection) =>
      selection.start == null ||
      selection.end == null ||
      seedCalendarDayCount(selection.start!, selection.end!) <= count;
}

SeedDateConstraint seedMaxSelectionCount(int count) {
  if (count < 1) {
    throw RangeError.value(count, 'count', 'Must be at least 1');
  }
  return (date, selection) => selection.dates.length <= count;
}

/// Navigation leaves selection untouched. focusDate additionally moves keyboard focus.
class SeedDatePickerController extends ChangeNotifier {
  DateTime? _target;
  bool _focus = false;
  DateTime? get target => _target;
  bool get requestsFocus => _focus;
  void navigateToDate(DateTime date) {
    _target = seedDateOnly(date);
    _focus = false;
    notifyListeners();
  }

  void focusDate(DateTime date) {
    _target = seedDateOnly(date);
    _focus = true;
    notifyListeners();
  }
}

class SeedDateCellInfo {
  const SeedDateCellInfo({
    required this.date,
    required this.label,
    required this.selected,
    required this.today,
    required this.inRange,
    required this.rangeStart,
    required this.rangeEnd,
    required this.unavailable,
    required this.readOnly,
    this.disabled = false,
    required this.focused,
  });
  final DateTime date;
  final String label;
  final bool selected,
      today,
      inRange,
      rangeStart,
      rangeEnd,
      unavailable,
      readOnly,
      disabled,
      focused;
}
