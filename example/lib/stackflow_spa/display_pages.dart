import 'package:flutter/material.dart';
import 'package:seed_design/seed_design.dart';

import 'spa_types.dart';

/// Demonstrations corresponding to the display-related Stackflow activities.
/// The parent SPA shell owns navigation and the top bar.
Widget? buildDisplayPage(
  String activity,
  BuildContext context, {
  required SpaNavigate navigate,
  required VoidCallback goBack,
  Object? arguments,
}) {
  switch (activity) {
    case 'ActivityActionButton':
    case 'ActivityToggleButton':
    case 'ActivityReactionButton':
    case 'ActivityChipButton':
    case 'ActivityChipToggle':
    case 'ActivityAvatar':
    case 'ActivityAvatarStack':
      return _VariantPage(activity: activity);
    case 'ActivityBadge':
      return const _BadgePage();
    case 'ActivityTagGroup':
      return const _TagGroupPage();
    case 'ActivityMannerTempLevel':
      return const _MannerTempPage();
    case 'ActivityAccordion':
      return const _AccordionPage();
    case 'ActivityResultSection':
      return const _ResultPage();
    case 'ActivityScaleFeedback':
      return const _ScaleFeedbackPage();
    case 'ActivityTypographyScale':
      return const _TypographyPage();
    case 'ActivityPartialDarkMode':
      return const _PartialDarkPage();
    default:
      return null;
  }
}

Widget _scroll(Widget child) => ListView(
  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
  children: [child],
);

Widget _heading(BuildContext context, String label) => Padding(
  padding: const EdgeInsets.only(bottom: 8),
  child: Text(
    label,
    style: context.seedTypography.t5Bold.copyWith(
      color: context.seedColor.fg.neutral,
    ),
  ),
);

Widget _subheading(BuildContext context, String label) => Padding(
  padding: const EdgeInsets.only(bottom: 6),
  child: Text(
    label,
    style: context.seedTypography.t3Medium.copyWith(
      color: context.seedColor.fg.neutralMuted,
    ),
  ),
);

Widget _section(BuildContext context, String title, Widget content) => Padding(
  padding: const EdgeInsets.only(bottom: 24),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [_heading(context, title), content],
  ),
);

Widget _stage(BuildContext context, Widget child) => Container(
  width: double.infinity,
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: context.seedColor.bg.layerDefault,
    border: Border.all(color: context.seedColor.stroke.neutralWeak),
    borderRadius: BorderRadius.circular(12),
  ),
  child: child,
);

void _notice(BuildContext context, String message) {
  SeedSnackbarProvider.of(context).show(
    strategy: SeedSnackbarStrategy.immediate,
    child: SeedSnackbar(message: message),
  );
}

const _avatarUrls = [
  'https://avatars.githubusercontent.com/u/54893898?v=4',
  'https://avatars.githubusercontent.com/u/102206520?v=4',
  'https://avatars.githubusercontent.com/u/56245920?v=4',
];

const _avatarSizes = [
  SeedAvatarSize.size20,
  SeedAvatarSize.size24,
  SeedAvatarSize.size36,
  SeedAvatarSize.size42,
  SeedAvatarSize.size48,
  SeedAvatarSize.size56,
  SeedAvatarSize.size64,
  SeedAvatarSize.size80,
  SeedAvatarSize.size96,
  SeedAvatarSize.size108,
];

typedef _VariantSpec = ({
  String variant,
  String size,
  String layout,
  String avatarSize,
});

class _VariantPage extends StatefulWidget {
  const _VariantPage({required this.activity});
  final String activity;

  @override
  State<_VariantPage> createState() => _VariantPageState();
}

class _VariantPageState extends State<_VariantPage> {
  String variant = 'brandSolid';
  String size = 'medium';
  String layout = 'withText';
  String avatarSize = '64';
  final Map<_VariantSpec, bool> _pressed = {};
  bool showGrid = false;
  bool enabled = true;
  bool loading = false;

  bool get _isAction => widget.activity == 'ActivityActionButton';
  bool get _isToggle => widget.activity == 'ActivityToggleButton';
  bool get _isReaction => widget.activity == 'ActivityReactionButton';
  bool get _isChip => widget.activity.startsWith('ActivityChip');

  bool get _isAvatar => widget.activity.startsWith('ActivityAvatar');

  // Only values in the React recipe maps are listed here. Flutter avatar
  // compatibility aliases (small, medium, large, xlarge) are not extra sizes.
  List<String> get _variants => _isAction
      ? SeedButtonVariant.values.map((item) => item.name).toList()
      : _isToggle
      ? SeedToggleButtonVariant.values.map((item) => item.name).toList()
      : _isChip
      ? SeedChipVariant.values.map((item) => item.name).toList()
      : const [];

  List<String> get _sizes => _isAction
      ? SeedButtonSize.values.map((item) => item.name).toList()
      : _isToggle
      ? SeedToggleButtonSize.values.map((item) => item.name).toList()
      : _isReaction
      ? SeedReactionButtonSize.values.map((item) => item.name).toList()
      : _isChip
      ? SeedChipSize.values.map((item) => item.name).toList()
      : const [];

  List<String> get _avatarSizeOptions =>
      _avatarSizes.map((item) => item.dimension.toStringAsFixed(0)).toList();

  List<String> get _layouts =>
      _isChip ? const ['iconOnly', 'withText'] : const ['withText', 'iconOnly'];

  List<String> _expand(String selected, List<String> official) =>
      selected == 'ALL' ? official : [selected];

  List<_VariantSpec> _combinations() {
    if (_isAvatar) {
      return [
        for (final item in _expand(avatarSize, _avatarSizeOptions))
          (variant: variant, size: size, layout: layout, avatarSize: item),
      ];
    }
    return [
      for (final itemVariant
          in _variants.isEmpty ? [variant] : _expand(variant, _variants))
        for (final itemSize in _expand(size, _sizes))
          for (final itemLayout
              in _isAction || _isChip ? _expand(layout, _layouts) : [layout])
            (
              variant: itemVariant,
              size: itemSize,
              layout: itemLayout,
              avatarSize: avatarSize,
            ),
    ];
  }

  int get _reactColumns {
    // Matches getGridColumnCount: the last dimension set to ALL determines
    // the React showcase's preferred column count.
    if (_isAvatar && avatarSize == 'ALL') return _avatarSizes.length;
    if ((_isAction || _isChip) && layout == 'ALL') return 2;
    if (_sizes.isNotEmpty && size == 'ALL') return _sizes.length;
    if (_variants.isNotEmpty && variant == 'ALL') return _variants.length;
    return 1;
  }

  String _specLabel(_VariantSpec spec) {
    if (_isAvatar) return 'size: ${spec.avatarSize}';
    final parts = <String>[
      if (_variants.isNotEmpty) 'variant: ${spec.variant}',
      'size: ${spec.size}',
      if (_isAction || _isChip) 'layout: ${spec.layout}',
    ];
    return parts.join('\n');
  }

  @override
  void initState() {
    super.initState();
    if (widget.activity == 'ActivityActionButton') size = 'xsmall';
    if (widget.activity == 'ActivityToggleButton' ||
        widget.activity == 'ActivityReactionButton') {
      size = 'small';
    }
    if (widget.activity.startsWith('ActivityChip')) variant = 'solid';
  }

  Widget _choose(
    String title,
    String value,
    List<String> options,
    ValueChanged<String> onChanged,
  ) {
    return _controlRow(
      title,
      DropdownButton<String>(
        value: value,
        isDense: true,
        underline: const SizedBox.shrink(),
        items: [
          for (final option in options)
            DropdownMenuItem(value: option, child: Text(option)),
          const DropdownMenuItem(value: 'ALL', child: Text('All')),
        ],
        onChanged: (next) {
          if (next != null) setState(() => onChanged(next));
        },
      ),
    );
  }

  Widget _preview(_VariantSpec spec) {
    final isPressed = _pressed[spec] ?? false;
    void changePressed(bool next) => setState(() => _pressed[spec] = next);
    switch (widget.activity) {
      case 'ActivityActionButton':
        final buttonSize = SeedButtonSize.values.byName(spec.size);
        final buttonVariant = SeedButtonVariant.values.byName(spec.variant);
        if (spec.layout == 'iconOnly') {
          return SeedButton.iconOnly(
            icon: const Icon(Icons.add),
            onPressed: () => _notice(context, 'Action Button 눌림'),
            size: buttonSize,
            variant: buttonVariant,
            loading: loading,
            enabled: enabled,
            semanticsLabel: '추가',
          );
        }
        return SeedButton(
          label: '야옹',
          prefixIcon: const Icon(Icons.add),
          suffixIcon: const Icon(Icons.keyboard_arrow_down),
          onPressed: () => _notice(context, '야옹'),
          size: buttonSize,
          variant: buttonVariant,
          loading: loading,
          enabled: enabled,
        );
      case 'ActivityToggleButton':
        return SeedToggleButton(
          selected: isPressed,
          onSelectedChanged: changePressed,
          prefixIcon: const Icon(Icons.thumb_up),
          label: 'Like',
          variant: SeedToggleButtonVariant.values.byName(spec.variant),
          size: SeedToggleButtonSize.values.byName(spec.size),
          loading: loading,
          enabled: enabled,
        );
      case 'ActivityReactionButton':
        return SeedReactionButton(
          pressed: isPressed,
          onPressedChange: changePressed,
          prefixIcon: const Icon(Icons.sentiment_satisfied_alt),
          label: '야옹쓰',
          count: 10,
          size: SeedReactionButtonSize.values.byName(spec.size),
          loading: loading,
          enabled: enabled,
        );
      case 'ActivityChipButton':
      case 'ActivityChipToggle':
        final chipSize = SeedChipSize.values.byName(spec.size);
        final chipVariant = SeedChipVariant.values.byName(spec.variant);
        if (spec.layout == 'iconOnly') {
          return SeedChip.iconOnly(
            icon: const Icon(Icons.add),
            semanticsLabel: '추가',
            size: chipSize,
            variant: chipVariant,
            enabled: enabled,
            checked: null,
            onCheckedChange: null,
            onPressed: () => _notice(context, 'Chip.Button'),
          );
        }
        return SeedChip(
          label: '야옹',
          size: chipSize,
          variant: chipVariant,
          enabled: enabled,
          checked: null,
          onCheckedChange: null,
          onPressed: () => _notice(context, 'Chip.Button'),
        );
      case 'ActivityAvatar':
        return SeedAvatar(
          size: _avatarSizes.firstWhere(
            (item) => item.dimension.toStringAsFixed(0) == spec.avatarSize,
          ),
          image: NetworkImage(_avatarUrls[0]),
          badge: Container(
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
          ),
        );
      case 'ActivityAvatarStack':
        final currentSize = _avatarSizes.firstWhere(
          (item) => item.dimension.toStringAsFixed(0) == spec.avatarSize,
        );
        return SeedAvatarStack(
          size: currentSize,
          children: [
            for (final url in _avatarUrls)
              SeedAvatar(image: NetworkImage(url), size: currentSize),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _previewTile(_VariantSpec spec) => Semantics(
    container: true,
    label: _specLabel(spec),
    child: Align(alignment: Alignment.topLeft, child: _preview(spec)),
  );

  Widget _controlRow(String title, Widget control) => Container(
    constraints: const BoxConstraints(minHeight: 52),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(color: context.seedColor.stroke.neutralMuted),
      ),
    ),
    child: Row(
      children: [
        Expanded(child: Text(title, style: context.seedTypography.t5Bold)),
        control,
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final combinations = _combinations();
    final columns = _reactColumns;
    return LayoutBuilder(
      builder: (context, constraints) {
        final controls = Material(
          color: context.seedColor.bg.layerDefault,
          child: SingleChildScrollView(
            key: const ValueKey('analyzer-controls'),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _controlRow(
                  '그리드 표시',
                  SeedSwitch(
                    size: SeedSwitchSize.size24,
                    checked: showGrid,
                    onCheckedChange: (v) => setState(() => showGrid = v),
                  ),
                ),
                if (_variants.isNotEmpty)
                  _choose('variant', variant, _variants, (v) => variant = v),
                if (_sizes.isNotEmpty)
                  _choose('size', size, _sizes, (v) => size = v),
                if (_isAction || _isChip)
                  _choose('layout', layout, _layouts, (v) => layout = v),
                if (_isAvatar)
                  _choose(
                    'size',
                    avatarSize,
                    _avatarSizeOptions,
                    (v) => avatarSize = v,
                  ),
              ],
            ),
          ),
        );
        return Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  if (showGrid)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: _ShowcaseGridPainter(
                            context.seedColor.fg.neutralMuted,
                          ),
                        ),
                      ),
                    ),
                  SingleChildScrollView(
                    key: const ValueKey('analyzer-preview'),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: constraints.maxWidth,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: IntrinsicWidth(
                            child: Table(
                              defaultColumnWidth: const IntrinsicColumnWidth(
                                flex: 1,
                              ),
                              defaultVerticalAlignment:
                                  TableCellVerticalAlignment.top,
                              children: [
                                for (
                                  var row = 0;
                                  row < combinations.length;
                                  row += columns
                                )
                                  TableRow(
                                    children: [
                                      for (var col = 0; col < columns; col++)
                                        Padding(
                                          padding: EdgeInsets.only(
                                            right: col == columns - 1 ? 0 : 16,
                                            bottom: 16,
                                          ),
                                          child: row + col < combinations.length
                                              ? _previewTile(
                                                  combinations[row + col],
                                                )
                                              : const SizedBox.shrink(),
                                        ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SeedDivider(),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: constraints.maxHeight * .46,
              ),
              child: controls,
            ),
          ],
        );
      },
    );
  }
}

class _ShowcaseGridPainter extends CustomPainter {
  const _ShowcaseGridPainter(this.lineColor);

  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    for (var x = 0.0; x <= size.width; x += 16) {
      final major = x.round() % 64 == 0;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        Paint()
          ..color = lineColor.withValues(alpha: major ? 0.3 : 0.13)
          ..strokeWidth = 1,
      );
    }
    for (var y = 0.0; y <= size.height; y += 16) {
      final major = y.round() % 64 == 0;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        Paint()
          ..color = lineColor.withValues(alpha: major ? 0.3 : 0.13)
          ..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(_ShowcaseGridPainter oldDelegate) =>
      oldDelegate.lineColor != lineColor;
}

class _BadgePage extends StatelessWidget {
  const _BadgePage();

  void _showHelp(BuildContext context, String title, String detail) {
    showSeedBottomSheet<void>(
      context: context,
      child: SeedBottomSheet(
        title: title,
        description: '집주인이 직접 등록한 매물에 표시돼요.',
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(detail),
        ),
        footer: Builder(
          builder: (sheetContext) => Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: SeedButton(
                label: '확인',
                onPressed: () => Navigator.of(sheetContext).pop(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _badgeSheetAction(BuildContext context, String description) =>
      SeedBadgeAction(
        semanticsLabel: '집주인 인증 안내',
        onPressed: () => _showHelp(context, '집주인 인증 매물', description),
        child: const Icon(Icons.help_outline),
      );

  Widget _badgeTooltip(String title) => SeedHelpBubbleTrigger(
    title: title,
    triggerBuilder: (context, isOpen, toggle) => SeedBadgeAction(
      semanticsLabel: '도움말',
      onPressed: toggle,
      child: const Icon(Icons.help_outline),
    ),
  );

  @override
  Widget build(BuildContext context) {
    const lorem = 'Est eiusmod sit do minim sunt incididunt aliqua et sit.';
    return _scroll(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final size in SeedBadgeSize.values)
            _section(
              context,
              size.name,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (size == SeedBadgeSize.medium ? 't1 ' : 't2 ') + lorem,
                    style: size == SeedBadgeSize.medium
                        ? context.seedTypography.t1Bold
                        : context.seedTypography.t2Bold,
                  ),
                  const SizedBox(height: 12),
                  for (final prefix in [false, true]) ...[
                    if (prefix) _subheading(context, 'Prefix'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final variant in [
                          SeedBadgeVariant.weak,
                          SeedBadgeVariant.solid,
                          SeedBadgeVariant.outline,
                        ])
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (final tone in SeedBadgeTone.values)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: SeedBadge(
                                    label: prefix
                                        ? '관심 등록'
                                        : '${size == SeedBadgeSize.medium ? 't1' : 't2'} $lorem',
                                    size: size,
                                    variant: variant,
                                    tone: tone,
                                    prefix: prefix
                                        ? const Icon(Icons.favorite)
                                        : null,
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  _subheading(context, 'Action'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      SeedBadge(
                        label: '판매 완료',
                        size: size,
                        variant: SeedBadgeVariant.weak,
                        action: _badgeTooltip('판매 완료된 상품이에요'),
                      ),
                      SeedBadge(
                        label: '집주인',
                        size: size,
                        variant: SeedBadgeVariant.outline,
                        action: _badgeSheetAction(
                          context,
                          '매물을 올린 사람이 집주인임을 확인할 수 있어, 중개소에서 등록한 매물과 구분할 수 있어요.',
                        ),
                      ),
                      SeedBadge(
                        label: '관심 등록',
                        size: size,
                        variant: SeedBadgeVariant.solid,
                        tone: SeedBadgeTone.brand,
                        prefix: const Icon(Icons.favorite),
                        action: _badgeTooltip('관심 등록한 이웃이 많은 상품이에요'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _subheading(context, 'Truncate'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      SeedBadge(label: lorem, size: size, maxWidth: 120),
                      SeedBadge(
                        label: lorem,
                        size: size,
                        maxWidth: 160,
                        prefix: const Icon(Icons.favorite),
                        action: _badgeTooltip(lorem),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TagGroupPage extends StatelessWidget {
  const _TagGroupPage();

  static const _items = [
    SeedTagItem(label: '광고', suffix: Icon(Icons.campaign)),
    SeedTagItem(label: '끌올 3시간 전'),
    SeedTagItem(label: '서초4동', icon: Icon(Icons.location_pin)),
  ];

  @override
  Widget build(BuildContext context) => _scroll(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final size in SeedTagGroupSize.values)
          _section(
            context,
            size.name,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _subheading(context, 'Default'),
                SeedTagGroup(
                  size: size,
                  tone: SeedTagTone.neutralSubtle,
                  items: _items,
                ),
                const SizedBox(height: 16),
                _subheading(context, 'Truncate'),
                SizedBox(
                  width: 220,
                  child: SeedTagGroup(
                    size: size,
                    tone: SeedTagTone.neutralSubtle,
                    truncate: true,
                    items: _items,
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

class _MannerTempPage extends StatefulWidget {
  const _MannerTempPage();

  @override
  State<_MannerTempPage> createState() => _MannerTempPageState();
}

class _MannerTempPageState extends State<_MannerTempPage> {
  int? level = 1;
  bool showGrid = false;

  Widget controlRow(String label, Widget control) => Container(
    height: 52,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      border: Border(
        top: BorderSide(color: context.seedColor.stroke.neutralMuted),
      ),
    ),
    child: Row(
      children: [
        Expanded(child: Text(label, style: context.seedTypography.t5Bold)),
        control,
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Expanded(
        child: Stack(
          children: [
            if (showGrid)
              Positioned.fill(
                child: CustomPaint(
                  painter: _ShowcaseGridPainter(
                    context.seedColor.fg.neutralMuted,
                  ),
                ),
              ),
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  for (final current
                      in level == null
                          ? List.generate(10, (i) => i + 1)
                          : [level!])
                    SeedMannerTempBadge(temperature: 36.5, level: current),
                ],
              ),
            ),
          ],
        ),
      ),
      controlRow(
        '그리드 표시',
        SeedSwitch(
          checked: showGrid,
          onCheckedChange: (value) => setState(() => showGrid = value),
        ),
      ),
      controlRow(
        'level',
        DropdownButton<int>(
          value: level ?? 0,
          isDense: true,
          underline: const SizedBox.shrink(),
          items: [
            for (var value = 1; value <= 10; value++)
              DropdownMenuItem(value: value, child: Text('l$value')),
            const DropdownMenuItem(value: 0, child: Text('All')),
          ],
          onChanged: (value) =>
              setState(() => level = value == 0 ? null : value),
        ),
      ),
    ],
  );
}

const _faq = [
  (
    'service',
    '당근마켓은 어떤 서비스인가요?',
    null,
    '당근마켓은 동네 이웃 간의 중고거래를 돕는 플랫폼입니다. 가까운 이웃과 직거래로 안전하게 거래할 수 있어요.',
  ),
  (
    'safety',
    '안전하게 거래하는 방법이 있나요?',
    '직거래 안전 가이드',
    '공공장소에서 만나거나 안전거래 서비스를 이용해 보세요. 상품을 직접 확인하고 거래하는 것을 권장합니다.',
  ),
  (
    'manner-temp',
    '매너온도는 무엇인가요?',
    null,
    '매너온도는 당근마켓 회원들의 거래 매너를 수치화한 지표입니다. 좋은 거래 경험을 쌓을수록 온도가 올라갑니다.',
  ),
];

class _AccordionPage extends StatelessWidget {
  const _AccordionPage();

  Widget _faqSection(
    BuildContext context, {
    required String title,
    required String description,
    required SeedAccordionVariant variant,
    required bool multiple,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: _stage(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: context.seedTypography.t5Bold),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: context.seedTypography.t3Regular.copyWith(
                        color: context.seedColor.fg.neutralMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SeedBadge(label: variant.name, variant: SeedBadgeVariant.weak),
            ],
          ),
          const SizedBox(height: 16),
          SeedAccordion(
            variant: variant,
            multiple: multiple,
            items: [
              for (final faq in _faq)
                SeedAccordionItem(
                  value: faq.$1,
                  title: faq.$2,
                  description: faq.$3,
                  content: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      faq.$4,
                      style: context.seedTypography.t4Regular.copyWith(
                        color: context.seedColor.fg.neutralMuted,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => _scroll(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _faqSection(
          context,
          title: 'Inline',
          description: '여러 항목을 동시에 열 수 있는 기본 accordion 예시입니다.',
          variant: SeedAccordionVariant.inline,
          multiple: true,
        ),
        _faqSection(
          context,
          title: 'Separated',
          description: '카드형 항목을 하나씩 열고 닫는 accordion 예시입니다.',
          variant: SeedAccordionVariant.separated,
          multiple: false,
        ),
      ],
    ),
  );
}

class _ResultPage extends StatefulWidget {
  const _ResultPage();

  @override
  State<_ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<_ResultPage> {
  bool showAsset = true;
  SeedResultSectionSize size = SeedResultSectionSize.large;

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: () async {
      await Future<void>.delayed(const Duration(seconds: 1));
    },
    child: LayoutBuilder(
      builder: (context, constraints) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: constraints.maxHeight > 0 ? constraints.maxHeight : 440,
            child: SeedResultSection(
              size: size,
              asset: showAsset
                  ? const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Icon(Icons.diamond, size: 40, color: Colors.blue),
                    )
                  : null,
              title: '완료되었어요',
              description: '요청하신 작업이 성공적으로 완료되었습니다.\n확인 후 다음 단계로 진행해주세요.',
              primaryActionLabel: showAsset ? '에셋 숨김' : '에셋 표시',
              onPrimaryAction: () => setState(() => showAsset = !showAsset),
              secondaryActionLabel: size == SeedResultSectionSize.large
                  ? 'medium으로 전환'
                  : 'large로 전환',
              onSecondaryAction: () => setState(() {
                size = size == SeedResultSectionSize.large
                    ? SeedResultSectionSize.medium
                    : SeedResultSectionSize.large;
              }),
            ),
          ),
        ],
      ),
    ),
  );
}

class _ScaleFeedbackPage extends StatefulWidget {
  const _ScaleFeedbackPage();

  @override
  State<_ScaleFeedbackPage> createState() => _ScaleFeedbackPageState();
}

class _ScaleFeedbackPageState extends State<_ScaleFeedbackPage> {
  bool check = true;
  bool checkInList = true;
  String radio = 'first';
  bool rerender = false;
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Widget _demo(
    String title,
    String description,
    Widget child, {
    bool highlighted = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(context, title),
        _subheading(context, description),
        _stage(
          context,
          Container(
            width: double.infinity,
            color: highlighted
                ? context.seedColor.bg.criticalWeak
                : Colors.transparent,
            child: child,
          ),
        ),
      ],
    ),
  );

  Widget _pressable(
    String text, {
    double? width,
    double? height,
    bool enableScale = true,
    FocusNode? focusNode,
  }) {
    return SeedPressable(
      focusNode: focusNode,
      onTap: () => _notice(context, '$text 눌림'),
      enableScale: enableScale,
      child: Container(
        width: width,
        height: height ?? 38,
        padding: width == null
            ? const EdgeInsets.symmetric(horizontal: 14)
            : EdgeInsets.zero,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.seedColor.bg.neutralWeak,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: context.seedTypography.t3Medium.copyWith(
            color: context.seedColor.fg.neutral,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => _scroll(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '요소를 누르는 동안 축소가 유지됩니다. 각 섹션의 설명이 그 패널에서 무엇을 확인할 수 있는지 알려줍니다.',
          style: context.seedTypography.t3Regular,
        ),
        const SizedBox(height: 20),
        _section(
          context,
          'SEED 컴포넌트',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _demo(
                'ActionButton — size',
                'size가 달라도 세로로 줄어드는 거리는 같습니다.',
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final size in SeedButtonSize.values)
                      SeedButton(
                        label: size.name,
                        size: size,
                        onPressed: () => _notice(context, size.name),
                      ),
                  ],
                ),
              ),
              _demo(
                'ActionButton — 폭',
                '배율의 기준은 max(높이, 폭 / 4, 24)입니다. 폭이 긴 요소는 세로로 덜 줄고 가로로 더 줄어듭니다.',
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SeedButton.iconOnly(
                      icon: const Icon(Icons.add),
                      semanticsLabel: '아이콘 전용 정사각 버튼',
                      onPressed: () => _notice(context, '추가'),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: SeedButton(
                        isFullWidth: true,
                        label: '화면 폭을 채우는 버튼',
                        onPressed: () => _notice(context, '전체 폭'),
                      ),
                    ),
                  ],
                ),
              ),
              _demo(
                'Checkbox / RadioGroup — 단독',
                '마크가 줄어듭니다.',
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SeedCheckbox(
                      label: 'Checkbox',
                      checked: check,
                      onCheckedChange: (value) => setState(() => check = value),
                    ),
                    SeedRadio<String>(
                      value: 'first',
                      groupValue: radio,
                      onChanged: (value) =>
                          setState(() => radio = value ?? 'first'),
                      label: 'RadioGroupItem',
                    ),
                  ],
                ),
              ),
              _demo(
                'Checkbox / RadioGroup — ListItem 안',
                '행 배경만 바뀌고 마크는 줄지 않습니다.',
                Column(
                  children: [
                    SeedList(
                      children: [
                        SeedListItem(
                          titleText: 'prefix Checkmark',
                          prefix: Icon(
                            checkInList
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                          ),
                          checked: checkInList,
                          onTap: () =>
                              setState(() => checkInList = !checkInList),
                        ),
                        SeedCheckListItem(
                          title: 'suffix Checkmark',
                          value: !checkInList,
                          onChanged: (value) =>
                              setState(() => checkInList = !value),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SeedList(
                      children: [
                        for (final value in ['first', 'second'])
                          SeedRadioListItem<String>(
                            title: value == 'first'
                                ? 'Radiomark 1'
                                : 'Radiomark 2',
                            value: value,
                            groupValue: radio,
                            onChanged: (next) =>
                                setState(() => radio = next ?? 'first'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              _demo(
                'Callout — 루트 전체',
                '누를 수 있는 Callout만 전체가 줄어듭니다.',
                Column(
                  children: [
                    SeedCallout(
                      title: 'asChild button',
                      description: '루트 전체가 줄어듭니다.',
                      onTap: () => _notice(context, 'Callout'),
                    ),
                    const SizedBox(height: 12),
                    SeedCallout(
                      title: 'asChild anchor',
                      description: '링크처럼 동작해도 같습니다.',
                      onTap: () => _notice(context, 'Callout anchor'),
                    ),
                  ],
                ),
              ),
              _demo(
                '닫기 버튼',
                '닫기 버튼만 줄어듭니다. 반복해서 눌러볼 수 있도록 열린 상태로 고정했습니다.',
                Column(
                  children: [
                    SeedCallout(
                      open: true,
                      title: 'Callout',
                      description: '닫기 버튼만 줄어듭니다.',
                      onDismiss: () {},
                    ),
                    const SizedBox(height: 12),
                    SeedPageBanner(
                      open: true,
                      dismissible: true,
                      title: 'PageBanner',
                      description: '닫기 버튼만 줄어듭니다.',
                      onDismiss: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _section(
          context,
          '커스텀 구현',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _demo(
                '적용 방법 세 가지',
                '크기를 측정해 SEED 공통 축소 공식을 적용합니다.',
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _pressable('순수 CSS'),
                    _pressable('scale-feedback 상수'),
                    _pressable('ScaleFeedback', focusNode: _focusNode),
                  ],
                ),
              ),
              SeedButton(
                size: SeedButtonSize.xsmall,
                variant: SeedButtonVariant.neutralWeak,
                label: '자식에 단 ref로 포커스 이동',
                onPressed: () => _focusNode.requestFocus(),
              ),
              const SizedBox(height: 16),
              _demo(
                '불안정한 ref',
                '리렌더가 발생해도 누르는 동안 일정하게 축소됩니다.',
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _pressable(rerender ? '렌더 B' : '렌더 A'),
                    const SizedBox(height: 8),
                    SeedButton(
                      label: '리렌더',
                      size: SeedButtonSize.xsmall,
                      onPressed: () => setState(() => rerender = !rerender),
                    ),
                  ],
                ),
              ),
              _demo(
                '크기 대비',
                '24px 정사각은 2px, 300×44 바는 가로로 8px 줄어듭니다.',
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _pressable('+', width: 24, height: 24),
                    _pressable('300px 바', width: 300, height: 44),
                  ],
                ),
              ),
            ],
          ),
        ),
        _section(
          context,
          '간섭·실패 케이스',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _demo(
                'ref와 클래스 중 하나만',
                '축소만 일어나지 않고 배경색은 바뀝니다.',
                Wrap(
                  spacing: 8,
                  children: [
                    for (final label in ['클래스만', 'ref만'])
                      SeedPressable(
                        enableScale: false,
                        onTap: () {},
                        builder: (ctx, pressed) => Container(
                          padding: const EdgeInsets.all(16),
                          color: pressed
                              ? ctx.seedColor.bg.neutralWeakPressed
                              : ctx.seedColor.bg.neutralWeak,
                          child: Text(label),
                        ),
                      ),
                  ],
                ),
              ),
              _demo(
                '커스텀 래퍼 안의 SEED 마크',
                '래퍼와 마크를 함께 축소하는 경우와 마크의 축소를 끈 경우입니다.',
                Column(
                  children: [
                    for (final optOut in [false, true])
                      SeedPressable(
                        onTap: () {},
                        builder: (ctx, pressed) => Container(
                          padding: const EdgeInsets.all(16),
                          color: pressed
                              ? ctx.seedColor.bg.neutralWeakPressed
                              : ctx.seedColor.bg.neutralWeak,
                          child: Row(
                            children: [
                              SeedContentScale(
                                pressed: !optOut && pressed,
                                child: const Icon(Icons.check_box),
                              ),
                              const SizedBox(width: 8),
                              Text(optOut ? '마크 축소 끔' : '이중 축소'),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

const _typeSizes = <double>[
  SeedFontSize.t1,
  SeedFontSize.t2,
  SeedFontSize.t3,
  SeedFontSize.t4,
  SeedFontSize.t5,
  SeedFontSize.t6,
  SeedFontSize.t7,
  SeedFontSize.t8,
  SeedFontSize.t9,
  SeedFontSize.t10,
  SeedFontSize.t11,
  SeedFontSize.t12,
  SeedFontSize.t13,
  SeedFontSize.t14,
];

const _typeHeights = <double>[
  SeedLineHeight.t1,
  SeedLineHeight.t2,
  SeedLineHeight.t3,
  SeedLineHeight.t4,
  SeedLineHeight.t5,
  SeedLineHeight.t6,
  SeedLineHeight.t7,
  SeedLineHeight.t8,
  SeedLineHeight.t9,
  SeedLineHeight.t10,
  SeedLineHeight.t11,
  SeedLineHeight.t12,
  SeedLineHeight.t13,
  SeedLineHeight.t14,
];

class _TypographyPage extends StatefulWidget {
  const _TypographyPage();

  @override
  State<_TypographyPage> createState() => _TypographyPageState();
}

class _TypographyPageState extends State<_TypographyPage> {
  String weight = 'Regular';

  FontWeight get _weight => switch (weight) {
    'Medium' => FontWeight.w500,
    'Bold' => FontWeight.w700,
    _ => FontWeight.w400,
  };

  List<TextStyle> _styles(SeedTypography type) => switch (weight) {
    'Medium' => [
      type.t1Medium,
      type.t2Medium,
      type.t3Medium,
      type.t4Medium,
      type.t5Medium,
      type.t6Medium,
      type.t7Medium,
      type.t8Medium,
      type.t9Medium,
      type.t10Medium,
      type.t11Medium,
      type.t12Medium,
      type.t13Medium,
      type.t14Medium,
    ],
    'Bold' => [
      type.t1Bold,
      type.t2Bold,
      type.t3Bold,
      type.t4Bold,
      type.t5Bold,
      type.t6Bold,
      type.t7Bold,
      type.t8Bold,
      type.t9Bold,
      type.t10Bold,
      type.t11Bold,
      type.t12Bold,
      type.t13Bold,
      type.t14Bold,
    ],
    _ => [
      type.t1Regular,
      type.t2Regular,
      type.t3Regular,
      type.t4Regular,
      type.t5Regular,
      type.t6Regular,
      type.t7Regular,
      type.t8Regular,
      type.t9Regular,
      type.t10Regular,
      type.t11Regular,
      type.t12Regular,
      type.t13Regular,
      type.t14Regular,
    ],
  };

  Widget _row(
    String label,
    TextStyle style,
    double baseline, {
    bool isStatic = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 66,
            child: Text(label, style: context.seedTypography.t1Regular),
          ),
          Container(
            width: 3,
            height: baseline,
            decoration: BoxDecoration(
              color: context.seedColor.fg.neutralMuted,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Container(
              color: context.seedColor.bg.neutralWeak,
              child: ClipRect(
                child: Text(
                  '당근 Ag 12',
                  softWrap: false,
                  overflow: TextOverflow.visible,
                  style: style.copyWith(color: context.seedColor.fg.neutral),
                  textScaler: isStatic ? TextScaler.noScaling : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final typo = context.seedTypography;
    final styles = _styles(typo);
    final named = <String, TextStyle>{
      'screenTitle': typo.screenTitle,
      'articleBody': typo.articleBody,
      'articleNote': typo.articleNote,
    };
    return _scroll(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SeedCallout(
            tone: SeedCalloutTone.informative,
            title: '폰트 스케일링 검증',
            description: 'dynamic과 raw px / raw rem은 시스템 글꼴 배율을 따라가고 static만 기준 막대에 고정됩니다. Flutter의 시스템 글꼴 크기를 변경해 비교해 보세요.',
          ),
          const SizedBox(height: 16),
          SeedSegmentedControl<String>(
            value: weight,
            onValueChange: (next) => setState(() => weight = next),
            segments: const [
              SeedSegment(value: 'Regular', label: 'Regular'),
              SeedSegment(value: 'Medium', label: 'Medium'),
              SeedSegment(value: 'Bold', label: 'Bold'),
            ],
          ),
          const SizedBox(height: 20),
          _heading(context, '읽는 법'),
          const Text('세로 막대 = 단계별 기준 line-height를 px로 고정한 자'),
          const Text('dynamic = 시스템 배율을 따르는 SEED TextStyle'),
          const Text('static = 시스템 배율을 적용하지 않은 고정 TextStyle'),
          const Text('raw px, raw rem = 배율이 적용되는 직접 지정 값'),
          const SizedBox(height: 20),
          for (var index = 0; index < _typeSizes.length; index++)
            _section(
              context,
              't${index + 1}   ${_typeSizes[index].toStringAsFixed(0)}px / ${_typeHeights[index].toStringAsFixed(0)}px',
              Column(
                children: [
                  _row('dynamic', styles[index], _typeHeights[index]),
                  _row(
                    'static',
                    styles[index],
                    _typeHeights[index],
                    isStatic: true,
                  ),
                  _row(
                    'raw px',
                    TextStyle(
                      fontSize: _typeSizes[index],
                      height: _typeHeights[index] / _typeSizes[index],
                      fontWeight: _weight,
                    ),
                    _typeHeights[index],
                  ),
                  _row(
                    'raw rem',
                    TextStyle(
                      fontSize: _typeSizes[index],
                      height: _typeHeights[index] / _typeSizes[index],
                      fontWeight: _weight,
                    ),
                    _typeHeights[index],
                  ),
                ],
              ),
            ),
          _heading(context, '이름 있는 텍스트 스타일'),
          _subheading(context, 'static 대응이 없어 항상 스케일링을 따라갑니다.'),
          const SizedBox(height: 8),
          for (final entry in named.entries)
            _section(
              context,
              entry.key,
              Column(
                children: [
                  _row(
                    'dynamic',
                    entry.value,
                    (entry.value.fontSize ?? 16) * (entry.value.height ?? 1.35),
                  ),
                  _row(
                    'raw px',
                    TextStyle(
                      fontSize: entry.value.fontSize,
                      height: entry.value.height,
                      fontWeight: entry.value.fontWeight,
                    ),
                    (entry.value.fontSize ?? 16) * (entry.value.height ?? 1.35),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PartialDarkPage extends StatelessWidget {
  const _PartialDarkPage();

  Widget _modePanel(String label, {SeedThemeData? seedTheme}) {
    Widget body = Builder(
      builder: (context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        color: context.seedColor.bg.layerDefault,
        child: Text(
          label,
          style: context.seedTypography.t4Regular.copyWith(
            color: context.seedColor.fg.neutral,
          ),
        ),
      ),
    );
    if (seedTheme != null) {
      body = SeedTheme(data: seedTheme, child: body);
    }
    return body;
  }

  @override
  Widget build(BuildContext context) => ListView(
    children: [
      _modePanel('This is System Mode'),
      _modePanel('This is Light Only Mode', seedTheme: SeedThemeData.light()),
      _modePanel('This is Dark Only Mode', seedTheme: SeedThemeData.dark()),
    ],
  );
}
