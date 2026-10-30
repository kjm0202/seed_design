import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_design/seed_design.dart';
import 'package:seed_design_example/stackflow_spa/stackflow_spa.dart';

void main() {
  for (final width in [390.0, 800.0]) {
    for (final dismiss in ['done', 'close', 'escape', 'scrim']) {
      testWidgets(
        'WheelPicker deep-link root retains date after $dismiss at $width',
        (tester) async {
          tester.view.physicalSize = Size(width, width == 390 ? 844 : 800);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await tester.pumpWidget(const StackflowSpaApp());
          await tester.pumpAndSettle();
          final done = Completer<void>();
          tester.binding.defaultBinaryMessenger.handlePlatformMessage(
            SystemChannels.navigation.name,
            SystemChannels.navigation.codec.encodeMethodCall(
              const MethodCall('pushRouteInformation', {
                'location': '/wheel-picker',
                'state': null,
              }),
            ),
            (_) => done.complete(),
          );
          await tester.pump();
          await done.future;
          await tester.pumpAndSettle();
          expect(find.byType(SeedBottomSheet), findsOneWidget);
          await tester.tap(find.text('다음 날로 변경'));
          await tester.pumpAndSettle();
          expect(find.text('2026년 8월 21일'), findsOneWidget);
          switch (dismiss) {
            case 'done':
              await tester.tap(find.text('완료'));
            case 'close':
              await tester.tap(find.byIcon(Icons.close_rounded).last);
            case 'escape':
              await tester.sendKeyEvent(LogicalKeyboardKey.escape);
            case 'scrim':
              await tester.tapAt(const Offset(8, 80));
          }
          await tester.pumpAndSettle();
          expect(find.byType(SeedBottomSheet), findsOneWidget);
          expect(find.text('2026년 8월 21일'), findsOneWidget);
        },
      );
    }
  }

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

        // React WheelPicker CSS uses max-content column widths, not three
        // equally expanded thirds. CDP 390: year=118.73, month=83.09,
        // day=86.97, centered as a group in the 360px root.
        final datePicker = tester.widget<SeedWheelPicker>(
          find.byType(SeedWheelPicker),
        );
        final columnWidths = [
          for (final column in datePicker.columns) column.width,
        ];
        expect(columnWidths, everyElement(isNotNull));
        expect(columnWidths[0], closeTo(119, 10));
        expect(columnWidths[1], closeTo(83, 10));
        expect(columnWidths[2], closeTo(87, 10));

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
