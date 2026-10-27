import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import '../widgets/attachment_example.dart';
import '../widgets/calendar_example.dart';
import '../widgets/section_header.dart';

/// Tab showcasing form inputs, quantity picker, slider, select, attachment input, wheel picker, scroll fog, and date/time pickers.
class InputsTab extends StatefulWidget {
  const InputsTab({super.key});

  @override
  State<InputsTab> createState() => _InputsTabState();
}

class _InputsTabState extends State<InputsTab> {
  static const _scrollFogSize = 20.0;
  int _quantity = 1;
  double _sliderVal = 20.0;
  RangeValues _range = const RangeValues(20, 70);
  bool _quantityRemoved = false;
  String? _selectedValue = 'electronics';
  int _selectedYear = 2026;
  int _selectedMonth = 10;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Form Controls & Quantity Picker',
          subtitle: '텍스트 필드, 수량 선택, 슬라이더',
        ),
        const SeedTextField(
          label: '상품명',
          required: true,
          maxGraphemeCount: 40,
          description: '최대 40자까지 입력할 수 있어요. 이모지도 한 글자로 셉니다.',
          placeholder: '판매할 물품 이름을 입력하세요',
        ),
        const SizedBox(height: SeedDimension.x3),
        const SeedField(
          label: '판매 희망 가격',
          required: true,
          errorMessage: '가격을 올바르게 입력해주세요',
          errorIcon: Icon(Icons.error_outline),
          child: SeedTextInput(hintText: '가격을 입력하세요'),
        ),
        const SizedBox(height: SeedDimension.x4),

        Row(
          children: [
            Expanded(
              child: SeedField(
                label: '구매 수량',
                child: _quantityRemoved
                    ? SeedButton(
                        label: '수량 다시 추가',
                        size: SeedButtonSize.small,
                        onPressed: () => setState(() {
                          _quantity = 1;
                          _quantityRemoved = false;
                        }),
                      )
                    : SeedQuantityPicker(
                        value: _quantity,
                        min: 1,
                        max: 20,
                        removable: true,
                        onRemove: () => setState(() => _quantityRemoved = true),
                        onValueChange: (q) => setState(() => _quantity = q),
                      ),
              ),
            ),
            const SizedBox(width: SeedDimension.x4),
            Expanded(
              child: SeedField(
                label: '희망 할인율 (${_sliderVal.toInt()}%)',
                child: SeedSlider(
                  values: [_sliderVal],
                  min: 0,
                  max: 100,
                  onValuesChange: (v) => setState(() => _sliderVal = v.single),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: SeedDimension.x6),

        SeedSlider.range(
          fieldLabel: '범위 선택',
          values: _range,
          step: 10,
          minStepsBetweenThumbs: 1,
          onValuesChange: (values) =>
              setState(() => _range = RangeValues(values[0], values[1])),
          markers: const [
            SeedSliderMarker(0, '0'),
            SeedSliderMarker(50, '50'),
            SeedSliderMarker(100, '100'),
          ],
        ),
        Text('선택 범위: ${_range.start.toInt()}–${_range.end.toInt()}'),
        const SizedBox(height: SeedDimension.x4),
        const SeedTextField(
          label: '상품 소개',
          description: '내용에 따라 높이가 늘어납니다.',
          maxGraphemeCount: 100,
          autoResize: true,
          maxHeight: 180,
          placeholder: '상품을 소개해 주세요',
        ),
        const SizedBox(height: SeedDimension.x6),

        const SectionHeader(
          title: 'Select & Input Button',
          subtitle: '옵션 목록 선택 및 입력형 트리거 버튼',
        ),
        SeedSelect<String>(
          value: [?_selectedValue],
          groups: const [
            SeedSelectGroup<String>(
              label: '카테고리 선택',
              items: [
                SeedSelectItem(value: 'electronics', label: '디지털/가전'),
                SeedSelectItem(value: 'furniture', label: '가구/인테리어'),
                SeedSelectItem(value: 'clothing', label: '의류/잡화'),
              ],
            ),
          ],
          onValueChange: (v) => setState(() => _selectedValue = v.firstOrNull),
        ),
        const SizedBox(height: SeedDimension.x4),
        SeedSelect<String>(
          label: '관심 분야',
          multiple: true,
          showClear: true,
          groups: const [
            SeedSelectGroup(
              items: [
                SeedSelectItem(value: 'book', label: '독서'),
                SeedSelectItem(value: 'camp', label: '캠핑'),
                SeedSelectItem(value: 'cook', label: '요리'),
              ],
            ),
          ],
        ),
        const SizedBox(height: SeedDimension.x4),
        SeedInputButton(
          value: '서울시 강남구 역삼동',
          placeholder: '활동 지역을 선택하세요',
          prefixIcon: const Icon(Icons.location_on_outlined),
          onPressed: () {
            showSeedSnackbar(context: context, message: '지역 설정 창이 열립니다.');
          },
        ),
        const SizedBox(height: SeedDimension.x6),

        const SectionHeader(
          title: 'Attachment Input & Dropzone',
          subtitle: '진행률·오류·재시도·순서 변경 UI입니다. 실제 파일 선택이나 업로드는 하지 않습니다.',
        ),
        const AttachmentExample(),
        const SizedBox(height: SeedDimension.x6),

        const SectionHeader(
          title: 'Date Picker',
          subtitle: '월·두 달·주·연속 보기와 단일·범위·다중 선택',
        ),
        const CalendarExample(),
        const SizedBox(height: SeedDimension.x6),

        const SectionHeader(
          title: 'Wheel Picker & Time Picker',
          subtitle: '다중 컬럼 드럼형 휠 피커 및 시간 선택기',
        ),
        SizedBox(
          height: 160,
          child: SeedWheelPicker(
            columns: [
              SeedWheelColumn.typed<int>(
                items: [2024, 2025, 2026, 2027, 2028],
                initialIndex: 2,
                itemBuilder: (context, item, isSelected) => Center(
                  child: Text(
                    '$item년',
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
                onChanged: (index) =>
                    setState(() => _selectedYear = 2024 + index),
              ),
              SeedWheelColumn.typed<int>(
                items: List.generate(12, (i) => i + 1),
                initialIndex: 9,
                itemBuilder: (context, item, isSelected) => Center(
                  child: Text(
                    '$item월',
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
                onChanged: (index) =>
                    setState(() => _selectedMonth = index + 1),
              ),
            ],
          ),
        ),
        const SizedBox(height: SeedDimension.x2),
        Center(child: Text('선택된 기간: $_selectedYear년 $_selectedMonth월')),
        const SizedBox(height: SeedDimension.x4),
        const SeedTimePicker(),
        const SizedBox(height: SeedDimension.x6),

        const SectionHeader(
          title: 'Scroll Fog',
          subtitle: '스크롤 가능 영역의 상/하/좌/우 경계에 더 많은 콘텐츠가 있음을 암시하는 페이드 효과',
        ),
        SizedBox(
          height: 80,
          child: Stack(
            children: [
              ListView.builder(
                scrollDirection: Axis.horizontal,
                // Scroll Fog stays visible at both ends. Keep endpoint items
                // outside the fade by reserving the same depth as padding.
                padding: const EdgeInsets.symmetric(horizontal: _scrollFogSize),
                itemCount: 20,
                itemBuilder: (context, index) {
                  return Container(
                    width: 72,
                    margin: EdgeInsets.only(right: index == 19 ? 0 : 8),
                    decoration: BoxDecoration(
                      color: context.seedColor.bg.layerDefault,
                      borderRadius: SeedBorderRadius.r2,
                      border: Border.all(
                        color: context.seedColor.stroke.neutralWeak,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Item $index',
                      style: context.seedTypography.t4Regular.copyWith(
                        color: context.seedColor.fg.neutral,
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: SeedScrollFog(
                  placement: SeedScrollFogPlacement.left,
                  size: _scrollFogSize,
                  color: context.seedColor.bg.layerDefault,
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: SeedScrollFog(
                  placement: SeedScrollFogPlacement.right,
                  size: _scrollFogSize,
                  color: context.seedColor.bg.layerDefault,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: SeedDimension.x6),
      ],
    );
  }
}
