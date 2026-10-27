import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

Widget host(Widget child) => MaterialApp(
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('date navigation is bounded and selected date has a full label', (
    tester,
  ) async {
    DateTime? picked;
    await tester.pumpWidget(
      host(
        SeedDatePicker(
          initialDate: DateTime(2026, 4, 12),
          firstDate: DateTime(2026, 4, 10),
          lastDate: DateTime(2026, 4, 20),
          onDateSelected: (day) => picked = day,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<IconButton>(find.byType(IconButton).at(0)).onPressed,
      isNull,
    );
    expect(
      tester.widget<IconButton>(find.byType(IconButton).at(1)).onPressed,
      isNull,
    );
    final expectedDisabledColor = SeedThemeData.light().colorScheme.fg.disabled;
    for (final button in tester.widgetList<IconButton>(
      find.byType(IconButton),
    )) {
      expect(button.disabledColor, expectedDisabledColor);
      expect((button.icon as Icon).color, isNull);
    }
    expect(find.text('2026년 4월'), findsOneWidget);
    final semantics = tester.ensureSemantics();
    expect(find.bySemanticsLabel('2026년 4월 12일'), findsOneWidget);
    await tester.tap(find.text('15'));
    expect(picked, DateTime(2026, 4, 15));
    semantics.dispose();
  });

  testWidgets('date picker clamps an initial month outside allowed range', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        SeedDatePicker(
          initialDate: DateTime(2025, 1, 1),
          firstDate: DateTime(2026, 4, 10),
          lastDate: DateTime(2026, 5, 10),
        ),
      ),
    );
    expect(find.text('2026년 4월'), findsOneWidget);
    await tester.tap(find.byTooltip('다음 달'));
    await tester.pumpAndSettle();
    expect(find.text('2026년 5월'), findsOneWidget);
    expect(
      tester.widget<IconButton>(find.byType(IconButton).at(1)).onPressed,
      isNull,
    );
  });

  testWidgets(
    'changing time step rebuilds wheel selection and reports valid minutes',
    (tester) async {
      TimeOfDay? changed;
      int step = 1;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () => setState(() => step = 15),
                  child: const Text('Step'),
                ),
                SeedTimePicker(
                  initialTime: const TimeOfDay(hour: 9, minute: 43),
                  minuteStep: step,
                  onChanged: (v) => changed = v,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.tap(find.text('Step'));
      await tester.pumpAndSettle();
      final picker = tester.widget<SeedWheelPicker>(
        find.byType(SeedWheelPicker),
      );
      expect(picker.columns.last.itemCount, 4);
      expect(picker.columns.last.initialIndex, 3);
      await tester.drag(
        find.byType(ListWheelScrollView).last,
        const Offset(0, 120),
      );
      await tester.pumpAndSettle();
      expect(changed, isNotNull);
      expect(changed!.minute % 15, 0);
      expect(changed!.minute, isNot(45));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'disabling an open select closes its popup and prevents changes',
    (tester) async {
      bool enabled = true;
      late StateSetter updateParent;
      final selected = <int>[];
      await tester.pumpWidget(
        host(
          SizedBox(
            width: 260,
            child: StatefulBuilder(
              builder: (context, setState) {
                updateParent = setState;
                return SeedSelect<int>(
                  enabled: enabled,
                  groups: const [
                    SeedSelectGroup<int>(
                      items: [
                        SeedSelectItem(value: 1, label: 'First option'),
                        SeedSelectItem(value: 2, label: 'Second option'),
                      ],
                    ),
                  ],
                  onChanged: selected.add,
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('선택해주세요'));
      await tester.pumpAndSettle();
      expect(find.text('First option'), findsOneWidget);
      final anchor = tester.widget<MenuAnchor>(find.byType(MenuAnchor));
      expect(anchor.controller!.isOpen, isTrue);

      updateParent(() => enabled = false);
      await tester.pumpAndSettle();
      expect(anchor.controller!.isOpen, isFalse);
      expect(find.text('First option'), findsNothing);
      expect(find.text('Second option'), findsNothing);

      // The disabled trigger cannot reopen with pointer or keyboard activation.
      await tester.tap(find.text('선택해주세요'));
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(anchor.controller!.isOpen, isFalse);
      expect(selected, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('updating value resynchronizes all three wheel positions', (
    tester,
  ) async {
    var value = const TimeOfDay(hour: 9, minute: 5);
    late StateSetter updateParent;
    final notifications = <TimeOfDay>[];
    await tester.pumpWidget(
      host(
        SizedBox(
          width: 280,
          child: StatefulBuilder(
            builder: (context, setState) {
              updateParent = setState;
              return SeedTimePicker(
                value: value,
                minuteStep: 10,
                onChanged: notifications.add,
              );
            },
          ),
        ),
      ),
    );

    List<int> positions() => tester
        .widgetList<ListWheelScrollView>(find.byType(ListWheelScrollView))
        .map(
          (wheel) =>
              (wheel.controller! as FixedExtentScrollController).selectedItem,
        )
        .toList();

    await tester.pumpAndSettle();
    expect(positions(), [0, 9, 0]); // 오전 9시 00분, 5분은 0분으로 반올림.

    updateParent(() => value = const TimeOfDay(hour: 15, minute: 54));
    await tester.pumpAndSettle();
    expect(positions(), [1, 3, 5]); // 오후 3시 50분.
    expect(
      notifications,
      isEmpty,
    ); // External input updates are not user edits.
    expect(tester.takeException(), isNull);
  });

  testWidgets('wheel rebuilds when columns are added, removed and resized', (
    tester,
  ) async {
    var counts = [5, 3];
    var positions = [4, 2];
    late StateSetter updateParent;
    await tester.pumpWidget(
      host(
        SizedBox(
          width: 280,
          child: StatefulBuilder(
            builder: (context, setState) {
              updateParent = setState;
              return SeedWheelPicker(
                columns: [
                  for (var i = 0; i < counts.length; i++)
                    SeedWheelColumn.typed<int>(
                      items: List.generate(counts[i], (index) => index),
                      initialIndex: positions[i],
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );

    List<int> selectedItems() => tester
        .widgetList<ListWheelScrollView>(find.byType(ListWheelScrollView))
        .map(
          (wheel) =>
              (wheel.controller! as FixedExtentScrollController).selectedItem,
        )
        .toList();

    await tester.pumpAndSettle();
    expect(selectedItems(), [4, 2]);
    updateParent(() {
      counts = [2];
      positions = [4]; // Clamped to last remaining item.
    });
    await tester.pumpAndSettle();
    expect(selectedItems(), [1]);
    updateParent(() {
      counts = [4, 6, 2];
      positions = [3, 5, 1];
    });
    await tester.pumpAndSettle();
    expect(selectedItems(), [3, 5, 1]);
    updateParent(() {
      counts = [];
      positions = [];
    });
    await tester.pumpAndSettle();
    expect(find.byType(ListWheelScrollView), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'resizing one wheel column preserves another scrolled selection',
    (tester) async {
      var secondColumnCount = 3;
      var secondColumnInitialIndex = 1;
      late StateSetter updateParent;
      await tester.pumpWidget(
        host(
          SizedBox(
            width: 280,
            child: StatefulBuilder(
              builder: (context, setState) {
                updateParent = setState;
                return SeedWheelPicker(
                  columns: [
                    SeedWheelColumn.typed<int>(
                      items: List.generate(5, (index) => index),
                      initialIndex: 1,
                    ),
                    SeedWheelColumn.typed<int>(
                      items: List.generate(secondColumnCount, (index) => index),
                      initialIndex: secondColumnInitialIndex,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      List<int> selectedItems() => tester
          .widgetList<ListWheelScrollView>(find.byType(ListWheelScrollView))
          .map(
            (wheel) =>
                (wheel.controller! as FixedExtentScrollController).selectedItem,
          )
          .toList();

      await tester.pumpAndSettle();
      expect(selectedItems(), [1, 1]);
      await tester.drag(
        find.byType(ListWheelScrollView).first,
        const Offset(0, -100),
      );
      await tester.pumpAndSettle();
      final firstUserSelection = selectedItems().first;
      expect(firstUserSelection, greaterThan(1));

      updateParent(() {
        secondColumnCount = 6;
        secondColumnInitialIndex = 5;
      });
      await tester.pumpAndSettle();
      expect(selectedItems(), [firstUserSelection, 5]);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'custom header dialog exposes dismiss action and Escape dismisses route',
    (tester) async {
      await tester.pumpWidget(
        host(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => showSeedDialog<void>(
                context: context,
                child: const SeedDialog(
                  header: Text('Custom header'),
                  content: Text('Body'),
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('닫기'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(SeedDialog), findsNothing);
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('닫기'));
      await tester.pumpAndSettle();
      expect(find.byType(SeedDialog), findsNothing);
    },
  );
}
