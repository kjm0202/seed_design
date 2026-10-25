import 'package:material_ui/material_ui.dart';

import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';

/// Selection mode for [SeedDatePicker].
enum SeedDatePickerMode { single, range }

/// A SEED Design Date Picker calendar component.
///
/// Features:
/// - Month/Year navigation header with previous/next chevron buttons
/// - Weekday indicator header (일, 월, 화, 수, 목, 금, 토)
/// - Single date or date range selection
/// - Custom min/max date constraints
class SeedDatePicker extends StatefulWidget {
  const SeedDatePicker({
    super.key,
    this.mode = SeedDatePickerMode.single,
    this.initialDate,
    this.initialStartDate,
    this.initialEndDate,
    this.firstDate,
    this.lastDate,
    this.onDateSelected,
    this.onRangeSelected,
    this.selectableDayPredicate,
  });

  final SeedDatePickerMode mode;
  final DateTime? initialDate;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime>? onDateSelected;
  final void Function(DateTime? start, DateTime? end)? onRangeSelected;
  final bool Function(DateTime date)? selectableDayPredicate;

  @override
  State<SeedDatePicker> createState() => _SeedDatePickerState();
}

class _SeedDatePickerState extends State<SeedDatePicker> {
  late DateTime _currentMonth;
  DateTime? _selectedDate;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    final init =
        widget.initialDate ?? widget.initialStartDate ?? DateTime.now();
    _currentMonth = _clampMonth(DateTime(init.year, init.month));
    _selectedDate = widget.initialDate != null
        ? DateTime(
            widget.initialDate!.year,
            widget.initialDate!.month,
            widget.initialDate!.day,
          )
        : null;
    _startDate = widget.initialStartDate != null
        ? DateTime(
            widget.initialStartDate!.year,
            widget.initialStartDate!.month,
            widget.initialStartDate!.day,
          )
        : null;
    _endDate = widget.initialEndDate != null
        ? DateTime(
            widget.initialEndDate!.year,
            widget.initialEndDate!.month,
            widget.initialEndDate!.day,
          )
        : null;
  }

  DateTime _clampMonth(DateTime month) {
    final first = widget.firstDate;
    final last = widget.lastDate;
    if (first != null && month.isBefore(DateTime(first.year, first.month))) {
      return DateTime(first.year, first.month);
    }
    if (last != null && month.isAfter(DateTime(last.year, last.month))) {
      return DateTime(last.year, last.month);
    }
    return month;
  }

  bool _canShowMonth(DateTime month) {
    final first = widget.firstDate;
    final last = widget.lastDate;
    if (first != null &&
        DateTime(
          month.year,
          month.month + 1,
          0,
        ).isBefore(DateUtils.dateOnly(first))) {
      return false;
    }
    if (last != null && month.isAfter(DateUtils.dateOnly(last))) {
      return false;
    }
    return true;
  }

  @override
  void didUpdateWidget(SeedDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.firstDate != widget.firstDate ||
        oldWidget.lastDate != widget.lastDate) {
      _currentMonth = _clampMonth(_currentMonth);
    }
  }

  void _onPrevMonth() {
    if (!_canShowMonth(DateTime(_currentMonth.year, _currentMonth.month - 1))) {
      return;
    }
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _onNextMonth() {
    if (!_canShowMonth(DateTime(_currentMonth.year, _currentMonth.month + 1))) {
      return;
    }
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  bool _isDateSelectable(DateTime date) {
    if (widget.firstDate != null &&
        date.isBefore(DateUtils.dateOnly(widget.firstDate!))) {
      return false;
    }
    if (widget.lastDate != null &&
        date.isAfter(DateUtils.dateOnly(widget.lastDate!))) {
      return false;
    }
    if (widget.selectableDayPredicate != null) {
      return widget.selectableDayPredicate!(date);
    }
    return true;
  }

  void _handleDayTap(DateTime day) {
    if (!_isDateSelectable(day)) return;

    if (widget.mode == SeedDatePickerMode.single) {
      setState(() {
        _selectedDate = day;
      });
      widget.onDateSelected?.call(day);
    } else {
      setState(() {
        if (_startDate == null || (_startDate != null && _endDate != null)) {
          _startDate = day;
          _endDate = null;
        } else if (_startDate != null && _endDate == null) {
          if (day.isBefore(_startDate!)) {
            _startDate = day;
          } else {
            _endDate = day;
          }
        }
      });
      widget.onRangeSelected?.call(_startDate, _endDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;

    final firstDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    );
    final daysInMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    ).day;
    final startingWeekday = firstDayOfMonth.weekday % 7;
    final canGoToPreviousMonth = _canShowMonth(
      DateTime(_currentMonth.year, _currentMonth.month - 1),
    );
    final canGoToNextMonth = _canShowMonth(
      DateTime(_currentMonth.year, _currentMonth.month + 1),
    );

    final weekdays = ['일', '월', '화', '수', '목', '금', '토'];

    return Container(
      constraints: const BoxConstraints(maxWidth: 360),
      padding: const EdgeInsets.all(SeedDimension.x4),
      decoration: BoxDecoration(
        color: colors.bg.layerFloating,
        borderRadius: SeedBorderRadius.r3,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: Month/Year navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${_currentMonth.year}년 ${_currentMonth.month}월',
                  style: typography.t5Bold.copyWith(color: colors.fg.neutral),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    color: colors.fg.neutral,
                    disabledColor: colors.fg.disabled,
                    tooltip: '이전 달',
                    onPressed: canGoToPreviousMonth ? _onPrevMonth : null,
                    splashRadius: 20,
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    color: colors.fg.neutral,
                    disabledColor: colors.fg.disabled,
                    tooltip: '다음 달',
                    onPressed: canGoToNextMonth ? _onNextMonth : null,
                    splashRadius: 20,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: SeedDimension.x2),

          // Weekday Row
          Row(
            children: weekdays.map((weekday) {
              return Expanded(
                child: SizedBox(
                  height: 48,
                  child: Center(
                    child: Text(
                      weekday,
                      style: typography.t4Medium.copyWith(
                        color: colors.fg.neutralSubtle,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: SeedDimension.x2),

          // Date Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: startingWeekday + daysInMonth,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisExtent: 48,
            ),
            itemBuilder: (context, index) {
              if (index < startingWeekday) {
                return const SizedBox.shrink();
              }
              final dayNumber = index - startingWeekday + 1;
              final date = DateTime(
                _currentMonth.year,
                _currentMonth.month,
                dayNumber,
              );
              final isSelectable = _isDateSelectable(date);

              final isSelectedSingle =
                  widget.mode == SeedDatePickerMode.single &&
                  _selectedDate != null &&
                  _selectedDate!.year == date.year &&
                  _selectedDate!.month == date.month &&
                  _selectedDate!.day == date.day;

              final isStart =
                  _startDate != null &&
                  _startDate!.year == date.year &&
                  _startDate!.month == date.month &&
                  _startDate!.day == date.day;

              final isEnd =
                  _endDate != null &&
                  _endDate!.year == date.year &&
                  _endDate!.month == date.month &&
                  _endDate!.day == date.day;

              final isInRange =
                  _startDate != null &&
                  _endDate != null &&
                  date.isAfter(_startDate!) &&
                  date.isBefore(_endDate!);

              final isToday =
                  DateTime.now().year == date.year &&
                  DateTime.now().month == date.month &&
                  DateTime.now().day == date.day;

              BoxDecoration? decoration;
              Color textColor = colors.fg.neutralMuted;

              if (isSelectedSingle || isStart || isEnd) {
                decoration = BoxDecoration(
                  color: colors.bg.neutralSolid,
                  shape: BoxShape.circle,
                );
                textColor = colors.fg.onNeutralSolid;
              } else if (isInRange) {
                decoration = BoxDecoration(
                  color: colors.bg.neutralWeak,
                  shape: BoxShape.rectangle,
                  borderRadius: SeedBorderRadius.r1,
                );
                textColor = colors.fg.neutral;
              } else if (isToday) {
                decoration = BoxDecoration(
                  color: colors.bg.neutralWeak,
                  shape: BoxShape.circle,
                );
                textColor = colors.fg.neutral;
              }

              if (!isSelectable) {
                textColor = colors.fg.disabled;
              }

              return Semantics(
                container: true,
                label: '${date.year}년 ${date.month}월 ${date.day}일',
                selected: isSelectedSingle || isStart || isEnd,
                child: InkWell(
                  onTap: isSelectable ? () => _handleDayTap(date) : null,
                  borderRadius: SeedBorderRadius.r2,
                  child: Center(
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: decoration,
                      alignment: Alignment.center,
                      child: ExcludeSemantics(
                        child: Text(
                          '$dayNumber',
                          style: typography.t5Medium.copyWith(color: textColor),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
