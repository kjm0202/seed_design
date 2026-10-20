import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

/// Sample listing content for the detail panel in the overlay catalog.
class SidePanelDetails extends StatelessWidget {
  const SidePanelDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;

    Widget heading(String text) =>
        Text(text, style: typography.t5Bold.copyWith(color: colors.fg.neutral));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.bg.neutralWeak,
            borderRadius: SeedBorderRadius.r4,
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colors.bg.layerFloating,
                  borderRadius: SeedBorderRadius.r3,
                ),
                child: Icon(
                  Icons.headphones_outlined,
                  size: 28,
                  color: colors.fg.neutralMuted,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '무선 헤드폰',
                      style: typography.t4Medium.copyWith(
                        color: colors.fg.neutralMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '85,000원',
                      style: typography.t7Bold.copyWith(
                        color: colors.fg.neutral,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        heading('상품 정보'),
        const SizedBox(height: 12),
        const Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            SeedBadge(label: '판매중', tone: SeedBadgeTone.brand),
            SeedBadge(label: '상태 좋음'),
          ],
        ),
        const SizedBox(height: 12),
        const Text('실내에서만 사용했어요.\n충전 케이블과 케이스가 있어요.'),
        const SizedBox(height: 24),
        const SeedDivider(),
        const SizedBox(height: 24),
        heading('거래 안내'),
        const SizedBox(height: 16),
        const _DetailRow(
          icon: Icons.place_outlined,
          label: '거래 지역',
          value: '서울 마포구 망원동',
        ),
        const SizedBox(height: 16),
        const _DetailRow(
          icon: Icons.handshake_outlined,
          label: '거래 방법',
          value: '직거래 · 택배 가능',
        ),
        const SizedBox(height: 24),
        const SeedDivider(),
        const SizedBox(height: 24),
        heading('판매자'),
        const SizedBox(height: 12),
        Row(
          children: [
            const SeedAvatar(size: SeedAvatarSize.medium),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '망원동 이웃',
                    style: typography.t4Bold.copyWith(color: colors.fg.neutral),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '동네 인증 완료',
                    style: typography.t3Regular.copyWith(
                      color: colors.fg.neutralSubtle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: colors.fg.neutralSubtle),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: typography.t3Regular.copyWith(
                  color: colors.fg.neutralSubtle,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: typography.t4Medium.copyWith(color: colors.fg.neutral),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
