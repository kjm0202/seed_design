import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

Widget host(Widget child) => MaterialApp(
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('manner temperatures preserve Celsius precision with an emote', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SeedMannerTemp(temperature: 40, showEmoji: true),
            SeedMannerTemp(temperature: 36.55, showEmoji: true),
            SeedMannerTempBadge(temperature: 80),
          ],
        ),
      ),
    );
    expect(find.text('40°C'), findsOneWidget);
    expect(find.text('36.55°C'), findsOneWidget);
    expect(find.text('80°C'), findsOneWidget);
    expect(find.text(SeedMannerTempLevel.getEmoji(6)), findsOneWidget);
    expect(find.text(SeedMannerTempLevel.getEmoji(4)), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('file status replaces metadata and stacks retry below the icon', (
    tester,
  ) async {
    SeedAttachmentItem? retried;
    const failed = SeedAttachmentItem(
      id: 'error',
      name: 'failed.pdf',
      type: SeedAttachmentType.file,
      status: SeedAttachmentStatus.error,
    );
    await tester.pumpWidget(
      host(
        SeedAttachmentInput(
          items: const [
            SeedAttachmentItem(
              id: 'loading',
              name: 'uploading.pdf',
              type: SeedAttachmentType.file,
              status: SeedAttachmentStatus.uploading,
              progress: .6,
            ),
            failed,
            SeedAttachmentItem(
              id: 'ready',
              name: 'ready.pdf',
              type: SeedAttachmentType.file,
            ),
          ],
          onRetry: (item) => retried = item,
        ),
      ),
    );
    expect(find.text('uploading.pdf'), findsNothing);
    expect(find.text('failed.pdf'), findsNothing);
    expect(find.text('ready.pdf'), findsOneWidget);
    expect(find.byType(SeedProgressCircle), findsOneWidget);
    final retry = find.byTooltip('첨부 파일 업로드 재시도');
    expect(tester.getSize(retry), const Size(160, 80));
    expect(
      tester.getTopLeft(find.text('재시도')).dy,
      greaterThanOrEqualTo(tester.getBottomLeft(find.byIcon(Icons.refresh)).dy),
    );
    await tester.tap(retry);
    expect(retried, same(failed));
    expect(tester.takeException(), isNull);
  });

  testWidgets('image errors keep the square thumbnail with a retry label', (
    tester,
  ) async {
    var retries = 0;
    await tester.pumpWidget(
      host(
        SeedAttachmentInput(
          items: const [
            SeedAttachmentItem(id: 'error', status: SeedAttachmentStatus.error),
          ],
          onRetry: (_) => retries++,
        ),
      ),
    );
    final retry = find.byTooltip('첨부 파일 업로드 재시도');
    expect(tester.getSize(retry), const Size(80, 80));
    expect(find.text('재시도'), findsOneWidget);
    await tester.tap(find.text('재시도'));
    expect(retries, 1);
    expect(tester.takeException(), isNull);
  });
}
