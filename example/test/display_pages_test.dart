import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_design/seed_design.dart';
import 'package:seed_design_example/stackflow_spa/stackflow_spa.dart';

Future<void> _open(
  WidgetTester tester,
  String route, {
  required double width,
  required double height,
}) async {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const StackflowSpaApp());
  await tester.pumpAndSettle();
  tester.state<NavigatorState>(find.byType(Navigator).first).pushNamed(route);
  await tester.pumpAndSettle();
}

Finder _panel(String title, int index) =>
    find.byKey(ValueKey('scale-feedback-panel:$title:$index'));

Future<void> _openTypography(
  WidgetTester tester,
  String route, {
  required Size size,
  double textScale = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    textScale == 1
        ? const StackflowSpaApp()
        : MediaQuery(
            data: MediaQueryData(
              size: size,
              textScaler: TextScaler.linear(textScale),
            ),
            child: const StackflowSpaApp(),
          ),
  );
  await tester.pumpAndSettle();
  tester.state<NavigatorState>(find.byType(Navigator).first).pushNamed(route);
  await tester.pumpAndSettle();
}

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

Future<void> _openHome(
  WidgetTester tester, {
  required double width,
  required double height,
  double scale = 1,
}) async {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(
        size: Size(width, height),
        textScaler: TextScaler.linear(scale),
      ),
      child: const StackflowSpaApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('ScaleFeedback and Typography', () {
    testWidgets('ScaleFeedback list toggle remains functional after split', (
      tester,
    ) async {
      await _open(tester, '/scale-feedback', width: 390, height: 844);
      final stage = _panel('Checkbox / RadioGroup — ListItem 안', 0);
      final prefixRow = find
          .descendant(of: stage, matching: find.byType(SeedListItem))
          .first;
      expect(tester.widget<SeedListItem>(prefixRow).checked, true);
      await tester.ensureVisible(find.text('prefix Checkmark'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('prefix Checkmark'));
      await tester.pumpAndSettle();
      expect(tester.widget<SeedListItem>(prefixRow).checked, false);
      expect(tester.takeException(), isNull);
    });
    testWidgets(
      'Typography steps stay scrollable without overflow at 320/200%',
      (tester) async {
        await _openTypography(
          tester,
          '/typography-scale',
          size: const Size(320, 568),
          textScale: 2,
        );
        expect(find.text('t1'), findsOneWidget);
        final list = find.byType(ListView).first;
        final scroll = find
            .descendant(of: list, matching: find.byType(Scrollable))
            .first;
        expect(
          tester.state<ScrollableState>(scroll).position.maxScrollExtent,
          greaterThan(568),
        );
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('ActionButton analyzer', () {
    testWidgets(
      'React ALL variant expands action-button showcase into a grid',
      (tester) async {
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
      },
    );
  });

  group('MannerTemp', () {
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
  });

  group('ScaleFeedback Home action', () {
    testWidgets('ScaleFeedback AppBarRight Home action returns to Home', (
      tester,
    ) async {
      await _openHome(tester, width: 390, height: 844);
      tester
          .state<NavigatorState>(find.byType(Navigator))
          .pushNamed('/scale-feedback');
      await tester.pumpAndSettle();
      final homeAction = find.byWidgetPredicate(
        (widget) =>
            widget is SeedTopNavigationIconButton &&
            widget.semanticsLabel == '홈',
      );
      expect(homeAction, findsOneWidget);
      await tester.tap(homeAction);
      await tester.pumpAndSettle();
      expect(find.byType(CustomScrollView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
