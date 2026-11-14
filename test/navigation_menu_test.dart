import 'dart:ui' show SemanticsRole;

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';

final _outside = FocusNode(debugLabel: 'outside');

Widget _app(Widget child, {TextDirection textDirection = TextDirection.ltr}) =>
    MaterialApp(
      theme: SeedThemeData.light(fontFamily: seedTestFontFamily).toThemeData(),
      home: Directionality(
        textDirection: textDirection,
        child: Scaffold(body: child),
      ),
    );

SeedNavigationMenuRoot _root(
  String value,
  String label,
  List<Widget> items, {
  bool disabled = false,
  SeedOverlaySide? side,
}) => SeedNavigationMenuRoot(
  value: value,
  disabled: disabled,
  side: side,
  trigger: SeedNavigationMenuTrigger(
    child: Padding(padding: const EdgeInsets.all(12), child: Text(label)),
  ),
  content: SeedNavigationMenuContent(
    children: [SeedNavigationMenuGroup(label: '$label group', children: items)],
  ),
);

Widget _menu({
  List<String?>? changes,
  String? value,
  bool controlled = false,
  String? defaultValue,
  VoidCallback? onA1,
  VoidCallback? onA2,
  bool disableB = false,
}) => Padding(
  padding: const EdgeInsets.all(40),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SeedNavigationMenu(
        value: value,
        controlled: controlled,
        defaultValue: defaultValue,
        onValueChange: changes?.add,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _root('a', 'Alpha', [
              SeedNavigationMenuItem(label: 'A1', current: true, onTap: onA1),
              SeedNavigationMenuItem(label: 'A2', onTap: onA2),
              const SeedNavigationMenuItem(label: 'A3', disabled: true),
            ]),
            const SizedBox(width: 24),
            _root('b', 'Beta', disabled: disableB, [
              const SeedNavigationMenuItem(label: 'B1'),
            ]),
          ],
        ),
      ),
      const Spacer(),
      Focus(
        focusNode: _outside,
        child: const SizedBox(
          width: 120,
          height: 40,
          child: Center(child: Text('Outside')),
        ),
      ),
    ],
  ),
);

Future<TestGesture> _mouse(WidgetTester tester) async {
  final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await gesture.addPointer(location: const Offset(700, 580));
  addTearDown(gesture.removePointer);
  return gesture;
}

bool _focusInContent() =>
    FocusManager.instance.primaryFocus?.context
        ?.findAncestorWidgetOfExactType<SeedNavigationMenuContent>() !=
    null;

String? _focusedItem() => FocusManager.instance.primaryFocus?.context
    ?.findAncestorWidgetOfExactType<SeedNavigationMenuItem>()
    ?.label;

bool _focusOnTrigger() =>
    FocusManager.instance.primaryFocus?.context
        ?.findAncestorWidgetOfExactType<SeedNavigationMenuTrigger>() !=
    null;

void main() {
  setUpAll(loadSeedTestFonts);

  group('hover', () {
    testWidgets('opens after 200ms and closes 100ms after leaving', (
      tester,
    ) async {
      final changes = <String?>[];
      await tester.pumpWidget(_app(_menu(changes: changes)));
      final mouse = await _mouse(tester);
      await mouse.moveTo(tester.getCenter(find.text('Alpha')));
      await tester.pump(const Duration(milliseconds: 190));
      expect(find.text('A1'), findsNothing);
      await tester.pump(const Duration(milliseconds: 20));
      await tester.pumpAndSettle();
      expect(find.text('A1'), findsOneWidget);
      expect(changes, ['a']);

      await mouse.moveTo(const Offset(700, 580));
      await tester.pump(const Duration(milliseconds: 90));
      expect(changes, ['a']);
      await tester.pump(const Duration(milliseconds: 20));
      await tester.pumpAndSettle();
      expect(changes, ['a', null]);
      expect(find.text('A1'), findsNothing);
    });

    testWidgets('leaving before the open delay cancels the opening', (
      tester,
    ) async {
      await tester.pumpWidget(_app(_menu()));
      final mouse = await _mouse(tester);
      await mouse.moveTo(tester.getCenter(find.text('Alpha')));
      await tester.pump(const Duration(milliseconds: 100));
      await mouse.moveTo(const Offset(700, 580));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('A1'), findsNothing);
    });

    testWidgets('moving to an open sibling switches instantly', (tester) async {
      await tester.pumpWidget(_app(_menu()));
      final mouse = await _mouse(tester);
      await mouse.moveTo(tester.getCenter(find.text('Alpha')));
      await tester.pump(const Duration(milliseconds: 210));
      await tester.pumpAndSettle();
      expect(find.text('A1'), findsOneWidget);

      await mouse.moveTo(tester.getCenter(find.text('Beta')));
      await tester.pump();
      await tester.pump();
      await tester.pump();
      // Far less than the 200ms open delay has elapsed.
      expect(find.text('B1'), findsOneWidget);
      expect(find.text('A1'), findsNothing);
      await mouse.moveTo(const Offset(700, 580));
      await tester.pumpAndSettle(const Duration(milliseconds: 50));
    });

    testWidgets('pointer path from trigger into the flyout keeps it open', (
      tester,
    ) async {
      await tester.pumpWidget(_app(_menu()));
      final mouse = await _mouse(tester);
      await mouse.moveTo(tester.getCenter(find.text('Alpha')));
      await tester.pump(const Duration(milliseconds: 210));
      await tester.pumpAndSettle();
      // Cross the 8px gutter, then rest on an item.
      final trigger = tester.getRect(find.text('Alpha'));
      await mouse.moveTo(Offset(trigger.center.dx, trigger.bottom + 16));
      await tester.pump(const Duration(milliseconds: 40));
      await mouse.moveTo(tester.getCenter(find.text('A2')));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('A2'), findsOneWidget);
      await mouse.moveTo(const Offset(700, 580));
      await tester.pumpAndSettle();
      expect(find.text('A2'), findsNothing);
    });

    testWidgets('hover never moves focus', (tester) async {
      await tester.pumpWidget(_app(_menu()));
      _outside.requestFocus();
      await tester.pump();
      final mouse = await _mouse(tester);
      await mouse.moveTo(tester.getCenter(find.text('Alpha')));
      await tester.pump(const Duration(milliseconds: 210));
      await tester.pumpAndSettle();
      expect(find.text('A1'), findsOneWidget);
      expect(_outside.hasPrimaryFocus, isTrue);
      await mouse.moveTo(tester.getCenter(find.text('A1')));
      await tester.pump(const Duration(milliseconds: 300));
      expect(_outside.hasPrimaryFocus, isTrue);
      await mouse.moveTo(const Offset(700, 580));
      await tester.pumpAndSettle();
    });

    testWidgets('a click keeps a hover-opened flyout open on leave', (
      tester,
    ) async {
      await tester.pumpWidget(_app(_menu()));
      final mouse = await _mouse(tester);
      await mouse.moveTo(tester.getCenter(find.text('Alpha')));
      await tester.pump(const Duration(milliseconds: 210));
      await tester.pumpAndSettle();
      await mouse.down(tester.getCenter(find.text('Alpha')));
      await mouse.up();
      await tester.pump();
      await mouse.moveTo(const Offset(700, 580));
      await tester.pumpAndSettle(const Duration(milliseconds: 50));
      expect(find.text('A1'), findsOneWidget);
      // The click did not move focus into the flyout.
      expect(_focusInContent(), isFalse);
    });
  });

  group('click and touch', () {
    testWidgets('tap toggles, outside tap and Escape dismiss', (tester) async {
      await tester.pumpWidget(_app(_menu()));
      await tester.tap(find.text('Alpha'));
      await tester.pumpAndSettle();
      expect(find.text('A1'), findsOneWidget);
      await tester.tap(find.text('Alpha'));
      await tester.pumpAndSettle();
      expect(find.text('A1'), findsNothing);

      await tester.tap(find.text('Alpha'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Outside'));
      await tester.pumpAndSettle();
      expect(find.text('A1'), findsNothing);

      await tester.tap(find.text('Alpha'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('A1'), findsNothing);
    });

    testWidgets('mouse click does not move focus into the flyout', (
      tester,
    ) async {
      await tester.pumpWidget(_app(_menu()));
      await tester.tap(find.text('Alpha'), kind: PointerDeviceKind.mouse);
      await tester.pumpAndSettle();
      expect(find.text('A1'), findsOneWidget);
      expect(_focusInContent(), isFalse);
    });

    testWidgets('Escape closes a hover-opened flyout with focus elsewhere', (
      tester,
    ) async {
      await tester.pumpWidget(_app(_menu()));
      _outside.requestFocus();
      final mouse = await _mouse(tester);
      await mouse.moveTo(tester.getCenter(find.text('Alpha')));
      await tester.pump(const Duration(milliseconds: 210));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('A1'), findsNothing);
      expect(_outside.hasPrimaryFocus, isTrue);
    });

    testWidgets('only one flyout is open at a time', (tester) async {
      final changes = <String?>[];
      await tester.pumpWidget(_app(_menu(changes: changes)));
      await tester.tap(find.text('Alpha'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Beta'));
      await tester.pumpAndSettle();
      expect(find.text('A1'), findsNothing);
      expect(find.text('B1'), findsOneWidget);
      expect(changes.last, 'b');
    });

    testWidgets('selecting an item runs onTap and closes', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_app(_menu(onA2: () => taps++)));
      await tester.tap(find.text('Alpha'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('A2'));
      await tester.pumpAndSettle();
      expect(taps, 1);
      expect(find.text('A2'), findsNothing);
    });

    testWidgets('an item without onTap is enabled and still closes', (
      tester,
    ) async {
      await tester.pumpWidget(_app(_menu()));
      await tester.tap(find.text('Alpha'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('A1'));
      await tester.pumpAndSettle();
      expect(find.text('A1'), findsNothing);
    });

    testWidgets('a disabled item ignores taps', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_app(_menu()));
      await tester.tap(find.text('Alpha'));
      await tester.pumpAndSettle();
      expect(
        tester.getSemantics(find.text('A3')),
        isSemantics(isButton: true, hasEnabledState: true, isEnabled: false),
      );
      await tester.tap(find.text('A3'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.text('A3'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('a disabled root opens on neither hover nor tap', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_app(_menu(disableB: true)));
      expect(
        tester.getSemantics(find.text('Beta')),
        isSemantics(isEnabled: false),
      );
      await tester.tap(find.text('Beta'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.text('B1'), findsNothing);
      final mouse = await _mouse(tester);
      await mouse.moveTo(tester.getCenter(find.text('Beta')));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('B1'), findsNothing);
      handle.dispose();
    });
  });

  group('keyboard', () {
    testWidgets('Enter moves focus in, Tab walks items, Escape returns', (
      tester,
    ) async {
      await tester.pumpWidget(_app(_menu()));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(_focusOnTrigger(), isTrue);
      expect(find.text('A1'), findsNothing, reason: 'focus does not open');

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.text('A1'), findsOneWidget);
      expect(_focusedItem(), 'A1');
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(_focusedItem(), 'A2');

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('A1'), findsNothing);
      expect(_focusOnTrigger(), isTrue);
      expect(
        FocusManager.instance.primaryFocus?.context
            ?.findAncestorWidgetOfExactType<SeedNavigationMenuRoot>()
            ?.value,
        'a',
      );
    });

    testWidgets('selecting by keyboard closes and returns focus', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(_app(_menu(onA1: () => taps++)));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(_focusedItem(), 'A1');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(taps, 1);
      expect(find.text('A1'), findsNothing);
      expect(_focusOnTrigger(), isTrue);
    });

    testWidgets('Tab past the last item leaves and closes the flyout', (
      tester,
    ) async {
      await tester.pumpWidget(_app(_menu()));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab); // A2
      await tester.sendKeyEvent(LogicalKeyboardKey.tab); // leaves (A3 disabled)
      await tester.pumpAndSettle();
      expect(find.text('A1'), findsNothing);
      expect(_focusInContent(), isFalse);
      // Focus continued with the next control after the trigger.
      expect(
        FocusManager.instance.primaryFocus?.context
            ?.findAncestorWidgetOfExactType<SeedNavigationMenuRoot>()
            ?.value,
        'b',
      );
    });
  });

  group('semantics', () {
    testWidgets('trigger is an expandable button, flyout is not a menu', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_app(_menu()));
      expect(
        tester.getSemantics(find.text('Alpha')),
        isSemantics(isButton: true, hasExpandedState: true, isExpanded: false),
      );
      await tester.tap(find.text('Alpha'));
      await tester.pumpAndSettle();
      expect(
        tester.getSemantics(find.text('Alpha')),
        isSemantics(hasExpandedState: true, isExpanded: true),
      );
      expect(
        tester.getSemantics(find.text('A1')),
        isSemantics(isButton: true, hasSelectedState: true, isSelected: true),
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              (widget.properties.role == SemanticsRole.menu ||
                  widget.properties.role == SemanticsRole.menuItem),
        ),
        findsNothing,
      );
      handle.dispose();
    });
  });

  group('controlled value', () {
    testWidgets('programmatic reopen does not reuse keyboard focus policy', (
      tester,
    ) async {
      String? value;
      late StateSetter rebuild;
      await tester.pumpWidget(
        _app(
          StatefulBuilder(
            builder: (context, setState) {
              rebuild = setState;
              return _menu(value: value, controlled: true, changes: []);
            },
          ),
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      rebuild(() => value = 'a');
      await tester.pumpAndSettle();
      expect(_focusedItem(), 'A1');

      rebuild(() => value = null);
      await tester.pumpAndSettle();
      _outside.requestFocus();
      await tester.pump();
      expect(_outside.hasPrimaryFocus, isTrue);

      rebuild(() => value = 'a');
      await tester.pumpAndSettle();
      expect(find.text('A1'), findsOneWidget);
      expect(_outside.hasPrimaryFocus, isTrue);
    });

    testWidgets('a parent can reject a close and an open', (tester) async {
      final changes = <String?>[];
      await tester.pumpWidget(_app(_menu(changes: changes, value: 'a')));
      await tester.pumpAndSettle();
      expect(find.text('A1'), findsOneWidget);

      await tester.tap(find.text('Outside'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      await tester.tap(find.text('A2'));
      await tester.pumpAndSettle();
      expect(changes, [null, null, null]);
      expect(find.text('A1'), findsOneWidget);

      await tester.tap(find.text('Beta'));
      await tester.pumpAndSettle();
      // Outside press for A and the open proposal for B, both rejected by
      // the parent. A was not opened by keyboard, so focus leaving its item
      // is not a dismissal (React FloatingFocusManager is disabled).
      expect(changes.skip(3), [null, 'b']);
      expect(find.text('B1'), findsNothing);
      expect(find.text('A1'), findsOneWidget);
    });

    testWidgets('controlled null rejects opening and follows the parent', (
      tester,
    ) async {
      final changes = <String?>[];
      await tester.pumpWidget(_app(_menu(changes: changes, controlled: true)));
      await tester.tap(find.text('Alpha'));
      await tester.pumpAndSettle();
      expect(changes, ['a']);
      expect(find.text('A1'), findsNothing);

      await tester.pumpWidget(
        _app(_menu(changes: changes, controlled: true, value: 'b')),
      );
      await tester.pumpAndSettle();
      expect(find.text('B1'), findsOneWidget);
      await tester.pumpWidget(_app(_menu(changes: changes, controlled: true)));
      await tester.pumpAndSettle();
      expect(find.text('B1'), findsNothing);
    });

    testWidgets('defaultValue opens initially', (tester) async {
      await tester.pumpWidget(_app(_menu(defaultValue: 'b')));
      await tester.pumpAndSettle();
      expect(find.text('B1'), findsOneWidget);
    });
  });

  group('placement', () {
    testWidgets('defaults to bottom with an 8px gutter', (tester) async {
      await tester.pumpWidget(_app(_menu()));
      await tester.tap(find.text('Alpha'));
      await tester.pumpAndSettle();
      final trigger = tester.getRect(
        find.byType(SeedNavigationMenuTrigger).first,
      );
      final content = tester.getRect(find.byType(SeedNavigationMenuContent));
      expect(content.top, moreOrLessEquals(trigger.bottom + 8));
      expect(content.width, 240);
    });

    testWidgets('narrow viewport keeps the flyout inside and flips up', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(300, 400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        _app(
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: SeedNavigationMenu(
                child: _root('a', 'Alpha', [
                  for (var i = 0; i < 3; i++)
                    SeedNavigationMenuItem(label: 'Item $i'),
                ]),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Alpha'));
      await tester.pumpAndSettle();
      final trigger = tester.getRect(find.byType(SeedNavigationMenuTrigger));
      final content = tester.getRect(find.byType(SeedNavigationMenuContent));
      expect(content.bottom, moreOrLessEquals(trigger.top - 8));
      expect(content.left, greaterThanOrEqualTo(8));
      expect(content.right, lessThanOrEqualTo(292));
      expect(content.top, greaterThanOrEqualTo(8));
    });

    testWidgets('overflow padding adds the safe-area inset', (tester) async {
      tester.view.physicalSize = const Size(300, 600);
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(right: 30);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        _app(
          Align(
            alignment: Alignment.topRight,
            child: SeedNavigationMenu(
              child: _root('a', 'Alpha', [
                const SeedNavigationMenuItem(label: 'Item'),
              ]),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Alpha'));
      await tester.pumpAndSettle();
      final content = tester.getRect(find.byType(SeedNavigationMenuContent));
      expect(content.right, lessThanOrEqualTo(300 - 30 - 8));
    });

    testWidgets('per-root side override', (tester) async {
      await tester.pumpWidget(
        _app(
          Center(
            child: SeedNavigationMenu(
              child: _root('a', 'Alpha', side: SeedOverlaySide.right, [
                const SeedNavigationMenuItem(label: 'Item'),
              ]),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Alpha'));
      await tester.pumpAndSettle();
      final trigger = tester.getRect(find.byType(SeedNavigationMenuTrigger));
      final content = tester.getRect(find.byType(SeedNavigationMenuContent));
      expect(content.left, moreOrLessEquals(trigger.right + 8));
    });

    testWidgets('start alignment follows RTL', (tester) async {
      await tester.pumpWidget(
        _app(
          textDirection: TextDirection.rtl,
          Center(
            child: SeedNavigationMenu(
              align: SeedOverlayAlign.start,
              child: _root('a', 'Alpha', [
                const SeedNavigationMenuItem(label: 'Item'),
              ]),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Alpha'));
      await tester.pumpAndSettle();
      final trigger = tester.getRect(find.byType(SeedNavigationMenuTrigger));
      final content = tester.getRect(find.byType(SeedNavigationMenuContent));
      expect(content.right, moreOrLessEquals(trigger.right));
    });
  });

  group('collapsed SideNavigation', () {
    Widget sidebar({
      String? selectedId,
      TextDirection textDirection = TextDirection.ltr,
      VoidCallback? onChild,
    }) => _app(
      textDirection: textDirection,
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: SizedBox(
          height: 500,
          child: SeedSideNavigation(
            collapsed: true,
            selectedId: selectedId,
            groups: [
              SeedSideNavGroup(
                items: [
                  const SeedSideNavItem(
                    id: 'home',
                    label: 'Home',
                    icon: Icons.home,
                  ),
                  SeedSideNavItem(
                    id: 'parent',
                    label: 'Parent',
                    icon: Icons.settings,
                    subItems: [
                      // 12-04: no onTap, not disabled.
                      const SeedSideNavSubItem(id: 'plain', label: 'Plain'),
                      SeedSideNavSubItem(
                        id: 'child',
                        label: 'Child',
                        badge: 'New',
                        onTap: onChild,
                      ),
                      const SeedSideNavSubItem(
                        id: 'off',
                        label: 'Off',
                        disabled: true,
                      ),
                    ],
                  ),
                  const SeedSideNavItem(
                    id: 'other',
                    label: 'Other',
                    icon: Icons.star,
                    subItems: [SeedSideNavSubItem(id: 'o1', label: 'O1')],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    testWidgets('flyout opens right-start after the hover delay', (
      tester,
    ) async {
      await tester.pumpWidget(sidebar());
      final mouse = await _mouse(tester);
      await mouse.moveTo(tester.getCenter(find.byIcon(Icons.settings)));
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.text('Plain'), findsNothing);
      await tester.pump(const Duration(milliseconds: 60));
      await tester.pumpAndSettle();
      expect(find.text('Parent'), findsOneWidget); // group label
      final trigger = tester.getRect(
        find.byType(SeedNavigationMenuTrigger).first,
      );
      final content = tester.getRect(find.byType(SeedNavigationMenuContent));
      expect(content.left, moreOrLessEquals(trigger.right + 8));
      expect(content.top, moreOrLessEquals(trigger.top));

      // Instant switch to the sibling flyout.
      await mouse.moveTo(tester.getCenter(find.byIcon(Icons.star)));
      await tester.pump();
      await tester.pump();
      await tester.pump();
      expect(find.text('O1'), findsOneWidget);
      expect(find.text('Plain'), findsNothing);
      await mouse.moveTo(const Offset(700, 580));
      await tester.pumpAndSettle();
      expect(find.text('O1'), findsNothing);
    });

    testWidgets('an open flyout makes the item tooltips instant', (
      tester,
    ) async {
      await tester.pumpWidget(sidebar());
      final mouse = await _mouse(tester);
      await mouse.moveTo(tester.getCenter(find.byIcon(Icons.settings)));
      await tester.pump(const Duration(milliseconds: 210));
      await tester.pumpAndSettle();
      await mouse.moveTo(tester.getCenter(find.byIcon(Icons.home)));
      await tester.pump(Duration.zero);
      await tester.pump();
      await tester.pump();
      expect(find.text('Home'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('Plain'), findsNothing);
      await mouse.moveTo(const Offset(700, 580));
      await tester.pumpAndSettle();
    });

    testWidgets('a sub item without onTap stays enabled (12-04)', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(sidebar());
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      expect(
        tester.getSemantics(find.text('Plain')),
        isSemantics(isButton: true, hasEnabledState: true, isEnabled: true),
      );
      expect(
        tester.getSemantics(find.text('Off')),
        isSemantics(hasEnabledState: true, isEnabled: false),
      );
      expect(find.text('New'), findsOneWidget);
      await tester.tap(find.text('Off'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.text('Plain'), findsOneWidget);
      await tester.tap(find.text('Plain'));
      await tester.pumpAndSettle();
      expect(find.text('Plain'), findsNothing);
      handle.dispose();
    });

    testWidgets('keyboard opens into the flyout and Escape returns focus', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(sidebar(onChild: () => taps++));
      final parent = find.byType(SeedNavigationMenuTrigger).first;
      // Home is the first stop, Parent the second.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(find.text('Plain'), findsNothing);
      expect(_focusOnTrigger(), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(_focusedItem(), 'Plain');
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Plain'), findsNothing);
      expect(
        FocusManager.instance.primaryFocus?.context
            ?.findAncestorWidgetOfExactType<SeedNavigationMenuTrigger>(),
        tester.widget(parent),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(_focusedItem(), 'Child');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(taps, 1);
      expect(find.text('Child'), findsNothing);
      expect(_focusOnTrigger(), isTrue);
    });

    testWidgets('RTL flyout opens toward the content on the left', (
      tester,
    ) async {
      await tester.pumpWidget(sidebar(textDirection: TextDirection.rtl));
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      final trigger = tester.getRect(
        find.byType(SeedNavigationMenuTrigger).first,
      );
      final content = tester.getRect(find.byType(SeedNavigationMenuContent));
      expect(content.right, moreOrLessEquals(trigger.left - 8));
      expect(content.top, moreOrLessEquals(trigger.top));
    });

    testWidgets('selected child marks the flyout item current', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(sidebar(selectedId: 'child'));
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      expect(
        tester.getSemantics(find.text('Child')),
        isSemantics(hasSelectedState: true, isSelected: true),
      );
      handle.dispose();
    });
  });

  // Regression: a flyout opened by hover and closed by leaving could not be
  // hovered open again; it closed one frame after reopening. pumpAndSettle's
  // 100ms frames hid it, so these tests pump 16ms frames.
  group('hover reopen', () {
    Future<void> hoverOpen(
      WidgetTester tester,
      TestGesture mouse,
      String label,
      String item,
      String reason,
    ) async {
      await mouse.moveTo(tester.getCenter(find.text(label)));
      await _frames(tester, 300);
      expect(find.text(item), findsOneWidget, reason: '$reason opens');
      // Still open after resting on the trigger for another second.
      await _frames(tester, 1000);
      expect(find.text(item), findsOneWidget, reason: '$reason stays open');
    }

    Future<void> leave(
      WidgetTester tester,
      TestGesture mouse,
      String item,
      String reason,
    ) async {
      await mouse.moveTo(const Offset(700, 580));
      await _frames(tester, 800);
      expect(find.text(item), findsNothing, reason: '$reason closes');
    }

    testWidgets('hover opens the same flyout again after leaving', (
      tester,
    ) async {
      final changes = <String?>[];
      await tester.pumpWidget(_app(_menu(changes: changes)));
      final mouse = await _mouse(tester);
      for (var round = 1; round <= 3; round++) {
        await hoverOpen(tester, mouse, 'Alpha', 'A1', 'round $round');
        await leave(tester, mouse, 'A1', 'round $round');
      }
      expect(changes, ['a', null, 'a', null, 'a', null]);
    });

    testWidgets('hover reopens after switching to a sibling and leaving', (
      tester,
    ) async {
      final changes = <String?>[];
      await tester.pumpWidget(_app(_menu(changes: changes)));
      final mouse = await _mouse(tester);
      for (var round = 1; round <= 2; round++) {
        await hoverOpen(tester, mouse, 'Alpha', 'A1', 'round $round a');
        await mouse.moveTo(tester.getCenter(find.text('Beta')));
        await _frames(tester, 48);
        // Instant switch, far below the 200ms open delay.
        expect(find.text('B1'), findsOneWidget, reason: 'round $round b');
        expect(find.text('A1'), findsNothing, reason: 'round $round a gone');
        await _frames(tester, 1000);
        expect(find.text('B1'), findsOneWidget, reason: 'round $round b stays');
        await leave(tester, mouse, 'B1', 'round $round b');
      }
      expect(changes, ['a', 'b', null, 'a', 'b', null]);
    });

    testWidgets('focus moving elsewhere keeps a hover-opened flyout open', (
      tester,
    ) async {
      final first = FocusNode(debugLabel: 'first field');
      final second = FocusNode(debugLabel: 'second field');
      addTearDown(first.dispose);
      addTearDown(second.dispose);
      final changes = <String?>[];
      await tester.pumpWidget(
        _app(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _menu(changes: changes)),
              SizedBox(width: 200, child: TextField(focusNode: first)),
              SizedBox(width: 200, child: TextField(focusNode: second)),
            ],
          ),
        ),
      );
      final mouse = await _mouse(tester);

      // Focus moves between two outside fields while the pointer rests on
      // the trigger of a hover-opened flyout.
      for (var round = 1; round <= 2; round++) {
        await hoverOpen(tester, mouse, 'Alpha', 'A1', 'round $round');
        first.requestFocus();
        await _frames(tester, 48);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await _frames(tester, 48);
        expect(second.hasPrimaryFocus, isTrue);
        await _frames(tester, 1000);
        expect(find.text('A1'), findsOneWidget, reason: 'round $round');
        await leave(tester, mouse, 'A1', 'round $round');
      }
      expect(changes, ['a', null, 'a', null]);
    });

    testWidgets('a keyboard-opened flyout still closes on focus-out', (
      tester,
    ) async {
      final field = FocusNode(debugLabel: 'field');
      addTearDown(field.dispose);
      await tester.pumpWidget(
        _app(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _menu()),
              SizedBox(width: 200, child: TextField(focusNode: field)),
            ],
          ),
        ),
      );
      Future<void> openByKeyboard() async {
        FocusManager.instance.primaryFocus?.unfocus();
        await _frames(tester, 48);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await _frames(tester, 400);
        expect(_focusedItem(), 'A1');
      }

      // Escape closes and returns focus to the trigger.
      await openByKeyboard();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await _frames(tester, 400);
      expect(find.text('A1'), findsNothing);
      expect(_focusOnTrigger(), isTrue);

      // Tab past the last item leaves and closes.
      await openByKeyboard();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab); // A2
      await tester.sendKeyEvent(LogicalKeyboardKey.tab); // leaves
      await _frames(tester, 400);
      expect(find.text('A1'), findsNothing);
      expect(_focusInContent(), isFalse);

      // Focus moving to another control closes it as well.
      await openByKeyboard();
      field.requestFocus();
      await _frames(tester, 400);
      expect(find.text('A1'), findsNothing);
      expect(field.hasPrimaryFocus, isTrue);

      // Hover opens again afterwards without the keyboard focus-out rule.
      final mouse = await _mouse(tester);
      await mouse.moveTo(tester.getCenter(find.text('Alpha')));
      await _frames(tester, 300);
      expect(find.text('A1'), findsOneWidget);
      field.unfocus();
      await _frames(tester, 1000);
      expect(find.text('A1'), findsOneWidget);
      await mouse.moveTo(const Offset(700, 580));
      await _frames(tester, 800);
      expect(find.text('A1'), findsNothing);
    });
  });
}

Future<void> _frames(WidgetTester tester, int ms) async {
  for (var i = 0; i < ms ~/ 16; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}
