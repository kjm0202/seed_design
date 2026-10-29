// Original MISMATCH: p2_list_item_800_suffix_{first,second}_alert, /list-item at 800x800.
// The browser event is observed through the callback test seam; the actual
// native window.alert API is implemented by list_item_native_alert_web.dart.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_design/seed_design.dart';
import 'package:seed_design_example/stackflow_spa/navigation_pages.dart'
    show debugListItemNativeAlert;
import 'package:seed_design_example/stackflow_spa/stackflow_spa.dart';

Future<Finder> _openSuffix(WidgetTester tester, int suffixIndex) async {
  tester.view.physicalSize = const Size(800, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(const StackflowSpaApp());
  await tester.pumpAndSettle();
  tester.state<NavigatorState>(find.byType(Navigator)).pushNamed('/list-item');
  await tester.pumpAndSettle();

  final row = find.byKey(const ValueKey('none-title-buttons'));
  expect(row, findsOneWidget);
  final suffixes = find.descendant(of: row, matching: find.byType(SeedButton));
  expect(suffixes, findsNWidgets(2));
  final first = suffixes.first;
  final second = suffixes.last;
  expect(tester.widget<SeedButton>(first).label, '라벨');
  expect(tester.widget<SeedButton>(first).size, SeedButtonSize.xsmall);
  expect(tester.widget<SeedButton>(first).onPressed, isNotNull);

  // Each original actor independently targets its named suffix position.
  final firstCenter = tester.getCenter(first);
  final secondCenter = tester.getCenter(second);
  expect(firstCenter.dx, lessThan(secondCenter.dx));
  expect(firstCenter.dx, inInclusiveRange(600, 800));
  expect(firstCenter.dy, inInclusiveRange(175, 325));

  // Keep the actual accessible action and label, not only the visible text.
  final semantics = tester.getSemantics(first);
  expect(semantics.label, '라벨');
  expect(semantics.flagsCollection.isButton, true);
  final target = suffixes.at(suffixIndex);
  expect(tester.getSemantics(target).label, '라벨');
  expect(tester.getSemantics(target).flagsCollection.isButton, true);
  return target;
}

void main() {
  for (final suffixIndex in [0, 1]) {
    final position = suffixIndex == 0 ? 'first' : 'second';
    testWidgets(
      '800 $position suffix sends one native alert message without modal, snackbar or route change',
      (tester) async {
        final handle = tester.ensureSemantics();
        final messages = <String>[];
        debugListItemNativeAlert = messages.add;
        addTearDown(() {
          debugListItemNativeAlert = null;
        });

        final first = await _openSuffix(tester, suffixIndex);
        final route = ModalRoute.of(tester.element(first));
        expect(route?.isCurrent, true);

        await tester.tap(first);
        await tester.pumpAndSettle();

        expect(messages, ['Button clicked']);
        expect(find.byType(SeedAlertDialog), findsNothing);
        expect(find.byType(SeedSnackbar), findsNothing);
        expect(ModalRoute.of(tester.element(first)), same(route));
        expect(route?.isCurrent, true);
        expect(tester.takeException(), isNull);
        handle.dispose();
      },
    );

    testWidgets(
      '800 $position suffix native Flutter keeps accessible modal fallback when no browser alert exists',
      (tester) async {
        final handle = tester.ensureSemantics();
        debugListItemNativeAlert = null;
        addTearDown(() {
          debugListItemNativeAlert = null;
        });

        final first = await _openSuffix(tester, suffixIndex);
        final route = ModalRoute.of(tester.element(first));
        await tester.tap(first);
        await tester.pumpAndSettle();

        expect(find.byType(SeedAlertDialog), findsOneWidget);
        expect(find.text('Button clicked'), findsOneWidget);
        expect(find.byType(SeedSnackbar), findsNothing);

        await tester.tap(find.widgetWithText(SeedButton, '확인').last);
        await tester.pumpAndSettle();
        expect(find.byType(SeedAlertDialog), findsNothing);
        expect(ModalRoute.of(tester.element(first)), same(route));
        expect(route?.isCurrent, true);
        expect(tester.takeException(), isNull);
        handle.dispose();
      },
    );
  }
}
