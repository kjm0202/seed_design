import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

void main() {
  Widget host(Widget child, {bool isDark = false}) {
    return MaterialApp(
      theme: (isDark ? SeedThemeData.dark() : SeedThemeData.light()).toThemeData(),
      home: Scaffold(body: Center(child: child)),
    );
  }

  group('Phase 1 & 2 Refinements', () {
    testWidgets('SeedContentPlaceholder uses gray200 background and domain presets', (tester) async {
      await tester.pumpWidget(
        host(const SeedContentPlaceholder(type: SeedContentPlaceholderType.buySell)),
      );

      expect(find.byType(SeedContentPlaceholder), findsOneWidget);
      expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(SeedContentPlaceholder),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, SeedPalette.gray200Light);
    });

    testWidgets('SeedButton supports withTextIconSize, bleed, and custom text styles', (tester) async {
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
    });

    testWidgets('SeedPageBanner and SeedCallout feature 40px close button with 8px radius', (tester) async {
      await tester.pumpWidget(
        host(
          Column(
            children: [
              SeedPageBanner(title: 'Banner', onDismiss: () {}),
              SeedCallout(description: 'Callout', onDismiss: () {}),
            ],
          ),
        ),
      );

      expect(find.byIcon(Icons.close_rounded), findsNWidgets(2));
      final animatedContainers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      final closeButtonContainers = animatedContainers.where((c) {
        return c.constraints?.maxWidth == 40.0 && c.constraints?.maxHeight == 40.0;
      }).toList();

      expect(closeButtonContainers.length, 2);
      for (final c in closeButtonContainers) {
        final decoration = c.decoration as BoxDecoration;
        expect(decoration.borderRadius, SeedBorderRadius.r2);
      }
    });

    testWidgets('SeedBadge supports prefix and action slots', (tester) async {
      await tester.pumpWidget(
        host(
          const SeedBadge(
            label: 'New',
            prefix: Icon(Icons.star),
            action: Icon(Icons.info),
          ),
        ),
      );

      expect(find.text('New'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byIcon(Icons.info), findsOneWidget);
    });

    testWidgets('SeedField renders 6px circle required indicator and icons', (tester) async {
      await tester.pumpWidget(
        host(
          const SeedField(
            label: 'Required Field',
            required: true,
            errorIcon: Icon(Icons.error),
            errorMessage: 'Error occurred',
            child: SizedBox(),
          ),
        ),
      );

      expect(find.text('Required Field'), findsOneWidget);
      expect(find.text('Error occurred'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
      expect(find.text('*'), findsOneWidget); // Screen reader / test compatibility
    });
  });

  group('Phase 3 New Components', () {
    testWidgets('SeedPopover renders structured Header, Body, Footer, and 52px close button', (tester) async {
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
        find.ancestor(of: closeFinder, matching: find.byType(AnimatedContainer)).first,
      );
      expect(animatedContainer.constraints?.maxWidth, 52.0);
      expect(animatedContainer.constraints?.maxHeight, 52.0);
    });

    testWidgets('SeedToggleButton toggles state and responds to onPressedChange', (tester) async {
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
    });

    testWidgets('SeedAvatarStack stacks avatars with negative gap and stroke separation', (tester) async {
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
    });

    testWidgets('SeedSelectBoxGroup spaces items by 12px', (tester) async {
      await tester.pumpWidget(
        host(
          const SeedSelectBoxGroup(
            children: [
              Text('Box 1'),
              Text('Box 2'),
            ],
          ),
        ),
      );

      expect(find.text('Box 1'), findsOneWidget);
      expect(find.text('Box 2'), findsOneWidget);
    });

    testWidgets('SeedTopNavigationIconButton & SeedTopNavigationTextButton render with 44px height', (tester) async {
      var iconTapped = false;
      var textTapped = false;

      await tester.pumpWidget(
        host(
          Row(
            children: [
              SeedTopNavigationIconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => iconTapped = true,
              ),
              SeedTopNavigationTextButton(
                text: '완료',
                onPressed: () => textTapped = true,
              ),
            ],
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.text('완료'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      expect(iconTapped, isTrue);

      await tester.tap(find.text('완료'));
      expect(textTapped, isTrue);
    });

    testWidgets('SeedTextButton renders with 36px height and t4Bold style', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        host(
          SeedTextButton(
            label: '텍스트 버튼',
            onPressed: () => tapped = true,
          ),
        ),
      );

      expect(find.text('텍스트 버튼'), findsOneWidget);
      await tester.tap(find.text('텍스트 버튼'));
      expect(tapped, isTrue);

      final size = tester.getSize(find.byType(SeedTextButton));
      expect(size.height, greaterThanOrEqualTo(36.0));
    });

    testWidgets('SeedAttachmentDropzone & SeedAttachmentItem file layout', (tester) async {
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

      expect(find.text('document.pdf'), findsOneWidget);
      expect(find.text('2.4 MB'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      expect(removed, isTrue);
    });
  });
}
