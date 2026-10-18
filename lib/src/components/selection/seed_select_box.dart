import 'package:material_ui/material_ui.dart';
import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
import '../../theme/seed_theme.dart';

/// Control icon style for [SeedSelectBox].
enum SeedSelectBoxControl {
  checkmark,
  radiomark,
  none,
}

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
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;

    final Color strokeColor = !enabled
        ? colors.stroke.neutralWeak
        : (selected ? colors.stroke.neutralContrast : colors.stroke.neutralWeak);

    final Color bgColor = !enabled
        ? colors.bg.disabled
        : (selected ? colors.bg.neutralWeak.withValues(alpha: 0.3) : colors.bg.layerFloating);

    final TextStyle titleStyle = typography.t4Bold.copyWith(
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
      child: Container(
        padding: const EdgeInsets.all(SeedDimension.x4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: SeedBorderRadius.r3,
          border: Border.all(
            color: strokeColor,
            width: selected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (prefix != null) ...[
                  prefix!,
                  const SizedBox(width: SeedDimension.x3),
                ],
                Expanded(
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
                if (control != SeedSelectBoxControl.none) ...[
                  const SizedBox(width: SeedDimension.x3),
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
        return Icon(
          Icons.check_rounded,
          size: 24.0,
          color: enabled ? colors.fg.neutral : colors.fg.disabled,
        );
      } else {
        return const SizedBox(width: 24.0, height: 24.0);
      }
    } else {
      // radiomark
      return Container(
        width: 20.0,
        height: 20.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: !enabled
                ? colors.stroke.neutralWeak
                : (selected ? colors.stroke.neutralContrast : colors.stroke.neutralWeak),
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: selected
            ? Container(
                width: 10.0,
                height: 10.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: enabled ? colors.fg.neutral : colors.fg.disabled,
                ),
              )
            : null,
      );
    }
  }
}
