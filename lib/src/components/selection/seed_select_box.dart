import 'package:material_ui/material_ui.dart';

import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
import '../../theme/seed_theme.dart';

/// Control icon style for [SeedSelectBox].
enum SeedSelectBoxControl { checkmark, radiomark, none }

/// Layout orientation for [SeedSelectBox].
enum SeedSelectBoxLayout { horizontal, vertical }

/// Select Box component of SEED Design System.
///
/// An explicit bordered card container for selecting single or multiple options.
class SeedSelectBox extends StatelessWidget {
  final String title;
  final String? description;
  final Widget? prefix;
  final Widget? customContent;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final SeedSelectBoxControl control;
  final SeedSelectBoxLayout layout;
  final bool enabled;

  const SeedSelectBox({
    super.key,
    required this.title,
    this.description,
    this.prefix,
    this.customContent,
    this.selected = false,
    this.onSelected,
    this.control = SeedSelectBoxControl.checkmark,
    this.layout = SeedSelectBoxLayout.horizontal,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;

    final Color strokeColor = !enabled
        ? colors.stroke.neutralWeak
        : (selected
              ? colors.stroke.neutralContrast
              : colors.stroke.neutralWeak);

    final Color bgColor = colors.bg.transparent;

    final TextStyle titleStyle = typography.t5Medium.copyWith(
      color: enabled ? colors.fg.neutral : colors.fg.disabled,
    );

    final TextStyle descStyle = typography.t3Regular.copyWith(
      color: enabled ? colors.fg.neutralMuted : colors.fg.disabled,
    );

    return SeedPressable(
      enabled: enabled && onSelected != null,
      selected: selected,
      enableScale: false,
      onTap: () => onSelected?.call(!selected),
      builder: (context, isPressed) => Container(
        padding: layout == SeedSelectBoxLayout.horizontal
            ? const EdgeInsets.fromLTRB(20, 16, 16, 16)
            : const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: isPressed ? colors.bg.transparentPressed : bgColor,
          borderRadius: SeedBorderRadius.r3,
          border: Border.all(color: strokeColor, width: selected ? 2 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (prefix != null) ...[
                  IconTheme(
                    data: IconThemeData(
                      size: 22.0,
                      color: enabled ? colors.fg.neutral : colors.fg.disabled,
                    ),
                    child: prefix!,
                  ),
                  SizedBox(
                    width: layout == SeedSelectBoxLayout.horizontal
                        ? SeedDimension.x3
                        : SeedDimension.x2_5,
                  ),
                ],
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: SeedDimension.x1),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: titleStyle),
                        if (description != null) ...[
                          const SizedBox(height: SeedDimension.x0_5),
                          Text(description!, style: descStyle),
                        ],
                      ],
                    ),
                  ),
                ),
                if (control != SeedSelectBoxControl.none) ...[
                  const SizedBox(width: SeedDimension.x1_5),
                  _buildControlMark(colors),
                ],
              ],
            ),
            if (customContent != null) ...[
              const SizedBox(height: SeedDimension.x3),
              customContent!,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildControlMark(dynamic colors) {
    if (control == SeedSelectBoxControl.checkmark) {
      if (selected) {
        return SizedBox.square(
          dimension: 20,
          child: Center(
            child: Icon(
              Icons.check_rounded,
              size: 15.0,
              color: enabled ? colors.fg.neutral : colors.fg.disabled,
            ),
          ),
        );
      } else {
        return SizedBox.square(
          dimension: 20,
          child: Center(
            child: Icon(
              Icons.check_rounded,
              size: 15,
              color: enabled ? colors.fg.placeholder : colors.fg.disabled,
            ),
          ),
        );
      }
    } else {
      // radiomark
      return Container(
        width: 20.0,
        height: 20.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected && enabled
              ? colors.bg.neutralSolid
              : colors.bg.transparent,
          border: Border.all(
            color: !enabled
                ? colors.stroke.neutralWeak
                : (selected
                      ? colors.stroke.neutralContrast
                      : colors.stroke.neutralWeak),
            width: selected && enabled ? 0 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: selected
            ? Container(
                width: enabled ? 8 : 10,
                height: enabled ? 8 : 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: enabled
                      ? colors.fg.onNeutralSolid
                      : colors.fg.disabled,
                ),
              )
            : null,
      );
    }
  }
}
