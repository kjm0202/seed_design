import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';

Widget _host(
  Widget child, {
  double width = 800,
  Brightness brightness = Brightness.light,
}) {
  final theme = brightness == Brightness.dark
      ? SeedThemeData.dark(fontFamily: seedTestFontFamily)
      : SeedThemeData.light(fontFamily: seedTestFontFamily);
  return MaterialApp(
    theme: theme.toThemeData(),
    home: Scaffold(
      body: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(width: width, child: child),
      ),
    ),
  );
}

class _MountCounter {
  final List<int> created = [0, 0, 0];
  final List<int> disposed = [0, 0, 0];
}

class _CountingPanel extends StatefulWidget {
  const _CountingPanel(this.index, this.counter);
  final int index;
  final _MountCounter counter;

  @override
  State<_CountingPanel> createState() => _CountingPanelState();
}

class _CountingPanelState extends State<_CountingPanel> {
  @override
  void initState() {
    super.initState();
    widget.counter.created[widget.index]++;
  }

  @override
  void dispose() {
    widget.counter.disposed[widget.index]++;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      SizedBox(height: 80, child: Text('panel ${widget.index}'));
}

Widget _tabs(
  _MountCounter counter,
  SeedTabsController controller, {
  required bool lazyMount,
  bool unmountOnExit = false,
}) => _host(
  SizedBox(
    height: 300,
    width: 360,
    child: SeedTabsView(
      carousel: true,
      height: 200,
      controller: controller,
      duration: const Duration(milliseconds: 180),
      lazyMount: lazyMount,
      unmountOnExit: unmountOnExit,
      items: const [
        SeedTabItem(label: 'A', value: 'a'),
        SeedTabItem(label: 'B', value: 'b'),
        SeedTabItem(label: 'C', value: 'c'),
      ],
      children: [for (var i = 0; i < 3; i++) _CountingPanel(i, counter)],
    ),
  ),
);

Finder get _rangeField => find.byWidgetPredicate(
  (widget) => widget is Semantics && widget.properties.label == '표시 범위',
);

Color _trackColor(WidgetTester tester) {
  final findTrack = find.descendant(
    of: find.byType(SeedSwitchMark),
    matching: find.byType(AnimatedContainer),
  );
  return (tester.widget<AnimatedContainer>(findTrack).decoration!
          as BoxDecoration)
      .color!;
}

void main() {
  setUpAll(loadSeedTestFonts);

  testWidgets('PKG-01: carousel mounts all initial non-lazy panels', (
    tester,
  ) async {
    final counter = _MountCounter();
    final controller = SeedTabsController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(_tabs(counter, controller, lazyMount: false));
    await tester.pumpAndSettle();
    expect(counter.created, [1, 1, 1]);
    controller.animateTo(2);
    await tester.pumpAndSettle();
    expect(counter.created, [1, 1, 1]);
  });

  testWidgets(
    'PKG-01: carousel lazy panels mount only after selection, even during drag',
    (tester) async {
      final counter = _MountCounter();
      final controller = SeedTabsController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(_tabs(counter, controller, lazyMount: true));
      await tester.pumpAndSettle();
      expect(counter.created, [1, 0, 0]);
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(PageView)),
      );
      await gesture.moveBy(const Offset(-100, 0));
      await tester.pump(const Duration(milliseconds: 16));
      expect(tester.widget<SeedTabs>(find.byType(SeedTabs)).selectedIndex, 0);
      expect(counter.created, [1, 0, 0]);
      await gesture.up();
      await tester.pumpAndSettle();
      controller.animateTo(2);
      await tester.pumpAndSettle();
      expect(counter.created[2], 1);
    },
  );

  testWidgets('PKG-01: unmountOnExit discards visited carousel panel state', (
    tester,
  ) async {
    final counter = _MountCounter();
    final controller = SeedTabsController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _tabs(counter, controller, lazyMount: true, unmountOnExit: true),
    );
    await tester.pumpAndSettle();
    controller.animateTo(1);
    await tester.pumpAndSettle();
    expect(counter.disposed[0], 1);
    controller.animateTo(0);
    await tester.pumpAndSettle();
    expect(counter.created[0], 2);
    expect(counter.disposed[1], 1);
  });

  for (final brightness in [Brightness.light, Brightness.dark]) {
    for (final size in SeedSwitchSize.values) {
      testWidgets(
        'PKG-02: brand checked remains brand when disabled, $brightness $size',
        (tester) async {
          await tester.pumpWidget(
            _host(
              SeedSwitchMark(
                checked: true,
                enabled: true,
                tone: SeedControlTone.brand,
                onCheckedChange: (_) {},
              ),
              brightness: brightness,
            ),
          );
          await tester.pumpAndSettle();
          final active = _trackColor(tester);
          await tester.pumpWidget(
            _host(
              SeedSwitchMark(
                checked: true,
                enabled: false,
                tone: SeedControlTone.brand,
                size: size,
                onCheckedChange: (_) {},
              ),
              brightness: brightness,
            ),
          );
          await tester.pumpAndSettle();
          final disabled = _trackColor(tester);
          expect(disabled, active);
          final opacity = tester.widget<Opacity>(
            find.descendant(
              of: find.byType(SeedSwitchMark),
              matching: find.byType(Opacity),
            ),
          );
          expect(opacity.opacity, 0.38);
        },
      );
    }
  }

  testWidgets('PKG-02: neutral disabled checked remains gray and no toggle', (
    tester,
  ) async {
    final updates = <bool>[];
    await tester.pumpWidget(
      _host(
        SeedSwitchMark(
          checked: false,
          enabled: false,
          tone: SeedControlTone.neutral,
          onCheckedChange: updates.add,
        ),
      ),
    );
    await tester.pumpAndSettle();
    final gray = _trackColor(tester);
    await tester.pumpWidget(
      _host(
        SeedSwitchMark(
          checked: true,
          enabled: false,
          tone: SeedControlTone.neutral,
          onCheckedChange: updates.add,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(_trackColor(tester), gray);
    await tester.tap(find.byType(SeedSwitchMark));
    await tester.pump();
    expect(updates, isEmpty);
  });

  testWidgets(
    'PKG-02: controlled checked switch without callback stays visually enabled',
    (tester) async {
      for (final labeled in [false, true]) {
        Widget buildSwitch({required bool callback}) => labeled
            ? SeedSwitch(
                checked: true,
                label: 'Alerts',
                onCheckedChange: callback ? (_) {} : null,
              )
            : SeedSwitchMark(
                checked: true,
                onCheckedChange: callback ? (_) {} : null,
              );
        Finder track() => find.descendant(
          of: labeled ? find.byType(SeedSwitch) : find.byType(SeedSwitchMark),
          matching: find.byType(AnimatedContainer),
        );

        await tester.pumpWidget(_host(buildSwitch(callback: true)));
        await tester.pumpAndSettle();
        final withCallback =
            (tester.widget<AnimatedContainer>(track()).decoration!
                    as BoxDecoration)
                .color;
        await tester.pumpWidget(_host(buildSwitch(callback: false)));
        await tester.pumpAndSettle();
        final withoutCallback =
            (tester.widget<AnimatedContainer>(track()).decoration!
                    as BoxDecoration)
                .color;
        expect(withoutCallback, withCallback, reason: 'label=$labeled');
        expect(
          tester
              .widget<Opacity>(
                find.descendant(
                  of: labeled
                      ? find.byType(SeedSwitch)
                      : find.byType(SeedSwitchMark),
                  matching: find.byType(Opacity),
                ),
              )
              .opacity,
          1.0,
          reason: 'Missing onCheckedChange does not imply CSS disabled',
        );
      }
    },
  );

  for (final width in [800.0, 390.0, 240.0]) {
    testWidgets('PKG-04: separate range selector and total at width $width', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 900);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final changed = <int>[];
      await tester.pumpWidget(
        _host(
          SeedTablePagination(
            value: const SeedTablePaginationValue(page: 3, pageSize: 25),
            totalItems: 237,
            onPageChanged: changed.add,
          ),
          width: width,
        ),
      );
      await tester.pumpAndSettle();
      expect(_rangeField, findsOneWidget);
      expect(tester.getSize(_rangeField).width, 96);
      expect(find.text('/ 총 237개'), findsOneWidget);
      expect(find.textContaining('총 237개', findRichText: true), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();
      expect(changed, [4]);
    });
  }

  testWidgets('PKG-04: range selection still emits page-range reason', (
    tester,
  ) async {
    final changes = <SeedTablePaginationChange>[];
    await tester.pumpWidget(
      _host(
        SeedTablePagination(
          defaultValue: const SeedTablePaginationValue(page: 3, pageSize: 25),
          totalItems: 237,
          onValueChanged: changes.add,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(_rangeField);
    await tester.pumpAndSettle();
    expect(find.text('76–100'), findsWidgets);
    await tester.tap(find.text('76–100').last);
    await tester.pumpAndSettle();
    expect(changes, hasLength(1));
    expect(changes.single.reason, SeedTablePageChangeReason.pageRange);
    expect(
      changes.single.value,
      const SeedTablePaginationValue(page: 4, pageSize: 25),
    );
    expect(find.text('/ 총 237개'), findsOneWidget);
  });

  testWidgets('PKG-04: zero total keeps distinct disabled range and total', (
    tester,
  ) async {
    await tester.pumpWidget(_host(const SeedTablePagination(totalItems: 0)));
    await tester.pumpAndSettle();
    expect(_rangeField, findsOneWidget);
    expect(tester.getSize(_rangeField).width, 96);
    expect(find.text('/ 총 0개'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('PKG-04: unknown total keeps plain range only', (tester) async {
    await tester.pumpWidget(
      _host(
        const SeedTablePagination(
          currentPage: 3,
          rowsPerPage: 25,
          currentPageItemCount: 12,
          hasPreviousPage: true,
          hasNextPage: false,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(_rangeField, findsNothing);
    expect(find.text('51–62'), findsOneWidget);
    expect(find.textContaining('총'), findsNothing);
  });

  for (final width in [800.0, 390.0]) {
    testWidgets(
      'PKG-01: dynamic-height carousel reflects delayed content at $width',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 900);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        final height = ValueNotifier<double>(80);
        addTearDown(height.dispose);
        await tester.pumpWidget(
          _host(
            SeedTabsView(
              carousel: true,
              dynamicHeight: true,
              lazyMount: true,
              items: const [SeedTabItem(label: 'Async', value: 'async')],
              children: [
                ValueListenableBuilder<double>(
                  valueListenable: height,
                  builder: (context, value, _) =>
                      SizedBox(height: value, child: const Text('Async')),
                ),
              ],
            ),
            width: width,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.getSize(find.byType(PageView)).height, 80);
        height.value = 400;
        await tester.pumpAndSettle();
        expect(tester.getSize(find.byType(PageView)).height, 400);
      },
    );
  }

  for (final useChipSubclass in [false, true]) {
    testWidgets(
      'MIX-03: chipListPadding preserves default and forwards 20px, SeedChipTabsView=$useChipSubclass',
      (tester) async {
        Widget buildTabs(EdgeInsetsGeometry? padding) {
          const items = [
            SeedTabItem(label: 'Immediate', value: '1'),
            SeedTabItem(label: 'Async', value: '2'),
          ];
          final children = <Widget>[
            const SizedBox(height: 80, child: Text('One')),
            const SizedBox(height: 120, child: Text('Two')),
          ];
          if (useChipSubclass) {
            return SeedChipTabsView(
              items: items,
              chipListPadding: padding,
              children: children,
            );
          }
          return SeedTabsView(
            items: items,
            variant: SeedTabsVariant.chipSolid,
            chipListPadding: padding,
            showScrollFog: true,
            children: children,
          );
        }

        EdgeInsetsGeometry? actualHeaderPadding() => tester
            .widget<SingleChildScrollView>(
              find
                  .descendant(
                    of: find.byType(SeedTabs),
                    matching: find.byType(SingleChildScrollView),
                  )
                  .first,
            )
            .padding;

        await tester.pumpWidget(_host(buildTabs(null)));
        await tester.pumpAndSettle();
        expect(
          actualHeaderPadding(),
          const EdgeInsets.symmetric(horizontal: 16),
          reason: 'Null continues to use SeedTabs chip default',
        );

        await tester.pumpWidget(
          _host(buildTabs(const EdgeInsets.symmetric(horizontal: 20))),
        );
        await tester.pumpAndSettle();
        expect(
          tester.widget<SeedTabs>(find.byType(SeedTabs)).chipListPadding,
          const EdgeInsets.symmetric(horizontal: 20),
        );
        expect(
          actualHeaderPadding(),
          const EdgeInsets.symmetric(horizontal: 20),
          reason: 'React ChipTabsList explicitly pads both sides by 20px',
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}
