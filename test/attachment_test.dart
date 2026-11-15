import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';
import 'support/seed_test_host.dart';

import 'package:flutter/semantics.dart';

void main() {
  testWidgets('general file trigger can use a paperclip and fires once', (
    tester,
  ) async {
    var added = 0;
    await tester.pumpWidget(
      koreanApp(
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
          koreanApp(
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
  group('status and errors', () {
    testWidgets(
      'file status replaces metadata and stacks retry below the icon',
      (tester) async {
        SeedAttachmentItem? retried;
        const failed = SeedAttachmentItem(
          id: 'error',
          name: 'failed.pdf',
          type: SeedAttachmentType.file,
          status: SeedAttachmentStatus.error,
        );
        await tester.pumpWidget(
          koreanAppCentered(
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
        final retry = find.byTooltip('재시도');
        expect(tester.getSize(retry), const Size(160, 80));
        expect(
          tester.getTopLeft(find.text('재시도')).dy,
          greaterThanOrEqualTo(
            tester.getBottomLeft(find.byIcon(Icons.refresh)).dy,
          ),
        );
        await tester.tap(retry);
        expect(retried, same(failed));
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('image errors keep the square thumbnail with a retry label', (
      tester,
    ) async {
      var retries = 0;
      await tester.pumpWidget(
        koreanAppCentered(
          SeedAttachmentInput(
            items: const [
              SeedAttachmentItem(
                id: 'error',
                status: SeedAttachmentStatus.error,
              ),
            ],
            onRetry: (_) => retries++,
          ),
        ),
      );
      final retry = find.byTooltip('재시도');
      expect(tester.getSize(retry), const Size(80, 80));
      expect(find.text('재시도'), findsOneWidget);
      await tester.tap(find.text('재시도'));
      expect(retries, 1);
      expect(tester.takeException(), isNull);
    });
  });

  group('upload retry', () {
    testWidgets('file upload loading and failure expose progress and retry', (
      tester,
    ) async {
      SeedAttachmentItem? retried;
      const failed = SeedAttachmentItem(
        id: 'failed',
        type: SeedAttachmentType.file,
        name: 'file.pdf',
        status: SeedAttachmentStatus.error,
      );
      await tester.pumpWidget(
        koreanAppCentered(
          SeedAttachmentInput(
            items: const [
              SeedAttachmentItem(
                id: 'loading',
                type: SeedAttachmentType.file,
                status: SeedAttachmentStatus.loading,
              ),
              failed,
            ],
            onRetry: (item) => retried = item,
          ),
        ),
      );
      expect(find.byType(SeedProgressCircle), findsOneWidget);
      await tester.tap(find.byTooltip('재시도'));
      expect(retried, same(failed));
    });

    testWidgets('disabled image upload cannot retry', (tester) async {
      var calls = 0;
      await tester.pumpWidget(
        koreanAppCentered(
          SeedAttachmentInput(
            enabled: false,
            items: const [
              SeedAttachmentItem(
                id: 'failed',
                status: SeedAttachmentStatus.error,
              ),
            ],
            onRetry: (_) => calls++,
          ),
        ),
      );
      await tester.tap(find.byIcon(Icons.refresh));
      expect(calls, 0);
    });
  });

  group('large text and truncation', () {
    setUpAll(loadSeedTestFonts);

    testWidgets(
      'attachment previews and reorder lanes grow with enlarged text',
      (tester) async {
        for (final scale in [1.0, 2.0, 3.0]) {
          for (final reorder in [false, true]) {
            await tester.pumpWidget(
              scaledApp(
                SeedAttachmentInput(
                  items: const [
                    SeedAttachmentItem(
                      id: 'file',
                      type: SeedAttachmentType.file,
                      name: 'sample.pdf',
                      sizeText: '2.4 MB',
                    ),
                  ],
                  onReorder: reorder ? (_, _) {} : null,
                ),
                scale: scale,
              ),
            );
            await tester.pumpAndSettle();
            expect(
              tester.takeException(),
              isNull,
              reason: 'scale=$scale, reorder=$reorder',
            );
            final name = tester.getRect(
              find.byWidgetPredicate(
                (widget) =>
                    widget is Text && widget.semanticsLabel == 'sample.pdf',
              ),
            );
            final size = tester.getRect(find.text('2.4 MB'));
            expect(name.overlaps(size), isFalse);
            expect(
              size.bottom - name.top,
              lessThanOrEqualTo(
                tester.getSize(find.byType(SeedAttachmentInput)).height,
              ),
            );
          }
        }
      },
    );

    testWidgets(
      'attachment truncation preserves just the extension at the end',
      (tester) async {
        for (final name in [
          'a_very_long_readable_document_filename.pdf',
          'a_very_long_readable_document_filename',
        ]) {
          await tester.pumpWidget(
            scaledApp(
              SeedAttachmentInput(
                items: [
                  SeedAttachmentItem(
                    id: name,
                    name: name,
                    type: SeedAttachmentType.file,
                  ),
                ],
              ),
            ),
          );
          final text = tester
              .widgetList<Text>(find.byType(Text))
              .singleWhere((widget) => widget.semanticsLabel == name);
          expect(text.data, contains('…'));
          expect(
            text.data!.split('…').last,
            name.endsWith('.pdf') ? '.pdf' : '',
          );
        }
      },
    );
  });

  group('readonly media', () {
    test('external media replacement and reorder honor readonly', () {
      final controller = SeedAttachmentController(maxCount: 1);
      addTearDown(controller.dispose);
      controller.addEntries(const [SeedAttachmentItem(id: 'one')]);
      controller.addEntries(const [SeedAttachmentItem(id: 'two')]);
      expect(controller.items.single.id, 'two');
      controller.maxCount = 3;
      controller.addEntries(const [
        SeedAttachmentItem(id: 'three'),
        SeedAttachmentItem(id: 'four'),
      ]);
      controller.reorder(0, 3);
      expect(controller.items.map((item) => item.id), ['three', 'four', 'two']);
    });
  });

  group('required and invalid', () {
    testWidgets(
      'Attachment explicitly exposes required and independent invalid state',
      (tester) async {
        await tester.pumpWidget(
          koreanAppCompact(
            const SeedAttachmentDisplayField(
              label: 'Photos',
              showRequiredIndicator: true,
              invalid: true,
              description: 'Select photos',
            ),
          ),
        );

        final field = tester.widget<SeedField>(find.byType(SeedField));
        expect(field.required, isTrue);
        expect(field.isInvalid, isTrue);
        expect(field.errorMessage, isNull);
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is Semantics && widget.properties.label == '필수 입력',
          ),
          findsOneWidget,
        );

        await tester.pumpWidget(
          koreanAppCompact(
            const SeedAttachmentDisplayField(
              label: 'Photos',
              invalid: false,
              errorMessage: 'Upload failed',
            ),
          ),
        );
        expect(
          tester.widget<SeedField>(find.byType(SeedField)).isInvalid,
          false,
        );
        expect(find.text('Upload failed'), findsNothing);

        await tester.pumpWidget(
          koreanAppCompact(
            const SeedAttachmentDisplayField(
              label: 'Photos',
              errorMessage: 'Upload failed',
            ),
          ),
        );
        expect(
          tester.widget<SeedField>(find.byType(SeedField)).isInvalid,
          true,
        );
        expect(find.text('Upload failed'), findsOneWidget);
      },
    );
  });

  group('dropzone and item', () {
    Widget koreanApp(Widget child, {bool isDark = false}) {
      return MaterialApp(
        theme: (isDark ? SeedThemeData.dark() : SeedThemeData.light())
            .toThemeData(),
        home: Scaffold(body: Center(child: child)),
      );
    }

    testWidgets('SeedAttachmentDropzone & SeedAttachmentItem file layout', (
      tester,
    ) async {
      var dropzoneTapped = false;
      var removed = false;

      await tester.pumpWidget(
        koreanApp(
          Column(
            children: [
              SeedAttachmentDropzone(onTap: () => dropzoneTapped = true),
              SeedAttachmentInput(
                items: [
                  const SeedAttachmentItem(
                    id: '1',
                    name: 'document.pdf',
                    sizeText: '2.4 MB',
                    type: SeedAttachmentType.file,
                  ),
                ],
                onRemove: (_) => removed = true,
              ),
            ],
          ),
        ),
      );

      expect(find.byType(SeedAttachmentDropzone), findsOneWidget);
      await tester.tap(find.byType(SeedAttachmentDropzone));
      expect(dropzoneTapped, isTrue);

      expect(
        find.byWidgetPredicate(
          (widget) => widget is Text && widget.semanticsLabel == 'document.pdf',
        ),
        findsOneWidget,
      );
      expect(find.text('2.4 MB'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      expect(removed, isTrue);
    });
  });

  group('input count', () {
    testWidgets('SeedAttachmentInput displays count and trigger', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light().toThemeData(),
          home: const Scaffold(
            body: SeedAttachmentInput(items: [], maxCount: 10),
          ),
        ),
      );

      expect(find.text('0/10'), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);
    });
  });

  group('remove button overhang', () {
    for (final type in SeedAttachmentType.values) {
      for (final reorderable in [false, true]) {
        testWidgets(
          '$type reorderable=$reorderable removes from the overhang',
          (tester) async {
            final removed = <String>[];
            await tester.pumpWidget(
              MaterialApp(
                theme: SeedThemeData.light().toThemeData(),
                home: Scaffold(
                  body: Padding(
                    padding: const EdgeInsets.all(24),
                    child: SeedAttachmentInput(
                      items: [
                        SeedAttachmentItem(id: 'a', name: 'a.pdf', type: type),
                        SeedAttachmentItem(id: 'b', name: 'b.pdf', type: type),
                      ],
                      onRemove: (item) => removed.add(item.id),
                      onReorder: reorderable ? (_, _) {} : null,
                    ),
                  ),
                ),
              ),
            );
            final button = tester.getRect(
              find
                  .ancestor(
                    of: find.byIcon(Icons.close_rounded).first,
                    matching: find.byType(Container),
                  )
                  .first,
            );
            // The button sits 4px past the item's top-right corner.
            await tester.tapAt(Offset(button.right - 2, button.top + 2));
            await tester.pump();
            expect(removed, ['a']);
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  });

  group('retry and controller forwarding', () {
    Widget host(Widget child) => MaterialApp(
      theme: SeedThemeData.light().toThemeData(),
      home: Scaffold(
        body: Center(child: SizedBox(width: 600, child: child)),
      ),
    );

    const failed = SeedAttachmentItem(
      id: 'failed',
      type: SeedAttachmentType.file,
      name: 'failed.pdf',
      status: SeedAttachmentStatus.error,
    );

    testWidgets('field forwards retry availability and the active controller', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        host(const SeedAttachmentDisplayField(defaultEntries: [failed])),
      );
      var input = tester.widget<SeedAttachmentInput>(
        find.byType(SeedAttachmentInput),
      );
      expect(input.onRetry, isNull);
      final retry = tester.getSemantics(find.byTooltip('Retry'));
      expect(retry.getSemanticsData().hasAction(SemanticsAction.tap), isFalse);

      SeedAttachmentItem? retried;
      SeedAttachmentController? usedController;
      final controller = SeedAttachmentController(items: [failed]);
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        host(
          SeedAttachmentField(
            controller: controller,
            onRetry: (item, active) {
              retried = item;
              usedController = active;
            },
          ),
        ),
      );
      input = tester.widget<SeedAttachmentInput>(
        find.byType(SeedAttachmentInput),
      );
      expect(input.onRetry, isNotNull);
      await tester.tap(find.byTooltip('Retry'));
      expect(retried, same(failed));
      expect(usedController, same(controller));
      semantics.dispose();
    });
  });

  group('dropzone', () {
    testWidgets('attachment dropzone spans the field width', (tester) async {
      await tester.pumpWidget(
        koreanAppTopLeft(SeedAttachmentField(showDropzone: true, onAdd: () {})),
      );
      final field = tester.getRect(find.byType(SeedAttachmentField));
      final dropzone = tester.getRect(find.byType(SeedAttachmentDropzone));
      expect(dropzone.width, moreOrLessEquals(field.width, epsilon: 1));
    });

    // Official AttachmentInput.DropzoneLabel is a plain div without
    // data-disabled, so the helper keeps fg.neutralSubtle even when the
    // ActionButton is disabled (e.g. maxFiles reached).
    testWidgets(
      'dropzone label stays neutralSubtle when the button is disabled',
      (tester) async {
        Color labelColor() =>
            tester.widget<Text>(find.text('또는 여기로 드래그해서 업로드')).style!.color!;
        final expected = const SeedColorScheme.light().fg.neutralSubtle;

        await tester.pumpWidget(
          koreanAppTopLeft(const SeedAttachmentDropzone(enabled: false)),
        );
        expect(labelColor(), expected);

        await tester.pumpWidget(
          koreanAppTopLeft(
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
      },
    );
  });
}
