import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:mime/mime.dart';
import 'package:material_ui/material_ui.dart' as mui;
import 'package:seed_design/seed_design.dart';

import 'spa_types.dart';

/// Returns the body for a form activity. The SPA shell owns its navigation bar.
Widget? buildFormsPage(
  String activity,
  BuildContext context, {
  required SpaNavigate navigate,
  required VoidCallback goBack,
  Object? arguments,
}) {
  switch (activity) {
    case 'ActivitySwitch':
    case 'ActivityCheckbox':
    case 'ActivityRadioGroup':
      return _AnalyzerPage(key: ValueKey(activity), activity: activity);
    case 'ActivityQuantityPicker':
      return const _QuantityPage();
    case 'ActivitySegmentedControl':
      return const _SegmentsPage();
    case 'ActivitySelect':
      return const _SelectPage();
    case 'ActivityTimePicker':
      return const _TimePage();
    case 'ActivityWheelPicker':
      return _WheelPage(goBack: goBack);
    case 'ActivityAttachmentField':
      return const _AttachmentPage(display: false);
    case 'ActivityAttachmentDisplayField':
      return const _AttachmentPage(display: true);
    case 'ActivityForm':
      return const _FormPage();
    default:
      return null;
  }
}

Widget _scroll(List<Widget> children) => SingleChildScrollView(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final child in children) ...[child, const SizedBox(height: 24)],
    ],
  ),
);

Widget _section(String title, String description, Widget content) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      title,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
    ),
    const SizedBox(height: 4),
    Text(description, style: const TextStyle(color: Colors.grey, fontSize: 13)),
    const SizedBox(height: 12),
    content,
  ],
);

Widget _wrap(List<Widget> children) => Wrap(
  spacing: 12,
  runSpacing: 12,
  crossAxisAlignment: WrapCrossAlignment.center,
  children: children,
);

const _switchLabel = '새로운 메시지가 도착할 때마다 푸시 알림을 받을 수 있습니다. 언제든지 변경할 수 있어요.';
const _checkboxLabel = '개인정보 처리방침과 서비스 이용약관을 읽고 이해했으며, 이에 동의합니다.';
const _radioLabels = [
  '이메일로 알림 받기 — 업데이트와 프로모션 소식을 이메일로 받아보세요. 수신 거부는 언제든 가능합니다.',
  '문자 메시지로 알림 받기 — 긴급한 알림과 인증 코드를 문자로 받아보세요. 통신사 요금이 부과될 수 있습니다.',
  '푸시 알림으로 받기 — 앱 푸시 알림을 통해 실시간으로 소식을 받아보세요. 기기 설정에서 관리 가능합니다.',
];

class _AnalyzerPage extends StatefulWidget {
  const _AnalyzerPage({super.key, required this.activity});
  final String activity;
  @override
  State<_AnalyzerPage> createState() => _AnalyzerPageState();
}

class _AnalyzerPageState extends State<_AnalyzerPage> {
  late final Map<String, List<String>> variantsMap;
  late final Map<String, String> selections;
  bool showGrid = false;

  @override
  void initState() {
    super.initState();
    final isSwitch = widget.activity == 'ActivitySwitch';
    final isCheckbox = widget.activity == 'ActivityCheckbox';
    variantsMap = {
      'size': isSwitch ? ['16', '24', '32'] : ['medium', 'large'],
      if (!isSwitch) 'weight': ['regular', 'bold'],
      'tone': ['neutral', 'brand'],
      if (isSwitch || isCheckbox) 'checked': ['false', 'true'],
      'disabled': ['false', 'true'],
    };
    selections = {
      'size': isSwitch ? '32' : 'medium',
      if (!isSwitch) 'weight': 'regular',
      'tone': 'brand',
      if (isSwitch || isCheckbox) 'checked': 'false',
      'disabled': 'false',
    };
  }

  /// Matches the Cartesian product in React's getVariantCombination().
  List<Map<String, String>> get combinations {
    var result = <Map<String, String>>[{}];
    for (final entry in variantsMap.entries) {
      final choices = selections[entry.key] == 'ALL'
          ? entry.value
          : [selections[entry.key]!];
      result = [
        for (final existing in result)
          for (final choice in choices) {...existing, entry.key: choice},
      ];
    }
    return result;
  }

  /// React uses the count of the last ALL dimension as its column count.
  int get gridColumns {
    for (final entry in variantsMap.entries.toList().reversed) {
      if (selections[entry.key] == 'ALL') return entry.value.length;
    }
    return 1;
  }

  Widget renderVariant(Map<String, String> variant) {
    final isSwitch = widget.activity == 'ActivitySwitch';
    final isCheckbox = widget.activity == 'ActivityCheckbox';
    final size = variant['size']!;
    final tone = variant['tone'] == 'brand'
        ? SeedControlTone.brand
        : SeedControlTone.neutral;
    final weight = variant['weight'] == 'bold'
        ? SeedLabelWeight.bold
        : SeedLabelWeight.regular;
    final disabled = variant['disabled'] == 'true';
    final checked = variant['checked'] == 'true';
    // Each combination owns its uncontrolled state independently, like the
    // React key={JSON.stringify(variants)} on each rendered component.
    final key = ValueKey(
      variant.entries.map((entry) => '${entry.key}=${entry.value}').join('|'),
    );
    if (isSwitch) {
      return SeedSwitch(
        key: key,
        label: _switchLabel,
        size: switch (size) {
          '16' => SeedSwitchSize.size16,
          '24' => SeedSwitchSize.size24,
          _ => SeedSwitchSize.size32,
        },
        tone: tone,
        defaultChecked: checked,
        enabled: !disabled,
      );
    }
    if (isCheckbox) {
      return SeedCheckbox(
        key: key,
        label: _checkboxLabel,
        size: size == 'large'
            ? SeedCheckboxSize.large
            : SeedCheckboxSize.medium,
        weight: weight,
        tone: tone,
        defaultChecked: checked,
        enabled: !disabled,
      );
    }
    return SeedRadioGroup<String>(
      key: key,
      defaultValue: 'a',
      enabled: !disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < 3; i++) ...[
            SeedRadio<String>(
              value: ['a', 'b', 'c'][i],
              label: _radioLabels[i],
              size: size == 'large'
                  ? SeedRadioSize.large
                  : SeedRadioSize.medium,
              weight: weight,
              tone: tone,
              enabled: !disabled,
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final variants = combinations;
    final columns = gridColumns;
    final cellWidth = widget.activity == 'ActivityRadioGroup' ? 350.0 : 310.0;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: CustomPaint(
                painter: showGrid ? const _AnalyzerGridPainter() : null,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (
                        var start = 0;
                        start < variants.length;
                        start += columns
                      )
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (
                              var index = start;
                              index < min(start + columns, variants.length);
                              index++
                            )
                              SizedBox(
                                width: cellWidth,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    right: 16,
                                    bottom: 16,
                                  ),
                                  child: renderVariant(variants[index]),
                                ),
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
        const Divider(height: 1),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 300),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _controlRow(
                  '그리드 표시',
                  SeedSwitch(
                    size: SeedSwitchSize.size24,
                    checked: showGrid,
                    onCheckedChange: (checked) =>
                        setState(() => showGrid = checked),
                  ),
                ),
                for (final entry in variantsMap.entries)
                  _controlRow(
                    entry.key,
                    DropdownButton<String>(
                      key: ValueKey(entry.key),
                      value: selections[entry.key],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selections[entry.key] = value);
                        }
                      },
                      items: [
                        for (final value in [...entry.value, 'ALL'])
                          DropdownMenuItem<String>(
                            value: value,
                            child: Text(value == 'ALL' ? 'All' : value),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _controlRow(String title, Widget control) => Container(
    constraints: const BoxConstraints(minHeight: 52),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        control,
      ],
    ),
  );
}

/// Matches the 16px / 64px checker grid in ComponentShowcase.css.ts.
class _AnalyzerGridPainter extends CustomPainter {
  const _AnalyzerGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    for (var x = 16.0; x < size.width; x += 16) {
      final bold = x % 64 == 16;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        Paint()..color = Colors.grey.withValues(alpha: bold ? 0.28 : 0.12),
      );
    }
    for (var y = 16.0; y < size.height; y += 16) {
      final bold = y % 64 == 16;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        Paint()..color = Colors.grey.withValues(alpha: bold ? 0.28 : 0.12),
      );
    }
  }

  @override
  bool shouldRepaint(_AnalyzerGridPainter oldDelegate) => false;
}

class _QuantityPage extends StatefulWidget {
  const _QuantityPage();
  @override
  State<_QuantityPage> createState() => _QuantityPageState();
}

class _QuantityPageState extends State<_QuantityPage> {
  int controlled = 2;
  int removable = 1;
  int fieldValue = 10;
  int formValue = 2;
  int? submitted;
  bool removed = false;
  bool loading = false;

  SeedQuantityPicker qty({
    int? value,
    int defaultValue = 2,
    int min = 1,
    int max = 99,
    int step = 1,
    ValueChanged<int>? onChanged,
    bool removable = false,
    VoidCallback? onRemove,
    bool loading = false,
    bool incrementLoading = false,
    bool disabled = false,
    bool readOnly = false,
    bool invalid = false,
  }) => SeedQuantityPicker(
    value: value,
    defaultValue: defaultValue,
    min: min,
    max: max,
    step: step,
    onValueChange: onChanged,
    removable: removable,
    onRemove: onRemove,
    loading: loading,
    incrementLoading: incrementLoading,
    enabled: !disabled,
    readOnly: readOnly,
    hasError: invalid,
    valueFormatter: (value) => '$value개',
  );

  @override
  Widget build(BuildContext context) => _scroll([
    _section(
      '범위 경계와 자릿수',
      '최솟값·중간값·최댓값에서 버튼 상태와 표시 너비를 확인합니다.',
      _wrap([
        qty(min: 1, max: 999, defaultValue: 1),
        qty(min: 1, max: 999, defaultValue: 10),
        qty(min: 1, max: 999, defaultValue: 999),
      ]),
    ),
    _section(
      '제어 상태와 step',
      '외부 상태와 5개 단위 증감을 확인합니다.',
      _wrap([
        qty(
          value: controlled,
          step: 5,
          onChanged: (value) => setState(() => controlled = value),
        ),
        Text('현재 수량: $controlled개'),
      ]),
    ),
    _section(
      'Removable',
      '최솟값에서 감소 버튼이 삭제 버튼으로 전환됩니다.',
      removed
          ? _wrap([
              const Text('상품을 삭제했습니다.'),
              SeedButton(
                label: '다시 추가',
                variant: SeedButtonVariant.neutralWeak,
                onPressed: () => setState(() {
                  removed = false;
                  removable = 1;
                }),
              ),
            ])
          : qty(
              value: removable,
              removable: true,
              onChanged: (value) => setState(() => removable = value),
              onRemove: () => setState(() => removed = true),
            ),
    ),
    _section(
      'Loading',
      '전체 버튼과 증가 버튼의 로딩 상태를 각각 확인합니다.',
      _wrap([
        SeedButton(
          label: loading ? '로딩 해제' : '로딩 시작',
          variant: SeedButtonVariant.neutralWeak,
          onPressed: () => setState(() => loading = !loading),
        ),
        qty(loading: loading),
        qty(incrementLoading: loading),
      ]),
    ),
    _section(
      '상태',
      'disabled, readOnly, invalid 상태를 비교합니다.',
      _wrap([qty(disabled: true), qty(readOnly: true), qty(invalid: true)]),
    ),
    _section(
      'Field 통합',
      '11개를 선택하면 오류가 나타납니다.',
      SeedField(
        label: '구매 수량',
        required: true,
        isInvalid: fieldValue == 11,
        errorMessage: fieldValue == 11 ? '11개는 구매할 수 없어요.' : null,
        helperText: fieldValue == 11 ? null : '11개를 제외한 수량을 선택할 수 있습니다.',
        child: qty(
          value: fieldValue,
          invalid: fieldValue == 11,
          onChanged: (value) => setState(() => fieldValue = value),
        ),
      ),
    ),
    _section(
      'Form',
      '현재 수량을 제출하면 아래에 표시합니다.',
      _wrap([
        qty(
          value: formValue,
          onChanged: (value) => setState(() => formValue = value),
        ),
        SeedButton(
          label: '제출',
          variant: SeedButtonVariant.neutralSolid,
          onPressed: () => setState(() => submitted = formValue),
        ),
        if (submitted != null) Text('제출한 수량: $submitted개'),
      ]),
    ),
  ]);
}

class _SegmentsPage extends StatelessWidget {
  const _SegmentsPage();
  static const items = [
    SeedSegment(value: '1', label: '가격 높은 순'),
    SeedSegment(value: '2', label: '할인율 높은 순'),
    SeedSegment(value: '3', label: '인기 많은 순'),
  ];

  @override
  Widget build(BuildContext context) => _scroll([
    Column(
      children: [
        SeedSegmentedControl<String>(segments: items, defaultValue: '1'),
        const SizedBox(height: 16),
        SeedButton(
          label: 'Test',
          variant: SeedButtonVariant.neutralSolid,
          onPressed: () {},
        ),
      ],
    ),
    const SizedBox(height: 16),
    Row(
      children: [
        Expanded(
          child: SeedSegmentedControl<String>(
            segments: items,
            defaultValue: '1',
          ),
        ),
        const SizedBox(width: 16),
        SeedButton(
          label: 'Test',
          variant: SeedButtonVariant.neutralSolid,
          onPressed: () {},
        ),
      ],
    ),
  ]);
}

const _fruits = [
  SeedSelectItem<String>(value: 'apple', label: '사과'),
  SeedSelectItem<String>(value: 'banana', label: '바나나'),
  SeedSelectItem<String>(value: 'cherry', label: '체리'),
];
const _fruitGroups = [SeedSelectGroup<String>(items: _fruits)];

class _SelectPage extends StatefulWidget {
  const _SelectPage();
  @override
  State<_SelectPage> createState() => _SelectPageState();
}

class _SelectPageState extends State<_SelectPage> {
  List<String> value = ['apple'];
  List<String> multiValue = ['apple', 'banana'];
  String? submitted;
  String? formFruit;
  final formKey = GlobalKey<FormState>();

  Widget _selectRow(List<Widget> children) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (var index = 0; index < children.length; index++) ...[
        if (index > 0) const SizedBox(width: 12),
        Flexible(child: children[index]),
      ],
    ],
  );

  Widget select({
    List<SeedSelectGroup<String>> groups = _fruitGroups,
    List<String>? initial,
    List<String>? selected,
    ValueChanged<List<String>>? onValueChange,
    SeedInputButtonSize size = SeedInputButtonSize.medium,
    String? label,
    String? description,
    String? errorMessage,
    bool enabled = true,
    bool readOnly = false,
    bool multiple = false,
    String placeholder = '과일 선택',
    Widget? prefix,
    double menuHeight = 480,
    String Function(List<SeedSelectItem<String>>)? format,
  }) => SizedBox(
    width: 200,
    child: SeedSelect<String>(
      groups: groups,
      defaultValue: initial,
      value: selected,
      onValueChange: onValueChange,
      size: size,
      multiple: multiple,
      enabled: enabled,
      readOnly: readOnly,
      label: label,
      description: description,
      errorMessage: errorMessage,
      isError: errorMessage != null,
      placeholder: placeholder,
      prefixIcon: prefix,
      maxMenuHeight: menuHeight,
      formatValue: format,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final deliveries = [
      const SeedSelectGroup<String>(
        label: '국내',
        items: [
          SeedSelectItem(
            value: 'standard',
            label: '일반 배송',
            description: '3-5일 소요',
          ),
          SeedSelectItem(
            value: 'express',
            label: '빠른 배송',
            description: '1-2일 소요',
          ),
        ],
      ),
      const SeedSelectGroup<String>(
        label: '기타',
        items: [
          SeedSelectItem(value: 'pickup', label: '직접 수령'),
          SeedSelectItem(
            value: 'unavailable',
            label: '해외 배송',
            description: '현재 불가',
            enabled: false,
          ),
        ],
      ),
    ];
    final many = [
      SeedSelectGroup<String>(
        items: [
          for (var i = 1; i <= 30; i++)
            SeedSelectItem(value: 'track-$i', label: 'Track $i'),
        ],
      ),
    ];
    final english = [
      const SeedSelectGroup<String>(
        items: [
          SeedSelectItem(value: 'apple', label: 'Apple'),
          SeedSelectItem(value: 'banana', label: 'Banana'),
          SeedSelectItem(value: 'cherry', label: 'Cherry'),
          SeedSelectItem(value: 'durian', label: 'Durian'),
          SeedSelectItem(value: 'elderberry', label: 'Elderberry'),
          SeedSelectItem(value: 'fig', label: 'Fig'),
          SeedSelectItem(value: 'grape', label: 'Grape'),
          SeedSelectItem(value: 'honeydew', label: 'Honeydew'),
          SeedSelectItem(value: 'kiwi', label: 'Kiwi'),
          SeedSelectItem(value: 'lemon', label: 'Lemon'),
        ],
      ),
    ];
    return _scroll([
      _section(
        'Size',
        'large / medium',
        _selectRow([
          select(size: SeedInputButtonSize.medium, initial: const ['apple']),
          select(size: SeedInputButtonSize.small, initial: const ['apple']),
        ]),
      ),
      _section(
        'With Field',
        'Label / Description / Error',
        _selectRow([
          select(
            label: '과일',
            description: '가장 좋아하는 과일을 골라주세요',
            initial: const ['apple'],
          ),
          select(
            label: '배송 방법',
            description: '배송 옵션을 선택하세요',
            errorMessage: '배송 방법을 선택해야 해요',
            placeholder: '배송 방법',
            groups: deliveries,
          ),
        ]),
      ),
      _section(
        'Groups & Disabled item',
        '설명·그룹·비활성 항목',
        select(
          groups: deliveries,
          initial: const ['standard'],
          placeholder: '배송 방법',
        ),
      ),
      _section(
        'Disabled / ReadOnly',
        '상태 비교',
        _selectRow([
          select(label: '비활성', enabled: false, initial: const ['apple']),
          select(label: '읽기 전용', readOnly: true, initial: const ['banana']),
        ]),
      ),
      _section(
        'Controlled + onValueChange',
        '외부 상태 동기화',
        _selectRow([
          select(
            selected: value,
            onValueChange: (next) => setState(() => value = next),
          ),
          Text('값: ${value.isEmpty ? '없음' : value.join(', ')}'),
        ]),
      ),
      _section(
        'Prefix Icon 우선순위',
        '선택 항목의 아이콘이 기본 아이콘보다 우선합니다.',
        select(
          prefix: const Icon(Icons.star_outline),
          groups: const [
            SeedSelectGroup(
              items: [
                SeedSelectItem(
                  value: 'apple',
                  label: '사과',
                  prefixIcon: Icon(Icons.favorite_outline),
                ),
                SeedSelectItem(
                  value: 'banana',
                  label: '바나나',
                  prefixIcon: Icon(Icons.diamond_outlined),
                ),
                SeedSelectItem(value: 'cherry', label: '체리'),
              ],
            ),
          ],
        ),
      ),
      _section(
        'Multiple × Prefix Icon',
        '다중 선택에서 기본 아이콘을 확인합니다.',
        select(
          multiple: true,
          initial: const ['apple'],
          prefix: const Icon(Icons.star_outline),
          groups: const [
            SeedSelectGroup(
              items: [
                SeedSelectItem(
                  value: 'apple',
                  label: '사과',
                  prefixIcon: Icon(Icons.favorite_outline),
                ),
                SeedSelectItem(
                  value: 'banana',
                  label: '바나나',
                  prefixIcon: Icon(Icons.diamond_outlined),
                ),
                SeedSelectItem(
                  value: 'cherry',
                  label: '체리',
                  prefixIcon: Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
      _section(
        'Multiple',
        '두 Select가 동일한 선택 값을 공유합니다.',
        _selectRow([
          select(
            multiple: true,
            selected: multiValue,
            onValueChange: (next) => setState(() => multiValue = next),
          ),
          select(
            multiple: true,
            selected: multiValue,
            onValueChange: (next) => setState(() => multiValue = next),
            format: (items) => '${items.length}개 선택됨',
          ),
        ]),
      ),
      _section(
        'Many Items (Scroll)',
        '30개 트랙 중 선택',
        select(groups: many, placeholder: '트랙 선택'),
      ),
      _section(
        'Max Height',
        '160px 높이 제한',
        select(groups: many, menuHeight: 160, placeholder: '트랙 선택'),
      ),
      _section('Typeahead', '영문 목록에서 키보드 탐색', select(groups: english)),
      _section(
        'Form Integration',
        '값을 선택한 뒤 제출합니다.',
        Form(
          key: formKey,
          child: _selectRow([
            FormField<String>(
              validator: (_) => formFruit == null ? '과일을 선택해주세요.' : null,
              builder: (field) => select(
                errorMessage: field.errorText,
                selected: formFruit == null ? const [] : [formFruit!],
                onValueChange: (next) => setState(() {
                  formFruit = next.firstOrNull;
                  field.didChange(formFruit);
                }),
              ),
            ),
            SeedButton(
              label: '제출',
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  setState(() => submitted = formFruit);
                }
              },
            ),
            if (submitted != null) Text('제출됨: $submitted'),
          ]),
        ),
      ),
      _section(
        'Select in BottomSheet',
        '시트 안에서 Select 팝업을 엽니다.',
        SeedButton(
          label: 'BottomSheet 열기',
          onPressed: () {
            showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (context) => SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Select in BottomSheet'),
                      const SizedBox(height: 12),
                      const Text('BottomSheet 내부에서 Select를 열 수 있습니다.'),
                      const SizedBox(height: 12),
                      select(initial: const ['apple']),
                      const SizedBox(height: 140),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ]);
  }
}

class _TimePage extends StatefulWidget {
  const _TimePage();
  @override
  State<_TimePage> createState() => _TimePageState();
}

class _TimePageState extends State<_TimePage> {
  mui.TimeOfDay time = const mui.TimeOfDay(hour: 13, minute: 10);
  @override
  Widget build(BuildContext context) => _scroll([
    Center(
      child: Column(
        children: [
          SeedTimePicker(
            value: time,
            minuteStep: 10,
            semanticsLabel: '약속 시간',
            onValueChange: (next) => setState(() => time = next),
          ),
          const SizedBox(height: 16),
          Text(
            '선택한 시간: ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
          ),
        ],
      ),
    ),
  ]);
}

class _WheelPage extends StatefulWidget {
  const _WheelPage({required this.goBack});
  final VoidCallback goBack;
  @override
  State<_WheelPage> createState() => _WheelPageState();
}

class _WheelPageState extends State<_WheelPage> {
  bool sheetOpened = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) openSheet();
    });
  }

  Future<void> openSheet() async {
    if (sheetOpened) return;
    sheetOpened = true;
    await showSeedBottomSheet<void>(
      context: context,
      child: const _WheelSheet(),
    );
    if (mounted) widget.goBack();
  }

  @override
  Widget build(BuildContext context) => Center(
    child: SeedButton(label: '날짜 선택', onPressed: openSheet),
  );
}

/// The React activity is a sheet route; Flutter's page route opens a matching
/// SEED sheet on its first frame and pops the page when the sheet closes.
class _WheelSheet extends StatefulWidget {
  const _WheelSheet();

  @override
  State<_WheelSheet> createState() => _WheelSheetState();
}

class _WheelSheetState extends State<_WheelSheet> {
  int year = 2026;
  int month = 8;
  int day = 20;
  int get lastDay => DateUtils.getDaysInMonth(year, month);

  void updateYear(int value) => setState(() {
    year = value;
    day = min(day, lastDay);
  });
  void updateMonth(int value) => setState(() {
    month = value;
    day = min(day, lastDay);
  });
  void nextDay() => setState(() => day = day % lastDay + 1);

  @override
  Widget build(BuildContext context) => SeedBottomSheet(
    title: '날짜 선택',
    showHandle: true,
    content: Center(
      child: SizedBox(
        width: 360,
        child: SeedWheelPicker(
          semanticsLabel: '날짜 선택',
          columns: [
            SeedWheelColumn.value<int>(
              items: [for (var y = 2020; y <= 2030; y++) y],
              value: year,
              semanticsLabel: '연도',
              onValueChange: (value, details) => updateYear(value),
              itemBuilder: (_, item, selected) => Center(child: Text('$item년')),
            ),
            SeedWheelColumn.value<int>(
              items: [for (var m = 1; m <= 12; m++) m],
              value: month,
              loop: true,
              semanticsLabel: '월',
              onValueChange: (value, details) => updateMonth(value),
              itemBuilder: (_, item, selected) => Center(child: Text('$item월')),
            ),
            SeedWheelColumn.value<int>(
              items: [for (var d = 1; d <= lastDay; d++) d],
              value: day,
              loop: true,
              semanticsLabel: '일',
              onValueChange: (value, details) => setState(() => day = value),
              itemBuilder: (_, item, selected) => Center(child: Text('$item일')),
            ),
          ],
        ),
      ),
    ),
    footer: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$year년 $month월 $day일'),
          const SizedBox(height: 12),
          SeedButton(
            label: '다음 날로 변경',
            variant: SeedButtonVariant.neutralWeak,
            size: SeedButtonSize.large,
            isFullWidth: true,
            onPressed: nextDay,
          ),
          const SizedBox(height: 12),
          SeedButton(
            label: '완료',
            variant: SeedButtonVariant.neutralSolid,
            size: SeedButtonSize.large,
            isFullWidth: true,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    ),
  );
}

class _AttachmentPage extends StatelessWidget {
  const _AttachmentPage({required this.display});
  final bool display;

  @override
  Widget build(BuildContext context) => _scroll(
    display
        ? const [
            _AttachmentDemo(
              title: 'AttachmentDisplay',
              description: '트리거를 누르면 외부 미디어 피커와 업로드를 시뮬레이션합니다.',
              display: true,
            ),
            _AttachmentDemo(
              title: 'AttachmentDisplayReorderable',
              description: '항목을 드래그해서 순서를 변경합니다.',
              display: true,
              reorderable: true,
            ),
            _AttachmentDemo(
              title: 'Customizing Items (대표사진 배지)',
              description: '첫 번째 항목이 대표 사진으로 표시됩니다.',
              display: true,
              initialCount: 2,
              featured: true,
            ),
            _AttachmentDemo(
              title: 'Disabled',
              description: '트리거는 비활성화되지만 항목을 제거할 수 있습니다.',
              display: true,
              initialCount: 2,
              enabled: false,
            ),
            _AttachmentDemo(
              title: 'Read Only',
              description: '추가·제거·순서 변경이 불가능합니다.',
              display: true,
              initialCount: 3,
              readOnly: true,
            ),
            _AttachmentDemo(
              title: 'Field Integration',
              description: '필드 설명 및 오류 문구 표시',
              display: true,
              errorMessage: '사진을 1장 이상 등록해 주세요.',
            ),
          ]
        : const [
            _AttachmentDemo(
              title: 'AttachmentInput (image/*)',
              description: '사진을 추가하면 업로드 상태가 변합니다. 최대 5개.',
              imagesOnly: true,
            ),
            _AttachmentDemo(
              title: 'AttachmentInput (all files)',
              description: '모든 파일 형식의 업로드 상태를 시뮬레이션합니다.',
            ),
            _AttachmentDemo(
              title: 'AttachmentDropzone (image/*)',
              description: '드롭존 트리거로 이미지 항목을 추가합니다.',
              imagesOnly: true,
              dropzone: true,
            ),
            _AttachmentDemo(
              title: 'AttachmentDropzone (all files)',
              description: '드롭존 트리거로 파일 항목을 추가합니다.',
              dropzone: true,
            ),
            _AttachmentDemo(
              title: 'AttachmentInputReorderable (image/*)',
              description: '이미지를 추가하고 드래그해 정렬합니다.',
              imagesOnly: true,
              reorderable: true,
            ),
            _AttachmentDemo(
              title: 'AttachmentInputReorderable (all files)',
              description: '모든 파일 형식에서 순서 변경을 확인합니다.',
              reorderable: true,
            ),
            _AttachmentDemo(
              title: 'AttachmentDropzoneReorderable (image/*)',
              description: '드롭존과 순서 변경',
              imagesOnly: true,
              dropzone: true,
              reorderable: true,
            ),
            _AttachmentDemo(
              title: 'AttachmentDropzoneReorderable (all files)',
              description: '드롭존과 순서 변경',
              dropzone: true,
              reorderable: true,
            ),
          ],
  );
}

/// The public attachment widget accepts UI entries, not native File objects.
/// File input selects native files; the display demos simulate media picking.
class _AttachmentDemo extends StatefulWidget {
  const _AttachmentDemo({
    required this.title,
    required this.description,
    this.display = false,
    this.imagesOnly = false,
    this.dropzone = false,
    this.reorderable = false,
    this.enabled = true,
    this.readOnly = false,
    this.initialCount = 0,
    this.featured = false,
    this.maxCount = 5,
    this.errorMessage,
    this.onEntriesChanged,
  });

  final String title;
  final String description;
  final bool display;
  final bool imagesOnly;
  final bool dropzone;
  final bool reorderable;
  final bool enabled;
  final bool readOnly;
  final int initialCount;
  final bool featured;
  final int maxCount;
  final String? errorMessage;
  final ValueChanged<List<SeedAttachmentItem>>? onEntriesChanged;

  @override
  State<_AttachmentDemo> createState() => _AttachmentDemoState();
}

class _AttachmentDemoState extends State<_AttachmentDemo> {
  late final SeedAttachmentController controller;
  final Random random = Random();
  final List<Timer> timers = [];
  int counter = 0;
  bool picking = false;

  SeedAttachmentItem newItem({bool completed = false}) {
    counter++;
    final id = '${widget.title.replaceAll(' ', '-')}-$counter';
    return SeedAttachmentItem(
      id: id,
      name: widget.imagesOnly || widget.display
          ? 'image_$counter.jpg'
          : 'file_$counter.pdf',
      sizeText: '1.2 MB',
      type: widget.imagesOnly || widget.display
          ? SeedAttachmentType.image
          : SeedAttachmentType.file,
      thumbnailUrl: widget.imagesOnly || widget.display
          ? 'https://picsum.photos/seed/${Uri.encodeComponent(id)}/200/200'
          : null,
      status: completed
          ? SeedAttachmentStatus.success
          : SeedAttachmentStatus.uploading,
      progress: completed ? 100 : 0,
      isRepresentative: widget.featured && counter == 1,
    );
  }

  @override
  void initState() {
    super.initState();
    final initial = [
      for (var i = 0; i < widget.initialCount; i++) newItem(completed: true),
    ];
    controller = SeedAttachmentController(
      items: initial,
      maxCount: widget.maxCount,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
    );
    controller.addListener(changed);
  }

  void changed() {
    if (widget.featured) {
      controller.replaceItems([
        for (var index = 0; index < controller.items.length; index++)
          controller.items[index].copyWith(isRepresentative: index == 0),
      ], notify: false);
    }
    widget.onEntriesChanged?.call(controller.items);
  }

  Future<void> pickFiles() async {
    if (picking || !controller.canAdd) return;
    picking = true;
    try {
      final files = await openFiles(
        acceptedTypeGroups: widget.imagesOnly
            ? const [
                XTypeGroup(
                  label: 'Images',
                  extensions: [
                    'jpg',
                    'jpeg',
                    'png',
                    'gif',
                    'webp',
                    'bmp',
                    'heic',
                    'avif',
                  ],
                  mimeTypes: ['image/*'],
                  uniformTypeIdentifiers: ['public.image'],
                  webWildCards: ['image/*'],
                ),
              ]
            : const [],
      );
      await receiveFiles(files);
    } catch (_) {
      if (mounted) {
        SeedSnackbarProvider.of(
          context,
        ).show(child: const SeedSnackbar(message: '파일을 열지 못했습니다. 다시 선택해주세요.'));
      }
    } finally {
      picking = false;
    }
  }

  Future<void> receiveFiles(List<XFile> files) async {
    if (!mounted || !controller.canAdd) return;
    for (final file in files) {
      if (!mounted || !controller.canAdd) break;
      try {
        final bytes = await file.readAsBytes();
        if (!mounted || !controller.canAdd) break;
        final mime =
            lookupMimeType(file.name, headerBytes: bytes) ?? file.mimeType;
        final image = mime?.startsWith('image/') ?? false;
        if (widget.imagesOnly && !image) {
          SeedSnackbarProvider.of(context).show(
            child: SeedSnackbar(message: '이미지 파일만 첨부할 수 있습니다: ${file.name}'),
          );
          continue;
        }
        counter++;
        final item = SeedAttachmentItem(
          id: '${widget.title}-$counter',
          name: file.name,
          sizeText: '${(bytes.length / 1024).toStringAsFixed(1)} KB',
          type: image ? SeedAttachmentType.image : SeedAttachmentType.file,
          imageProvider: image ? MemoryImage(bytes) : null,
          status: SeedAttachmentStatus.uploading,
          progress: 0,
        );
        controller.addEntries([item]);
        upload(item.id, controller);
      } catch (_) {
        if (mounted) {
          SeedSnackbarProvider.of(context)
              .show(child: SeedSnackbar(message: '파일을 읽지 못했습니다: ${file.name}'));
        }
      }
    }
  }

  void add(SeedAttachmentController target) {
    if (!target.canAdd) return;
    final item = newItem();
    target.addEntries([item]);
    upload(item.id, target);
  }

  void upload(String id, SeedAttachmentController target) {
    if (!target.items.any((item) => item.id == id)) return;
    target.updateStatus(id, SeedAttachmentStatus.uploading, progress: 0);
    var step = 0;
    late final Timer timer;
    timer = Timer.periodic(const Duration(milliseconds: 280), (timer) {
      if (!mounted || !target.items.any((item) => item.id == id)) {
        timer.cancel();
        return;
      }
      step++;
      if (step == 5) {
        timer.cancel();
        target.updateStatus(
          id,
          random.nextBool()
              ? SeedAttachmentStatus.success
              : SeedAttachmentStatus.error,
          progress: 100,
        );
      } else {
        target.updateStatus(
          id,
          SeedAttachmentStatus.uploading,
          progress: step * 20.0,
        );
      }
    });
    timers.add(timer);
  }

  @override
  void dispose() {
    for (final timer in timers) {
      timer.cancel();
    }
    controller.removeListener(changed);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final field = widget.display
        ? SeedAttachmentDisplayField(
            controller: controller,
            maxEntries: widget.maxCount,
            label: widget.title,
            description: widget.description,
            errorMessage: widget.errorMessage,
            reorderable: widget.reorderable,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            onTrigger: add,
            onRetry: (item, target) => upload(item.id, target),
          )
        : SeedAttachmentField(
            controller: controller,
            maxCount: widget.maxCount,
            label: widget.title,
            description: widget.description,
            errorMessage: widget.errorMessage,
            showDropzone: widget.dropzone,
            triggerIcon: Icon(
              widget.imagesOnly ? Icons.camera_alt_outlined : Icons.attach_file,
            ),
            reorderable: widget.reorderable,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            onAdd: pickFiles,
            onRetry: (item, target) => upload(item.id, target),
          );
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.dropzone && !widget.display)
            DropTarget(
              enable:
                  controller.canAdd &&
                  (ModalRoute.of(context)?.isCurrent ?? true),
              onDragDone: (details) => receiveFiles(details.files),
              child: field,
            )
          else
            field,
          if (widget.featured && controller.items.isNotEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('첫 번째 이미지: 대표사진', style: TextStyle(fontSize: 12)),
            ),
          const Divider(height: 32),
        ],
      ),
    );
  }
}

class _FormPage extends StatefulWidget {
  const _FormPage();
  @override
  State<_FormPage> createState() => _FormPageState();
}

const _categories = <(String value, String label)>[
  ('electronics', '전자기기'),
  ('fashion', '패션/의류'),
  ('food', '식품/음료'),
  ('home', '가구/인테리어'),
  ('sports', '스포츠/레저'),
  ('beauty', '뷰티/미용'),
  ('books', '도서/음반'),
  ('toys', '완구/취미'),
  ('pet', '반려동물용품'),
  ('baby', '유아동'),
  ('digital', '디지털/가전'),
  ('car', '자동차용품'),
  ('office', '문구/오피스'),
  ('health', '건강/의료'),
  ('travel', '여행/티켓'),
  ('kitchen', '주방용품'),
  ('garden', '정원/원예'),
  ('music', '악기/음향'),
  ('art', '미술/공예'),
  ('jewelry', '쥬얼리/시계'),
  ('camping', '캠핑/아웃도어'),
  ('fishing', '낚시용품'),
  ('golf', '골프'),
  ('cycling', '자전거'),
  ('game', '게임/콘솔'),
  ('collectibles', '수집품/굿즈'),
  ('handmade', '핸드메이드'),
  ('vintage', '빈티지/앤틱'),
  ('rental', '대여서비스'),
  ('etc', '기타'),
];

class _FormPageState extends State<_FormPage> {
  String name = '';
  String email = '';
  String address = '';
  String? category;
  String shipping = 'standard';
  String contact = 'email';
  final Set<String> extras = {};
  final Set<String> fruits = {};
  final Set<String> agreements = {};
  List<SeedAttachmentItem> attachments = [];
  double like = 5;
  mui.RangeValues budget = const mui.RangeValues(200000, 500000);
  String background = 'default';

  void toggle(Set<String> values, String item, bool checked) => setState(() {
    if (checked) {
      values.add(item);
    } else {
      values.remove(item);
    }
  });

  void submit() {
    final data = {
      'name': [name],
      'email': [email],
      'address': [address],
      if (category != null) 'category': [category],
      'shipping': [shipping],
      'attachments': attachments.isEmpty
          ? [{}]
          : [for (final _ in attachments) {}],
      if (extras.isNotEmpty) 'extra': extras.toList(),
      if (fruits.isNotEmpty) 'fruit': fruits.toList(),
      'like-level': [like.round().toString()],
      'budget-range': [
        budget.start.round().toString(),
        budget.end.round().toString(),
      ],
      'contact': [contact],
      if (agreements.isNotEmpty) 'agreement': agreements.toList(),
    };
    SeedSnackbarProvider.of(context).show(
      strategy: SeedSnackbarStrategy.immediate,
      duration: const Duration(seconds: 5),
      child: SeedSnackbar(message: jsonEncode(data)),
    );
  }

  String categoryLabel(String value) =>
      _categories
          .where((entry) => entry.$1 == value)
          .map((entry) => entry.$2)
          .firstOrNull ??
      value;

  void chooseCategory() async {
    // The React form pushes ActivityCategorySheet and receives a value/label
    // result when the sheet activity is dismissed.
    final result = await Navigator.of(context)
        .pushNamed('/category-sheet', arguments: {'defaultValue': category});
    if (!mounted || result is! Map) return;
    final picked = result['value'];
    if (picked is String && _categories.any((entry) => entry.$1 == picked)) {
      setState(() => category = picked);
    }
  }

  Widget check(
    String key,
    String label,
    Set<String> values, {
    SeedControlTone tone = SeedControlTone.neutral,
  }) => SeedCheckbox(
    label: label,
    tone: tone,
    size: SeedCheckboxSize.large,
    checked: values.contains(key),
    onCheckedChange: (checked) => toggle(values, key, checked),
  );

  Widget extraBox(
    String value,
    String title,
    String description,
    String price,
    IconData icon,
  ) => SeedSelectBox(
    title: title,
    description: description,
    prefix: Icon(icon),
    checked: extras.contains(value),
    onCheckedChange: (checked) => toggle(extras, value, checked),
    footer: Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 16),
      child: Text(price, style: const TextStyle(color: Colors.grey)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final dark = background == 'basement';
    return Column(
      children: [
        const SeedPageBanner(
          tone: SeedPageBannerTone.warning,
          variant: SeedPageBannerVariant.solid,
          prefixIcon: Icon(Icons.error_outline),
          description: '입력된 정보는 자동완성될 수 있으므로 실제 개인정보는 입력하지 마세요.',
        ),
        const SizedBox(height: 8),
        SeedSegmentedControl<String>(
          segments: const [
            SeedSegment(value: 'default', label: 'Default'),
            SeedSegment(value: 'basement', label: 'Basement'),
          ],
          value: background,
          onValueChange: (next) => setState(() => background = next),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ColoredBox(
            color: dark
                ? Theme.of(context).colorScheme.surfaceContainer
                : Theme.of(context).colorScheme.surface,
            child: _scroll([
              SeedTextField(
                label: '이름',
                required: true,
                placeholder: '김하늘',
                variant: SeedTextInputVariant.underline,
                description: '이름을 입력해주세요.',
                onChanged: (value) => name = value,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SeedTextField(
                      label: '이메일',
                      placeholder: 'foo@bar.baz',
                      prefixIcon: const Icon(Icons.mail_outline),
                      keyboardType: TextInputType.emailAddress,
                      description: '이메일 형식으로 입력해주세요.',
                      onChanged: (value) => email = value,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SeedTextField(
                      label: '주소',
                      placeholder: '대한민국 …',
                      description: '상세 주소까지 입력해주세요.',
                      maxGraphemeCount: 100,
                      onChanged: (value) => address = value,
                    ),
                  ),
                ],
              ),
              const Divider(),
              SeedFieldButton(
                label: '카테고리 선택',
                required: true,
                description: '원하는 카테고리를 선택해주세요.',
                placeholder: '카테고리를 선택해주세요.',
                values: category == null
                    ? const []
                    : [categoryLabel(category!)],
                onPressed: chooseCategory,
              ),
              SeedField(
                label: '배송 방법 선택',
                required: true,
                helperText: '원하는 배송 방법을 선택해주세요.',
                child: SeedSelectBoxGroup(
                  value: shipping,
                  columns: MediaQuery.sizeOf(context).width < 500 ? 1 : 2,
                  onValueChange: (next) =>
                      setState(() => shipping = next as String),
                  children: const [
                    SeedSelectBox(
                      value: 'express',
                      title: '빠른 배송 (1-2일)',
                      prefix: Icon(Icons.local_fire_department_outlined),
                      control: SeedSelectBoxControl.radiomark,
                    ),
                    SeedSelectBox(
                      value: 'standard',
                      title: '일반 배송 (3-5일)',
                      prefix: Icon(Icons.local_shipping_outlined),
                      control: SeedSelectBoxControl.radiomark,
                    ),
                    SeedSelectBox(
                      value: 'drone',
                      title: '드론 배송 (당일)',
                      prefix: Icon(Icons.send_outlined),
                      control: SeedSelectBoxControl.radiomark,
                    ),
                    SeedSelectBox(
                      value: 'pickup',
                      title: '직접 수령',
                      prefix: Icon(Icons.directions_walk_outlined),
                      control: SeedSelectBoxControl.radiomark,
                      enabled: false,
                    ),
                  ],
                ),
              ),
              _AttachmentDemo(
                title: '첨부 파일',
                description: '사진, 영수증 등을 첨부해주세요. (최대 3장)',
                imagesOnly: true,
                maxCount: 3,
                onEntriesChanged: (next) => attachments = next,
              ),
              const Divider(),
              SeedField(
                label: '추가 서비스',
                helperText: '원하는 추가 서비스를 선택해주세요.',
                child: Column(
                  children: [
                    extraBox(
                      'gift-wrap',
                      '선물 포장',
                      '고급 포장지로 선물 포장해 드립니다.',
                      '+3,000원이 추가됩니다.',
                      Icons.card_giftcard,
                    ),
                    extraBox(
                      'insurance',
                      '보험 가입',
                      '배송 중 파손 시 100% 보상',
                      '+5,000원이 추가됩니다.',
                      Icons.shield_outlined,
                    ),
                  ],
                ),
              ),
              const Divider(),
              SeedField(
                label: '좋아하는 과일',
                helperText: '좋아하는 과일을 모두 선택해주세요.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    check('apple', '사과', fruits),
                    check('banana', '바나나', fruits),
                    check('orange', '오렌지', fruits),
                  ],
                ),
              ),
              SeedSlider(
                values: [like],
                min: 0,
                max: 10,
                ticks: const [2, 4, 6, 8],
                markers: const [
                  SeedSliderMarker(0, '별로'),
                  SeedSliderMarker(10, '최고'),
                ],
                fieldLabel: '얼마나 좋아하시나요?',
                description: '좋아하는 정도를 0~10 사이로 선택해주세요.',
                onValuesChange: (values) => setState(() => like = values.first),
              ),
              const Divider(),
              SeedSlider.range(
                values: budget,
                min: 0,
                max: 1000000,
                step: 50000,
                fieldLabel: '예산 범위',
                description: '원하는 예산 범위를 선택해주세요.',
                invalid: true,
                errorMessage: 'Fugiat nisi exercitation incididunt qui incididunt in id laborum voluptate.',
                valueFormatter: (value) => '${value.round()}원',
                onValuesChange: (values) => setState(
                  () => budget = mui.RangeValues(values.first, values.last),
                ),
              ),
              const Divider(),
              SeedRadioGroup<String>(
                label: '선호하는 연락 방법',
                description: '연락 받고 싶은 방법을 선택해주세요.',
                value: contact,
                onValueChange: (next) {
                  if (next != null) setState(() => contact = next);
                },
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SeedRadio<String>(
                      value: 'email',
                      label: '이메일',
                      size: SeedRadioSize.large,
                      tone: SeedControlTone.neutral,
                    ),
                    SeedRadio<String>(
                      value: 'phone',
                      label: '전화',
                      size: SeedRadioSize.large,
                      tone: SeedControlTone.neutral,
                    ),
                    SeedRadio<String>(
                      value: 'sms',
                      label: '문자',
                      size: SeedRadioSize.large,
                      tone: SeedControlTone.neutral,
                    ),
                  ],
                ),
              ),
              SeedField(
                label: '약관 동의',
                required: true,
                helperText: '서비스 이용을 위해 약관에 동의해주세요.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    check('terms', '이용약관 동의 (필수)', agreements),
                    check('privacy', '개인정보 처리방침 동의 (필수)', agreements),
                    check('marketing', '마케팅 수신 동의 (선택)', agreements),
                  ],
                ),
              ),
            ]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: SeedButton(
            label: '제출',
            isFullWidth: true,
            size: SeedButtonSize.large,
            variant: SeedButtonVariant.neutralSolid,
            onPressed: submit,
          ),
        ),
      ],
    );
  }
}
