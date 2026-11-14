import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_design_example/stackflow_spa/stackflow_spa.dart';

void main() {
  // Android reports a 0x0 view for the first frame(s) before the surface is
  // sized. The Home grid must survive that frame and lay out normally after.
  testWidgets('Home builds through a zero-size first frame', (tester) async {
    tester.view.physicalSize = Size.zero;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const StackflowSpaApp());
    await tester.pump();
    expect(tester.takeException(), isNull);

    tester.view.physicalSize = const Size(852, 883);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Home'), findsWidgets);
  });
}
