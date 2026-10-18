import 'package:material_ui/material_ui.dart';
import '../../foundations/dimensions/seed_dimension.dart';
import '../../theme/seed_theme.dart';
import '../button/seed_button.dart';

/// Size of [SeedResultSection].
enum SeedResultSectionSize {
  medium,
  large,
}

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
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;

    final TextStyle titleStyle = (size == SeedResultSectionSize.large
            ? typography.t7Bold
            : typography.t5Bold)
        .copyWith(color: colors.fg.neutral);

    final TextStyle descStyle = (size == SeedResultSectionSize.large
            ? typography.t4Regular
            : typography.t3Regular)
        .copyWith(color: colors.fg.neutralMuted);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SeedDimension.x6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (asset != null) ...[
              asset!,
              const SizedBox(height: SeedDimension.x5),
            ],
            Text(
              title,
              style: titleStyle,
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: SeedDimension.x2),
              Text(
                description!,
                style: descStyle,
                textAlign: TextAlign.center,
              ),
            ],
            if (primaryActionLabel != null || secondaryActionLabel != null) ...[
              const SizedBox(height: SeedDimension.x6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (secondaryActionLabel != null) ...[
                    SeedButton(
                      label: secondaryActionLabel!,
                      variant: SeedButtonVariant.neutralWeak,
                      onPressed: onSecondaryAction,
                    ),
                    if (primaryActionLabel != null)
                      const SizedBox(width: SeedDimension.x2),
                  ],
                  if (primaryActionLabel != null)
                    SeedButton(
                      label: primaryActionLabel!,
                      variant: SeedButtonVariant.brandSolid,
                      onPressed: onPrimaryAction,
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
