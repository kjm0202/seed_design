import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_design/seed_design.dart';

Widget host(Widget child) => MaterialApp(
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('tabs arrows wrap, skip disabled items and leave one Tab stop', (
    tester,
  ) async {
    var selected = 0;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SeedTabs(
                selectedIndex: selected,
                onTabSelected: (index) => setState(() => selected = index),
                items: const [
                  SeedTabItem(label: 'First'),
                  SeedTabItem(label: 'Disabled', enabled: false),
                  SeedTabItem(label: 'Last'),
                ],
              ),
              TextButton(onPressed: () {}, child: const Text('After')),
            ],
          ),
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(selected, 2);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(selected, 0);
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pumpAndSettle();
    expect(selected, 2);
    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pumpAndSettle();
    expect(selected, 0);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    final selectedBefore = selected;
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(selected, selectedBefore);
    expect(
      FocusManager.instance.primaryFocus!.context!
          .findAncestorWidgetOfExactType<TextButton>(),
      isNotNull,
    );
  });

  testWidgets('RTL segments move in reading order', (tester) async {
    var selected = 0;
    await tester.pumpWidget(
      host(
        Directionality(
          textDirection: TextDirection.rtl,
          child: StatefulBuilder(
            builder: (context, setState) => SizedBox(
              width: 280,
              child: SeedSegmentedControl<int>(
                selectedValue: selected,
                onValueChanged: (value) => setState(() => selected = value),
                segments: const [
                  SeedSegment(value: 0, label: 'One'),
                  SeedSegment(value: 1, label: 'Two'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(selected, 1);
  });

  testWidgets('native radio group handles arrows and ignores disabled radios', (
    tester,
  ) async {
    int? selected = 0;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => SeedRadioGroup<int>(
            groupValue: selected,
            onChanged: (value) => setState(() => selected = value),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SeedRadio<int>(value: 0, label: 'First'),
                SeedRadio<int>(value: 1, label: 'Disabled', enabled: false),
                SeedRadio<int>(value: 2, label: 'Last'),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(selected, 2);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(selected, 0);
  });

  testWidgets(
    'switch mark and label execute only once and expose toggle state',
    (tester) async {
      var count = 0;
      await tester.pumpWidget(
        host(SeedSwitch(value: true, label: '알림', onChanged: (_) => count++)),
      );
      expect(
        tester.getSemantics(find.byType(SeedSwitch)),
        matchesSemantics(
          label: '알림',
          hasToggledState: true,
          isToggled: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
        ),
      );
      await tester.tap(find.text('알림'));
      expect(count, 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      expect(count, 2);
    },
  );

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
      ),
    );
  });

  testWidgets(
    'disabled controls ignore semantic, pointer and keyboard activation',
    (tester) async {
      var calls = 0;
      await tester.pumpWidget(
        host(
          SeedButton(
            label: 'Disabled',
            enabled: false,
            onPressed: () => calls++,
          ),
        ),
      );
      await tester.tap(find.text('Disabled'));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(calls, 0);
    },
  );

  testWidgets('nested clear action does not open input button', (tester) async {
    var opened = 0;
    var cleared = 0;
    await tester.pumpWidget(
      host(
        SizedBox(
          width: 280,
          child: SeedInputButton(
            value: '선택됨',
            showClear: true,
            onClear: () => cleared++,
            onPressed: () => opened++,
          ),
        ),
      ),
    );
    await tester.tap(find.bySemanticsLabel('선택 내용 지우기'));
    expect(cleared, 1);
    expect(opened, 0);
  });

  testWidgets('loading preserves label width and prevents activation', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(
      host(SeedButton(label: '저장하고 계속하기', onPressed: () => calls++)),
    );
    final width = tester.getSize(find.byType(SeedButton)).width;
    await tester.pumpWidget(
      host(
        SeedButton(label: '저장하고 계속하기', loading: true, onPressed: () => calls++),
      ),
    );
    expect(tester.getSize(find.byType(SeedButton)).width, width);
    await tester.tap(find.byType(SeedButton));
    expect(calls, 0);
    expect(
      tester.getSemantics(find.byType(SeedButton)),
      matchesSemantics(
        label: '저장하고 계속하기',
        isButton: true,
        hasEnabledState: true,
      ),
    );
  });

  testWidgets('dialog and sheets retain a local theme and custom font', (
    tester,
  ) async {
    for (final kind in ['dialog', 'sheet', 'menu', 'panel']) {
      await tester.pumpWidget(
        host(
          SeedTheme(
            data: SeedThemeData.dark(fontFamily: 'LocalFont'),
            child: Builder(
              builder: (context) => TextButton(
                onPressed: () {
                  final content = Builder(
                    builder: (context) {
                      expect(context.seedIsDark, isTrue);
                      expect(
                        context.seedTypography.t4Regular.fontFamily,
                        'LocalFont',
                      );
                      return const Text('Local content');
                    },
                  );
                  switch (kind) {
                    case 'dialog':
                      showSeedDialog<void>(
                        context: context,
                        child: SeedDialog(title: 'Title', content: content),
                      );
                    case 'sheet':
                      showSeedBottomSheet<void>(
                        context: context,
                        child: SeedBottomSheet(content: content),
                      );
                    case 'menu':
                      showSeedMenuSheet<void>(
                        context: context,
                        groups: [
                          SeedMenuGroupData(
                            items: [
                              SeedMenuItemData(
                                label: 'Menu',
                                prefixIcon: content,
                              ),
                            ],
                          ),
                        ],
                      );
                    case 'panel':
                      showSeedSidePanel<void>(
                        context: context,
                        title: 'Panel',
                        body: content,
                      );
                  }
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Local content'), findsOneWidget);
      // Remove the whole navigator between cases.
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    }
  });

  testWidgets('reduced motion stops skeleton tickers', (tester) async {
    await tester.pumpWidget(
      host(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: SeedSkeleton(width: 100, height: 20),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.binding.transientCallbackCount, 0);
  });

  testWidgets('invalid minute steps fail immediately', (tester) async {
    await tester.pumpWidget(host(const SeedTimePicker(minuteStep: 0)));
    expect(tester.takeException(), isArgumentError);
  });

  test('manner temperature boundaries follow pinned upstream source', () {
    const boundaries = [30.0, 36.0, 36.5, 37.0, 40.0, 45.0, 55.0, 65.0, 80.0];
    for (var i = 0; i < boundaries.length; i++) {
      expect(SeedMannerTempLevel.fromTemperature(boundaries[i] - 0.001), i + 1);
      expect(SeedMannerTempLevel.fromTemperature(boundaries[i]), i + 2);
    }
    expect(
      () => SeedMannerTempLevel.fromTemperature(double.nan),
      throwsArgumentError,
    );
  });
}
