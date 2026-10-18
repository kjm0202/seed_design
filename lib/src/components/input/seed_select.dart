import 'package:material_ui/material_ui.dart';
import '../../foundations/colors/seed_color_scheme.dart';
import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../foundations/typography/seed_typography.dart';
import '../../theme/seed_theme.dart';
import '../layout/seed_divider.dart';
import 'seed_input_button.dart';

/// An individual option item in a [SeedSelect].
class SeedSelectItem<T> {
  const SeedSelectItem({
    required this.value,
    required this.label,
    this.description,
    this.prefixIcon,
    this.enabled = true,
  });

  final T value;
  final String label;
  final String? description;
  final Widget? prefixIcon;
  final bool enabled;
}

/// A group of items in a [SeedSelect].
class SeedSelectGroup<T> {
  const SeedSelectGroup({
    this.label,
    required this.items,
  });

  final String? label;
  final List<SeedSelectItem<T>> items;
}

/// A SEED Design Select component for form inputs.
///
/// Combines an input-styled trigger button with an anchored popup menu of options
/// organized into items and groups.
class SeedSelect<T> extends StatefulWidget {
  const SeedSelect({
    super.key,
    required this.groups,
    this.value,
    this.placeholder = '선택해주세요',
    this.prefixIcon,
    this.onChanged,
    this.size = SeedInputButtonSize.medium,
    this.enabled = true,
    this.isError = false,
  });

  /// The groups and options available for selection.
  final List<SeedSelectGroup<T>> groups;

  /// Currently selected value.
  final T? value;

  /// Placeholder text when [value] is null.
  final String placeholder;

  /// Prefix icon for the trigger.
  final Widget? prefixIcon;

  /// Callback when a value is selected.
  final ValueChanged<T>? onChanged;

  /// The size variant of the select trigger.
  final SeedInputButtonSize size;

  /// Whether the select is enabled.
  final bool enabled;

  /// Whether the select trigger displays an error stroke.
  final bool isError;

  @override
  State<SeedSelect<T>> createState() => _SeedSelectState<T>();
}

class _SeedSelectState<T> extends State<SeedSelect<T>> {
  final MenuController _menuController = MenuController();

  SeedSelectItem<T>? get _selectedItem {
    for (final group in widget.groups) {
      for (final item in group.items) {
        if (item.value == widget.value) return item;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;
    final selectedItem = _selectedItem;

    return MenuAnchor(
      controller: _menuController,
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(colors.bg.layerDefault),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(6.0),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: SeedBorderRadius.r3),
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(vertical: SeedDimension.x1),
        ),
      ),
      menuChildren: _buildMenuChildren(context, colors, typography),
      builder: (context, controller, child) {
        return SeedInputButton(
          size: widget.size,
          value: selectedItem?.label,
          placeholder: widget.placeholder,
          prefixIcon: selectedItem?.prefixIcon ?? widget.prefixIcon,
          suffixIcon: Icon(
            controller.isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            size: 20,
          ),
          enabled: widget.enabled,
          isError: widget.isError,
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
        );
      },
    );
  }

  List<Widget> _buildMenuChildren(
    BuildContext context,
    SeedColorScheme colors,
    SeedTypography typography,
  ) {
    final children = <Widget>[];

    for (int g = 0; g < widget.groups.length; g++) {
      final group = widget.groups[g];

      if (g > 0) {
        children.add(const SeedDivider());
      }

      if (group.label != null) {
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SeedDimension.x4,
              vertical: SeedDimension.x2,
            ),
            child: Text(
              group.label!,
              style: typography.t3Bold.copyWith(
                color: colors.fg.neutralSubtle,
              ),
            ),
          ),
        );
      }

      for (final item in group.items) {
        final isSelected = item.value == widget.value;

        children.add(
          MenuItemButton(
            onPressed: item.enabled
                ? () {
                    widget.onChanged?.call(item.value);
                  }
                : null,
            leadingIcon: item.prefixIcon != null
                ? IconTheme(
                    data: IconThemeData(
                      size: 20,
                      color: item.enabled ? colors.fg.neutralSubtle : colors.fg.disabled,
                    ),
                    child: item.prefixIcon!,
                  )
                : null,
            trailingIcon: isSelected
                ? Icon(
                    Icons.check,
                    color: colors.fg.brand,
                    size: 20,
                  )
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.label,
                  style: typography.t5Regular.copyWith(
                    color: item.enabled ? colors.fg.neutral : colors.fg.disabled,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (item.description != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.description!,
                    style: typography.t3Regular.copyWith(
                      color: item.enabled ? colors.fg.neutralSubtle : colors.fg.disabled,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }
    }

    return children;
  }
}
