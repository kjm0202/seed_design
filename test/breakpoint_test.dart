import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

void main() {
  group('useBreakpoint and ResponsiveValue', () {
    test('thresholds match the official media queries', () {
      expect(SeedBreakpoint.fromWidth(0), SeedBreakpoint.base);
      expect(SeedBreakpoint.fromWidth(479.9), SeedBreakpoint.base);
      expect(SeedBreakpoint.fromWidth(480), SeedBreakpoint.sm);
      expect(SeedBreakpoint.fromWidth(767.9), SeedBreakpoint.sm);
      expect(SeedBreakpoint.fromWidth(768), SeedBreakpoint.md);
      expect(SeedBreakpoint.fromWidth(1279.9), SeedBreakpoint.md);
      expect(SeedBreakpoint.fromWidth(1280), SeedBreakpoint.lg);
      expect(SeedBreakpoint.fromWidth(1440), SeedBreakpoint.xl);
      expect(SeedBreakpoint.thresholds, [
        SeedBreakpoint.sm,
        SeedBreakpoint.md,
        SeedBreakpoint.lg,
        SeedBreakpoint.xl,
      ]);
      expect(SeedBreakpoint.lg >= SeedBreakpoint.md, isTrue);
      expect(SeedBreakpoint.sm < SeedBreakpoint.md, isTrue);
    });

    test('a missing breakpoint falls back to the nearest smaller value', () {
      const value = SeedResponsiveValue<int>(base: 1, md: 2, xl: 4);
      expect(value.resolve(SeedBreakpoint.base), 1);
      expect(value.resolve(SeedBreakpoint.sm), 1);
      expect(value.resolve(SeedBreakpoint.md), 2);
      expect(value.resolve(SeedBreakpoint.lg), 2);
      expect(value.resolve(SeedBreakpoint.xl), 4);
      // Nothing at or below the breakpoint: undefined in React, null here.
      expect(
        const SeedResponsiveValue<int>(md: 2).resolve(SeedBreakpoint.sm),
        isNull,
      );
      expect(
        const SeedResponsiveValue<int>.all(7).resolve(SeedBreakpoint.xl),
        7,
      );
      expect(value, const SeedResponsiveValue<int>(base: 1, md: 2, xl: 4));
    });

    testWidgets('follows the viewport width and rebuilds when it changes', (
      tester,
    ) async {
      Widget at(double width) => MediaQuery(
        data: MediaQueryData(size: Size(width, 800)),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) => Text(
              '${SeedBreakpoint.of(context).name}:'
              '${const SeedResponsiveValue(base: 'one', md: 'two').of(context)}',
            ),
          ),
        ),
      );
      await tester.pumpWidget(at(390));
      expect(find.text('base:one'), findsOneWidget);
      await tester.pumpWidget(at(1024));
      expect(find.text('md:two'), findsOneWidget);
      await tester.pumpWidget(at(1600));
      expect(find.text('xl:two'), findsOneWidget);
    });
  });
}
