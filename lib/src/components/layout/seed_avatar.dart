import 'package:material_ui/material_ui.dart';

import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';
import 'seed_identity_placeholder.dart';

/// Size options for [SeedAvatar].
enum SeedAvatarSize {
  small,
  medium,
  large,
  xlarge;

  double get dimension {
    switch (this) {
      case SeedAvatarSize.small:
        return 36.0;
      case SeedAvatarSize.medium:
        return 42.0;
      case SeedAvatarSize.large:
        return 56.0;
      case SeedAvatarSize.xlarge:
        return 80.0;
    }
  }

  double get iconSize => dimension * 0.5;
}

/// Avatar component of SEED Design System.
///
/// Displays user profile pictures, store logos, or default placeholder graphics.
class SeedAvatar extends StatelessWidget {
  final ImageProvider? image;
  final Widget? placeholder;
  final SeedAvatarSize size;
  final BorderRadius? borderRadius;

  const SeedAvatar({
    super.key,
    this.image,
    this.placeholder,
    this.size = SeedAvatarSize.medium,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final effectiveRadius = borderRadius ?? SeedBorderRadius.full;

    return Container(
      width: size.dimension,
      height: size.dimension,
      decoration: BoxDecoration(
        color: colors.bg.neutralWeak,
        borderRadius: effectiveRadius,
        image: image != null
            ? DecorationImage(image: image!, fit: BoxFit.cover)
            : null,
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: effectiveRadius,
        border: Border.all(color: colors.stroke.neutralSubtle),
      ),
      alignment: Alignment.center,
      child: image == null
          ? (placeholder ?? SeedIdentityPlaceholder(size: size.dimension))
          : null,
    );
  }
}
