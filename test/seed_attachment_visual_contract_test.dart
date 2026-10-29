import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

Widget host(Widget child) => MaterialApp(
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(body: child),
);

void main() {
  testWidgets('general file trigger can use a paperclip and fires once', (
    tester,
  ) async {
    var added = 0;
    await tester.pumpWidget(
      host(
        SeedAttachmentField(
          triggerIcon: const Icon(Icons.attach_file),
          onAdd: () => added++,
        ),
      ),
    );
    await tester.tap(find.byIcon(Icons.attach_file));
    expect(added, 1);
    expect(find.byIcon(Icons.camera_alt_outlined), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Dropzone offers file selection without a duplicate tile, including disabled',
    (tester) async {
      for (final enabled in [true, false]) {
        var added = 0;
        await tester.pumpWidget(
          host(
            SeedAttachmentField(
              enabled: enabled,
              showDropzone: true,
              onAdd: () => added++,
            ),
          ),
        );
        expect(find.text('파일 선택'), findsOneWidget);
        expect(find.text('또는 여기로 드래그해서 업로드'), findsOneWidget);
        expect(find.byIcon(Icons.camera_alt_outlined), findsNothing);
        await tester.tap(find.text('파일 선택'));
        expect(added, enabled ? 1 : 0);
        expect(tester.takeException(), isNull);
      }
    },
  );
}
