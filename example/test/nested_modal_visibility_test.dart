import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_design/seed_design.dart';
import 'package:seed_design_example/stackflow_spa/stackflow_spa.dart';

Future<void> _directNested(WidgetTester tester) async {
  final completed = Completer<void>();
  tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    SystemChannels.navigation.name,
    SystemChannels.navigation.codec.encodeMethodCall(
      const MethodCall('pushRouteInformation', {
        'location': '/nested-bottom-sheet',
        'state': null,
      }),
    ),
    (_) => completed.complete(),
  );
  await tester.pump();
  await completed.future;
  await tester.pumpAndSettle();
}

void main() {
  for (final width in [390.0, 800.0]) {
    for (final closeActor in ['footer', 'header']) {
      testWidgets(
        'direct root nested sheet retains content on $closeActor close $width',
        (tester) async {
          tester.view.physicalSize = Size(width, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          await tester.pumpWidget(const StackflowSpaApp());
          await tester.pumpAndSettle();
          await _directNested(tester);
          final close = closeActor == 'footer'
              ? find.widgetWithText(SeedButton, '닫기')
              : find.byWidgetPredicate(
                  (w) =>
                      w is SeedPressable &&
                      w.semanticsLabel == '닫기' &&
                      !w.enableScale,
                );
          expect(close.hitTestable(), findsOneWidget);
          await tester.tap(close);
          await tester.pumpAndSettle();
          expect(
            find.byType(SeedBottomSheet),
            findsOneWidget,
            reason:
                'React pop() does nothing for a directly entered root Activity',
          );
          expect(
            find.widgetWithText(SeedButton, 'Open AlertDialog').hitTestable(),
            findsOneWidget,
          );
          await tester.sendKeyEvent(LogicalKeyboardKey.escape);
          await tester.pumpAndSettle();
          expect(find.byType(SeedBottomSheet), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets('nested modal paints retained parent beneath child $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const StackflowSpaApp());
      await tester.pumpAndSettle();
      await _directNested(tester);
      expect(find.byType(SeedBottomSheet), findsOneWidget);
      final parentRect = tester.getRect(find.byType(SeedBottomSheet));
      await tester.tap(find.widgetWithText(SeedButton, 'Open AlertDialog'));
      await tester.pumpAndSettle();
      expect(find.byType(SeedAlertDialog), findsOneWidget);
      expect(
        find.byType(SeedBottomSheet),
        findsOneWidget,
        reason: 'Mounted offstage content cannot paint the React parent sheet',
      );
      expect(tester.getRect(find.byType(SeedBottomSheet)), parentRect);
      final navigator = Navigator.of(
        tester.element(find.byType(SeedAlertDialog)),
      );
      final childActivity =
          navigator.widget.onGenerateRoute!(
                const RouteSettings(name: '/alert-dialog'),
              )!
              as PageRoute<dynamic>;
      expect(childActivity.opaque, isFalse);
      childActivity.dispose();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(SeedAlertDialog), findsNothing);
      expect(find.byType(SeedBottomSheet), findsOneWidget);
      expect(
        find.widgetWithText(SeedButton, 'Open AlertDialog').hitTestable(),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
