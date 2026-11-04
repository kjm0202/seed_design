import 'package:material_ui/material_ui.dart';

/// Returns the calendar date of [date] at local midnight, discarding time.
///
/// This does not convert [date] to another time zone.
DateTime seedDateOnly(DateTime date) =>
    DateTime(date.year, date.month, date.day);

/// Counts calendar days from [start] through [end], including both endpoints.
///
/// UTC date components avoid daylight-saving transitions changing the count.
int seedCalendarDayCount(DateTime start, DateTime end) =>
    DateTime.utc(
      end.year,
      end.month,
      end.day,
    ).difference(DateTime.utc(start.year, start.month, start.day)).inDays +
    1;

/// A range selection whose [start] is required and [end] may be unset.
///
/// [SeedDatePicker.range] uses this value for controlled and default selection.
class SeedDateRange {
  /// Creates a range, including a range with no selected [end] yet.
  const SeedDateRange({required this.start, this.end});

  /// Selected beginning of the range.
  final DateTime start;

  /// Selected end, or null while the range is still being chosen.
  final DateTime? end;
}

/// Proposed selection passed to date constraints before the change is accepted.
class SeedDateSelection {
  /// Describes the proposed single [date], range [start]/[end], or [dates].
  ///
  /// An absent selection is null; [dates] defaults to an empty list.
  const SeedDateSelection({
    this.date,
    this.start,
    this.end,
    this.dates = const [],
  });
  /// Single date, range start, and range end in the proposed selection.
  final DateTime? date, start, end;

  /// Proposed selection in multiple-date mode; defaults to an empty list.
  final List<DateTime> dates;
}

/// How excluded dates are checked for a range selection.
enum SeedExcludeDatesScope {
  /// Check the directly selected date without inspecting intervening days.
  selection,

  /// Reject a range when any day from its start through end is excluded.
  range,
}

/// Returns whether [date] may be selected under the proposed [selection].
///
/// Returning false rejects the proposed change. Flutter's [SeedDateSelection]
/// supplies the current proposal in place of React's date-picker context.
typedef SeedDateConstraint = bool Function(
  DateTime date,
  SeedDateSelection selection,
);
/// Accepts dates on or after [first], inclusive, ignoring the time of day.
SeedDateConstraint seedDateOnOrAfter(DateTime first) =>
    (date, _) => !seedDateOnly(date).isBefore(seedDateOnly(first));

/// Accepts dates on or before [last], inclusive, ignoring the time of day.
SeedDateConstraint seedDateOnOrBefore(DateTime last) =>
    (date, _) => !seedDateOnly(date).isAfter(seedDateOnly(last));

/// Rejects dates for which [excluded] returns true.
///
/// With the default [SeedExcludeDatesScope.range], a proposed selection with
/// both range endpoints checks every included day. [SeedExcludeDatesScope.selection]
/// checks only the proposed date. Matches React's `excludeDates` helper.
SeedDateConstraint seedExcludeDates(
  bool Function(DateTime) excluded, {
  SeedExcludeDatesScope scope = SeedExcludeDatesScope.range,
}) => (date, selection) {
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
/// Requires at least [count] calendar days in a completed range.
///
/// Both endpoints count. Incomplete ranges are allowed; [count] below one
/// throws [RangeError]. Corresponds to React's `rangeDayCountAtLeast`.
SeedDateConstraint seedRangeDayCountAtLeast(int count) {
  if (count < 1) {
    throw RangeError.value(count, 'count', 'Must be at least 1');
  }
  return (date, selection) =>
      selection.start == null ||
      selection.end == null ||
      seedCalendarDayCount(selection.start!, selection.end!) >= count;
}

/// Allows at most [count] calendar days in a completed range.
///
/// Both endpoints count. Incomplete ranges are allowed; [count] below one
/// throws [RangeError]. Corresponds to React's `rangeDayCountAtMost`.
SeedDateConstraint seedRangeDayCountAtMost(int count) {
  if (count < 1) {
    throw RangeError.value(count, 'count', 'Must be at least 1');
  }
  return (date, selection) =>
      selection.start == null ||
      selection.end == null ||
      seedCalendarDayCount(selection.start!, selection.end!) <= count;
}

/// Rejects a multiple-date proposal containing more than [count] dates.
///
/// Existing selections can still be deselected; [count] below one throws
/// [RangeError]. Corresponds to React's `maxSelectionCount`.
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

  /// Most recently requested visible date, reduced to its calendar day.
  DateTime? get target => _target;

  /// Whether the latest navigation request should also move keyboard focus.
  bool get requestsFocus => _focus;

  /// Requests calendar navigation to [date] without changing the selection.
  void navigateToDate(DateTime date) {
    _target = seedDateOnly(date);
    _focus = false;
    notifyListeners();
  }

  /// Requests navigation and keyboard focus on [date] without selecting it.
  void focusDate(DateTime date) {
    _target = seedDateOnly(date);
    _focus = true;
    notifyListeners();
  }
}

/// Selection, availability, and focus state of a rendered calendar day cell.
///
/// Passed to [SeedDatePicker.dateCellSupplement] and
/// [SeedDatePicker.dateCellContent].
class SeedDateCellInfo {
  /// Describes the [date] cell and its accessible [label].
  ///
  /// [selected], [today], [inRange], [rangeStart], and [rangeEnd] describe
  /// selection visuals. [unavailable], [readOnly], and [disabled] describe
  /// interaction limits; [focused] is the keyboard focus target.
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
  /// Calendar date associated with this cell.
  final DateTime date;

  /// Localized day label.
  final String label;

  /// Whether the cell is selected, represents today, falls within a selected
  /// range, begins that range, ends that range, is unavailable, is read-only,
  /// is disabled, and has keyboard focus, respectively.
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
