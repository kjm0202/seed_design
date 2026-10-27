import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

void main() {
  Widget host(Widget child, {bool isDark = false}) {
    return MaterialApp(
      theme: (isDark ? SeedThemeData.dark() : SeedThemeData.light())
          .toThemeData(),
      home: Scaffold(body: Center(child: child)),
    );
  }

  group('Phase 1 & 2 Refinements', () {
    testWidgets(
      'SeedButton supports withTextIconSize, bleed, and custom text styles',
      (tester) async {
        expect(SeedButtonSize.small.withTextIconSize, 14.0);
        expect(SeedButtonSize.medium.withTextIconSize, 16.0);
        expect(SeedButtonSize.small.iconOnlySize, 16.0);

        await tester.pumpWidget(
          host(
            SeedButton(
              label: 'Ghost Button',
              variant: SeedButtonVariant.ghost,
              bleed: true,
              textColor: Colors.blue,
              fontWeight: FontWeight.w400,
              onPressed: () {},
            ),
          ),
        );

        final text = tester.widget<Text>(find.text('Ghost Button'));
        expect(text.style?.color, Colors.blue);
        expect(text.style?.fontWeight, FontWeight.w400);
      },
    );
  });

  group('Phase 3 New Components', () {
    testWidgets(
      'SeedPopover renders structured Header, Body, Footer, and 52px close button',
      (tester) async {
        var closed = false;
        await tester.pumpWidget(
          host(
            SeedPopover(
              titleText: '알림',
              descriptionText: '자세한 내용입니다.',
              body: const Text('본문 내용'),
              footer: const Text('하단 액션'),
              onClose: () => closed = true,
            ),
          ),
        );

        expect(find.text('알림'), findsOneWidget);
        expect(find.text('자세한 내용입니다.'), findsOneWidget);
        expect(find.text('본문 내용'), findsOneWidget);
        expect(find.text('하단 액션'), findsOneWidget);

        final closeFinder = find.byIcon(Icons.close_rounded);
        expect(closeFinder, findsOneWidget);
        await tester.tap(closeFinder);
        expect(closed, isTrue);

        final animatedContainer = tester.widget<AnimatedContainer>(
          find
              .ancestor(
                of: closeFinder,
                matching: find.byType(AnimatedContainer),
              )
              .first,
        );
        expect(animatedContainer.constraints?.maxWidth, 52.0);
        expect(animatedContainer.constraints?.maxHeight, 52.0);
      },
    );

    testWidgets(
      'SeedToggleButton toggles state and responds to onPressedChange',
      (tester) async {
        bool isSelected = false;
        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return host(
                SeedToggleButton(
                  label: '즐겨찾기',
                  selected: isSelected,
                  onSelectedChanged: (val) => setState(() => isSelected = val),
                ),
              );
            },
          ),
        );

        expect(isSelected, isFalse);
        await tester.tap(find.text('즐겨찾기'));
        await tester.pumpAndSettle();
        expect(isSelected, isTrue);
      },
    );

    testWidgets(
      'SeedAvatarStack stacks avatars with negative gap and stroke separation',
      (tester) async {
        await tester.pumpWidget(
          host(
            SeedAvatarStack(
              size: SeedAvatarSize.medium,
              maxVisible: 2,
              children: const [
                SeedAvatar(placeholder: Text('A')),
                SeedAvatar(placeholder: Text('B')),
                SeedAvatar(placeholder: Text('C')),
              ],
            ),
          ),
        );

        expect(find.byType(SeedAvatarStack), findsOneWidget);
        expect(find.text('A'), findsOneWidget);
        expect(find.text('B'), findsOneWidget);
        expect(find.text('+1'), findsOneWidget);
      },
    );

    testWidgets('SeedAttachmentDropzone & SeedAttachmentItem file layout', (
      tester,
    ) async {
      var dropzoneTapped = false;
      var removed = false;

      await tester.pumpWidget(
        host(
          Column(
            children: [
              SeedAttachmentDropzone(onTap: () => dropzoneTapped = true),
              SeedAttachmentInput(
                items: [
                  const SeedAttachmentItem(
                    id: '1',
                    name: 'document.pdf',
                    sizeText: '2.4 MB',
                    type: SeedAttachmentType.file,
                  ),
                ],
                onRemove: (_) => removed = true,
              ),
            ],
          ),
        ),
      );

      expect(find.byType(SeedAttachmentDropzone), findsOneWidget);
      await tester.tap(find.byType(SeedAttachmentDropzone));
      expect(dropzoneTapped, isTrue);

      expect(
        find.byWidgetPredicate(
          (widget) => widget is Text && widget.semanticsLabel == 'document.pdf',
        ),
        findsOneWidget,
      );
      expect(find.text('2.4 MB'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      expect(removed, isTrue);
    });
  });
}
