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
}
