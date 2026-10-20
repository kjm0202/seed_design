import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_design/seed_design.dart';
import 'package:seed_design_example/main.dart';

void main() {
  testWidgets('more button opens SeedMenu and selection dismisses it', (
    tester,
  ) async {
    await tester.pumpWidget(const SeedDesignCatalogApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('오버레이'));
    await tester.pumpAndSettle();

    final button = find.byTooltip('채팅방 메뉴');
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();

    expect(find.byType(SeedMenu), findsNothing);
    final bubble = find.text('메뉴 버튼을 눌러보세요');
    expect(bubble, findsOneWidget);
    expect(
      tester.getTopLeft(bubble).dy,
      greaterThan(tester.getBottomLeft(button).dy),
    );

    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.byType(SeedMenu), findsOneWidget);
    expect(find.text('알림 끄기'), findsOneWidget);
    expect(bubble.hitTestable(), findsNothing);

    await tester.tap(find.text('알림 끄기'));
    await tester.pumpAndSettle();
    expect(find.byType(SeedMenu), findsNothing);
    expect(find.text('채팅방 알림을 껐어요.'), findsOneWidget);
    expect(bubble, findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'anchored menu dismisses outside and with Escape on a narrow screen',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const SeedDesignCatalogApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('오버레이'));
      await tester.pumpAndSettle();
      final button = find.byTooltip('채팅방 메뉴');
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();

      await tester.tap(button);
      await tester.pumpAndSettle();
      final menuBounds = tester.getRect(find.byType(SeedMenu));
      expect(menuBounds.left, greaterThanOrEqualTo(0));
      expect(menuBounds.right, lessThanOrEqualTo(320));
      expect(menuBounds.top, greaterThanOrEqualTo(0));
      expect(menuBounds.bottom, lessThanOrEqualTo(640));

      await tester.tapAt(const Offset(300, 100));
      await tester.pumpAndSettle();
      expect(find.byType(SeedMenu), findsNothing);

      await tester.tap(button);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(SeedMenu), findsNothing);
      expect(find.text('메뉴 버튼을 눌러보세요'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('bottom sheet sorting options open and dismiss without errors', (
    tester,
  ) async {
    await tester.pumpWidget(const SeedDesignCatalogApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('오버레이'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('바텀 시트 열기'));
    await tester.tap(find.text('바텀 시트 열기'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('정렬 옵션 선택'), findsOneWidget);
    expect(find.byType(SeedListItem), findsNWidgets(3));

    await tester.tap(find.text('최신순'));
    await tester.pumpAndSettle();

    expect(find.text('정렬 옵션 선택'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('SeedDesignCatalogApp smoke and navigation test', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SeedDesignCatalogApp());
    await tester.pumpAndSettle();

    // Verify initial components tab
    expect(find.text('SEED Design System'), findsOneWidget);
    expect(find.text('SeedButton Variants'), findsOneWidget);

    // Switch to Feedback & Status tab
    await tester.tap(find.text('피드백 & 상태'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Manner Temperature'), findsOneWidget);

    // Switch to Inputs & Pickers tab
    await tester.tap(find.text('입력 & 피커'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Form Controls & Quantity Picker'), findsOneWidget);

    // Switch to Navigation & Layout tab
    await tester.tap(find.text('탐색 & 레이아웃'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Pagination & Table Controls'), findsOneWidget);

    // Switch to Overlays tab
    await tester.tap(find.text('오버레이'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Dialogs & Alerts'), findsOneWidget);
  });

  testWidgets(
    'SeedDesignCatalogApp narrow mobile viewport responsiveness test',
    (WidgetTester tester) async {
      // Test on narrow 320px screen (e.g. Galaxy Fold cover screen / small device)
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const SeedDesignCatalogApp());
      await tester.pumpAndSettle();

      // Components tab must render without any RenderFlex overflow
      expect(find.text('SeedButton Variants'), findsOneWidget);

      // Feedback & Status tab
      await tester.tap(find.text('피드백 & 상태'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Manner Temperature'), findsOneWidget);
    },
  );
}
