import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import '../widgets/section_header.dart';

/// Tab showcasing feedback, status indicators, gauges, reactions, and loading states.
class FeedbackTab extends StatefulWidget {
  const FeedbackTab({super.key});

  @override
  State<FeedbackTab> createState() => _FeedbackTabState();
}

class _FeedbackTabState extends State<FeedbackTab> {
  double _mannerTemp = 36.5;
  bool _isLiked = false;
  int _reactionCount = 12;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Manner Temperature',
          subtitle: '당근 매너온도: 10단계 레벨 색상 및 이모지 반응형 게이지',
        ),
        SeedMannerTemp(temperature: _mannerTemp),
        const SizedBox(height: SeedDimension.x4),
        Row(
          children: [
            const Text('온도 조절: '),
            Expanded(
              child: SeedSlider(
                value: _mannerTemp,
                min: 0,
                max: 99.9,
                onChanged: (v) => setState(() => _mannerTemp = v),
              ),
            ),
          ],
        ),
        const SizedBox(height: SeedDimension.x4),
        Wrap(
          spacing: SeedDimension.x2,
          runSpacing: SeedDimension.x2,
          children: [20.0, 36.5, 42.0, 55.0, 75.0, 99.0].map((t) {
            return SeedMannerTempBadge(temperature: t);
          }).toList(),
        ),
        const SizedBox(height: SeedDimension.x6),

        const SectionHeader(
          title: 'Progress & Skeleton',
          subtitle: '원형 진행률 인디케이터 및 쉬머 스켈레톤 플레이스홀더',
        ),
        Row(
          children: const [
            SeedProgressCircle(size: 24),
            SizedBox(width: SeedDimension.x4),
            SeedProgressCircle(size: 32, value: 0.7),
            SizedBox(width: SeedDimension.x4),
            Text('70% 완료 인디케이터'),
          ],
        ),
        const SizedBox(height: SeedDimension.x4),
        const _SkeletonPreview(),
        const SizedBox(height: SeedDimension.x6),

        const SectionHeader(
          title: 'Reaction & Help Bubble',
          subtitle: '반응형 공감 버튼 및 힌트 말풍선',
        ),
        Row(
          children: [
            SeedReactionButton(
              prefixIcon: Icon(
                _isLiked ? Icons.favorite : Icons.favorite_border,
              ),
              count: _reactionCount,
              isReacted: _isLiked,
              onReactedChanged: (val) {
                setState(() {
                  _isLiked = val;
                  _reactionCount += val ? 1 : -1;
                });
              },
            ),
            const SizedBox(width: SeedDimension.x4),
            const Expanded(
              child: SeedHelpBubble(
                title: '관심 목록 알림',
                description: '관심 목록에 등록하면 가격 변동 시 알림을 받아요!',
              ),
            ),
          ],
        ),
        const SizedBox(height: SeedDimension.x6),

        const SectionHeader(
          title: 'Result Section',
          subtitle: '데이터 조회 결과 없음 또는 완료 상태 안내',
        ),
        const SeedResultSection(
          title: '주변에 등록된 매물이 없습니다',
          description: '동네 범위를 넓혀서 검색하거나 키워드 알림을 설정해보세요.',
        ),
      ],
    );
  }
}

class _SkeletonPreview extends StatelessWidget {
  const _SkeletonPreview();

  @override
  Widget build(BuildContext context) {
    const skeleton = Row(
      children: [
        SeedSkeleton.circle(size: 48),
        SizedBox(width: SeedDimension.x3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SeedSkeleton(width: 140, height: 16),
              SizedBox(height: SeedDimension.x2),
              SeedSkeleton(width: double.infinity, height: 12),
            ],
          ),
        ),
      ],
    );

    if (Theme.of(context).brightness == Brightness.dark) return skeleton;

    // The light catalog background and skeleton share the neutralWeak color.
    // A content surface keeps the placeholder visible throughout its shimmer.
    return Container(
      padding: const EdgeInsets.all(SeedDimension.x4),
      decoration: BoxDecoration(
        color: context.seedColor.bg.layerDefault,
        borderRadius: SeedBorderRadius.r3,
      ),
      child: skeleton,
    );
  }
}
