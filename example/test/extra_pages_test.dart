import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_design/seed_design.dart';
import 'package:seed_design_example/stackflow_spa/stackflow_spa.dart';
import 'package:seed_design_example/stackflow_spa/extra_pages.dart';
import 'package:seed_design_example/stackflow_spa/spa_types.dart';

Future<void> _route(
  WidgetTester tester,
  String route, {
  Object? arguments,
}) async {
  await tester.pumpWidget(const StackflowSpaApp());
  await tester.pumpAndSettle();
  tester
      .state<NavigatorState>(find.byType(Navigator).first)
      .pushNamed(route, arguments: arguments);
  await tester.pumpAndSettle();
}

Future<void> _direct(WidgetTester tester, String route) async {
  await tester.pumpWidget(const StackflowSpaApp());
  await tester.pumpAndSettle();
  final done = Completer<void>();
  tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    SystemChannels.navigation.name,
    SystemChannels.navigation.codec.encodeMethodCall(
      MethodCall('pushRouteInformation', {'location': route, 'state': null}),
    ),
    (_) => done.complete(),
  );
  await tester.pump();
  await done.future;
  await tester.pumpAndSettle();
}

void main() {
  for (final width in [390.0, 800.0]) {
    testWidgets('direct URL app-bar-slot has no back $width', (tester) async {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await _direct(tester, '/app-bar-slot');
      expect(find.byIcon(Icons.chevron_left), findsNothing);
      expect(find.byType(SeedTopNavigation), findsOneWidget);
    });

    testWidgets(
      'direct URL AlertDialogStackflow has no stray host AppBar $width',
      (tester) async {
        tester.view.physicalSize = Size(width, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await _direct(tester, '/alert-dialog-stackflow');
        expect(find.byType(SeedTopNavigation), findsNothing);
        final action = find.widgetWithText(SeedButton, '확인');
        expect(
          tester.widget<SeedButton>(action).variant,
          SeedButtonVariant.neutralSolid,
        );
      },
    );

    testWidgets('direct URL CategorySheet has no stray host AppBar $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await _direct(tester, '/category-sheet');
      expect(find.byType(SeedTopNavigation), findsNothing);
      expect(find.byType(SeedBottomSheet), findsOneWidget);
    });
    testWidgets(
      'detail: one header title, body once, no invented Home text $width',
      (tester) async {
        tester.view.physicalSize = Size(width, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await _route(
          tester,
          '/detail',
          arguments: {'title': 'Only Real Title', 'body': 'Only Real Body'},
        );
        expect(find.text('Only Real Title'), findsOneWidget);
        expect(find.text('Only Real Body'), findsOneWidget);
        expect(find.text('홈으로'), findsNothing);
      },
    );

    testWidgets(
      'stackflow alert: backdrop no AppBar and neutral confirm $width',
      (tester) async {
        tester.view.physicalSize = Size(width, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await _route(tester, '/alert-dialog-stackflow');
        expect(find.byType(SeedAlertDialog), findsOneWidget);
        expect(find.byType(SeedTopNavigation), findsNothing);
        final action = find.widgetWithText(SeedButton, '확인');
        expect(
          tester.widget<SeedButton>(action).variant,
          SeedButtonVariant.neutralSolid,
        );
        await tester.tap(action);
        await tester.pumpAndSettle();
        expect(find.byType(SeedAlertDialog), findsNothing);
      },
    );

    testWidgets(
      'category: background no AppBar and zero invented row dividers $width',
      (tester) async {
        tester.view.physicalSize = Size(width, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await _route(tester, '/category-sheet');
        expect(find.byType(SeedBottomSheet), findsOneWidget);
        expect(find.byType(SeedTopNavigation), findsNothing);
        final rows = find.byType(SeedRadioListItem<String>);
        expect(rows, findsWidgets);
        for (final row in tester.widgetList<SeedRadioListItem<String>>(rows)) {
          expect(row.showDivider, false);
        }
        await tester.tap(find.text('전자기기'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('완료'));
        await tester.pumpAndSettle();
        expect(find.byType(SeedBottomSheet), findsNothing);
      },
    );

    testWidgets('dialog: 16 neutral switch and no invented Home $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await _route(tester, '/dialog');
      final toggle = tester.widget<SeedSwitch>(find.byType(SeedSwitch));
      expect(toggle.size, SeedSwitchSize.size16);
      expect(toggle.tone, SeedControlTone.neutral);
      expect(find.text('홈으로'), findsNothing);
      await tester.tap(find.text('다이얼로그 열기'));
      await tester.pumpAndSettle();
      expect(find.byType(SeedDialog), findsOneWidget);
    });
  }

  testWidgets(
    'app-bar-slot root hides back and bell buttons do nothing; nested has back',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final page = buildExtraPage(
                'ActivityAppBarSlot',
                context,
                navigate: (name, {arguments}) {},
                goBack: () {},
              );
              return page as SpaOwnScaffold;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.chevron_left), findsNothing);
      final bell = tester
          .widgetList<SeedTopNavigationIconButton>(
            find.byType(SeedTopNavigationIconButton),
          )
          .toList();
      expect(bell.length, 2);
      for (final icon in bell) {
        expect(icon.onPressed, isNull);
      }
      await tester.pumpWidget(const StackflowSpaApp());
      await tester.pumpAndSettle();
      tester
          .state<NavigatorState>(find.byType(Navigator).first)
          .pushNamed('/app-bar-slot');
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    },
  );
}
