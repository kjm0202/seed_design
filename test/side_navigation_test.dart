import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';

Widget _app(Widget child) => MaterialApp(
  theme: SeedThemeData.light(fontFamily: seedTestFontFamily).toThemeData(),
  home: Scaffold(body: Center(child: child)),
);

Widget _appCurrent(Widget child, {bool scaffold = true}) => MaterialApp(
  theme: SeedThemeData.light(fontFamily: seedTestFontFamily).toThemeData(),
  home: scaffold ? Scaffold(body: Center(child: child)) : Center(child: child),
);

Widget host(Widget child) => MaterialApp(
  locale: const Locale('ko'),
  supportedLocales: const [Locale('en'), Locale('ko')],
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(body: Center(child: child)),
);

SeedSideNavigation navigation({String? selectedId, VoidCallback? onParent}) =>
    SeedSideNavigation(
      selectedId: selectedId,
      groups: [
        SeedSideNavGroup(
          items: [
            SeedSideNavItem(
              id: 'parent',
              label: 'Parent',
              onTap: onParent,
              subItems: const [SeedSideNavSubItem(id: 'child', label: 'Child')],
            ),
          ],
        ),
      ],
    );

void main() {
  group('items and flyout', () {
    setUpAll(loadSeedTestFonts);
    Widget nav({bool collapsed = false}) => SizedBox(
      height: 500,
      child: SeedSideNavigation(
        isCollapsed: collapsed,
        onCollapsedChanged: (_) {},
        groups: [
          SeedSideNavGroup(
            label: 'Group',
            items: [
              SeedSideNavItem(
                id: 'parent',
                label: 'Parent',
                icon: Icons.settings,
                subItems: [SeedSideNavSubItem(id: 'child', label: 'Child')],
              ),
            ],
          ),
        ],
      ),
    );

    testWidgets('sub items animate open and leave the tree when closed', (
      tester,
    ) async {
      await tester.pumpWidget(_app(nav()));
      expect(find.text('Child'), findsNothing);
      await tester.tap(find.text('Parent'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Child'), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_up), findsNothing);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Parent'));
      await tester.pumpAndSettle();
      expect(find.text('Child'), findsNothing);
    });

    testWidgets('a collapsed flyout shows its label without a tooltip', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          SizedBox(
            height: 500,
            child: SeedSideNavigation(
              isCollapsed: true,
              groups: [
                SeedSideNavGroup(
                  items: [
                    SeedSideNavItem(
                      id: 'parent',
                      label: 'Parent',
                      icon: Icons.settings,
                      subItems: [
                        SeedSideNavSubItem(id: 'child', label: 'Child'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      expect(find.byType(SeedHelpBubbleTooltip), findsNothing);
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      expect(find.text('Parent'), findsOneWidget);
      expect(find.text('Child'), findsOneWidget);
    });
  });

  group('current item state', () {
    setUpAll(loadSeedTestFonts);

    const groups = [
      SeedSideNavGroup(
        label: 'Group',
        items: [
          SeedSideNavItem(id: 'a', label: 'Alpha', icon: Icons.home),
          SeedSideNavItem(id: 'b', label: 'Beta', icon: Icons.star),
          SeedSideNavItem(
            id: 'long',
            label: 'A very very very very very very very long navigation label',
            icon: Icons.abc,
          ),
          SeedSideNavItem(
            id: 'p',
            label: 'Parent',
            icon: Icons.folder,
            subItems: [SeedSideNavSubItem(id: 'c', label: 'Child')],
          ),
        ],
      ),
    ];

    Finder selectedSurface(WidgetTester tester) {
      final colors = tester.element(find.byType(SeedSideNavigation)).seedColor;
      return find.byWidgetPredicate(
        (widget) =>
            widget is AnimatedContainer &&
            (widget.decoration as BoxDecoration?)?.color ==
                colors.bg.transparentSelected,
      );
    }

    testWidgets('collapsed SideNavigation shows the current item', (
      tester,
    ) async {
      await tester.pumpWidget(
        _appCurrent(
          const SizedBox(
            height: 700,
            child: SeedSideNavigation(
              groups: groups,
              selectedId: 'a',
              collapsed: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(selectedSurface(tester), findsOneWidget);
      final colors = tester.element(find.byType(SeedSideNavigation)).seedColor;
      expect(
        tester.widget<Icon>(find.byIcon(Icons.home)).color,
        colors.fg.neutral,
      );
      expect(
        tester.widget<Icon>(find.byIcon(Icons.star)).color,
        SeedPalette.gray600Light,
      );
    });

    testWidgets('collapsed parent is current when a child is selected', (
      tester,
    ) async {
      await tester.pumpWidget(
        _appCurrent(
          const SizedBox(
            height: 700,
            child: SeedSideNavigation(
              groups: groups,
              selectedId: 'c',
              collapsed: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(selectedSurface(tester), findsOneWidget);
    });

    testWidgets('SideNavigation rebuild keeps a user-closed parent closed', (
      tester,
    ) async {
      late StateSetter rebuild;
      var selected = 'c';
      await tester.pumpWidget(
        _appCurrent(
          StatefulBuilder(
            builder: (context, setState) {
              rebuild = setState;
              return SizedBox(
                height: 700,
                child: SeedSideNavigation(groups: groups, selectedId: selected),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Child'), findsOneWidget);
      await tester.tap(find.text('Parent'));
      await tester.pumpAndSettle();
      expect(find.text('Child'), findsNothing);
      rebuild(() {});
      await tester.pumpAndSettle();
      expect(find.text('Child'), findsNothing);
      // Selecting the child anew still reveals it.
      rebuild(() => selected = 'a');
      await tester.pumpAndSettle();
      rebuild(() => selected = 'c');
      await tester.pumpAndSettle();
      expect(find.text('Child'), findsOneWidget);
    });
  });
  group('expansion and visibility', () {
    testWidgets(
      'collapsed navigation exposes children to pointer and keyboard',
      (tester) async {
        var selected = false;
        await tester.pumpWidget(
          host(
            SeedSideNavigation(
              isCollapsed: true,
              groups: [
                SeedSideNavGroup(
                  items: [
                    SeedSideNavItem(
                      id: 'parent',
                      label: 'Parent',
                      icon: Icons.settings,
                      subItems: [
                        SeedSideNavSubItem(
                          id: 'child',
                          label: 'Child',
                          onTap: () => selected = true,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
        await tester.tap(find.byIcon(Icons.settings));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Child'));
        await tester.pumpAndSettle();
        expect(selected, isTrue);
        selected = false;
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(find.text('Child'), findsOneWidget);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(selected, isTrue);
      },
    );

    testWidgets('expanding a navigation parent does not navigate', (
      tester,
    ) async {
      var calls = 0;
      await tester.pumpWidget(host(navigation(onParent: () => calls++)));
      await tester.tap(find.text('Parent'));
      await tester.pumpAndSettle();
      expect(find.text('Child'), findsOneWidget);
      expect(calls, 0);
    });

    testWidgets(
      'active navigation child is visible initially and after update',
      (tester) async {
        await tester.pumpWidget(host(navigation(selectedId: 'child')));
        expect(find.text('Child'), findsOneWidget);
        await tester.pumpWidget(host(navigation()));
        await tester.tap(find.text('Parent'));
        await tester.pumpAndSettle();
        expect(find.text('Child'), findsNothing);
        await tester.pumpWidget(host(navigation(selectedId: 'child')));
        expect(find.text('Child'), findsOneWidget);
      },
    );
  });
}
