import 'dart:ui' show SemanticsAction, SemanticsActionEvent;

import 'package:flutter/semantics.dart'
    show SemanticsValidationResult, SemanticsNode;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';

Widget _app(Widget child) => MaterialApp(
  theme: SeedThemeData.light(fontFamily: seedTestFontFamily).toThemeData(),
  home: Scaffold(body: Center(child: child)),
);

Widget _appValues(Widget child, {bool scaffold = true}) => MaterialApp(
  theme: SeedThemeData.light(fontFamily: seedTestFontFamily).toThemeData(),
  home: scaffold ? Scaffold(body: Center(child: child)) : Center(child: child),
);

Widget host(Widget child) => MaterialApp(
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(body: child),
);

SemanticsNode? actionNode(SemanticsNode node, SemanticsAction action) {
  if (node.getSemanticsData().hasAction(action)) return node;
  SemanticsNode? found;
  node.visitChildren((child) {
    found = actionNode(child, action);
    return found == null;
  });
  return found;
}

Widget hostStateParity(Widget child) => MaterialApp(
  supportedLocales: const [Locale('en'), Locale('ko')],
  locale: const Locale('ko'),
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(body: child),
);

void main() {
  group('keyboard', () {
    setUpAll(loadSeedTestFonts);
    Future<List<double>> commits(
      WidgetTester tester, {
      int jumpMultiplier = 10,
    }) async {
      final commits = <double>[];
      await tester.pumpWidget(
        _app(
          SizedBox(
            width: 300,
            child: SeedSlider(
              defaultValues: const [50],
              jumpMultiplier: jumpMultiplier,
              onValuesCommit: (values) => commits.add(values.single),
            ),
          ),
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      return commits;
    }

    testWidgets('supports the official keyboard keys', (tester) async {
      final log = await commits(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
      expect(log.last, 60);
      await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
      expect(log.last, 50);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      expect(log.last, 60);
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      expect(log.last, 0);
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      expect(log.last, 100);
    });

    testWidgets('jumpMultiplier changes the page step', (tester) async {
      final log = await commits(tester, jumpMultiplier: 5);
      await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
      expect(log.last, 55);
    });
  });

  group('allowed values', () {
    setUpAll(loadSeedTestFonts);

    testWidgets('Slider arrow keys step through allowed values', (
      tester,
    ) async {
      final changes = <List<double>>[];
      final commits = <List<double>>[];
      await tester.pumpWidget(
        _appValues(
          SizedBox(
            width: 300,
            child: SeedSlider(
              defaultValues: const [50],
              allowedValues: const [0, 50, 100],
              onValuesChange: changes.add,
              onValuesCommit: commits.add,
            ),
          ),
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(changes, [
        [100.0],
      ]);
      expect(commits, [
        [100.0],
      ]);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(changes.last, [50.0]);
      expect(commits.last, [50.0]);
    });

    testWidgets('Slider pointer tap on allowed values snaps to the nearest', (
      tester,
    ) async {
      final changes = <List<double>>[];
      await tester.pumpWidget(
        _appValues(
          SizedBox(
            width: 300,
            child: SeedSlider(
              defaultValues: const [0],
              allowedValues: const [0, 10, 100],
              onValuesChange: changes.add,
            ),
          ),
        ),
      );
      final rect = tester.getRect(find.byType(SeedSlider));
      await tester.tapAt(Offset(rect.right - 30, rect.center.dy));
      await tester.pump();
      expect(changes, [
        [100.0],
      ]);
    });

    testWidgets('Slider keeps the step precision in values', (tester) async {
      final changes = <List<double>>[];
      await tester.pumpWidget(
        _appValues(
          SizedBox(
            width: 300,
            child: SeedSlider(
              min: 0,
              max: 1,
              step: 0.1,
              defaultValues: const [0.2],
              onValuesChange: changes.add,
            ),
          ),
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(changes, [
        [0.3],
      ]);
    });
  });
  group('validation, step and RTL', () {
    testWidgets('slider invalid propagates validation semantics', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        host(const SeedSlider(invalid: true, semanticsLabel: 'invalid slider')),
      );
      final node = tester.getSemantics(find.byType(Slider));
      expect(
        node.getSemanticsData().validationResult,
        SemanticsValidationResult.invalid,
      );
      semantics.dispose();
    });

    testWidgets(
      'slider explicit step and range accessibility use matching increments',
      (tester) async {
        final semantics = tester.ensureSemantics();
        await tester.pumpWidget(
          host(const SeedSlider(min: 0, max: 10, defaultValue: 4, step: 2)),
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();
        expect(tester.widget<Slider>(find.byType(Slider)).value, 6);
        final node = tester.getSemantics(find.byType(Slider));
        tester.binding.performSemanticsAction(
          SemanticsActionEvent(
            nodeId: actionNode(node, SemanticsAction.decrease)!.id,
            viewId: tester.view.viewId,
            type: SemanticsAction.decrease,
          ),
        );
        await tester.pump();
        expect(tester.widget<Slider>(find.byType(Slider)).value, 4);
        await tester.pumpWidget(
          host(
            const SeedSlider.range(
              min: 0,
              max: 10,
              defaultValues: RangeValues(3, 7),
            ),
          ),
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await tester.pump();
        expect(
          tester.widget<RangeSlider>(find.byType(RangeSlider)).values,
          const RangeValues(2, 7),
        );
        semantics.dispose();
      },
    );

    testWidgets('slider markers anchor to track positions in RTL', (
      tester,
    ) async {
      for (final align in SeedSliderMarkerAlign.values) {
        await tester.pumpWidget(
          host(
            Directionality(
              textDirection: TextDirection.rtl,
              child: SizedBox(
                width: 300,
                child: SeedSlider(
                  markers: [SeedSliderMarker(25, 'marker', align: align)],
                ),
              ),
            ),
          ),
        );
        final bounds = tester.getRect(find.text('marker'));
        final origin = tester.getTopLeft(find.byType(SeedSlider));
        final expected = origin.dx + 10 + .75 * (300 - 20);
        final anchor = switch (align) {
          SeedSliderMarkerAlign.start => bounds.right,
          SeedSliderMarkerAlign.center => bounds.center.dx,
          SeedSliderMarkerAlign.end => bounds.left,
        };
        expect(anchor, closeTo(expected, .01));
      }
    });

    testWidgets('slider default step supports keyboard decrement', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(const SeedSlider(min: 0, max: 10, defaultValue: 5)),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(tester.widget<Slider>(find.byType(Slider)).value, 4);
    });
  });

  group('range thumb gap', () {
    testWidgets('range slider step and minimum thumb gap constrain commits', (
      tester,
    ) async {
      RangeValues? value, committed;
      await tester.pumpWidget(
        hostStateParity(
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

    testWidgets('allowed values ignore the thumb gap like React', (
      tester,
    ) async {
      final changes = <List<double>>[];
      await tester.pumpWidget(
        _appValues(
          SizedBox(
            width: 300,
            child: SeedSlider.range(
              defaultValues: const RangeValues(0, 50),
              step: 10,
              allowedValues: const [0, 45, 50],
              minStepsBetweenThumbs: 1,
              jumpMultiplier: 1,
              onValuesChange: changes.add,
            ),
          ),
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
      await tester.pump();
      expect(changes, [
        [45.0, 50.0],
      ]);

      final slider = tester.widget<RangeSlider>(find.byType(RangeSlider));
      slider.onChanged!(const RangeValues(50, 50));
      await tester.pump();
      expect(changes.last, [50.0, 50.0]);
    });
  });
}
