import 'package:material_ui/material_ui.dart';

import '../../theme/seed_theme.dart';
import '../../foundations/colors/seed_palette.dart';

/// The type of identity for [SeedIdentityPlaceholder].
enum SeedIdentityType { person, business }

/// A SEED Design Identity Placeholder component.
///
/// Used as a fallback visual element for user avatars when no profile
/// image is uploaded or available. Supports Person and Business variants.
class SeedIdentityPlaceholder extends StatelessWidget {
  const SeedIdentityPlaceholder({
    super.key,
    this.type = SeedIdentityType.person,
    this.size = 42.0,
    this.backgroundColor,
    this.iconColor,
  });

  /// The type of identity (person or business).
  final SeedIdentityType type;

  /// The diameter of the circular placeholder.
  final double size;

  /// Optional background color override.
  final Color? backgroundColor;

  /// Optional icon color override.
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;

    final IconData iconData = switch (type) {
      SeedIdentityType.person => Icons.person,
      SeedIdentityType.business => Icons.storefront,
    };

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color:
            backgroundColor ??
            (colors.isDark
                ? SeedPalette.gray500Dark
                : SeedPalette.gray500Light),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          iconData,
          size: size * 0.55,
          color: iconColor ?? SeedPalette.staticWhiteAlpha800,
        ),
      ),
    );
  }
}
