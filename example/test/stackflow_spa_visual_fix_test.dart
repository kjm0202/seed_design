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
  for (final width in [390.0, 800.0]) {
    testWidgets(
      'Pagination official React content inset, heading tokens and nav Y $width',
      (tester) async {
        await open(tester, '/pagination', width: width);
        final heading = tester.widget<Text>(
          find
              .descendant(
                of: find.byType(ListView),
                matching: find.text('Pagination'),
              )
              .first,
        );
        expect(heading.style?.fontSize, 16);
        expect(heading.style?.height, closeTo(22 / 16, 0.001));
        expect(
          tester.getTopLeft(find.byType(SeedPagination)).dy,
          closeTo(114, 0.1),
          reason: 'React py24 + t5Bold line-height22 + x3 gap12 after 56px bar',
        );
        for (final title in ['Table Pagination', 'Unknown Total']) {
          final text = tester.widget<Text>(find.text(title).last);
          expect(text.style?.fontSize, 16);
          expect(text.style?.height, closeTo(22 / 16, 0.001));
        }
        expect(tester.takeException(), isNull);
      },
    );
  }
  for (final width in [390.0, 800.0]) {
    testWidgets(
      'Accordion inline content shares React trigger left inset $width',
      (tester) async {
        await open(tester, '/accordion', width: width);
        final trigger = find.text('당근마켓은 어떤 서비스인가요?').first;
        await tester.tap(trigger);
        await tester.pumpAndSettle();
        final content = find
            .text(
              '당근마켓은 동네 이웃 간의 중고거래를 돕는 플랫폼입니다. 가까운 이웃과 직거래로 안전하게 거래할 수 있어요.',
            )
            .first;
        expect(
          tester.getTopLeft(content).dx,
          closeTo(tester.getTopLeft(trigger).dx, 2),
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
  for (final (route, title) in [
    ('/tabs-auto-height-lazy', 'Tabs AutoHeight + LazyMount'),
    ('/chip-tabs-scroll-fog', 'ChipTabs ScrollFog + LazyMount'),
  ]) {
    testWidgets('$route shows the official React AppBar title', (tester) async {
      await open(tester, route, width: 390);
      expect(find.text(title), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('ChipTabs color panel has no border in official React', (
    tester,
  ) async {
    await open(tester, '/chip-tabs-scroll-fog', width: 390);
    final panel = tester.widget<Container>(
      find
          .ancestor(
            of: find.text('Tab 1: Immediate (100px)'),
            matching: find.byType(Container),
          )
          .first,
    );
    expect((panel.decoration! as BoxDecoration).border, isNull);
  });



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
    'ResponsiveSidePanel 767/768 retains React compact layout on resize',
    (tester) async {
      await open(tester, '/responsive-side-panel', width: 767);
      final sheet = tester.widget<SeedBottomSheet>(
        find.byType(SeedBottomSheet),
      );
      expect(sheet.showHandle, isFalse);
      expect(find.text('패널 크기'), findsNothing);
      final cancel = find.widgetWithText(SeedButton, '닫기');
      final confirm = find.widgetWithText(SeedButton, '확인');
      expect(tester.getTopLeft(cancel).dy, tester.getTopLeft(confirm).dy);
      expect(
        tester.getTopLeft(cancel).dx,
        lessThan(tester.getTopLeft(confirm).dx),
      );

      await tester.tap(find.text('Large'));
      await tester.pumpAndSettle();
      tester.view.physicalSize = const Size(768, 800);
      await tester.pumpAndSettle();
      expect(find.byType(SeedBottomSheet), findsNothing);
      expect(find.byType(SeedSidePanel), findsOneWidget);
      expect(
        tester
            .widget<SeedSegmentedControl<String>>(
              find.byType(SeedSegmentedControl<String>),
            )
            .value,
        'large',
      );
      expect(find.text('패널 크기'), findsNothing);
      expect(tester.getTopLeft(cancel).dy, tester.getTopLeft(confirm).dy);
      expect(
        tester.getTopLeft(cancel).dx,
        lessThan(tester.getTopLeft(confirm).dx),
      );
      expect(tester.takeException(), isNull);
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

  testWidgets(
      'SideNavigation collapses and expands without layout overflow',
      (tester) async {
        await open(tester, '/side-navigation');
        expect(tester.getTopLeft(find.byType(SeedSideNavigation)).dy, 0);
        await tester.tap(find.byTooltip('사이드바 닫기'));
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull);
        await tester.pumpAndSettle();
        expect(tester.getSize(find.byType(SeedSideNavigation)).width, 56);
        await tester.tap(find.byTooltip('사이드바 열기'));
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull);
        await tester.pumpAndSettle();
        expect(tester.getSize(find.byType(SeedSideNavigation)).width, 240);
      },
    );

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
      // Official React's 24px gradient toggle occupies only its visual height.
      // Flutter's 44px touch target must not shift the subsequent CTA down.
      expect(
        tester
            .getTopLeft(find.widgetWithText(SeedButton, 'ActivityLayerBar'))
            .dy,
        closeTo(399, 2),
      );
      expect(tester.getSize(find.byType(SeedSwitch)).height, 44);
      await tester.tap(find.text('gradient'));
      await tester.pumpAndSettle();
      expect(tester.widget<SeedSwitch>(find.byType(SeedSwitch)).checked, false);
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

  testWidgets('TransparentBar desktop CTA follows the React switch baseline', (
    tester,
  ) async {
    await open(tester, '/transparent-bar', width: 800);
    expect(
      tester.getTopLeft(find.widgetWithText(SeedButton, 'ActivityLayerBar')).dy,
      closeTo(706, 2),
    );
    expect(tester.takeException(), isNull);
  });

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

  for (final width in [390.0, 800.0]) {
    testWidgets('Popover nested cascade reason labels match React at $width', (
      tester,
    ) async {
      await open(tester, '/popover', width: width);
      final outer = find.text('바깥 popover');
      await tester.scrollUntilVisible(
        outer,
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      await tester.tap(outer);
      await tester.pumpAndSettle();
      await tester.tap(find.text('안쪽 popover'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('바깥 popover 닫기'));
      await tester.pumpAndSettle();
      expect(find.text('outer close · -'), findsOneWidget);
      expect(find.text('nested close · cascadeDismiss'), findsOneWidget);
      expect(find.text('안쪽 레이어'), findsNothing);
      expect(find.text('바깥 레이어'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Side Navigation shows all density choices initially at 600px', (
    tester,
  ) async {
    await open(tester, '/side-navigation', width: 600);
    final high = find.text('high');
    expect(high, findsOneWidget);
    expect(find.text('low'), findsOneWidget);
    expect(find.text('medium'), findsOneWidget);
    expect(tester.getRect(high).right, lessThanOrEqualTo(600));
    expect(tester.takeException(), isNull);
  });

  for (final width in [390.0, 800.0]) {
    testWidgets('ListRadio ArrowDown chooses next enabled item at $width', (
      tester,
    ) async {
      await open(tester, '/list-item-radio', width: width);
      const second = 'prefix-title-unchecked-suffix-icon-info';
      const third = 'prefix-title-unchecked-suffix-icon-chevron';
      final secondRow = find.text(second);
      await tester.ensureVisible(secondRow);
      await tester.pumpAndSettle();
      await tester.tap(secondRow);
      await tester.pumpAndSettle();
      Semantics radio(String label) => tester.widget<Semantics>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              (widget.properties.label == label ||
                  widget.properties.label?.startsWith('$label\n') == true),
        ),
      );
      expect(radio(second).properties.checked, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(radio(second).properties.checked, isFalse);
      expect(radio(third).properties.checked, isTrue);
      expect(
        FocusManager.instance.primaryFocus?.debugLabel,
        'ListRadio $third',
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();
      expect(radio(second).properties.checked, isTrue);
      expect(radio(third).properties.checked, isFalse);
      expect(
        FocusManager.instance.primaryFocus?.debugLabel,
        'ListRadio $second',
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(radio(third).properties.checked, isTrue);
      // Three consecutive disabled radio rows must be skipped as one group.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      const following = 'prefix-title-detail-unchecked-suffix-none';
      await tester.scrollUntilVisible(
        find.text(following),
        80,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      expect(radio(following).properties.checked, isTrue);
      expect(
        FocusManager.instance.primaryFocus?.debugLabel,
        'ListRadio $following',
      );
      expect(tester.takeException(), isNull);
    });
  }

  for (final width in [390.0, 800.0]) {
    for (final (route, isSwitch) in [
      ('/list-item-check', false),
      ('/list-item-switch', true),
    ]) {
      testWidgets('$route activates with Space, not Enter at $width', (
        tester,
      ) async {
        await open(tester, route, width: width);
        const label = 'prefix-title-unchecked-suffix-none';
        final rowFinder = find.byKey(const ValueKey(label));
        bool value() {
          final row = tester.widget<SeedListItem>(rowFinder);
          return (isSwitch ? row.toggled : row.checked) ?? false;
        }

        expect(value(), isFalse);
        await tester.tap(find.text(label));
        await tester.pumpAndSettle();
        expect(value(), isTrue);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(
          value(),
          isTrue,
          reason: 'React native checkbox/switch ignores Enter',
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pumpAndSettle();
        expect(
          value(),
          isFalse,
          reason: 'React native checkbox/switch toggles on Space',
        );
        expect(tester.takeException(), isNull);
      });
    }
  }

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
