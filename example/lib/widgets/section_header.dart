import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

/// Reusable section title and description header for the example catalog.
class SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const SectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;

    return Padding(
      padding: const EdgeInsets.only(bottom: SeedDimension.x3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: typography.t6Bold.copyWith(color: colors.fg.neutral),
          ),
          const SizedBox(height: SeedDimension.x0_5),
          Text(
            subtitle,
            style: typography.t2Regular.copyWith(color: colors.fg.neutralMuted),
          ),
        ],
      ),
    );
  }
}
