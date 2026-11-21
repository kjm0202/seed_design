import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';
import 'package:seed_design_example/stackflow_spa/spa_paths.dart';
import 'package:seed_design_example/stackflow_spa/stackflow_spa.dart';

// A wide, short window with system insets on the top, the right and the
// bottom, like an unfolded foldable: iPhone Duo keeps its status column in the
// right corner, and Pixel Fold has a top cutout and a bottom gesture bar.
const _size = Size(951, 669);
const _inset = 40.0;
final _safe = Rect.fromLTRB(
  0,
  _inset,
  _size.width - _inset,
  _size.height - _inset,
);

// Known exceptions that are not system-inset collisions.
const _allowed = <String, String>{
  // A full-body tap target that dismisses the keyboard; it is a background.
  '/swipe-back-keyboard': 'GestureDetector',
};

Object? _argumentsFor(String activity) => switch (activity) {
  'ActivityDetail' => <String, Object>{'title': 'T', 'body': 'B'},
  'ActivityDemoArticleDetail' => 1,
  _ => null,
};

Future<void> _open(
  WidgetTester tester,
  String path, {
  Object? arguments,
}) async {
  tester.view.physicalSize = _size;
  tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(
    top: _inset,
    right: _inset,
    bottom: _inset,
  );
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const StackflowSpaApp());
  await tester.pump();
  tester
      .state<NavigatorState>(find.byType(Navigator))
      .pushNamed(path, arguments: arguments);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pump();
}

Future<void> _dispose(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 5));
}

Rect _rectOf(RenderBox box) => box.localToGlobal(Offset.zero) & box.size;

List<String> _collisions(WidgetTester tester, String path) {
  final found = <String>[];
  void check(Element element, RenderBox box, String label, {bool tap = false}) {
    if (!box.hasSize || box.size.isEmpty) return;
    final rect = _rectOf(box);
    if (tap && (rect.width > 900 || rect.height > 560)) return;
    final scrollable = element.findAncestorStateOfType<ScrollableState>();
    final axis = scrollable?.position.axis;
    if (rect.top < _safe.top - 0.5) found.add('top $label $rect');
    if (axis != Axis.horizontal && rect.right > _safe.right + 0.5) {
      found.add('right $label $rect');
    }
    // Scrolled content may pass under the gesture bar; fixed content may not.
    if (scrollable == null && rect.bottom > _safe.bottom + 0.5) {
      found.add('bottom $label $rect');
    }
  }

  for (final element in find.byType(RichText).hitTestable().evaluate()) {
    final text = (element.widget as RichText).text.toPlainText().trim();
    if (text.isEmpty) continue;
    check(element, element.renderObject! as RenderBox, '"$text"');
  }
  for (final element
      in find
          .byWidgetPredicate((w) => w is InkResponse || w is GestureDetector)
          .hitTestable()
          .evaluate()) {
    final type = '${element.widget.runtimeType}';
    if (_allowed[path] == type) continue;
    final box = element.findRenderObject();
    if (box is RenderBox) check(element, box, type, tap: true);
  }
  return found;
}

void main() {
  for (final entry in spaActivityPaths.entries) {
    testWidgets('${entry.value} keeps content out of system insets', (
      tester,
    ) async {
      await _open(tester, entry.value, arguments: _argumentsFor(entry.key));
      tester.takeException();
      final collisions = _collisions(tester, entry.value);
      expect(collisions, isEmpty, reason: collisions.take(3).join('\n'));
      await _dispose(tester);
    });
  }

  testWidgets('/form keeps its fixed submit button above the gesture bar', (
    tester,
  ) async {
    await _open(tester, '/form');
    final button = find.widgetWithText(SeedButton, '제출').last;
    expect(tester.getRect(button).bottom, lessThanOrEqualTo(_safe.bottom));
    await _dispose(tester);
  });

  testWidgets('/side-navigation surface runs under the status bar', (
    tester,
  ) async {
    await _open(tester, '/side-navigation');
    final navigation = tester.getRect(find.byType(SeedSideNavigation));
    // Items start below the status bar ...
    expect(navigation.top, _inset);
    // ... while a strip in the navigation surface color fills the inset.
    final strip = find.byWidgetPredicate(
      (w) =>
          w is DecoratedBox &&
          w.decoration is BoxDecoration &&
          (w.decoration as BoxDecoration).color == SeedPalette.gray100Light,
    );
    final stripRect = tester.getRect(strip.first);
    expect(stripRect.top, 0);
    expect(stripRect.height, _inset);
    expect(stripRect.width, navigation.width);
    await _dispose(tester);
  });

  testWidgets('/form shows a back button only when it has a previous page', (
    tester,
  ) async {
    // Pushed from home: the AppBar back button is present.
    await _open(tester, '/form');
    expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);
    await _dispose(tester);
  });

  for (final brightness in Brightness.values) {
    testWidgets(
      '/app-screen-transparent status bar contrasts with its background '
      '(${brightness.name})',
      (tester) async {
        tester.platformDispatcher.platformBrightnessTestValue = brightness;
        addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
        await _open(tester, '/app-screen-transparent');
        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).last);
        final region = tester.widget<AnnotatedRegion<SystemUiOverlayStyle>>(
          find.byType(AnnotatedRegion<SystemUiOverlayStyle>).last,
        );
        final darkBackground =
            ThemeData.estimateBrightnessForColor(scaffold.backgroundColor!) ==
            Brightness.dark;
        expect(
          region.value.statusBarIconBrightness,
          darkBackground ? Brightness.light : Brightness.dark,
        );
        await _dispose(tester);
      },
    );
  }
}
