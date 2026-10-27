import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../foundations/colors/seed_color_scheme.dart';
import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../foundations/typography/seed_typography.dart';
import '../../theme/seed_theme.dart';
import '../badge/seed_badge.dart';
import 'seed_bottom_sheet.dart';
import 'seed_menu.dart';
import 'seed_anchored_overlay.dart';

/// Shows a SEED Menu Sheet centered within the available safe area.
Future<T?> showSeedMenuSheet<T>({
  required BuildContext context,
  String? title,
  String? description,
  required List<SeedMenuGroupData> groups,
  String cancelLabel = '닫기',
  bool showCancelButton = true,
  bool closeOnSelect = true,
  TextAlign labelAlign = TextAlign.start,
  bool isDismissible = true,
  bool enableDrag = true,
  bool showHandle = true,
}) => showSeedBottomSheet<T>(
  context: context,
  isDismissible: isDismissible,
  enableDrag: enableDrag,
  child: SeedMenuSheet(
    title: title,
    description: description,
    groups: groups,
    cancelLabel: cancelLabel,
    showCancelButton: showCancelButton,
    closeOnSelect: closeOnSelect,
    labelAlign: labelAlign,
    showHandle: showHandle,
  ),
);

/// A grouped action menu with a fixed header/footer and a scrolling list.
class SeedMenuSheet extends StatelessWidget {
  const SeedMenuSheet({
    super.key,
    this.title,
    this.description,
    required this.groups,
    this.cancelLabel = '닫기',
    this.showCancelButton = true,
    this.closeOnSelect = true,
    this.labelAlign = TextAlign.start,
    this.showHandle = true,
  });

  final String? title;
  final String? description;
  final List<SeedMenuGroupData> groups;
  final String cancelLabel;
  final bool showCancelButton;

  /// Keep the sheet open for multi-selection or asynchronous confirmation.
  final bool closeOnSelect;
  final TextAlign labelAlign;
  final bool showHandle;

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;
    final mediaQuery = MediaQuery.of(context);

    return Align(
      alignment: Alignment.bottomCenter,
      widthFactor: 1,
      heightFactor: 1,
      child: SafeArea(
        top: false,
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) => ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 480,
              maxHeight: math.max(
                0,
                math.min(constraints.maxHeight, mediaQuery.size.height * 0.9),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: Material(
                color: colors.bg.layerFloating,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(SeedRadius.r5),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        24,
                        16,
                        16 + mediaQuery.padding.bottom,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (title != null || description != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Column(
                                children: [
                                  if (title != null)
                                    Semantics(
                                      header: true,
                                      child: Text(
                                        title!,
                                        style: typography.t6Bold.copyWith(
                                          color: colors.fg.neutral,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  if (description != null) ...[
                                    if (title != null)
                                      const SizedBox(height: 4),
                                    Text(
                                      description!,
                                      style: typography.t4Regular.copyWith(
                                        color: colors.fg.neutralMuted,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          Flexible(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  for (int g = 0; g < groups.length; g++) ...[
                                    if (g > 0) const SizedBox(height: 10),
                                    if (groups[g].label != null)
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          4,
                                          8,
                                          4,
                                          4,
                                        ),
                                        child: Text(
                                          groups[g].label!,
                                          style: typography.t3Bold.copyWith(
                                            color: colors.fg.neutralSubtle,
                                          ),
                                        ),
                                      ),
                                    Material(
                                      color: colors.bg.neutralWeak,
                                      borderRadius: SeedBorderRadius.r4,
                                      clipBehavior: Clip.antiAlias,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          for (
                                            int i = 0;
                                            i < groups[g].items.length;
                                            i++
                                          ) ...[
                                            if (i > 0)
                                              Divider(
                                                height: 1,
                                                thickness: 1,
                                                color:
                                                    colors.stroke.neutralMuted,
                                              ),
                                            _buildSheetItem(
                                              context,
                                              groups[g].items[i],
                                              colors,
                                              typography,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          if (showCancelButton)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Material(
                                color: colors.bg.neutralWeak,
                                borderRadius: SeedBorderRadius.r3,
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  onTap: () => _close(
                                    context,
                                    SeedOverlayDismissReason.closeButton,
                                  ),
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      minHeight: 52,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 14,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      cancelLabel,
                                      style: typography.t5Medium.copyWith(
                                        color: colors.fg.neutral,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (showHandle)
                      Positioned(
                        top: 6,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            width: 36,
                            height: 4,
                            decoration: BoxDecoration(
                              color: colors.stroke.neutralWeak,
                              borderRadius: SeedBorderRadius.full,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
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
      overlayColor: WidgetStatePropertyAll(colors.bg.neutralWeakPressed),
      onTap: item.enabled
          ? () {
              if (closeOnSelect) {
                _close(context, SeedOverlayDismissReason.action);
              }
              item.onTap?.call();
            }
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SeedDimension.x4,
          vertical: SeedDimension.x3_5,
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
              const SizedBox(width: SeedDimension.x3_5),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: labelAlign == TextAlign.center
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.label,
                    textAlign: labelAlign,
                    style: typography.t5Regular.copyWith(
                      color: labelColor,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  if (item.description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.description!,
                      textAlign: labelAlign,
                      style: typography.t3Medium.copyWith(
                        color: item.enabled
                            ? colors.fg.neutralSubtle
                            : colors.fg.disabled,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (item.badge != null)
              SeedBadge(
                label: item.badge!,
                tone: item.isDestructive
                    ? SeedBadgeTone.critical
                    : SeedBadgeTone.neutral,
              ),
          ],
        ),
      ),
    );
  }
}

void _close(BuildContext context, SeedOverlayDismissReason reason) {
  final scope = SeedOverlayScope.maybeOf(context);
  if (scope != null) {
    scope.close(reason);
  } else {
    Navigator.of(context).pop();
  }
}
