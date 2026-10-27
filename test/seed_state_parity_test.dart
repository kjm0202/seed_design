import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

Widget host(Widget child) => MaterialApp(
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(body: child),
);
void main() {
  testWidgets(
    'snackbar pauses the remaining timeout while hovered and preserves queue',
    (tester) async {
      final controller = SeedSnackbarController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        host(
          SeedSnackbarProvider(
            controller: controller,
            child: const SizedBox.expand(),
          ),
        ),
      );
      controller.show(
        child: const SeedSnackbar(message: 'One'),
        duration: const Duration(seconds: 1),
      );
      controller.show(child: const SeedSnackbar(message: 'Two'));
      await tester.pumpAndSettle();
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: tester.getCenter(find.text('One')));
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('One'), findsOneWidget);
      await mouse.moveTo(const Offset(0, 0));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('One'), findsNothing);
      expect(find.text('Two'), findsOneWidget);
      await mouse.removePointer();
    },
  );
  testWidgets(
    'controlled wheel rejects a proposed edit and reports only one commit',
    (tester) async {
      final changes = <String>[];
      await tester.pumpWidget(
        host(
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
  testWidgets('uncontrolled quantity updates without an external callback', (
    tester,
  ) async {
    await tester.pumpWidget(host(const SeedQuantityPicker(defaultValue: 3)));
    await tester.tap(find.bySemanticsLabel('수량 늘리기'));
    await tester.pump();
    expect(find.text('4'), findsOneWidget);
  });
  testWidgets(
    'pagination hides trivial counts and reports external constraints once',
    (tester) async {
      final changes = <SeedPageChange>[];
      await tester.pumpWidget(
        host(SeedPagination(totalPages: 0, onPageChange: changes.add)),
      );
      expect(find.byType(InkWell), findsNothing);
      await tester.pumpWidget(
        host(
          SeedPagination(
            currentPage: 20,
            totalPages: 5,
            onPageChange: changes.add,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(changes.last.reason, SeedPageChangeReason.constraint);
      expect(changes.last.page, 5);
      expect(changes.last.previousPage, 20);
      expect(changes, hasLength(1));
    },
  );
  testWidgets('form reset restores text and grapheme counter', (tester) async {
    final form = GlobalKey<FormState>();
    await tester.pumpWidget(
      host(
        Form(
          key: form,
          child: const SeedTextField(
            defaultValue: 'Original',
            maxGraphemeCount: 20,
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'Changed');
    form.currentState!.reset();
    await tester.pump();
    expect(find.text('Original'), findsOneWidget);
  });
  testWidgets('refresh supports ready notification and prevents pulls', (
    tester,
  ) async {
    var refreshes = 0, ready = 0;
    final completion = Completer<void>();
    await tester.pumpWidget(
      host(
        SeedPullToRefresh(
          onRefresh: () {
            refreshes++;
            return completion.future;
          },
          onReady: () => ready++,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [SizedBox(height: 1000)],
          ),
        ),
      ),
    );
    await tester.drag(find.byType(ListView), const Offset(0, 900));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(ready, 1);
    expect(refreshes, 1);
    completion.complete();
    await tester.pumpAndSettle();
    await tester.pumpWidget(
      host(
        SeedPullToRefresh(
          preventPull: true,
          onRefresh: () async {
            refreshes++;
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [SizedBox(height: 1000)],
          ),
        ),
      ),
    );
    await tester.drag(find.byType(ListView), const Offset(0, 900));
    await tester.pumpAndSettle();
    expect(refreshes, 1);
  });
  testWidgets('range slider step and minimum thumb gap constrain commits', (
    tester,
  ) async {
    RangeValues? value, committed;
    await tester.pumpWidget(
      host(
        SeedSlider.range(
          defaultValues: const RangeValues(20, 60),
          step: 10,
          minStepsBetweenThumbs: 2,
          onChanged: (next) => value = next,
          onChangeEnd: (next) => committed = next,
        ),
      ),
    );
    final slider = tester.widget<RangeSlider>(find.byType(RangeSlider));
    slider.onChanged!(const RangeValues(55, 60));
    slider.onChangeEnd!(const RangeValues(55, 60));
    await tester.pump();
    expect(value, const RangeValues(40, 60));
    expect(committed, value);
  });
}
