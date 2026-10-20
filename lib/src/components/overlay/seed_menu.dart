import 'package:material_ui/material_ui.dart';

import '../../foundations/colors/seed_color_scheme.dart';
import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../foundations/typography/seed_typography.dart';
import '../../theme/seed_theme.dart';
import '../badge/seed_badge.dart';
import '../layout/seed_divider.dart';

/// An individual action or selectable item in [SeedMenu].
class SeedMenuItemData {
  const SeedMenuItemData({
    required this.label,
    this.description,
    this.prefixIcon,
    this.suffixIcon,
    this.badge,
    this.onTap,
    this.isDestructive = false,
    this.enabled = true,
  });

  final String label;
  final String? description;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? badge;
  final VoidCallback? onTap;
  final bool isDestructive;
  final bool enabled;
}

/// A group of items in [SeedMenu].
class SeedMenuGroupData {
  const SeedMenuGroupData({this.label, required this.items});

  final String? label;
  final List<SeedMenuItemData> items;
}

/// A SEED Design Menu component providing a list of actions or options.
class SeedMenu extends StatelessWidget {
  const SeedMenu({super.key, required this.groups, this.width = 240.0});

  /// The groups of items in the menu.
  final List<SeedMenuGroupData> groups;

  /// Width of the menu container.
  final double width;

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;
    final shadows = context.seedShadows;

    return Container(
      constraints: const BoxConstraints(maxHeight: 480),
      width: width,
      decoration: BoxDecoration(
        color: colors.bg.layerFloating,
        borderRadius: SeedBorderRadius.r5,
        boxShadow: shadows.s3,
      ),
      padding: const EdgeInsets.symmetric(vertical: SeedDimension.x2),
      child: SingleChildScrollView(
        primary: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int g = 0; g < groups.length; g++) ...[
              if (g > 0)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: SeedDimension.x4),
                  child: SeedDivider(),
                ),
              if (groups[g].label != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SeedDimension.x4,
                    vertical: SeedDimension.x2_5,
                  ),
                  child: Text(
                    groups[g].label!,
                    style: typography.t4Medium.copyWith(
                      color: colors.fg.neutralSubtle,
                    ),
                  ),
                ),
              ...groups[g].items.map(
                (item) => _buildMenuItem(context, item, colors, typography),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    SeedMenuItemData item,
    SeedColorScheme colors,
    SeedTypography typography,
  ) {
    Color labelColor;
    if (!item.enabled) {
      labelColor = colors.fg.disabled;
    } else if (item.isDestructive) {
      labelColor = colors.fg.critical;
    } else {
      labelColor = colors.fg.neutral;
    }

    return InkWell(
      overlayColor: WidgetStatePropertyAll(colors.bg.transparentPressed),
      onTap: item.enabled ? item.onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SeedDimension.x4,
          vertical: SeedDimension.x3,
        ),
        child: Row(
          children: [
            if (item.prefixIcon != null) ...[
              IconTheme(
                data: IconThemeData(
                  size: 22,
                  color: !item.enabled
                      ? colors.fg.disabled
                      : (item.isDestructive
                            ? colors.fg.critical
                            : colors.fg.neutral),
                ),
                child: item.prefixIcon!,
              ),
              const SizedBox(width: SeedDimension.x3),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.label,
                    style: typography.t5Regular.copyWith(color: labelColor),
                  ),
                  if (item.description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.description!,
                      style: typography.t3Regular.copyWith(
                        color: item.enabled
                            ? colors.fg.neutralSubtle
                            : colors.fg.disabled,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (item.badge != null) ...[
              SeedBadge(
                label: item.badge!,
                tone: item.isDestructive
                    ? SeedBadgeTone.critical
                    : SeedBadgeTone.neutral,
              ),
              const SizedBox(width: SeedDimension.x2),
            ],
            if (item.suffixIcon != null)
              IconTheme(
                data: IconThemeData(
                  size: 18,
                  color: item.enabled
                      ? (item.isDestructive
                            ? colors.fg.critical
                            : colors.fg.neutral)
                      : colors.fg.disabled,
                ),
                child: item.suffixIcon!,
              ),
          ],
        ),
      ),
    );
  }
}
