import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' as seed_material;
import 'package:seed_design/seed_design.dart';
import 'package:seed_design_example/stackflow_spa/stackflow_spa.dart';

void main() {
  for (final insets in [
    FakeViewPadding.zero,
    const FakeViewPadding(left: 24, right: 32),
  ]) {
    testWidgets(
      'safe area band follows theme with insets ${insets.left}/${insets.right}',
      (tester) async {
        tester.view.physicalSize = const Size(440, 960);
        tester.view.devicePixelRatio = 1;
        tester.view.padding = insets;
        tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPadding);
        addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
        final boundaryKey = GlobalKey();
        await tester.pumpWidget(
          RepaintBoundary(key: boundaryKey, child: const StackflowSpaApp()),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('좌우 safe area와 bleed'));
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.text('배경 띠'),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        const message = '배경은 화면 끝까지, 글자는 safe area 안쪽에 있어요.';
        final band = find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.child is Text &&
              (widget.child as Text).data == message,
        );
        await tester.ensureVisible(band);
        await tester.pumpAndSettle();

        for (final brightness in [
          Brightness.dark,
          Brightness.light,
          Brightness.dark,
        ]) {
          tester.platformDispatcher.platformBrightnessTestValue = brightness;
          await tester.pumpAndSettle();
          final colors = tester.element(band).seedColor;
          final text = find.descendant(of: band, matching: find.byType(Text));
          expect(tester.widget<Text>(text).style!.color, colors.fg.brand);
          expect(tester.widget<Text>(text).style!.fontWeight, FontWeight.w500);
          final rect = tester.getRect(band);
          expect(rect.left, 0);
          expect(rect.right, 440);
          expect(tester.getRect(text).left, 16 + insets.left);
          expect(tester.getRect(text).right, 440 - 16 - insets.right);

          final pixels = await tester.runAsync(() async {
            final image = await tester
                .renderObject<RenderRepaintBoundary>(find.byKey(boundaryKey))
                .toImage(pixelRatio: 1);
            try {
              final data = (await image.toByteData(
                format: ui.ImageByteFormat.rawRgba,
              ))!;
              return [
                for (final x in [0, 220, 439])
                  Color.fromARGB(
                    255,
                    data.getUint8(
                      ((rect.top.toInt() + 2) * image.width + x) * 4,
                    ),
                    data.getUint8(
                      ((rect.top.toInt() + 2) * image.width + x) * 4 + 1,
                    ),
                    data.getUint8(
                      ((rect.top.toInt() + 2) * image.width + x) * 4 + 2,
                    ),
                  ),
              ];
            } finally {
              image.dispose();
            }
          });
          expect(pixels, everyElement(colors.bg.brandWeak));
        }
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }

  testWidgets('an open activity follows system theme changes', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await tester.pumpWidget(const StackflowSpaApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('App Bar 슬롯과 긴 제목'));
    await tester.pumpAndSettle();
    for (final brightness in [Brightness.light, Brightness.dark]) {
      tester.platformDispatcher.platformBrightnessTestValue = brightness;
      await tester.pumpAndSettle();
      final context = tester.element(find.text('ActivityTransparentBar'));
      final nativeTheme = Theme.of(context);
      final seedTheme = seed_material.Theme.of(context);
      expect(nativeTheme.brightness, brightness);
      expect(seedTheme.brightness, brightness);
      expect(
        nativeTheme.scaffoldBackgroundColor,
        seedTheme.scaffoldBackgroundColor,
      );
      expect(
        nativeTheme.textTheme.bodyMedium!.color,
        seedTheme.textTheme.bodyMedium!.color,
      );
    }
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  for (final width in [440.0, 1000.0]) {
    for (final brightness in Brightness.values) {
      testWidgets('first home entry keeps $brightness theme at width $width', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 960);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.platformBrightnessTestValue = brightness;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
        final boundaryKey = GlobalKey();
        await tester.pumpWidget(
          RepaintBoundary(key: boundaryKey, child: const StackflowSpaApp()),
        );
        await tester.pumpAndSettle();
        await tester.tap(
          find.text('App Bar 슬롯과 긴 제목'),
          kind: PointerDeviceKind.mouse,
        );
        await tester.pumpAndSettle();

        final heading = tester.element(find.text('ActivityTransparentBar'));
        final nativeTheme = Theme.of(heading);
        final seedTheme = seed_material.Theme.of(heading);
        expect(seedTheme.brightness, brightness);
        expect(nativeTheme.brightness, brightness);
        expect(
          nativeTheme.scaffoldBackgroundColor,
          seedTheme.scaffoldBackgroundColor,
        );
        expect(
          nativeTheme.textTheme.bodyMedium!.color,
          seedTheme.textTheme.bodyMedium!.color,
        );

        final background = await tester.runAsync(() async {
          final image = await tester
              .renderObject<RenderRepaintBoundary>(find.byKey(boundaryKey))
              .toImage(pixelRatio: 1);
          try {
            final data = (await image.toByteData(
              format: ui.ImageByteFormat.rawRgba,
            ))!;
            // Empty body area below all of this page's controls.
            final offset = (800 * image.width + 20) * 4;
            return Color.fromARGB(
              255,
              data.getUint8(offset),
              data.getUint8(offset + 1),
              data.getUint8(offset + 2),
            );
          } finally {
            image.dispose();
          }
        });
        expect(background, heading.seedColor.bg.layerDefault);

        await tester.tap(find.text('Append Left'));
        await tester.pumpAndSettle();
        expect(find.byTooltip('Left notification 2'), findsOneWidget);
        expect(Theme.of(heading).brightness, brightness);

        await tester.tap(find.text('‹  Back'), kind: PointerDeviceKind.mouse);
        await tester.pumpAndSettle();
        expect(find.text('Home'), findsOneWidget);
        expect(
          seed_material.Theme.of(tester.element(find.text('Home'))).brightness,
          brightness,
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  }
}
