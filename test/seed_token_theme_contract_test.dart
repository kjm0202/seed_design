import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

void main() {
  for (final brightness in [Brightness.light, Brightness.dark]) {
    test('SEED Material theme preserves $brightness semantic token roles', () {
      final seed = brightness == Brightness.light
          ? SeedThemeData.light(fontFamily: 'CustomSans')
          : SeedThemeData.dark(fontFamily: 'CustomSans');
      final material = seed.toThemeData();

      expect(material.brightness, brightness);
      expect(material.colorScheme.brightness, brightness);
      expect(material.colorScheme.primary, seed.colorScheme.fg.brand);
      expect(material.colorScheme.onPrimary, seed.colorScheme.fg.onBrandSolid);
      expect(material.colorScheme.surface, seed.colorScheme.bg.layerDefault);
      expect(material.colorScheme.onSurface, seed.colorScheme.fg.neutral);
      expect(material.colorScheme.outline, seed.colorScheme.stroke.neutralWeak);
      expect(
        material.scaffoldBackgroundColor,
        seed.colorScheme.bg.layerBasement,
      );
      expect(material.extension<SeedColorScheme>(), seed.colorScheme);
      expect(material.extension<SeedTypography>(), seed.typography);
      expect(material.extension<SeedShadows>(), seed.shadows);
      expect(material.textTheme.bodyLarge?.fontFamily, 'CustomSans');
      expect(material.textTheme.bodyLarge?.fontSize, SeedFontSize.t5);
      expect(
        material.textTheme.bodyLarge?.height,
        SeedLineHeight.t5 / SeedFontSize.t5,
      );
    });
  }
}
