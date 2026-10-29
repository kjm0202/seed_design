import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_design/seed_design.dart';
import 'package:seed_design_example/stackflow_spa/navigation_pages.dart'
    show debugListItemNativeAlert;
import 'package:seed_design_example/stackflow_spa/stackflow_spa.dart';

Future<Finder> _openListButtonPage(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(const StackflowSpaApp());
  await tester.pumpAndSettle();
  tester
      .state<NavigatorState>(find.byType(Navigator))
      .pushNamed('/list-item-button');
  await tester.pumpAndSettle();
  return find.byKey(const ValueKey('none-title-buttons'));
}

Finder _suffixes(Finder row) =>
    find.descendant(of: row, matching: find.byType(SeedButton));

void main() {
  testWidgets(
    'suffix buttons are accessible and inert; the row opens its dialog',
    (tester) async {
      final alerts = <String>[];
      debugListItemNativeAlert = alerts.add;
      addTearDown(() => debugListItemNativeAlert = null);
      final semantics = tester.ensureSemantics();
      final row = await _openListButtonPage(tester);
      expect(row, findsOneWidget);
      final route = ModalRoute.of(tester.element(row));
      final buttons = _suffixes(row);
      expect(buttons, findsNWidgets(2));
      expect(
        tester.getCenter(buttons.first).dx,
        lessThan(tester.getCenter(buttons.last).dx),
      );

      for (var index = 0; index < 2; index++) {
        final button = buttons.at(index);
        final widget = tester.widget<SeedButton>(button);
        expect(widget.label, '라벨');
        expect(widget.size, SeedButtonSize.xsmall);
        expect(widget.variant, SeedButtonVariant.neutralWeak);
        expect(widget.onPressed, isNotNull);
        final node = tester.getSemantics(button);
        expect(node.label, '라벨');
        expect(node.flagsCollection.isButton, isTrue);

        await tester.tap(button);
        await tester.pumpAndSettle();
        expect(find.byType(SeedSnackbar), findsNothing);
        expect(find.byType(SeedAlertDialog), findsNothing);
        expect(alerts, isEmpty);
        expect(ModalRoute.of(tester.element(row)), same(route));
        expect(route?.isCurrent, isTrue);
      }
      semantics.dispose();

      await tester.tapAt(Offset(85, tester.getCenter(buttons.first).dy));
      await tester.pumpAndSettle();
      expect(find.byType(SeedAlertDialog), findsOneWidget);
      expect(find.text('consectetur'), findsOneWidget);
      await tester.tap(find.widgetWithText(SeedButton, '닫기').last);
      await tester.pumpAndSettle();
      expect(find.byType(SeedAlertDialog), findsNothing);
      expect(ModalRoute.of(tester.element(row)), same(route));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('suffix buttons do not replace or renew an existing snackbar', (
    tester,
  ) async {
    final alerts = <String>[];
    debugListItemNativeAlert = alerts.add;
    addTearDown(() => debugListItemNativeAlert = null);
    final row = await _openListButtonPage(tester);
    final route = ModalRoute.of(tester.element(row));
    final buttons = _suffixes(row);
    expect(buttons, findsNWidgets(2));
    var closeCount = 0;
    SeedSnackbarProvider.of(tester.element(row)).show(
      child: const SeedSnackbar(message: 'Button clicked'),
      duration: const Duration(milliseconds: 1200),
      onClose: () => closeCount++,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    for (var index = 0; index < 2; index++) {
      await tester.tap(buttons.at(index));
      await tester.pump();
      expect(closeCount, 0);
      expect(find.byType(SeedSnackbar), findsOneWidget);
      expect(find.byType(SeedAlertDialog), findsNothing);
      expect(alerts, isEmpty);
      expect(ModalRoute.of(tester.element(row)), same(route));
    }
    await tester.pump(const Duration(milliseconds: 1250));
    await tester.pumpAndSettle();
    expect(closeCount, 1);
    expect(find.byType(SeedSnackbar), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
