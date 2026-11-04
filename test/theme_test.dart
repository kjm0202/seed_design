import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

Widget host(Widget child, {ThemeData? theme}) => MaterialApp(
  locale: const Locale('ko'),
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: theme ?? SeedThemeData.light().toThemeData(),
  home: Scaffold(body: Center(child: child)),
);

Widget hostInteraction(Widget child) => MaterialApp(
  supportedLocales: const [Locale('en'), Locale('ko')],
  locale: const Locale('ko'),
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('fallback SEED typography preserves host application font', (
    tester,
  ) async {
    late SeedThemeData fallback;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(fontFamily: 'HostSans'),
        home: Builder(
          builder: (context) {
            fallback = SeedTheme.of(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(fallback.typography.body.fontFamily, 'HostSans');
    expect(fallback.typography.body.fontSize, SeedFontSize.t5);
    expect(
      fallback.typography.body.height,
      SeedLineHeight.t5 / SeedFontSize.t5,
    );
  });
  group('theme boundaries', () {

    test('migration preserves fonts, fallbacks and unrelated extensions', () {
      final original = ThemeData(
        fontFamily: 'CustomFont',
        fontFamilyFallback: const ['Fallback'],
        extensions: const [_AppMarker()],
      );
      final result = original.withSeedDesign();
      expect(result.textTheme.bodyMedium!.fontFamily, 'CustomFont');
      expect(result.extension<_AppMarker>(), isNotNull);
      expect(
        result.textTheme.bodyMedium!.fontFamilyFallback,
        contains('Fallback'),
      );
      expect(
        result.extension<SeedTypography>()!.t4Regular.fontFamily,
        'CustomFont',
      );
      final explicit = original.withSeedDesign(fontFamily: 'ExplicitFont');
      expect(explicit.textTheme.bodyMedium!.fontFamily, 'ExplicitFont');
      expect(
        explicit.extension<SeedTypography>()!.t4Regular.fontFamily,
        'ExplicitFont',
      );
    });
  });
}

class _AppMarker extends ThemeExtension<_AppMarker> {
  const _AppMarker();
  @override
  _AppMarker copyWith() => this;
  @override
  _AppMarker lerp(covariant _AppMarker? other, double t) => this;
}
