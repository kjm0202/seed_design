import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';

void main() {
  setUpAll(loadSeedTestFonts);
  for (final dark in [false, true]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('${dark ? 'dark' : 'light'} catalog at text scale $scale', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(440, scale == 1 ? 950 : 1300);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        await tester.pumpWidget(_Catalog(dark: dark, scale: scale));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await expectLater(
          find.byKey(const Key('catalog')),
          matchesGoldenFile(
            'goldens/${dark ? 'dark' : 'light'}_scale_${scale.toInt()}.png',
          ),
        );
      });
    }
  }
  testWidgets('keyboard focus is visible', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(240, 120);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      MaterialApp(
        theme: SeedThemeData.light(fontFamily: seedTestFontFamily)
            .toThemeData(),
        home: Scaffold(
          body: Center(
            child: SeedButton(label: '확인', onPressed: () {}),
          ),
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/keyboard_focus.png'),
    );
  });
}

class _Catalog extends StatelessWidget {
  final bool dark;
  final double scale;
  const _Catalog({required this.dark, required this.scale});

  @override
  Widget build(BuildContext context) {
    final seed = dark
        ? SeedThemeData.dark(fontFamily: seedTestFontFamily)
        : SeedThemeData.light(fontFamily: seedTestFontFamily);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: seed.toThemeData(),
      home: MediaQuery(
        data: MediaQueryData(
          textScaler: TextScaler.linear(scale),
          disableAnimations: true,
        ),
        child: Scaffold(
          body: RepaintBoundary(
            key: const Key('catalog'),
            child: ColoredBox(
              color: seed.colorScheme.bg.layerDefault,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('우리 동네 디자인', style: seed.typography.screenTitle),
                    const SizedBox(height: 8),
                    Text(
                      '한글과 English · 36.5°C',
                      style: seed.typography.articleBody,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final variant in SeedButtonVariant.values)
                          SeedButton(
                            label: switch (variant) {
                              SeedButtonVariant.brandSolid => '채팅하기',
                              SeedButtonVariant.neutralSolid => '확인',
                              SeedButtonVariant.neutralWeak => '취소',
                              SeedButtonVariant.brandOutline => '더 보기',
                              SeedButtonVariant.neutralOutline => '선택',
                              SeedButtonVariant.criticalSolid => '삭제',
                              SeedButtonVariant.ghost => '건너뛰기',
                            },
                            variant: variant,
                            onPressed: () {},
                          ),
                        const SeedButton(label: '사용 불가', onPressed: null),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        for (final size in SeedButtonSize.values)
                          SeedButton(label: '확인', size: size, onPressed: () {}),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SeedButton(
                      label: '긴 라벨도 가용 너비 안에서 표시합니다',
                      prefixIcon: const Icon(Icons.add),
                      isFullWidth: true,
                      onPressed: () {},
                    ),
                    const SizedBox(height: 16),
                    SeedCheckbox(
                      value: true,
                      label: '약관에 동의합니다',
                      onChanged: (_) {},
                    ),
                    SeedCheckbox(
                      value: null,
                      tristate: true,
                      label: '일부 선택',
                      onChanged: (_) {},
                    ),
                    SeedSwitch(value: true, label: '채팅 알림', onChanged: (_) {}),
                    const SeedSwitch(
                      value: false,
                      label: '알림 사용 불가',
                      onChanged: null,
                    ),
                    const SizedBox(height: 12),
                    const SeedTextInput(
                      hintText: '이름을 입력해 주세요',
                      clearable: false,
                    ),
                    const SizedBox(height: 12),
                    const SeedTextInput(
                      initialValue: '입력한 내용',
                      hasError: true,
                      clearable: false,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final value in [25.0, 36.5, 42.0, 80.0])
                          SeedMannerTempBadge(temperature: value),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SeedAccordionItem(
                      title: '자세한 안내',
                      content: const Text('상세 내용'),
                      initiallyExpanded: true,
                    ),
                    const SizedBox(height: 12),
                    const SeedProgressCircle(value: 0.6),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
