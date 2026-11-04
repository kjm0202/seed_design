import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';

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
group('RadioGroup field composition', () {
    testWidgets('description renders in the footer below the options', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          SeedRadioGroup<String>(
            label: '선호하는 연락 방법',
            description: '연락 받고 싶은 방법을 선택해주세요.',
            value: 'email',
            child: const Column(
              children: [
                SeedRadio<String>(value: 'email', label: '이메일'),
                SeedRadio<String>(value: 'sms', label: '문자'),
              ],
            ),
          ),
        ),
      );
      final label = tester.getRect(find.text('선호하는 연락 방법'));
      final lastOption = tester.getRect(find.text('문자'));
      final description = tester.getRect(find.text('연락 받고 싶은 방법을 선택해주세요.'));
      expect(label.bottom, lessThan(lastOption.top));
      expect(description.top, greaterThan(lastOption.bottom));
    });

    testWidgets('showRequiredIndicator adds the required mark', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          SeedRadioGroup<String>(
            label: '선호하는 연락 방법',
            showRequiredIndicator: true,
            value: 'email',
            child: const SeedRadio<String>(value: 'email', label: '이메일'),
          ),
        ),
      );
      expect(find.bySemanticsLabel('필수 입력'), findsOneWidget);
      handle.dispose();
    });
  });
}
