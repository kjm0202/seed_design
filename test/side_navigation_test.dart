import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';
import 'support/seed_test_host.dart';

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

SeedSideNavigation navigationWithItem(bool present) => SeedSideNavigation(
  groups: [
    SeedSideNavGroup(
      items: present
          ? const [
              SeedSideNavItem(
                id: 'parent',
                label: 'Parent',
                subItems: [SeedSideNavSubItem(id: 'child', label: 'Child')],
              ),
            ]
          : const [],
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
      await tester.pumpWidget(fontApp(nav()));
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
        fontApp(
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

    testWidgets('collapsed flyout waits until the width transition ends', (
      tester,
    ) async {
      await tester.pumpWidget(fontApp(nav()));
      await tester.pumpWidget(fontApp(nav(collapsed: true)));
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pump(const Duration(milliseconds: 90));
      expect(find.byType(SeedNavigationMenuTrigger), findsNothing);
      expect(find.text('Child'), findsNothing);

      await tester.pumpAndSettle();
      expect(find.text('Child'), findsNothing);
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      expect(find.text('Child'), findsOneWidget);
    });

    testWidgets('reduced motion makes the collapsed flyout available at once', (
      tester,
    ) async {
      Widget koreanAppCentered(bool collapsed) => fontApp(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: nav(collapsed: collapsed),
        ),
      );

      await tester.pumpWidget(koreanAppCentered(false));
      await tester.pumpWidget(koreanAppCentered(true));
      expect(find.byType(SeedNavigationMenuTrigger), findsOneWidget);
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      expect(find.text('Child'), findsOneWidget);
    });

    testWidgets('hover starts the flyout delay after collapse settles', (
      tester,
    ) async {
      Widget koreanAppCentered(bool collapsed) => fontApp(
        Align(
          alignment: Alignment.centerLeft,
          child: nav(collapsed: collapsed),
        ),
      );

      await tester.pumpWidget(koreanAppCentered(false));
      await tester.pumpWidget(koreanAppCentered(true));
      await tester.pump(const Duration(milliseconds: 100));
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(
        location: tester.getCenter(find.byIcon(Icons.settings)),
      );
      addTearDown(mouse.removePointer);

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 190));
      expect(find.text('Child'), findsNothing);
      await tester.pump(const Duration(milliseconds: 20));
      await tester.pumpAndSettle();
      expect(find.text('Child'), findsOneWidget);
    });

    // Regression: the collapsed flyout could be hovered open only once; on
    // later hovers it closed one frame after opening. 16ms frames expose it.
    testWidgets('collapsed flyout reopens on every hover', (tester) async {
      Future<void> frames(int ms) async {
        for (var i = 0; i < ms ~/ 16; i++) {
          await tester.pump(const Duration(milliseconds: 16));
        }
      }

      await tester.pumpWidget(
        fontApp(
          Align(alignment: Alignment.centerLeft, child: nav(collapsed: true)),
        ),
      );
      await tester.pumpAndSettle();
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: const Offset(700, 580));
      addTearDown(mouse.removePointer);
      for (var round = 1; round <= 3; round++) {
        await mouse.moveTo(tester.getCenter(find.byIcon(Icons.settings)));
        await frames(300);
        expect(find.text('Child'), findsOneWidget, reason: 'round $round');
        await frames(1000);
        expect(find.text('Child'), findsOneWidget, reason: 'round $round');
        await mouse.moveTo(const Offset(700, 580));
        await frames(800);
        expect(find.text('Child'), findsNothing, reason: 'round $round');
      }
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
        fontApp(
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
        fontApp(
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
        fontApp(
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
    testWidgets('a removed and reintroduced item starts from its default', (
      tester,
    ) async {
      late StateSetter rebuild;
      var present = true;
      await tester.pumpWidget(
        koreanAppCentered(
          StatefulBuilder(
            builder: (context, setState) {
              rebuild = setState;
              return navigationWithItem(present);
            },
          ),
        ),
      );
      await tester.tap(find.text('Parent'));
      await tester.pumpAndSettle();
      expect(find.text('Child'), findsOneWidget);
      rebuild(() => present = false);
      await tester.pumpAndSettle();
      rebuild(() => present = true);
      await tester.pumpAndSettle();
      expect(find.text('Child'), findsNothing);
    });

    testWidgets(
      'collapsed navigation exposes children to pointer and keyboard',
      (tester) async {
        var selected = false;
        await tester.pumpWidget(
          koreanAppCentered(
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
      await tester.pumpWidget(
        koreanAppCentered(navigation(onParent: () => calls++)),
      );
      await tester.tap(find.text('Parent'));
      await tester.pumpAndSettle();
      expect(find.text('Child'), findsOneWidget);
      expect(calls, 0);
    });

    testWidgets(
      'active navigation child is visible initially and after update',
      (tester) async {
        await tester.pumpWidget(
          koreanAppCentered(navigation(selectedId: 'child')),
        );
        expect(find.text('Child'), findsOneWidget);
        await tester.pumpWidget(koreanAppCentered(navigation()));
        await tester.tap(find.text('Parent'));
        await tester.pumpAndSettle();
        expect(find.text('Child'), findsNothing);
        await tester.pumpWidget(
          koreanAppCentered(navigation(selectedId: 'child')),
        );
        expect(find.text('Child'), findsOneWidget);
      },
    );
  });

  group('default-open items and collapsed submenu', () {
    Widget host(Widget child) => MaterialApp(
      theme: SeedThemeData.light().toThemeData(),
      home: Scaffold(body: SizedBox(height: 500, child: child)),
    );
    testWidgets(
      'new default-open item opens and existing manual state survives',
      (tester) async {
        late StateSetter update;
        var added = false;
        await tester.pumpWidget(
          host(
            StatefulBuilder(
              builder: (context, setState) {
                update = setState;
                return SeedSideNavigation(
                  groups: [
                    SeedSideNavGroup(
                      items: [
                        const SeedSideNavItem(
                          id: 'existing',
                          label: 'Existing',
                          defaultOpen: true,
                          subItems: [
                            SeedSideNavSubItem(id: 'old', label: 'Old child'),
                          ],
                        ),
                        if (added)
                          const SeedSideNavItem(
                            id: 'new',
                            label: 'New',
                            defaultOpen: true,
                            subItems: [
                              SeedSideNavSubItem(
                                id: 'new-child',
                                label: 'New child',
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        );
        expect(find.text('Old child'), findsOneWidget);
        await tester.tap(find.text('Existing'));
        await tester.pumpAndSettle();
        expect(find.text('Old child'), findsNothing);
        update(() => added = true);
        await tester.pumpAndSettle();
        expect(find.text('New child'), findsOneWidget);
        expect(find.text('Old child'), findsNothing);
      },
    );

    testWidgets('collapsed submenu retains enabled status and badge', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        host(
          const SeedSideNavigation(
            collapsed: true,
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
                        badge: 'New',
                      ),
                      SeedSideNavSubItem(
                        id: 'disabled',
                        label: 'Disabled',
                        disabled: true,
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
      // The flyout is a SeedNavigationMenu disclosure; check the public
      // semantics instead of its internal widgets.
      expect(
        tester.getSemantics(find.text('Child')),
        isSemantics(isEnabled: true, hasEnabledState: true),
      );
      expect(
        tester.getSemantics(find.text('Disabled')),
        isSemantics(isEnabled: false, hasEnabledState: true),
      );
      expect(find.text('New'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('New')), findsWidgets);
      semantics.dispose();
    });
  });

  group('provider, inset and context', () {
    group('SideNavigation.Provider, Inset and context', () {
      const groups = [
        SeedSideNavGroup(
          items: [SeedSideNavItem(id: 'home', label: 'Home', icon: Icons.home)],
        ),
      ];

      Widget app(Widget child) => MaterialApp(
        theme: SeedThemeData.light().toThemeData(),
        home: Scaffold(body: child),
      );

      testWidgets('a control in the inset toggles the navigation', (
        tester,
      ) async {
        final changes = <bool>[];
        await tester.pumpWidget(
          app(
            SeedSideNavigationProvider(
              onCollapsedChange: changes.add,
              child: Row(
                children: [
                  const SeedSideNavigation(groups: groups),
                  SeedSideNavigationInset(
                    child: Builder(
                      builder: (context) {
                        final nav = SeedSideNavigationProvider.of(context);
                        return TextButton(
                          onPressed: nav.toggle,
                          child: Text(nav.collapsed ? 'expand' : 'collapse'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        expect(tester.getSize(find.byType(SeedSideNavigation)).width, 240);
        // The inset takes the rest of the row.
        expect(
          tester.getSize(find.byType(SeedSideNavigationInset)).width,
          800 - 240,
        );

        await tester.tap(find.text('collapse'));
        await tester.pumpAndSettle();
        expect(changes, [true]);
        expect(find.text('expand'), findsOneWidget);
        expect(tester.getSize(find.byType(SeedSideNavigation)).width, 56);

        await tester.tap(find.text('expand'));
        await tester.pumpAndSettle();
        expect(changes, [true, false]);
        expect(tester.getSize(find.byType(SeedSideNavigation)).width, 240);
      });

      testWidgets('a controlled provider only reports the request', (
        tester,
      ) async {
        final changes = <bool>[];
        late SeedSideNavigationContextValue nav;
        await tester.pumpWidget(
          app(
            SeedSideNavigationProvider(
              collapsed: false,
              onCollapsedChange: changes.add,
              child: Row(
                children: [
                  const SeedSideNavigation(groups: groups),
                  Builder(
                    builder: (context) {
                      nav = SeedSideNavigationProvider.of(context);
                      return const SizedBox();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
        nav.setCollapsed(true);
        await tester.pumpAndSettle();
        expect(changes, [true]);
        expect(nav.collapsed, isFalse);
        expect(tester.getSize(find.byType(SeedSideNavigation)).width, 240);
      });

      testWidgets("the navigation's own collapsed wins over the provider", (
        tester,
      ) async {
        await tester.pumpWidget(
          app(
            const SeedSideNavigationProvider(
              defaultCollapsed: false,
              child: Row(
                children: [SeedSideNavigation(groups: groups, collapsed: true)],
              ),
            ),
          ),
        );
        expect(tester.getSize(find.byType(SeedSideNavigation)).width, 56);
      });

      testWidgets('the header reads the state without a provider', (
        tester,
      ) async {
        await tester.pumpWidget(
          app(
            Row(
              children: [
                SeedSideNavigation(
                  groups: groups,
                  showCollapseButton: true,
                  footer: Builder(
                    builder: (context) => Text(
                      SeedSideNavigationProvider.of(context).collapsed
                          ? 'footer:collapsed'
                          : 'footer:expanded',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        expect(find.text('footer:expanded'), findsOneWidget);
        expect(
          SeedSideNavigationProvider.maybeOf(
            tester.element(find.byType(SeedSideNavigation)),
          ),
          isNull,
        );
      });

      testWidgets('the inset scrolls tall content by default', (tester) async {
        await tester.pumpWidget(
          app(
            const Row(
              children: [
                SeedSideNavigation(groups: groups),
                SeedSideNavigationInset(child: SizedBox(height: 2000)),
              ],
            ),
          ),
        );
        expect(tester.takeException(), isNull);
        expect(
          find.descendant(
            of: find.byType(SeedSideNavigationInset),
            matching: find.byType(SingleChildScrollView),
          ),
          findsOneWidget,
        );

        await tester.pumpWidget(
          app(
            Row(
              children: [
                const SeedSideNavigation(groups: groups),
                SeedSideNavigationInset(
                  scrollable: false,
                  child: ListView(children: const [SizedBox(height: 2000)]),
                ),
              ],
            ),
          ),
        );
        expect(tester.takeException(), isNull);
        expect(
          tester
              .getSize(
                find.descendant(
                  of: find.byType(SeedSideNavigationInset),
                  matching: find.byType(ListView),
                ),
              )
              .height,
          600,
        );
      });
    });
  });
}
