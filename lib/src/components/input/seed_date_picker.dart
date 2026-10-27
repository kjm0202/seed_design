import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' show DateFormat, NumberFormat;
import 'package:intl/date_symbol_data_local.dart';

import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
import '../../theme/seed_theme.dart';
import '../popover/seed_popover.dart';
import 'seed_wheel_picker.dart';
import 'seed_date_constraints.dart';
export 'seed_date_constraints.dart';

enum SeedDatePickerMode { single, range, multiple }

enum SeedDatePickerLayout { month, twoMonths, week, continuous }

/// Calendar dates without time-zone conversion. View changes never select a day.
///
/// A non-null value controls the corresponding selection mode. Set [controlled]
/// to true to control an empty (null) selection as well. Change callbacks propose
/// values; the displayed selection changes only when the parent accepts them.
/// The default* inputs initialize local state once; initial* inputs are aliases.
class SeedDatePicker extends StatefulWidget {
  const SeedDatePicker({
    super.key,
    SeedDatePickerMode? selectionMode,
    SeedDatePickerMode? mode,
    SeedDatePickerLayout? visibleRange,
    SeedDatePickerLayout? layout,
    DateTime? defaultValue,
    DateTime? initialDate,
    this.today,
    SeedDateRange? defaultRangeValue,
    this.initialStartDate,
    this.initialEndDate,
    this.value,
    this.rangeValue,
    this.values,
    List<DateTime>? defaultValues,
    List<DateTime>? initialDates,
    this.firstDate,
    this.lastDate,
    this.onDateSelected,
    ValueChanged<DateTime?>? onValueChange,
    ValueChanged<DateTime?>? onValueChanged,
    this.onRangeValueChange,
    this.onRangeSelected,
    ValueChanged<List<DateTime>>? onDatesChange,
    ValueChanged<List<DateTime>>? onDatesSelected,
    this.selectableDayPredicate,
    this.constraints = const [],
    this.enabled = true,
    this.disabled = false,
    this.readOnly = false,
    this.controlled = false,
    this.rangeStartReadOnly = false,
    this.locale = const Locale('ko', 'KR'),
    this.weekStartsOn,
    this.viewDate,
    this.defaultViewDate,
    ValueChanged<DateTime>? onViewDateChange,
    ValueChanged<DateTime>? onViewDateChanged,
    this.controller,
    this.yearRange,
    this.monthRange,
    this.height,
    this.minHeight,
    this.maxHeight,
    this.cellHeight = 48,
    this.dateCellSupplement,
    this.dateCellContent,
    this.semanticsLabel,
    this.showReset = false,
    this.onReset,
  }) : mode = selectionMode ?? mode ?? SeedDatePickerMode.single,
       layout = visibleRange ?? layout ?? SeedDatePickerLayout.month,
       assert(selectionMode == null || mode == null),
       assert(visibleRange == null || layout == null),
       onDatesSelected = onDatesChange ?? onDatesSelected,
       assert(onDatesChange == null || onDatesSelected == null),
       onViewDateChanged = onViewDateChange ?? onViewDateChanged,
       assert(onViewDateChange == null || onViewDateChanged == null),
       onValueChanged = onValueChange ?? onValueChanged,
       assert(onValueChange == null || onValueChanged == null),
       initialDate = defaultValue ?? initialDate,
       _defaultRangeValue = defaultRangeValue,
       initialDates = defaultValues ?? initialDates ?? const [],
       assert(defaultValue == null || initialDate == null),
       assert(
         defaultRangeValue == null ||
             (initialStartDate == null && initialEndDate == null),
       ),
       assert(defaultValues == null || initialDates == null),
       assert(weekStartsOn == null || (weekStartsOn >= 1 && weekStartsOn <= 7)),
       assert(dateCellSupplement == null || dateCellContent == null),
       assert(cellHeight > 0),
       assert(
         (visibleRange ?? layout) != SeedDatePickerLayout.continuous ||
             (height != null || minHeight != null || maxHeight != null),
         'Continuous calendars require a bounded height',
       );

  /// React-compatible range selection with a typed value/defaultValue.
  const SeedDatePicker.range({
    SeedDateRange? value,
    SeedDateRange? defaultValue,
    ValueChanged<SeedDateRange?>? onValueChange,
    Key? key,
    SeedDatePickerLayout visibleRange = SeedDatePickerLayout.month,
    DateTime? today,
    DateTime? firstDate,
    DateTime? lastDate,
    bool Function(DateTime)? selectableDayPredicate,
    List<SeedDateConstraint> constraints = const [],
    bool enabled = true,
    bool disabled = false,
    bool readOnly = false,
    bool controlled = false,
    Locale locale = const Locale('ko', 'KR'),
    int? weekStartsOn,
    DateTime? viewDate,
    DateTime? defaultViewDate,
    ValueChanged<DateTime>? onViewDateChange,
    SeedDatePickerController? controller,
    ({int start, int end})? yearRange,
    DateTimeRange? monthRange,
    double? height,
    double? minHeight,
    double? maxHeight,
    double cellHeight = 48,
    Widget Function(BuildContext, SeedDateCellInfo)? dateCellSupplement,
    Widget Function(BuildContext, SeedDateCellInfo)? dateCellContent,
    String? semanticsLabel,
    bool showReset = false,
    VoidCallback? onReset,
    bool rangeStartReadOnly = false,
  }) : this(
         selectionMode: SeedDatePickerMode.range,
         rangeValue: value,
         defaultRangeValue: defaultValue,
         onRangeValueChange: onValueChange,
         key: key,
         visibleRange: visibleRange,
         today: today,
         firstDate: firstDate,
         lastDate: lastDate,
         selectableDayPredicate: selectableDayPredicate,
         constraints: constraints,
         enabled: enabled,
         disabled: disabled,
         readOnly: readOnly,
         controlled: controlled,
         locale: locale,
         weekStartsOn: weekStartsOn,
         viewDate: viewDate,
         defaultViewDate: defaultViewDate,
         onViewDateChange: onViewDateChange,
         controller: controller,
         yearRange: yearRange,
         monthRange: monthRange,
         height: height,
         minHeight: minHeight,
         maxHeight: maxHeight,
         cellHeight: cellHeight,
         dateCellSupplement: dateCellSupplement,
         dateCellContent: dateCellContent,
         semanticsLabel: semanticsLabel,
         showReset: showReset,
         onReset: onReset,
         rangeStartReadOnly: rangeStartReadOnly,
       );

  /// React-compatible multiple selection with a typed value/defaultValue.
  const SeedDatePicker.multiple({
    List<DateTime>? value,
    List<DateTime>? defaultValue,
    ValueChanged<List<DateTime>>? onValueChange,
    Key? key,
    SeedDatePickerLayout visibleRange = SeedDatePickerLayout.month,
    DateTime? today,
    DateTime? firstDate,
    DateTime? lastDate,
    bool Function(DateTime)? selectableDayPredicate,
    List<SeedDateConstraint> constraints = const [],
    bool enabled = true,
    bool disabled = false,
    bool readOnly = false,
    bool controlled = false,
    Locale locale = const Locale('ko', 'KR'),
    int? weekStartsOn,
    DateTime? viewDate,
    DateTime? defaultViewDate,
    ValueChanged<DateTime>? onViewDateChange,
    SeedDatePickerController? controller,
    ({int start, int end})? yearRange,
    DateTimeRange? monthRange,
    double? height,
    double? minHeight,
    double? maxHeight,
    double cellHeight = 48,
    Widget Function(BuildContext, SeedDateCellInfo)? dateCellSupplement,
    Widget Function(BuildContext, SeedDateCellInfo)? dateCellContent,
    String? semanticsLabel,
    bool showReset = false,
    VoidCallback? onReset,
  }) : this(
         selectionMode: SeedDatePickerMode.multiple,
         values: value,
         defaultValues: defaultValue,
         onDatesChange: onValueChange,
         key: key,
         visibleRange: visibleRange,
         today: today,
         firstDate: firstDate,
         lastDate: lastDate,
         selectableDayPredicate: selectableDayPredicate,
         constraints: constraints,
         enabled: enabled,
         disabled: disabled,
         readOnly: readOnly,
         controlled: controlled,
         locale: locale,
         weekStartsOn: weekStartsOn,
         viewDate: viewDate,
         defaultViewDate: defaultViewDate,
         onViewDateChange: onViewDateChange,
         controller: controller,
         yearRange: yearRange,
         monthRange: monthRange,
         height: height,
         minHeight: minHeight,
         maxHeight: maxHeight,
         cellHeight: cellHeight,
         dateCellSupplement: dateCellSupplement,
         dateCellContent: dateCellContent,
         semanticsLabel: semanticsLabel,
         showReset: showReset,
         onReset: onReset,
       );

  final SeedDatePickerMode mode;
  final SeedDatePickerLayout layout;
  SeedDatePickerMode get selectionMode => mode;
  SeedDatePickerLayout get visibleRange => layout;
  final DateTime? initialDate, initialStartDate, initialEndDate;
  final DateTime? value;
  final SeedDateRange? rangeValue;
  final List<DateTime>? values;
  final List<DateTime> initialDates;

  /// One-time uncontrolled seed. [initialDate] is a compatibility alias.
  DateTime? get defaultValue => initialDate;
  final SeedDateRange? _defaultRangeValue;

  /// One-time uncontrolled range seed. The initial*Date names are aliases.
  SeedDateRange? get defaultRangeValue =>
      _defaultRangeValue ??
      (initialStartDate == null
          ? null
          : SeedDateRange(start: initialStartDate!, end: initialEndDate));

  /// One-time uncontrolled seed. [initialDates] is a compatibility alias.
  List<DateTime> get defaultValues => initialDates;
  final DateTime? firstDate, lastDate;
  final ValueChanged<DateTime>? onDateSelected;
  final ValueChanged<DateTime?>? onValueChanged;
  ValueChanged<DateTime?>? get onValueChange => onValueChanged;
  final void Function(DateTime? start, DateTime? end)? onRangeSelected;
  final ValueChanged<SeedDateRange?>? onRangeValueChange;
  final ValueChanged<List<DateTime>>? onDatesSelected;
  ValueChanged<List<DateTime>>? get onDatesChange => onDatesSelected;
  final bool Function(DateTime date)? selectableDayPredicate;
  final List<SeedDateConstraint> constraints;
  final bool enabled, disabled, readOnly, rangeStartReadOnly, controlled;
  final Locale locale;

  /// Uses DateTime weekday numbering: Monday=1 through Sunday=7.
  final int? weekStartsOn;
  final DateTime? viewDate, defaultViewDate;
  final ValueChanged<DateTime>? onViewDateChanged;
  ValueChanged<DateTime>? get onViewDateChange => onViewDateChanged;
  final SeedDatePickerController? controller;
  final ({int start, int end})? yearRange;
  final DateTimeRange? monthRange;
  final double? height, minHeight, maxHeight;
  final DateTime? today;
  final double cellHeight;
  final Widget Function(BuildContext, SeedDateCellInfo)? dateCellSupplement,
      dateCellContent;
  final String? semanticsLabel;
  final bool showReset;
  final VoidCallback? onReset;
  @override
  State<SeedDatePicker> createState() => _SeedDatePickerState();
}

class _SeedDatePickerState extends State<SeedDatePicker> {
  late DateTime _view;
  DateTime? _selectedDate, _startDate, _endDate, _focusedDate;
  late Set<DateTime> _dates;
  bool _showMonthPicker = false;
  double _monthPickerHeight = 296;
  final FocusNode _monthYearFocusNode = FocusNode();
  final Map<DateTime, FocusNode> _dayNodes = {};
  final Map<DateTime, BuildContext> _monthContexts = {};
  final GlobalKey _continuousScrollKey = GlobalKey();
  final ScrollController _scroll = ScrollController();
  final GlobalKey _continuousCenter = GlobalKey();
  late DateTime _continuousAnchor;
  final GlobalKey _headerKey = GlobalKey();
  StateSetter? _updateMonthOverlay;
  bool _weekOverlayOpen = false;
  bool get _isDisabled => !widget.enabled || widget.disabled;
  bool get _singleControlled => widget.controlled || widget.value != null;
  bool get _rangeControlled => widget.controlled || widget.rangeValue != null;
  bool get _multipleControlled => widget.controlled || widget.values != null;
  String get _locale => widget.locale.toString();
  bool get _korean => widget.locale.languageCode == 'ko';
  int get _weekStartsOn =>
      widget.weekStartsOn ??
      DateFormat.E(_locale).dateSymbols.FIRSTDAYOFWEEK + 1;
  DateTime _month(DateTime day) => DateTime(day.year, day.month);
  DateTime _week(DateTime day) => DateTime(
    day.year,
    day.month,
    day.day - (day.weekday - _weekStartsOn) % 7,
  );
  DateTime get _firstMonth => _month(
    widget.monthRange?.start ?? widget.firstDate ?? DateTime(_firstYear),
  );
  DateTime get _lastMonth => _month(
    widget.monthRange?.end ?? widget.lastDate ?? DateTime(_lastYear, 12),
  );
  int get _firstYear =>
      widget.yearRange?.start ??
      widget.monthRange?.start.year ??
      widget.firstDate?.year ??
      math.min((widget.today ?? DateTime.now()).year - 100, _view.year);
  int get _lastYear =>
      widget.yearRange?.end ??
      widget.monthRange?.end.year ??
      widget.lastDate?.year ??
      math.max((widget.today ?? DateTime.now()).year + 100, _view.year);
  DateTime get _headerMonth {
    if (widget.layout != SeedDatePickerLayout.week) return _month(_view);
    final start = _week(_view),
        end = DateTime(
          _week(_view).year,
          _week(_view).month,
          _week(_view).day + 6,
        );
    return _canShow(end) ? _month(end) : _month(start);
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting(_locale);
    final single = _singleControlled ? widget.value : widget.defaultValue;
    final start = _rangeControlled
        ? widget.rangeValue?.start
        : widget.defaultRangeValue?.start;
    final end = _rangeControlled
        ? widget.rangeValue?.end
        : widget.defaultRangeValue?.end;
    _selectedDate = single == null ? null : seedDateOnly(single);
    _startDate = start == null ? null : seedDateOnly(start);
    _endDate = end == null ? null : seedDateOnly(end);
    _dates = (_multipleControlled ? widget.values ?? [] : widget.defaultValues)
        .map(seedDateOnly)
        .toSet();
    final initial =
        widget.viewDate ??
        widget.defaultViewDate ??
        _selectedDate ??
        _startDate ??
        (_dates.isEmpty
            ? (widget.today ?? DateTime.now())
            : (_dates.toList()..sort()).first);
    _view = seedDateOnly(initial);
    _view = _clampView(_view);
    _continuousAnchor = _month(_view);
    widget.controller?.addListener(_controllerChanged);
    if (widget.layout == SeedDatePickerLayout.continuous) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollTo(_view));
    }
  }

  @override
  void didUpdateWidget(SeedDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.locale != widget.locale) initializeDateFormatting(_locale);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_controllerChanged);
      widget.controller?.addListener(_controllerChanged);
    }
    if (_singleControlled) {
      final d = widget.value;
      _selectedDate = d == null ? null : seedDateOnly(d);
    }
    if (_rangeControlled) {
      final s = widget.rangeValue?.start;
      final e = widget.rangeValue?.end;
      _startDate = s == null ? null : seedDateOnly(s);
      _endDate = e == null ? null : seedDateOnly(e);
    }
    if (_multipleControlled) {
      _dates = (widget.values ?? []).map(seedDateOnly).toSet();
    }
    if (widget.viewDate != null && oldWidget.viewDate != widget.viewDate) {
      _view = _clampView(widget.viewDate!);
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollTo(_view));
    } else {
      _view = _clampView(_view);
    }
    if (widget.layout == SeedDatePickerLayout.continuous &&
        (oldWidget.layout != widget.layout ||
            oldWidget.monthRange != widget.monthRange ||
            oldWidget.yearRange != widget.yearRange ||
            oldWidget.firstDate != widget.firstDate ||
            oldWidget.lastDate != widget.lastDate)) {
      _continuousAnchor = _month(_view);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _scrollTo(_view);
      });
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_controllerChanged);
    _monthYearFocusNode.dispose();
    _scroll.dispose();
    for (final node in _dayNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  DateTime _clampView(DateTime day) {
    final first =
        widget.monthRange?.start ??
        widget.firstDate ??
        (widget.yearRange == null ? null : DateTime(_firstYear));
    final last =
        widget.monthRange?.end ??
        widget.lastDate ??
        (widget.yearRange == null ? null : DateTime(_lastYear, 12, 31));
    if (first != null && _month(day).isBefore(_month(first))) {
      return _month(first);
    }
    if (last != null && _month(day).isAfter(_month(last))) return _month(last);
    return seedDateOnly(day);
  }

  bool _canShow(DateTime day) {
    final first =
        widget.monthRange?.start ??
        widget.firstDate ??
        (widget.yearRange == null ? null : DateTime(_firstYear));
    final last =
        widget.monthRange?.end ??
        widget.lastDate ??
        (widget.yearRange == null ? null : DateTime(_lastYear, 12, 31));
    return (first == null || !_month(day).isBefore(_month(first))) &&
        (last == null || !_month(day).isAfter(_month(last)));
  }

  void _setView(DateTime day, {bool focus = false}) {
    final next = _clampView(day);
    if (widget.viewDate == null) {
      setState(() {
        _view = next;
        if (widget.layout == SeedDatePickerLayout.continuous) {
          _continuousAnchor = _month(next);
        }
      });
    }
    widget.onViewDateChanged?.call(
      widget.layout == SeedDatePickerLayout.week ? _week(next) : _month(next),
    );
    _updateMonthOverlay?.call(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scrollTo(widget.viewDate == null ? next : _view);
      if (focus) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final node = _dayNodes[seedDateOnly(next)];
          if (node?.context != null) {
            node!.requestFocus();
            Scrollable.ensureVisible(node.context!);
          }
        });
      }
    });
  }

  void _controllerChanged() {
    final controller = widget.controller;
    if (controller?.target != null) {
      _setView(controller!.target!, focus: controller.requestsFocus);
    }
  }

  int _monthIndex(DateTime month) =>
      (month.year - _firstMonth.year) * 12 + month.month - _firstMonth.month;
  double _monthHeight(DateTime month) {
    final offset = (month.weekday - _weekStartsOn) % 7;
    final count = DateTime(month.year, month.month + 1, 0).day;
    return 40 + ((offset + count) / 7).ceil() * widget.cellHeight;
  }

  void _scrollTo(DateTime day) {
    if (!mounted || widget.layout != SeedDatePickerLayout.continuous) return;
    // An ordinary SliverList must lay out every intervening month when jumping
    // from the first year to the current date. Anchor the viewport at the target
    // month instead: months before it grow upward, and later months grow down.
    // Only visible/cache months are built, even with variable-height cells.
    final anchor = _month(_clampView(day));
    if (_continuousAnchor != anchor) {
      setState(() => _continuousAnchor = anchor);
    }
    if (_scroll.hasClients && _scroll.offset != 0) _scroll.jumpTo(0);
  }

  void _syncVisibleContinuousMonth() {
    final scrollBox =
        _continuousScrollKey.currentContext?.findRenderObject() as RenderBox?;
    if (scrollBox == null || !scrollBox.hasSize) return;
    final viewportTop = scrollBox.localToGlobal(Offset.zero).dy;
    DateTime? bestMonth;
    double bestDistance = double.infinity;
    final stale = <DateTime>[];
    for (final entry in _monthContexts.entries) {
      final ctx = entry.value;
      if (!ctx.mounted) {
        stale.add(entry.key);
        continue;
      }
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize || !box.attached) continue;
      final top = box.localToGlobal(Offset.zero).dy;
      final bottom = top + box.size.height;
      if (bottom <= viewportTop + 8) continue;
      final distance = (top - viewportTop).abs();
      if (distance < bestDistance) {
        bestDistance = distance;
        bestMonth = entry.key;
      }
    }
    for (final key in stale) {
      _monthContexts.remove(key);
    }
    if (bestMonth != null && _month(_view) != bestMonth) {
      if (widget.viewDate == null) {
        _view = bestMonth;
      }
      widget.onViewDateChanged?.call(bestMonth);
    }
  }

  Widget _continuousCalendar() {
    final first = _monthIndex(_continuousAnchor)
        .clamp(0, _monthIndex(_lastMonth));
    final anchor = DateTime(_firstMonth.year, _firstMonth.month + first);
    Widget monthAt(int delta) {
      final month = DateTime(anchor.year, anchor.month + delta);
      return Builder(
        builder: (context) {
          _monthContexts[month] = context;
          return _monthCalendar(month, heading: true, weekdays: false);
        },
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if ((notification is ScrollUpdateNotification &&
                notification.dragDetails != null) ||
            notification is ScrollEndNotification) {
          _syncVisibleContinuousMonth();
        }
        return false;
      },
      child: CustomScrollView(
        key: _continuousScrollKey,
        controller: _scroll,
        primary: false,
        center: _continuousCenter,
        slivers: [
          if (first > 0)
            SliverList.builder(
              itemCount: first,
              itemBuilder: (context, index) => monthAt(-index - 1),
            ),
          SliverList.builder(
            key: _continuousCenter,
            itemCount: _monthIndex(_lastMonth) - first + 1,
            itemBuilder: (context, index) => monthAt(index),
          ),
        ],
      ),
    );
  }

  SeedDateSelection _proposal(DateTime day) {
    if (widget.mode == SeedDatePickerMode.single) {
      return SeedDateSelection(date: day);
    }
    if (widget.mode == SeedDatePickerMode.multiple) {
      final dates = Set<DateTime>.of(_dates);
      dates.contains(day) ? dates.remove(day) : dates.add(day);
      return SeedDateSelection(dates: dates.toList()..sort());
    }
    if (widget.rangeStartReadOnly && _startDate != null) {
      return SeedDateSelection(start: _startDate, end: day);
    }
    if (_startDate == null || _endDate != null || day.isBefore(_startDate!)) {
      return SeedDateSelection(start: day);
    }
    return SeedDateSelection(start: _startDate, end: day);
  }

  bool _selectable(DateTime day) {
    if (widget.firstDate != null &&
        day.isBefore(seedDateOnly(widget.firstDate!))) {
      return false;
    }
    if (widget.lastDate != null &&
        day.isAfter(seedDateOnly(widget.lastDate!))) {
      return false;
    }
    if (widget.selectableDayPredicate?.call(day) == false) return false;
    if (widget.rangeStartReadOnly && _startDate == day) {
      return true;
    }
    if (widget.rangeStartReadOnly &&
        _startDate != null &&
        day.isBefore(_startDate!)) {
      return false;
    }
    final proposal = _proposal(day);
    return widget.constraints.every((constraint) => constraint(day, proposal));
  }

  void _notifyRange(DateTime? start, DateTime? end) {
    widget.onRangeValueChange?.call(
      start == null ? null : SeedDateRange(start: start, end: end),
    );
    widget.onRangeSelected?.call(start, end);
  }

  void _select(DateTime date) {
    final day = seedDateOnly(date);
    if (_isDisabled || widget.readOnly) return;
    if (widget.mode == SeedDatePickerMode.range && widget.rangeStartReadOnly) {
      if (_startDate == null || !day.isAfter(_startDate!) || day == _endDate) {
        return;
      }
    }
    final removal =
        widget.mode == SeedDatePickerMode.multiple && _dates.contains(day);
    if (!removal && !_selectable(day)) return;
    final proposal = _proposal(day);
    setState(() {
      _focusedDate = day;
      if (widget.mode == SeedDatePickerMode.single && !_singleControlled) {
        _selectedDate = day;
      }
      if (widget.mode == SeedDatePickerMode.range && !_rangeControlled) {
        _startDate = proposal.start;
        _endDate = proposal.end;
      }
      if (widget.mode == SeedDatePickerMode.multiple && !_multipleControlled) {
        _dates = proposal.dates.toSet();
      }
    });
    switch (widget.mode) {
      case SeedDatePickerMode.single:
        widget.onDateSelected?.call(day);
        widget.onValueChanged?.call(day);
      case SeedDatePickerMode.range:
        _notifyRange(proposal.start, proposal.end);
      case SeedDatePickerMode.multiple:
        widget.onDatesSelected?.call(List.unmodifiable(proposal.dates));
    }
  }

  void _toggleMonthPicker() {
    if (_isDisabled) return;
    if (widget.layout == SeedDatePickerLayout.week && !_weekOverlayOpen) {
      _openWeekMonthPicker();
      return;
    }
    setState(() {
      if (!_showMonthPicker) {
        _monthPickerHeight = 56 + (_monthHeight(_headerMonth) - 40);
      }
      _showMonthPicker = !_showMonthPicker;
    });
    _monthYearFocusNode.requestFocus();
  }

  Future<void> _openWeekMonthPicker() async {
    final box = _headerKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    setState(() => _weekOverlayOpen = true);
    await showSeedPopover<void>(
      context: context,
      anchorRect: box.localToGlobal(Offset.zero) & box.size,
      builder: (context) => StatefulBuilder(
        builder: (context, update) {
          _updateMonthOverlay = update;
          return CallbackShortcuts(
            bindings: {
              const SingleActivator(LogicalKeyboardKey.escape): () =>
                  Navigator.of(context).pop(),
            },
            child: SizedBox(
              width: 280,
              child: _buildMonthPicker(context, small: true),
            ),
          );
        },
      ),
    );
    _updateMonthOverlay = null;
    if (mounted) {
      setState(() => _weekOverlayOpen = false);
      _monthYearFocusNode.requestFocus();
    }
  }

  Widget _buildMonthPicker(BuildContext context, {bool small = false}) {
    final year = _headerMonth.year;
    final firstBound = widget.monthRange?.start ?? widget.firstDate;
    final lastBound = widget.monthRange?.end ?? widget.lastDate;
    final firstMonth = firstBound?.year == year ? firstBound!.month : 1;
    final lastMonth = lastBound?.year == year ? lastBound!.month : 12;
    final months = List.generate(
      lastMonth - firstMonth + 1,
      (i) => firstMonth + i,
    );
    final selectedMonth = _headerMonth.month;
    return SeedWheelPicker(
      height: small ? 180 : _monthPickerHeight,
      size: small ? SeedWheelPickerSize.small : SeedWheelPickerSize.medium,
      enabled: !_isDisabled,
      readOnly: widget.readOnly,
      columns: [
        SeedWheelColumn.typed<int>(
          items: List.generate(
            _lastYear - _firstYear + 1,
            (i) => _firstYear + i,
          ),
          initialIndex: year - _firstYear,
          onChanged: (index) =>
              _setView(DateTime(_firstYear + index, selectedMonth)),
          itemBuilder: (context, value, selected) => _wheelLabel(
            context,
            _korean ? '$value년' : '$value',
            selected,
            small,
          ),
        ),
        SeedWheelColumn.typed<int>(
          items: months,
          initialIndex: (selectedMonth - firstMonth).clamp(
            0,
            months.length - 1,
          ),
          looping: months.length == 12,
          onChanged: (index) => _setView(DateTime(year, months[index])),
          itemBuilder: (context, value, selected) => _wheelLabel(
            context,
            DateFormat.MMM(_locale).format(DateTime(year, value)),
            selected,
            small,
          ),
        ),
      ],
    );
  }

  Widget _wheelLabel(
    BuildContext context,
    String label,
    bool selected,
    bool small,
  ) => Text(
    label,
    textScaler: TextScaler.noScaling,
    style:
        (small
                ? context.seedTypography.t7Medium
                : context.seedTypography.t10Medium)
            .copyWith(
              color: selected
                  ? context.seedColor.fg.neutral
                  : context.seedColor.fg.disabled,
            ),
  );
  KeyEventResult _onDayKey(DateTime day, KeyEvent event) {
    if (event is! KeyDownEvent || _isDisabled) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.space) {
      if (!widget.readOnly) _select(day);
      return KeyEventResult.handled;
    }
    final rtl = Directionality.of(context) == TextDirection.rtl;
    DateTime? next;
    if (key == LogicalKeyboardKey.arrowLeft) {
      next = DateTime(day.year, day.month, day.day + (rtl ? 1 : -1));
    }
    if (key == LogicalKeyboardKey.arrowRight) {
      next = DateTime(day.year, day.month, day.day + (rtl ? -1 : 1));
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      next = DateTime(day.year, day.month, day.day - 7);
    }
    if (key == LogicalKeyboardKey.arrowDown) {
      next = DateTime(day.year, day.month, day.day + 7);
    }
    if (key == LogicalKeyboardKey.home) next = _week(day);
    if (key == LogicalKeyboardKey.end) {
      final first = _week(day);
      next = DateTime(first.year, first.month, first.day + 6);
    }
    if (key == LogicalKeyboardKey.pageUp ||
        key == LogicalKeyboardKey.pageDown) {
      final direction = key == LogicalKeyboardKey.pageDown ? 1 : -1;
      if (HardwareKeyboard.instance.isShiftPressed) {
        final target = DateTime(day.year, day.month + direction * 12);
        next = DateTime(
          target.year,
          target.month,
          math.min(day.day, DateTime(target.year, target.month + 1, 0).day),
        );
      } else if (widget.layout == SeedDatePickerLayout.week) {
        next = DateTime(day.year, day.month, day.day + direction * 7);
      } else {
        final monthStep = widget.layout == SeedDatePickerLayout.twoMonths
            ? 2
            : 1;
        final target = DateTime(day.year, day.month + direction * monthStep);
        next = DateTime(
          target.year,
          target.month,
          math.min(day.day, DateTime(target.year, target.month + 1, 0).day),
        );
      }
    }
    if (next == null || !_canShow(next)) return KeyEventResult.ignored;
    _focusedDate = next;
    _setView(next, focus: true);
    return KeyEventResult.handled;
  }

  Widget _weekdays() => Row(
    children: [
      for (var i = 0; i < 7; i++)
        Expanded(
          child: SizedBox(
            height: 48,
            child: Center(
              child: Text(
                DateFormat.E(_locale)
                    .format(DateTime(2024, 1, _weekStartsOn + i)),
                style: context.seedTypography.t4Medium.copyWith(
                  color: context.seedColor.fg.neutralSubtle,
                ),
              ),
            ),
          ),
        ),
    ],
  );
  Widget _cell(DateTime date, DateTime tabDate) {
    final colors = context.seedColor;
    final single =
        widget.mode == SeedDatePickerMode.single && _selectedDate == date;
    final multi =
        widget.mode == SeedDatePickerMode.multiple && _dates.contains(date);
    final start = widget.mode == SeedDatePickerMode.range && _startDate == date;
    final end = widget.mode == SeedDatePickerMode.range && _endDate == date;
    final endpointSelected = single || multi || start || end;
    final rangeComplete =
        widget.mode == SeedDatePickerMode.range &&
        _startDate != null &&
        _endDate != null;
    final inRange =
        rangeComplete && date.isAfter(_startDate!) && date.isBefore(_endDate!);
    final selected = endpointSelected || inRange;
    final today = date == seedDateOnly((widget.today ?? DateTime.now()));
    final unavailable = !_selectable(date) && !(multi && !widget.readOnly);
    final isRangeStartReadOnly = widget.rangeStartReadOnly && start;
    final readOnly = widget.readOnly || isRangeStartReadOnly;
    final node = _dayNodes.putIfAbsent(date, FocusNode.new);
    final info = SeedDateCellInfo(
      date: date,
      label: NumberFormat.decimalPattern(_locale).format(date.day),
      selected: selected,
      today: today,
      inRange: inRange,
      rangeStart: start,
      rangeEnd: end,
      unavailable: unavailable,
      readOnly: readOnly,
      disabled: _isDisabled,
      focused: node.hasFocus,
    );
    final foreground = _isDisabled || unavailable
        ? colors.fg.disabled
        : endpointSelected
        ? colors.fg.onNeutralSolid
        : inRange || today
        ? colors.fg.neutral
        : colors.fg.neutralMuted;
    final decoration = endpointSelected
        ? BoxDecoration(
            color: isRangeStartReadOnly
                ? colors.bg.neutralSolid.withValues(alpha: 0.5)
                : colors.bg.neutralSolid,
            shape: BoxShape.circle,
          )
        : !inRange && today
        ? BoxDecoration(color: colors.bg.neutralWeak, shape: BoxShape.circle)
        : null;
    final showLineThrough = unavailable && !(start && !rangeComplete);
    final label = Text(
      info.label,
      maxLines: 1,
      softWrap: false,
      style: context.seedTypography.t5Medium.copyWith(
        color: foreground,
        decoration: showLineThrough ? TextDecoration.lineThrough : null,
        decorationColor: foreground,
      ),
    );
    final content =
        widget.dateCellContent?.call(context, info) ??
        (widget.dateCellSupplement == null
            ? FittedBox(fit: BoxFit.scaleDown, child: label)
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(fit: BoxFit.scaleDown, child: label),
                  widget.dateCellSupplement!(context, info),
                ],
              ));
    final showRangeSpan =
        rangeComplete && _startDate != _endDate && (inRange || start || end);
    return Focus(
      focusNode: node,
      skipTraversal: date != tabDate,
      canRequestFocus: !_isDisabled,
      includeSemantics: false,
      onKeyEvent: (_, event) => _onDayKey(date, event),
      onFocusChange: (focused) {
        if (focused && mounted) setState(() => _focusedDate = date);
      },
      child: Semantics(
        container: true,
        label: DateFormat.yMMMMd(_locale).format(date),
        enabled: _isDisabled ? false : null,
        selected: selected,
        focusable: !_isDisabled,
        focused: node.hasFocus,
        readOnly: readOnly,
        onFocus: _isDisabled ? null : node.requestFocus,
        child: InkWell(
          canRequestFocus: false,
          onTap: _isDisabled || unavailable || isRangeStartReadOnly
              ? null
              : widget.readOnly
              ? node.requestFocus
              : () {
                  node.requestFocus();
                  _select(date);
                },
          borderRadius: SeedBorderRadius.r2,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (showRangeSpan)
                Positioned.fill(
                  child: Align(
                    alignment: inRange
                        ? Alignment.center
                        : start
                        ? AlignmentDirectional.centerEnd
                        : AlignmentDirectional.centerStart,
                    child: FractionallySizedBox(
                      widthFactor: inRange ? 1.0 : 0.5,
                      child: SizedBox(
                        height: 42,
                        child: ColoredBox(color: colors.bg.neutralWeak),
                      ),
                    ),
                  ),
                ),
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        widget.dateCellSupplement != null ||
                            widget.dateCellContent != null
                        ? widget.cellHeight
                        : 42,
                  ),
                  child: Container(
                    width: 42,
                    constraints: const BoxConstraints(minHeight: 42),
                    decoration: decoration,
                    alignment: Alignment.center,
                    child: ExcludeSemantics(child: content),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  DateTime _tabDate(DateTime first, DateTime last) {
    for (final candidate in [
      _focusedDate,
      _selectedDate,
      _startDate,
      seedDateOnly((widget.today ?? DateTime.now())),
      first,
    ]) {
      if (candidate != null &&
          !candidate.isBefore(first) &&
          !candidate.isAfter(last)) {
        return candidate;
      }
    }
    return first;
  }

  Widget _grid(DateTime month, {bool week = false}) {
    final first = week ? _week(month) : _month(month);
    final count = week ? 7 : DateTime(month.year, month.month + 1, 0).day;
    final offset = week ? 0 : (first.weekday - _weekStartsOn) % 7;
    final last = DateTime(first.year, first.month, first.day + count - 1);
    final tab = _tabDate(first, last);
    if (widget.dateCellSupplement != null || widget.dateCellContent != null) {
      return Table(
        children: [
          for (var row = 0; row < (offset + count + 6) ~/ 7; row++)
            TableRow(
              children: [
                for (var col = 0; col < 7; col++)
                  if (row * 7 + col < offset || row * 7 + col >= offset + count)
                    const SizedBox.shrink()
                  else
                    _cell(
                      DateTime(
                        first.year,
                        first.month,
                        first.day + row * 7 + col - offset,
                      ),
                      tab,
                    ),
              ],
            ),
        ],
      );
    }
    return GridView.builder(
      primary: false,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: offset + count,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisExtent: widget.cellHeight,
      ),
      itemBuilder: (context, index) => index < offset
          ? const SizedBox.shrink()
          : _cell(
              DateTime(first.year, first.month, first.day + index - offset),
              tab,
            ),
    );
  }

  Widget _twoMonthHeader(DateTime month, {required bool isFirst}) {
    final colors = context.seedColor;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final target = DateTime(month.year, month.month + (isFirst ? -1 : 1));
    final canMove = !_isDisabled && !_showMonthPicker && _canShow(target);
    final icon = isFirst
        ? (rtl ? Icons.chevron_right : Icons.chevron_left)
        : (rtl ? Icons.chevron_left : Icons.chevron_right);
    final tooltip = isFirst
        ? (_korean ? '이전 달' : 'Previous month')
        : (_korean ? '다음 달' : 'Next month');
    return SizedBox(
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Text(
              DateFormat.yMMMM(_locale).format(month),
              style: context.seedTypography.t5Bold.copyWith(
                color: colors.fg.neutral,
              ),
            ),
          ),
          Align(
            alignment: isFirst
                ? AlignmentDirectional.centerStart
                : AlignmentDirectional.centerEnd,
            child: IconButton(
              icon: Icon(icon),
              color: colors.fg.neutral,
              disabledColor: colors.fg.disabled,
              tooltip: tooltip,
              onPressed: canMove ? () => _setView(target) : null,
              splashRadius: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _monthCalendar(
    DateTime month, {
    bool heading = false,
    Widget? customHeader,
    bool weekdays = true,
  }) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      ?customHeader,
      if (heading)
        SizedBox(
          height: 40,
          child: Center(
            child: Text(
              DateFormat.yMMMM(_locale).format(month),
              style: context.seedTypography.t5Bold,
            ),
          ),
        ),
      if (weekdays) ...[_weekdays(), const SizedBox(height: 8)],
      _grid(month),
    ],
  );
  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final month = _headerMonth;
    final week = widget.layout == SeedDatePickerLayout.week;
    final twoMonths = widget.layout == SeedDatePickerLayout.twoMonths;
    final prev = week
        ? DateTime(_view.year, _view.month, _view.day - 7)
        : DateTime(month.year, month.month - 1);
    final next = week
        ? DateTime(_view.year, _view.month, _view.day + 7)
        : DateTime(month.year, month.month + 1);
    final continuous = widget.layout == SeedDatePickerLayout.continuous;
    final title = DateFormat.yMMMM(_locale).format(month);
    final header = Row(
      children: [
        Expanded(
          child: SeedPressable(
            key: _headerKey,
            focusNode: _monthYearFocusNode,
            enabled: !_isDisabled,
            semanticsLabel: _korean ? '연도와 월 선택' : 'Choose month and year',
            semanticsValue: title,
            expanded: _showMonthPicker || _weekOverlayOpen,
            enableScale: false,
            onTap: _isDisabled ? null : _toggleMonthPicker,
            child: SizedBox(
              height: 48,
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: context.seedTypography.t5Bold.copyWith(
                        color: _isDisabled
                            ? colors.fg.disabled
                            : colors.fg.neutral,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _showMonthPicker || _weekOverlayOpen
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 20,
                    color: _isDisabled ? colors.fg.disabled : colors.fg.neutral,
                  ),
                ],
              ),
            ),
          ),
        ),
        IconButton(
          icon: Icon(rtl ? Icons.chevron_right : Icons.chevron_left),
          color: colors.fg.neutral,
          disabledColor: colors.fg.disabled,
          tooltip: _korean
              ? (week ? '이전 주' : '이전 달')
              : (week ? 'Previous week' : 'Previous month'),
          onPressed: !_isDisabled && !_showMonthPicker && _canShow(prev)
              ? () => _setView(prev)
              : null,
          splashRadius: 20,
        ),
        IconButton(
          icon: Icon(rtl ? Icons.chevron_left : Icons.chevron_right),
          color: colors.fg.neutral,
          disabledColor: colors.fg.disabled,
          tooltip: _korean
              ? (week ? '다음 주' : '다음 달')
              : (week ? 'Next week' : 'Next month'),
          onPressed: !_isDisabled && !_showMonthPicker && _canShow(next)
              ? () => _setView(next)
              : null,
          splashRadius: 20,
        ),
      ],
    );
    final secondMonth = DateTime(month.year, month.month + 1);
    final body = _showMonthPicker
        ? _buildMonthPicker(context)
        : switch (widget.layout) {
            SeedDatePickerLayout.month => _monthCalendar(month),
            SeedDatePickerLayout.twoMonths => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _monthCalendar(
                    month,
                    customHeader: _twoMonthHeader(month, isFirst: true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _monthCalendar(
                    secondMonth,
                    customHeader: _twoMonthHeader(secondMonth, isFirst: false),
                  ),
                ),
              ],
            ),
            SeedDatePickerLayout.week => Column(
              mainAxisSize: MainAxisSize.min,
              children: [_weekdays(), _grid(_view, week: true)],
            ),
            SeedDatePickerLayout.continuous => Expanded(
              child: _continuousCalendar(),
            ),
          };
    return CallbackShortcuts(
      bindings: {
        if (_showMonthPicker)
          const SingleActivator(LogicalKeyboardKey.escape): _toggleMonthPicker,
      },
      child: Semantics(
        label: widget.semanticsLabel,
        enabled: _isDisabled ? false : null,
        child: Container(
          constraints: BoxConstraints(
            minHeight: widget.minHeight ?? 0,
            maxHeight: widget.maxHeight ?? double.infinity,
          ),
          height: continuous
              ? (widget.height ?? widget.maxHeight ?? widget.minHeight)
              : null,
          padding: const EdgeInsets.all(SeedDimension.x4),
          decoration: BoxDecoration(
            color: colors.bg.layerFloating,
            borderRadius: SeedBorderRadius.r3,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!continuous && !twoMonths) ...[
                header,
                const SizedBox(height: 8),
              ] else if (continuous)
                _weekdays(),
              body,
              if (widget.showReset)
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                    onPressed: _isDisabled || widget.readOnly
                        ? null
                        : () {
                            setState(() {
                              if (!_singleControlled) {
                                _selectedDate = null;
                              }
                              if (!_rangeControlled) {
                                if (!widget.rangeStartReadOnly) {
                                  _startDate = null;
                                }
                                _endDate = null;
                              }
                              if (!_multipleControlled) {
                                _dates = {};
                              }
                            });
                            switch (widget.mode) {
                              case SeedDatePickerMode.single:
                                widget.onValueChanged?.call(null);
                              case SeedDatePickerMode.range:
                                _notifyRange(
                                  widget.rangeStartReadOnly ? _startDate : null,
                                  null,
                                );
                              case SeedDatePickerMode.multiple:
                                widget.onDatesSelected?.call(
                                  List<DateTime>.unmodifiable([]),
                                );
                            }
                            widget.onReset?.call();
                          },
                    child: Text(_korean ? '초기화' : 'Reset'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
