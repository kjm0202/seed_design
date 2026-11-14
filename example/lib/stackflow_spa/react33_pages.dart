import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'spa_types.dart';

Widget? buildReact33Page(
  String activity, {
  required SpaNavigate navigate,
  required VoidCallback goBack,
}) => switch (activity) {
  'ActivitySearchInput' => _SearchDemo(
    openSearchBar: () => navigate('ActivitySearchBar'),
  ),
  'ActivitySearchBar' => SpaOwnScaffold(child: _SearchBarDemo(onClose: goBack)),
  'ActivityAppBarTextButton' => const SpaOwnScaffold(
    child: _AppBarTextButtonDemo(),
  ),
  'ActivitySegmentedTextInput' => const _SegmentedDemo(),
  'ActivityNavigationMenu' => const _NavigationMenuDemo(),
  'ActivityDatePickerTwoWeeks' => const _DatePickerDemo(),
  'ActivityTextAndLoading' => const _TextAndLoadingDemo(),
  'ActivityExtendSafeAreaX' => const _SafeAreaDemo(),
  'ActivityAccordionFieldset' => const _AccordionFieldsetDemo(),
  _ => null,
};

Widget _demoBody(List<Widget> children) => ListView(
  padding: const EdgeInsets.all(16),
  children: [
    for (final (i, child) in children.indexed) ...[
      if (i > 0) const SizedBox(height: 16),
      child,
    ],
  ],
);

class _SearchDemo extends StatefulWidget {
  const _SearchDemo({required this.openSearchBar});

  final VoidCallback openSearchBar;

  @override
  State<_SearchDemo> createState() => _SearchDemoState();
}

class _SearchDemoState extends State<_SearchDemo> {
  String? _submitted;

  @override
  Widget build(BuildContext context) => _demoBody([
    SeedSearchInput(
      placeholder: '검색어 입력',
      onSubmit: (value) => setState(() => _submitted = value),
    ),
    Text(_submitted == null ? '아직 검색하지 않았습니다.' : '검색한 값: $_submitted'),
    SeedButton(label: 'Search Bar 열기', onPressed: widget.openSearchBar),
  ]);
}

class _SearchBarDemo extends StatefulWidget {
  const _SearchBarDemo({required this.onClose});

  final VoidCallback onClose;

  @override
  State<_SearchBarDemo> createState() => _SearchBarDemoState();
}

class _SearchBarDemoState extends State<_SearchBarDemo> {
  String _value = '';
  String _message = '검색어를 입력하고 검색해주세요';

  @override
  Widget build(BuildContext context) {
    final isRoot = ModalRoute.of(context)?.isFirst ?? true;
    return Scaffold(
      appBar: SeedTopNavigation(
        automaticallyImplyLeading: !isRoot,
        // Official search-bar.tsx overrides the AppBar edge rules with inline
        // styles: `<AppBarLeft style={{ paddingRight: 0 }}>` with a back
        // button `marginRight: 0`, and a close text button `marginLeft: 0`.
        // The slot path's cupertino layout has no left padding; the slot's
        // own padding then cancels the buttons' inner -10px overlaps.
        platform: SeedTopNavigationPlatform.cupertino,
        slot: Padding(
          padding: EdgeInsetsDirectional.only(
            start: isRoot ? 0 : SeedDimension.x2_5,
            end: SeedDimension.x2_5,
          ),
          child: Center(
            child: SeedSearchInput(
              value: _value,
              onValueChange: (value) => setState(() => _value = value),
              placeholder: '검색어를 입력해주세요',
              onSubmit: (value) => setState(() => _message = '"$value" 검색'),
            ),
          ),
        ),
        actions: [
          SeedTopNavigationTextButton(
            text: SeedLocalizations.label(context, SeedLabel.close),
            onPressed: isRoot
                ? () => setState(() => _message = '닫기를 눌렀습니다')
                : widget.onClose,
          ),
        ],
      ),
      body: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        child: SafeArea(
          top: false,
          child: Center(
            child: Text(
              _message,
              style: TextStyle(color: context.seedColor.fg.neutralMuted),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppBarTextButtonDemo extends StatefulWidget {
  const _AppBarTextButtonDemo();

  @override
  State<_AppBarTextButtonDemo> createState() => _AppBarTextButtonDemoState();
}

class _AppBarTextButtonDemoState extends State<_AppBarTextButtonDemo> {
  String _lastAction = '없음';

  SeedTopNavigationTextButton _action(String text) =>
      SeedTopNavigationTextButton(
        text: text,
        onPressed: () => setState(() => _lastAction = text),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: SeedTopNavigation(
      titleText: '작성하기',
      leading: _action('취소'),
      actions: [_action('완료')],
    ),
    body: SafeArea(
      top: false,
      child: Center(
        child: Text(
          '마지막 액션: $_lastAction',
          style: TextStyle(color: context.seedColor.fg.neutralMuted),
        ),
      ),
    ),
  );
}

// These registry compositions are showcase-local. They use sample numbers
// only and do not store or display submitted card or resident numbers.
const _separator = SeedSegmentedTextInputSeparator(child: Text('-'));

List<Widget> _cardSegments(Set<int> masked) => [
  for (var i = 0; i < 4; i++) ...[
    if (i > 0) _separator,
    SeedSegmentedTextInputSegment(
      length: 4,
      masked: masked.contains(i),
      placeholder: masked.contains(i) ? null : '0000',
      semanticsLabel: '카드번호 ${4 * i + 1}-${4 * i + 4}번째 자리',
      autofillHints: i == 0 ? const [AutofillHints.creditCardNumber] : const [],
    ),
  ],
];

class _CardNumberField extends StatelessWidget {
  const _CardNumberField({this.maskedDigits = 8, this.suffix})
    : assert(maskedDigits == 4 || maskedDigits == 8);

  final int maskedDigits;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) => SeedField(
    label: '카드번호',
    child: SeedSegmentedTextInput(
      children: [
        ..._cardSegments({for (var i = 4 - maskedDigits ~/ 4; i < 4; i++) i}),
        if (suffix case final suffix?)
          SeedSegmentedTextInputSuffix(child: suffix),
      ],
    ),
  );
}

class _ResidentNumberField extends StatelessWidget {
  const _ResidentNumberField({super.key, this.digits = 7})
    : assert(digits == 6 || digits == 7 || digits == 13);

  final int digits;

  @override
  Widget build(BuildContext context) => SeedField(
    label: '주민등록번호',
    child: SeedSegmentedTextInput(
      children: [
        const SeedSegmentedTextInputSegment(
          length: 6,
          placeholder: '생년월일 6자리',
          semanticsLabel: '생년월일 6자리',
          autofillHints: [AutofillHints.birthday],
          sizing: SeedSegmentedTextInputSizing.fill,
        ),
        _separator,
        if (digits == 6)
          const SeedSegmentedTextInputSegment.staticText(
            staticText: SeedSegmentedTextInputDots(count: 7),
            sizing: SeedSegmentedTextInputSizing.fill,
            align: SeedSegmentedTextInputAlign.center,
          )
        else
          SeedSegmentedTextInputSegment(
            length: digits == 7 ? 1 : 7,
            masked: digits == 13,
            placeholderWidget: digits == 7
                ? const SeedSegmentedTextInputDots(count: 1)
                : null,
            staticSuffix: digits == 7
                ? const SeedSegmentedTextInputDots(count: 6)
                : null,
            semanticsLabel: digits == 7
                ? '주민등록번호 뒷자리 첫 번째 자리'
                : '주민등록번호 뒷자리 7자리',
            sizing: SeedSegmentedTextInputSizing.fill,
            align: SeedSegmentedTextInputAlign.center,
          ),
      ],
    ),
  );
}

class _SegmentedDemo extends StatefulWidget {
  const _SegmentedDemo();

  @override
  State<_SegmentedDemo> createState() => _SegmentedDemoState();
}

class _SegmentedDemoState extends State<_SegmentedDemo> {
  int _digits = 7;
  bool _officialCard = false;

  @override
  Widget build(BuildContext context) => _demoBody([
    const Text('실제 번호 대신 테스트용 숫자를 입력하세요.'),
    if (_officialCard)
      const _CardNumberField(suffix: Icon(Icons.credit_card, size: 16))
    else
      SeedField(
        label: '카드번호 · 가운데 두 칸 가림',
        child: SeedSegmentedTextInput(children: _cardSegments({1, 2})),
      ),
    SeedButton(
      label: _officialCard ? '가운데 가림 보기' : '공식 카드 조합 보기',
      onPressed: () => setState(() => _officialCard = !_officialCard),
    ),
    SeedSegmentedControl<int>(
      value: _digits,
      segments: const [
        SeedSegment(value: 6, label: '6자리'),
        SeedSegment(value: 7, label: '7자리'),
        SeedSegment(value: 13, label: '13자리'),
      ],
      onValueChange: (value) => setState(() => _digits = value),
    ),
    _ResidentNumberField(key: ValueKey(_digits), digits: _digits),
  ]);
}

class _NavigationMenuDemo extends StatefulWidget {
  const _NavigationMenuDemo();

  @override
  State<_NavigationMenuDemo> createState() => _NavigationMenuDemoState();
}

class _NavigationMenuDemoState extends State<_NavigationMenuDemo> {
  String _current = '프로젝트';

  void _select(String label) => setState(() => _current = label);

  @override
  Widget build(BuildContext context) => _demoBody([
    SeedNavigationMenu(
      child: Wrap(
        spacing: 12,
        children: [
          for (final (section, items) in const [
            ('작업', ['프로젝트', '작업 내역']),
            ('설정', ['알림 설정', '사용자 설정']),
          ])
            SeedNavigationMenuRoot(
              value: section,
              trigger: SeedNavigationMenuTrigger(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(section),
                ),
              ),
              content: SeedNavigationMenuContent(
                children: [
                  SeedNavigationMenuGroup(
                    label: section,
                    children: [
                      for (final item in items)
                        SeedNavigationMenuItem(
                          label: item,
                          current: _current == item,
                          onTap: () => _select(item),
                        ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    ),
    Text('선택: $_current'),
    SizedBox(
      height: 210,
      child: Align(
        alignment: AlignmentDirectional.topStart,
        child: SeedSideNavigation(
          defaultCollapsed: true,
          showCollapseButton: true,
          selectedId: _current,
          groups: [
            SeedSideNavGroup(
              items: [
                SeedSideNavItem(
                  id: 'workspace',
                  label: '워크스페이스',
                  icon: Icons.work_outline,
                  subItems: [
                    SeedSideNavSubItem(
                      id: '팀 목록',
                      label: '팀 목록',
                      onTap: () => _select('팀 목록'),
                    ),
                    SeedSideNavSubItem(
                      id: '초대',
                      label: '초대',
                      onTap: () => _select('초대'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  ]);
}

class _DatePickerDemo extends StatefulWidget {
  const _DatePickerDemo();

  @override
  State<_DatePickerDemo> createState() => _DatePickerDemoState();
}

class _DatePickerDemoState extends State<_DatePickerDemo> {
  DateTime? _selected;

  @override
  Widget build(BuildContext context) => _demoBody([
    Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 358),
        child: SeedDatePicker(
          visibleRange: SeedDatePickerLayout.twoWeeks,
          today: DateTime(2026, 12, 30),
          defaultViewDate: DateTime(2026, 12, 30),
          onValueChange: (value) => setState(() => _selected = value),
        ),
      ),
    ),
    Text(
      _selected == null
          ? '날짜를 선택하세요.'
          : '선택: ${_selected!.year}-${_selected!.month}-${_selected!.day}',
    ),
  ]);
}

class _TextAndLoadingDemo extends StatefulWidget {
  const _TextAndLoadingDemo();

  @override
  State<_TextAndLoadingDemo> createState() => _TextAndLoadingDemoState();
}

class _TextAndLoadingDemoState extends State<_TextAndLoadingDemo> {
  bool _bold = false;
  bool _loading = false;
  bool _large = false;

  @override
  Widget build(BuildContext context) {
    final typography = context.seedTypography;
    return _demoBody([
      Row(
        children: [
          SeedConsistentWidth(
            '텍스트 너비',
            style: _bold ? typography.t5Bold : typography.t5Regular,
          ),
          const SizedBox(width: 8),
          const Text('|'),
        ],
      ),
      SeedButton(
        label: '굵기 전환',
        onPressed: () => setState(() => _bold = !_bold),
      ),
      SeedLoadingIndicator(
        loading: _loading,
        semanticsLabel: '로딩 중',
        child: const SizedBox(
          height: 48,
          child: Center(child: Text('로딩 대상 콘텐츠')),
        ),
      ),
      SeedButton(
        label: _loading ? '로딩 종료' : '로딩 시작',
        onPressed: () => setState(() => _loading = !_loading),
      ),
      MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(_large ? 1.8 : 1)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('시스템 배율 적용', style: typography.t5Regular),
            SeedStaticTextScope(
              child: Text('고정 타이포그래피', style: typography.t5StaticRegular),
            ),
          ],
        ),
      ),
      SeedButton(
        label: '글자 배율 전환',
        onPressed: () => setState(() => _large = !_large),
      ),
    ]);
  }
}

class _SafeAreaDemo extends StatefulWidget {
  const _SafeAreaDemo();

  @override
  State<_SafeAreaDemo> createState() => _SafeAreaDemoState();
}

class _SafeAreaDemoState extends State<_SafeAreaDemo> {
  bool _extend = true;
  int _tab = 0;
  List<SeedAttachmentItem> _items = [
    for (var i = 1; i <= 8; i++)
      SeedAttachmentItem(
        id: '$i',
        name: 'sample-$i.pdf',
        type: SeedAttachmentType.file,
      ),
  ];

  @override
  Widget build(BuildContext context) {
    const insets = EdgeInsets.only(left: 36, right: 24);
    final media = MediaQuery.of(context);
    final padding = media.padding.copyWith(
      left: insets.left,
      right: insets.right,
    );
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SeedButton(
            label: _extend ? '가로 확장 끄기' : '가로 확장 켜기',
            onPressed: () => setState(() => _extend = !_extend),
          ),
        ),
        ColoredBox(
          color: context.seedColor.bg.layerBasement,
          child: Padding(
            padding: insets,
            child: MediaQuery(
              // Keep the simulated view inset visible inside the padded area.
              data: media.copyWith(viewPadding: padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SeedPageBanner(
                    title: '가로 안전 영역 미리보기',
                    extendSafeAreaX: _extend,
                  ),
                  SeedTabs(
                    extendSafeAreaX: _extend,
                    fill: false,
                    selectedIndex: _tab,
                    onTabSelected: (index) => setState(() => _tab = index),
                    items: [
                      for (var i = 1; i <= 8; i++) SeedTabItem(label: '탭 $i'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SeedAttachmentInput(
                    items: _items,
                    showTrigger: false,
                    extendSafeAreaX: _extend,
                    onReorder: (from, to) => setState(() {
                      final copy = _items.toList();
                      copy.insert(to > from ? to - 1 : to, copy.removeAt(from));
                      _items = copy;
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AccordionFieldsetDemo extends StatefulWidget {
  const _AccordionFieldsetDemo();

  @override
  State<_AccordionFieldsetDemo> createState() => _AccordionFieldsetDemoState();
}

class _AccordionFieldsetDemoState extends State<_AccordionFieldsetDemo> {
  bool _invalid = true;

  @override
  Widget build(BuildContext context) => _demoBody([
    const SeedAccordion(
      items: [
        SeedAccordionItem(
          title: '배송 정보',
          titleWidget: Text('배송 정보와 일정'),
          descriptionWidget: Text('자세한 안내'),
          suffixIcon: Icon(Icons.expand_more),
          content: Text('배송 예정일은 주문 화면에서 확인할 수 있습니다.'),
        ),
      ],
    ),
    SeedFieldset(
      label: '연락처',
      description: '받을 수 있는 연락처를 입력하세요.',
      errorMessage: _invalid ? '연락처를 확인해 주세요.' : null,
      child: const SeedTextInput(semanticsLabel: '연락처 입력'),
    ),
    SeedButton(
      label: _invalid ? '오류 지우기' : '오류 표시',
      onPressed: () => setState(() => _invalid = !_invalid),
    ),
  ]);
}
