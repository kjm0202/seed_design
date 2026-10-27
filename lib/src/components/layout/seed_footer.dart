import 'package:material_ui/material_ui.dart';

import '../../foundations/dimensions/seed_dimension.dart';
import '../../theme/seed_theme.dart';
import 'seed_divider.dart';
import '../../foundations/feedback/seed_scale_feedback.dart';
import '../../foundations/motion/seed_motion.dart';

enum SeedFooterLinkTextSize { medium, large }

/// SEED Footer.LinkText, independent of the full page [SeedFooter] layout.
/// The caller handles navigation in [onTap]; [uri] exposes the link destination
/// to accessibility services without imposing a URL launcher dependency.
class SeedFooterLinkText extends StatelessWidget {
  const SeedFooterLinkText({
    super.key,
    required this.label,
    this.onTap,
    this.uri,
    this.suffixIcon,
    this.size = SeedFooterLinkTextSize.medium,
  });
  final String label;
  final VoidCallback? onTap;
  final Uri? uri;
  final Widget? suffixIcon;
  final SeedFooterLinkTextSize size;

  @override
  Widget build(BuildContext context) {
    final large = size == SeedFooterLinkTextSize.large;
    final colors = context.seedColor;
    return Semantics(
      link: true,
      linkUrl: uri,
      child: SeedPressable(
        semanticButton: false,
        enableScale: false,
        semanticsLabel: label,
        onTap: onTap,
        builder: (context, engaged) => AnimatedDefaultTextStyle(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : SeedDuration.colorTransition,
          curve: SeedCurves.easing,
          style:
              (large
                      ? context.seedTypography.t5Medium
                      : context.seedTypography.t4Medium)
                  .copyWith(
                    color: engaged
                        ? (large ? colors.fg.neutralSubtle : colors.fg.neutral)
                        : (large ? colors.fg.neutral : colors.fg.neutralMuted),
                  ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: Text(label)),
              if (suffixIcon != null) ...[
                const SizedBox(width: SeedDimension.x1),
                IconTheme(
                  data: IconThemeData(
                    size: large ? 14 : 12,
                    color: large ? colors.fg.neutral : colors.fg.neutralMuted,
                  ),
                  child: suffixIcon!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A link item in [SeedFooter].
class SeedFooterLink {
  const SeedFooterLink({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;
}

/// A sitemap column of links in [SeedFooter].
class SeedFooterColumn {
  const SeedFooterColumn({required this.title, required this.links});

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
    this.countrySelector,
    this.contactLinks,
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
  final String? copyright;
  final Widget? countrySelector;
  final List<SeedFooterLink>? contactLinks;

  /// Optional row of social/SNS link icon buttons.
  final List<Widget>? socialLinks;

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;

    final hasTopArea =
        brandLogo != null ||
        brandName != null ||
        (sitemapColumns != null && sitemapColumns!.isNotEmpty);

    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked =
            constraints.maxWidth < 600 ||
            MediaQuery.textScalerOf(context).scale(14) > 21;
        final brand = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ?brandLogo,
            if (brandLogo != null && brandName != null)
              const SizedBox(width: SeedDimension.x2),
            if (brandName != null)
              Flexible(
                child: Text(
                  brandName!,
                  style: typography.t6Bold.copyWith(color: colors.fg.neutral),
                ),
              ),
          ],
        );
        final sitemap = Wrap(
          spacing: SeedDimension.x6,
          runSpacing: SeedDimension.x4,
          children: [
            for (final col in sitemapColumns ?? <SeedFooterColumn>[])
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    col.title,
                    style: typography.t4Bold.copyWith(color: colors.fg.neutral),
                  ),
                  const SizedBox(height: SeedDimension.x2),
                  for (final link in col.links)
                    Padding(
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
                    ),
                ],
              ),
          ],
        );
        final copyrightText = Text(
          copyright ?? '',
          style: typography.t2Regular.copyWith(color: colors.fg.neutralMuted),
        );
        final socials = Wrap(
          runSpacing: SeedDimension.x1,
          children: socialLinks ?? [],
        );

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
                if (stacked)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (brandLogo != null || brandName != null) brand,
                      if (sitemapColumns?.isNotEmpty ?? false) ...[
                        const SizedBox(height: SeedDimension.x4),
                        sitemap,
                      ],
                    ],
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (brandLogo != null || brandName != null)
                        Expanded(flex: 2, child: brand),
                      if (sitemapColumns?.isNotEmpty ?? false)
                        Expanded(flex: 3, child: sitemap),
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

              if (contactLinks != null)
                Wrap(
                  spacing: 12,
                  children: [
                    for (final link in contactLinks!)
                      TextButton(
                        onPressed: link.onTap,
                        child: Text(link.label),
                      ),
                  ],
                ),
              if (countrySelector != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: countrySelector,
                ),
              // Bottom row: Copyright & Social links
              if (stacked)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    copyrightText,
                    if (socialLinks?.isNotEmpty ?? false) ...[
                      const SizedBox(height: SeedDimension.x3),
                      socials,
                    ],
                  ],
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: copyrightText),
                    if (socialLinks?.isNotEmpty ?? false)
                      Flexible(child: socials),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}
