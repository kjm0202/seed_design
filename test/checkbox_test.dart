import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

Widget host(Widget child) => MaterialApp(
  supportedLocales: const [Locale('en'), Locale('ko')],
  locale: const Locale('ko'),
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(body: Center(child: child)),
);

Widget hostRegression(Widget child, {ThemeData? theme}) => MaterialApp(
  locale: const Locale('ko'),
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: theme ?? SeedThemeData.light().toThemeData(),
  home: Scaffold(body: Center(child: child)),
);

Widget hostLayoutParity(Widget child) => MaterialApp(
  supportedLocales: const [Locale('en'), Locale('ko')],
  locale: const Locale('ko'),
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(body: child),
);

void main() {
  group('tristate', () {
    testWidgets('tristate checkbox exposes mixed state', (tester) async {
      await tester.pumpWidget(
        host(
          SeedCheckbox(
            value: null,
            tristate: true,
            label: '일부',
            onChanged: (_) {},
          ),
        ),
      );
      expect(
        tester.getSemantics(find.byType(SeedCheckbox)),
        matchesSemantics(
          label: '일부',
          hasCheckedState: true,
          isCheckStateMixed: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
    });
  });

  group('semantics and target', () {
    testWidgets('checkbox exposes checked state and has a minimum target', (
      tester,
    ) async {
      var changes = 0;
      await tester.pumpWidget(
        hostRegression(
          Padding(
            padding: const EdgeInsets.all(24),
            child: SeedCheckbox(value: true, onChanged: (_) => changes++),
          ),
        ),
      );
      // React keeps the 20px layout size and extends only the touch area.
      expect(tester.getSize(find.byType(SeedCheckbox)).shortestSide, 20);
      await tester.tapAt(
        tester.getCenter(find.byType(SeedCheckbox)) + const Offset(20, 0),
      );
      expect(changes, 1);
      expect(
        tester.getSemantics(
          find.descendant(
            of: find.byType(SeedCheckbox),
            matching: find.byType(SeedPressable),
          ),
        ),
        matchesSemantics(
          hasCheckedState: true,
          isChecked: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
    });
  });

  group('hover', () {
    testWidgets(
      'hover changes checkmark color without applying physical press scale',
      (tester) async {
        await tester.pumpWidget(
          hostLayoutParity(
            Center(
              child: SeedCheckbox(
                value: false,
                onChanged: (_) {},
                label: 'Check',
              ),
            ),
          ),
        );
        final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await mouse.addPointer(location: const Offset(0, 0));
        await mouse.moveTo(tester.getCenter(find.text('Check')));
        await tester.pumpAndSettle();
        expect(
          tester.widget<SeedCheckmark>(find.byType(SeedCheckmark)).pressed,
          isTrue,
        );
        expect(
          tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale,
          1,
        );
        await mouse.removePointer();
      },
    );
  });
}
