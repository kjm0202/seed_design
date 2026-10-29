import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

Widget host(Widget child) => MaterialApp(
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(body: Center(child: child)),
);

SeedSideNavigation navigation({String? selectedId, VoidCallback? onParent}) =>
    SeedSideNavigation(
      selectedId: selectedId,
      groups: [
        SeedSideNavGroup(
          items: [
            SeedSideNavItem(
              id: 'parent',
              label: 'Parent',
              onTap: onParent,
              subItems: const [SeedSideNavSubItem(id: 'child', label: 'Child')],
            ),
          ],
        ),
      ],
    );

void main() {
  testWidgets('collapsed navigation exposes children to pointer and keyboard', (
    tester,
  ) async {
    var selected = false;
    await tester.pumpWidget(
      host(
        SeedSideNavigation(
          isCollapsed: true,
          groups: [
            SeedSideNavGroup(
              items: [
                SeedSideNavItem(
                  id: 'parent',
                  label: 'Parent',
                  icon: Icons.settings,
                  subItems: [
                    SeedSideNavSubItem(
                      id: 'child',
                      label: 'Child',
                      onTap: () => selected = true,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
    await tester.tap(find.byTooltip('Parent'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Child'));
    await tester.pumpAndSettle();
    expect(selected, isTrue);
    selected = false;
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Child'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(selected, isTrue);
  });

  testWidgets('wheel taps settle once and disabled wheels keep their value', (
    tester,
  ) async {
    final changes = <int>[];
    var enabled = true;
    late StateSetter update;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return SizedBox(
              width: 220,
              child: SeedWheelPicker(
                enabled: enabled,
                columns: [
                  SeedWheelColumn.typed(
                    items: List.generate(20, (i) => 'Value $i'),
                    initialIndex: 5,
                    onChanged: changes.add,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('Value 6'));
    expect(changes, isEmpty);
    await tester.pumpAndSettle();
    expect(changes, [6]);
    update(() => enabled = false);
    await tester.pumpAndSettle();
    await tester.drag(find.byType(SeedWheelPicker), const Offset(0, -150));
    await tester.pumpAndSettle();
    final wheel = tester.widget<ListWheelScrollView>(
      find.byType(ListWheelScrollView),
    );
    expect((wheel.controller! as FixedExtentScrollController).selectedItem, 6);
    expect(changes, [6]);

    update(() => enabled = true);
    await tester.pumpAndSettle();
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(SeedWheelPicker)),
    );
    await gesture.moveBy(const Offset(0, -20));
    await tester.pump(const Duration(milliseconds: 50));
    await gesture.moveBy(const Offset(0, -100));
    await tester.pump(const Duration(milliseconds: 50));
    expect(changes, [6]);
    update(() => enabled = false);
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
    expect((wheel.controller! as FixedExtentScrollController).selectedItem, 6);
    expect(changes, [6]);
  });

  testWidgets('large chip tabs honor their explicit size', (tester) async {
    for (final (size, height) in [
      (SeedTabsSize.medium, 36.0),
      (SeedTabsSize.large, 40.0),
    ]) {
      await tester.pumpWidget(
        host(
          SeedTabs(
            items: const [
              SeedTabItem(label: 'A'),
              SeedTabItem(label: 'B'),
            ],
            selectedIndex: 0,
            onTabSelected: (_) {},
            variant: SeedTabsVariant.chipSolid,
            size: size,
          ),
        ),
      );
      final surface = find.ancestor(
        of: find.text('A'),
        matching: find.byType(AnimatedContainer),
      );
      expect(tester.getSize(surface).height, height);
    }
  });

  testWidgets('long tags wrap in a narrow container at 200 percent text', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: const SizedBox(
            width: 120,
            child: SeedTagGroup(
              items: [
                SeedTagItem(label: '아주 긴 태그 정보입니다', icon: Icon(Icons.info)),
                SeedTagItem(label: '다음 태그'),
              ],
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('custom wheel extent is preserved and limits fog', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        SizedBox(
          width: 220,
          child: SeedWheelPicker(
            size: SeedWheelPickerSize.small,
            height: 400,
            columns: [
              SeedWheelColumn.typed(items: ['A', 'B', 'C'], itemExtent: 30),
            ],
          ),
        ),
      ),
    );
    expect(
      tester
          .widget<ListWheelScrollView>(find.byType(ListWheelScrollView))
          .itemExtent,
      30,
    );
    expect(
      tester
          .widgetList<SeedScrollFog>(find.byType(SeedScrollFog))
          .map((fog) => fog.size),
      [90, 90],
    );
  });

  testWidgets(
    'bottom navigation skips disabled tabs and reads notification state',
    (tester) async {
      final changes = <int>[];
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        host(
          SeedBottomNavigation(
            currentIndex: 0,
            onTap: changes.add,
            items: const [
              SeedBottomNavigationItem(icon: Icon(Icons.home), label: 'Home'),
              SeedBottomNavigationItem(
                icon: Icon(Icons.lock),
                label: 'Locked',
                enabled: false,
              ),
              SeedBottomNavigationItem(
                icon: Icon(Icons.chat),
                label: 'Chat',
                notificationCount: 120,
              ),
              SeedBottomNavigationItem(
                icon: Icon(Icons.notifications),
                label: 'News',
                showNotificationDot: true,
              ),
            ],
          ),
        ),
      );
      await tester.tap(find.text('Locked'));
      expect(changes, isEmpty);
      final locked = tester.getSemantics(find.bySemanticsLabel('Locked'));
      expect(
        locked,
        matchesSemantics(
          label: 'Locked',
          isButton: true,
          hasEnabledState: true,
          isEnabled: false,
          hasSelectedState: true,
        ),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Chat')).value,
        '읽지 않은 알림 120개',
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('News')).value,
        '새 알림 있음',
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(changes, [2]);
      semantics.dispose();
    },
  );

  testWidgets('expanding a navigation parent does not navigate', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(host(navigation(onParent: () => calls++)));
    await tester.tap(find.text('Parent'));
    await tester.pumpAndSettle();
    expect(find.text('Child'), findsOneWidget);
    expect(calls, 0);
  });

  testWidgets('active navigation child is visible initially and after update', (
    tester,
  ) async {
    await tester.pumpWidget(host(navigation(selectedId: 'child')));
    expect(find.text('Child'), findsOneWidget);
    await tester.pumpWidget(host(navigation()));
    await tester.tap(find.text('Parent'));
    await tester.pumpAndSettle();
    expect(find.text('Child'), findsNothing);
    await tester.pumpWidget(host(navigation(selectedId: 'child')));
    expect(find.text('Child'), findsOneWidget);
  });

  testWidgets('list can suppress dividers through wrapped children', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const SeedList(
          showDividers: false,
          children: [
            SeedListItem(titleText: 'One'),
            Padding(
              padding: EdgeInsets.zero,
              child: SeedListItem(titleText: 'Two'),
            ),
          ],
        ),
      ),
    );
    expect(find.byType(SeedDivider), findsNothing);
    await tester.pumpWidget(host(const SeedListItem(titleText: 'Standalone')));
    expect(find.byType(SeedDivider), findsOneWidget);
  });

  testWidgets('snackbars retain each message for its duration in FIFO order', (
    tester,
  ) async {
    late BuildContext context;
    await tester.pumpWidget(
      host(
        Builder(
          builder: (value) {
            context = value;
            return const SizedBox();
          },
        ),
      ),
    );
    final first = showSeedSnackbar(context: context, message: 'First');
    await tester.pumpAndSettle();
    showSeedSnackbar(context: context, message: 'Second');
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('First'), findsOneWidget);
    expect(find.text('Second'), findsNothing);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(await first.closed, SnackBarClosedReason.timeout);
    expect(find.text('Second'), findsOneWidget);
  });

  testWidgets('wheel commits once after scrolling settles', (tester) async {
    final changes = <int>[];
    await tester.pumpWidget(
      host(
        SizedBox(
          width: 220,
          child: SeedWheelPicker(
            columns: [
              SeedWheelColumn.typed(
                items: List.generate(30, (i) => i),
                onChanged: changes.add,
              ),
            ],
          ),
        ),
      ),
    );
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(ListWheelScrollView)),
    );
    await gesture.moveBy(const Offset(0, -20));
    await tester.pump(const Duration(milliseconds: 50));
    await gesture.moveBy(const Offset(0, -140));
    await tester.pump(const Duration(milliseconds: 100));
    expect(changes, isEmpty);
    await gesture.up();
    await tester.pumpAndSettle();
    final wheel = tester.widget<ListWheelScrollView>(
      find.byType(ListWheelScrollView),
    );
    expect(changes, [
      (wheel.controller! as FixedExtentScrollController).selectedItem,
    ]);
  });

  testWidgets('small wheel inherits row extent and font from picker size', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        SizedBox(
          width: 220,
          child: SeedWheelPicker(
            size: SeedWheelPickerSize.small,
            columns: [
              SeedWheelColumn.typed(items: ['A', 'B', 'C']),
            ],
          ),
        ),
      ),
    );
    expect(
      tester
          .widget<ListWheelScrollView>(find.byType(ListWheelScrollView))
          .itemExtent,
      36,
    );
    expect(
      tester.widget<Text>(find.text('A')).style!.fontSize,
      SeedThemeData.light().typography.t7Medium.fontSize,
    );
  });

  testWidgets('avatar uses placeholder when image decoding fails', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(SeedAvatar(image: MemoryImage(Uint8List.fromList([1, 2, 3])))),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(SeedIdentityPlaceholder), findsOneWidget);
  });

  testWidgets('file upload loading and failure expose progress and retry', (
    tester,
  ) async {
    SeedAttachmentItem? retried;
    const failed = SeedAttachmentItem(
      id: 'failed',
      type: SeedAttachmentType.file,
      name: 'file.pdf',
      status: SeedAttachmentStatus.error,
    );
    await tester.pumpWidget(
      host(
        SeedAttachmentInput(
          items: const [
            SeedAttachmentItem(
              id: 'loading',
              type: SeedAttachmentType.file,
              status: SeedAttachmentStatus.loading,
            ),
            failed,
          ],
          onRetry: (item) => retried = item,
        ),
      ),
    );
    expect(find.byType(SeedProgressCircle), findsOneWidget);
    await tester.tap(find.byTooltip('첨부 파일 업로드 재시도'));
    expect(retried, same(failed));
  });

  testWidgets('disabled image upload cannot retry', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      host(
        SeedAttachmentInput(
          enabled: false,
          items: const [
            SeedAttachmentItem(
              id: 'failed',
              status: SeedAttachmentStatus.error,
            ),
          ],
          onRetry: (_) => calls++,
        ),
      ),
    );
    await tester.tap(find.byIcon(Icons.refresh));
    expect(calls, 0);
  });

  testWidgets('desktop side panel caps its preferred width at 80%', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      host(const SeedSidePanel(title: 'Panel', width: 720, body: SizedBox())),
    );
    expect(tester.getSize(find.byType(SeedSidePanel)).width, 640);
  });

  testWidgets('selected disabled segment has a disabled indicator', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        SeedSegmentedControl(
          segments: const [
            SeedSegment(value: 1, label: 'One', enabled: false),
            SeedSegment(value: 2, label: 'Two'),
          ],
          selectedValue: 1,
          onValueChanged: (_) {},
        ),
      ),
    );
    final indicator = find.descendant(
      of: find.byType(AnimatedPositioned),
      matching: find.byType(Container),
    );
    expect(
      (tester.widget<Container>(indicator).decoration! as BoxDecoration).color,
      SeedThemeData.light().colorScheme.bg.disabled,
    );
  });

  testWidgets('footer fits a phone with long branding and social links', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      host(
        SeedFooter(
          brandName: 'A long service brand name',
          sitemapColumns: const [SeedFooterColumn(title: 'Company', links: [])],
          socialLinks: List.generate(
            5,
            (_) => const SizedBox(width: 48, height: 48),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
