import 'package:material_ui/material_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_design/seed_design.dart';

Widget _host(Widget child, {TextDirection direction = TextDirection.ltr}) {
  return MaterialApp(
    theme: SeedThemeData.light().toThemeData(),
    home: Scaffold(
      body: Center(
        child: Directionality(textDirection: direction, child: child),
      ),
    ),
  );
}

void main() {
  testWidgets('four segments retain 86px minimum and scroll at 240px', (
    tester,
  ) async {
    var selected = 0;
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) => SizedBox(
            width: 240,
            child: SeedSegmentedControl<int>(
              selectedValue: selected,
              onValueChanged: (next) => setState(() => selected = next),
              segments: const [
                SeedSegment(value: 0, label: 'First'),
                SeedSegment(value: 1, label: 'Second'),
                SeedSegment(value: 2, label: 'Third'),
                SeedSegment(value: 3, label: 'Fourth'),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(SeedSegmentedControl<int>)).height, 42);

    final targets = find.descendant(
      of: find.byType(SeedSegmentedControl<int>),
      matching: find.byType(SeedPressable),
    );
    expect(targets, findsNWidgets(4));
    for (final target in targets.evaluate()) {
      expect(
        tester.getSize(find.byElementPredicate((e) => e == target)).width,
        greaterThanOrEqualTo(86),
      );
    }

    await tester.ensureVisible(find.text('Fourth'));
    await tester.tap(find.text('Fourth'));
    await tester.pumpAndSettle();
    expect(selected, 3);
    expect(tester.takeException(), isNull);
  });

  testWidgets('RTL indicator follows the selected segment', (tester) async {
    var selected = 0;
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) => SizedBox(
            width: 320,
            child: SeedSegmentedControl<int>(
              selectedValue: selected,
              onValueChanged: (next) => setState(() => selected = next),
              segments: const [
                SeedSegment(value: 0, label: 'First'),
                SeedSegment(value: 1, label: 'Second'),
                SeedSegment(value: 2, label: 'Third'),
              ],
            ),
          ),
        ),
        direction: TextDirection.rtl,
      ),
    );
    await tester.pumpAndSettle();

    Rect indicatorRect() => tester.getRect(
      find
          .descendant(
            of: find.byType(AnimatedPositioned),
            matching: find.byType(Container),
          )
          .first,
    );

    expect(
      indicatorRect().center.dx,
      closeTo(tester.getCenter(find.text('First')).dx, 1),
    );
    await tester.tap(find.text('Third'));
    await tester.pumpAndSettle();
    expect(selected, 2);
    expect(
      indicatorRect().center.dx,
      closeTo(tester.getCenter(find.text('Third')).dx, 1),
    );
  });

  testWidgets('pressed segment gets official pressed surface and border', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        SizedBox(
          width: 280,
          child: SeedSegmentedControl<int>(
            selectedValue: 0,
            onValueChanged: (_) {},
            segments: const [
              SeedSegment(value: 0, label: 'First'),
              SeedSegment(value: 1, label: 'Second'),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final segments = find.descendant(
      of: find.byType(SeedSegmentedControl<int>),
      matching: find.byType(SeedPressable),
    );
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Second')),
      kind: PointerDeviceKind.touch,
    );
    await tester.pump();
    final pressed = tester.widget<Container>(
      find
          .descendant(of: segments.at(1), matching: find.byType(Container))
          .first,
    );
    final colors = tester.element(segments.at(1)).seedColor;
    final decoration = pressed.decoration! as BoxDecoration;
    expect(decoration.color, colors.bg.neutralWeakPressed);
    expect(decoration.border!.top.color, colors.stroke.neutralMuted);
    expect(decoration.border!.top.width, 1);
    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets(
    '200% text and Korean labels increase minimum height without overflow',
    (tester) async {
      await tester.pumpWidget(
        _host(
          MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2)),
            child: SizedBox(
              width: 240,
              child: SeedSegmentedControl<int>(
                selectedValue: 0,
                onValueChanged: (_) {},
                segments: const [
                  SeedSegment(
                    value: 0,
                    label: '선택한 알림 목록',
                    notificationCount: 99,
                  ),
                  SeedSegment(
                    value: 1,
                    label: '좋아요를 받은 내용',
                    showNotificationDot: true,
                  ),
                  SeedSegment(value: 2, label: '이름이 아주 긴 한글 항목'),
                  SeedSegment(value: 3, label: '마지막 선택지'),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      final root = find.byType(SeedSegmentedControl<int>);
      expect(tester.getSize(root).height, greaterThan(42));
      final segments = find.descendant(
        of: root,
        matching: find.byType(SeedPressable),
      );
      for (final segment in segments.evaluate()) {
        final elementFinder = find.byElementPredicate((e) => e == segment);
        expect(tester.getSize(elementFinder).height, greaterThan(34));
        expect(tester.getSize(elementFinder).width, greaterThanOrEqualTo(86));
      }
      expect(find.byType(SeedNotificationBadge), findsNWidgets(2));
    },
  );

  testWidgets(
    'unbounded horizontal width preserves segmented minimum geometry',
    (tester) async {
      await tester.pumpWidget(
        _host(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SeedSegmentedControl<int>(
                selectedValue: 1,
                onValueChanged: (_) {},
                segments: const [
                  SeedSegment(value: 0, label: '첫 번째'),
                  SeedSegment(value: 1, label: '두 번째'),
                ],
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byType(SeedSegmentedControl<int>)).width,
        greaterThanOrEqualTo(180),
      );
    },
  );

  testWidgets(
    'RTL narrow scroll starts at reading-order first item and arrows expose last',
    (tester) async {
      var selected = 0;
      await tester.pumpWidget(
        _host(
          StatefulBuilder(
            builder: (context, setState) => SizedBox(
              width: 190,
              child: SeedSegmentedControl<int>(
                selectedValue: selected,
                onValueChanged: (next) => setState(() => selected = next),
                segments: const [
                  SeedSegment(value: 0, label: '첫째'),
                  SeedSegment(value: 1, label: '둘째'),
                  SeedSegment(value: 2, label: '셋째'),
                  SeedSegment(value: 3, label: '넷째'),
                ],
              ),
            ),
          ),
          direction: TextDirection.rtl,
        ),
      );
      await tester.pumpAndSettle();
      final viewport = tester.getRect(find.byType(SeedSegmentedControl<int>));
      expect(
        tester.getCenter(find.text('첫째')).dx,
        inInclusiveRange(viewport.left, viewport.right),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      for (var index = 1; index <= 3; index++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await tester.pumpAndSettle();
        expect(selected, index);
      }
      expect(
        tester.getCenter(find.text('넷째')).dx,
        inInclusiveRange(viewport.left, viewport.right),
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('null-callback navigation buttons render disabled foreground', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SeedTopNavigationTextButton(text: '닫힌 메뉴', onPressed: null),
            SeedTopNavigationIconButton(
              icon: Icon(Icons.close),
              onPressed: null,
              semanticsLabel: '닫기',
            ),
            SeedTextButton(label: '작동 안 함', onPressed: null),
          ],
        ),
      ),
    );
    final disabled = tester
        .element(find.byType(SeedTextButton))
        .seedColor
        .fg
        .disabled;
    expect(tester.widget<Text>(find.text('닫힌 메뉴')).style!.color, disabled);
    expect(tester.widget<Text>(find.text('작동 안 함')).style!.color, disabled);
    final icon = find.descendant(
      of: find.byType(SeedTopNavigationIconButton),
      matching: find.byType(IconTheme),
    );
    expect(tester.widget<IconTheme>(icon.last).data.color, disabled);
  });
}
