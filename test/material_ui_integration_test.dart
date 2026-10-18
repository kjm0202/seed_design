import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('bottom sheet supports ListTile in $brightness mode', (
      tester,
    ) async {
      final seedTheme = brightness == Brightness.light
          ? SeedThemeData.light()
          : SeedThemeData.dark();
      String? selection;
      await tester.pumpWidget(
        MaterialApp(
          theme: seedTheme.toThemeData(),
          home: Scaffold(
            body: Builder(
              builder: (context) => SeedButton(
                label: 'Open sheet',
                onPressed: () async {
                  selection = await showSeedBottomSheet<String>(
                    context: context,
                    child: SeedBottomSheet(
                      title: 'Sort',
                      content: Builder(
                        builder: (sheetContext) => ListTile(
                          selected: true,
                          selectedTileColor: seedTheme.colorScheme.bg.brandWeak,
                          title: const Text('Latest'),
                          onTap: () => Navigator.of(sheetContext).pop('latest'),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open sheet'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Sort'), findsOneWidget);

      await tester.tap(find.text('Latest'));
      await tester.pumpAndSettle();
      expect(selection, 'latest');
      expect(find.text('Sort'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'material_ui Korean localizations support Seed inputs and dialogs',
    (tester) async {
      bool? confirmed;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ko'),
          supportedLocales: const [Locale('en'), Locale('ko')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          theme: SeedThemeData.light().toThemeData(),
          home: Builder(
            builder: (context) {
              expect(MaterialLocalizations.of(context).okButtonLabel, '확인');
              expect(
                context.seedColor.fg.brand,
                Theme.of(context).colorScheme.primary,
              );
              return Scaffold(
                body: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SeedTextInput(hintText: '이름'),
                    SeedButton(
                      label: '다이얼로그 열기',
                      onPressed: () async {
                        confirmed = await showSeedAlertDialog(
                          context: context,
                          title: '변경 확인',
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '동네 이웃');
      expect(find.text('동네 이웃'), findsOneWidget);
      await tester.tap(find.text('다이얼로그 열기'));
      await tester.pumpAndSettle();
      expect(find.text('변경 확인'), findsOneWidget);
      await tester.tap(find.text('확인'));
      await tester.pumpAndSettle();
      expect(confirmed, isTrue);
      expect(tester.takeException(), isNull);
    },
  );
}
