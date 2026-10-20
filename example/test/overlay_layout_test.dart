import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';
import 'package:seed_design_example/tabs/overlays_tab.dart';

import '../../test/support/seed_test_fonts.dart';

Future<void> mount(
  WidgetTester tester, {
  double width = 390,
  double scale = 1,
  bool dark = false,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, 800);
  final theme = dark
      ? SeedThemeData.dark(fontFamily: seedTestFontFamily)
      : SeedThemeData.light(fontFamily: seedTestFontFamily);
  await tester.pumpWidget(
    MaterialApp(
      theme: theme.toThemeData(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: const Scaffold(
        body: SingleChildScrollView(
          child: Padding(padding: EdgeInsets.all(16), child: OverlaysTab()),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> open(WidgetTester tester, String label) async {
  await tester.ensureVisible(find.text(label));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => loadSeedTestFonts(fontDirectory: '../test/assets/fonts'));

  testWidgets('confirmation sample uses a concise single-line Korean title', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    await mount(tester);
    await open(tester, '기본 확인 알림창');
    expect(
      tester.getSize(find.text('알림 설정을 저장할까요?')).height,
      SeedLineHeight.t7,
    );
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();
    expect(find.byType(SeedAlertDialog), findsNothing);
  });
}
