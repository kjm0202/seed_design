import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'seed_test_fonts.dart';

// App shells shared by the widget tests. The name says what surrounds the
// widget under test: the locale, the font, and how the body is laid out.

const _korean = Locale('ko');
const _locales = [Locale('en'), Locale('ko')];

ThemeData _light({bool testFont = false}) =>
    SeedThemeData.light(fontFamily: testFont ? seedTestFontFamily : null)
        .toThemeData();

Widget _sized(Widget child, double? width) =>
    width == null ? child : SizedBox(width: width, child: child);

/// Light theme; [child] fills the scaffold body.
Widget seedApp(Widget child) => MaterialApp(
  theme: _light(),
  home: Scaffold(body: child),
);

/// Light theme; [child] centered.
Widget seedAppCentered(Widget child) => MaterialApp(
  theme: _light(),
  home: Scaffold(body: Center(child: child)),
);

/// Light theme; [child] at the top left.
Widget seedAppTopLeft(Widget child) => MaterialApp(
  theme: _light(),
  home: Scaffold(
    body: Align(alignment: Alignment.topLeft, child: child),
  ),
);

/// Light theme; [child] centered in a 360px column.
Widget seedAppNarrow(Widget child) => seedAppSized(child, width: 360);

/// Light theme; [child] centered in a column of [width].
Widget seedAppSized(Widget child, {double width = 300}) => MaterialApp(
  theme: _light(),
  home: Scaffold(body: Center(child: _sized(child, width))),
);

/// Korean locale; [child] fills the scaffold body.
Widget koreanApp(Widget child) => MaterialApp(
  locale: _korean,
  supportedLocales: _locales,
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: _light(),
  home: Scaffold(body: child),
);

/// Korean locale; [child] centered.
Widget koreanAppCentered(Widget child, {double? width}) => MaterialApp(
  locale: _korean,
  supportedLocales: _locales,
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: _light(),
  home: Scaffold(body: Center(child: _sized(child, width))),
);

/// Korean locale; [child] centered in a 360px column.
Widget koreanAppNarrow(Widget child) => koreanAppCentered(child, width: 360);

/// Korean locale; [child] centered in a 340px column.
Widget koreanAppCompact(Widget child) => koreanAppCentered(child, width: 340);

/// Korean locale and the test font; [child] at the top left in a column of
/// [width].
Widget koreanAppTopLeft(Widget child, {double width = 320}) => MaterialApp(
  locale: _korean,
  supportedLocales: _locales,
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: _light(testFont: true),
  home: Scaffold(
    body: Align(
      alignment: Alignment.topLeft,
      child: SizedBox(width: width, child: child),
    ),
  ),
);

/// The test font; [child] centered, optionally without a [Scaffold].
Widget fontApp(Widget child, {bool scaffold = true}) => MaterialApp(
  theme: _light(testFont: true),
  home: scaffold ? Scaffold(body: Center(child: child)) : Center(child: child),
);

/// Korean locale and the test font, with a text [scale] and optional [dark]
/// theme; [child] centered.
Widget scaledApp(Widget child, {double scale = 1, bool dark = false}) =>
    MaterialApp(
      locale: _korean,
      supportedLocales: _locales,
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

/// Korean locale with a replaceable [theme]; [child] centered.
Widget themedApp(Widget child, {ThemeData? theme}) => MaterialApp(
  locale: _korean,
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: theme ?? _light(),
  home: Scaffold(body: Center(child: child)),
);
