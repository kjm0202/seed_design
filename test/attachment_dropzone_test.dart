import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';

Widget _host(Widget child, {double width = 320}) => MaterialApp(
  locale: const Locale('ko'),
  supportedLocales: const [Locale('en'), Locale('ko')],
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: SeedThemeData.light(fontFamily: seedTestFontFamily).toThemeData(),
  home: Scaffold(
    body: Align(
      alignment: Alignment.topLeft,
      child: SizedBox(width: width, child: child),
    ),
  ),
);

void main() {
testWidgets('attachment dropzone spans the field width', (tester) async {
    await tester.pumpWidget(
      _host(SeedAttachmentField(showDropzone: true, onAdd: () {})),
    );
    final field = tester.getRect(find.byType(SeedAttachmentField));
    final dropzone = tester.getRect(find.byType(SeedAttachmentDropzone));
    expect(dropzone.width, moreOrLessEquals(field.width, epsilon: 1));
  });

  // Official AttachmentInput.DropzoneLabel is a plain div without
  // data-disabled, so the helper keeps fg.neutralSubtle even when the
  // ActionButton is disabled (e.g. maxFiles reached).
  testWidgets('dropzone label stays neutralSubtle when the button is disabled', (
    tester,
  ) async {
    Color labelColor() => tester
        .widget<Text>(find.text('또는 여기로 드래그해서 업로드'))
        .style!
        .color!;
    final expected = const SeedColorScheme.light().fg.neutralSubtle;

    await tester.pumpWidget(_host(const SeedAttachmentDropzone(enabled: false)));
    expect(labelColor(), expected);

    await tester.pumpWidget(
      _host(
        SeedAttachmentField(
          showDropzone: true,
          maxCount: 1,
          defaultItems: const [
            SeedAttachmentItem(
              id: 'a',
              name: 'a.txt',
              type: SeedAttachmentType.file,
            ),
          ],
          onAdd: () {},
        ),
      ),
    );
    expect(labelColor(), expected);
  });
}
