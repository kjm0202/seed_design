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

  testWidgets(
    'Select paired fields shrink side-by-side within 390px viewport',
    (tester) async {
      await _open(tester, '/select', width: 390);
      final fields = find.byType(SeedSelect<String>);
      final first = tester.getRect(fields.at(0));
      final second = tester.getRect(fields.at(1));
      final third = tester.getRect(fields.at(2));
      final fourth = tester.getRect(fields.at(3));
      expect(first.width, inInclusiveRange(165, 180));
      expect(second.top, closeTo(first.top, 1));
      expect(second.right, lessThanOrEqualTo(375));
      expect(third.width, inInclusiveRange(160, 180));
      expect(fourth.top, closeTo(third.top, 1));
      expect(fourth.right, lessThanOrEqualTo(375));
      final firstMultiple = tester.getRect(fields.at(10));
      final secondMultiple = tester.getRect(fields.at(11));
      expect(firstMultiple.width, inInclusiveRange(160, 180));
      expect(secondMultiple.top, closeTo(firstMultiple.top, 1));
      expect(secondMultiple.right, lessThanOrEqualTo(375));
      expect(tester.takeException(), isNull);
    },
  );

  for (final width in [390.0, 800.0]) {
    testWidgets(
      'Select prefix examples retain official React explanations $width',
      (tester) async {
        await _open(tester, '/select', width: width);
        expect(
          find.text(
            '미선택: star · 사과/바나나: 각 item 아이콘이 star를 이김 · 체리(무아이콘): static star로 fallback',
          ),
          findsOneWidget,
        );
        expect(
          find.text('1개 선택: 그 item 아이콘 미러 · 2개 이상: static star로 복귀'),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final width in [390.0, 800.0]) {
    testWidgets('EX-11 TimePicker matches React full content width at $width', (
      tester,
    ) async {
      await _open(tester, '/time-picker', width: width);
      final pickerRect = tester.getRect(find.byType(SeedTimePicker));
      // React ActivityTimePicker fills AppScreenContent with 16px gutters.
      // A former hard-coded 220px box clipped 오전/오후 wheel labels on phones.
      expect(pickerRect.width, closeTo(width - 32, 1));
      expect(pickerRect.left, closeTo(16, 1));
      expect(find.text('선택한 시간: 13:10'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

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

  for (final width in [390.0, 800.0]) {
    testWidgets(
      'Quantity demo uses official React section typography and copy $width',
      (tester) async {
        await _open(tester, '/quantity-picker', width: width);
        final title = tester.widget<Text>(find.text('범위 경계와 자릿수'));
        expect(title.style?.fontSize, SeedFontSize.t4);
        expect(title.style?.fontWeight, FontWeight.w700);

        const description = '최솟값·중간값·최댓값에서 action 상태와 값 표시 너비를 확인합니다.';
        final copy = tester.widget<Text>(find.text(description));
        expect(copy.style?.fontSize, SeedFontSize.t5);
        expect(find.text('외부 상태 동기화와 step 단위 증감 동작을 확인합니다.'), findsOneWidget);
        expect(
          find.text('최소 수량에서 Decrement 버튼이 Remove 버튼으로 전환되는지 확인합니다.'),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

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

  for (final width in [390.0, 800.0]) {
    testWidgets(
      'EX-11 Select max-height explanation and sheet CTA match React at $width',
      (tester) async {
        await _open(tester, '/select', width: width);
        expect(
          find.text(
            '--seed-select-max-height로 기본 480px 대신 160px까지만 열립니다 · 화면에 남은 공간이 더 좁으면 그쪽을 따릅니다',
          ),
          findsOneWidget,
        );
        final cta = find.widgetWithText(SeedButton, 'BottomSheet 열기');
        await tester.ensureVisible(cta);
        expect(tester.getRect(cta).width, closeTo(width - 32, 1));
        expect(tester.takeException(), isNull);
      },
    );
  }

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
