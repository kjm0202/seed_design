import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' as seed_material;
import 'package:seed_design/seed_design.dart';
import 'package:seed_design_example/stackflow_spa/stackflow_spa.dart';

void main() {
  Finder action(String label) => find.byWidgetPredicate(
    (widget) =>
        widget is SeedTopNavigationIconButton && widget.semanticsLabel == label,
  );

  for (final initialBrightness in [Brightness.light, Brightness.dark]) {
    testWidgets('home theme menu selects auto, light, dark across routes '
        'from $initialBrightness', (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = initialBrightness;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      await tester.pumpWidget(const StackflowSpaApp());
      await tester.pumpAndSettle();

      final initialContext = tester.element(find.text('Home'));
      expect(Theme.of(initialContext).brightness, initialBrightness);
      expect(
        seed_material.Theme.of(initialContext).brightness,
        initialBrightness,
      );
      expect(action('알림'), findsOneWidget);
      expect(action('테마 설정: 자동'), findsOneWidget);
      expect(
        tester.getTopLeft(action('테마 설정: 자동')).dx,
        lessThan(tester.getTopLeft(action('알림')).dx),
      );

      await tester.tap(action('테마 설정: 자동'));
      await tester.pumpAndSettle();
      final menu = tester.widget<SeedMenu>(find.byType(SeedMenu));
      expect(menu.groups.single.items.map((item) => item.label).toList(), [
        '자동',
        '라이트',
        '다크',
      ]);
      expect(menu.groups.single.items[0].suffixIcon, isNotNull);
      expect(menu.groups.single.items[1].suffixIcon, isNull);
      expect(menu.groups.single.items[2].suffixIcon, isNull);

      final nextBrightness = initialBrightness == Brightness.dark
          ? Brightness.light
          : Brightness.dark;
      final selectedLabel = nextBrightness == Brightness.dark ? '다크' : '라이트';
      await tester.tap(find.text(selectedLabel));
      await tester.pumpAndSettle();
      final homeContext = tester.element(find.text('Home'));
      expect(Theme.of(homeContext).brightness, nextBrightness);
      expect(seed_material.Theme.of(homeContext).brightness, nextBrightness);
      expect(action('테마 설정: $selectedLabel'), findsOneWidget);
      expect(find.byType(SeedMenu), findsNothing);

      // Manual selection continues to override changes to the OS preference.
      tester.platformDispatcher.platformBrightnessTestValue = nextBrightness;
      await tester.pumpAndSettle();
      tester.platformDispatcher.platformBrightnessTestValue = initialBrightness;
      await tester.pumpAndSettle();
      expect(Theme.of(homeContext).brightness, nextBrightness);

      await tester.tap(find.text('App Bar 슬롯과 긴 제목'));
      await tester.pumpAndSettle();
      final detailContext = tester.element(find.text('ActivityTransparentBar'));
      expect(Theme.of(detailContext).brightness, nextBrightness);
      expect(seed_material.Theme.of(detailContext).brightness, nextBrightness);

      await tester.tap(find.text('‹  Back'));
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
      expect(
        Theme.of(tester.element(find.text('Home'))).brightness,
        nextBrightness,
      );
      expect(action('알림'), findsOneWidget);
      expect(action('테마 설정: $selectedLabel'), findsOneWidget);

      // The same button also allows selecting the other manual theme.
      await tester.tap(action('테마 설정: $selectedLabel'));
      await tester.pumpAndSettle();
      final manualMenu = tester.widget<SeedMenu>(find.byType(SeedMenu));
      expect(
        manualMenu.groups.single.items
            .singleWhere((item) => item.label == selectedLabel)
            .suffixIcon,
        isNotNull,
      );
      final otherLabel = initialBrightness == Brightness.dark ? '다크' : '라이트';
      await tester.tap(find.text(otherLabel));
      await tester.pumpAndSettle();
      expect(
        Theme.of(tester.element(find.text('Home'))).brightness,
        initialBrightness,
      );
      expect(action('테마 설정: $otherLabel'), findsOneWidget);

      // Auto resumes live system changes, unlike either explicit selection.
      await tester.tap(action('테마 설정: $otherLabel'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('자동'));
      await tester.pumpAndSettle();
      expect(action('테마 설정: 자동'), findsOneWidget);
      expect(
        Theme.of(tester.element(find.text('Home'))).brightness,
        initialBrightness,
      );
      tester.platformDispatcher.platformBrightnessTestValue = nextBrightness;
      await tester.pumpAndSettle();
      final autoContext = tester.element(find.text('Home'));
      expect(Theme.of(autoContext).brightness, nextBrightness);
      expect(seed_material.Theme.of(autoContext).brightness, nextBrightness);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('390px home keeps one theme action and anchored three-way menu', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const StackflowSpaApp());
    await tester.pumpAndSettle();
    expect(action('테마 설정: 자동'), findsOneWidget);
    await tester.tap(action('테마 설정: 자동'));
    await tester.pumpAndSettle();
    final menuRect = tester.getRect(find.byType(SeedMenu));
    expect(menuRect.left, greaterThanOrEqualTo(0));
    expect(menuRect.right, lessThanOrEqualTo(390));

    await tester.tap(find.text('다크'));
    await tester.pumpAndSettle();
    expect(action('테마 설정: 다크'), findsOneWidget);
    await tester.tap(action('테마 설정: 다크'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('자동'));
    await tester.pumpAndSettle();
    expect(action('테마 설정: 자동'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
