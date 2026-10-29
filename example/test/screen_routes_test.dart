import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_design/seed_design.dart';
import 'package:seed_design_example/stackflow_spa/stackflow_spa.dart';

Future<NavigatorState> _open(
  WidgetTester tester,
  String path,
  double width,
) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, width == 390 ? 844 : 800);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const StackflowSpaApp());
  await tester.pumpAndSettle();
  final nav = tester.state<NavigatorState>(find.byType(Navigator));
  nav.pushNamed(path);
  await tester.pumpAndSettle();
  return nav;
}

Future<void> _visitBrowserHistory(
  WidgetTester tester,
  String path,
  Object? state,
) async {
  final done = Completer<void>();
  tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    SystemChannels.navigation.name,
    SystemChannels.navigation.codec.encodeMethodCall(
      MethodCall('pushRouteInformation', {'location': path, 'state': state}),
    ),
    (_) => done.complete(),
  );
  await tester.pump();
  await done.future;
  await tester.pumpAndSettle();
}

void main() {
  for (final width in [390.0, 800.0]) {
    testWidgets(
      'INC article pull has selectable protected origin and separate plain outside $width',
      (tester) async {
        await _open(tester, '/article-prevent-pull', width);
        final protectedText = find.byType(SelectableText);
        expect(protectedText, findsOneWidget);
        expect(
          tester.widget<SelectableText>(protectedText).data,
          contains('Article 내부'),
        );
        expect(find.byType(SeedPullToRefreshPreventPull), findsOneWidget);
        final textOutside = find.textContaining('이 요소는 Article 외부에 있으므로');
        expect(textOutside, findsOneWidget);
        expect(
          tester.widget<Text>(textOutside).data,
          contains('PTR을 호출할 수 있습니다'),
        );
        expect(
          tester
              .widget<SeedPullToRefresh>(find.byType(SeedPullToRefresh))
              .enabled,
          isTrue,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'INC protected Article gesture never arms PTR even when dragged into the outside area $width',
      (tester) async {
        await _open(tester, '/article-prevent-pull', width);
        final origin = tester.getCenter(find.byType(SelectableText));
        final gesture = await tester.startGesture(origin, pointer: 7);
        for (var i = 0; i < 5; i++) {
          await gesture.moveBy(const Offset(0, 36));
          await tester.pump(const Duration(milliseconds: 16));
        }
        expect(
          tester
              .widget<SeedProgressCircle>(find.byType(SeedProgressCircle))
              .value,
          0,
        );
        await gesture.up();
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<SeedProgressCircle>(find.byType(SeedProgressCircle))
              .value,
          0,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'INC outside Article downward gesture arms PTR and returns to idle $width',
      (tester) async {
        await _open(tester, '/article-prevent-pull', width);
        final outside = find.textContaining('이 요소는 Article 외부에 있으므로');
        final origin = tester.getCenter(outside);
        final gesture = await tester.startGesture(origin, pointer: 8);
        for (var i = 0; i < 7; i++) {
          await gesture.moveBy(const Offset(0, 35));
          await tester.pump(const Duration(milliseconds: 16));
        }
        expect(
          tester
              .widget<SeedProgressCircle>(find.byType(SeedProgressCircle))
              .value,
          1,
        );
        await gesture.up();
        await tester.pump(const Duration(milliseconds: 1100));
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<SeedProgressCircle>(find.byType(SeedProgressCircle))
              .value,
          0,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'INC swipe keyboard retains original draft and loses focus after child Back $width',
      (tester) async {
        final nav = await _open(tester, '/swipe-back-keyboard', width);
        final input = find.byType(TextField);
        expect(input, findsOneWidget);
        final semantics = tester.getSemantics(input);
        expect(semantics.label, contains('검색어'));
        await tester.enterText(input, 'semantic-2026');
        tester.testTextInput.hide();
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pump();
        expect(find.text('입력 포커스: 없음'), findsOneWidget);
        await tester.tap(find.text('입력 화면 한 장 더 열기'));
        await tester.pumpAndSettle();
        expect(find.byType(TextField, skipOffstage: false), findsNWidgets(2));
        nav.pop();
        await tester.pumpAndSettle();
        expect(find.byType(TextField), findsOneWidget);
        expect(
          tester.widget<TextField>(input).controller?.text ??
              tester
                  .state<EditableTextState>(find.byType(EditableText))
                  .textEditingValue
                  .text,
          'semantic-2026',
        );
        expect(find.text('입력 포커스: 없음'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'INC swipe keyboard direct URL same-route PUSH then browser history Back retains parent draft $width',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, width == 390 ? 844 : 800);
        addTearDown(tester.view.reset);
        final browserEntries = <Map<dynamic, dynamic>>[];
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.navigation,
          (call) async {
            if (call.method == 'routeInformationUpdated') {
              browserEntries.add(
                Map<dynamic, dynamic>.from(call.arguments as Map),
              );
            }
            return null;
          },
        );
        addTearDown(
          () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            SystemChannels.navigation,
            null,
          ),
        );
        await tester.pumpWidget(const StackflowSpaApp());
        await tester.pumpAndSettle();
        await _visitBrowserHistory(tester, '/swipe-back-keyboard', null);
        final input = find.byType(TextField);
        expect(input, findsOneWidget);
        await tester.enterText(input, 'semantic-2026');
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        await tester.tap(find.text('입력 화면 한 장 더 열기'));
        await tester.pumpAndSettle();
        expect(find.byType(TextField, skipOffstage: false), findsNWidgets(2));
        expect(browserEntries.last['uri'], '/swipe-back-keyboard');
        final published = Map<dynamic, dynamic>.from(
          browserEntries.last['state'] as Map,
        );
        final stack = published['seedActivities'] as List;
        expect(stack.length, 2);
        // This is the preceding browser entry's serialized state, immediately
        // before the same-URI PUSH. The prefix identifies the retained parent.
        await _visitBrowserHistory(tester, '/swipe-back-keyboard', {
          'seedActivities': [stack.first],
        });
        expect(find.byType(TextField), findsOneWidget);
        expect(
          tester
              .state<EditableTextState>(find.byType(EditableText))
              .textEditingValue
              .text,
          'semantic-2026',
        );
        expect(find.text('입력 포커스: 없음'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'INC intersection scroller leaves and returns to white region $width',
      (tester) async {
        await _open(tester, '/app-screen-intersection-observer', width);
        SeedTopNavigation appBar() =>
            tester.widget(find.byType(SeedTopNavigation));
        expect(appBar().tone, SeedTopNavigationTone.transparent);
        final scroll = tester
            .widget<ListView>(find.byType(ListView))
            .controller!;
        scroll.jumpTo(401);
        await tester.pumpAndSettle();
        expect(appBar().tone, SeedTopNavigationTone.layer);
        scroll.jumpTo(0);
        await tester.pumpAndSettle();
        expect(appBar().tone, SeedTopNavigationTone.transparent);
      },
    );

    testWidgets(
      'INC image list retains six configured variants after scroll return $width',
      (tester) async {
        await _open(tester, '/list-image-frame', width);
        final list = find.byType(ListView).last;
        final first = find.text('ratio=1, width=96');
        final last = find.text('ratio=3/4, width=120');
        expect(first, findsOneWidget);
        await tester.scrollUntilVisible(
          last,
          160,
          scrollable: find
              .descendant(of: list, matching: find.byType(Scrollable))
              .first,
        );
        await tester.pumpAndSettle();
        expect(last, findsOneWidget);
        final listState = tester.state<ScrollableState>(
          find.descendant(of: list, matching: find.byType(Scrollable)).first,
        );
        expect(listState.position.pixels, greaterThan(0));
        listState.position.jumpTo(0);
        await tester.pumpAndSettle();
        expect(first, findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'INC list starts nonzero then one continuous contact returns to zero and arms PTR $width',
      (tester) async {
        await _open(tester, '/list-image-frame', width);
        final list = find.byType(ListView).last;
        final scrollable = find
            .descendant(of: list, matching: find.byType(Scrollable))
            .first;
        final position = tester.state<ScrollableState>(scrollable).position;
        expect(position.maxScrollExtent, greaterThan(0));
        position.jumpTo(math.min(80, position.maxScrollExtent));
        await tester.pumpAndSettle();
        expect(position.pixels, greaterThan(0));

        final listRect = tester.getRect(list);
        final origin = Offset(listRect.center.dx, listRect.top + 120);
        final gesture = await tester.startGesture(origin, pointer: 12);
        for (var i = 0; i < 24; i++) {
          await gesture.moveBy(const Offset(0, 15));
          await tester.pump(const Duration(milliseconds: 16));
        }
        expect(position.pixels, closeTo(0, 0.01));
        expect(
          tester
              .widget<SeedProgressCircle>(find.byType(SeedProgressCircle))
              .value,
          1,
        );
        await gesture.up();
        await tester.pump(const Duration(milliseconds: 16));
        expect(
          tester
              .widget<SeedProgressCircle>(find.byType(SeedProgressCircle))
              .value,
          isNull,
        );
        // A second contact during the original in-flight refresh must leave
        // the first Future in control. A follow-up pull after settlement can
        // still become ready from the same visible list.
        final retry = await tester.startGesture(origin, pointer: 13);
        for (var i = 0; i < 12; i++) {
          await retry.moveBy(const Offset(0, 20));
          await tester.pump(const Duration(milliseconds: 16));
        }
        expect(
          tester
              .widget<SeedProgressCircle>(find.byType(SeedProgressCircle))
              .value,
          isNull,
        );
        await retry.up();
        await tester.pump(const Duration(milliseconds: 1100));
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<SeedProgressCircle>(find.byType(SeedProgressCircle))
              .value,
          0,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'INC article drag preserves first tab on protected gesture $width',
      (tester) async {
        await _open(tester, '/article-prevent-drag', width);
        SeedTabs tabs() => tester.widget(find.byType(SeedTabs).first);
        expect(tabs().selectedIndex, 0);
        final paragraph = find.textContaining('이 요소는 Article 내부에 있으므로');
        await tester.drag(paragraph, const Offset(-170, 0));
        await tester.pumpAndSettle();
        expect(tabs().selectedIndex, 0);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'INC article drag outside protected text advances to second tab $width',
      (tester) async {
        await _open(tester, '/article-prevent-drag', width);
        SeedTabs tabs() => tester.widget(find.byType(SeedTabs).first);
        expect(tabs().selectedIndex, 0);
        final outside = find.textContaining('이 요소는 Article 외부에 있으므로');
        // Commit the page change at both viewport widths; 220px is less than
        // half of the 800px carousel and correctly snaps back at that size.
        await tester.drag(outside, Offset(-width * 0.65, 0));
        await tester.pumpAndSettle();
        expect(tabs().selectedIndex, 1);
        expect(find.text('안녕하세요!'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
