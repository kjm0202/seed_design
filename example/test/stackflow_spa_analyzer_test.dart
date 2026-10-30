import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_design/seed_design.dart';
import 'package:seed_design_example/stackflow_spa/stackflow_spa.dart';

void main() {
  testWidgets('React ALL variant expands action-button showcase into a grid', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(440, 960);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const StackflowSpaApp());
    tester
        .state<NavigatorState>(find.byType(Navigator))
        .pushNamed('/action-button');
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButton<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('All').last);
    await tester.pumpAndSettle();

    expect(find.byType(Table), findsOneWidget);
    expect(find.text('그리드 표시'), findsOneWidget);
  });

  testWidgets('React ALL choices enumerate checkbox size variants', (
    tester,
  ) async {
    await tester.pumpWidget(const StackflowSpaApp());
    tester.state<NavigatorState>(find.byType(Navigator)).pushNamed('/checkbox');
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButton<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('All').last);
    await tester.pumpAndSettle();

    expect(find.text('그리드 표시'), findsOneWidget);
    expect(find.text('ALL'), findsNothing);
  });

  for (final width in [390.0, 800.0]) {
    testWidgets(
      'WheelPicker sheet has no host AppBar at $width and advances day',
      (tester) async {
        final height = width == 390 ? 844.0 : 800.0;
        tester.view.physicalSize = Size(width, height);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(const StackflowSpaApp());
        tester
            .state<NavigatorState>(find.byType(Navigator))
            .pushNamed('/wheel-picker');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        // React ActivityWheelPicker is the sheet itself, with no AppBar behind
        // its scrim. The host must not insert its generic navigation bar.
        expect(find.byType(SeedTopNavigation), findsNothing);
        expect(find.byType(SeedBottomSheet), findsOneWidget);
        expect(find.text('2026년 8월 20일'), findsOneWidget);

        // The official medium WheelPicker uses t10Medium (26px, w500) for
        // all three wheels, not the default 14px example body text.
        for (final label in ['2026년', '8월', '20일']) {
          final item = tester.widget<Text>(find.text(label).first);
          expect(item.style?.fontSize, 26, reason: '$label font size');
          expect(
            item.style?.fontWeight,
            FontWeight.w500,
            reason: '$label font weight',
          );
        }

        // The sheet component already applies its own footer x16 inset.
        final nextButton = find.widgetWithText(SeedButton, '다음 날로 변경');
        expect(
          tester.getTopLeft(nextButton).dx,
          closeTo(width == 390 ? 16 : 176, 1),
        );
        // React sheet begins y376 (390x844) / y332 (800x800), with its
        // 220px wheel 70px below the sheet's top edge.
        expect(
          tester.getTopLeft(find.byType(SeedWheelPicker)).dy,
          closeTo(width == 390 ? 446 : 402, 4),
        );
        await tester.tap(find.text('다음 날로 변경'));
        await tester.pumpAndSettle();
        expect(find.text('2026년 8월 21일'), findsOneWidget);

        await tester.tap(find.text('완료'));
        await tester.pumpAndSettle();
        expect(find.text('Home'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
