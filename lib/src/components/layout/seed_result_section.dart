import 'package:material_ui/material_ui.dart';

import '../../foundations/dimensions/seed_dimension.dart';
import '../../theme/seed_theme.dart';
import '../button/seed_button.dart';

/// Size of [SeedResultSection].
/// [SeedResultSectionSize.medium] uses compact typography;
/// [SeedResultSectionSize.large] uses larger spacing and text.
enum SeedResultSectionSize {
  /// Compact type and spacing.
  medium,
  /// Larger type and spacing.
  large,
}

/// Result Section component of SEED Design System.
///
/// Communicates empty states, completion results, or error feedback
/// with an asset graphic, title, description, and primary/secondary actions.
class SeedResultSection extends StatelessWidget {
  /// Optional illustration or icon shown above the result message.
  final Widget? asset;
  /// Main result message; omitted when null.
  final String? title;
  /// Custom action region, taking precedence over built-in action labels.
  final Widget? actions;
  /// Supporting result explanation.
  final String? description;
  /// Label for the built-in primary button when [actions] is null.
  final String? primaryActionLabel;
  /// Invoked by the primary action button.
  final VoidCallback? onPrimaryAction;
  /// Label for the built-in secondary button when [actions] is null.
  final String? secondaryActionLabel;
  /// Invoked by the secondary action button.
  final VoidCallback? onSecondaryAction;
  /// Typography and spacing scale; defaults to [SeedResultSectionSize.large].
  final SeedResultSectionSize size;

  /// Space around the section. Override horizontal padding when the parent
  /// already provides the screen gutter.
  final EdgeInsetsGeometry padding;

  /// Creates a result section with optional illustration, text, and actions.
  const SeedResultSection({
    super.key,
    this.asset,
    this.title,
    this.actions,
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
            ?asset,
            if (title != null)
              Text(title!, style: titleStyle, textAlign: TextAlign.center),
            if (title != null && description != null)
              SizedBox(height: size == SeedResultSectionSize.large ? 12 : 8),
            if (description != null)
              Text(description!, style: descStyle, textAlign: TextAlign.center),
            SizedBox(height: size == SeedResultSectionSize.large ? 28 : 24),
            if (actions != null) ...[
              actions!,
            ] else if (primaryActionLabel != null ||
                secondaryActionLabel != null) ...[
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
                      textColor: colors.fg.neutral,
                      fontWeight: FontWeight.bold,
                      bleed: true,
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
