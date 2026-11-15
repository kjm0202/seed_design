import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_host.dart';

void main() {
  group('dismissal', () {
    testWidgets('callout can dismiss without requiring an observer', (
      tester,
    ) async {
      await tester.pumpWidget(
        seedAppTopLeft(
          const SeedCallout(description: 'Message', showCloseButton: true),
        ),
      );
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.close_rounded), findsNothing);
    });
  });
}
