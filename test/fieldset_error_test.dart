import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

// React Fieldset.ErrorMessage: a group-level error in the footer.

Widget host(Widget child) => MaterialApp(
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(body: Center(child: SizedBox(width: 320, child: child))),
);

void main() {
  testWidgets('group error replaces the description and is a live region', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    Widget build(String? error) => host(
      SeedFieldset(
        label: 'Contact',
        description: 'Pick at least one',
        errorMessage: error,
        child: const SeedCheckbox(label: 'Email'),
      ),
    );
    await tester.pumpWidget(build(null));
    expect(find.text('Pick at least one'), findsOneWidget);
    expect(find.byIcon(Icons.error), findsNothing);

    await tester.pumpWidget(build('Choose a contact method'));
    expect(find.text('Pick at least one'), findsNothing);
    final error = find.text('Choose a contact method');
    expect(error, findsOneWidget);
    expect(find.byIcon(Icons.error), findsOneWidget);
    final colors = SeedThemeData.light().colorScheme;
    expect(tester.widget<Text>(error).style!.color, colors.fg.critical);
    expect(tester.getSemantics(error), isSemantics(isLiveRegion: true));

    // The error sits below the control, inside the group.
    expect(
      tester.getTopLeft(error).dy,
      greaterThan(tester.getBottomLeft(find.text('Email')).dy),
    );
    semantics.dispose();
  });

  testWidgets('group error keeps disabled inheritance and control errors', (
    tester,
  ) async {
    var changes = 0;
    await tester.pumpWidget(
      host(
        SeedFieldset(
          label: 'Profile',
          enabled: false,
          errorMessage: 'Group error',
          errorIcon: const Icon(Icons.warning),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SeedCheckbox(label: 'Agree', onCheckedChange: (_) => changes++),
              const SeedTextField(label: 'Name', errorMessage: 'Name error'),
            ],
          ),
        ),
      ),
    );
    expect(find.text('Group error'), findsOneWidget);
    expect(find.text('Name error'), findsOneWidget);
    expect(find.byIcon(Icons.warning), findsOneWidget);
    await tester.tap(find.text('Agree'));
    await tester.pump();
    expect(changes, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('long group error wraps at large text scale without overflow', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: SeedThemeData.light().toThemeData(),
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Scaffold(
            body: Directionality(
              textDirection: TextDirection.rtl,
              child: SizedBox(
                width: 240,
                child: SeedFieldset(
                  label: 'Group',
                  errorMessage: 'A long group error message ' * 3,
                  child: const SizedBox(height: 20),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
