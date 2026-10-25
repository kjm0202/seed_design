import 'package:material_ui/material_ui.dart';

import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../theme/seed_theme.dart';

/// Size of [SeedInputButton].
enum SeedInputButtonSize {
  /// Official `large` (52px), retaining the original Flutter API name.
  medium(height: 52.0, paddingX: 16.0),

  /// Official `medium` (40px), intended for desktop use.
  small(height: 40.0, paddingX: 14.0);

  const SeedInputButtonSize({required this.height, required this.paddingX});
  final double height;
  final double paddingX;
}

/// A SEED Design Input Button component.
///
/// Looks like an input field but functions as an interactive button that opens
/// pickers, sheets, or modal selections.
class SeedInputButton extends StatelessWidget {
  const SeedInputButton({
    super.key,
    this.value,
    this.placeholder,
    this.prefixIcon,
    this.suffixIcon,
    this.showClear = false,
    this.onClear,
    this.onPressed,
    this.size = SeedInputButtonSize.medium,
    this.isError = false,
    this.enabled = true,
  });

  /// Currently selected or displayed value.
  final String? value;

  /// Placeholder text when [value] is null or empty.
  final String? placeholder;

  /// Optional prefix icon widget.
  final Widget? prefixIcon;

  /// Optional suffix icon widget. Defaults to a down chevron.
  final Widget? suffixIcon;

  /// Whether to display a clear button when [value] is not empty.
  final bool showClear;

  /// Callback when the clear button is pressed.
  final VoidCallback? onClear;

  /// Callback when the button is tapped.
  final VoidCallback? onPressed;

  /// The size variant of the input button.
  final SeedInputButtonSize size;

  /// Whether the input button is in an error state.
  final bool isError;

  /// Whether the button is enabled for interaction.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;

    final hasValue = value != null && value!.isNotEmpty;

    Color borderColor;
    if (!enabled) {
      borderColor = colors.stroke.neutralWeak;
    } else if (isError) {
      borderColor = colors.stroke.criticalSolid;
    } else {
      borderColor = colors.stroke.neutralWeak;
    }

    final effectiveBg = enabled ? colors.bg.transparent : colors.bg.disabled;

    final effectiveTextColor = !enabled
        ? colors.fg.disabled
        : (hasValue ? colors.fg.neutral : colors.fg.placeholder);

    return SeedPressable(
      enabled: enabled,
      onTap: enabled ? onPressed : null,
      builder: (context, isPressed) {
        return Container(
          height: size.height,
          padding: EdgeInsets.symmetric(horizontal: size.paddingX),
          decoration: BoxDecoration(
            color: isPressed ? colors.bg.transparentPressed : effectiveBg,
            borderRadius: size == SeedInputButtonSize.medium
                ? SeedBorderRadius.r3
                : SeedBorderRadius.r2,
            border: Border.all(color: borderColor, width: isError ? 2 : 1),
          ),
          child: Row(
            children: [
              if (prefixIcon != null) ...[
                IconTheme(
                  data: IconThemeData(
                    size: size == SeedInputButtonSize.medium ? 20 : 16,
                    color: enabled
                        ? colors.fg.neutralMuted
                        : colors.fg.disabled,
                  ),
                  child: prefixIcon!,
                ),
                SizedBox(width: size == SeedInputButtonSize.medium ? 10 : 8),
              ],
              Expanded(
                child: Text(
                  hasValue ? value! : (placeholder ?? ''),
                  style:
                      (size == SeedInputButtonSize.medium
                              ? typography.t5Regular
                              : typography.t4Regular)
                          .copyWith(color: effectiveTextColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (showClear && hasValue && enabled) ...[
                SeedPressable(
                  semanticsLabel: '선택 내용 지우기',
                  enableScale: false,
                  onTap: onClear,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                    child: Center(
                      widthFactor: 1,
                      heightFactor: 1,
                      child: Icon(
                        Icons.cancel,
                        size: size == SeedInputButtonSize.medium ? 22.0 : 18.0,
                        color: colors.fg.neutralSubtle,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: SeedDimension.x1),
              ],
              IconTheme(
                data: IconThemeData(
                  size: size == SeedInputButtonSize.medium ? 20 : 16,
                  color: enabled ? colors.fg.neutralMuted : colors.fg.disabled,
                ),
                child: suffixIcon ?? const Icon(Icons.keyboard_arrow_down),
              ),
            ],
          ),
        );
      },
    );
  }
}
