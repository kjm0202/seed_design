import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

Widget _app({
  required Widget appBar,
  TextDirection direction = TextDirection.ltr,
  double scale = 1,
}) => MaterialApp(
  theme: SeedThemeData.light().toThemeData(),
  home: Directionality(
    textDirection: direction,
    child: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(scale)),
      child: Scaffold(appBar: appBar as PreferredSizeWidget),
    ),
  ),
);

void main() {
  testWidgets('AppBar.Slot edge-overhanging icon keeps full 44px hit target', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    var firstTaps = 0;
    var lastTaps = 0;
    await tester.pumpWidget(
      _app(
        appBar: SeedTopNavigation(
          automaticallyImplyLeading: false,
          slot: const SizedBox.expand(),
          actions: [
            SeedTopNavigationIconButton(
              icon: const Icon(Icons.notifications_none_rounded),
              onPressed: () => firstTaps++,
            ),
            SeedTopNavigationIconButton(
              icon: const Icon(Icons.notifications_none_rounded),
              onPressed: () => lastTaps++,
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    // Official CSS icon buttons are still 44px hit targets even when their
    // first/last negative margins reduce flex *layout* width by 20px.
    // The points below are within the painted 44px buttons but outside the
    // reduced 68px logical trailing flex area: x=296..305 and x=374..383.
    await tester.tapAt(const Offset(298, 28));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(382, 28));
    await tester.pumpAndSettle();
    expect(firstTaps, 1);
    expect(lastTaps, 1);
    expect(tester.takeException(), isNull);
  });

  group('AppBar.Slot with text buttons follows the official CSS margins', () {
    const slotKey = Key('slot');
    Finder buttonOf(String label) => find.ancestor(
      of: find.text(label),
      matching: find.byType(SeedTopNavigationTextButton),
    );

    Future<void> pumpBar(
      WidgetTester tester,
      SeedTopNavigation bar, {
      TextDirection direction = TextDirection.ltr,
    }) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_app(appBar: bar, direction: direction));
      await tester.pumpAndSettle();
    }

    testWidgets('trailing text button overhangs the 16px padding by 10px', (
      tester,
    ) async {
      var taps = 0;
      await pumpBar(
        tester,
        SeedTopNavigation(
          automaticallyImplyLeading: false,
          slot: const SizedBox.expand(key: slotKey),
          actions: [
            SeedTopNavigationTextButton(text: '닫기', onPressed: () => taps++),
          ],
        ),
      );
      final slot = tester.getRect(find.byKey(slotKey));
      final label = tester.getRect(find.text('닫기'));
      final button = tester.getRect(buttonOf('닫기'));
      // `.seed-app-bar__textButton:first-child/:last-child` margins are
      // x1_5 - x4 = -10px: the label's right edge sits on the bar padding.
      expect(label.right, closeTo(374, 0.01));
      expect(button.right, closeTo(384, 0.01));
      expect(button.left, closeTo(label.left - 10, 0.01));
      expect(button.height, 44);
      expect(slot.left, 16);
      expect(slot.right, closeTo(label.left, 0.01));
      // Both 10px overhangs (over the slot and past the bar padding) remain
      // part of the button's hit target.
      await tester.tapAt(Offset(button.left + 2, 28));
      await tester.pumpAndSettle();
      await tester.tapAt(Offset(button.right - 2, 28));
      await tester.pumpAndSettle();
      expect(taps, 2);
      expect(tester.takeException(), isNull);
    });

    testWidgets('leading text button adds the android left padding', (
      tester,
    ) async {
      var taps = 0;
      await pumpBar(
        tester,
        SeedTopNavigation(
          automaticallyImplyLeading: false,
          leading: SeedTopNavigationTextButton(
            text: '취소',
            onPressed: () => taps++,
          ),
          slot: const SizedBox.expand(key: slotKey),
        ),
      );
      final slot = tester.getRect(find.byKey(slotKey));
      final label = tester.getRect(find.text('취소'));
      expect(label.left, closeTo(16, 0.01));
      expect(tester.getRect(buttonOf('취소')).left, closeTo(6, 0.01));
      // android `.seed-app-bar__left { padding-right: 16px }`.
      expect(slot.left, closeTo(label.right + 16, 0.01));
      expect(slot.right, 374);
      await tester.tapAt(const Offset(8, 28));
      await tester.pumpAndSettle();
      expect(taps, 1);
    });

    testWidgets('cupertino leading text button has no left padding', (
      tester,
    ) async {
      await pumpBar(
        tester,
        SeedTopNavigation(
          automaticallyImplyLeading: false,
          platform: SeedTopNavigationPlatform.cupertino,
          leading: SeedTopNavigationTextButton(text: '취소', onPressed: () {}),
          slot: const SizedBox.expand(key: slotKey),
        ),
      );
      final label = tester.getRect(find.text('취소'));
      expect(label.left, closeTo(16, 0.01));
      expect(
        tester.getRect(find.byKey(slotKey)).left,
        closeTo(label.right, 0.01),
      );
    });

    testWidgets('mixed icon and text actions only offset the outer edges', (
      tester,
    ) async {
      await pumpBar(
        tester,
        SeedTopNavigation(
          automaticallyImplyLeading: false,
          slot: const SizedBox.expand(key: slotKey),
          actions: [
            SeedTopNavigationIconButton(
              icon: const Icon(Icons.notifications_none_rounded),
              onPressed: () {},
            ),
            SeedTopNavigationTextButton(text: '완료', onPressed: () {}),
          ],
        ),
      );
      final icon = tester.getRect(find.byType(SeedTopNavigationIconButton));
      final text = tester.getRect(buttonOf('완료'));
      expect(text.right, closeTo(384, 0.01));
      expect(icon.right, closeTo(text.left, 0.01));
      expect(icon.width, 44);
      expect(
        tester.getRect(find.byKey(slotKey)).right,
        closeTo(icon.left + 10, 0.01),
      );
    });

    testWidgets('RTL mirrors the slot and text-button geometry', (
      tester,
    ) async {
      await pumpBar(
        tester,
        direction: TextDirection.rtl,
        SeedTopNavigation(
          automaticallyImplyLeading: false,
          slot: const SizedBox.expand(key: slotKey),
          actions: [SeedTopNavigationTextButton(text: '닫기', onPressed: () {})],
        ),
      );
      final label = tester.getRect(find.text('닫기'));
      expect(label.left, closeTo(16, 0.01));
      expect(tester.getRect(buttonOf('닫기')).left, closeTo(6, 0.01));
      final slot = tester.getRect(find.byKey(slotKey));
      expect(slot.left, closeTo(label.right, 0.01));
      expect(slot.right, 374);
    });
  });

  test('A custom slot cannot also specify a title or subtitle', () {
    expect(
      () => SeedTopNavigation(slot: const SizedBox(), titleText: 'Page'),
      throwsAssertionError,
    );
    expect(
      () => SeedTopNavigation(slot: const SizedBox(), subtitle: 'Second'),
      throwsAssertionError,
    );
  });

  for (final (scale, expected) in [(0.8, 1.0), (2.0, 1.2)]) {
    testWidgets('title and subtitle clamp text scale $scale like React', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        _app(
          scale: scale,
          appBar: const SeedTopNavigation(
            titleText: 'Title',
            subtitle: 'Subtitle',
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (final text in ['Title', 'Subtitle']) {
        final paragraph = tester.renderObject<RenderParagraph>(find.text(text));
        expect(paragraph.textScaler.scale(10), closeTo(10 * expected, 1e-9));
      }
      expect(tester.getSize(find.byType(SeedTopNavigation)).height, 56);
      expect(tester.takeException(), isNull);
    });
  }

  for (final (scale, expected) in [(1.0, 1.0), (1.1, 1.1), (2.0, 1.2)]) {
    testWidgets('text button label clamps text scale $scale like React', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          scale: scale,
          appBar: SeedTopNavigation(
            automaticallyImplyLeading: false,
            title: const Text('Title'),
            actions: [
              SeedTopNavigationTextButton(text: '완료', onPressed: () {}),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      final paragraph = tester.renderObject<RenderParagraph>(find.text('완료'));
      expect(paragraph.textScaler.scale(10), closeTo(10 * expected, 1e-9));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('text button hugs its label in leading and loose slots', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      _app(
        appBar: SeedTopNavigation(
          automaticallyImplyLeading: false,
          leading: SeedTopNavigationTextButton(text: '닫기', onPressed: () {}),
          title: const Text('Title'),
          actions: [SeedTopNavigationTextButton(text: '완료', onPressed: () {})],
        ),
      ),
    );
    await tester.pumpAndSettle();
    for (final label in ['닫기', '완료']) {
      final button = tester.getSize(
        find.ancestor(
          of: find.text(label),
          matching: find.byType(SeedTopNavigationTextButton),
        ),
      );
      final text = tester.getSize(find.text(label));
      expect(button.width, closeTo(text.width + 20, 0.5), reason: label);
      // The leading slot stretches its child to the toolbar height.
      expect(button.height, label == '완료' ? 44 : greaterThanOrEqualTo(44));
    }
    expect(find.text('Title'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
