import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';

Widget host(Widget child, {double scale = 1, bool dark = false}) => MaterialApp(
  supportedLocales: const [Locale('en'), Locale('ko')],
  locale: const Locale('ko'),
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme:
      (dark
              ? SeedThemeData.dark(fontFamily: seedTestFontFamily)
              : SeedThemeData.light(fontFamily: seedTestFontFamily))
          .toThemeData(),
  home: Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(scale)),
      child: Scaffold(body: Center(child: child)),
    ),
  ),
);

Widget hostComponentBehaviorRegress(Widget child) => MaterialApp(
  locale: const Locale('ko'),
  supportedLocales: const [Locale('en'), Locale('ko')],
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  group('placeholders', () {
    setUpAll(loadSeedTestFonts);

    testWidgets('avatar clips empty and custom placeholders in both themes', (
      tester,
    ) async {
      for (final dark in [false, true]) {
        for (final custom in [false, true]) {
          await tester.pumpWidget(
            host(
              RepaintBoundary(
                key: const Key('avatar'),
                child: SeedAvatar(
                  placeholder: custom
                      ? const ColoredBox(color: Colors.red)
                      : null,
                ),
              ),
              dark: dark,
            ),
          );
          await tester.pumpAndSettle();
          final alpha = await tester.runAsync(() async {
            final image = await tester
                .renderObject<RenderRepaintBoundary>(
                  find.byKey(const Key('avatar')),
                )
                .toImage(pixelRatio: 1);
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.rawRgba,
            );
            image.dispose();
            return bytes!.getUint8(3);
          });
          expect(
            alpha,
            0,
            reason: 'The circular avatar corner must be transparent.',
          );
        }
      }
    });
  });

  group('decode failure', () {
    testWidgets('avatar uses placeholder when image decoding fails', (
      tester,
    ) async {
      await tester.pumpWidget(
        hostComponentBehaviorRegress(
          SeedAvatar(image: MemoryImage(Uint8List.fromList([1, 2, 3]))),
        ),
      );
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(SeedIdentityPlaceholder), findsOneWidget);
    });
  });

  group('AvatarStack', () {
    Widget host(Widget child, {bool isDark = false}) {
      return MaterialApp(
        theme: (isDark ? SeedThemeData.dark() : SeedThemeData.light())
            .toThemeData(),
        home: Scaffold(body: Center(child: child)),
      );
    }

    testWidgets(
      'SeedAvatarStack stacks avatars with negative gap and stroke separation',
      (tester) async {
        await tester.pumpWidget(
          host(
            SeedAvatarStack(
              size: SeedAvatarSize.medium,
              maxVisible: 2,
              children: const [
                SeedAvatar(placeholder: Text('A')),
                SeedAvatar(placeholder: Text('B')),
                SeedAvatar(placeholder: Text('C')),
              ],
            ),
          ),
        );

        expect(find.byType(SeedAvatarStack), findsOneWidget);
        expect(find.text('A'), findsOneWidget);
        expect(find.text('B'), findsOneWidget);
        expect(find.text('+1'), findsOneWidget);
      },
    );
  });
}
