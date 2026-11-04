import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';

const _longLabel =
    '새로운 메시지가 도착할 때마다 푸시 알림을 받을 수 있습니다. 언제든지 변경할 수 있어요. '
    '이 문장은 두 줄 이상으로 줄바꿈되어야 합니다.';

Widget _host(Widget child, {double width = 320}) => MaterialApp(
  locale: const Locale('ko'),
  supportedLocales: const [Locale('en'), Locale('ko')],
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: SeedThemeData.light(fontFamily: seedTestFontFamily).toThemeData(),
  home: Scaffold(
    body: Align(
      alignment: Alignment.topLeft,
      child: SizedBox(width: width, child: child),
    ),
  ),
);

void main() {
group('Checkbox / Radio: recipe align-items flex-start', () {
    testWidgets('a wrapped checkbox label keeps the mark on its first line', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          SeedCheckbox(value: false, onChanged: (_) {}, label: _longLabel),
        ),
      );
      final label = tester.getRect(find.text(_longLabel));
      final root = tester.getRect(find.byType(SeedCheckbox));
      final mark = tester.getRect(
        find.byType(SeedControlFocusRing).first,
      );
      expect(label.height, greaterThan(40), reason: 'label must wrap');
      // (32 - 20) / 2 = 6px from the root top, not centered on the label.
      expect(mark.top - root.top, moreOrLessEquals(6, epsilon: 0.5));
      expect(mark.center.dy, lessThan(label.center.dy - 8));
    });

    testWidgets('a wrapped radio label keeps the mark on its first line', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          SeedRadioGroup<String>(
            value: 'a',
            child: const SeedRadio<String>(value: 'a', label: _longLabel),
          ),
        ),
      );
      final label = tester.getRect(find.text(_longLabel));
      final root = tester.getRect(find.byType(SeedRadio<String>));
      final mark = tester.getRect(find.byType(SeedControlFocusRing).first);
      expect(label.height, greaterThan(40));
      expect(mark.top - root.top, moreOrLessEquals(6, epsilon: 0.5));
    });

    testWidgets('a single-line label is still centered within 32px', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(SeedCheckbox(value: true, onChanged: (_) {}, label: '사과')),
      );
      final root = tester.getRect(find.byType(SeedCheckbox));
      final mark = tester.getRect(find.byType(SeedControlFocusRing).first);
      final label = tester.getRect(find.text('사과'));
      expect(root.height, 32);
      expect(mark.center.dy, moreOrLessEquals(root.center.dy, epsilon: 0.5));
      expect(label.center.dy, moreOrLessEquals(root.center.dy, epsilon: 1));
    });
  });
}
