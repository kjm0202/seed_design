import 'package:material_ui/material_ui.dart';

import '../../foundations/dimensions/seed_dimension.dart';
import '../../theme/seed_theme.dart';
import '../button/seed_button.dart';

/// Size of [SeedResultSection].
enum SeedResultSectionSize { medium, large }

/// Result Section component of SEED Design System.
///
/// Communicates empty states, completion results, or error feedback
/// with an asset graphic, title, description, and primary/secondary actions.
class SeedResultSection extends StatelessWidget {
  final Widget? asset;
  final String title;
  final String? description;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final SeedResultSectionSize size;

  /// Space around the section. Override horizontal padding when the parent
  /// already provides the screen gutter.
  final EdgeInsetsGeometry padding;

  const SeedResultSection({
    super.key,
    this.asset,
    required this.title,
    this.description,
    this.primaryActionLabel,
    this.onPrimaryAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.size = SeedResultSectionSize.large,
    this.padding = const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;

    final TextStyle titleStyle =
        (size == SeedResultSectionSize.large
                ? typography.t8Bold
                : typography.t5Bold)
            .copyWith(color: colors.fg.neutral);

    final TextStyle descStyle =
        (size == SeedResultSectionSize.large
                ? typography.t5Regular
                : typography.t4Regular)
            .copyWith(color: colors.fg.neutralMuted);

    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (asset != null) ...[
              asset!,
              const SizedBox(height: SeedDimension.x5),
            ],
            Text(title, style: titleStyle, textAlign: TextAlign.center),
            if (description != null) ...[
              SizedBox(height: size == SeedResultSectionSize.large ? 12 : 8),
              Text(description!, style: descStyle, textAlign: TextAlign.center),
            ],
            if (primaryActionLabel != null || secondaryActionLabel != null) ...[
              SizedBox(height: size == SeedResultSectionSize.large ? 28 : 24),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (primaryActionLabel != null)
                    SeedButton(
                      label: primaryActionLabel!,
                      variant: SeedButtonVariant.neutralWeak,
                      onPressed: onPrimaryAction,
                    ),
                  if (primaryActionLabel != null &&
                      secondaryActionLabel != null)
                    const SizedBox(height: SeedDimension.x5),
                  if (secondaryActionLabel != null)
                    SeedButton(
                      label: secondaryActionLabel!,
                      variant: SeedButtonVariant.ghost,
                      size: SeedButtonSize.small,
                      onPressed: onSecondaryAction,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
