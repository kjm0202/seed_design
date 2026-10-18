import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_design/seed_design.dart';

void main() {
  group('SEED Foundations - Scale Feedback Physics', () {
    test('Calculates exact scale as defined in SEED documentation', () {
      // 32 x 32 icon button: basis = 32, scale = (32 - 2)/32 = 0.9375
      final scale32 = SeedScaleCalculator.calculateScale(width: 32, height: 32);
      expect(scale32, closeTo(0.9375, 0.001));

      // 120 x 48 text button: basis = 48, scale = (48 - 2)/48 = 0.9583
      final scale120 = SeedScaleCalculator.calculateScale(width: 120, height: 48);
      expect(scale120, closeTo(0.9583, 0.001));

      // 343 x 48 full-width button: basis = 343/4 = 85.75, scale = (85.75 - 2)/85.75 = 0.9766
      final scale343 = SeedScaleCalculator.calculateScale(width: 343, height: 48);
      expect(scale343, closeTo(0.9766, 0.001));

      // 22 x 22 small button: basis = min 24, scale = (24 - 2)/24 = 0.9166
      final scale22 = SeedScaleCalculator.calculateScale(width: 22, height: 22);
      expect(scale22, closeTo(0.9166, 0.001));

      // Reduce Motion disabled animations
      final scaleReduceMotion = SeedScaleCalculator.calculateScale(
        width: 120,
        height: 48,
        disableAnimations: true,
      );
      expect(scaleReduceMotion, 1.0);
    });
  });

  group('SEED Foundations - Color Scheme & Roles', () {
    test('Light and dark schemes have valid colors', () {
      const light = SeedColorScheme.light();
      const dark = SeedColorScheme.dark();

      expect(light.isDark, isFalse);
      expect(dark.isDark, isTrue);

      expect(light.fg.brand, SeedPalette.carrot600Light);
      expect(dark.fg.brand, SeedPalette.carrot700Dark);

      expect(light.bg.layerDefault, SeedPalette.gray00Light);
      expect(dark.bg.layerDefault, SeedPalette.gray100Dark);
    });

    test('Manner temperature levels resolve correctly', () {
      expect(SeedMannerTempLevel.fromTemperature(25.0), 1);
      expect(SeedMannerTempLevel.fromTemperature(35.0), 2);
      expect(SeedMannerTempLevel.fromTemperature(36.5), 4);
      expect(SeedMannerTempLevel.fromTemperature(38.0), 5);
      expect(SeedMannerTempLevel.fromTemperature(42.0), 6);
      expect(SeedMannerTempLevel.fromTemperature(48.0), 7);
      expect(SeedMannerTempLevel.fromTemperature(55.0), 8);
      expect(SeedMannerTempLevel.fromTemperature(65.0), 9);
      expect(SeedMannerTempLevel.fromTemperature(75.0), 9);
      expect(SeedMannerTempLevel.fromTemperature(90.0), 10);
    });
  });

  group('SEED Components - SeedButton & FAB', () {
    testWidgets('Renders label and handles tap', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light().toThemeData(),
          home: Scaffold(
            body: SeedButton(
              label: '동네생활 글쓰기',
              variant: SeedButtonVariant.brandSolid,
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('동네생활 글쓰기'), findsOneWidget);

      await tester.tap(find.text('동네생활 글쓰기'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('Displays progress circle when loading', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light().toThemeData(),
          home: Scaffold(
            body: SeedButton(
              label: '저장하기',
              loading: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(SeedProgressCircle), findsOneWidget);
    });

    testWidgets('SeedFloatingActionButton renders icon and label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light().toThemeData(),
          home: Scaffold(
            floatingActionButton: SeedFloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: '글쓰기',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('글쓰기'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });

  group('SEED Components - Badge & Notification', () {
    testWidgets('Renders badge with label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light().toThemeData(),
          home: const Scaffold(
            body: SeedBadge(
              label: '판매중',
              tone: SeedBadgeTone.positive,
              variant: SeedBadgeVariant.solid,
            ),
          ),
        ),
      );

      expect(find.text('판매중'), findsOneWidget);
    });

    testWidgets('Notification badge hides on count 0', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light().toThemeData(),
          home: const Scaffold(
            body: SeedNotificationBadge(count: 0),
          ),
        ),
      );

      expect(find.text('0'), findsNothing);
    });

    testWidgets('Notification badge shows count and truncates above max', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light().toThemeData(),
          home: const Scaffold(
            body: SeedNotificationBadge(count: 150, maxCount: 99),
          ),
        ),
      );

      expect(find.text('99+'), findsOneWidget);
    });
  });

  group('SEED Components - Selection', () {
    testWidgets('SeedCheckbox toggles', (tester) async {
      bool checked = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light().toThemeData(),
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: SeedCheckbox(
                  value: checked,
                  label: '약관에 동의합니다',
                  onChanged: (val) {
                    setState(() => checked = val ?? false);
                  },
                ),
              );
            },
          ),
        ),
      );

      expect(checked, isFalse);
      await tester.tap(find.text('약관에 동의합니다'));
      await tester.pumpAndSettle();
      expect(checked, isTrue);
    });

    testWidgets('SeedSwitch toggles', (tester) async {
      bool switched = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light().toThemeData(),
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: SeedSwitch(
                  value: switched,
                  label: '채팅 알림 받기',
                  onChanged: (val) {
                    setState(() => switched = val);
                  },
                ),
              );
            },
          ),
        ),
      );

      expect(switched, isFalse);
      await tester.tap(find.text('채팅 알림 받기'));
      await tester.pumpAndSettle();
      expect(switched, isTrue);
    });

    testWidgets('SeedSelectBox renders title and selection indicator', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light().toThemeData(),
          home: const Scaffold(
            body: SeedSelectBox(
              selected: true,
              title: '직거래',
              description: '만나서 직접 거래해요',
            ),
          ),
        ),
      );

      expect(find.text('직거래'), findsOneWidget);
      expect(find.text('만나서 직접 거래해요'), findsOneWidget);
    });
  });

  group('SEED Components - Manner Temp', () {
    testWidgets('Renders temperature text and badge', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light().toThemeData(),
          home: const Scaffold(
            body: Column(
              children: [
                SeedMannerTempBadge(temperature: 36.5),
                SeedMannerTemp(temperature: 42.0),
              ],
            ),
          ),
        ),
      );

      expect(find.text('36.5°C'), findsOneWidget);
      expect(find.text('42.0°C'), findsOneWidget);
    });
  });

  group('SEED Components - Input & Field', () {
    testWidgets('SeedField renders label and requirement mark', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light().toThemeData(),
          home: const Scaffold(
            body: SeedField(
              label: '닉네임',
              required: true,
              helperText: '한글, 영문, 숫자 조합 2~10자',
              child: SeedTextInput(hintText: '닉네임을 입력해주세요'),
            ),
          ),
        ),
      );

      expect(find.text('닉네임'), findsOneWidget);
      expect(find.text('*'), findsOneWidget);
      expect(find.text('한글, 영문, 숫자 조합 2~10자'), findsOneWidget);
      expect(find.text('닉네임을 입력해주세요'), findsOneWidget);
    });

    testWidgets('SeedInputButton renders placeholder and value', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light().toThemeData(),
          home: const Scaffold(
            body: SeedInputButton(
              value: '서울시 서초구',
              placeholder: '지역을 선택하세요',
            ),
          ),
        ),
      );

      expect(find.text('서울시 서초구'), findsOneWidget);
    });

    testWidgets('SeedQuantityPicker increments and decrements', (tester) async {
      int count = 1;

      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light().toThemeData(),
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: SeedQuantityPicker(
                  value: count,
                  min: 1,
                  max: 10,
                  onChanged: (val) {
                    setState(() => count = val);
                  },
                ),
              );
            },
          ),
        ),
      );

      expect(find.text('1'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();
      expect(count, 2);
    });

    testWidgets('SeedSlider renders and slides', (tester) async {
      double sliderVal = 50.0;

      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light().toThemeData(),
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: SeedSlider(
                  value: sliderVal,
                  min: 0,
                  max: 100,
                  onChanged: (v) => setState(() => sliderVal = v),
                ),
              );
            },
          ),
        ),
      );

      expect(find.byType(SeedSlider), findsOneWidget);
    });
  });

  group('SEED Components - Date & Time & Wheel Picker', () {
    testWidgets('SeedWheelPicker renders columns', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light().toThemeData(),
          home: Scaffold(
            body: SeedWheelPicker(
              columns: [
                SeedWheelColumn.typed<String>(items: ['항목 1', '항목 2', '항목 3']),
              ],
            ),
          ),
        ),
      );

      expect(find.text('항목 1'), findsWidgets);
    });

    testWidgets('SeedTimePicker renders period and hours', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light().toThemeData(),
          home: const Scaffold(
            body: SeedTimePicker(
              initialTime: TimeOfDay(hour: 10, minute: 30),
            ),
          ),
        ),
      );

      expect(find.text('오전'), findsWidgets);
      expect(find.text('10'), findsWidgets);
    });

    testWidgets('SeedDatePicker renders month and weekday headers', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light().toThemeData(),
          home: Scaffold(
            body: Center(
              child: SeedDatePicker(
                initialDate: DateTime(2026, 10, 17),
              ),
            ),
          ),
        ),
      );

      expect(find.text('2026년 10월'), findsOneWidget);
      expect(find.text('일'), findsOneWidget);
      expect(find.text('월'), findsOneWidget);
    });
  });

  group('SEED Components - Media & Layout & Placeholders', () {
    testWidgets('SeedAttachmentInput displays count and trigger', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light().toThemeData(),
          home: const Scaffold(
            body: SeedAttachmentInput(
              items: [],
              maxCount: 10,
            ),
          ),
        ),
      );

      expect(find.text('0/10'), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);
    });

    testWidgets('SeedImageFrame renders fallback placeholder when image is absent', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light().toThemeData(),
          home: const Scaffold(
            body: SeedImageFrame(
              badge: '대표사진',
            ),
          ),
        ),
      );

      expect(find.text('대표사진'), findsOneWidget);
      expect(find.byType(SeedContentPlaceholder), findsOneWidget);
    });

    testWidgets('SeedIdentityPlaceholder renders person and business icons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light().toThemeData(),
          home: const Scaffold(
            body: Column(
              children: [
                SeedIdentityPlaceholder(type: SeedIdentityType.person),
                SeedIdentityPlaceholder(type: SeedIdentityType.business),
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.byIcon(Icons.storefront), findsOneWidget);
    });

    testWidgets('SeedFooter renders brand and policy links', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light().toThemeData(),
          home: const Scaffold(
            body: SeedFooter(
              brandName: '당근',
              policyLinks: [
                SeedFooterLink(label: '이용약관'),
                SeedFooterLink(label: '개인정보처리방침'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('당근'), findsOneWidget);
      expect(find.text('이용약관'), findsOneWidget);
      expect(find.text('개인정보처리방침'), findsOneWidget);
    });
  });

  group('SEED Components - Navigation & Menus', () {
    testWidgets('SeedPagination renders page numbers and navigation', (tester) async {
      int page = 1;

      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light().toThemeData(),
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: SeedPagination(
                  currentPage: page,
                  totalPages: 5,
                  onPageChanged: (p) => setState(() => page = p),
                ),
              );
            },
          ),
        ),
      );

      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);

      await tester.tap(find.text('2'));
      await tester.pumpAndSettle();
      expect(page, 2);
    });

    testWidgets('SeedTablePagination renders range and rows control', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light().toThemeData(),
          home: Scaffold(
            body: SeedTablePagination(
              currentPage: 1,
              totalItems: 100,
              rowsPerPage: 10,
              onPageChanged: (_) {},
              onRowsPerPageChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('1–10 / 총 100개'), findsOneWidget);
      expect(find.text('씩 보기'), findsOneWidget);
    });

    testWidgets('SeedSideNavigation renders items and header', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light().toThemeData(),
          home: const Scaffold(
            body: SeedSideNavigation(
              header: Text('당근 비즈니스'),
              groups: [
                SeedSideNavGroup(
                  label: '광고 관리',
                  items: [
                    SeedSideNavItem(id: 'campaign', label: '캠페인 목록'),
                    SeedSideNavItem(id: 'report', label: '성과 보고서'),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('당근 비즈니스'), findsOneWidget);
      expect(find.text('광고 관리'), findsOneWidget);
      expect(find.text('캠페인 목록'), findsOneWidget);
      expect(find.text('성과 보고서'), findsOneWidget);
    });

    testWidgets('SeedMenu renders groups and item labels', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light().toThemeData(),
          home: const Scaffold(
            body: SeedMenu(
              groups: [
                SeedMenuGroupData(
                  label: '게시글 작업',
                  items: [
                    SeedMenuItemData(label: '수정하기'),
                    SeedMenuItemData(label: '삭제하기', isDestructive: true),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('게시글 작업'), findsOneWidget);
      expect(find.text('수정하기'), findsOneWidget);
      expect(find.text('삭제하기'), findsOneWidget);
    });

    testWidgets('SeedBottomNavigation renders tabs and triggers callback', (tester) async {
      int activeIndex = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light().toThemeData(),
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                bottomNavigationBar: SeedBottomNavigation(
                  currentIndex: activeIndex,
                  onTap: (idx) => setState(() => activeIndex = idx),
                  items: const [
                    SeedBottomNavigationItem(
                      label: '홈',
                      icon: Icon(Icons.home_outlined),
                      activeIcon: Icon(Icons.home),
                    ),
                    SeedBottomNavigationItem(
                      label: '동네생활',
                      icon: Icon(Icons.article_outlined),
                      activeIcon: Icon(Icons.article),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      expect(find.text('홈'), findsOneWidget);
      expect(find.text('동네생활'), findsOneWidget);

      await tester.tap(find.text('동네생활'));
      await tester.pumpAndSettle();
      expect(activeIndex, 1);
    });
  });

  group('SEED Components - Disclosure & Feedback', () {
    testWidgets('SeedAccordionItem expands on tap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light().toThemeData(),
          home: const Scaffold(
            body: SeedAccordionItem(
              title: '중고거래 사기 예방법',
              content: Text('안전결제를 이용하고 직거래를 우선하세요.'),
            ),
          ),
        ),
      );

      expect(find.text('중고거래 사기 예방법'), findsOneWidget);
      await tester.tap(find.text('중고거래 사기 예방법'));
      await tester.pumpAndSettle();
      expect(find.text('안전결제를 이용하고 직거래를 우선하세요.'), findsOneWidget);
    });

    testWidgets('SeedPageBanner renders banner text and action', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light().toThemeData(),
          home: const Scaffold(
            body: SeedPageBanner(
              title: '서비스 점검 안내',
              description: '새벽 2시부터 4시까지 서버 점검이 진행됩니다.',
            ),
          ),
        ),
      );

      expect(find.text('서비스 점검 안내'), findsOneWidget);
      expect(find.text('새벽 2시부터 4시까지 서버 점검이 진행됩니다.'), findsOneWidget);
    });

    testWidgets('SeedResultSection renders title and empty state action', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: SeedThemeData.light().toThemeData(),
          home: const Scaffold(
            body: SeedResultSection(
              title: '검색 결과가 없습니다',
              description: '다른 검색어로 다시 찾아보세요.',
            ),
          ),
        ),
      );

      expect(find.text('검색 결과가 없습니다'), findsOneWidget);
      expect(find.text('다른 검색어로 다시 찾아보세요.'), findsOneWidget);
    });
  });
}
