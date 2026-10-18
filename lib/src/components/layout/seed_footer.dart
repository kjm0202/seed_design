import 'package:material_ui/material_ui.dart';
import '../../foundations/dimensions/seed_dimension.dart';
import '../../theme/seed_theme.dart';
import 'seed_divider.dart';

/// A link item in [SeedFooter].
class SeedFooterLink {
  const SeedFooterLink({
    required this.label,
    this.onTap,
  });

  final String label;
  final VoidCallback? onTap;
}

/// A sitemap column of links in [SeedFooter].
class SeedFooterColumn {
  const SeedFooterColumn({
    required this.title,
    required this.links,
  });

  final String title;
  final List<SeedFooterLink> links;
}

/// A SEED Design Footer component for pages and websites.
///
/// Organized into an optional top navigation/sitemap area and a bottom
/// notice/company information area separated by a divider.
class SeedFooter extends StatelessWidget {
  const SeedFooter({
    super.key,
    this.brandLogo,
    this.brandName,
    this.sitemapColumns,
    this.policyLinks,
    this.companyInfo,
    this.copyright = '© Danggeun Market Inc. All rights reserved.',
    this.socialLinks,
  });

  /// Optional brand logo widget.
  final Widget? brandLogo;

  /// Optional brand name text.
  final String? brandName;

  /// Optional sitemap navigation columns.
  final List<SeedFooterColumn>? sitemapColumns;

  /// List of policy/terms links (e.g. Terms of Service, Privacy Policy).
  final List<SeedFooterLink>? policyLinks;

  /// Multi-line or formatted business and company information string.
  final String? companyInfo;

  /// Copyright statement text.
  final String copyright;

  /// Optional row of social/SNS link icon buttons.
  final List<Widget>? socialLinks;

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;

    final hasTopArea = brandLogo != null ||
        brandName != null ||
        (sitemapColumns != null && sitemapColumns!.isNotEmpty);

    return Container(
      color: colors.bg.neutralWeak,
      padding: const EdgeInsets.symmetric(
        horizontal: SeedDimension.x4,
        vertical: SeedDimension.x6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top navigation area
          if (hasTopArea) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (brandLogo != null || brandName != null)
                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ?brandLogo,
                        if (brandLogo != null && brandName != null)
                          const SizedBox(width: SeedDimension.x2),
                        if (brandName != null)
                          Text(
                            brandName!,
                            style: typography.t6Bold.copyWith(
                              color: colors.fg.neutral,
                            ),
                          ),
                      ],
                    ),
                  ),
                if (sitemapColumns != null)
                  Expanded(
                    flex: 3,
                    child: Wrap(
                      spacing: SeedDimension.x6,
                      runSpacing: SeedDimension.x4,
                      children: sitemapColumns!.map((col) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              col.title,
                              style: typography.t4Bold.copyWith(
                                color: colors.fg.neutral,
                              ),
                            ),
                            const SizedBox(height: SeedDimension.x2),
                            ...col.links.map((link) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: SeedDimension.x1),
                                child: InkWell(
                                  onTap: link.onTap,
                                  child: Text(
                                    link.label,
                                    style: typography.t3Regular.copyWith(
                                      color: colors.fg.neutralSubtle,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: SeedDimension.x6),
            const SeedDivider(),
            const SizedBox(height: SeedDimension.x6),
          ],

          // Policy Links
          if (policyLinks != null && policyLinks!.isNotEmpty) ...[
            Wrap(
              spacing: SeedDimension.x3,
              runSpacing: SeedDimension.x2,
              children: policyLinks!.map((link) {
                return InkWell(
                  onTap: link.onTap,
                  child: Text(
                    link.label,
                    style: typography.t3Bold.copyWith(
                      color: colors.fg.neutral,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: SeedDimension.x3),
          ],

          // Business / Company Info
          if (companyInfo != null) ...[
            Text(
              companyInfo!,
              style: typography.t2Regular.copyWith(
                color: colors.fg.neutralMuted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: SeedDimension.x3),
          ],

          // Bottom row: Copyright & Social links
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  copyright,
                  style: typography.t2Regular.copyWith(
                    color: colors.fg.neutralMuted,
                  ),
                ),
              ),
              if (socialLinks != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: socialLinks!,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
