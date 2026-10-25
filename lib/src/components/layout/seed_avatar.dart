import 'package:material_ui/material_ui.dart';

import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';
import 'seed_identity_placeholder.dart';

/// Size options for [SeedAvatar] corresponding to SEED Design specifications.
enum SeedAvatarSize {
  size20,
  size24,
  size36,
  small,
  size42,
  medium,
  size48,
  size56,
  large,
  size64,
  size80,
  xlarge,
  size96,
  size108;

  double get dimension {
    switch (this) {
      case SeedAvatarSize.size20:
        return 20.0;
      case SeedAvatarSize.size24:
        return 24.0;
      case SeedAvatarSize.size36:
      case SeedAvatarSize.small:
        return 36.0;
      case SeedAvatarSize.size42:
      case SeedAvatarSize.medium:
        return 42.0;
      case SeedAvatarSize.size48:
        return 48.0;
      case SeedAvatarSize.size56:
      case SeedAvatarSize.large:
        return 56.0;
      case SeedAvatarSize.size64:
        return 64.0;
      case SeedAvatarSize.size80:
      case SeedAvatarSize.xlarge:
        return 80.0;
      case SeedAvatarSize.size96:
        return 96.0;
      case SeedAvatarSize.size108:
        return 108.0;
    }
  }

  double get iconSize => dimension * 0.5;
}

/// Avatar component of SEED Design System.
///
/// Displays user profile pictures, store logos, or default placeholder graphics.
/// Supports 10 official sizes (20..108px) and badge attachments.
class SeedAvatar extends StatelessWidget {
  final ImageProvider? image;
  final Widget? placeholder;
  final SeedAvatarSize size;
  final BorderRadius? borderRadius;
  final Widget? badge;
  final AlignmentGeometry badgeAlignment;

  const SeedAvatar({
    super.key,
    this.image,
    this.placeholder,
    this.size = SeedAvatarSize.size48,
    this.borderRadius,
    this.badge,
    this.badgeAlignment = Alignment.bottomRight,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final effectiveRadius = borderRadius ?? SeedBorderRadius.full;

    final avatarBody = Container(
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

    if (badge != null) {
      return SizedBox(
        width: size.dimension,
        height: size.dimension,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            avatarBody,
            Align(
              alignment: badgeAlignment,
              child: badge!,
            ),
          ],
        ),
      );
    }

    return avatarBody;
  }
}
