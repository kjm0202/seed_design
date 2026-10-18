import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

/// A SEED menu opened by its more-options button.
class SeedMenuExample extends StatefulWidget {
  const SeedMenuExample({super.key});

  @override
  State<SeedMenuExample> createState() => _SeedMenuExampleState();
}

class _SeedMenuExampleState extends State<SeedMenuExample> {
  final _controller = MenuController();
  final _buttonFocusNode = FocusNode();
  bool _isOpen = false;

  @override
  void dispose() {
    _buttonFocusNode.dispose();
    super.dispose();
  }

  void _select(String message) {
    _controller.close();
    showSeedSnackbar(context: context, message: message);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        MenuAnchor(
          controller: _controller,
          childFocusNode: _buttonFocusNode,
          consumeOutsideTap: true,
          clipBehavior: Clip.none,
          alignmentOffset: const Offset(0, SeedDimension.x2),
          style: const MenuStyle(
            alignment: AlignmentDirectional.bottomStart,
            padding: WidgetStatePropertyAll(EdgeInsets.zero),
            backgroundColor: WidgetStatePropertyAll(Colors.transparent),
            surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
            elevation: WidgetStatePropertyAll(0),
          ),
          onOpen: () => setState(() => _isOpen = true),
          onClose: () => setState(() => _isOpen = false),
          menuChildren: [
            SeedMenu(
              groups: [
                SeedMenuGroupData(
                  label: '채팅방 작업',
                  items: [
                    SeedMenuItemData(
                      label: '알림 끄기',
                      prefixIcon: const Icon(Icons.notifications_off_outlined),
                      onTap: () => _select('채팅방 알림을 껐어요.'),
                    ),
                    SeedMenuItemData(
                      label: '채팅방 나가기',
                      prefixIcon: const Icon(Icons.exit_to_app),
                      isDestructive: true,
                      onTap: () => _select('채팅방 나가기를 선택했어요.'),
                    ),
                  ],
                ),
              ],
            ),
          ],
          builder: (context, controller, child) => Semantics(
            expanded: _isOpen,
            child: SizedBox.square(
              dimension: 48,
              child: IconButton(
                focusNode: _buttonFocusNode,
                tooltip: '채팅방 메뉴',
                icon: const Icon(Icons.more_horiz),
                color: context.seedColor.fg.neutral,
                onPressed: () =>
                    controller.isOpen ? controller.close() : controller.open(),
              ),
            ),
          ),
        ),
        const SizedBox(height: SeedDimension.x2),
        Visibility(
          visible: !_isOpen,
          maintainState: true,
          maintainAnimation: true,
          maintainSize: true,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 260),
            child: const SeedHelpBubble(
              title: '메뉴 버튼을 눌러보세요',
              description: '채팅방 작업을 선택할 수 있어요.',
              arrowOffset: 17,
            ),
          ),
        ),
      ],
    );
  }
}
