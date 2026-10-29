import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

  testWidgets('WheelPicker opens as sheet and preserves next-day interaction', (
    tester,
  ) async {
    await tester.pumpWidget(const StackflowSpaApp());
    tester
        .state<NavigatorState>(find.byType(Navigator))
        .pushNamed('/wheel-picker');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('2026년 8월 20일'), findsOneWidget);
    await tester.tap(find.text('다음 날로 변경'));
    await tester.pumpAndSettle();
    expect(find.text('2026년 8월 21일'), findsOneWidget);

    await tester.tap(find.text('완료'));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
  });
}
