// Isolated Flutter PUBLIC SeedWheelPicker consumer contract: controlled date
// boundary changes from 31-day month to 28-day month and back. This is not a
// React/Flutter browser parity result or an original INC resolution.

import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';
import 'support/seed_test_host.dart';

List<SemanticsNode> _nodes(WidgetTester tester) {
  final result = <SemanticsNode>[];
  void visit(SemanticsNode node) {
    result.add(node);
    node.visitChildren((child) {
      visit(child);
      return true;
    });
  }

  visit(
    tester.binding.renderViews.single.owner!.semanticsOwner!.rootSemanticsNode!,
  );
  return result;
}

void main() {
  group('keyboard and pointer', () {
    setUpAll(loadSeedTestFonts);

    Widget wheel(ValueChanged<int> onChange) => fontApp(
      SeedWheelPicker(
        columns: [
          SeedWheelColumn.value<int>(
            items: const [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
            defaultValue: 2,
            onValueChange: (value, _) => onChange(value),
          ),
        ],
      ),
    );

    testWidgets('WheelPicker moves four rows on PageDown and PageUp', (
      tester,
    ) async {
      final values = <int>[];
      await tester.pumpWidget(wheel(values.add));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
      await tester.pumpAndSettle();
      expect(values.last, 6);
      await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
      await tester.pumpAndSettle();
      expect(values.last, 2);
    });

    testWidgets('WheelPicker follows a mouse drag', (tester) async {
      await tester.pumpWidget(wheel((_) {}));
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(SeedWheelPicker)),
        kind: PointerDeviceKind.mouse,
      );
      for (var i = 0; i < 7; i++) {
        await gesture.moveBy(const Offset(0, -10));
        await tester.pump(const Duration(milliseconds: 16));
      }
      await gesture.up();
      await tester.pumpAndSettle();
      final scroller = tester.widget<ListWheelScrollView>(
        find.byType(ListWheelScrollView),
      );
      expect(
        (scroller.controller! as FixedExtentScrollController).selectedItem,
        isNot(2),
      );
    });
  });

  group('column widths', () {
    for (final flexibleCount in [1, 2]) {
      testWidgets(
        'Wheel fixed width leaves room for $flexibleCount flex columns',
        (tester) async {
          await tester.pumpWidget(
            seedAppSized(
              SeedWheelPicker(
                columns: [
                  SeedWheelColumn.typed<int>(items: [1], width: 100),
                  for (var i = 1; i <= flexibleCount; i++)
                    SeedWheelColumn.typed<int>(items: [1], flex: i),
                ],
              ),
            ),
          );
          final wheels = find.byType(ListWheelScrollView);
          expect(tester.getSize(wheels.first).width, closeTo(100, .01));
          final totalFlex = flexibleCount * (flexibleCount + 1) / 2;
          for (var i = 1; i <= flexibleCount; i++) {
            expect(
              tester.getSize(wheels.at(i)).width,
              closeTo(200 * i / totalFlex, .01),
            );
          }
          expect(tester.takeException(), isNull);
        },
      );
    }

    for (final width in [180.0, 500.0]) {
      testWidgets(
        'fixed Wheel columns stay centered and shrink only when needed at $width',
        (tester) async {
          await tester.pumpWidget(
            seedAppSized(
              SeedWheelPicker(
                columns: [
                  SeedWheelColumn.typed<int>(items: [1], width: 120),
                  SeedWheelColumn.typed<int>(items: [1], width: 80),
                ],
              ),
              width: width,
            ),
          );
          final wheels = find.byType(ListWheelScrollView);
          final first = tester.getRect(wheels.first);
          final second = tester.getRect(wheels.last);
          final ratio = width < 200 ? width / 200 : 1;
          expect(first.width, closeTo(120 * ratio, .01));
          expect(second.width, closeTo(80 * ratio, .01));
          expect(
            (first.left + second.right) / 2,
            closeTo(tester.getCenter(find.byType(SeedWheelPicker)).dx, .01),
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  });
  group('controlled range', () {
    for (final viewport in const [Size(800, 800), Size(390, 844)]) {
      testWidgets('controlled Wheel 31→28 day range and back $viewport', (
        tester,
      ) async {
        await tester.binding.setSurfaceSize(viewport);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        var month = 8;
        var day = 31;
        final changeEvents = <String>[];
        await tester.pumpWidget(
          MaterialApp(
            theme: SeedThemeData.light().toThemeData(),
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) => Column(
                  children: [
                    SizedBox(
                      width: 360,
                      child: SeedWheelPicker(
                        columns: [
                          SeedWheelColumn.value<int>(
                            items: [
                              for (var year = 2020; year <= 2030; year++) year,
                            ],
                            value: 2026,
                            semanticsLabel: '연도',
                            onValueChange: (value, _) =>
                                changeEvents.add('year=$value'),
                          ),
                          SeedWheelColumn.value<int>(
                            items: [for (var m = 1; m <= 12; m++) m],
                            value: month,
                            loop: true,
                            semanticsLabel: '월',
                            onValueChange: (value, _) =>
                                changeEvents.add('month=$value'),
                          ),
                          SeedWheelColumn.value<int>(
                            items: [
                              for (var d = 1; d <= (month == 2 ? 28 : 31); d++)
                                d,
                            ],
                            value: day,
                            loop: true,
                            semanticsLabel: '일',
                            onValueChange: (value, _) =>
                                changeEvents.add('day=$value'),
                          ),
                        ],
                      ),
                    ),
                    SeedButton(
                      key: const ValueKey('to-feb'),
                      label: '2월로 변경',
                      onPressed: () => setState(() {
                        month = 2;
                        if (day > 28) day = 28;
                      }),
                    ),
                    SeedButton(
                      key: const ValueKey('to-aug'),
                      label: '8월로 변경',
                      onPressed: () => setState(() => month = 8),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        List<int> indexes() => tester
            .widgetList<ListWheelScrollView>(find.byType(ListWheelScrollView))
            .map(
              (w) =>
                  (w.controller! as FixedExtentScrollController).selectedItem,
            )
            .toList();

        await tester.pumpAndSettle();
        expect(indexes(), [
          6,
          7,
          30,
        ], reason: '2026-08-31 initial public value');
        expect(
          changeEvents,
          isEmpty,
          reason: 'mount does not simulate user edit',
        );

        await tester.tap(find.byKey(const ValueKey('to-feb')));
        await tester.pumpAndSettle();
        expect(indexes(), [
          6,
          1,
          27,
        ], reason: 'Feb 2026 has 28 days; day 31 clamps to 28');
        expect(
          changeEvents,
          isEmpty,
          reason: 'parent-controlled update is not user wheel input',
        );

        await tester.tap(find.byKey(const ValueKey('to-aug')));
        await tester.pumpAndSettle();
        expect(indexes(), [
          6,
          7,
          27,
        ], reason: 're-expand 31-day options; preserve selected day 28');
        expect(
          changeEvents,
          isEmpty,
          reason: 'no spurious callback on range expansion',
        );
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('accessibility', () {
    for (final width in [390.0, 800.0]) {
      testWidgets(
        'wheel exposes one named adjustable value per column $width',
        (tester) async {
          tester.view.physicalSize = Size(width, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          final handle = tester.ensureSemantics();
          final changes = <int>[];
          await tester.pumpWidget(
            seedAppNarrow(
              SeedWheelPicker(
                columns: [
                  SeedWheelColumn.value<int>(
                    items: List.generate(12, (i) => i + 1),
                    defaultValue: 8,
                    semanticsLabel: '월',
                    semanticsValueFormatter: (month) => '$month월',
                    loop: true,
                    onValueChange: (month, _) => changes.add(month),
                  ),
                ],
              ),
            ),
          );
          await tester.pumpAndSettle();
          final adjustable = _nodes(tester)
              .where(
                (node) =>
                    node.getSemanticsData().hasAction(SemanticsAction.increase),
              )
              .toList();
          expect(
            adjustable,
            hasLength(1),
            reason: 'The scroll view must not expose a second unlabeled slider',
          );
          final data = adjustable.single.getSemanticsData();
          expect(data.label, '월');
          expect(data.value, '8월');
          expect(data.flagsCollection.isSlider, isTrue);
          expect(data.increasedValue, '9월');
          tester.binding.renderViews.single.owner!.semanticsOwner!
              .performAction(adjustable.single.id, SemanticsAction.increase);
          await tester.pumpAndSettle();
          expect(changes, [9]);
          expect(tester.getSemantics(find.bySemanticsLabel('월')).value, '9월');
          handle.dispose();
        },
      );

      testWidgets(
        'external wheel value and option count retain keyboard focus $width',
        (tester) async {
          tester.view.physicalSize = Size(width, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          var value = 20;
          var count = 31;
          late StateSetter update;
          final changes = <int>[];
          await tester.pumpWidget(
            seedAppNarrow(
              StatefulBuilder(
                builder: (context, setState) {
                  update = setState;
                  return SeedWheelPicker(
                    columns: [
                      SeedWheelColumn.value<int>(
                        items: List.generate(count, (i) => i + 1),
                        value: value,
                        semanticsLabel: '일',
                        onValueChange: (next, _) {
                          changes.add(next);
                          setState(() => value = next);
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          );
          await tester.pumpAndSettle();
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pump();
          final focus = FocusManager.instance.primaryFocus;
          expect(focus?.context, isNotNull);
          update(() {
            value = 21;
            count = 28;
          });
          await tester.pumpAndSettle();
          expect(
            FocusManager.instance.primaryFocus,
            same(focus),
            reason:
                'Updating a controlled value must preserve the column actor',
          );
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
          await tester.pumpAndSettle();
          expect(changes, [22]);
          expect(value, 22);
        },
      );
    }
  });

  group('settling and sizing', () {
    testWidgets('wheel taps settle once and disabled wheels keep their value', (
      tester,
    ) async {
      final changes = <int>[];
      var enabled = true;
      late StateSetter update;
      await tester.pumpWidget(
        koreanAppCentered(
          StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return SizedBox(
                width: 220,
                child: SeedWheelPicker(
                  enabled: enabled,
                  columns: [
                    SeedWheelColumn.typed(
                      items: List.generate(20, (i) => 'Value $i'),
                      initialIndex: 5,
                      onChanged: changes.add,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
      await tester.tap(find.text('Value 6'));
      expect(changes, isEmpty);
      await tester.pumpAndSettle();
      expect(changes, [6]);
      update(() => enabled = false);
      await tester.pumpAndSettle();
      await tester.drag(find.byType(SeedWheelPicker), const Offset(0, -150));
      await tester.pumpAndSettle();
      final wheel = tester.widget<ListWheelScrollView>(
        find.byType(ListWheelScrollView),
      );
      expect(
        (wheel.controller! as FixedExtentScrollController).selectedItem,
        6,
      );
      expect(changes, [6]);

      update(() => enabled = true);
      await tester.pumpAndSettle();
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(SeedWheelPicker)),
      );
      await gesture.moveBy(const Offset(0, -20));
      await tester.pump(const Duration(milliseconds: 50));
      await gesture.moveBy(const Offset(0, -100));
      await tester.pump(const Duration(milliseconds: 50));
      expect(changes, [6]);
      update(() => enabled = false);
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
      expect(
        (wheel.controller! as FixedExtentScrollController).selectedItem,
        6,
      );
      expect(changes, [6]);
    });

    testWidgets('custom wheel extent is preserved and limits fog', (
      tester,
    ) async {
      await tester.pumpWidget(
        koreanAppCentered(
          SizedBox(
            width: 220,
            child: SeedWheelPicker(
              size: SeedWheelPickerSize.small,
              height: 400,
              columns: [
                SeedWheelColumn.typed(items: ['A', 'B', 'C'], itemExtent: 30),
              ],
            ),
          ),
        ),
      );
      expect(
        tester
            .widget<ListWheelScrollView>(find.byType(ListWheelScrollView))
            .itemExtent,
        30,
      );
      expect(
        tester.widget<SeedScrollFogMask>(find.byType(SeedScrollFogMask)).size,
        90,
      );
    });

    testWidgets('wheel commits once after scrolling settles', (tester) async {
      final changes = <int>[];
      await tester.pumpWidget(
        koreanAppCentered(
          SizedBox(
            width: 220,
            child: SeedWheelPicker(
              columns: [
                SeedWheelColumn.typed(
                  items: List.generate(30, (i) => i),
                  onChanged: changes.add,
                ),
              ],
            ),
          ),
        ),
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(ListWheelScrollView)),
      );
      await gesture.moveBy(const Offset(0, -20));
      await tester.pump(const Duration(milliseconds: 50));
      await gesture.moveBy(const Offset(0, -140));
      await tester.pump(const Duration(milliseconds: 100));
      expect(changes, isEmpty);
      await gesture.up();
      await tester.pumpAndSettle();
      final wheel = tester.widget<ListWheelScrollView>(
        find.byType(ListWheelScrollView),
      );
      expect(changes, [
        (wheel.controller! as FixedExtentScrollController).selectedItem,
      ]);
    });

    testWidgets('small wheel inherits row extent and font from picker size', (
      tester,
    ) async {
      await tester.pumpWidget(
        koreanAppCentered(
          SizedBox(
            width: 220,
            child: SeedWheelPicker(
              size: SeedWheelPickerSize.small,
              columns: [
                SeedWheelColumn.typed(items: ['A', 'B', 'C']),
              ],
            ),
          ),
        ),
      );
      expect(
        tester
            .widget<ListWheelScrollView>(find.byType(ListWheelScrollView))
            .itemExtent,
        36,
      );
      expect(
        tester.widget<Text>(find.text('A')).style!.fontSize,
        SeedThemeData.light().typography.t7Medium.fontSize,
      );
    });
  });

  group('columns', () {
    testWidgets('wheel rebuilds when columns are added, removed and resized', (
      tester,
    ) async {
      var counts = [5, 3];
      var positions = [4, 2];
      late StateSetter updateParent;
      await tester.pumpWidget(
        koreanAppCentered(
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
          koreanAppCentered(
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
                        items: List.generate(
                          secondColumnCount,
                          (index) => index,
                        ),
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
              (wheel) => (wheel.controller! as FixedExtentScrollController)
                  .selectedItem,
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
  });

  group('controlled rejection', () {
    testWidgets(
      'controlled wheel rejects a proposed edit and reports only one commit',
      (tester) async {
        final changes = <String>[];
        await tester.pumpWidget(
          koreanApp(
            SeedWheelPicker(
              columns: [
                SeedWheelColumn.value(
                  items: ['A', 'B'],
                  value: 'A',
                  onValueChanged: changes.add,
                ),
              ],
            ),
          ),
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        expect(changes, ['B']);
        final wheel = tester.widget<ListWheelScrollView>(
          find.byType(ListWheelScrollView),
        );
        expect(
          (wheel.controller! as FixedExtentScrollController).selectedItem,
          0,
        );
      },
    );
  });

  group('keyboard commit', () {
    testWidgets(
      'wheel keyboard commits once and readonly preserves focus without edits',
      (tester) async {
        final changes = <int>[];
        await tester.pumpWidget(
          koreanAppNarrow(
            SeedWheelPicker(
              columns: [
                SeedWheelColumn.typed(
                  items: ['A', 'B', 'C'],
                  initialIndex: 1,
                  semanticsLabel: 'Letter',
                  onChanged: changes.add,
                ),
              ],
            ),
          ),
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        expect(changes, [2]);
        await tester.pumpWidget(
          koreanAppNarrow(
            SeedWheelPicker(
              readOnly: true,
              columns: [
                SeedWheelColumn.typed(
                  items: ['A', 'B', 'C'],
                  initialIndex: 2,
                  onChanged: changes.add,
                ),
              ],
            ),
          ),
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.home);
        await tester.pumpAndSettle();
        expect(changes, [2]);
      },
    );
  });

  group('committed value across reorder and reduced motion', () {
    Widget host(Widget child, {bool reduceMotion = false}) => MaterialApp(
      theme: SeedThemeData.light().toThemeData(),
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduceMotion),
        child: Scaffold(
          body: Center(child: SizedBox(width: 300, child: child)),
        ),
      ),
    );

    int selectedItem(WidgetTester tester) =>
        (tester
                    .widget<ListWheelScrollView>(
                      find.byType(ListWheelScrollView),
                    )
                    .controller!
                as FixedExtentScrollController)
            .selectedItem;
    testWidgets('reordering a moving wheel keeps the last committed value', (
      tester,
    ) async {
      var items = ['A', 'B', 'C', 'D'];
      final changes = <String>[];
      final steps = <String>[];
      late StateSetter update;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (_, setState) {
              update = setState;
              return SeedWheelPicker(
                columns: [
                  SeedWheelColumn.value(
                    items: items,
                    onValueChange: (value, _) => changes.add(value),
                    onIndexChange: (_, value) => steps.add(value),
                  ),
                ],
              );
            },
          ),
        ),
      );
      final wheel = find.byType(ListWheelScrollView);
      final extent = tester.widget<ListWheelScrollView>(wheel).itemExtent;
      final gesture = await tester.startGesture(tester.getCenter(wheel));
      await gesture.moveBy(const Offset(0, -20));
      await gesture.moveBy(Offset(0, -extent * 1.4));
      await tester.pump();
      expect(steps, isNotEmpty);
      expect(changes, isEmpty);
      update(() => items = ['D', 'C', 'A', 'B']);
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
      expect(selectedItem(tester), 2);
      expect(changes, isEmpty);
    });

    testWidgets(
      'value selection follows an in-place options reorder and removal',
      (tester) async {
        final items = ['A', 'B', 'C'];
        final changes = <String>[];
        late StateSetter update;
        await tester.pumpWidget(
          host(
            StatefulBuilder(
              builder: (context, setState) {
                update = setState;
                return SeedWheelPicker(
                  columns: [
                    SeedWheelColumn.value(
                      items: items,
                      defaultValue: items.contains('B') ? 'B' : null,
                      onValueChange: (value, _) => changes.add(value),
                    ),
                  ],
                );
              },
            ),
          ),
        );
        expect(selectedItem(tester), 1);
        update(() {
          items.insert(0, items.removeLast());
        });
        await tester.pumpAndSettle();
        expect(selectedItem(tester), 2); // B
        expect(changes, isEmpty);
        update(() {
          items.remove('B');
        });
        await tester.pumpAndSettle();
        expect(selectedItem(tester), 0); // first remaining option
        expect(changes, isEmpty);
      },
    );

    testWidgets(
      'reduced motion moves keyboard and tapped options immediately',
      (tester) async {
        final changes = <String>[];
        await tester.pumpWidget(
          host(
            SeedWheelPicker(
              columns: [
                SeedWheelColumn.value(
                  items: const ['A', 'B', 'C', 'D'],
                  onValueChange: (value, _) => changes.add(value),
                ),
              ],
            ),
            reduceMotion: true,
          ),
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pump();
        expect(selectedItem(tester), 1);
        expect(changes, ['B']);
        await tester.tap(find.text('C'));
        await tester.pump();
        expect(selectedItem(tester), 2);
        expect(changes, ['B', 'C']);
      },
    );

    for (final constraint in [
      'column disabled',
      'column read-only',
      'root read-only',
    ]) {
      testWidgets('$constraint cancels movement at the committed value', (
        tester,
      ) async {
        var constrained = false;
        late StateSetter update;
        final changes = <String>[];
        await tester.pumpWidget(
          host(
            StatefulBuilder(
              builder: (context, setState) {
                update = setState;
                return SeedWheelPicker(
                  readOnly: constraint == 'root read-only' && constrained,
                  columns: [
                    SeedWheelColumn.value(
                      items: const ['A', 'B', 'C', 'D'],
                      enabled: constraint != 'column disabled' || !constrained,
                      readOnly: constraint == 'column read-only' && constrained,
                      onValueChange: (value, _) => changes.add(value),
                    ),
                  ],
                );
              },
            ),
          ),
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyEvent(LogicalKeyboardKey.end);
        await tester.pump(const Duration(milliseconds: 100));
        update(() => constrained = true);
        await tester.pumpAndSettle();
        expect(selectedItem(tester), 0);
        expect(changes, isEmpty);
        update(() => constrained = false);
        await tester.pumpAndSettle();
        expect(selectedItem(tester), 0);
      });
    }
  });
}
