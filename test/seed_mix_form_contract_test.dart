import 'package:flutter/semantics.dart' show SemanticsAction;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

Widget _host(Widget child) => MaterialApp(
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(
    body: Center(child: SizedBox(width: 340, child: child)),
  ),
);

void main() {
  testWidgets(
    'Attachment explicitly exposes required and independent invalid state',
    (tester) async {
      await tester.pumpWidget(
        _host(
          const SeedAttachmentDisplayField(
            label: 'Photos',
            showRequiredIndicator: true,
            invalid: true,
            description: 'Select photos',
          ),
        ),
      );

      final field = tester.widget<SeedField>(find.byType(SeedField));
      expect(field.required, isTrue);
      expect(field.isInvalid, isTrue);
      expect(field.errorMessage, isNull);
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Semantics && widget.properties.label == '필수 입력',
        ),
        findsOneWidget,
      );

      await tester.pumpWidget(
        _host(
          const SeedAttachmentDisplayField(
            label: 'Photos',
            invalid: false,
            errorMessage: 'Upload failed',
          ),
        ),
      );
      expect(tester.widget<SeedField>(find.byType(SeedField)).isInvalid, false);
      expect(find.text('Upload failed'), findsNothing);

      await tester.pumpWidget(
        _host(
          const SeedAttachmentDisplayField(
            label: 'Photos',
            errorMessage: 'Upload failed',
          ),
        ),
      );
      expect(tester.widget<SeedField>(find.byType(SeedField)).isInvalid, true);
      expect(find.text('Upload failed'), findsOneWidget);
    },
  );

  testWidgets(
    'ChipTabs respects explicit strip padding and keeps 16px default',
    (tester) async {
      Widget tabs({
        EdgeInsetsGeometry? padding,
        SeedTabsVariant variant = SeedTabsVariant.chipSolid,
        bool showScrollFog = false,
      }) => SeedTabs(
        items: const [
          SeedTabItem(label: 'One'),
          SeedTabItem(label: 'Two'),
        ],
        selectedIndex: 0,
        onTabSelected: (_) {},
        variant: variant,
        showScrollFog: showScrollFog,
        chipListPadding: padding,
      );
      await tester.pumpWidget(_host(tabs()));
      expect(
        tester
            .widget<SingleChildScrollView>(find.byType(SingleChildScrollView))
            .padding,
        const EdgeInsets.symmetric(horizontal: 16),
      );
      await tester.pumpWidget(
        _host(tabs(padding: const EdgeInsets.symmetric(horizontal: 20))),
      );
      expect(
        tester
            .widget<SingleChildScrollView>(find.byType(SingleChildScrollView))
            .padding,
        const EdgeInsets.symmetric(horizontal: 20),
      );
      await tester.pumpWidget(
        _host(
          tabs(
            variant: SeedTabsVariant.chipOutline,
            showScrollFog: true,
            padding: const EdgeInsetsDirectional.only(start: 24, end: 12),
          ),
        ),
      );
      expect(
        tester
            .widget<SingleChildScrollView>(find.byType(SingleChildScrollView))
            .padding,
        const EdgeInsetsDirectional.only(start: 24, end: 12),
      );
    },
  );

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
}
