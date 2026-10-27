import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

/// All calendar layouts and selection modes within the inputs catalog.
class CalendarExample extends StatefulWidget {
  const CalendarExample({super.key});

  @override
  State<CalendarExample> createState() => _CalendarExampleState();
}

class _CalendarExampleState extends State<CalendarExample> {
  SeedDatePickerLayout _layout = SeedDatePickerLayout.month;
  SeedDatePickerMode _mode = SeedDatePickerMode.single;
  DateTime? _date = DateTime.now();
  SeedDateRange? _range;
  List<DateTime> _dates = [];

  String _format(DateTime? date) =>
      date == null ? '미선택' : '${date.year}.${date.month}.${date.day}';

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 372),
        child: Row(
          children: [
            Expanded(
              child: SeedSelect<SeedDatePickerLayout>(
                key: const ValueKey('calendar-layout'),
                label: '달력 보기',
                value: _layout,
                groups: [
                  SeedSelectGroup(
                    items: [
                      for (final layout in SeedDatePickerLayout.values)
                        SeedSelectItem(
                          value: layout,
                          label: switch (layout) {
                            SeedDatePickerLayout.month => '한 달',
                            SeedDatePickerLayout.twoMonths => '두 달',
                            SeedDatePickerLayout.week => '한 주',
                            SeedDatePickerLayout.continuous => '연속',
                          },
                        ),
                    ],
                  ),
                ],
                onChanged: (value) => setState(() => _layout = value),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SeedSelect<SeedDatePickerMode>(
                key: const ValueKey('calendar-mode'),
                label: '날짜 선택 방식',
                value: _mode,
                groups: [
                  SeedSelectGroup(
                    items: [
                      for (final mode in SeedDatePickerMode.values)
                        SeedSelectItem(
                          value: mode,
                          label: switch (mode) {
                            SeedDatePickerMode.single => '단일 선택',
                            SeedDatePickerMode.range => '범위 선택',
                            SeedDatePickerMode.multiple => '다중 선택',
                          },
                        ),
                    ],
                  ),
                ],
                onChanged: (value) => setState(() => _mode = value),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: _layout == SeedDatePickerLayout.twoMonths ? 736 : 360,
          ),
          child: SeedDatePicker(
            key: ValueKey((_layout, _mode)),
            layout: _layout,
            mode: _mode,
            controlled: true,
            value: _date,
            rangeValue: _range,
            values: _dates,
            height: _layout == SeedDatePickerLayout.continuous ? 420 : null,
            onValueChanged: (value) => setState(() => _date = value),
            onRangeSelected: (start, end) => setState(() {
              _range = start == null
                  ? null
                  : SeedDateRange(start: start, end: end);
            }),
            onDatesSelected: (value) => setState(() => _dates = value),
            showReset: true,
          ),
        ),
      ),
      const SizedBox(height: 8),
      Text(key: const ValueKey('calendar-selection'), switch (_mode) {
        SeedDatePickerMode.single => '선택한 날짜: ${_format(_date)}',
        SeedDatePickerMode.range =>
          '선택한 기간: ${_format(_range?.start)} ~ ${_format(_range?.end)}',
        SeedDatePickerMode.multiple =>
          '다중 선택: ${_dates.isEmpty ? '미선택' : _dates.map(_format).join(', ')}',
      }),
    ],
  );
}
