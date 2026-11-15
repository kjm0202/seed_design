import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'support/seed_test_fonts.dart';
import 'support/seed_test_host.dart';

Future<void> _mount(
  WidgetTester tester, {
  required double width,
  required double scale,
  Widget? child,
  SeedTablePaginationValue? value,
  int totalItems = 237,
  void Function(SeedTablePaginationValue, SeedTablePaginationChange)? onChange,
}) async {
  tester.view.physicalSize = Size(width, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('ko'),
      supportedLocales: const [Locale('ko'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: SeedThemeData.light(fontFamily: seedTestFontFamily).toThemeData(),
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(scale)),
        child: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: width,
              child:
                  child ??
                  SeedTablePagination(
                    totalItems: totalItems,
                    value:
                        value ??
                        const SeedTablePaginationValue(page: 3, pageSize: 25),
                    onValueChange: onChange,
                  ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder get _horizontalScroller =>
    find.byKey(const ValueKey('seed-table-pagination-horizontal-scroll'));

Finder get _outerViewport =>
    find.byKey(const ValueKey('table-pagination-outer-viewport'));

FocusNode _focusNode(WidgetTester tester, Finder root) {
  final focusable = find.descendant(
    of: root,
    matching: find.byType(FocusableActionDetector),
  );
  return tester.widget<FocusableActionDetector>(focusable.first).focusNode!;
}

Future<void> _mountNested(
  WidgetTester tester, {
  required double width,
  required double scale,
  required ScrollController outerController,
  required ValueChanged<SeedTablePaginationChange> onChange,
}) async {
  tester.view.physicalSize = Size(width, 800);
  tester.view.devicePixelRatio = 1;

  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('ko'),
      supportedLocales: const [Locale('ko'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: SeedThemeData.light(fontFamily: seedTestFontFamily).toThemeData(),
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(scale)),
        child: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SingleChildScrollView(
              key: const ValueKey('table-pagination-outer-viewport'),
              controller: outerController,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 640,
                child: SeedTablePagination(
                  totalItems: 237,
                  value: const SeedTablePaginationValue(page: 3, pageSize: 25),
                  onValueChanged: onChange,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void _expectControlFullyVisible(
  WidgetTester tester,
  Finder control,
  String caseId,
) {
  final rect = tester.getRect(control);
  final viewport = tester.getRect(_outerViewport);
  expect(rect.left, greaterThanOrEqualTo(viewport.left - .5), reason: caseId);
  expect(rect.right, lessThanOrEqualTo(viewport.right + .5), reason: caseId);
}

Future<void> mount(
  WidgetTester tester,
  Widget child,
  double width,
  double scale,
) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: SeedThemeData.light(fontFamily: seedTestFontFamily).toThemeData(),
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(scale)),
        child: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(width: width, child: child),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Widget host(Widget child, {double width = 328}) => MaterialApp(
  theme: SeedThemeData.light().toThemeData(),
  home: Scaffold(
    body: Align(
      alignment: Alignment.topLeft,
      child: SizedBox(width: width, child: child),
    ),
  ),
);

List<String> labels(WidgetTester tester) => tester
    .widgetList<Widget>(
      find.descendant(
        of: find.byType(SeedPagination),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Text ||
              (widget is Icon && widget.icon == Icons.more_horiz),
        ),
      ),
    )
    .map((widget) => widget is Text ? widget.data! : '...')
    .toList();

Widget _host(
  Widget child, {
  double width = 800,
  Brightness brightness = Brightness.light,
}) {
  final theme = brightness == Brightness.dark
      ? SeedThemeData.dark(fontFamily: seedTestFontFamily)
      : SeedThemeData.light(fontFamily: seedTestFontFamily);
  return MaterialApp(
    locale: const Locale('ko'),
    supportedLocales: const [Locale('en'), Locale('ko')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: theme.toThemeData(),
    home: Scaffold(
      body: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(width: width, child: child),
      ),
    ),
  );
}

Finder get _rangeField => find.byWidgetPredicate(
  (widget) => widget is Semantics && widget.properties.label == '표시 범위',
);

void main() {
  for (final width in [240.0, 320.0, 390.0, 640.0]) {
    for (final scale in [1.0, 1.5, 2.5, 3.0]) {
      testWidgets('40px nowrap row $width x textScale$scale with long total', (
        tester,
      ) async {
        await _mount(
          tester,
          width: width,
          scale: scale,
          value: const SeedTablePaginationValue(page: 101, pageSize: 25),
          totalItems: 987654321012345,
        );
        final table = tester.getRect(find.byType(SeedTablePagination));
        expect(table.width, closeTo(width, .01));
        expect(table.height, closeTo(40, .01));
        expect(find.byType(SeedSelect<int>), findsNWidgets(2));
        final selects = find.byType(SeedInputButton);
        expect(selects, findsNWidgets(2));
        for (final anchor in selects.evaluate()) {
          final rect = tester.getRect(
            find.byElementPredicate((e) => e == anchor),
          );
          expect(rect.height, closeTo(40, .01));
          expect(rect.top, greaterThanOrEqualTo(table.top - .01));
          expect(rect.bottom, lessThanOrEqualTo(table.bottom + .01));
        }
        final arrows = [
          tester.getRect(find.byIcon(Icons.chevron_left)),
          tester.getRect(find.byIcon(Icons.chevron_right)),
        ];
        for (final arrow in arrows) {
          expect(arrow.center.dy, closeTo(table.center.dy, .1));
        }
        // The inner non-wrapping row is wider than a narrow viewport. The
        // React example's outer overflow-x:auto is separately route-tested.
        final scrollable = tester.state<ScrollableState>(
          find.descendant(
            of: _horizontalScroller,
            matching: find.byType(Scrollable),
          ),
        );
        expect(scrollable.position.maxScrollExtent, greaterThan(0));
        expect(find.textContaining('총 987654321012345개'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets(
    'controlled next buttons propose same page until parent updates',
    (tester) async {
      final changes = <SeedTablePaginationChange>[];
      await _mount(
        tester,
        width: 240,
        scale: 1.5,
        value: const SeedTablePaginationValue(page: 3, pageSize: 25),
        onChange: (_, details) => changes.add(details),
      );
      final next = find.bySemanticsLabel('다음 페이지');
      for (var i = 0; i < 2; i++) {
        await tester.ensureVisible(next);
        await tester.pumpAndSettle();
        await tester.tap(next);
        await tester.pumpAndSettle();
      }
      expect(changes, hasLength(2));
      for (final change in changes) {
        expect(
          change.previousValue,
          const SeedTablePaginationValue(page: 3, pageSize: 25),
        );
        expect(
          change.value,
          const SeedTablePaginationValue(page: 4, pageSize: 25),
        );
        expect(change.reason, SeedTablePageChangeReason.next);
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('keyboard next activation reveals horizontally hidden control', (
    tester,
  ) async {
    final changes = <SeedTablePaginationChange>[];
    await _mount(
      tester,
      width: 240,
      scale: 2.5,
      onChange: (_, details) => changes.add(details),
    );
    final next = find.bySemanticsLabel('다음 페이지');
    final focusable = find.descendant(
      of: next,
      matching: find.byType(FocusableActionDetector),
    );
    expect(focusable, findsOneWidget);
    tester.widget<FocusableActionDetector>(focusable).focusNode!.requestFocus();
    await tester.pumpAndSettle();
    final rootRect = tester.getRect(find.byType(SeedTablePagination));
    final nextRect = tester.getRect(next);
    expect(nextRect.right, lessThanOrEqualTo(rootRect.right + .1));
    expect(nextRect.left, greaterThanOrEqualTo(rootRect.left - .1));
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(changes, hasLength(1));
    expect(
      changes.single.value,
      const SeedTablePaginationValue(page: 4, pageSize: 25),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Tab traverses both Selects and nav buttons with focus reveal', (
    tester,
  ) async {
    final changes = <SeedTablePaginationChange>[];
    await _mount(
      tester,
      width: 240,
      scale: 2.5,
      onChange: (_, details) => changes.add(details),
    );
    FocusNode focusNodeWithin(Finder root) {
      final focusables = find.descendant(
        of: root,
        matching: find.byType(FocusableActionDetector),
      );
      return tester
          .widget<FocusableActionDetector>(focusables.first)
          .focusNode!;
    }

    final rowsNode = focusNodeWithin(find.byType(SeedSelect<int>).first);
    final rangeNode = focusNodeWithin(find.byType(SeedSelect<int>).last);
    final previousNode = focusNodeWithin(find.bySemanticsLabel('이전 페이지'));
    final nextNode = focusNodeWithin(find.bySemanticsLabel('다음 페이지'));
    rowsNode.requestFocus();
    await tester.pumpAndSettle();
    expect(rowsNode.hasFocus, isTrue);
    for (final node in [rangeNode, previousNode, nextNode]) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(node.hasFocus, isTrue);
    }
    final rootRect = tester.getRect(find.byType(SeedTablePagination));
    final buttonRect = tester.getRect(find.bySemanticsLabel('다음 페이지'));
    expect(buttonRect.left, greaterThanOrEqualTo(rootRect.left - .1));
    expect(buttonRect.right, lessThanOrEqualTo(rootRect.right + .1));
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(changes.single.reason, SeedTablePageChangeReason.next);
    expect(changes.single.value.page, 4);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Shift+Tab travels back to first Select and scrolls to start', (
    tester,
  ) async {
    await _mount(tester, width: 240, scale: 3);
    FocusNode focusNodeWithin(Finder root) {
      final focusables = find.descendant(
        of: root,
        matching: find.byType(FocusableActionDetector),
      );
      return tester
          .widget<FocusableActionDetector>(focusables.first)
          .focusNode!;
    }

    final selects = find.byType(SeedSelect<int>);
    final rowsNode = focusNodeWithin(selects.first);
    final rangeNode = focusNodeWithin(selects.last);
    final previousNode = focusNodeWithin(find.bySemanticsLabel('이전 페이지'));
    final nextNode = focusNodeWithin(find.bySemanticsLabel('다음 페이지'));
    nextNode.requestFocus();
    await tester.pumpAndSettle();
    expect(nextNode.hasFocus, isTrue);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    for (final node in [previousNode, rangeNode, rowsNode]) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(node.hasFocus, isTrue);
    }
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    final rootRect = tester.getRect(find.byType(SeedTablePagination));
    final trigger = tester.getRect(
      find.descendant(
        of: selects.first,
        matching: find.byType(SeedInputButton),
      ),
    );
    expect(trigger.left, greaterThanOrEqualTo(rootRect.left - .1));
    expect(trigger.right, lessThanOrEqualTo(rootRect.right + .1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('page range keyboard arrows and Enter select next page', (
    tester,
  ) async {
    final changes = <SeedTablePaginationChange>[];
    await _mount(
      tester,
      width: 640,
      scale: 1,
      child: SeedTablePagination(
        defaultValue: const SeedTablePaginationValue(page: 3, pageSize: 25),
        totalItems: 237,
        onValueChanged: changes.add,
      ),
    );
    final selectWidgets = find.byType(SeedSelect<int>);
    final rangeSelect = selectWidgets.last;
    final rangeTrigger = find
        .descendant(of: rangeSelect, matching: find.byType(SeedInputButton))
        .first;
    final rangeFocus = find
        .descendant(
          of: rangeSelect,
          matching: find.byType(FocusableActionDetector),
        )
        .first;
    await tester.ensureVisible(rangeTrigger);
    await tester.pumpAndSettle();
    tester
        .widget<FocusableActionDetector>(rangeFocus)
        .focusNode!
        .requestFocus();
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(changes, isNotEmpty);
    expect(changes.last.reason, SeedTablePageChangeReason.pageRange);
    expect(changes.last.value.page, 4);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'page-size keyboard options reset page, preserve callback reason',
    (tester) async {
      final changes = <SeedTablePaginationChange>[];
      await _mount(
        tester,
        width: 640,
        scale: 1,
        child: SeedTablePagination(
          defaultValue: const SeedTablePaginationValue(page: 3, pageSize: 25),
          totalItems: 237,
          onValueChanged: changes.add,
        ),
      );
      final sizeSelect = find.byType(SeedSelect<int>).first;
      final sizeTrigger = find
          .descendant(of: sizeSelect, matching: find.byType(SeedInputButton))
          .first;
      await tester.tap(sizeTrigger);
      await tester.pumpAndSettle();
      expect(find.text('50개'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(changes, isNotEmpty);
      expect(changes.last.reason, SeedTablePageChangeReason.pageSize);
      expect(changes.last.value.page, 1);
      expect(changes.last.value.pageSize, 50);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('zero-total controls cannot enter tab order or emit changes', (
    tester,
  ) async {
    final changes = <SeedTablePaginationChange>[];
    await _mount(
      tester,
      width: 240,
      scale: 3,
      child: SeedTablePagination(totalItems: 0, onValueChanged: changes.add),
    );
    final nav = [
      find.bySemanticsLabel('이전 페이지'),
      find.bySemanticsLabel('다음 페이지'),
    ];
    final selectableRange = find.byType(SeedSelect<int>).last;
    expect(tester.widget<SeedSelect<int>>(selectableRange).enabled, isFalse);
    for (final button in nav) {
      final focus = tester.widget<FocusableActionDetector>(
        find.descendant(
          of: button,
          matching: find.byType(FocusableActionDetector),
        ),
      );
      expect(focus.enabled, isFalse);
      await tester.ensureVisible(button);
      await tester.tap(button);
    }
    expect(changes, isEmpty);
    expect(find.text('0-0'), findsOneWidget);
    expect(tester.getSize(find.byType(SeedTablePagination)).height, 40);
    expect(tester.takeException(), isNull);
  });

  testWidgets('unknown total has no range dropdown and honors next=false', (
    tester,
  ) async {
    final changes = <SeedTablePaginationChange>[];
    await _mount(
      tester,
      width: 320,
      scale: 2.5,
      child: SeedTablePagination(
        value: const SeedTablePaginationValue(page: 2, pageSize: 10),
        hasPreviousPage: true,
        hasNextPage: false,
        currentPageItemCount: 7,
        onValueChanged: changes.add,
      ),
    );
    expect(find.byType(SeedSelect<int>), findsOneWidget);
    expect(find.text('11-17'), findsOneWidget);
    final next = find.bySemanticsLabel('다음 페이지');
    expect(
      tester
          .widget<FocusableActionDetector>(
            find.descendant(
              of: next,
              matching: find.byType(FocusableActionDetector),
            ),
          )
          .enabled,
      isFalse,
    );
    final prev = find.bySemanticsLabel('이전 페이지');
    final node = tester
        .widget<FocusableActionDetector>(
          find.descendant(
            of: prev,
            matching: find.byType(FocusableActionDetector),
          ),
        )
        .focusNode!;
    node.requestFocus();
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(changes.single.reason, SeedTablePageChangeReason.previous);
    expect(
      changes.single.value,
      const SeedTablePaginationValue(page: 1, pageSize: 10),
    );
    expect(tester.takeException(), isNull);
  });
  group('nested range popup', () {
    setUpAll(loadSeedTestFonts);

    for (final (width, scale) in [
      (240.0, 3.0),
      (320.0, 2.5),
      (390.0, 1.5),
      (640.0, 1.0),
    ]) {
      testWidgets(
        'nested range popup exposes React labels and commits keyboard change at $width/$scale',
        (tester) async {
          final controller = ScrollController();
          addTearDown(controller.dispose);
          addTearDown(tester.view.reset);
          final changes = <SeedTablePaginationChange>[];
          await _mountNested(
            tester,
            width: width,
            scale: scale,
            outerController: controller,
            onChange: changes.add,
          );
          expect(find.bySemanticsLabel('표 페이지 탐색'), findsOneWidget);
          expect(find.bySemanticsLabel('페이지당 표시 개수'), findsOneWidget);
          expect(find.bySemanticsLabel('표시 범위'), findsOneWidget);
          expect(find.bySemanticsLabel('이전 페이지'), findsOneWidget);
          expect(find.bySemanticsLabel('다음 페이지'), findsOneWidget);

          final range = find.byType(SeedSelect<int>).last;
          _focusNode(tester, range).requestFocus();
          await tester.pumpAndSettle();
          _expectControlFullyVisible(
            tester,
            range,
            'range trigger before keyboard popup $width/$scale',
          );
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
          await tester.pumpAndSettle();
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          await tester.pumpAndSettle();
          expect(changes, hasLength(1));
          expect(changes.single.reason, SeedTablePageChangeReason.pageRange);
          expect(
            changes.single.value,
            const SeedTablePaginationValue(page: 4, pageSize: 25),
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  });
  group('without a Material ancestor', () {
    setUpAll(loadSeedTestFonts);

    testWidgets('Pagination works without a Material ancestor', (tester) async {
      final pages = <int>[];
      await tester.pumpWidget(
        fontApp(
          SizedBox(
            width: 400,
            child: SeedPagination(totalPages: 5, onPageChanged: pages.add),
          ),
          scaffold: false,
        ),
      );
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('3'));
      await tester.pump();
      expect(pages, [3]);
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pump();
      expect(pages, [3, 4]);
    });

    testWidgets('TablePagination works without a Material ancestor', (
      tester,
    ) async {
      final pages = <int>[];
      await tester.pumpWidget(
        fontApp(
          SizedBox(
            width: 700,
            child: SeedTablePagination(
              totalItems: 100,
              onPageChanged: pages.add,
            ),
          ),
          scaffold: false,
        ),
      );
      await tester.pumpAndSettle();
      // The Select overlays provide their own Material here.
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pump();
      expect(pages, [2]);
    });
  });
  group('Pagination layout', () {
    setUpAll(loadSeedTestFonts);

    testWidgets(
      'page controls fit narrow containers and still select and advance',
      (tester) async {
        for (final width in [240.0, 288.0, 328.0, 768.0]) {
          for (final page in [1, 5, 10]) {
            int? selected;
            await mount(
              tester,
              SeedPagination(
                currentPage: page,
                totalPages: 10,
                onPageChanged: (value) => selected = value,
              ),
              width,
              1,
            );
            expect(
              tester.takeException(),
              isNull,
              reason: 'width=$width, page=$page',
            );
            final bounds = tester.getRect(find.byType(SeedPagination));
            for (final ink
                in find
                    .descendant(
                      of: find.byType(SeedPagination),
                      matching: find.byType(SeedPressable),
                    )
                    .evaluate()) {
              final box = tester.getRect(find.byWidget(ink.widget));
              expect(box.left, greaterThanOrEqualTo(bounds.left));
              expect(box.right, lessThanOrEqualTo(bounds.right));
              expect(box.width, greaterThanOrEqualTo(40));
            }
            if (page < 10) {
              await tester.tap(find.byIcon(Icons.chevron_right));
              await tester.pumpAndSettle();
              expect(selected, page + 1);
            } else {
              await tester.tap(find.byIcon(Icons.chevron_right));
              expect(selected, isNull);
            }
            selected = null;
            await tester.tap(find.text('$page'));
            expect(
              selected,
              isNull,
            ); // Selecting the current page is not a value change.
          }
        }
      },
    );

    testWidgets(
      'table page controls scroll without wrapping and remain actionable',
      (tester) async {
        for (final width in [240.0, 288.0, 328.0, 768.0]) {
          for (final scale in [1.0, 2.0]) {
            int? selected;
            await mount(
              tester,
              SeedTablePagination(
                currentPage: 2,
                totalItems: 320,
                rowsPerPage: 10,
                onPageChanged: (value) => selected = value,
                onRowsPerPageChanged: (_) {},
              ),
              width,
              scale,
            );
            expect(
              tester.takeException(),
              isNull,
              reason: 'width=$width, scale=$scale',
            );
            // Official TablePagination uses a single max-content, nowrap row.
            // At narrow widths the navigation controls are in the horizontal
            // scrollport rather than a second row; reveal them before tapping.
            final nextButton = find.byIcon(Icons.chevron_right);
            await tester.ensureVisible(nextButton);
            await tester.pumpAndSettle();
            await tester.tap(nextButton);
            await tester.pumpAndSettle();
            expect(selected, 3);
            final prevButton = find.byIcon(Icons.chevron_left);
            await tester.ensureVisible(prevButton);
            await tester.pumpAndSettle();
            await tester.tap(prevButton);
            await tester.pumpAndSettle();
            expect(selected, 1);
          }
        }
      },
    );
    testWidgets(
      'custom slot limits keep the current page visible without duplicates',
      (tester) async {
        for (final slots in [1, 3, 5, 7]) {
          for (final page in [1, 5, 10]) {
            await mount(
              tester,
              SeedPagination(
                currentPage: page,
                totalPages: 10,
                maxVisibleSlots: slots,
                onPageChanged: (_) {},
              ),
              768,
              2,
            );
            final labels = tester
                .widgetList<Text>(
                  find.descendant(
                    of: find.byType(SeedPagination),
                    matching: find.byType(Text),
                  ),
                )
                .map((text) => text.data!)
                .toList();
            expect(labels.length, lessThanOrEqualTo(slots));
            expect(labels, contains('$page'));
            final numbers = labels.where((label) => label != '...').toList();
            expect(numbers.toSet().length, numbers.length);
            expect(tester.takeException(), isNull);
          }
        }
      },
    );
  });

  group('Pagination page window', () {
    testWidgets(
      'selecting 10 then 8 keeps earlier neighboring pages reachable',
      (tester) async {
        var page = 9;
        final changes = <int>[];
        await tester.pumpWidget(
          host(
            StatefulBuilder(
              builder: (context, setState) => SeedPagination(
                currentPage: page,
                totalPages: 10,
                onPageChanged: (next) {
                  changes.add(next);
                  setState(() => page = next);
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('10'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('8'));
        await tester.pumpAndSettle();
        expect(page, 8);
        expect(labels(tester), ['...', '7', '8', '9', '10']);
        for (final previous in [7, 6, 5, 4, 3, 2, 1]) {
          await tester.tap(find.text('$previous'));
          await tester.pumpAndSettle();
          expect(page, previous);
        }
        expect(changes, [10, 8, 7, 6, 5, 4, 3, 2, 1]);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('five page slots follow the official compact page windows', (
      tester,
    ) async {
      const expected = [
        ['1', '2', '3', '4', '...'],
        ['1', '2', '3', '4', '...'],
        ['1', '2', '3', '4', '...'],
        ['...', '3', '4', '5', '...'],
        ['...', '4', '5', '6', '...'],
        ['...', '5', '6', '7', '...'],
        ['...', '6', '7', '8', '...'],
        ['...', '7', '8', '9', '10'],
        ['...', '7', '8', '9', '10'],
        ['...', '7', '8', '9', '10'],
      ];
      for (var page = 1; page <= 10; page++) {
        await tester.pumpWidget(
          host(SeedPagination(currentPage: page, totalPages: 10)),
        );
        await tester.pumpAndSettle();
        expect(labels(tester), expected[page - 1], reason: 'page=$page');
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('seven page slots retain official desktop boundary pages', (
      tester,
    ) async {
      const expected = {
        1: ['1', '2', '3', '4', '5', '...', '10'],
        4: ['1', '2', '3', '4', '5', '...', '10'],
        5: ['1', '...', '4', '5', '6', '...', '10'],
        6: ['1', '...', '5', '6', '7', '...', '10'],
        7: ['1', '...', '6', '7', '8', '9', '10'],
        10: ['1', '...', '6', '7', '8', '9', '10'],
      };
      for (final entry in expected.entries) {
        await tester.pumpWidget(
          host(
            SeedPagination(currentPage: entry.key, totalPages: 10),
            width: 768,
          ),
        );
        await tester.pumpAndSettle();
        expect(labels(tester), entry.value, reason: 'page=${entry.key}');
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('range selector', () {
    setUpAll(loadSeedTestFonts);

    for (final width in [800.0, 390.0, 240.0]) {
      testWidgets(
        'TablePagination separate range selector and total at width $width',
        (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = Size(width, 900);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.view.resetPhysicalSize);
          final changed = <int>[];
          await tester.pumpWidget(
            _host(
              SeedTablePagination(
                value: const SeedTablePaginationValue(page: 3, pageSize: 25),
                totalItems: 237,
                onPageChanged: changed.add,
              ),
              width: width,
            ),
          );
          await tester.pumpAndSettle();
          expect(_rangeField, findsOneWidget);
          // React: `min-width: 96px; width: max-content`.
          expect(tester.getSize(_rangeField).width, greaterThanOrEqualTo(96));
          expect(find.text('/ 총 237개'), findsOneWidget);
          expect(
            find.textContaining('총 237개', findRichText: true),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
          // The official TablePagination is one max-content row. The enclosing
          // horizontal scrollport must expose the next action before a pointer
          // tap at 240/390px, rather than relying on a wrapped second line.
          final nextButton = find.byIcon(Icons.chevron_right);
          await tester.ensureVisible(nextButton);
          await tester.pumpAndSettle();
          await tester.tap(nextButton);
          await tester.pumpAndSettle();
          expect(changed, [4]);
        },
      );
    }

    testWidgets(
      'TablePagination range selection still emits page-range reason',
      (tester) async {
        final changes = <SeedTablePaginationChange>[];
        await tester.pumpWidget(
          _host(
            SeedTablePagination(
              defaultValue: const SeedTablePaginationValue(
                page: 3,
                pageSize: 25,
              ),
              totalItems: 237,
              onValueChanged: changes.add,
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(_rangeField);
        await tester.pumpAndSettle();
        expect(find.text('76-100'), findsWidgets);
        await tester.tap(find.text('76-100').last);
        await tester.pumpAndSettle();
        expect(changes, hasLength(1));
        expect(changes.single.reason, SeedTablePageChangeReason.pageRange);
        expect(
          changes.single.value,
          const SeedTablePaginationValue(page: 4, pageSize: 25),
        );
        expect(find.text('/ 총 237개'), findsOneWidget);
      },
    );

    testWidgets(
      'TablePagination zero total keeps distinct disabled range and total',
      (tester) async {
        await tester.pumpWidget(
          _host(const SeedTablePagination(totalItems: 0)),
        );
        await tester.pumpAndSettle();
        expect(_rangeField, findsOneWidget);
        expect(tester.getSize(_rangeField).width, 96);
        expect(find.text('/ 총 0개'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('TablePagination unknown total keeps plain range only', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const SeedTablePagination(
            currentPage: 3,
            rowsPerPage: 25,
            currentPageItemCount: 12,
            hasPreviousPage: true,
            hasNextPage: false,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(_rangeField, findsNothing);
      expect(find.text('51-62'), findsOneWidget);
      expect(find.textContaining('총'), findsNothing);
    });
  });

  group('trivial counts', () {
    testWidgets(
      'pagination hides trivial counts and reports external constraints once',
      (tester) async {
        final changes = <SeedPageChange>[];
        await tester.pumpWidget(
          koreanApp(SeedPagination(totalPages: 0, onPageChange: changes.add)),
        );
        expect(find.byType(InkWell), findsNothing);
        await tester.pumpWidget(
          koreanApp(
            SeedPagination(
              currentPage: 20,
              totalPages: 5,
              onPageChange: changes.add,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(changes.last.reason, SeedPageChangeReason.constraint);
        expect(changes.last.page, 5);
        expect(changes.last.previousPage, 20);
        expect(changes, hasLength(1));
      },
    );
  });
}
