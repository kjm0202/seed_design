import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:seed_design_example/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('default app opens an activity and returns home', (tester) async {
    app.main();
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);

    await tester.tap(find.text('App Bar 슬롯과 긴 제목'));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsNothing);
    expect(
      find.text(
        'Random Long Title Hello World Commodo occaecat laboris voluptate aute magna.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('‹  Back'));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    expect(Navigator.of(tester.element(find.text('Home'))).canPop(), isFalse);
    expect(tester.takeException(), isNull);
  });
}
