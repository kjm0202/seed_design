// Strict React ActivityCategorySheet direct-root guard:
// Stackflow pop() cannot pop the only history activity, so the sheet remains.
// Pushed CategorySheet from Form still sends its result and closes normally.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_design/seed_design.dart';
import 'package:seed_design_example/stackflow_spa/stackflow_spa.dart';

Future<void> directCategory(WidgetTester tester) async {
  await tester.pumpWidget(const StackflowSpaApp());
  await tester.pumpAndSettle();
  final done = Completer<void>();
  tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    SystemChannels.navigation.name,
    SystemChannels.navigation.codec.encodeMethodCall(
      const MethodCall('pushRouteInformation', {
        'location': '/category-sheet',
        'state': null,
      }),
    ),
    (_) => done.complete(),
  );
  await tester.pump();
  await done.future;
  await tester.pumpAndSettle();
}

void main() {
  for (final viewport in [const Size(390, 844), const Size(800, 800)]) {
    testWidgets(
      '${viewport.width.toInt()} direct root Fashion→완료 keeps visible sheet, does not leave empty route',
      (tester) async {
        tester.view.physicalSize = viewport;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await directCategory(tester);
        expect(find.byType(SeedBottomSheet), findsOneWidget);
        await tester.tap(find.text('패션/의류'));
        await tester.pumpAndSettle();
        final fashion = find.byWidgetPredicate(
          (w) => w is SeedRadioListItem<String> && w.value == 'fashion',
        );
        expect(
          tester.widget<SeedRadioListItem<String>>(fashion).groupValue,
          'fashion',
        );
        await tester.tap(find.widgetWithText(SeedButton, '완료'));
        await tester.pumpAndSettle();
        expect(find.byType(SeedBottomSheet), findsOneWidget);
        expect(find.text('카테고리 선택'), findsOneWidget);
        expect(
          tester.widget<SeedRadioListItem<String>>(fashion).groupValue,
          'fashion',
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '${viewport.width.toInt()} parent push Fashion→완료 returns value and closes sheet',
      (tester) async {
        tester.view.physicalSize = viewport;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(const StackflowSpaApp());
        await tester.pumpAndSettle();
        final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
        final result = nav.pushNamed('/category-sheet');
        await tester.pumpAndSettle();
        await tester.tap(find.text('패션/의류'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(SeedButton, '완료'));
        await tester.pumpAndSettle();
        expect(await result, {'value': 'fashion', 'label': '패션/의류'});
        expect(find.byType(SeedBottomSheet), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
