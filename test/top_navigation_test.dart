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
}
