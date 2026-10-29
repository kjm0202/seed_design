import 'package:flutter_test/flutter_test.dart';
import 'package:seed_design_example/main.dart' as app;
import 'package:seed_design_example/stackflow_spa/stackflow_spa.dart';

void main() {
  testWidgets('default entrypoint launches the Stackflow SPA', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    expect(find.byType(StackflowSpaApp), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('App Bar 슬롯과 긴 제목'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
