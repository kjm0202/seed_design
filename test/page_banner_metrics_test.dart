import 'package:flutter/rendering.dart' show RenderParagraph;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';

const _width = 400.0;
const _prefixKey = Key('page-banner-prefix-icon');

Future<void> _pump(
  WidgetTester tester,
  Widget banner, {
  TextScaler textScaler = TextScaler.noScaling,
  TextDirection textDirection = TextDirection.ltr,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: SeedThemeData.light(fontFamily: seedTestFontFamily).toThemeData(),
      home: MediaQuery(
        data: MediaQueryData.fromView(tester.view)
            .copyWith(textScaler: textScaler),
        child: Directionality(
          textDirection: textDirection,
          child: Scaffold(
            body: Align(
              alignment: AlignmentDirectional.topStart,
              child: SizedBox(width: _width, child: banner),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Rect _banner(WidgetTester tester) =>
    tester.getRect(find.byType(SeedPageBanner));

Rect _prefix(WidgetTester tester) => tester.getRect(find.byKey(_prefixKey));

Finder _linkPressable() => find
    .ancestor(of: find.text('Action'), matching: find.byType(SeedPressable))
    .first;

Finder _closePressable() => find
    .ancestor(
      of: find.byIcon(Icons.close_rounded),
      matching: find.byType(SeedPressable),
    )
    .first;

void main() {
  setUpAll(loadSeedTestFonts);

  group('100% text, single line', () {
    final cases = <(String, Widget)>[
      ('description only', const SeedPageBanner(description: 'Banner')),
      (
        'with link',
        SeedPageBanner(
          description: 'Banner',
          linkText: 'Action',
          onLinkTap: () {},
        ),
      ),
      (
        'with close button',
        const SeedPageBanner(description: 'Banner', dismissible: true),
      ),
      ('with chevron', SeedPageBanner(description: 'Banner', onTap: () {})),
    ];
    for (final (name, banner) in cases) {
      testWidgets('is 39px tall ($name)', (tester) async {
        await _pump(tester, banner);
        expect(_banner(tester).height, closeTo(39, 0.01));
      });
    }

    testWidgets('prefix icon is 16x16 at 11.5px from the top', (tester) async {
      await _pump(
        tester,
        const SeedPageBanner(
          description: 'Banner',
          prefixIcon: Icon(Icons.info_outline, key: _prefixKey),
        ),
      );
      final banner = _banner(tester);
      final icon = _prefix(tester);
      expect(icon.size, const Size(16, 16));
      expect(icon.top - banner.top, closeTo(11.5, 0.01));
    });

    testWidgets('chevron is centered on the first line', (tester) async {
      await _pump(tester, SeedPageBanner(description: 'Banner', onTap: () {}));
      final text = tester.getRect(find.text('Banner'));
      final chevron = tester.getRect(find.byIcon(Icons.chevron_right_rounded));
      expect(chevron.center.dy, closeTo(text.center.dy, 0.5));
    });
  });

  group('prefix icon stays 16px and centers on the first line', () {
    for (final scale in [1.0, 1.5, 2.0]) {
      testWidgets('is 16x16 at text scale $scale', (tester) async {
        await _pump(
          tester,
          const SeedPageBanner(
            description: 'Banner',
            prefixIcon: Icon(Icons.info_outline, key: _prefixKey),
          ),
          textScaler: TextScaler.linear(scale),
        );
        final icon = _prefix(tester);
        // Measure the laid-out text rather than deriving the line box here.
        final text = tester.getRect(find.text('Banner'));
        final firstLineCenter = text.top + text.height / 2;
        expect(icon.size, const Size(16, 16));
        expect(icon.center.dy, closeTo(firstLineCenter, 0.5));
      });
    }
  });

  group('close button geometry', () {
    for (final direction in TextDirection.values) {
      testWidgets('sits 16px inside the banner end edge ($direction)', (
        tester,
      ) async {
        await _pump(
          tester,
          const SeedPageBanner(description: 'Banner', dismissible: true),
          textDirection: direction,
        );
        final banner = _banner(tester);
        final icon = tester.getRect(find.byIcon(Icons.close_rounded));
        if (direction == TextDirection.ltr) {
          expect(banner.right - icon.right, closeTo(16, 0.01));
        } else {
          expect(icon.left - banner.left, closeTo(16, 0.01));
        }
      });
    }

    testWidgets('pressable is a 40x40 target centered on the first line', (
      tester,
    ) async {
      await _pump(
        tester,
        const SeedPageBanner(description: 'Banner', dismissible: true),
      );
      final banner = _banner(tester);
      final text = tester.getRect(find.text('Banner'));
      final close = tester.getRect(_closePressable());
      expect(close.size, const Size(40, 40));
      expect(close.center.dx, closeTo(banner.right - 24, 0.01));
      expect(close.center.dy, closeTo(text.center.dy, 0.01));
    });

    testWidgets('tapping the target center dismisses', (tester) async {
      var dismissals = 0;
      await _pump(
        tester,
        SeedPageBanner(
          description: 'Banner',
          dismissible: true,
          onDismiss: () => dismissals++,
        ),
      );
      await tester.tap(_closePressable());
      await tester.pumpAndSettle();
      expect(dismissals, 1);
      expect(find.text('Banner'), findsNothing);
    });
  });

  testWidgets('chevron ends 16px inside the banner edge', (tester) async {
    await _pump(tester, SeedPageBanner(description: 'Banner', onTap: () {}));
    final banner = _banner(tester);
    final chevron = tester.getRect(find.byIcon(Icons.chevron_right_rounded));
    expect(banner.right - chevron.right, closeTo(16, 0.01));
  });

  testWidgets('link still fires onLinkTap', (tester) async {
    var links = 0;
    await _pump(
      tester,
      SeedPageBanner(
        description: 'Banner',
        linkText: 'Action',
        onLinkTap: () => links++,
      ),
    );
    final link = _linkPressable();
    // The target keeps its height although only the t3 line joins the layout.
    expect(tester.getSize(link).height, closeTo(40, 0.01));
    await tester.tap(link);
    await tester.pump();
    expect(links, 1);
  });

  group('first-line alignment on a wrapping banner', () {
    const description =
        'This description is long enough to wrap onto several lines inside a '
        'page banner that is four hundred logical pixels wide, so the banner '
        'grows taller than a single line of text.';
    // The t4 line box is 19px at 100% text, so the first line's center is
    // 9.5px below the text's top; the banner's own center is lower.
    const firstLineHalf = 9.5;

    testWidgets('close icon and target center on the first line', (
      tester,
    ) async {
      await _pump(
        tester,
        const SeedPageBanner(description: description, dismissible: true),
      );
      final banner = _banner(tester);
      expect(banner.height, greaterThan(40));
      final text = tester.getRect(find.text(description));
      final target = tester.getRect(_closePressable());
      final close = tester.getRect(find.byIcon(Icons.close_rounded));
      expect(target.size, const Size(40, 40));
      expect(target.center.dy, closeTo(text.top + firstLineHalf, 0.5));
      expect(close.center.dy, closeTo(text.top + firstLineHalf, 0.5));
      expect(target.center.dy, lessThan(banner.center.dy - 1));
    });

    testWidgets('chevron centers on the first line', (tester) async {
      await _pump(
        tester,
        SeedPageBanner(description: description, onTap: () {}),
      );
      final banner = _banner(tester);
      expect(banner.height, greaterThan(40));
      final text = tester.getRect(find.text(description));
      final chevron = tester.getRect(find.byIcon(Icons.chevron_right_rounded));
      expect(chevron.center.dy, closeTo(text.top + firstLineHalf, 0.5));
      expect(chevron.center.dy, lessThan(banner.center.dy - 1));
    });
  });

  group('link bleeds its target 11px inline (css margin -11 / padding 11)', () {
    Widget linkBanner({bool dismissible = false, Widget? prefixIcon}) =>
        SeedPageBanner(
          description: 'Banner',
          linkText: 'Action',
          onLinkTap: () {},
          dismissible: dismissible,
          prefixIcon: prefixIcon,
        );

    for (final direction in TextDirection.values) {
      testWidgets('text stays put while the target grows ($direction)', (
        tester,
      ) async {
        await _pump(tester, linkBanner(), textDirection: direction);
        final banner = _banner(tester);
        final description = tester.getRect(find.text('Banner'));
        final link = tester.getRect(find.text('Action'));
        final target = tester.getRect(_linkPressable());
        final ltr = direction == TextDirection.ltr;
        // Text keeps the root's 16px inline padding on both ends.
        expect(
          ltr
              ? description.left - banner.left
              : banner.right - description.right,
          closeTo(16, 0.01),
        );
        expect(
          ltr ? banner.right - link.right : link.left - banner.left,
          closeTo(16, 0.01),
        );
        // The target spans 11px past the link text on both inline sides.
        expect(link.left - target.left, closeTo(11, 0.01));
        expect(target.right - link.right, closeTo(11, 0.01));
      });

      testWidgets('taps in the bleed reach the link ($direction)', (
        tester,
      ) async {
        var links = 0;
        await _pump(
          tester,
          SeedPageBanner(
            description: 'Banner',
            linkText: 'Action',
            onLinkTap: () => links++,
          ),
          textDirection: direction,
        );
        final link = tester.getRect(find.text('Action'));
        // 10px past the text on the end side, inside the root's padding.
        final endSide = direction == TextDirection.ltr
            ? Offset(link.right + 10, link.center.dy)
            : Offset(link.left - 10, link.center.dy);
        final startSide = direction == TextDirection.ltr
            ? Offset(link.left - 10, link.center.dy)
            : Offset(link.right + 10, link.center.dy);
        await tester.tapAt(endSide);
        await tester.pump();
        await tester.tapAt(startSide);
        await tester.pump();
        expect(links, 2);
      });
    }

    testWidgets('prefix icon keeps the text 8px after it', (tester) async {
      await _pump(
        tester,
        linkBanner(prefixIcon: const Icon(Icons.info_outline, key: _prefixKey)),
      );
      final banner = _banner(tester);
      expect(_prefix(tester).left - banner.left, closeTo(16, 0.01));
      expect(
        tester.getRect(find.text('Banner')).left - _prefix(tester).right,
        closeTo(8, 0.01),
      );
    });

    testWidgets('link ends before the close target as before', (tester) async {
      await _pump(tester, linkBanner(dismissible: true));
      final banner = _banner(tester);
      final link = tester.getRect(find.text('Action'));
      expect(banner.right - link.right, closeTo(40, 0.01));
    });

    testWidgets('the end of the link text stays the link\'s, not close\'s', (
      tester,
    ) async {
      var links = 0;
      var dismissals = 0;
      await _pump(
        tester,
        SeedPageBanner(
          description: 'Banner',
          linkText: 'Action',
          onLinkTap: () => links++,
          dismissible: true,
          onDismiss: () => dismissals++,
        ),
      );
      final link = tester.getRect(find.text('Action'));
      // The close target paints from 44px inside the end edge, 4px over the
      // link text, which ends 40px inside it.
      expect(
        _banner(tester).right - tester.getRect(_closePressable()).left,
        closeTo(44, 0.01),
      );
      await tester.tapAt(Offset(link.right - 2, link.center.dy));
      await tester.pumpAndSettle();
      expect(links, 1);
      expect(dismissals, 0);

      await tester.tap(_closePressable());
      await tester.pumpAndSettle();
      expect(links, 1);
      expect(dismissals, 1);
    });

    testWidgets('a single-line link takes taps across the banner height', (
      tester,
    ) async {
      var links = 0;
      await _pump(
        tester,
        SeedPageBanner(
          description: 'Banner',
          linkText: 'Action',
          onLinkTap: () => links++,
        ),
      );
      final banner = _banner(tester);
      final x = tester.getCenter(find.text('Action')).dx;
      // The 40px target covers the whole 39px banner, edge to edge.
      await tester.tapAt(Offset(x, banner.top + 1));
      await tester.pump();
      await tester.tapAt(Offset(x, banner.bottom - 1));
      await tester.pump();
      expect(links, 2);
    });

    testWidgets('a multiline link grows instead of clipping', (tester) async {
      const label = 'View\naccount\ndetails';
      await _pump(
        tester,
        SeedPageBanner(
          description: 'Banner',
          linkText: label,
          onLinkTap: () {},
        ),
      );
      final banner = _banner(tester);
      final text = tester.getRect(find.text(label));
      final paragraph = tester.renderObject<RenderParagraph>(find.text(label));
      final target = tester.getRect(
        find
            .ancestor(of: find.text(label), matching: find.byType(SeedPressable))
            .first,
      );
      // Every line lays out: the paragraph is as tall as its three lines.
      expect(
        paragraph.size.height,
        closeTo(paragraph.getMaxIntrinsicHeight(paragraph.size.width), 0.01),
      );
      expect(text.height, greaterThan(40));
      // css `padding: 11px`: the target is the label plus 11px on each side.
      expect(target.height, closeTo(text.height + 22, 0.01));
      // The banner grows with the label and keeps its 10px block padding.
      expect(text.top - banner.top, closeTo(10, 0.01));
      expect(banner.bottom - text.bottom, closeTo(10, 0.01));
    });

    testWidgets('a wrapped link starts at the content edge', (tester) async {
      const description =
          'This description is long enough to fill the first line of a '
          'four hundred pixel wide banner on its own.';
      await _pump(
        tester,
        SeedPageBanner(
          description: description,
          linkText: 'Action',
          onLinkTap: () {},
        ),
      );
      final banner = _banner(tester);
      final text = tester.getRect(find.text(description));
      final link = tester.getRect(find.text('Action'));
      expect(link.top, greaterThan(text.top + 10));
      expect(link.left - banner.left, closeTo(16, 0.01));
      expect(text.left - banner.left, closeTo(16, 0.01));
    });
  });
}
