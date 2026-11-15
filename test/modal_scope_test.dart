import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

void main() {
  group('modal presentation scope', () {
    Widget host(Widget child, {double width = 320}) => MaterialApp(
      theme: SeedThemeData.light().toThemeData(),
      home: Scaffold(
        body: Center(
          child: SizedBox(width: width, child: child),
        ),
      ),
    );

    group('useResponsiveDialogContext and useResponsiveSidePanelContext', () {
      Future<void> open(
        WidgetTester tester, {
        required double width,
        required Widget Function(WidgetBuilder content) trigger,
      }) async {
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          MaterialApp(
            theme: SeedThemeData.light().toThemeData(),
            home: Scaffold(
              body: trigger(
                (context) => Text(
                  SeedModalScope.of(context).shouldUseBottomSheet
                      ? 'as sheet'
                      : 'as requested',
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
      }

      Widget button(BuildContext context, bool open, VoidCallback toggle) =>
          TextButton(onPressed: toggle, child: const Text('open'));

      testWidgets('a responsive dialog reports a bottom sheet when narrow', (
        tester,
      ) async {
        Widget trigger(WidgetBuilder content) => SeedDialogTrigger(
          triggerBuilder: button,
          // The builder's own context reads the scope as well.
          builder: (context) => SeedDialog(
            title: SeedModalScope.of(context).type.name,
            content: Builder(builder: content),
          ),
        );
        await open(tester, width: 390, trigger: trigger);
        expect(find.text('as sheet'), findsOneWidget);
        expect(find.text('bottomSheet'), findsOneWidget);
      });

      testWidgets('a responsive dialog reports a dialog when wide', (
        tester,
      ) async {
        await open(
          tester,
          width: 1024,
          trigger: (content) => SeedDialogTrigger(
            triggerBuilder: button,
            builder: (context) => SeedDialog(
              title: SeedModalScope.of(context).type.name,
              content: Builder(builder: content),
            ),
          ),
        );
        expect(find.text('as requested'), findsOneWidget);
        expect(find.text('dialog'), findsOneWidget);
      });

      testWidgets(
        'a responsive side panel reports a bottom sheet when narrow',
        (tester) async {
          await open(
            tester,
            width: 390,
            trigger: (content) => SeedSidePanelTrigger(
              triggerBuilder: button,
              builder: (context) => SeedSidePanel(
                title: 'Panel',
                body: Builder(builder: content),
              ),
            ),
          );
          expect(find.text('as sheet'), findsOneWidget);
        },
      );

      testWidgets('a plain bottom sheet is not a responsive fallback', (
        tester,
      ) async {
        await open(
          tester,
          width: 390,
          trigger: (content) => SeedBottomSheetTrigger(
            triggerBuilder: button,
            builder: (context) => SeedBottomSheet(
              title: 'Sheet',
              content: Builder(builder: content),
            ),
          ),
        );
        expect(find.text('as requested'), findsOneWidget);
      });

      testWidgets('there is no scope outside modal content', (tester) async {
        await tester.pumpWidget(
          host(
            Builder(
              builder: (context) =>
                  Text('${SeedModalScope.maybeOf(context) == null}'),
            ),
          ),
        );
        expect(find.text('true'), findsOneWidget);
      });
    });
  });
}
