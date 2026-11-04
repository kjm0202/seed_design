import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

Widget _label(SeedLabel label) => Builder(
  builder: (context) => Text(SeedLocalizations.label(context, label)),
);

void main() {
  for (final locale in [const Locale('en'), const Locale('ko')]) {
    testWidgets('SEED fallback copy follows $locale', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: locale,
          supportedLocales: const [Locale('en'), Locale('ko')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: Scaffold(body: _label(SeedLabel.requiredInput)),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text(locale.languageCode == 'ko' ? '필수 입력' : 'Required'),
        findsOneWidget,
      );
    });
  }

  testWidgets('scoped labels remain captured by a dialog route', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SeedLocalizations(
          labels: const {SeedLabel.requiredInput: 'Application required label'},
          child: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => Dialog(child: _label(SeedLabel.requiredInput)),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Application required label'), findsOneWidget);
  });
}
