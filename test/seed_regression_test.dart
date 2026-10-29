import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_design/seed_design.dart';

Widget host(Widget child, {ThemeData? theme}) => MaterialApp(
  theme: theme ?? SeedThemeData.light().toThemeData(),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  group('Input ownership', () {
    testWidgets('replaces external controllers and detaches old listeners', (
      tester,
    ) async {
      final first = TextEditingController(text: 'first');
      final second = TextEditingController(text: 'second');
      addTearDown(first.dispose);
      addTearDown(second.dispose);
      await tester.pumpWidget(host(SeedTextInput(controller: first)));
      await tester.pumpWidget(host(SeedTextInput(controller: second)));
      expect(find.text('second'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller,
        same(second),
      );
      first.text = 'detached';
      await tester.pump();
      expect(find.text('detached'), findsNothing);
      await tester.pumpWidget(const SizedBox());
      second.text = 'still owned by caller';
    });

    testWidgets(
      'external to internal preserves editing value without disposing caller',
      (tester) async {
        final controller = TextEditingController(text: 'keep me');
        addTearDown(controller.dispose);
        controller.selection = const TextSelection.collapsed(offset: 3);
        await tester.pumpWidget(host(SeedTextInput(controller: controller)));
        await tester.pumpWidget(host(const SeedTextInput()));
        final current = tester
            .widget<TextField>(find.byType(TextField))
            .controller!;
        expect(current, isNot(same(controller)));
        expect(current.value, controller.value);
        await tester.pumpWidget(const SizedBox());
        controller.text = 'caller can still use it';
      },
    );

    testWidgets('internal to external and focus node replacement', (
      tester,
    ) async {
      final controller = TextEditingController(text: 'replacement');
      final first = FocusNode();
      final second = FocusNode();
      addTearDown(controller.dispose);
      addTearDown(first.dispose);
      addTearDown(second.dispose);
      await tester.pumpWidget(
        host(SeedTextInput(initialValue: 'initial', focusNode: first)),
      );
      await tester.pumpWidget(
        host(SeedTextInput(controller: controller, focusNode: second)),
      );
      expect(find.text('replacement'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).focusNode,
        same(second),
      );
      second.requestFocus();
      await tester.pump();
      expect(second.hasFocus, isTrue);
      await tester.pumpWidget(const SizedBox());
    });
  });

  group('Theme boundaries', () {
    testWidgets('MaterialApp dark theme overrides an outer legacy SeedTheme', (
      tester,
    ) async {
      await tester.pumpWidget(
        SeedTheme(
          data: SeedThemeData.light(),
          child: MaterialApp(
            theme: SeedThemeData.light().toThemeData(),
            darkTheme: SeedThemeData.dark().toThemeData(),
            themeMode: ThemeMode.dark,
            home: Builder(
              builder: (context) {
                expect(Theme.of(context).brightness, Brightness.dark);
                expect(context.seedIsDark, isTrue);
                return const SizedBox();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('subtree override synchronizes Material and modal themes', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          SeedTheme(
            data: SeedThemeData.dark(),
            child: Builder(
              builder: (context) {
                expect(context.seedIsDark, isTrue);
                expect(Theme.of(context).brightness, Brightness.dark);
                return TextButton(
                  onPressed: () => showSeedDialog<void>(
                    context: context,
                    child: Builder(
                      builder: (context) {
                        expect(context.seedIsDark, isTrue);
                        expect(Theme.of(context).brightness, Brightness.dark);
                        return const Center(child: Text('themed dialog'));
                      },
                    ),
                  ),
                  child: const Text('Open'),
                );
              },
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('themed dialog'), findsOneWidget);
    });

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

  group('Button sizing and state', () {
    testWidgets('hug, fill and long labels respect available width', (
      tester,
    ) async {
      await tester.pumpWidget(host(SeedButton(label: 'OK', onPressed: () {})));
      expect(tester.getSize(find.byType(SeedButton)).width, lessThan(100));
      await tester.pumpWidget(
        host(
          SizedBox(
            width: 180,
            child: SeedButton(
              label: '아주 긴 버튼 레이블을 표시하는 테스트',
              prefixIcon: const Icon(Icons.add),
              onPressed: () {},
              isFullWidth: true,
            ),
          ),
        ),
      );
      expect(tester.getSize(find.byType(SeedButton)).width, 180);
      expect(tester.takeException(), isNull);
    });

    testWidgets('null callbacks use disabled colors and semantics', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(const SeedButton(label: 'Disabled', onPressed: null)),
      );
      final container = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(SeedButton),
          matching: find.byType(AnimatedContainer),
        ),
      );
      expect(
        (container.decoration as BoxDecoration).color,
        const SeedColorScheme.light().bg.disabled,
      );
      expect(
        tester.getSemantics(find.byType(SeedButton)),
        matchesSemantics(
          label: 'Disabled',
          isButton: true,
          hasEnabledState: true,
        ),
      );
    });

    testWidgets('large text increases height without clipping', (tester) async {
      await tester.pumpWidget(
        host(
          MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2.5)),
            child: SeedButton(label: '확인', onPressed: () {}),
          ),
        ),
      );
      expect(tester.getSize(find.byType(SeedButton)).height, greaterThan(40));
      expect(tester.takeException(), isNull);
    });
  });

  group('Accessible interactions', () {
    testWidgets(
      'Tab then Enter and Space activate a button exactly once each',
      (tester) async {
        var count = 0;
        await tester.pumpWidget(
          host(SeedButton(label: 'Run', onPressed: () => count++)),
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(count, 1);
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pumpAndSettle();
        expect(count, 2);
      },
    );

    testWidgets('checkbox exposes checked state and has a minimum target', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(SeedCheckbox(value: true, onChanged: (_) {})),
      );
      expect(
        tester.getSize(find.byType(SeedCheckbox)).shortestSide,
        greaterThanOrEqualTo(24),
      );
      expect(
        tester.getSemantics(find.byType(SeedCheckbox)),
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

  testWidgets('date bounds ignore time of day', (tester) async {
    DateTime? selected;
    await tester.pumpWidget(
      host(
        SeedDatePicker(
          initialDate: DateTime(2026, 10, 18),
          firstDate: DateTime(2026, 10, 18, 12),
          onDateSelected: (date) => selected = date,
        ),
      ),
    );
    await tester.tap(find.text('18'));
    expect(selected, DateTime(2026, 10, 18));
  });
}

class _AppMarker extends ThemeExtension<_AppMarker> {
  const _AppMarker();
  @override
  _AppMarker copyWith() => this;
  @override
  _AppMarker lerp(covariant _AppMarker? other, double t) => this;
}
