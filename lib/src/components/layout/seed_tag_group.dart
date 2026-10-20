import 'package:material_ui/material_ui.dart';

import '../../foundations/dimensions/seed_dimension.dart';
import '../../theme/seed_theme.dart';
import '../../foundations/colors/seed_palette.dart';

/// Size of [SeedTagItem] and [SeedTagGroup].
enum SeedTagGroupSize {
  t2, // 12pt
  t3, // 13pt
  t4, // 14pt
}

/// Tone of [SeedTagItem].
enum SeedTagTone { neutralSubtle, neutral, brand }

/// An individual tag item in a [SeedTagGroup].
class SeedTagItem {
  final String label;
  final Widget? icon;
  final SeedTagTone tone;
  final bool bold;

  const SeedTagItem({
    required this.label,
    this.icon,
    this.tone = SeedTagTone.neutralSubtle,
    this.bold = false,
  });
}

/// Tag Group component of SEED Design System.
///
/// Displays metadata, summary tags, or entity attributes horizontally
/// separated by a bullet dot (`·`).
class SeedTagGroup extends StatelessWidget {
  final List<SeedTagItem> items;
  final SeedTagGroupSize size;
  final String separator;

  const SeedTagGroup({
    super.key,
    required this.items,
    this.size = SeedTagGroupSize.t2,
    this.separator = '·',
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;

    TextStyle baseStyle;
    switch (size) {
      case SeedTagGroupSize.t2:
        baseStyle = typography.t2Regular;
        break;
      case SeedTagGroupSize.t3:
        baseStyle = typography.t3Regular;
        break;
      case SeedTagGroupSize.t4:
        baseStyle = typography.t4Regular;
        break;
    }

    final double iconSize = size == SeedTagGroupSize.t2
        ? 12.0
        : (size == SeedTagGroupSize.t3 ? 13.0 : 14.0);

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: List.generate(items.isEmpty ? 0 : items.length * 2 - 1, (
        index,
      ) {
        if (index.isOdd) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: SeedDimension.x1),
            child: Text(
              separator,
              style: baseStyle.copyWith(
                color: colors.isDark
                    ? SeedPalette.gray600Dark
                    : SeedPalette.gray600Light,
              ),
            ),
          );
        }

        final item = items[index ~/ 2];
        Color textColor;
        switch (item.tone) {
          case SeedTagTone.neutralSubtle:
            textColor = colors.fg.neutralSubtle;
            break;
          case SeedTagTone.neutral:
            textColor = colors.fg.neutral;
            break;
          case SeedTagTone.brand:
            textColor = colors.fg.brand;
            break;
        }

        final TextStyle itemStyle = baseStyle.copyWith(
          color: textColor,
          fontWeight: item.bold ? FontWeight.bold : FontWeight.normal,
        );

        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (item.icon != null) ...[
              IconTheme(
                data: IconThemeData(color: textColor, size: iconSize),
                child: item.icon!,
              ),
              const SizedBox(width: SeedDimension.x0_5),
            ],
            Text(item.label, style: itemStyle),
          ],
        );
      }),
    );
  }
}
