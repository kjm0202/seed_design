import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_design/seed_design.dart';
import 'package:seed_design_example/stackflow_spa/stackflow_spa.dart';

Future<void> open(
  WidgetTester tester,
  String route, {
  double width = 800,
}) async {
  tester.view.physicalSize = Size(width, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const StackflowSpaApp());
  await tester.pumpAndSettle();
  tester.state<NavigatorState>(find.byType(Navigator)).pushNamed(route);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('TimePicker keeps the official React AppBar title', (
    tester,
  ) async {
    await open(tester, '/time-picker', width: 390);
    expect(find.text('TimePicker'), findsOneWidget);
    expect(find.text('Time Picker'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final (route, launch, title) in [
    ('/alert-dialog-activity', 'ActivityAlertDialog를 Push', 'Activity'),
    ('/bottom-sheet-activity', 'ActivityBottomSheet을 Push', 'Activity'),
    ('/side-panel-activity', 'ActivitySidePanel을 Push', 'Side Panel Activity'),
  ]) {
    testWidgets('$route places exactly two actions below its React AppBar', (
      tester,
    ) async {
      await open(tester, route, width: 390);
      expect(tester.getTopLeft(find.widgetWithText(SeedButton, launch)).dy, 76);
      expect(find.byType(SeedButton), findsNWidgets(2));
      expect(find.text(title), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'ResponsiveDialog mobile matches React sheet without a drag handle',
    (tester) async {
      await open(tester, '/responsive-dialog', width: 390);
      final sheet = tester.widget<SeedBottomSheet>(
        find.byType(SeedBottomSheet),
      );
      expect(sheet.showHandle, isFalse);
      expect(find.text('Responsive Dialog'), findsWidgets);
    },
  );

  testWidgets(
    'ResponsiveDialog entered as root retains open selected size on Escape',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const StackflowSpaApp());
      await tester.pumpAndSettle();
      tester
          .state<NavigatorState>(find.byType(Navigator))
          .pushReplacementNamed('/responsive-dialog');
      await tester.pumpAndSettle();
      final sizeControl = find.byType(SeedSegmentedControl<String>);
      expect(sizeControl, findsOneWidget);
      await tester.tap(find.text('Large'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<SeedSegmentedControl<String>>(sizeControl).value,
        'large',
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Responsive Dialog'), findsWidgets);
      expect(sizeControl, findsOneWidget);
      expect(
        tester.widget<SeedSegmentedControl<String>>(sizeControl).value,
        'large',
      );
      await tester.tap(find.text('취소'));
      await tester.pumpAndSettle();
      expect(sizeControl, findsOneWidget);
      await tester.tap(find.text('확인'));
      await tester.pumpAndSettle();
      expect(sizeControl, findsOneWidget);
      await tester.tap(
        find
            .byWidgetPredicate(
              (widget) =>
                  widget is SeedPressable && widget.semanticsLabel == '닫기',
            )
            .last,
      );
      await tester.pumpAndSettle();
      expect(sizeControl, findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('ResponsiveDialog pushed from Home still dismisses with Escape', (
    tester,
  ) async {
    await open(tester, '/responsive-dialog', width: 800);
    expect(find.byType(SeedDialog), findsOneWidget);
    await tester.tap(find.text('Large'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(SeedDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final width in [390.0, 800.0]) {
    for (final (route, title) in [
      ('/form', 'Form Components'),
      ('/menu', 'Menu'),
    ]) {
      testWidgets('$route root title preserves React x32 inset at $width', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(const StackflowSpaApp());
        await tester.pumpAndSettle();
        tester
            .state<NavigatorState>(find.byType(Navigator))
            .pushReplacementNamed(route);
        await tester.pumpAndSettle();
        expect(tester.getTopLeft(find.text(title)).dx, closeTo(32, 0.5));
      });
    }
  }

  testWidgets(
    'LayerBar uses a white surface and starts controls below AppBar',
    (tester) async {
      await open(tester, '/layer-bar');
      final button = find.widgetWithText(SeedButton, 'ActivityTransparentBar');
      expect(tester.getTopLeft(button).dy, 68);
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).last);
      expect(scaffold.backgroundColor, Colors.white);
      expect(find.text('AppBarLeft / AppBarRight'), findsNothing);
      expect(
        tester
            .widget<SeedTopNavigation>(find.byType(SeedTopNavigation).last)
            .centerTitle,
        false,
      );
      await tester.tap(find.text('Append Left'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Left notification 2'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Sticky tab list pins below AppBar while its introduction scrolls away',
    (tester) async {
      await open(tester, '/tabs');
      expect(find.text('Sticky Tablist'), findsOneWidget);
      await tester.drag(
        find.byType(CustomScrollView).last,
        const Offset(0, -350),
      );
      await tester.pumpAndSettle();
      expect(find.text('Sticky Tablist').hitTestable(), findsNothing);
      expect(tester.getTopLeft(find.byType(SeedTabs)).dy, 56);
      await tester.tap(find.text('Tab 2'));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('Tab 2 content'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('SideNavigation collapses and expands without layout overflow', (
    tester,
  ) async {
    await open(tester, '/side-navigation');
    expect(tester.getTopLeft(find.byType(SeedSideNavigation)).dy, 0);
    await tester.tap(find.byTooltip('접기'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(SeedSideNavigation)).width, 56);
    await tester.tap(find.byTooltip('펼치기'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(SeedSideNavigation)).width, 240);
  });

  for (final route in ['/side-panel', '/responsive-side-panel']) {
    testWidgets('$route keeps the default 80% panel cap at desktop width', (
      tester,
    ) async {
      await open(tester, route);
      final panel = find.byType(SeedSidePanel);
      expect(tester.getSize(panel).width, 640);
      expect(tester.getTopLeft(panel).dx, 160);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets(
    'Form keeps email and address side by side and serializes successful controls',
    (tester) async {
      await open(tester, '/form', width: 390);
      expect(find.text('Form Components'), findsOneWidget);
      expect(find.byIcon(Icons.home_outlined), findsNothing);
      final email = find.byWidgetPredicate(
        (w) => w is SeedTextField && w.label == '이메일',
      );
      final address = find.byWidgetPredicate(
        (w) => w is SeedTextField && w.label == '주소',
      );
      expect(tester.getTopLeft(email).dy, tester.getTopLeft(address).dy);
      expect(
        tester.getTopLeft(email).dx,
        lessThan(tester.getTopLeft(address).dx),
      );
      await tester.tap(find.widgetWithText(SeedButton, '제출'));
      await tester.pumpAndSettle();
      final data = jsonDecode(
        tester.widget<SeedSnackbar>(find.byType(SeedSnackbar)).message,
      ) as Map;
      expect(data['attachments'], [{}]);
      for (final key in ['category', 'extra', 'fruit', 'agreement']) {
        expect(data.containsKey(key), false);
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'TransparentBar compact controls keep one-line segments and full CTA labels',
    (tester) async {
      await open(tester, '/transparent-bar', width: 390);
      final control = find.byType(SeedSegmentedControl<String>);
      expect(tester.getSize(control).height, closeTo(42, 1));
      expect(find.text('safeArea'), findsOneWidget);
      const longTitle = 'ActivityTransitionStyle (fadeFromBottomAndroid)';
      final longButton = find.widgetWithText(SeedButton, longTitle);
      await tester.scrollUntilVisible(
        longButton,
        160,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      expect(tester.getSize(longButton).width, greaterThan(358));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Menu fills its long-list and sheet trigger rows at phone width',
    (tester) async {
      await open(tester, '/menu', width: 390);
      final longList = find.widgetWithText(SeedButton, '30개 항목');
      final sheetTrigger = find.widgetWithText(SeedButton, '메뉴에서 시트 열기');
      expect(tester.getSize(longList).width, closeTo(358, 1));
      await tester.scrollUntilVisible(
        sheetTrigger,
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      expect(tester.getSize(sheetTrigger).width, closeTo(358, 1));
      expect(
        find.textContaining('--seed-menu-max-height로 기본 480px 대신 160px'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Menu onOpenChange reason labels match React outside and Escape',
    (tester) async {
      await open(tester, '/menu', width: 390);
      final reasonTrigger = find.text('Reason 추적');
      await tester.scrollUntilVisible(
        reasonTrigger,
        180,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      await tester.tap(reasonTrigger);
      await tester.pumpAndSettle();
      expect(find.text('마지막: trigger'), findsOneWidget);
      await tester.tapAt(const Offset(10, 95));
      await tester.pumpAndSettle();
      expect(find.text('마지막: interactOutside'), findsOneWidget);
      await tester.tap(reasonTrigger);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('마지막: escapeKeyDown'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Popover headerless sample has no header and uses Apply', (
    tester,
  ) async {
    await open(tester, '/popover', width: 390);
    await tester.tap(find.text('헤더 없음'));
    await tester.pumpAndSettle();
    final visiblePopover = tester.widget<SeedPopover>(
      find.byType(SeedPopover).last,
    );
    expect(visiblePopover.titleText, isNull);
    expect(visiblePopover.semanticsLabel, '필터');
    expect(visiblePopover.descriptionText, isNull);
    expect(visiblePopover.showCloseButton, isFalse);
    expect(find.text('적용'), findsOneWidget);
    await tester.tap(find.text('적용'));
    await tester.pumpAndSettle();
    expect(find.text('적용'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Avatar ALL sizes fit in the 800px preview without artificial tile widths',
    (tester) async {
      await open(tester, '/avatar');
      await tester.tap(find.byType(DropdownButton<String>).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('All').last);
      await tester.pumpAndSettle();
      expect(find.byType(SeedAvatar), findsNWidgets(10));
      for (final avatar in find.byType(SeedAvatar).evaluate()) {
        final rect = tester.getRect(
          find.byElementPredicate((e) => e == avatar),
        );
        expect(rect.left, greaterThanOrEqualTo(16));
        expect(rect.right, lessThanOrEqualTo(784.01));
        expect(rect.top, 72);
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'transparent AppScreen has the official full-screen slate surface and slots',
    (tester) async {
      await open(tester, '/app-screen-transparent');
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).last);
      expect(scaffold.extendBodyBehindAppBar, true);
      expect(scaffold.backgroundColor, SeedPalette.gray800Light);
      // React app-bar.tsx:111-115 renders Close only for root activities.
      // open() pushes this page on top of Home, so it is a nested activity.
      expect(find.bySemanticsLabel('Close'), findsNothing);
      expect(find.bySemanticsLabel('Notification'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
