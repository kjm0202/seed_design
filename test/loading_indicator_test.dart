import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

Widget _host(Widget child) => MaterialApp(
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(
    body: Align(alignment: Alignment.topLeft, child: child),
  ),
);

class _Counter extends StatefulWidget {
  const _Counter();

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int count = 0;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => setState(() => count++),
    child: SizedBox(width: 120, height: 40, child: Text('Save $count')),
  );
}

void main() {
  testWidgets('keeps the content size while loading, even with a larger '
      'indicator', (tester) async {
    Widget build(bool loading) => _host(
      SeedLoadingIndicator(
        key: const ValueKey('indicator'),
        loading: loading,
        indicator: const SizedBox(
          key: ValueKey('big'),
          width: 200,
          height: 200,
        ),
        child: const SizedBox(width: 120, height: 40),
      ),
    );
    await tester.pumpWidget(build(false));
    final idle = tester.getSize(find.byKey(const ValueKey('indicator')));
    await tester.pumpWidget(build(true));
    final busy = tester.getSize(find.byKey(const ValueKey('indicator')));
    expect(idle, const Size(120, 40));
    expect(busy, idle);
    // The overflowing indicator is centered on the content and not clipped.
    final big = tester.getRect(find.byKey(const ValueKey('big')));
    expect(big.size, const Size(200, 200));
    expect(big.center, const Offset(60, 20));
    expect(tester.takeException(), isNull);
  });

  testWidgets('default indicator is a 24px SeedProgressCircle', (tester) async {
    await tester.pumpWidget(
      _host(
        const SeedLoadingIndicator(
          loading: true,
          child: SizedBox(width: 80, height: 40),
        ),
      ),
    );
    expect(find.byType(SeedProgressCircle), findsOneWidget);
    expect(tester.getSize(find.byType(SeedProgressCircle)), const Size(24, 24));
  });

  testWidgets('hidden content is not painted, not in semantics, and the '
      'indicator is announced once', (tester) async {
    final handle = tester.ensureSemantics();
    Widget build(bool loading) => _host(
      SeedLoadingIndicator(
        loading: loading,
        semanticsLabel: '저장 중',
        child: Semantics(
          button: true,
          label: 'Save',
          child: const SizedBox(width: 120, height: 40),
        ),
      ),
    );

    await tester.pumpWidget(build(true));
    expect(find.bySemanticsLabel('Save'), findsNothing);
    expect(find.bySemanticsLabel('저장 중'), findsOneWidget);
    final visibility = tester.widget<Visibility>(find.byType(Visibility));
    expect(visibility.visible, isFalse);
    expect(visibility.maintainSize, isTrue);

    await tester.pumpWidget(build(false));
    expect(find.bySemanticsLabel('Save'), findsOneWidget);
    expect(find.bySemanticsLabel('저장 중'), findsNothing);
    expect(find.byType(SeedProgressCircle), findsNothing);
    handle.dispose();
  });

  testWidgets('content keeps its state across loading changes', (tester) async {
    Widget build(bool loading) => _host(
      SeedLoadingIndicator(
        loading: loading,
        disableOnLoading: false,
        child: const _Counter(),
      ),
    );
    await tester.pumpWidget(build(false));
    await tester.tap(find.byType(_Counter));
    await tester.pump();
    await tester.pumpWidget(build(true));
    await tester.pumpWidget(build(false));
    expect(find.text('Save 1'), findsOneWidget);
  });

  testWidgets('disableOnLoading separately blocks pointer and focus input', (
    tester,
  ) async {
    for (final disable in [true, false]) {
      var taps = 0;
      final node = FocusNode();
      await tester.pumpWidget(
        _host(
          SeedLoadingIndicator(
            key: ValueKey(disable),
            loading: true,
            disableOnLoading: disable,
            child: Focus(
              focusNode: node,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => taps++,
                child: const SizedBox(width: 120, height: 40),
              ),
            ),
          ),
        ),
      );
      await tester.tapAt(const Offset(10, 10));
      node.requestFocus();
      await tester.pump();
      expect(taps, disable ? 0 : 1, reason: 'disableOnLoading: $disable');
      expect(node.hasFocus, !disable, reason: 'disableOnLoading: $disable');
      node.dispose();
    }
  });

  testWidgets('passes tight constraints through to the content', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const SizedBox(
          width: 300,
          height: 48,
          child: SeedLoadingIndicator(
            loading: true,
            child: ColoredBox(key: ValueKey('content'), color: Colors.red),
          ),
        ),
      ),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('content'))),
      const Size(300, 48),
    );
  });
}
