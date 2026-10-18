import 'package:material_ui/material_ui.dart';
import '../../foundations/dimensions/seed_dimension.dart';
import '../../theme/seed_theme.dart';

/// Weight for [SeedField] label.
enum SeedFieldLabelWeight {
  medium,
  bold,
}

/// Field container component of SEED Design System.
///
/// Wraps input elements with standard Header (label, requirement mark, sub-actions)
/// and Footer (helper text, error message, character count).
class SeedField extends StatelessWidget {
  final String? label;
  final SeedFieldLabelWeight labelWeight;
  final bool required;
  final bool optional;
  final Widget? subAction;
  final Widget child;
  final String? helperText;
  final String? errorMessage;
  final String? characterCount;

  const SeedField({
    super.key,
    this.label,
    this.labelWeight = SeedFieldLabelWeight.bold,
    this.required = false,
    this.optional = false,
    this.subAction,
    required this.child,
    this.helperText,
    this.errorMessage,
    this.characterCount,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;

    final bool hasHeader = label != null || subAction != null;
    final bool hasFooter = errorMessage != null || helperText != null || characterCount != null;

    final TextStyle labelStyle = (labelWeight == SeedFieldLabelWeight.bold
            ? typography.t4Bold
            : typography.t4Medium)
        .copyWith(color: colors.fg.neutral);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasHeader) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (label != null)
                    Text(
                      label!,
                      style: labelStyle,
                    ),
                  if (required) ...[
                    const SizedBox(width: SeedDimension.x0_5),
                    Text(
                      '*',
                      style: typography.t4Bold.copyWith(
                        color: colors.fg.critical,
                      ),
                    ),
                  ] else if (optional) ...[
                    const SizedBox(width: SeedDimension.x1),
                    Text(
                      '(선택)',
                      style: typography.t3Regular.copyWith(
                        color: colors.fg.neutralSubtle,
                      ),
                    ),
                  ],
                ],
              ),
              ?subAction,
            ],
          ),
          const SizedBox(height: SeedDimension.x1_5),
        ],
        child,
        if (hasFooter) ...[
          const SizedBox(height: SeedDimension.x1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: errorMessage != null
                    ? Text(
                        errorMessage!,
                        style: typography.t2Regular.copyWith(
                          color: colors.fg.critical,
                        ),
                      )
                    : helperText != null
                        ? Text(
                            helperText!,
                            style: typography.t2Regular.copyWith(
                              color: colors.fg.neutralMuted,
                            ),
                          )
                        : const SizedBox.shrink(),
              ),
              if (characterCount != null) ...[
                const SizedBox(width: SeedDimension.x2),
                Text(
                  characterCount!,
                  style: typography.t2Regular.copyWith(
                    color: colors.fg.neutralMuted,
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}
