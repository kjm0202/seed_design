import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

void main() {
  for (final dark in [false, true]) {
    for (final variant in SeedSnackbarVariant.values) {
      testWidgets('provider snackbar text dark=$dark variant=${variant.name}', (
        tester,
      ) async {
        final controller = SeedSnackbarController();
        addTearDown(controller.dispose);
        final seedTheme = dark ? SeedThemeData.dark() : SeedThemeData.light();
        await tester.pumpWidget(
          MaterialApp(
            theme: seedTheme.toThemeData(),
            // Match app-root placement, outside the page's Material surface.
            home: SeedSnackbarProvider(
              controller: controller,
              child: const Scaffold(body: SizedBox.shrink()),
            ),
          ),
        );
        var actions = 0;
        controller.show(
          child: SeedSnackbar(
            message: '키워드 알림이 설정되었습니다.',
            actionLabel: '설정확인',
            onAction: () => actions++,
            variant: variant,
          ),
        );
        await tester.pumpAndSettle();

        for (final (label, color) in [
          ('키워드 알림이 설정되었습니다.', seedTheme.colorScheme.fg.onNeutralSolid),
          ('설정확인', seedTheme.colorScheme.fg.brand),
        ]) {
          final paragraph = tester.renderObject<RenderParagraph>(
            find.descendant(
              of: find.text(label),
              matching: find.byType(RichText),
            ),
          );
          final style = paragraph.text.style!;
          expect(style.decoration ?? TextDecoration.none, TextDecoration.none);
          expect(style.color, color);
        }

        await tester.tap(find.text('설정확인'));
        await tester.pumpAndSettle();
        expect(actions, 1);
        expect(find.byType(SeedSnackbar), findsNothing);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  }
}
