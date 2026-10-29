import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_design/seed_design.dart';
import 'package:seed_design_example/stackflow_spa/stackflow_spa.dart';

Future<void> _open(
  WidgetTester tester,
  String route, {
  double width = 390,
}) async {
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const StackflowSpaApp());
  await tester.pump();
  final navigator = tester.state<NavigatorState>(find.byType(Navigator));
  navigator.pushNamed(route);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump();
}

void main() {
  for (final width in [390.0, 800.0]) {
    testWidgets('EX-10 shipping stays in two columns at ${width.toInt()}px', (
      tester,
    ) async {
      await _open(tester, '/form', width: width);
      final group = tester.widget<SeedSelectBoxGroup>(
        find.byType(SeedSelectBoxGroup),
      );
      expect(group.columns, 2);
      final boxes = find.descendant(
        of: find.byType(SeedSelectBoxGroup),
        matching: find.byType(SeedSelectBox),
      );
      expect(boxes, findsNWidgets(4));
      final first = tester.getTopLeft(boxes.at(0));
      final second = tester.getTopLeft(boxes.at(1));
      expect((first.dy - second.dy).abs(), lessThan(1));
      expect(second.dx, greaterThan(first.dx));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'EX-11 Select keeps React field widths, icons, and grouped option distinction',
    (tester) async {
      await _open(tester, '/select', width: 800);
      final all = tester
          .widgetList<SeedSelect<String>>(find.byType(SeedSelect<String>))
          .toList();
      expect(all.length, greaterThanOrEqualTo(7));
      expect(tester.getSize(find.byType(SeedSelect<String>).at(0)).width, 200);
      expect(tester.getSize(find.byType(SeedSelect<String>).at(2)).width, 260);
      expect(tester.getSize(find.byType(SeedSelect<String>).at(3)).width, 260);
      expect(all[0].groups.first.items.first.prefixIcon, isA<Icon>());
      expect(all[7].groups.first.items.first.prefixIcon, isA<Icon>());
      expect(all[3].groups.single.items.map((item) => item.value), [
        'standard',
        'express',
      ]);
      final fields = tester
          .widgetList<SeedField>(find.byType(SeedField))
          .toList();
      expect(
        fields.any((field) => field.label == '과일' && field.required),
        isTrue,
      );
      expect(
        fields.any(
          (field) => field.label == '배송 방법' && field.errorIcon != null,
        ),
        isTrue,
      );
    },
  );

  testWidgets('EX-11 TimePicker is centered at React compact wheel width', (
    tester,
  ) async {
    await _open(tester, '/time-picker', width: 800);
    expect(
      tester.getSize(find.byType(SeedTimePicker)).width,
      lessThanOrEqualTo(260),
    );
    expect(find.text('선택한 시간: 13:10'), findsOneWidget);
  });

  testWidgets('EX-11 Quantity Form owns FormField state', (tester) async {
    await _open(tester, '/quantity-picker');
    expect(find.byType(Form), findsWidgets);
    expect(find.byType(FormField<int>), findsOneWidget);
    final quantity = tester.state<FormFieldState<int>>(
      find.byType(FormField<int>),
    );
    quantity.didChange(5);
    await tester.pump();
    final submit = find.widgetWithText(SeedButton, '제출');
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pump();
    expect(find.text('제출한 수량: 5개'), findsOneWidget);
  });

  testWidgets('EX-11 Select sheet keeps the handle and puts Select in footer', (
    tester,
  ) async {
    await _open(tester, '/select');
    final button = find.widgetWithText(SeedButton, 'BottomSheet 열기');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump(const Duration(milliseconds: 400));
    final sheet = tester.widget<SeedBottomSheet>(find.byType(SeedBottomSheet));
    expect(sheet.showHandle, true);
    expect(sheet.title, 'Select in BottomSheet');
    expect(sheet.footer, isNotNull);
    expect(
      find.descendant(
        of: find.byType(SeedBottomSheet),
        matching: find.byType(SeedSelect<String>),
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'MIX-02 Attachment display integration opts into invalid and required APIs',
    (tester) async {
      await _open(tester, '/attachment-display-field');
      final display = tester
          .widgetList<SeedAttachmentDisplayField>(
            find.byType(SeedAttachmentDisplayField),
          )
          .toList();
      final integration = display.singleWhere(
        (field) => field.label == 'Field Integration',
      );
      expect(integration.invalid, isTrue);
      expect(integration.showRequiredIndicator, isTrue);
      expect(integration.errorMessage, '사진을 1장 이상 등록해 주세요.');
      final field = tester
          .widgetList<SeedField>(find.byType(SeedField))
          .singleWhere((candidate) => candidate.label == 'Field Integration');
      expect(field.required, isTrue);
      expect(field.isInvalid, isTrue);
    },
  );
}
