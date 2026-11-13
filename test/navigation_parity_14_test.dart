import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

Widget host(Widget child) => MaterialApp(
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(body: SizedBox(height: 500, child: child)),
);

void main() {
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
    final child = tester.widget<MenuItemButton>(
      find.ancestor(
        of: find.text('Child'),
        matching: find.byType(MenuItemButton),
      ),
    );
    final disabled = tester.widget<MenuItemButton>(
      find.ancestor(
        of: find.text('Disabled'),
        matching: find.byType(MenuItemButton),
      ),
    );
    expect(child.onPressed, isNotNull);
    expect(disabled.onPressed, isNull);
    expect(find.text('New'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('New')), findsWidgets);
    semantics.dispose();
  });
}
