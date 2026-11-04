import 'package:flutter/semantics.dart' show SemanticsAction;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

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

Widget _host(Widget child) => MaterialApp(
  supportedLocales: const [Locale('en'), Locale('ko')],
  locale: const Locale('ko'),
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(
    body: Center(child: SizedBox(width: 340, child: child)),
  ),
);

void main() {
  group('dividers', () {
    testWidgets('list can suppress dividers through wrapped children', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const SeedList(
            showDividers: false,
            children: [
              SeedListItem(titleText: 'One'),
              Padding(
                padding: EdgeInsets.zero,
                child: SeedListItem(titleText: 'Two'),
              ),
            ],
          ),
        ),
      );
      expect(find.byType(SeedDivider), findsNothing);
      await tester.pumpWidget(
        host(const SeedListItem(titleText: 'Standalone')),
      );
      expect(find.byType(SeedDivider), findsNothing);
      await tester.pumpWidget(
        host(const SeedListItem(titleText: 'Explicit', showDivider: true)),
      );
      expect(find.byType(SeedDivider), findsOneWidget);
    });
  });

  group('link row', () {
    testWidgets(
      'Link row exposes URI/link role and dispatches navigation callback',
      (tester) async {
        final uri = Uri.parse('https://example.com/guide');
        var activated = 0;
        final semantics = tester.ensureSemantics();
        await tester.pumpWidget(
          _host(
            SeedList(
              children: [
                SeedListLinkItem(
                  titleText: 'Guide',
                  uri: uri,
                  onTap: () => activated++,
                ),
              ],
            ),
          ),
        );
        final linkSemantics = find.byWidgetPredicate(
          (widget) => widget is Semantics && widget.properties.linkUrl == uri,
        );
        expect(linkSemantics, findsOneWidget);
        final node = tester.getSemantics(linkSemantics);
        expect(node.getSemanticsData().linkUrl, uri);
        expect(node.flagsCollection.isLink, true);
        expect(node.flagsCollection.isButton, false);
        expect(node.getSemanticsData().hasAction(SemanticsAction.tap), true);
        tester.binding.renderViews.first.owner!.semanticsOwner!.performAction(
          node.id,
          SemanticsAction.tap,
        );
        await tester.pump();
        expect(activated, 1);
        await tester.tap(find.text('Guide'));
        await tester.pump();
        expect(activated, 2);
        await tester.pumpWidget(
          _host(
            SeedListLinkItem(
              titleText: 'Disabled guide',
              uri: uri,
              enabled: false,
              onTap: () => activated++,
            ),
          ),
        );
        await tester.tap(find.text('Disabled guide'));
        await tester.pump();
        expect(activated, 2);
        semantics.dispose();
      },
    );
  });
}
