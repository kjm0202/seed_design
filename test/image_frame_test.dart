import 'dart:typed_data';

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

void main() {
  group('indicator and icon', () {
    // Official React 3.3.0 exports that had no Flutter counterpart.

    /// A 1x1 transparent PNG.
    final Uint8List kTransparentImage = Uint8List.fromList(const [
      0x89,
      0x50,
      0x4E,
      0x47,
      0x0D,
      0x0A,
      0x1A,
      0x0A,
      0x00,
      0x00,
      0x00,
      0x0D,
      0x49,
      0x48,
      0x44,
      0x52,
      0x00,
      0x00,
      0x00,
      0x01,
      0x00,
      0x00,
      0x00,
      0x01,
      0x08,
      0x06,
      0x00,
      0x00,
      0x00,
      0x1F,
      0x15,
      0xC4,
      0x89,
      0x00,
      0x00,
      0x00,
      0x0A,
      0x49,
      0x44,
      0x41,
      0x54,
      0x78,
      0x9C,
      0x63,
      0x00,
      0x01,
      0x00,
      0x00,
      0x05,
      0x00,
      0x01,
      0x0D,
      0x0A,
      0x2D,
      0xB4,
      0x00,
      0x00,
      0x00,
      0x00,
      0x49,
      0x45,
      0x4E,
      0x44,
      0xAE,
      0x42,
      0x60,
      0x82,
    ]);

    Widget host(Widget child, {double width = 320}) => MaterialApp(
      theme: SeedThemeData.light().toThemeData(),
      home: Scaffold(
        body: Center(
          child: SizedBox(width: width, child: child),
        ),
      ),
    );

    group('ImageFrame.Indicator and ImageFrame.Icon', () {
      testWidgets(
        'indicator is a static black pill with t1 medium white text',
        (tester) async {
          await tester.pumpWidget(
            host(
              const Center(child: SeedImageFrameIndicator(child: Text('1/5'))),
            ),
          );
          final box = tester.widget<DecoratedBox>(
            find.descendant(
              of: find.byType(SeedImageFrameIndicator),
              matching: find.byType(DecoratedBox),
            ),
          );
          final decoration = box.decoration as BoxDecoration;
          expect(decoration.color, SeedPalette.staticBlackAlpha800);
          expect(decoration.borderRadius, SeedBorderRadius.full);
          final text = tester.renderObject<RenderParagraph>(find.text('1/5'));
          final typography = SeedThemeData.light().typography;
          expect(text.text.style!.color, SeedPalette.staticWhite);
          expect(text.text.style!.fontSize, typography.t1Medium.fontSize);
          expect(text.text.style!.fontWeight, typography.t1Medium.fontWeight);
          // paddingX x1_5 and paddingY x0_5 around the label.
          final pill = tester.getRect(find.byType(SeedImageFrameIndicator));
          final label = tester.getRect(find.text('1/5'));
          expect(label.left - pill.left, 6);
          expect(label.top - pill.top, 2);
        },
      );

      testWidgets('the frame badge keeps the indicator appearance', (
        tester,
      ) async {
        await tester.pumpWidget(
          host(
            SeedImageFrame(
              imageProvider: MemoryImage(kTransparentImage),
              badge: '+9',
            ),
          ),
        );
        expect(
          find.ancestor(
            of: find.text('+9'),
            matching: find.byType(SeedImageFrameIndicator),
          ),
          findsOneWidget,
        );
      });

      testWidgets('icon is static white in light and dark themes', (
        tester,
      ) async {
        for (final theme in [SeedThemeData.light(), SeedThemeData.dark()]) {
          await tester.pumpWidget(
            MaterialApp(
              theme: theme.toThemeData(),
              home: const SeedImageFrameIcon(icon: Icon(Icons.play_arrow)),
            ),
          );
          final icon = tester.renderObject<RenderParagraph>(
            find.descendant(
              of: find.byType(Icon),
              matching: find.byType(RichText),
            ),
          );
          expect(icon.text.style!.color, SeedPalette.staticWhite);
        }
      });
    });
  });
}
