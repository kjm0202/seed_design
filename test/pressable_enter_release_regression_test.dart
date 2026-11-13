import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

void main() {
  testWidgets('Enter release clears the press after Enter activation changes', (
    tester,
  ) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    var activateOnEnter = true;
    late StateSetter update;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return SeedPressable(
              focusNode: focusNode,
              activateOnEnter: activateOnEnter,
              onTap: () {},
              builder: (context, pressed) => Text(pressed ? 'pressed' : 'idle'),
            );
          },
        ),
      ),
    );
    focusNode.requestFocus();
    await tester.pump();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(find.text('pressed'), findsOneWidget);

    update(() => activateOnEnter = false);
    await tester.pump();
    await tester.sendKeyUpEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(find.text('idle'), findsOneWidget);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(find.text('pressed'), findsOneWidget);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(find.text('idle'), findsOneWidget);
  });
}
