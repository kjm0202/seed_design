import 'package:material_ui/material_ui.dart';
import '../../foundations/colors/seed_color_scheme.dart';
import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../foundations/typography/seed_typography.dart';
import '../../theme/seed_theme.dart';
import '../badge/seed_badge.dart';
import 'seed_menu.dart';

/// Shows a SEED Design modal bottom Menu Sheet.
Future<T?> showSeedMenuSheet<T>({
  required BuildContext context,
  String? title,
  String? description,
  required List<SeedMenuGroupData> groups,
  String cancelLabel = '닫기',
  bool showCancelButton = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    showDragHandle: false,
    isScrollControlled: true,
    builder: (context) {
      return SeedMenuSheet(
        title: title,
        description: description,
        groups: groups,
        cancelLabel: cancelLabel,
        showCancelButton: showCancelButton,
      );
    },
  );
}

/// A SEED Design Menu Sheet component.
///
/// Presents a group of actionable options in a mobile-optimized modal bottom sheet.
class SeedMenuSheet extends StatelessWidget {
  const SeedMenuSheet({
    super.key,
    this.title,
    this.description,
    required this.groups,
    this.cancelLabel = '닫기',
    this.showCancelButton = true,
  });

  /// Optional sheet title.
  final String? title;

  /// Optional sheet description.
  final String? description;

  /// The groups of menu items to display.
  final List<SeedMenuGroupData> groups;

  /// Text for the bottom cancel button.
  final String cancelLabel;

  /// Whether to display a bottom cancel button.
  final bool showCancelButton;

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;

    return Container(
      decoration: BoxDecoration(
        color: colors.bg.layerFloating,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(SeedRadius.r4),
          topRight: Radius.circular(SeedRadius.r4),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: SeedDimension.x3),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.stroke.neutralWeak,
                  borderRadius: SeedBorderRadius.full,
                ),
              ),
            ),

            // Header title & description
            if (title != null || description != null) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  SeedDimension.x4,
                  SeedDimension.x4,
                  SeedDimension.x4,
                  SeedDimension.x3,
                ),
                child: Column(
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        style: typography.t6Bold.copyWith(color: colors.fg.neutral),
                        textAlign: TextAlign.center,
                      ),
                    if (description != null) ...[
                      const SizedBox(height: SeedDimension.x1),
                      Text(
                        description!,
                        style: typography.t3Regular.copyWith(
                          color: colors.fg.neutralMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(height: SeedDimension.x3),
            ],

            // Menu Groups in rounded cards
            for (int g = 0; g < groups.length; g++) ...[
              if (groups[g].label != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    SeedDimension.x5,
                    SeedDimension.x2,
                    SeedDimension.x5,
                    SeedDimension.x1,
                  ),
                  child: Text(
                    groups[g].label!,
                    style: typography.t3Bold.copyWith(
                      color: colors.fg.neutralSubtle,
                    ),
                  ),
                ),
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: SeedDimension.x4,
                  vertical: SeedDimension.x1,
                ),
                decoration: BoxDecoration(
                  color: colors.bg.neutralWeak,
                  borderRadius: SeedBorderRadius.r3,
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < groups[g].items.length; i++) ...[
                      if (i > 0)
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: colors.stroke.neutralWeak.withValues(alpha: 0.5),
                        ),
                      _buildSheetItem(context, groups[g].items[i], colors, typography),
                    ],
                  ],
                ),
              ),
            ],

            // Cancel button
            if (showCancelButton) ...[
              Container(
                margin: const EdgeInsets.fromLTRB(
                  SeedDimension.x4,
                  SeedDimension.x2,
                  SeedDimension.x4,
                  SeedDimension.x4,
                ),
                decoration: BoxDecoration(
                  color: colors.bg.neutralWeak,
                  borderRadius: SeedBorderRadius.r3,
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    height: 52,
                    alignment: Alignment.center,
                    child: Text(
                      cancelLabel,
                      style: typography.t5Bold.copyWith(
                        color: colors.fg.neutral,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSheetItem(
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
      onTap: item.enabled
          ? () {
              Navigator.of(context).pop();
              item.onTap?.call();
            }
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SeedDimension.x5,
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
                      : (item.isDestructive ? colors.fg.critical : colors.fg.neutralSubtle),
                ),
                child: item.prefixIcon!,
              ),
              const SizedBox(width: SeedDimension.x3),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: item.prefixIcon == null
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.label,
                    textAlign:
                        item.prefixIcon == null ? TextAlign.center : TextAlign.start,
                    style: typography.t5Regular.copyWith(
                      color: labelColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (item.description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.description!,
                      textAlign:
                          item.prefixIcon == null ? TextAlign.center : TextAlign.start,
                      style: typography.t3Regular.copyWith(
                        color: item.enabled ? colors.fg.neutralSubtle : colors.fg.disabled,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (item.badge != null)
              SeedBadge(
                label: item.badge!,
                tone: item.isDestructive ? SeedBadgeTone.critical : SeedBadgeTone.neutral,
              ),
          ],
        ),
      ),
    );
  }
}
