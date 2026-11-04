import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

Widget host(Widget child) => MaterialApp(
  supportedLocales: const [Locale('en'), Locale('ko')],
  locale: const Locale('ko'),
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(body: child),
);

void main() {
  testWidgets('readonly select box does not change and group fits columns', (
    tester,
  ) async {
    var changes = 0;
    await tester.pumpWidget(
      host(
        SizedBox(
          width: 320,
          child: SeedSelectBoxGroup(
            columns: 2,
            children: [
              SeedSelectBox(
                title: 'One',
                readOnly: true,
                onSelected: (_) => changes++,
              ),
              const SeedSelectBox(
                title: 'Two',
                selected: true,
                footer: Text('Extra'),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.text('One'));
    await tester.pumpAndSettle();
    expect(changes, 0);
    expect(tester.takeException(), isNull);
  });
}
