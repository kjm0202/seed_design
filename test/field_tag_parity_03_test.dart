import 'dart:ui' show SemanticsAction;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

Widget host(Widget child) => MaterialApp(
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(
    body: Center(child: SizedBox(width: 350, child: child)),
  ),
);

void main() {
  testWidgets('field associates both description and error with input', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      host(
        const SeedTextField(
          label: 'Name',
          description: 'Use a full name',
          errorMessage: 'Name is invalid',
        ),
      ),
    );
    final nodes = tester.semantics.simulatedAccessibilityTraversal();
    expect(
      nodes.any(
        (n) =>
            n.getSemanticsData().flagsCollection.isTextField &&
            n.hint.contains('Use a full name') &&
            n.hint.contains('Name is invalid'),
      ),
      isTrue,
    );
    expect(find.text('Name is invalid'), findsOneWidget);
    expect(find.text('Use a full name'), findsNothing);
    semantics.dispose();
  });

  for (final textarea in [false, true]) {
    testWidgets(
      'count and required marker are independent, textarea=$textarea',
      (tester) async {
        final formKey = GlobalKey<FormState>();
        final controller = TextEditingController(text: 'abc');
        addTearDown(controller.dispose);
        final field = textarea
            ? SeedTextField.textarea(
                controller: controller,
                label: 'Name',
                required: true,
                showRequiredIndicator: false,
                maxGraphemeCount: 2,
                hideCharacterCount: true,
              )
            : SeedTextField(
                controller: controller,
                label: 'Name',
                required: true,
                showRequiredIndicator: false,
                maxGraphemeCount: 2,
                hideCharacterCount: true,
              );
        await tester.pumpWidget(host(Form(key: formKey, child: field)));
        final fieldWidget = tester.widget<SeedField>(find.byType(SeedField));
        expect(fieldWidget.required, isTrue);
        expect(find.text('*'), findsNothing);
        expect(fieldWidget.characterCount, isNull);
        expect(fieldWidget.maxCharacterCount, isNull);
        expect(formKey.currentState!.validate(), isFalse);
        expect(controller.text, 'abc');
      },
    );
  }

  testWidgets('tag suffix remains an independently accessible action', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    var presses = 0;
    await tester.pumpWidget(
      host(
        SeedTagGroup(
          items: [
            SeedTagItem(
              label: 'Location',
              semanticsLabel: 'Place',
              suffix: IconButton(
                onPressed: () => presses++,
                tooltip: 'Edit place',
                icon: const Icon(Icons.edit),
              ),
            ),
          ],
        ),
      ),
    );
    final nodes = tester.semantics.simulatedAccessibilityTraversal();
    expect(nodes.any((n) => n.label.contains('Place')), isTrue);
    final action = nodes.singleWhere(
      (n) => n.getSemanticsData().tooltip.contains('Edit place'),
    );
    expect(action.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
    tester.binding.renderViews.single.owner!.semanticsOwner!.performAction(
      action.id,
      SemanticsAction.tap,
    );
    await tester.pump();
    expect(presses, 1);
    semantics.dispose();
  });

  testWidgets('custom tag label retains an embedded action', (tester) async {
    final semantics = tester.ensureSemantics();
    var presses = 0;
    await tester.pumpWidget(
      host(
        SeedTagGroup(
          items: [
            SeedTagItem(
              label: 'Location',
              semanticsLabel: 'Place',
              labelWidget: TextButton(
                onPressed: () => presses++,
                child: const Text('Change place'),
              ),
            ),
          ],
        ),
      ),
    );
    final nodes = tester.semantics.simulatedAccessibilityTraversal();
    expect(nodes.any((n) => n.label.contains('Place')), isTrue);
    final action = nodes.singleWhere(
      (n) =>
          n.label.contains('Change place') &&
          n.getSemanticsData().hasAction(SemanticsAction.tap),
    );
    tester.binding.renderViews.single.owner!.semanticsOwner!.performAction(
      action.id,
      SemanticsAction.tap,
    );
    await tester.pump();
    expect(presses, 1);
    semantics.dispose();
  });

  testWidgets('field button chip deletion is independently accessible', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    var opens = 0;
    await tester.pumpWidget(
      host(
        SeedFieldButton(
          label: 'Fruits',
          defaultValues: const ['Apple'],
          onPressed: () => opens++,
        ),
      ),
    );
    final nodes = tester.semantics.simulatedAccessibilityTraversal();
    final action = nodes.singleWhere(
      (n) =>
          n.label.contains('Apple') &&
          n.getSemanticsData().hasAction(SemanticsAction.tap) &&
          n.label.toLowerCase().contains('delete'),
    );
    tester.binding.renderViews.single.owner!.semanticsOwner!.performAction(
      action.id,
      SemanticsAction.tap,
    );
    await tester.pumpAndSettle();
    expect(find.text('Apple'), findsNothing);
    expect(opens, 0);
    semantics.dispose();
  });
}
