import 'dart:convert';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_design/seed_design.dart';
import 'package:seed_design_example/stackflow_spa/stackflow_spa.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:url_launcher_platform_interface/link.dart';

class Picker extends FileSelectorPlatform {
  List<XFile> files = [];
  List<XTypeGroup>? accepted;
  @override
  Future<List<XFile>> openFiles({
    List<XTypeGroup>? acceptedTypeGroups,
    String? initialDirectory,
    String? confirmButtonText,
  }) async {
    accepted = acceptedTypeGroups;
    return files;
  }
}

class Launcher extends UrlLauncherPlatform {
  @override
  LinkDelegate? get linkDelegate => null;
  String? url;
  LaunchOptions? options;
  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    this.url = url;
    this.options = options;
    return true;
  }
}

final png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIW2P4z8DwHwAFgAI/ScLbtAAAAABJRU5ErkJggg==',
);
XFile image(String name) =>
    XFile.fromData(png, name: name, path: name, mimeType: 'image/png');

Future<void> open(WidgetTester tester, String path) async {
  await tester.pumpWidget(const StackflowSpaApp());
  tester.state<NavigatorState>(find.byType(Navigator)).pushNamed(path);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'attachment picker uses actual names/bytes and rejects nonimages',
    (tester) async {
      final previous = FileSelectorPlatform.instance;
      final picker = Picker()
        ..files = [
          image('receipt.png'),
          XFile.fromData(
            utf8.encode('text'),
            name: 'notes.txt',
            path: 'notes.txt',
            mimeType: 'text/plain',
          ),
        ];
      FileSelectorPlatform.instance = picker;
      addTearDown(() => FileSelectorPlatform.instance = previous);
      await open(tester, '/attachment-field');
      final input = find.byType(SeedAttachmentInput).first;
      await tester.tap(
        find.descendant(of: input, matching: find.byType(SeedPressable)).first,
      );
      await tester.pumpAndSettle();
      final entry = tester.widget<SeedAttachmentInput>(input).items.single;
      expect(entry.name, 'receipt.png');
      expect(entry.imageProvider, isA<MemoryImage>());
      expect(picker.accepted!.single.mimeTypes, ['image/*']);
      expect(find.textContaining('이미지 파일만'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'Form attachments enforce maximum count and cancellation adds nothing',
    (tester) async {
      final previous = FileSelectorPlatform.instance;
      final picker = Picker();
      FileSelectorPlatform.instance = picker;
      addTearDown(() => FileSelectorPlatform.instance = previous);
      await open(tester, '/form');
      final input = find.byType(SeedAttachmentInput);
      await tester.ensureVisible(input);
      final trigger = find
          .descendant(of: input, matching: find.byType(SeedPressable))
          .first;
      await tester.tap(trigger);
      await tester.pumpAndSettle();
      expect(tester.widget<SeedAttachmentInput>(input).items, isEmpty);
      picker.files = [for (var i = 0; i < 5; i++) image('image-$i.png')];
      await tester.tap(trigger);
      await tester.pumpAndSettle();
      expect(tester.widget<SeedAttachmentInput>(input).items.length, 3);
      expect(
        tester.widget<SeedAttachmentInput>(input).items.map((e) => e.name),
        ['image-0.png', 'image-1.png', 'image-2.png'],
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'dropzone receives real dropped files through the same validation path',
    (tester) async {
      await open(tester, '/attachment-field');
      final target = find.byType(DropTarget).first;
      await tester.ensureVisible(target);
      final drop = tester.widget<DropTarget>(target);
      drop.onDragDone!(
        DropDoneDetails(
          files: [
            DropItemFile.fromData(
              png,
              name: 'dropped.png',
              path: 'dropped.png',
              mimeType: 'image/png',
            ),
          ],
          localPosition: Offset.zero,
          globalPosition: Offset.zero,
        ),
      );
      await tester.pumpAndSettle();
      final input = find.descendant(
        of: target,
        matching: find.byType(SeedAttachmentInput),
      );
      expect(
        tester.widget<SeedAttachmentInput>(input).items.single.name,
        'dropped.png',
      );
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'ListLinkItem opens the external destination in a new browser tab',
    (tester) async {
      final previous = UrlLauncherPlatform.instance;
      final launcher = Launcher();
      UrlLauncherPlatform.instance = launcher;
      addTearDown(() => UrlLauncherPlatform.instance = previous);
      await open(tester, '/list-item-link');
      await tester.tap(find.byType(SeedListItem).first);
      await tester.pumpAndSettle();
      expect(launcher.url, 'https://example.com');
      expect(launcher.options!.webOnlyWindowName, '_blank');
      expect(tester.takeException(), isNull);
    },
  );
}
