import 'package:material_ui/material_ui.dart';

import '../../foundations/colors/seed_palette.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';

/// Predefined domain types for [SeedContentPlaceholder] as specified by SEED Design.
enum SeedContentPlaceholderType {
  defaultType,
  buySell,
  car,
  commerce,
  coupon,
  food,
  group,
  image,
  jobs,
  business,
  post,
  realty,
}

/// A SEED Design Content Placeholder component.
///
/// Used as a fallback visual placeholder when images or media content
/// are absent or failed to load.
class SeedContentPlaceholder extends StatelessWidget {
  const SeedContentPlaceholder({
    super.key,
    this.type = SeedContentPlaceholderType.defaultType,
    this.width,
    this.height,
    this.icon,
    this.iconSize,
    this.borderRadius,
  });

  /// Predefined domain preset type. Defaults to [SeedContentPlaceholderType.defaultType].
  final SeedContentPlaceholderType type;

  /// Optional width. If null, expands to fill parent.
  final double? width;

  /// Optional height. If null, expands to fill parent.
  final double? height;

  /// Custom icon widget. If null, uses the default icon for [type].
  final Widget? icon;

  /// Size of the fallback icon. If null, defaults to 50% of parent height (clamped 16..160).
  final double? iconSize;

  /// Border radius of the placeholder box. Defaults to [SeedBorderRadius.r2].
  final BorderRadius? borderRadius;

  IconData _iconForType(SeedContentPlaceholderType type) {
    switch (type) {
      case SeedContentPlaceholderType.buySell:
        return Icons.shopping_bag_outlined;
      case SeedContentPlaceholderType.car:
        return Icons.directions_car_outlined;
      case SeedContentPlaceholderType.commerce:
        return Icons.shopping_cart_outlined;
      case SeedContentPlaceholderType.coupon:
        return Icons.confirmation_number_outlined;
      case SeedContentPlaceholderType.food:
        return Icons.restaurant_outlined;
      case SeedContentPlaceholderType.group:
        return Icons.group_outlined;
      case SeedContentPlaceholderType.jobs:
        return Icons.work_outline;
      case SeedContentPlaceholderType.business:
        return Icons.business_outlined;
      case SeedContentPlaceholderType.post:
        return Icons.article_outlined;
      case SeedContentPlaceholderType.realty:
        return Icons.home_work_outlined;
      case SeedContentPlaceholderType.image:
      case SeedContentPlaceholderType.defaultType:
        return Icons.image_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final bgColor = colors.isDark ? SeedPalette.gray200Dark : SeedPalette.gray200Light;
    final fgColor = colors.isDark ? SeedPalette.gray400Dark : SeedPalette.gray400Light;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: borderRadius ?? SeedBorderRadius.r2,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final computedSize = (constraints.maxHeight.isFinite
                  ? constraints.maxHeight * 0.5
                  : 32.0)
              .clamp(16.0, 160.0);

          return Center(
            child: icon ??
                Icon(
                  _iconForType(type),
                  size: iconSize ?? computedSize,
                  color: fgColor,
                ),
          );
        },
      ),
    );
  }
}
