import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_design/seed_design.dart';
import 'package:seed_design_example/stackflow_spa/stackflow_spa.dart';

Future<NavigatorState> open(WidgetTester tester, String route) async {
  tester.view.physicalSize = const Size(440, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const StackflowSpaApp());
  await tester.pumpAndSettle();
  final navigator = tester.state<NavigatorState>(find.byType(Navigator));
  navigator.pushNamed(route);
  await tester.pumpAndSettle();
  return navigator;
}

void main() {
  testWidgets('home remains reachable after replacing its root activity', (
    tester,
  ) async {
    final navigator = await open(tester, '/action-button');
    navigator.pop();
    await tester.pumpAndSettle();
    navigator.pushReplacementNamed('/action-button');
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('홈으로'));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('required Select blocks empty submit then accepts a fruit', (
    tester,
  ) async {
    await open(tester, '/select');
    final submit = find.widgetWithText(SeedButton, '제출');
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();
    expect(find.textContaining('제출됨:'), findsNothing);
    expect(find.text('과일을 선택해주세요.'), findsOneWidget);
    final select = find.descendant(
      of: find.byType(FormField<String>),
      matching: find.byType(SeedSelect<String>),
    );
    await tester.ensureVisible(select);
    await tester.tap(select);
    await tester.pumpAndSettle();
    await tester.tap(find.text('바나나').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();
    expect(find.text('제출됨: banana'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Form submits default values as JSON without messenger errors', (
    tester,
  ) async {
    await open(tester, '/form');
    await tester.tap(find.widgetWithText(SeedButton, '제출'));
    await tester.pumpAndSettle();
    final snackbar = tester.widget<SeedSnackbar>(find.byType(SeedSnackbar));
    expect(jsonDecode(snackbar.message), containsPair('name', ['']));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'MannerTemp level changes preserve temperature and ALL has ten badges',
    (tester) async {
      await open(tester, '/manner-temp-level');
      expect(
        tester
            .widget<SeedMannerTempBadge>(find.byType(SeedMannerTempBadge))
            .level,
        1,
      );
      await tester.tap(find.byType(DropdownButton<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('l5').last);
      await tester.pumpAndSettle();
      final badge = tester.widget<SeedMannerTempBadge>(
        find.byType(SeedMannerTempBadge),
      );
      expect(badge.level, 5);
      expect(badge.temperature, 36.5);
      await tester.tap(find.byType(DropdownButton<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('All').last);
      await tester.pumpAndSettle();
      expect(find.byType(SeedMannerTempBadge), findsNWidgets(10));
    },
  );

  for (final route in ['/responsive-dialog', '/responsive-side-panel']) {
    testWidgets('$route changes surface while open on viewport resize', (
      tester,
    ) async {
      await open(tester, route);
      expect(find.byType(SeedBottomSheet), findsOneWidget);
      tester.view.physicalSize = const Size(1000, 900);
      await tester.pumpAndSettle();
      expect(find.byType(SeedBottomSheet), findsNothing);
      expect(
        route == '/responsive-dialog'
            ? find.byType(SeedDialog)
            : find.byType(SeedSidePanel),
        findsOneWidget,
      );
      tester.view.physicalSize = const Size(440, 900);
      await tester.pumpAndSettle();
      expect(find.byType(SeedBottomSheet), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('LayerBar controls change the actual top navigation slots', (
    tester,
  ) async {
    await open(tester, '/layer-bar');
    final bar = find.byType(SeedTopNavigation).last;
    expect(
      find.descendant(of: bar, matching: find.byTooltip('Left notification 2')),
      findsNothing,
    );
    await tester.tap(find.text('Append Left'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: bar, matching: find.byTooltip('Left notification 2')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('LayerBar keeps appended icons visible as its title shrinks', (
    tester,
  ) async {
    await open(tester, '/layer-bar');
    tester.view.physicalSize = const Size(1024, 900);
    await tester.pumpAndSettle();

    for (var i = 1; i < 10; i++) {
      await tester.tap(find.text('Append Left'));
      await tester.pump();
    }
    for (var i = 1; i < 3; i++) {
      await tester.tap(find.text('Append Right'));
      await tester.pump();
    }

    final left = find.byTooltip('Left notification 10');
    final right = find.byTooltip('Right notification 3');
    expect(left, findsOneWidget);
    expect(right, findsOneWidget);
    expect(tester.getRect(left).right, lessThan(1024));
    expect(tester.getRect(right).right, lessThan(1024));
    expect(tester.getRect(left).right, lessThan(tester.getRect(right).left));
    expect(tester.takeException(), isNull);
  });

  testWidgets('LayerBar keeps the left icon-to-title gap fixed when appending', (
    tester,
  ) async {
    await open(tester, '/layer-bar');
    tester.view.physicalSize = const Size(2048, 900);
    await tester.pumpAndSettle();

    const title =
        'Random Long Title Hello World Commodo occaecat laboris voluptate aute magna.';
    double gapForCount(int count) =>
        tester.getRect(find.text(title)).left -
        tester.getRect(find.byTooltip('Left notification $count')).right;

    final initialGap = gapForCount(1);
    expect(tester.getSize(find.byTooltip('Left notification 1')).width, 44);
    for (var count = 2; count <= 20; count++) {
      await tester.tap(find.text('Append Left'));
      await tester.pump();
      if (count == 4 || count == 12 || count == 20) {
        expect(
          tester.getSize(find.byTooltip('Left notification $count')).width,
          44,
        );
        expect(
          tester.getRect(find.byTooltip('Left notification $count')).left -
              tester
                  .getRect(find.byTooltip('Left notification ${count - 1}'))
                  .left,
          44,
        );
        expect(
          (gapForCount(count) - initialGap).abs(),
          lessThan(1),
          reason: 'Adding left actions must not increase reserved blank space',
        );
      }
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('Swipeable tabs only refresh the first feed', (tester) async {
    await open(tester, '/swipeable-tabs');
    await tester.tap(find.text('Tab 2'));
    await tester.pumpAndSettle();
    expect(find.byType(SeedPullToRefresh), findsNothing);
    expect(tester.takeException(), isNull);
  });
  for (final route in ['/menu-sheet', '/swipeable-menu-sheet']) {
    testWidgets('$route returns the selected action to its caller', (
      tester,
    ) async {
      final navigator = await open(tester, '/action-button');
      final result = navigator.pushNamed(route);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();
      expect(await result, {'action': 'add'});
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets(
    'keyboard playground options change sheet geometry and use live insets',
    (tester) async {
      await open(tester, '/bottom-sheet-keyboard-playground');
      final fixed = find.text('fixed: off');
      await tester.ensureVisible(fixed);
      await tester.tap(fixed);
      await tester.pumpAndSettle();
      expect(
        tester.widget<SeedBottomSheet>(find.byType(SeedBottomSheet)).expand,
        isFalse,
        reason:
            'React fixed controls keyboard anchoring; it does not request '
            'an expanded sheet (useDrawer fixed + repositionInputs contract).',
      );
      await tester.ensureVisible(find.text('snapPoints: off'));
      await tester.tap(find.text('snapPoints: off'));
      await tester.pumpAndSettle();
      expect(find.byType(SeedSnappingBottomSheet), findsOneWidget);
      tester.view.viewInsets = const FakeViewPadding(bottom: 250);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      expect(find.textContaining('keyboard 250px'), findsOneWidget);
      expect(find.textContaining('sheet top'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('native swipe back obeys the prevent toggle', (tester) async {
    final navigator = await open(tester, '/action-button');
    navigator.pushNamed(
      '/transition-style',
      arguments: {'transitionStyle': 'slideFromRightIOS'},
    );
    await tester.pumpAndSettle();
    final control = tester.widget<SeedSegmentedControl<bool>>(
      find.byType(SeedSegmentedControl<bool>),
    );
    control.onValueChange!(true);
    await tester.pumpAndSettle();
    await tester.timedDragFrom(
      const Offset(2, 200),
      const Offset(400, 0),
      const Duration(milliseconds: 500),
    );
    await tester.pumpAndSettle();
    expect(find.text('Prevent Swipe Back'), findsOneWidget);
    tester
        .widget<SeedSegmentedControl<bool>>(
          find.byType(SeedSegmentedControl<bool>),
        )
        .onValueChange!(false);
    await tester.pumpAndSettle();
    await tester.timedDragFrom(
      const Offset(2, 200),
      const Offset(400, 0),
      const Duration(milliseconds: 500),
    );
    await tester.pumpAndSettle();
    expect(find.text('Prevent Swipe Back'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'home immediate snackbar replaces queued message and exposes Dance',
    (tester) async {
      await tester.pumpWidget(const StackflowSpaApp());
      await tester.pumpAndSettle();
      for (
        var i = 0;
        i < 30 && find.text('queued').hitTestable().evaluate().isEmpty;
        i++
      ) {
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -450));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('queued'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Queued Snackbar'), findsOneWidget);
      await tester.tap(find.text('기본').last);
      await tester.pumpAndSettle();
      expect(find.text('Disco Party!'), findsOneWidget);
      expect(find.text('Queued Snackbar'), findsNothing);
      await tester.tap(find.text('Dance'));
      await tester.pumpAndSettle();
      expect(find.text('Disco Party!'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'deleting the featured attachment promotes the current first entry',
    (tester) async {
      await open(tester, '/attachment-display-field');
      final field = find.byWidgetPredicate(
        (w) =>
            w is SeedAttachmentDisplayField &&
            w.label == 'Customizing Items (대표사진 배지)',
      );
      await tester.ensureVisible(field);
      await tester.tap(
        find
            .descendant(of: field, matching: find.bySemanticsLabel('첨부 파일 삭제'))
            .first,
      );
      await tester.pumpAndSettle();
      final input = tester.widget<SeedAttachmentInput>(
        find.descendant(of: field, matching: find.byType(SeedAttachmentInput)),
      );
      expect(input.items.length, 1);
      expect(input.items.single.isRepresentative, isTrue);
      expect(tester.takeException(), isNull);
    },
  );
  for (final keep in [false, true]) {
    testWidgets(
      'BottomSheet keepMounted=$keep controls uncontrolled input lifetime',
      (tester) async {
        final navigator = await open(tester, '/bottom-sheet');
        await tester.enterText(find.byType(EditableText), 'saved name');
        if (keep) {
          final toggle = find.text('Push 이후에도 BottomSheet 마운트 유지');
          await tester.ensureVisible(toggle);
          await tester.tap(toggle);
          await tester.pumpAndSettle();
        }
        await tester.ensureVisible(find.text('ActivityDetail'));
        await tester.tap(find.text('ActivityDetail'));
        await tester.pumpAndSettle();
        navigator.pop();
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<EditableText>(find.byType(EditableText))
              .controller
              .text,
          keep ? 'saved name' : '',
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }

  testWidgets('AlertDialog returns hello to the activity caller', (
    tester,
  ) async {
    final navigator = await open(tester, '/action-button');
    final result = navigator.pushNamed('/alert-dialog');
    await tester.pumpAndSettle();
    await tester.tap(find.text('확인'));
    await tester.pumpAndSettle();
    expect(await result, {'message': 'hello'});
    expect(tester.takeException(), isNull);
  });
}
