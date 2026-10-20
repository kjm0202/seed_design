import 'dart:io';

import 'package:flutter/services.dart';

const seedTestFontFamily = 'SeedTestNotoSansKR';
bool _loaded = false;

/// Bundled test-only font: independent of fonts installed on the host machine.
Future<void> loadSeedTestFonts({
  String fontDirectory = 'test/assets/fonts',
}) async {
  if (_loaded) return;
  final bytes = await File('$fontDirectory/NotoSansKR[wght].ttf').readAsBytes();
  final loader = FontLoader(seedTestFontFamily)
    ..addFont(Future.value(ByteData.sublistView(bytes)));
  await loader.load();
  final icons = FontLoader('MaterialIcons')
    ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
  await icons.load();
  _loaded = true;
}
