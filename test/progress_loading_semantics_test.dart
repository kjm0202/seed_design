import 'dart:ui' show SemanticsRole;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

void main() {
  for (final width in [390.0, 800.0]) {
    testWidgets(
      'indeterminate progress exposes loading text without a false percentage $width',
      (tester) async {
        tester.view.physicalSize = Size(width, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final semantics = tester.ensureSemantics();
        Future<void> show(SeedProgressCircle indicator) async {
          await tester.pumpWidget(MaterialApp(home: Scaffold(body: indicator)));
          await tester.pump();
        }

        try {
          await show(const SeedProgressCircle());
          var data = tester
              .getSemantics(
                find
                    .descendant(
                      of: find.byType(SeedProgressCircle),
                      matching: find.byType(Semantics),
                    )
                    .first,
              )
              .getSemanticsData();
          expect(data.role, SemanticsRole.loadingSpinner);
          expect(data.value, 'loading...');
          expect(data.minValue, isNull);
          expect(data.maxValue, isNull);
          await show(
            const SeedProgressCircle(
              semanticsLabel: '동기화',
              semanticsValue: '불러오는 중',
            ),
          );
          data = tester
              .getSemantics(
                find
                    .descendant(
                      of: find.byType(SeedProgressCircle),
                      matching: find.byType(Semantics),
                    )
                    .first,
              )
              .getSemanticsData();
          expect(data.label, '동기화');
          expect(data.value, '불러오는 중');
          await show(const SeedProgressCircle(value: 0.75));
          data = tester
              .getSemantics(
                find
                    .descendant(
                      of: find.byType(SeedProgressCircle),
                      matching: find.byType(Semantics),
                    )
                    .first,
              )
              .getSemanticsData();
          expect(data.role, SemanticsRole.progressBar);
          expect(data.value, '75');
          expect(data.minValue, '0');
          expect(data.maxValue, '100');
          await tester.pumpWidget(const SizedBox.shrink());
        } finally {
          semantics.dispose();
        }
      },
    );
  }
}
