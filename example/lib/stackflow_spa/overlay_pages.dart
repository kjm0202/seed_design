import 'package:flutter/material.dart';
import 'package:seed_design/seed_design.dart';

import 'spa_types.dart';

/// The interactive overlay activities from the React stackflow-spa example.
/// The surrounding SPA owns the Scaffold and its top navigation bar.
Widget? buildOverlayPage(
  String activity,
  BuildContext context, {
  required SpaNavigate navigate,
  required VoidCallback goBack,
  Object? arguments,
}) {
  switch (activity) {
    case 'ActivityBottomSheet':
    case 'ActivityBottomSheetInputFocus':
    case 'ActivityBottomSheetTextField':
    case 'ActivityBottomSheetKeyboardPlayground':
    case 'ActivityNestedBottomSheet':
    case 'ActivityMenuSheet':
    case 'ActivityMenuSheetSimple':
    case 'ActivitySwipeableMenuSheet':
    case 'ActivitySidePanel':
    case 'ActivityResponsiveSidePanel':
    case 'ActivityAlertDialog':
    case 'ActivityResponsiveDialog':
    case 'ActivityBottomSheetModalTest':
      return SpaOwnScaffold(
        child: Scaffold(
          backgroundColor: context.seedColor.bg.layerDefault,
          body: _ModalActivityPage(
            key: ValueKey(activity),
            activity: activity,
            navigate: navigate,
            goBack: goBack,
          ),
        ),
      );
    case 'ActivityBottomSheetWithAlertDialogStep':
      return const _SheetDialogStepPage();
    case 'ActivityAlertDialogStep':
      return _AlertDialogStepPage(navigate: navigate);
    case 'ActivityBottomSheetStep':
      return _BottomSheetStepPage(navigate: navigate);
    case 'ActivityMenuSheetStep':
      return _MenuSheetStepPage(navigate: navigate);
    case 'ActivityAlertDialogActivity':
      return _ActivityLaunchPage(
        activity: activity,
        overlayActivity: 'ActivityAlertDialog',
        navigate: navigate,
      );
    case 'ActivityBottomSheetActivity':
      return _ActivityLaunchPage(
        activity: activity,
        overlayActivity: 'ActivityBottomSheet',
        navigate: navigate,
      );
    case 'ActivityMenuSheetActivity':
      return _ActivityLaunchPage(
        activity: activity,
        overlayActivity: 'ActivityMenuSheetSimple',
        navigate: navigate,
      );
    case 'ActivitySidePanelActivity':
      return _ActivityLaunchPage(
        activity: activity,
        overlayActivity: 'ActivitySidePanel',
        navigate: navigate,
      );
    case 'ActivityMenu':
      return SpaOwnScaffold(child: _MenuDemoPage(navigate: navigate));
    case 'ActivityHelpBubble':
      return const _HelpBubbleDemoPage();
    case 'ActivityPopover':
      return const SpaOwnScaffold(child: _PopoverDemoPage());
    default:
      return null;
  }
}

SeedButton _button(
  String label,
  VoidCallback onPressed, {
  SeedButtonVariant variant = SeedButtonVariant.neutralSolid,
  SeedButtonSize size = SeedButtonSize.medium,
}) => SeedButton(
  label: label,
  onPressed: onPressed,
  variant: variant,
  size: size,
);

Widget _column(List<Widget> children, {double gap = 12}) => Column(
  mainAxisSize: MainAxisSize.min,
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    for (var i = 0; i < children.length; i++) ...[
      if (i > 0) SizedBox(height: gap),
      children[i],
    ],
  ],
);

Widget _choices(
  List<String> values,
  String selected,
  ValueChanged<String> onChange,
) => Wrap(
  spacing: 8,
  runSpacing: 8,
  children: [
    for (final value in values)
      _button(
        value,
        () => onChange(value),
        size: SeedButtonSize.xsmall,
        variant: value == selected
            ? SeedButtonVariant.neutralSolid
            : SeedButtonVariant.neutralWeak,
      ),
  ],
);

Widget _section(String title, Widget child, {String? hint}) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 12),
  child: _column([
    Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
    if (hint != null) Text(hint, style: const TextStyle(fontSize: 12)),
    child,
  ], gap: 8),
);

Widget _demoScroll(List<Widget> children) => ListView(
  padding: const EdgeInsets.fromLTRB(20, 24, 20, 240),
  children: children,
);

void _notify(BuildContext context, String message) {
  if (context.mounted) {
    SeedSnackbarProvider.of(context).show(
      child: SeedSnackbar(
        message: message,
        variant: SeedSnackbarVariant.positive,
      ),
    );
  }
}

class _ModalActivityPage extends StatefulWidget {
  const _ModalActivityPage({
    super.key,
    required this.activity,
    required this.navigate,
    required this.goBack,
  });
  final String activity;
  final SpaNavigate navigate;
  final VoidCallback goBack;

  @override
  State<_ModalActivityPage> createState() => _ModalActivityPageState();
}

class _ModalActivityPageState extends State<_ModalActivityPage> {
  bool _shown = false;
  Object? _result;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_shown) return;
    _shown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _openActivity();
    });
  }

  Future<void> _openActivity() async {
    switch (widget.activity) {
      case 'ActivityBottomSheet':
        await _openFormSheet();
      case 'ActivityBottomSheetTextField':
        await _openNameSheet();
      case 'ActivityBottomSheetInputFocus':
        await _openChatSheet();
      case 'ActivityBottomSheetKeyboardPlayground':
        await _openKeyboardPlayground();
      case 'ActivityNestedBottomSheet':
        await showSeedBottomSheet<void>(
          context: context,
          child: SeedBottomSheet(
            title: 'BottomSheet × AlertDialog (Activity)',
            description: '아래 버튼으로 AlertDialog Activity를 push해 위에 얹어보세요.',
            showHandle: true,
            content: const Text(
              'Activity 패턴: BottomSheet 자체 Activity 위에 AlertDialog Activity가 얹힙니다. '
              'Backdrop이나 Content 빈 영역을 클릭해보세요.',
            ),
            footer: _column([
              _button('Open AlertDialog', () {
                widget.navigate('ActivityAlertDialog');
              }),
              Builder(
                builder: (ctx) => _button(
                  '닫기',
                  () => Navigator.pop(ctx),
                  variant: SeedButtonVariant.neutralWeak,
                ),
              ),
            ]),
          ),
        );
      case 'ActivityMenuSheet':
      case 'ActivitySwipeableMenuSheet':
        await _openMenuSheet();
      case 'ActivityMenuSheetSimple':
        await _openSimpleMenuSheet();
      case 'ActivitySidePanel':
      case 'ActivityResponsiveSidePanel':
        await _openSidePanel();
      case 'ActivityAlertDialog':
        _result = await showSeedDialog<Map<String, String>>(
          context: context,
          barrierDismissible: true,
          child: _ActivityAlertDialog(navigate: widget.navigate),
        );
        _result ??= {'message': 'hello'};
      case 'ActivityResponsiveDialog':
        await _openResponsiveDialog();
      case 'ActivityBottomSheetModalTest':
        await _openModalTest();
    }
    if (mounted) Navigator.of(context).pop(_result);
  }

  Future<void> _openFormSheet() async {
    final nameController = TextEditingController();
    bool subscribe = false;
    bool keepMounted = false;
    String transition = 'slideFromRightIOS';
    String? error;
    try {
      await showSeedBottomSheet<void>(
        context: context,
        child: StatefulBuilder(
          builder: (sheetContext, refresh) => _RoutePresence(
            keepMounted: keepMounted,
            onUnmount: () {
              nameController.clear();
              refresh(() => subscribe = false);
            },
            child: SeedBottomSheet(
              title: '정보 입력',
              showHandle: true,
              showCloseButton: false,
              content: _column([
                SeedTextField(
                  controller: nameController,
                  label: '이름',
                  description: '본명이 아니어도 괜찮아요.',
                  required: true,
                  placeholder: '이름을 입력하세요',
                  errorMessage: error,
                  onChanged: (_) {
                    if (error != null) refresh(() => error = null);
                  },
                ),
                SeedCheckbox(
                  label: '뉴스레터 구독하기',
                  checked: subscribe,
                  onCheckedChange: (value) => refresh(() => subscribe = value),
                ),
              ]),
              footer: _column([
                Row(
                  children: [
                    Expanded(
                      child: _button(
                        '닫기',
                        () => Navigator.pop(sheetContext),
                        variant: SeedButtonVariant.neutralWeak,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _button('제출', () {
                        if (nameController.text.trim().isEmpty) {
                          refresh(() => error = '이름을 입력해주세요.');
                          return;
                        }
                        _notify(
                          context,
                          '{"name":"${nameController.text}","subscribe":$subscribe}',
                        );
                        Navigator.pop(sheetContext);
                      }),
                    ),
                  ],
                ),
                const SeedDivider(),
                SeedSwitch(
                  label: 'Push 이후에도 BottomSheet 마운트 유지',
                  checked: keepMounted,
                  onCheckedChange: (value) =>
                      refresh(() => keepMounted = value),
                ),
                _choices(
                  const [
                    'slideFromRightIOS',
                    'fadeFromBottomAndroid',
                    'fadeIn',
                  ],
                  transition,
                  (value) => refresh(() => transition = value),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _button('ActivityDetail', () {
                        widget.navigate(
                          'ActivityDetail',
                          arguments: {
                            'title': 'ActivityDetail',
                            'body': keepMounted
                                ? 'BottomSheet가 유지되므로 입력한 이름과 체크 상태를 보존합니다.'
                                : '화면을 다시 열면 BottomSheet의 입력값이 초기화됩니다.',
                            'transitionStyle': transition,
                          },
                        );
                      }),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _button('ActivityHome', () {
                        widget.navigate(
                          'ActivityHome',
                          arguments: {'transitionStyle': transition},
                        );
                      }),
                    ),
                  ],
                ),
              ], gap: 8),
            ),
          ),
        ),
      );
    } finally {
      nameController.dispose();
    }
  }

  Future<void> _openNameSheet() async {
    final nameController = TextEditingController();
    try {
      await showSeedBottomSheet<void>(
        context: context,
        child: Builder(
          builder: (sheetContext) => SeedBottomSheet(
            title: '이름 입력',
            showHandle: true,
            showCloseButton: false,
            content: SeedTextField(
              controller: nameController,
              label: '이름',
              placeholder: '이름을 입력하세요',
            ),
            footer: _button('제출', () {
              _notify(context, '입력한 이름: ${nameController.text}');
              Navigator.pop(sheetContext);
            }),
          ),
        ),
      );
    } finally {
      nameController.dispose();
    }
  }

  Future<void> _openChatSheet() async {
    const rooms = [
      ('잠실엘스', '145명', 'L'),
      ('Fufuf', '1명', 'F'),
      ('Rfwfwfwfaf', '1명', 'R'),
      ('실거주 인증 채팅방', '9명', '채'),
    ];
    String? selected;
    final controller = SeedSheetController();
    final messageFocus = FocusNode();
    try {
      await showSeedBottomSheet<void>(
        context: context,
        snapPoints: const [
          SeedSheetSnapPoint.fraction(.5),
          SeedSheetSnapPoint.fraction(.85),
        ],
        snapController: controller,
        child: SeedBottomSheet(
          title: '같이해요 공유',
          showHandle: true,
          expand: true,
          content: StatefulBuilder(
            builder: (sheetContext, refresh) => _column([
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final room in rooms)
                      Padding(
                        padding: const EdgeInsets.only(right: 14),
                        child: InkWell(
                          onTap: () {
                            refresh(() => selected = room.$1);
                            controller.snapTo(1);
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (sheetContext.mounted) {
                                messageFocus.requestFocus();
                              }
                            });
                          },
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: selected == room.$1
                                    ? Colors.blue.shade200
                                    : Colors.purple.shade100,
                                child: Text(room.$3),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: 78,
                                child: Text(
                                  room.$1,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Text(room.$2),
                              if (selected == room.$1)
                                const Icon(Icons.check, size: 18),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (selected != null)
                SeedTextField(
                  key: ValueKey(selected),
                  focusNode: messageFocus,
                  label: '$selected에 보낼 메시지',
                  placeholder: '메시지를 입력해 주세요. (선택)',
                ),
            ], gap: 24),
          ),
          footer: const Text(
            '채팅방을 선택하면 더 큰 snap point로 확장됩니다.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    } finally {
      controller.dispose();
      messageFocus.dispose();
    }
  }

  Future<void> _openKeyboardPlayground() async {
    String contentMode = 'short';
    String fieldMode = 'single';
    bool fixed = false;
    bool snap = false;
    bool reposition = true;
    final sheetKey = GlobalKey();
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '닫기',
      barrierColor: Colors.black54,
      pageBuilder: (_, animation, secondaryAnimation) => StatefulBuilder(
        builder: (sheetContext, refresh) {
          Widget fields = switch (fieldMode) {
            'multiple' => _column(const [
              SeedTextField(
                label: 'First',
                placeholder: 'Tap here, then jump to the next',
              ),
              SeedTextField(
                label: 'Second',
                placeholder: 'Keyboard should stay up',
              ),
            ]),
            'textarea' => const SeedTextField.textarea(
              label: 'Memo',
              placeholder: 'Type several lines and watch the height',
            ),
            'editable' => const SeedTextField.textarea(
              label: 'contentEditable',
              placeholder: 'Tap to focus',
            ),
            'no-keyboard' => _column([
              const SeedCheckbox(label: 'checkbox (no keyboard)'),
              _button('button input (no keyboard)', () {}),
            ]),
            _ => const SeedTextField(
              label: 'Name',
              placeholder: 'Tap to raise the keyboard',
            ),
          };
          final media = MediaQuery.of(sheetContext);
          final sheet = SeedBottomSheet(
            key: sheetKey,
            expand: fixed,
            title: 'Keyboard playground',
            showHandle: true,
            showCloseButton: false,
            content: _column([
              Text(
                'screen ${media.size.height.toStringAsFixed(0)}px · '
                'keyboard ${media.viewInsets.bottom.toStringAsFixed(0)}px · '
                'visible ${(media.size.height - media.viewInsets.bottom).toStringAsFixed(0)}px',
              ),
              _SheetMetrics(sheetKey: sheetKey),
              _section(
                'content',
                _choices(
                  const ['short', 'tall', 'scroll'],
                  contentMode,
                  (value) => refresh(() => contentMode = value),
                ),
              ),
              _section(
                'field',
                _choices(
                  const [
                    'single',
                    'multiple',
                    'textarea',
                    'editable',
                    'no-keyboard',
                  ],
                  fieldMode,
                  (value) => refresh(() => fieldMode = value),
                ),
              ),
              _section(
                'drawer props',
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _button(
                      'fixed: ${fixed ? "on" : "off"}',
                      () => refresh(() => fixed = !fixed),
                    ),
                    _button(
                      'snapPoints: ${snap ? "on" : "off"}',
                      () => refresh(() => snap = !snap),
                    ),
                    _button(
                      'repositionInputs: ${reposition ? "on" : "off"}',
                      () => refresh(() => reposition = !reposition),
                    ),
                  ],
                ),
              ),
              Text(
                'Keyboard Insets는 Flutter MediaQuery로 측정합니다. '
                '${fixed ? "Fixed" : "Natural"} / '
                '${snap ? "Snap enabled" : "Snap disabled"} / '
                '${reposition ? "Auto reposition" : "Manual"}',
              ),
              if (contentMode == 'scroll')
                SizedBox(
                  height: 160,
                  child: SingleChildScrollView(
                    child: _playgroundFields(fields, 14),
                  ),
                )
              else
                _playgroundFields(fields, contentMode == 'tall' ? 8 : 0),
            ]),
            footer: _button('Close', () => Navigator.pop(sheetContext)),
          );
          final keyboard = reposition ? media.viewInsets.bottom : 0.0;
          Widget surface = snap
              ? SeedSnappingBottomSheet(
                  sheet: sheet,
                  snapPoints: const [
                    SeedSheetSnapPoint.fraction(.5),
                    SeedSheetSnapPoint.fraction(.9),
                  ],
                  initialSnapIndex: 0,
                  dismissible: true,
                )
              : sheet;
          surface = Padding(
            padding: EdgeInsets.only(bottom: keyboard),
            child: surface,
          );
          return MediaQuery(
            data: media.copyWith(
              viewInsets: reposition ? media.viewInsets : EdgeInsets.zero,
            ),
            child: Align(alignment: Alignment.bottomCenter, child: surface),
          );
        },
      ),
    );
  }

  Widget _playgroundFields(Widget fields, int count) => _column([
    fields,
    for (var i = 0; i < count; i++)
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: .13),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text('filler ${i + 1}'),
      ),
  ]);

  Future<void> _openMenuSheet() async {
    final swipeable = widget.activity == 'ActivitySwipeableMenuSheet';
    _result = await showSeedMenuSheet<Map<String, String>>(
      context: context,
      enableDrag: swipeable,
      closeOnSelect: false,
      title: 'Actions',
      groups: [
        SeedMenuGroupData(
          items: [
            SeedMenuItemData(
              label: 'Add',
              prefixIcon: const Icon(Icons.add),
              onTap: () {
                if (swipeable) _notify(context, '선택한 액션: add');
                Navigator.of(context).pop({'action': 'add'});
              },
            ),
            SeedMenuItemData(
              label: 'Edit Proident pariatur do cillum labore nisi ex velit fugiat laboris pariatur consequat mollit ex culpa cillum.',
              description: 'Aliqua reprehenderit nostrud ea laborum. Aliquip qui sint amet nulla aliqua mollit consequat sint nostrud cupidatat nisi.',
              prefixIcon: const Icon(Icons.edit),
              onTap: () {
                if (swipeable) _notify(context, '선택한 액션: edit');
                Navigator.of(context).pop({'action': 'edit'});
              },
            ),
          ],
        ),
        SeedMenuGroupData(
          items: [
            SeedMenuItemData(
              label: 'Test1',
              onTap: () {
                if (swipeable) _notify(context, '선택한 액션: test1');
                Navigator.of(context).pop({'action': 'test1'});
              },
            ),
            SeedMenuItemData(
              label: 'Test2',
              onTap: () {
                if (swipeable) _notify(context, '선택한 액션: test2');
                Navigator.of(context).pop({'action': 'test2'});
              },
            ),
            SeedMenuItemData(
              label: 'Adipisicing commodo et ex ad reprehenderit. Excepteur sint aute voluptate id.',
              isDestructive: true,
              onTap: () {
                if (swipeable) _notify(context, '선택한 액션: delete');
                Navigator.of(context).pop({'action': 'delete'});
              },
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _openSimpleMenuSheet() async {
    _result = await showSeedMenuSheet<Map<String, String>>(
      context: context,
      closeOnSelect: false,
      enableDrag: false,
      title: 'Actions',
      groups: [
        SeedMenuGroupData(
          items: [
            SeedMenuItemData(
              label: '추가',
              prefixIcon: const Icon(Icons.add),
              onTap: () => Navigator.of(context).pop({'action': 'add'}),
            ),
            SeedMenuItemData(
              label: '수정',
              prefixIcon: const Icon(Icons.edit),
              onTap: () => Navigator.of(context).pop({'action': 'edit'}),
            ),
            SeedMenuItemData(
              label: '삭제',
              prefixIcon: const Icon(Icons.delete),
              isDestructive: true,
              onTap: () => Navigator.of(context).pop({'action': 'delete'}),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _openSidePanel() async {
    final responsive = widget.activity == 'ActivityResponsiveSidePanel';
    String direction = 'right';
    String size = 'medium';
    bool showTitle = true,
        showDescription = true,
        showCloseButton = true,
        showFooter = true;
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '닫기',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (dialogContext, animation, secondaryAnimation) =>
          StatefulBuilder(
            builder: (ctx, refresh) {
              final compact = responsive && MediaQuery.sizeOf(ctx).width < 768;
              final title = responsive ? 'Responsive Side Panel' : 'Side Panel';
              final description = responsive
                  ? 'md 이상에서는 Side Panel, sm 이하에서는 Bottom Sheet로 표시됩니다. 뷰포트를 줄여서 자동 전환을 확인해보세요.'
                  : 'Side Panel 컴포넌트 데모입니다.';
              final body = _column([
                if (!responsive)
                  Text(
                    List.filled(
                      32,
                      'Exercitation sint voluptate sunt minim ut eiusmod deserunt consectetur elit sit ex. Duis eiusmod non exercitation commodo mollit non elit consequat anim. ',
                    ).join(),
                  ),
                if (!responsive)
                  _section(
                    '패널 방향',
                    _choices(
                      const ['left', 'right'],
                      direction,
                      (next) => refresh(() => direction = next),
                    ),
                  ),
                _section(
                  '패널 크기',
                  SeedSegmentedControl<String>(
                    segments: const [
                      SeedSegment(value: 'small', label: 'Small'),
                      SeedSegment(value: 'medium', label: 'Medium'),
                      SeedSegment(value: 'large', label: 'Large'),
                    ],
                    value: size,
                    onValueChange: (next) => refresh(() => size = next),
                  ),
                ),
                if (!responsive) ...[
                  SeedSwitch(
                    label: '제목 표시',
                    checked: showTitle,
                    onCheckedChange: (v) => refresh(() => showTitle = v),
                  ),
                  SeedSwitch(
                    label: '설명 표시',
                    checked: showDescription,
                    onCheckedChange: (v) => refresh(() => showDescription = v),
                  ),
                  SeedSwitch(
                    label: '닫기 버튼 표시',
                    checked: showCloseButton,
                    onCheckedChange: (v) => refresh(() => showCloseButton = v),
                  ),
                  SeedSwitch(
                    label: '푸터 표시',
                    checked: showFooter,
                    onCheckedChange: (v) => refresh(() => showFooter = v),
                  ),
                ],
              ]);
              final footer = showFooter || responsive
                  ? _column([
                      _button(
                        '닫기',
                        () => Navigator.pop(ctx),
                        variant: SeedButtonVariant.neutralWeak,
                      ),
                      _button('확인', () => Navigator.pop(ctx)),
                    ], gap: 8)
                  : null;
              if (compact) {
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: SeedBottomSheet(
                    title: title,
                    description: description,
                    showHandle: true,
                    content: body,
                    footer: footer,
                  ),
                );
              }
              return Align(
                alignment: direction == 'right'
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: SeedSidePanel(
                  title: showTitle || responsive ? title : '',
                  description: showDescription || responsive
                      ? description
                      : null,
                  fromRight: direction == 'right',
                  size: switch (size) {
                    'small' => SeedSidePanelSize.small,
                    'large' => SeedSidePanelSize.large,
                    _ => SeedSidePanelSize.medium,
                  },
                  showCloseButton: showCloseButton,
                  onClose: () => Navigator.pop(ctx),
                  body: body,
                  footer: footer,
                ),
              );
            },
          ),
      transitionBuilder: (ctx, animation, secondaryAnimation, child) =>
          SlideTransition(
            position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          ),
    );
  }

  Future<void> _openResponsiveDialog() async {
    String size = 'medium';
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '닫기',
      barrierColor: Colors.black54,
      pageBuilder: (dialogContext, animation, secondaryAnimation) =>
          StatefulBuilder(
            builder: (ctx, refresh) {
              final compact = MediaQuery.sizeOf(ctx).width < 768;
              final content = SeedSegmentedControl<String>(
                segments: const [
                  SeedSegment(value: 'medium', label: 'Medium'),
                  SeedSegment(value: 'large', label: 'Large'),
                ],
                value: size,
                onValueChange: (next) => refresh(() => size = next),
              );
              final footer = Row(
                children: [
                  Expanded(
                    child: _button(
                      '취소',
                      () => Navigator.pop(ctx),
                      variant: SeedButtonVariant.neutralWeak,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: _button('확인', () => Navigator.pop(ctx))),
                ],
              );
              if (compact) {
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: SeedBottomSheet(
                    title: 'Responsive Dialog',
                    description: 'md 이상에서는 Dialog, sm 이하에서는 Bottom Sheet로 표시됩니다. 뷰포트를 줄여서 자동 전환을 확인해보세요.',
                    showHandle: true,
                    content: content,
                    footer: footer,
                  ),
                );
              }
              return SeedDialog(
                title: 'Responsive Dialog',
                description: 'md 이상에서는 Dialog, sm 이하에서는 Bottom Sheet로 표시됩니다. 뷰포트를 줄여서 자동 전환을 확인해보세요.',
                size: size == 'large'
                    ? SeedDialogSize.large
                    : SeedDialogSize.medium,
                content: content,
                footer: footer,
              );
            },
          ),
    );
  }

  Future<void> _openModalTest() async {
    final modal = ValueNotifier(true);
    try {
      await showSeedBottomSheet<void>(
        context: context,
        modalListenable: modal,
        child: StatefulBuilder(
          builder: (ctx, refresh) => SeedBottomSheet(
            title: 'BottomSheet Modal Prop 테스트',
            description: 'modal prop을 동적으로 변경할 때 애니메이션이 재실행되지 않는지 테스트합니다.',
            headerAlign: SeedBottomSheetHeaderAlign.center,
            showHandle: true,
            showCloseButton: false,
            content: _column([
              const Text(
                '이 화면은 BottomSheet의 modal prop을 동적으로 변경할 때 애니메이션이 재실행되지 않는지 테스트하기 위한 화면입니다.',
              ),
              Text('현재 modal: ${modal.value}'),
              SeedSwitch(
                label: 'modal prop 토글',
                checked: modal.value,
                onCheckedChange: (v) => refresh(() => modal.value = v),
              ),
              _button('닫기', () => Navigator.pop(ctx)),
            ]),
          ),
        ),
      );
    } finally {
      modal.dispose();
    }
  }

  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}

class _ActivityAlertDialog extends StatefulWidget {
  const _ActivityAlertDialog({required this.navigate});
  final SpaNavigate navigate;
  @override
  State<_ActivityAlertDialog> createState() => _ActivityAlertDialogState();
}

class _ActivityAlertDialogState extends State<_ActivityAlertDialog> {
  bool keepMounted = false;
  @override
  Widget build(BuildContext context) => _RoutePresence(
    keepMounted: keepMounted,
    child: SeedAlertDialog(
      title: '제목',
      description: '다람쥐 헌 쳇바퀴에 타고파',
      footer: _column([
        Row(
          children: [
            Expanded(
              child: _button(
                '확인',
                () => Navigator.pop(context, {'message': 'hello'}),
                variant: SeedButtonVariant.neutralWeak,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _button('Push', () {
                widget.navigate(
                  'ActivityDetail',
                  arguments: {
                    'title': 'AlertDialog에서 Push됨',
                    'body': keepMounted
                        ? 'AlertDialog가 유지되므로 현재 Activity를 pop하면 다시 표시됩니다.'
                        : 'AlertDialog를 재진입하면 enter 애니메이션이 다시 실행됩니다.',
                  },
                );
              }),
            ),
          ],
        ),
        SeedSwitch(
          label: 'Push 이후에도 AlertDialog 마운트 유지',
          checked: keepMounted,
          onCheckedChange: (value) => setState(() => keepMounted = value),
        ),
      ]),
    ),
  );
}

class _SheetDialogStepPage extends StatelessWidget {
  const _SheetDialogStepPage();
  @override
  Widget build(BuildContext context) => _demoScroll([
    _section(
      'Step 패턴',
      const Text(
        'useStepOverlay로 BottomSheet step과 AlertDialog step을 한 Activity 안에서 동시에 사용합니다. '
        '시트 위에 다이얼로그를 얹어 Backdrop과 내부 빈 영역을 확인해보세요.',
      ),
    ),
    _button('Open BottomSheet', () {
      showSeedBottomSheet<void>(
        context: context,
        child: Builder(
          builder: (sheetContext) => SeedBottomSheet(
            showHandle: true,
            title: 'BottomSheet (step)',
            description: '이 BottomSheet 위에 AlertDialog를 얹어볼 수 있어요.',
            content: _button('Open AlertDialog', () {
              showSeedDialog<void>(
                context: sheetContext,
                barrierDismissible: true,
                child: Builder(
                  builder: (dialogContext) => SeedAlertDialog(
                    title: '제목',
                    description:
                        'AlertDialog Backdrop 또는 Content 빈 영역을 클릭해 동작을 관찰해보세요.',
                    footer: _button('닫기', () => Navigator.pop(dialogContext)),
                  ),
                ),
              );
            }),
            footer: _button(
              '닫기',
              () => Navigator.pop(sheetContext),
              variant: SeedButtonVariant.neutralWeak,
            ),
          ),
        ),
      );
    }),
  ]);
}

class _AlertDialogStepPage extends StatelessWidget {
  const _AlertDialogStepPage({required this.navigate});
  final SpaNavigate navigate;

  @override
  Widget build(BuildContext context) => _demoScroll([
    _button('Alert Dialog 열기', () {
      showSeedDialog<void>(
        context: context,
        child: Builder(
          builder: (dialogContext) => SeedAlertDialog(
            title: 'Step',
            description: 'Alert Dialog가 Step으로 만들어져 있기 때문에 뒤로 가기로 닫을 수 있습니다.',
            footer: Row(
              children: [
                Expanded(
                  child: _button(
                    '닫기',
                    () => Navigator.pop(dialogContext),
                    variant: SeedButtonVariant.neutralWeak,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _button('Push', () {
                    Navigator.pop(dialogContext);
                    navigate(
                      'ActivityDetail',
                      arguments: {
                        'title': 'Alert Dialog에서 이동한 화면',
                        'body': 'Alert Dialog를 닫고 이동했습니다.',
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      );
    }),
  ]);
}

/// The React Activity examples are plain screens that push a modal activity or
/// another copy of themselves. The SPA shell already owns the top app bar.
class _ActivityLaunchPage extends StatelessWidget {
  const _ActivityLaunchPage({
    required this.activity,
    required this.overlayActivity,
    required this.navigate,
  });

  final String activity;
  final String overlayActivity;
  final SpaNavigate navigate;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(20),
    child: Center(
      child: _column([
        _button(
          '$overlayActivity${overlayActivity == 'ActivityBottomSheet' ? '을' : '를'} Push',
          () => navigate(overlayActivity),
        ),
        _button(
          '지금 열린 이 Activity를 Push',
          () => navigate(activity),
          variant: SeedButtonVariant.neutralWeak,
        ),
        _button(
          'Home',
          () => navigate('ActivityHome'),
          variant: SeedButtonVariant.neutralWeak,
        ),
      ], gap: 16),
    ),
  );
}

class _BottomSheetStepPage extends StatelessWidget {
  const _BottomSheetStepPage({required this.navigate});
  final SpaNavigate navigate;

  @override
  Widget build(BuildContext context) => _demoScroll([
    _button('Bottom Sheet 열기', () {
      showSeedBottomSheet<void>(
        context: context,
        child: Builder(
          builder: (sheetContext) => SeedBottomSheet(
            title: 'Step',
            showHandle: true,
            description: 'Bottom Sheet가 Step으로 만들어져 있기 때문에 뒤로 가기로 닫을 수 있습니다.',
            content: const SizedBox.shrink(),
            footer: Row(
              children: [
                Expanded(
                  child: _button(
                    '닫기',
                    () => Navigator.pop(sheetContext),
                    variant: SeedButtonVariant.neutralWeak,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _button('Push', () {
                    Navigator.pop(sheetContext);
                    navigate(
                      'ActivityDetail',
                      arguments: {
                        'title': 'Bottom Sheet에서 이동한 화면',
                        'body': 'Bottom Sheet를 닫고 이동했습니다.',
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      );
    }),
  ]);
}

class _MenuSheetStepPage extends StatelessWidget {
  const _MenuSheetStepPage({required this.navigate});
  final SpaNavigate navigate;

  @override
  Widget build(BuildContext context) => _demoScroll([
    _button('Menu Sheet 열기', () {
      showSeedMenuSheet<void>(
        context: context,
        title: 'Step',
        groups: [
          SeedMenuGroupData(
            items: [
              SeedMenuItemData(
                label: '추가',
                prefixIcon: const Icon(Icons.add),
                onTap: () => _notify(context, '선택한 액션: add'),
              ),
              SeedMenuItemData(
                label: '수정',
                prefixIcon: const Icon(Icons.edit),
                onTap: () => _notify(context, '선택한 액션: edit'),
              ),
              SeedMenuItemData(
                label: '삭제',
                prefixIcon: const Icon(Icons.delete),
                isDestructive: true,
                onTap: () => _notify(context, '선택한 액션: delete'),
              ),
            ],
          ),
          SeedMenuGroupData(
            items: [
              SeedMenuItemData(
                label: 'Push',
                onTap: () {
                  // Queue the route after menu item dispatch and modal dismissal.
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (context.mounted) {
                      navigate(
                        'ActivityDetail',
                        arguments: {
                          'title': 'Menu Sheet에서 이동한 화면',
                          'body': 'Menu Sheet를 닫고 이동했습니다.',
                        },
                      );
                    }
                  });
                },
              ),
            ],
          ),
        ],
      );
    }),
  ]);
}

class _MenuDemoPage extends StatefulWidget {
  const _MenuDemoPage({required this.navigate});
  final SpaNavigate navigate;

  @override
  State<_MenuDemoPage> createState() => _MenuDemoPageState();
}

class _MenuDemoPageState extends State<_MenuDemoPage> {
  bool _anchorOpen = false;
  String _lastReason = '-';

  List<SeedMenuGroupData> _basicGroups() => [
    SeedMenuGroupData(
      label: '작업',
      items: [
        const SeedMenuItemData(label: '라이브러리에 추가', prefixIcon: Icon(Icons.add)),
        const SeedMenuItemData(
          label: '수정',
          description: '현재 항목을 수정합니다',
          prefixIcon: Icon(Icons.edit),
        ),
        const SeedMenuItemData(
          label: '공유',
          description: '다른 사람과 공유합니다',
          prefixIcon: Icon(Icons.share),
        ),
        const SeedMenuItemData(
          label: '비활성 항목',
          enabled: false,
          prefixIcon: Icon(Icons.add),
        ),
      ],
    ),
    const SeedMenuGroupData(
      items: [
        SeedMenuItemData(
          label: '삭제',
          description: '이 작업은 되돌릴 수 없습니다',
          prefixIcon: Icon(Icons.delete),
          isDestructive: true,
        ),
      ],
    ),
  ];

  Widget _menuButton(
    String label,
    List<SeedMenuGroupData> groups, {
    SeedMenuSize size = SeedMenuSize.medium,
    SeedOverlaySide side = SeedOverlaySide.bottom,
    SeedOverlayAlign align = SeedOverlayAlign.start,
    double maxHeight = 480,
    SeedOverlayOpenChanged? onOpenChange,
  }) => SeedMenuTrigger(
    side: side,
    align: align,
    onOpenChange: onOpenChange,
    triggerBuilder: (context, open, toggle) =>
        _button(label, toggle, variant: SeedButtonVariant.brandSolid),
    builder: (ctx) =>
        SeedMenu(groups: groups, size: size, maxHeight: maxHeight),
  );

  void _openSheet(BuildContext context, {bool showMenu = false}) {
    showSeedBottomSheet<void>(
      context: context,
      child: Builder(
        builder: (sheetContext) => SeedBottomSheet(
          title: showMenu ? 'Menu in BottomSheet' : 'Menu에서 열림',
          showHandle: true,
          content: Text(
            showMenu
                ? 'BottomSheet 내부에서 Menu를 열 수 있습니다.'
                : 'Menu item 클릭으로 열린 BottomSheet입니다.',
          ),
          footer: showMenu
              ? _menuButton('Open Menu', [
                  const SeedMenuGroupData(
                    items: [
                      SeedMenuItemData(
                        label: '추가',
                        prefixIcon: Icon(Icons.add),
                      ),
                      SeedMenuItemData(
                        label: '수정',
                        prefixIcon: Icon(Icons.edit),
                      ),
                      SeedMenuItemData(
                        label: '공유',
                        prefixIcon: Icon(Icons.share),
                      ),
                    ],
                  ),
                  const SeedMenuGroupData(
                    items: [SeedMenuItemData(label: '삭제', isDestructive: true)],
                  ),
                ])
              : null,
        ),
      ),
    );
  }

  void _openDialogWithMenu() {
    showSeedDialog<void>(
      context: context,
      child: Builder(
        builder: (dialogContext) => SeedAlertDialog(
          title: 'Menu in AlertDialog',
          description: 'AlertDialog 내부에서 Menu를 열 수 있습니다.',
          footer: Row(
            children: [
              Expanded(
                child: _menuButton('Open Menu', [
                  const SeedMenuGroupData(
                    items: [
                      SeedMenuItemData(
                        label: '추가',
                        prefixIcon: Icon(Icons.add),
                      ),
                      SeedMenuItemData(
                        label: '수정',
                        prefixIcon: Icon(Icons.edit),
                      ),
                    ],
                  ),
                ]),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _button('확인', () => Navigator.pop(dialogContext)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.seedColor.bg.layerDefault,
    appBar: SeedTopNavigation(
      titleText: 'Menu',
      centerTitle: false,
      actions: [
        SeedMenuTrigger(
          triggerBuilder: (ctx, open, toggle) => SeedTopNavigationIconButton(
            semanticsLabel: '알림',
            icon: const Icon(Icons.notifications_none),
            onPressed: toggle,
          ),
          builder: (ctx) => SeedMenu(
            groups: const [
              SeedMenuGroupData(
                label: '알림',
                items: [
                  SeedMenuItemData(label: '모두 읽음 처리'),
                  SeedMenuItemData(label: '알림 설정'),
                ],
              ),
            ],
          ),
        ),
        SeedMenuTrigger(
          align: SeedOverlayAlign.end,
          triggerBuilder: (ctx, open, toggle) => SeedTopNavigationIconButton(
            semanticsLabel: '더보기',
            icon: const Icon(Icons.more_vert),
            onPressed: toggle,
          ),
          builder: (ctx) => SeedMenu(
            groups: [
              SeedMenuGroupData(
                items: [
                  const SeedMenuItemData(
                    label: '공유',
                    prefixIcon: Icon(Icons.ios_share),
                  ),
                  const SeedMenuItemData(
                    label: '북마크',
                    prefixIcon: Icon(Icons.bookmark_outline),
                  ),
                  SeedMenuItemData(
                    label: '홈으로 이동',
                    prefixIcon: const Icon(Icons.home_outlined),
                    onTap: () => widget.navigate('ActivityHome'),
                  ),
                ],
              ),
              const SeedMenuGroupData(
                items: [
                  SeedMenuItemData(
                    label: '신고',
                    isDestructive: true,
                    prefixIcon: Icon(Icons.flag_outlined),
                  ),
                ],
              ),
            ],
          ),
        ),
        SeedTopNavigationIconButton(
          semanticsLabel: 'Home',
          icon: const Icon(Icons.home_outlined),
          onPressed: () => widget.navigate('ActivityHome'),
        ),
      ],
    ),
    body: _demoScroll([
      _section(
        'Basic Trigger',
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _menuButton('Medium', _basicGroups()),
            _menuButton('Small', const [
              SeedMenuGroupData(
                items: [
                  SeedMenuItemData(label: '추가', prefixIcon: Icon(Icons.add)),
                  SeedMenuItemData(label: '수정', prefixIcon: Icon(Icons.edit)),
                  SeedMenuItemData(
                    label: '삭제',
                    prefixIcon: Icon(Icons.delete),
                    isDestructive: true,
                  ),
                ],
              ),
            ], size: SeedMenuSize.small),
          ],
        ),
      ),
      _section(
        'Placement',
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _menuButton('bottom-start', _basicGroups()),
            _menuButton(
              'bottom-end',
              _basicGroups(),
              align: SeedOverlayAlign.end,
            ),
            _menuButton(
              'top',
              _basicGroups(),
              side: SeedOverlaySide.top,
              align: SeedOverlayAlign.center,
            ),
          ],
        ),
      ),
      _section(
        'Anchor (Controlled)',
        Row(
          children: [
            Expanded(
              child: SeedSwitch(
                label: '메뉴',
                checked: _anchorOpen,
                onCheckedChange: (v) => setState(() => _anchorOpen = v),
              ),
            ),
            SeedMenuTrigger(
              open: _anchorOpen,
              onOpenChange: (next, reason) {
                if (!next && reason == SeedOverlayDismissReason.outside) return;
                setState(() => _anchorOpen = next);
              },
              triggerBuilder: (ctx, open, toggle) => const CircleAvatar(
                radius: 36,
                child: Icon(Icons.person, size: 40),
              ),
              builder: (ctx) => const SeedMenu(
                groups: [
                  SeedMenuGroupData(
                    items: [
                      SeedMenuItemData(label: '프로필 보기'),
                      SeedMenuItemData(label: '메시지 보내기'),
                    ],
                  ),
                  SeedMenuGroupData(
                    items: [
                      SeedMenuItemData(
                        label: '숨기기',
                        prefixIcon: Icon(Icons.visibility_off),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      _section(
        'Many Items (Scroll)',
        _menuButton('30개 항목', [
          SeedMenuGroupData(
            label: 'Recently Played',
            items: [
              for (var i = 1; i <= 30; i++) SeedMenuItemData(label: 'Track $i'),
            ],
          ),
        ]),
      ),
      _section(
        'Max Height',
        _menuButton('30개 항목 (높이 제한)', [
          SeedMenuGroupData(
            label: 'Recently Played',
            items: [
              for (var i = 1; i <= 30; i++) SeedMenuItemData(label: 'Track $i'),
            ],
          ),
        ], maxHeight: 160),
        hint: '메뉴의 높이를 160px로 제한합니다.',
      ),
      _section(
        'onOpenChange Reason',
        Row(
          children: [
            _menuButton(
              'Reason 추적',
              const [
                SeedMenuGroupData(items: [SeedMenuItemData(label: '항목')]),
              ],
              onOpenChange: (open, reason) {
                setState(() => _lastReason = reason.name);
              },
            ),
            const SizedBox(width: 16),
            Expanded(child: Text('마지막: $_lastReason')),
          ],
        ),
      ),
      _section(
        'Menu → BottomSheet',
        _menuButton('메뉴에서 시트 열기', [
          SeedMenuGroupData(
            items: [
              const SeedMenuItemData(label: '추가', prefixIcon: Icon(Icons.add)),
              SeedMenuItemData(
                label: 'BottomSheet 열기',
                prefixIcon: const Icon(Icons.ios_share),
                onTap: () => WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _openSheet(context);
                }),
              ),
            ],
          ),
        ]),
      ),
      _section(
        'Menu in BottomSheet',
        _button('BottomSheet 열기', () => _openSheet(context, showMenu: true)),
      ),
      _section(
        'Menu in AlertDialog',
        _button('AlertDialog 열기', _openDialogWithMenu),
      ),
      _section(
        'Navigation',
        _menuButton('더보기', [
          SeedMenuGroupData(
            items: [
              const SeedMenuItemData(
                label: '공유',
                prefixIcon: Icon(Icons.share),
              ),
              const SeedMenuItemData(
                label: '북마크',
                prefixIcon: Icon(Icons.bookmark),
              ),
              SeedMenuItemData(
                label: '홈으로 이동',
                prefixIcon: const Icon(Icons.home),
                onTap: () => widget.navigate('ActivityHome'),
              ),
            ],
          ),
          const SeedMenuGroupData(
            items: [
              SeedMenuItemData(
                label: '신고',
                isDestructive: true,
                prefixIcon: Icon(Icons.flag),
              ),
            ],
          ),
        ]),
      ),
    ]),
  );
}

class _HelpBubbleDemoPage extends StatefulWidget {
  const _HelpBubbleDemoPage();

  @override
  State<_HelpBubbleDemoPage> createState() => _HelpBubbleDemoPageState();
}

class _HelpBubbleDemoPageState extends State<_HelpBubbleDemoPage> {
  double triggerWidth = 40;
  static const _longDescription =
      '당근은 동네 이웃과 따뜻한 거래를 나누는 공간이에요. 중고 거래부터 동네 가게, 알바, 부동산까지 '
      '우리 동네의 다양한 소식을 만나보세요. 이 도움말은 컨텐츠가 길 때 말풍선이 세로로 얼마나 '
      '늘어나는지 확인하기 위한 예시예요. 가로 너비는 제한하고 세로 넘침은 flip과 shift가 처리합니다.';
  static const _portalDescription = '말풍선을 포털로 렌더링하며 화면 너비를 넘지 않도록 조정합니다.';

  Widget _helpButton(
    String label, {
    String? title,
    String? description,
    SeedOverlaySide side = SeedOverlaySide.top,
    SeedOverlayAlign align = SeedOverlayAlign.center,
    bool flip = true,
    bool showCloseButton = false,
    bool dismissOutside = true,
  }) => SeedHelpBubbleTrigger(
    title: title ?? label,
    description: description,
    side: side,
    align: align,
    flip: flip,
    showCloseButton: showCloseButton,
    closeOnInteractOutside: dismissOutside,
    triggerBuilder: (context, open, toggle) =>
        _button(label, toggle, variant: SeedButtonVariant.brandSolid),
  );

  void _showSheet() {
    showSeedBottomSheet<void>(
      context: context,
      child: Builder(
        builder: (ctx) => SeedBottomSheet(
          title: 'BottomSheet',
          showHandle: true,
          content: const Text(
            '왼쪽 말풍선은 Escape나 바깥 탭 한 번에 말풍선만 닫히고 시트는 남아 있어야 해요. '
            '오른쪽은 바깥 탭으로 닫히지 않으니 시트를 닫으면 함께 닫혀야 합니다.',
          ),
          footer: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _helpButton(
                '기본',
                title: 'sheet 위의 help bubble',
                description: '시트 스크림 위로 올라와야 해요.',
              ),
              _helpButton(
                '바깥 탭 무시',
                title: 'closeOnInteractOutside=false',
                description: '시트를 닫으면 함께 닫혀야 해요.',
                dismissOutside: false,
              ),
              _button('시트 닫기', () => Navigator.pop(ctx)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => _demoScroll([
    Center(
      child: _button(
        'BottomSheet 안에서 테스트',
        _showSheet,
        variant: SeedButtonVariant.brandSolid,
      ),
    ),
    for (final demo
        in <
          ({
            String label,
            SeedOverlaySide side,
            SeedOverlayAlign align,
            bool flip,
            bool close,
            String? description,
          })
        >[
          (
            label: 'Flip 테스트',
            side: SeedOverlaySide.top,
            align: SeedOverlayAlign.center,
            flip: true,
            close: false,
            description: null,
          ),
          (
            label: 'Flip off 테스트',
            side: SeedOverlaySide.top,
            align: SeedOverlayAlign.center,
            flip: false,
            close: false,
            description: null,
          ),
          (
            label: 'Slide 테스트',
            side: SeedOverlaySide.top,
            align: SeedOverlayAlign.center,
            flip: true,
            close: false,
            description: '어흥어흥어흥어흥 야옹야옹야옹야옹야옹야옹',
          ),
          (
            label: 'Close Button 테스트',
            side: SeedOverlaySide.top,
            align: SeedOverlayAlign.center,
            flip: true,
            close: true,
            description: '어흥어흥어흥어흥 야옹야옹야옹야옹야옹야옹',
          ),
          (
            label: 'Placement=bottom 테스트',
            side: SeedOverlaySide.bottom,
            align: SeedOverlayAlign.center,
            flip: true,
            close: false,
            description: null,
          ),
          (
            label: 'Placement=right 테스트',
            side: SeedOverlaySide.right,
            align: SeedOverlayAlign.center,
            flip: true,
            close: false,
            description: '어흥어흥어흥어흥 야옹야옹야옹야옹야옹야옹',
          ),
          (
            label: 'Placement=left 테스트',
            side: SeedOverlaySide.left,
            align: SeedOverlayAlign.center,
            flip: true,
            close: false,
            description: '어흥어흥어흥어흥 야옹야옹야옹야옹야옹야옹',
          ),
          (
            label: 'Placement=right-start 테스트',
            side: SeedOverlaySide.right,
            align: SeedOverlayAlign.start,
            flip: true,
            close: false,
            description: null,
          ),
          (
            label: 'Placement=left-end 테스트',
            side: SeedOverlaySide.left,
            align: SeedOverlayAlign.end,
            flip: true,
            close: false,
            description: null,
          ),
        ])
      Padding(
        padding: EdgeInsets.only(top: MediaQuery.sizeOf(context).height * .2),
        child: Align(
          alignment:
              demo.label == 'Slide 테스트' || demo.side == SeedOverlaySide.left
              ? Alignment.centerRight
              : demo.side == SeedOverlaySide.right
              ? Alignment.centerLeft
              : Alignment.center,
          child: _helpButton(
            demo.label,
            description: demo.description,
            side: demo.side,
            align: demo.align,
            flip: demo.flip,
            showCloseButton: demo.close,
          ),
        ),
      ),
    const SizedBox(height: 60),
    _section(
      'Trigger 너비: ${triggerWidth.round()}%',
      Slider(
        min: 20,
        max: 100,
        divisions: 80,
        value: triggerWidth,
        onChanged: (next) => setState(() => triggerWidth = next),
      ),
    ),
    FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: triggerWidth / 100,
      child: _helpButton(
        '너비 ${triggerWidth.round()}%',
        title: 'Width 조절 테스트',
        side: SeedOverlaySide.right,
        dismissOutside: false,
        description:
            'trigger를 넓혀 좌우 공간이 없어지면 top/bottom으로 폴백돼요. '
            '말풍선을 열어둔 채 슬라이더를 움직여 보세요.',
      ),
    ),
    for (final side in [SeedOverlaySide.top, SeedOverlaySide.bottom])
      Padding(
        padding: const EdgeInsets.only(top: 110),
        child: Center(
          child: _helpButton(
            '긴 컨텐츠 ${side.name} 테스트',
            title: '긴 컨텐츠 (placement=${side.name})',
            side: side,
            description: _longDescription,
          ),
        ),
      ),
    for (final side in SeedOverlaySide.values)
      Padding(
        padding: const EdgeInsets.only(top: 110),
        child: Center(
          child: _helpButton(
            'Portal (${side.name})',
            title: 'Portal placement=${side.name}',
            side: side,
            description: _portalDescription,
          ),
        ),
      ),
    Padding(
      padding: const EdgeInsets.only(top: 110),
      child: Center(
        child: SeedHelpBubbleTooltip(
          title: 'Hover 트리거 테스트',
          description: '포인터를 올리거나 키보드로 포커스해보세요.',
          maxWidth: 200,
          child: _button('Hover 트리거 테스트', () {}),
        ),
      ),
    ),
    Padding(
      padding: const EdgeInsets.only(top: 110),
      child: Center(
        child: SeedHelpBubbleTooltip(
          title: 'Portal 트리거 테스트',
          description: '포털로 body에 렌더되는 변종이에요.',
          maxWidth: 200,
          child: _button('Portal 트리거 테스트', () {}),
        ),
      ),
    ),
  ]);
}

class _PopoverDemoPage extends StatefulWidget {
  const _PopoverDemoPage();

  @override
  State<_PopoverDemoPage> createState() => _PopoverDemoPageState();
}

class _PopoverDemoPageState extends State<_PopoverDemoPage> {
  static const placements = [
    'top',
    'top-start',
    'top-end',
    'bottom',
    'bottom-start',
    'bottom-end',
    'left',
    'left-start',
    'left-end',
    'right',
    'right-start',
    'right-end',
  ];
  String placement = 'bottom';
  bool flip = true;
  bool slide = true;
  bool outerOpen = false;
  final List<String> eventLog = [];

  SeedOverlaySide _side(String value) => switch (value.split('-').first) {
    'top' => SeedOverlaySide.top,
    'left' => SeedOverlaySide.left,
    'right' => SeedOverlaySide.right,
    _ => SeedOverlaySide.bottom,
  };

  SeedOverlayAlign _align(String value) =>
      switch (value.split('-').length == 1 ? '' : value.split('-')[1]) {
        'start' => SeedOverlayAlign.start,
        'end' => SeedOverlayAlign.end,
        _ => SeedOverlayAlign.center,
      };

  void _record(String scope, bool open, SeedOverlayDismissReason reason) {
    if (!mounted) return;
    setState(() {
      eventLog.insert(0, '$scope ${open ? "open" : "close"} · ${reason.name}');
      if (eventLog.length > 8) eventLog.removeLast();
    });
  }

  Widget _popoverButton(
    String label, {
    String? title,
    String? description,
    String? bodyText,
    String placement = 'bottom',
    bool flip = true,
    bool slide = true,
    bool lazyMount = false,
    bool unmountOnExit = false,
    bool closeOnInteractOutside = true,
    bool showCloseButton = true,
    bool closeOnFocusOut = true,
    bool? open,
    SeedOverlayOpenChanged? onOpenChange,
    double maxWidth = 360,
    double maxHeight = 420,
    WidgetBuilder? customBody,
  }) => SeedPopoverTrigger(
    key: ValueKey('popover-$label'),
    open: open,
    onOpenChange: onOpenChange,
    side: _side(placement),
    align: _align(placement),
    flip: flip,
    slide: slide,
    lazyMount: lazyMount,
    unmountOnExit: unmountOnExit,
    closeOnInteractOutside: closeOnInteractOutside,
    closeOnFocusOut: closeOnFocusOut,
    maxWidth: maxWidth,
    maxHeight: maxHeight,
    triggerBuilder: (ctx, isOpen, toggle) =>
        _button(label, toggle, variant: SeedButtonVariant.neutralWeak),
    builder: (overlayContext) => SeedPopover(
      titleText: title ?? label,
      descriptionText: description,
      showCloseButton: showCloseButton,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      minWidth: 180,
      body:
          customBody?.call(overlayContext) ??
          Text(bodyText ?? 'Header / Body / Footer 구조를 가진 기본 Popover입니다.'),
      footer: Align(
        alignment: Alignment.centerRight,
        child: _button(
          '확인',
          () =>
              SeedOverlayScope.maybeOf(overlayContext)
                  ?.close(SeedOverlayDismissReason.action),
        ),
      ),
    ),
  );

  void _openLayerSheet() {
    showSeedBottomSheet<void>(
      context: context,
      child: Builder(
        builder: (ctx) => SeedBottomSheet(
          title: 'BottomSheet',
          showHandle: true,
          content: const Text('시트 안에서 popover를 열어보세요.'),
          footer: _popoverButton(
            'popover 열기',
            title: 'sheet 위의 popover',
            placement: 'top',
            bodyText: '시트 스크림 위로 올라와야 합니다.',
          ),
        ),
      ),
    );
  }

  void _openLayerDialog() {
    showSeedDialog<void>(
      context: context,
      child: Builder(
        builder: (ctx) => SeedDialog(
          title: 'Dialog',
          content: const Text('다이얼로그 안에서 popover를 열어보세요.'),
          footer: _popoverButton(
            'popover 열기',
            title: 'dialog 위의 popover',
            bodyText: 'Escape 한 번에 popover만 닫히고 dialog는 남아 있어야 합니다.',
          ),
        ),
      ),
    );
  }

  Widget _nestedPopovers() => SeedPopoverTrigger(
    open: outerOpen,
    onOpenChange: (next, reason) {
      setState(() => outerOpen = next);
      _record('outer', next, reason);
    },
    triggerBuilder: (ctx, isOpen, toggle) => _button('바깥 popover', toggle),
    builder: (ctx) => SeedPopover(
      titleText: '바깥 레이어',
      descriptionText: '여기서 안쪽 popover를 열 수 있어요',
      showCloseButton: true,
      body: const Text('Escape / 바깥 클릭 / 닫기 버튼으로 각각 닫아보세요.'),
      footer: _popoverButton(
        '안쪽 popover',
        title: '안쪽 레이어',
        placement: 'bottom-end',
        onOpenChange: (next, reason) => _record('nested', next, reason),
        customBody: (innerCtx) => _column([
          const Text('아래 버튼으로 부모 레이어를 먼저 닫으면 안쪽 레이어도 닫힙니다.'),
          _button('바깥 popover 닫기', () {
            setState(() => outerOpen = false);
            _record('outer', false, SeedOverlayDismissReason.programmatic);
          }),
        ]),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.seedColor.bg.layerDefault,
    appBar: SeedTopNavigation(
      titleText: 'Popover',
      centerTitle: false,
      actions: [
        SeedPopoverTrigger(
          align: SeedOverlayAlign.end,
          triggerBuilder: (ctx, open, toggle) => SeedTopNavigationIconButton(
            semanticsLabel: '도움말',
            icon: const Icon(Icons.help_outline),
            onPressed: toggle,
          ),
          builder: (ctx) => SeedPopover(
            titleText: 'AppBar 트리거',
            body: const Text(
              '상단 safe-area 바로 아래에서 열립니다. 노치가 있는 기기에서 잘리지 않는지 확인하세요.',
            ),
            footer: _button(
              '확인',
              () =>
                  SeedOverlayScope.maybeOf(ctx)
                      ?.close(SeedOverlayDismissReason.action),
            ),
          ),
        ),
        SeedTopNavigationIconButton(
          semanticsLabel: 'Home',
          icon: const Icon(Icons.home_outlined),
          onPressed: () => Navigator.of(context).pushNamed('/'),
        ),
      ],
    ),
    body: _demoScroll([
      const Text('기본', style: TextStyle(fontWeight: FontWeight.bold)),
      _section(
        'Header / Body / Footer',
        Center(
          child: _popoverButton(
            '기본',
            title: '제목',
            description: '설명을 작성할 수 있어요',
          ),
        ),
      ),
      _section(
        '헤더 구성과 접근 가능한 이름',
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _popoverButton(
              '닫기 버튼 없음',
              title: 'showCloseButton=false',
              showCloseButton: false,
              bodyText: 'Escape 키, 바깥 클릭, 확인 버튼으로 닫을 수 있습니다.',
            ),
            _popoverButton(
              '설명만',
              title: '',
              description: '이 popover는 title이 없습니다.',
              bodyText: '설명만 있는 Popover입니다.',
            ),
            _popoverButton(
              '헤더 없음',
              title: '',
              showCloseButton: false,
              bodyText: 'Header 슬롯 자체가 렌더되지 않습니다.',
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      const SeedDivider(),
      const Text('배치', style: TextStyle(fontWeight: FontWeight.bold)),
      _section(
        'placement 12종',
        _column([
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final value in placements)
                _button(
                  value,
                  () => setState(() => placement = value),
                  size: SeedButtonSize.xsmall,
                  variant: placement == value
                      ? SeedButtonVariant.neutralSolid
                      : SeedButtonVariant.neutralWeak,
                ),
            ],
          ),
          Center(
            child: _popoverButton(
              'placement=$placement',
              title: placement,
              placement: placement,
              showCloseButton: false,
              closeOnInteractOutside: false,
              bodyText: '요청 placement: $placement',
            ),
          ),
        ]),
        hint: '열어둔 채 placement를 변경하면 새 위치에서 다시 측정합니다.',
      ),
      _section(
        'positioning 옵션',
        _column([
          SeedSwitch(
            label: 'flip',
            checked: flip,
            onCheckedChange: (v) => setState(() => flip = v),
          ),
          SeedSwitch(
            label: 'slide',
            checked: slide,
            onCheckedChange: (v) => setState(() => slide = v),
          ),
          _popoverButton(
            '옵션 적용 popover',
            title: 'positioning',
            placement: 'top',
            flip: flip,
            slide: slide,
            closeOnInteractOutside: false,
            bodyText: 'flip $flip / slide $slide',
          ),
        ]),
        hint: 'Flutter의 앵커 팝오버는 화면 경계에 맞춰 이동합니다.',
      ),
      const SizedBox(height: 24),
      const SeedDivider(),
      const Text('콘텐츠', style: TextStyle(fontWeight: FontWeight.bold)),
      _section(
        '긴 콘텐츠 스크롤',
        _popoverButton(
          '약관 동의',
          title: '약관 동의',
          description: '아래 내용을 확인해주세요',
          customBody: (ctx) => _column([
            for (var i = 1; i <= 24; i++)
              Text('$i. 본문이 길어지면 Body만 스크롤되고 Header / Footer는 고정됩니다.'),
          ], gap: 7),
        ),
      ),
      _section(
        '크기 style props',
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _popoverButton(
              'width 고정',
              title: 'width=400px',
              maxWidth: 400,
              bodyText: '콘텐츠 길이와 무관하게 너비가 고정됩니다.',
            ),
            _popoverButton(
              'Body 높이 제한',
              title: 'maxHeight=120px',
              maxWidth: 360,
              maxHeight: 240,
              customBody: (ctx) => SizedBox(
                height: 120,
                child: SingleChildScrollView(
                  child: _column([
                    for (var i = 1; i <= 12; i++)
                      Text('$i. 좌우 padding과 최대 높이를 직접 지정한 Body입니다.'),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      const SeedDivider(),
      const Text('상태', style: TextStyle(fontWeight: FontWeight.bold)),
      _section(
        'onOpenChange reason + 중첩 dismiss',
        _column([
          _nestedPopovers(),
          Container(
            constraints: const BoxConstraints(minHeight: 120),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _column(
              eventLog.isEmpty
                  ? [const Text('아직 이벤트가 없습니다.')]
                  : [
                      for (final entry in eventLog)
                        Text(entry, style: const TextStyle(fontSize: 12)),
                    ],
              gap: 4,
            ),
          ),
        ]),
        hint: 'trigger / closeButton / Escape / outside / focusOut을 확인해보세요.',
      ),
      _section(
        'closeOnInteractOutside=false',
        _popoverButton(
          '바깥 클릭 무시',
          title: 'closeOnInteractOutside=false',
          closeOnInteractOutside: false,
          bodyText: '바깥 아무 데나 눌러보세요.',
        ),
        hint: '바깥을 눌러도 닫히지 않습니다.',
      ),
      _section(
        'lazyMount / unmountOnExit',
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _popoverButton(
              '기본 (유지)',
              lazyMount: true,
              title: '상태 유지',
              customBody: (ctx) =>
                  const SeedTextField(label: '메모', placeholder: '적고 닫아보세요'),
            ),
            _popoverButton(
              'unmountOnExit',
              unmountOnExit: true,
              title: '상태 초기화',
              customBody: (ctx) =>
                  const SeedTextField(label: '메모', placeholder: '닫으면 사라집니다'),
            ),
            _popoverButton(
              'lazyMount=false',
              lazyMount: false,
              title: '선마운트',
              bodyText: '열기 전에도 content가 DOM에 있습니다.',
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      const SeedDivider(),
      const Text('레이어', style: TextStyle(fontWeight: FontWeight.bold)),
      _section(
        '다른 레이어 위의 popover',
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _button('BottomSheet 안에서', _openLayerSheet),
            _button('Dialog 안에서', _openLayerDialog),
          ],
        ),
        hint: 'BottomSheet / Dialog 안에서 열어 overlay와 focus를 시험합니다.',
      ),
      const SizedBox(height: 24),
      const SeedDivider(),
      const Text('포커스', style: TextStyle(fontWeight: FontWeight.bold)),
      _section(
        'focus 경계',
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _button('이전 버튼', () {}),
            _popoverButton(
              '가운데 trigger',
              title: '경계 테스트',
              bodyText: 'Tab / Shift+Tab이 dialog 안에서 어떻게 도는지 봅니다.',
            ),
            _button('다음 버튼', () {}),
          ],
        ),
      ),
    ]),
  );
}

/// Measures the live sheet after layout, including changes caused by the IME.
class _SheetMetrics extends StatefulWidget {
  const _SheetMetrics({required this.sheetKey});
  final GlobalKey sheetKey;
  @override
  State<_SheetMetrics> createState() => _SheetMetricsState();
}

class _SheetMetricsState extends State<_SheetMetrics>
    with WidgetsBindingObserver {
  Rect? bounds;
  bool pending = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeMetrics() => measure();
  void measure() {
    if (pending) return;
    pending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      pending = false;
      if (!mounted) return;
      final box = widget.sheetKey.currentContext?.findRenderObject();
      if (box is! RenderBox || !box.hasSize) return;
      final rect = box.localToGlobal(Offset.zero) & box.size;
      if (rect != bounds) setState(() => bounds = rect);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    measure();
    return Text(
      bounds == null
          ? 'sheet metrics: measuring'
          : 'sheet top ${bounds!.top.round()}px · bottom ${bounds!.bottom.round()}px · height ${bounds!.height.round()}px',
    );
  }
}

/// React's inactive overlay presence mapped to the containing Navigator route.
class _RoutePresence extends StatefulWidget {
  const _RoutePresence({
    required this.keepMounted,
    required this.child,
    this.onUnmount,
  });
  final bool keepMounted;
  final Widget child;
  final VoidCallback? onUnmount;
  @override
  State<_RoutePresence> createState() => _RoutePresenceState();
}

class _RoutePresenceState extends State<_RoutePresence> {
  bool wasActive = true;
  @override
  Widget build(BuildContext context) {
    final active = ModalRoute.isCurrentOf(context) ?? true;
    if (wasActive && !active && !widget.keepMounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !wasActive) widget.onUnmount?.call();
      });
    }
    wasActive = active;
    if (widget.keepMounted) {
      return Offstage(offstage: !active, child: widget.child);
    }
    if (!active) return const SizedBox.shrink();
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 250),
      builder: (_, opacity, child) => Opacity(opacity: opacity, child: child),
      child: widget.child,
    );
  }
}
