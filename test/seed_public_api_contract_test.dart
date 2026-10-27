import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

Widget host(Widget child) => MaterialApp(
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(
    body: Center(child: SizedBox(width: 360, child: child)),
  ),
);

void main() {
  test(
    'canonical default names support const construction and legacy aliases',
    () {
      const text = SeedTextInput(defaultValue: 'Text');
      expect(text.defaultValue, 'Text');
      expect(text.initialValue, 'Text');
      const select = SeedSelect<int>(groups: [], defaultValues: {1});
      expect(select.initialValues, {1});
      const attachment = SeedAttachmentDisplayField(
        defaultEntries: [SeedAttachmentItem(id: 'entry')],
      );
      expect(attachment.initialEntries.single.id, 'entry');
      const time = SeedTimePicker(
        defaultValue: TimeOfDay(hour: 12, minute: 30),
      );
      expect(time.initialTime, time.defaultValue);
      final date = DateTime(2026, 4, 10);
      final calendar = SeedDatePicker(
        defaultValue: date,
        defaultRangeValue: SeedDateRange(start: date),
        defaultValues: [date],
      );
      expect(calendar.initialDate, date);
      expect(calendar.defaultRangeValue!.start, date);
      expect(calendar.initialDates, [date]);
      final legacy = SeedDatePicker(initialStartDate: date);
      expect(legacy.defaultRangeValue!.start, date);
    },
  );

  test('text and attachment controllers have one source of truth', () {
    final text = TextEditingController();
    final attachments = SeedAttachmentController();
    addTearDown(text.dispose);
    addTearDown(attachments.dispose);
    expect(
      () => SeedTextInput(controller: text, value: 'conflict'),
      throwsAssertionError,
    );
    expect(
      () => SeedTextInput.textarea(controller: text, defaultValue: 'conflict'),
      throwsAssertionError,
    );
    expect(
      () => SeedTextField(controller: text, value: 'conflict'),
      throwsAssertionError,
    );
    expect(
      () => SeedTextField.textarea(controller: text, defaultValue: 'conflict'),
      throwsAssertionError,
    );
    expect(
      () => SeedAttachmentDisplayField(
        controller: attachments,
        entries: const [],
      ),
      throwsAssertionError,
    );
    expect(
      () => SeedSelect<int>(
        groups: const [],
        defaultValues: const {1},
        initialValues: const {2},
      ),
      throwsAssertionError,
    );
  });

  testWidgets(
    'controlled FormField preserves null, accepted updates and reset',
    (tester) async {
      final field = GlobalKey<FormFieldState<String>>();
      final form = GlobalKey<FormState>();
      final proposals = <String?>[];
      String? value;
      late StateSetter update;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return Form(
                key: form,
                child: SeedFormField<String>(
                  key: field,
                  controlled: true,
                  value: value,
                  initialValue: 'ignored seed',
                  onValueChanged: proposals.add,
                  builder: (state) => Text(state.value ?? 'empty'),
                ),
              );
            },
          ),
        ),
      );
      expect(field.currentState!.value, isNull);
      field.currentState!.didChange('proposal');
      await tester.pump();
      expect(proposals, ['proposal']);
      expect(field.currentState!.value, isNull);
      update(() => value = 'accepted');
      await tester.pump();
      expect(field.currentState!.value, 'accepted');
      field.currentState!.didChange('rejected');
      form.currentState!.reset();
      await tester.pump();
      expect(field.currentState!.value, 'accepted');
      update(() => value = null);
      await tester.pump();
      expect(field.currentState!.value, isNull);
      expect(proposals, ['proposal', 'rejected']);
    },
  );

  testWidgets('controlled empty radio group rejects proposals', (tester) async {
    final proposals = <String?>[];
    await tester.pumpWidget(
      host(
        SeedRadioGroup<String>(
          controlled: true,
          defaultValue: 'a',
          onChanged: proposals.add,
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SeedRadio(value: 'a', label: 'Alpha'),
              SeedRadio(value: 'b', label: 'Beta'),
            ],
          ),
        ),
      ),
    );
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.text('Beta'));
      await tester.pump();
      expect(
        tester
            .widget<RadioGroup<String>>(find.byType(RadioGroup<String>))
            .groupValue,
        isNull,
      );
    }
    expect(proposals, ['b', 'b']);
  });

  testWidgets('controlled empty card group accepts only parent updates', (
    tester,
  ) async {
    final proposals = <Object?>[];
    Object? value;
    late StateSetter update;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return SeedSelectBoxGroup(
              controlled: true,
              value: value,
              defaultValue: 'a',
              onValueChanged: proposals.add,
              children: const [
                SeedSelectBox(value: 'a', title: 'Alpha'),
                SeedSelectBox(value: 'b', title: 'Beta'),
              ],
            );
          },
        ),
      ),
    );
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.text('Beta'));
      await tester.pumpAndSettle();
    }
    expect(proposals, ['b', 'b']);
    update(() => value = 'b');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Beta'));
    expect(proposals, hasLength(2));
    update(() => value = null);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Beta'));
    await tester.pumpAndSettle();
    expect(proposals, ['b', 'b', 'b']);
  });

  testWidgets('segmented control supports an authoritative empty selection', (
    tester,
  ) async {
    final proposals = <String>[];
    await tester.pumpWidget(
      host(
        SeedSegmentedControl<String>(
          controlled: true,
          defaultValue: 'a',
          segments: const [
            SeedSegment(value: 'a', label: 'Alpha'),
            SeedSegment(value: 'b', label: 'Beta'),
          ],
          onValueChanged: proposals.add,
        ),
      ),
    );
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.text('Beta'));
      await tester.pumpAndSettle();
    }
    expect(proposals, ['b', 'b']);
  });

  for (final mode in SeedDatePickerMode.values) {
    testWidgets('calendar $mode rejects proposals while controlled and empty', (
      tester,
    ) async {
      final single = <DateTime?>[];
      final ranges = <(DateTime?, DateTime?)>[];
      final multiple = <List<DateTime>>[];
      final cells = <int, SeedDateCellInfo>{};
      final seed = DateTime(2026, 4, 1);
      await tester.pumpWidget(
        host(
          SeedDatePicker(
            mode: mode,
            controlled: true,
            defaultViewDate: seed,
            defaultValue: seed,
            defaultRangeValue: SeedDateRange(start: seed),
            defaultValues: [seed],
            onValueChanged: single.add,
            onRangeSelected: (start, end) => ranges.add((start, end)),
            onDatesSelected: multiple.add,
            dateCellContent: (context, info) {
              cells[info.date.day] = info;
              return Text('day ${info.date.day}');
            },
          ),
        ),
      );
      expect(cells.values.any((cell) => cell.selected), isFalse);
      await tester.tap(find.text('day 10'));
      await tester.pump();
      await tester.tap(find.text('day 20'));
      await tester.pump();
      expect(cells.values.any((cell) => cell.selected), isFalse);
      switch (mode) {
        case SeedDatePickerMode.single:
          expect(single, [DateTime(2026, 4, 10), DateTime(2026, 4, 20)]);
        case SeedDatePickerMode.range:
          expect(ranges, [
            (DateTime(2026, 4, 10), null),
            (DateTime(2026, 4, 20), null),
          ]);
        case SeedDatePickerMode.multiple:
          expect(multiple, [
            [DateTime(2026, 4, 10)],
            [DateTime(2026, 4, 20)],
          ]);
          expect(() => multiple.last.clear(), throwsUnsupportedError);
      }
    });
  }

  for (final mode in SeedDatePickerMode.values) {
    testWidgets(
      'calendar $mode accepts parent values and clears back to null',
      (tester) async {
        final day = DateTime(2026, 4, 10);
        var filled = true;
        late StateSetter update;
        final cells = <int, SeedDateCellInfo>{};
        await tester.pumpWidget(
          host(
            StatefulBuilder(
              builder: (context, setState) {
                update = setState;
                return SeedDatePicker(
                  mode: mode,
                  controlled: true,
                  defaultViewDate: day,
                  value: filled ? day : null,
                  rangeValue: filled
                      ? SeedDateRange(start: day, end: DateTime(2026, 4, 12))
                      : null,
                  values: filled ? [day] : null,
                  dateCellContent: (context, info) {
                    cells[info.date.day] = info;
                    return Text('day ${info.date.day}');
                  },
                );
              },
            ),
          ),
        );
        expect(cells[10]!.selected, isTrue);
        update(() => filled = false);
        await tester.pump();
        expect(cells.values.any((cell) => cell.selected), isFalse);
      },
    );
  }

  testWidgets('calendar defaults are one-time seeds, parent values can clear', (
    tester,
  ) async {
    DateTime? value;
    var seed = DateTime(2026, 4, 1);
    var controlled = false;
    late StateSetter update;
    final cells = <int, SeedDateCellInfo>{};
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return SeedDatePicker(
              controlled: controlled,
              value: value,
              defaultValue: seed,
              dateCellContent: (context, info) {
                cells[info.date.day] = info;
                return Text('day ${info.date.day}');
              },
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('day 10'));
    await tester.pump();
    update(() => seed = DateTime(2026, 4, 20));
    await tester.pump();
    expect(cells[10]!.selected, isTrue);
    expect(cells[20]!.selected, isFalse);
    update(() {
      controlled = true;
      value = DateTime(2026, 4, 15);
    });
    await tester.pump();
    expect(cells[15]!.selected, isTrue);
    update(() => value = null);
    await tester.pump();
    expect(cells.values.any((cell) => cell.selected), isFalse);
  });

  testWidgets('controlled multiple select does not commit a local set', (
    tester,
  ) async {
    final proposals = <Set<int>>[];
    await tester.pumpWidget(
      host(
        SeedSelect<int>(
          multiple: true,
          controlled: true,
          defaultValues: const {2},
          onValuesChanged: proposals.add,
          groups: const [
            SeedSelectGroup(
              items: [
                SeedSelectItem(value: 1, label: 'Apple'),
                SeedSelectItem(value: 2, label: 'Pear'),
              ],
            ),
          ],
        ),
      ),
    );
    expect(
      tester.widget<SeedInputButton>(find.byType(SeedInputButton)).value,
      '',
    );
    await tester.tap(find.text('선택해주세요'));
    await tester.pumpAndSettle();
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.text('Apple'));
      await tester.pumpAndSettle();
    }
    expect(proposals, [
      {1},
      {1},
    ]);
    expect(
      tester.widget<SeedInputButton>(find.byType(SeedInputButton)).value,
      '',
    );
    expect(() => proposals.last.add(2), throwsUnsupportedError);
  });

  testWidgets(
    'time defaults do not overwrite edits on rebuild or locale change',
    (tester) async {
      var seed = const TimeOfDay(hour: 9, minute: 0);
      var locale = const Locale('en', 'US');
      late StateSetter update;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return SeedTimePicker(
                defaultValue: seed,
                locale: locale,
                hourSemanticsLabel: 'hour',
              );
            },
          ),
        ),
      );
      SeedWheelColumn hour() => tester
          .widget<SeedWheelPicker>(find.byType(SeedWheelPicker))
          .columns
          .singleWhere((column) => column.semanticsLabel == 'hour');
      hour().onStepChanged!(10, 1);
      await tester.pump();
      expect(hour().initialIndex, 10);
      update(() {
        seed = const TimeOfDay(hour: 16, minute: 0);
        locale = const Locale('ko', 'KR');
      });
      await tester.pump();
      expect(hour().initialIndex, 10);
    },
  );

  testWidgets('selectedIndex takes precedence over a tabs controller', (
    tester,
  ) async {
    final controller = SeedTabsController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      host(
        SeedTabsView(
          selectedIndex: 0,
          controller: controller,
          items: const [
            SeedTabItem(label: 'Alpha'),
            SeedTabItem(label: 'Beta'),
          ],
          children: const [Text('Page A'), Text('Page B')],
        ),
      ),
    );
    controller.animateTo(1);
    await tester.pumpAndSettle();
    expect(find.text('Page A').hitTestable(), findsOneWidget);
    expect(find.text('Page B').hitTestable(), findsNothing);
  });

  testWidgets(
    'external text controller updates validation and reset without edit callbacks',
    (tester) async {
      final controller = TextEditingController(text: 'initial');
      addTearDown(controller.dispose);
      final form = GlobalKey<FormState>();
      final edits = <String>[];
      String? saved;
      await tester.pumpWidget(
        host(
          Form(
            key: form,
            child: SeedTextField(
              controller: controller,
              validator: (value) => value == controller.text ? null : 'stale',
              onChanged: edits.add,
              onSaved: (value) => saved = value,
            ),
          ),
        ),
      );
      controller.text = 'external';
      await tester.pump();
      expect(form.currentState!.validate(), isTrue);
      form.currentState!.save();
      expect(saved, 'external');
      expect(edits, isEmpty);
      form.currentState!.reset();
      await tester.pump();
      expect(controller.text, 'initial');
      expect(form.currentState!.validate(), isTrue);
      await tester.pumpWidget(host(const SizedBox()));
      // The widget does not dispose a caller-owned controller.
      controller.text = 'still usable';
    },
  );

  testWidgets(
    'controlled select reports reasons and keeps rejected dismissal open',
    (tester) async {
      final events = <(bool, SeedOverlayDismissReason)>[];
      final visibility = <bool>[];
      var open = true;
      late StateSetter update;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return SeedSelect<int>(
                open: open,
                onOpenChanged: (next, reason) => events.add((next, reason)),
                onOpenStateChanged: visibility.add,
                groups: const [
                  SeedSelectGroup(
                    items: [SeedSelectItem(value: 1, label: 'Apple')],
                  ),
                ],
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apple'));
      await tester.pumpAndSettle();
      expect(events.last, (false, SeedOverlayDismissReason.action));
      expect(
        tester.widget<MenuAnchor>(find.byType(MenuAnchor)).controller!.isOpen,
        isTrue,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(events.last, (false, SeedOverlayDismissReason.escapeKey));
      expect(
        tester.widget<MenuAnchor>(find.byType(MenuAnchor)).controller!.isOpen,
        isTrue,
      );
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(events.last, (false, SeedOverlayDismissReason.outside));
      expect(
        tester.widget<MenuAnchor>(find.byType(MenuAnchor)).controller!.isOpen,
        isTrue,
      );
      expect(visibility, [false, false, false]);
      update(() => open = false);
      await tester.pumpAndSettle();
      expect(
        tester.widget<MenuAnchor>(find.byType(MenuAnchor)).controller!.isOpen,
        isFalse,
      );
      expect(events, hasLength(3));
    },
  );

  testWidgets('tooltip visibility uses the same reason-bearing callback', (
    tester,
  ) async {
    final events = <(bool, SeedOverlayDismissReason)>[];
    await tester.pumpWidget(
      host(
        SeedHelpBubbleTooltip(
          open: false,
          openDelay: Duration.zero,
          closeDelay: Duration.zero,
          title: 'Tooltip',
          onOpenChanged: (open, reason) => events.add((open, reason)),
          child: const Text('Hover me'),
        ),
      ),
    );
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: tester.getCenter(find.text('Hover me')));
    await tester.pumpAndSettle();
    expect(events, [(true, SeedOverlayDismissReason.trigger)]);
    expect(find.text('Tooltip'), findsNothing);
    await mouse.removePointer();
    await tester.pumpAndSettle();
    expect(events, hasLength(1));
  });
}
