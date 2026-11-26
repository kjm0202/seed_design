import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';

// React 3.4.0's time-picker recipe end-aligns the hour column's items
// (`justify-content: flex-end`) so one-digit hours share a trailing edge with
// "10".."12", while the period and minute columns stay centered. These tests
// pin the painted geometry of the public widget. The Korean locale keeps the
// column order deterministic: period, hour, minute.

const _korean = Locale('ko');

Widget _host(Widget child, {TextDirection textDirection = TextDirection.ltr}) {
  return MaterialApp(
    locale: _korean,
    supportedLocales: const [_korean],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: SeedThemeData.light(fontFamily: seedTestFontFamily).toThemeData(),
    home: Directionality(
      textDirection: textDirection,
      child: Scaffold(
        body: Center(child: SizedBox(width: 360, child: child)),
      ),
    ),
  );
}

Widget _pickerAtOneOClock() =>
    const SeedTimePicker(value: TimeOfDay(hour: 1, minute: 0), locale: _korean);

Finder _wheel(int column) => find.byType(ListWheelScrollView).at(column);

/// Painted bounds of [label] inside [wheel].
///
/// A looping wheel can build the same label twice, so this picks the instance
/// closest to the wheel's vertical center instead of relying on build order.
Rect _labelRect(WidgetTester tester, Finder wheel, String label) {
  final matches = find.descendant(of: wheel, matching: find.text(label));
  expect(matches, findsWidgets, reason: 'Expected "$label" inside the wheel');
  final wheelCenterY = tester.getCenter(wheel).dy;
  Rect? nearest;
  for (var i = 0; i < matches.evaluate().length; i++) {
    final rect = tester.getRect(matches.at(i));
    if (nearest == null ||
        (rect.center.dy - wheelCenterY).abs() <
            (nearest.center.dy - wheelCenterY).abs()) {
      nearest = rect;
    }
  }
  return nearest!;
}

void main() {
  setUpAll(loadSeedTestFonts);

  testWidgets('hour labels share their trailing edge in LTR', (tester) async {
    await tester.pumpWidget(_host(_pickerAtOneOClock()));
    await tester.pumpAndSettle();

    final hourWheel = _wheel(1);
    final one = _labelRect(tester, hourWheel, '1');
    final twelve = _labelRect(tester, hourWheel, '12');

    expect(one.right, closeTo(twelve.right, 0.5));
    expect(one.left, greaterThan(twelve.left + 1));
  });

  testWidgets('hour labels share their trailing (left) edge in RTL', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(_pickerAtOneOClock(), textDirection: TextDirection.rtl),
    );
    await tester.pumpAndSettle();

    final hourWheel = _wheel(1);
    final one = _labelRect(tester, hourWheel, '1');
    final twelve = _labelRect(tester, hourWheel, '12');

    expect(one.left, closeTo(twelve.left, 0.5));
    expect(one.right, lessThan(twelve.right - 1));
  });

  testWidgets('period and minute labels stay centered in their columns', (
    tester,
  ) async {
    await tester.pumpWidget(_host(_pickerAtOneOClock()));
    await tester.pumpAndSettle();

    final periodWheel = _wheel(0);
    final minuteWheel = _wheel(2);
    expect(
      _labelRect(tester, periodWheel, '오전').center.dx,
      closeTo(tester.getCenter(periodWheel).dx, 0.5),
    );
    expect(
      _labelRect(tester, minuteWheel, '00').center.dx,
      closeTo(tester.getCenter(minuteWheel).dx, 0.5),
    );
    expect(tester.takeException(), isNull);
  });

  // The hour column relies on the wheel placing even custom-built items by the
  // column alignment, as React's full-width item row does with
  // `justify-content`.
  group('WheelPicker custom item builders follow the column alignment', () {
    const columnWidth = 120.0;
    const itemWidth = 40.0;
    const itemKey = Key('custom-wheel-item');

    Future<(Rect, Rect)> pumpColumn(
      WidgetTester tester,
      AlignmentGeometry alignment,
      TextDirection textDirection,
    ) async {
      await tester.pumpWidget(
        _host(
          Align(
            alignment: AlignmentDirectional.topStart,
            child: SeedWheelPicker(
              columns: [
                SeedWheelColumn.typed<int>(
                  items: const [1],
                  width: columnWidth,
                  alignment: alignment,
                  itemBuilder: (context, item, isSelected) => SizedBox(
                    key: itemKey,
                    width: itemWidth,
                    child: Text('$item'),
                  ),
                ),
              ],
            ),
          ),
          textDirection: textDirection,
        ),
      );
      await tester.pumpAndSettle();
      return (
        tester.getRect(find.byType(ListWheelScrollView)),
        tester.getRect(find.byKey(itemKey)),
      );
    }

    for (final direction in TextDirection.values) {
      testWidgets('centerEnd puts the item at the end edge ($direction)', (
        tester,
      ) async {
        final (wheel, item) = await pumpColumn(
          tester,
          AlignmentDirectional.centerEnd,
          direction,
        );
        expect(wheel.width, closeTo(columnWidth, 0.01));
        expect(item.width, closeTo(itemWidth, 0.01));
        if (direction == TextDirection.ltr) {
          expect(item.right, closeTo(wheel.right, 0.5));
        } else {
          expect(item.left, closeTo(wheel.left, 0.5));
        }
      });

      testWidgets('centerStart puts the item at the start edge ($direction)', (
        tester,
      ) async {
        final (wheel, item) = await pumpColumn(
          tester,
          AlignmentDirectional.centerStart,
          direction,
        );
        if (direction == TextDirection.ltr) {
          expect(item.left, closeTo(wheel.left, 0.5));
        } else {
          expect(item.right, closeTo(wheel.right, 0.5));
        }
      });
    }

    testWidgets('center keeps the item centered', (tester) async {
      final (wheel, item) = await pumpColumn(
        tester,
        Alignment.center,
        TextDirection.ltr,
      );
      expect(item.width, closeTo(itemWidth, 0.01));
      expect(item.center.dx, closeTo(wheel.center.dx, 0.5));
    });
  });
}
