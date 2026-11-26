import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

List<SeedAttachmentItem> _files(int count) => [
  for (var i = 0; i < count; i++)
    SeedAttachmentItem(
      id: 'file-$i',
      name: 'report-$i.pdf',
      sizeText: '1.2 MB',
      type: SeedAttachmentType.file,
    ),
];

class _Harness extends StatefulWidget {
  const _Harness({required this.count});

  final int count;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  late List<SeedAttachmentItem> items = _files(widget.count);

  @override
  Widget build(BuildContext context) => SeedAttachmentInput(
    items: items,
    showTrigger: false,
    maxCount: 10,
    onReorder: (from, to) => setState(() {
      final next = items.toList();
      next.insert(to > from ? to - 1 : to, next.removeAt(from));
      items = next;
    }),
    onRemove: (item) =>
        setState(() => items = items.where((e) => e.id != item.id).toList()),
  );
}

Widget _host(Widget child) => MaterialApp(
  supportedLocales: const [Locale('en'), Locale('ko')],
  locale: const Locale('en'),
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(
    body: Align(
      alignment: Alignment.topLeft,
      child: SizedBox(width: 390, child: child),
    ),
  ),
);

// The delayed drag starts after kLongPressTimeout; the proxy animation then
// takes 250ms. Pump past both so the scale feedback is fully applied.
Future<TestGesture> _startDrag(WidgetTester tester, String id) async {
  final gesture = await tester.startGesture(
    tester.getCenter(find.byKey(ValueKey(id))),
  );
  await tester.pump(const Duration(milliseconds: 650));
  await gesture.moveBy(const Offset(24, 0));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  return gesture;
}

void main() {
  testWidgets('dragged proxy uses SEED scale feedback and no elevation', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 300);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_host(const _Harness(count: 3)));
    await tester.pumpAndSettle();

    final proxy = find.byKey(const ValueKey('file-0'));
    final gesture = await _startDrag(tester, 'file-0');

    // The item moved into the overlay proxy; the list slot is now empty.
    expect(proxy, findsOneWidget);
    final layoutSize = tester.getSize(proxy);
    final rendered = tester.getRect(proxy);
    final measuredScale = rendered.width / layoutSize.width;
    final expectedScale = SeedScaleCalculator.calculateScale(
      width: layoutSize.width,
      height: layoutSize.height,
    );
    expect(measuredScale, closeTo(expectedScale, 1e-3));

    // The official dragging item has no drop shadow: Material's default
    // elevation proxy must not wrap it.
    final materials = tester.widgetList<Material>(
      find.ancestor(of: proxy, matching: find.byType(Material)),
    );
    expect(materials.where((material) => material.elevation > 0), isEmpty);

    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('reduced motion keeps the dragged proxy unscaled', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 300);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    await tester.pumpWidget(_host(const _Harness(count: 3)));
    await tester.pumpAndSettle();

    final proxy = find.byKey(const ValueKey('file-0'));
    final gesture = await _startDrag(tester, 'file-0');

    // Still verify the proxy is the dragged, dragging-state copy.
    expect(
      find.descendant(of: proxy, matching: find.byIcon(Icons.close_rounded)),
      findsNothing,
    );
    final layoutSize = tester.getSize(proxy);
    final rendered = tester.getRect(proxy);
    expect(rendered.width, closeTo(layoutSize.width, 1e-3));
    expect(rendered.height, closeTo(layoutSize.height, 1e-3));

    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('a local reduced-motion override reaches the dragged proxy', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 300);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Only the input disables animations; the platform and the overlay that
    // hosts the proxy keep them on.
    await tester.pumpWidget(
      _host(
        Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: const _Harness(count: 3),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final proxy = find.byKey(const ValueKey('file-0'));
    final gesture = await _startDrag(tester, 'file-0');

    expect(
      find.descendant(of: proxy, matching: find.byIcon(Icons.close_rounded)),
      findsNothing,
    );
    final layoutSize = tester.getSize(proxy);
    final rendered = tester.getRect(proxy);
    expect(rendered.width, closeTo(layoutSize.width, 1e-3));
    expect(rendered.height, closeTo(layoutSize.height, 1e-3));

    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('dragged proxy shows dragging state and restores after drop', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 300);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_host(const _Harness(count: 3)));
    await tester.pumpAndSettle();

    final proxy = find.byKey(const ValueKey('file-0'));
    final gesture = await _startDrag(tester, 'file-0');

    // type=file dragging hides the remove button.
    expect(
      find.descendant(of: proxy, matching: find.byIcon(Icons.close_rounded)),
      findsNothing,
    );
    // ...and dims the thumbnail icon, name and size with fg.disabled.
    final name = tester.widget<SeedMiddleTruncate>(
      find.descendant(of: proxy, matching: find.byType(SeedMiddleTruncate)),
    );
    expect(name.style?.color, SeedThemeData.light().colorScheme.fg.disabled);

    await gesture.up();
    await tester.pumpAndSettle();

    final item = find.byKey(const ValueKey('file-0'));
    expect(
      find.descendant(of: item, matching: find.byIcon(Icons.close_rounded)),
      findsOneWidget,
    );
  });
}
