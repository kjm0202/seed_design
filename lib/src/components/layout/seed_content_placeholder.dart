import 'package:material_ui/material_ui.dart';

import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';
import '../../foundations/colors/seed_palette.dart';

/// A SEED Design Content Placeholder component.
///
/// Used as a fallback visual placeholder when images or media content
/// are absent or failed to load.
class SeedContentPlaceholder extends StatelessWidget {
  const SeedContentPlaceholder({
    super.key,
    this.width,
    this.height,
    this.icon,
    this.iconSize,
    this.borderRadius,
  });

  /// Optional width. If null, expands to fill parent.
  final double? width;

  /// Optional height. If null, expands to fill parent.
  final double? height;

  /// Custom icon widget. Defaults to an image placeholder icon.
  final Widget? icon;

  /// Size of the fallback icon.
  final double? iconSize;

  /// Border radius of the placeholder box. Defaults to [SeedBorderRadius.r2].
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colors.bg.neutralWeak,
        borderRadius: borderRadius ?? SeedBorderRadius.r2,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => Center(
          child:
              icon ??
              Icon(
                Icons.image_outlined,
                size:
                    iconSize ??
                    (constraints.maxHeight.isFinite
                            ? constraints.maxHeight * 0.5
                            : 32.0)
                        .clamp(16.0, 160.0),
                color: colors.isDark
                    ? SeedPalette.gray400Dark
                    : SeedPalette.gray400Light,
              ),
        ),
      ),
    );
  }
}
