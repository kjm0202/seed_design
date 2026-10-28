import 'package:flutter/material.dart' as flutter_material;
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'display_pages.dart';
import 'extra_pages.dart';
import 'forms_pages.dart';
import 'navigation_pages.dart';
import 'overlay_pages.dart';
import 'screen_pages.dart';
import 'spa_catalog.dart';
import 'spa_paths.dart';
import 'spa_types.dart';
import 'spa_routes.dart';
import 'spa_material_theme.dart';
import 'demo_pages.dart';

/// Standalone example of the React Stackflow SPA, using Flutter's Navigator
/// to support named routes, push/replace/pop and the native back gesture.
class StackflowSpaApp extends StatelessWidget {
  const StackflowSpaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SEED Design Stackflow SPA',
      navigatorObservers: [SpaGestureObserver()],
      debugShowCheckedModeBanner: false,
      theme: SeedThemeData.light(fontFamily: 'WantedSans').toThemeData(),
      darkTheme: SeedThemeData.dark(fontFamily: 'WantedSans').toThemeData(),
      themeMode: ThemeMode.system,
      builder: (context, child) => flutter_material.Localizations.override(
        context: context,
        delegates: const [
          flutter_material.DefaultMaterialLocalizations.delegate,
        ],
        child: flutter_material.Theme(
          data: spaMaterialTheme(Theme.of(context)),
          child: flutter_material.Material(
            type: flutter_material.MaterialType.transparency,
            child: SeedSnackbarProvider(
              strategy: SeedSnackbarStrategy.immediate,
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        ),
      ),
      onGenerateRoute: (settings) {
        final requested = Uri.tryParse(settings.name ?? '/')?.path ?? '/';
        final activity = spaPathActivities[requested] ?? 'ActivityNotFound';
        final page = _SpaActivityPage(
          activity: activity,
          arguments: settings.arguments,
        );
        final requestedStyle = settings.arguments is Map
            ? (settings.arguments as Map)['transitionStyle']
            : null;
        final platform = Theme.of(context).platform;
        if (requestedStyle == 'slideFromRightIOS') {
          return SpaCupertinoRoute<Object?>(
            settings: settings,
            builder: (_) => page,
          );
        }
        if (requestedStyle is String) {
          return PageRouteBuilder<Object?>(
            settings: settings,
            transitionDuration: Duration(
              milliseconds: platform == TargetPlatform.iOS ? 350 : 300,
            ),
            reverseTransitionDuration: Duration(
              milliseconds: platform == TargetPlatform.iOS ? 350 : 300,
            ),
            pageBuilder: (_, _, _) => page,
            transitionsBuilder: (_, animation, secondaryAnimation, child) {
              final curved = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              );
              return switch (requestedStyle) {
                'fadeIn' => FadeTransition(opacity: curved, child: child),
                'fadeFromBottomAndroid' => FadeTransition(
                  opacity: curved,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.1),
                      end: Offset.zero,
                    ).animate(curved),
                    child: child,
                  ),
                ),
                _ => SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(curved),
                  child: child,
                ),
              };
            },
          );
        }
        if (platform == TargetPlatform.iOS ||
            platform == TargetPlatform.macOS) {
          return SpaCupertinoRoute<Object?>(
            settings: settings,
            builder: (_) => page,
          );
        }
        return MaterialPageRoute<Object?>(
          settings: settings,
          builder: (_) => page,
        );
      },
    );
  }
}

class _SpaActivityPage extends StatelessWidget {
  const _SpaActivityPage({required this.activity, this.arguments});

  final String activity;
  final Object? arguments;

  @override
  Widget build(BuildContext context) {
    void navigate(String target, {Object? arguments}) {
      final route = spaActivityPaths[target];
      if (route == null) return;
      if (target == 'ActivitySideNavigation') {
        Navigator.of(context).pushReplacementNamed(route, arguments: arguments);
      } else {
        Navigator.of(context).pushNamed(route, arguments: arguments);
      }
    }

    void goHome() {
      final navigator = Navigator.of(context);
      String? rootName;
      navigator.popUntil((route) {
        if (route.isFirst) rootName = route.settings.name;
        return route.isFirst;
      });
      if (rootName != '/') {
        navigator.pushReplacementNamed('/');
      }
    }

    void goBack() => Navigator.of(context).maybePop();

    if (activity == 'ActivityHome') {
      return _SpaHomePage(
        navigate: navigate,
        depth: Navigator.of(context).widget.observers
            .whereType<SpaGestureObserver>()
            .first
            .activityIndex,
      );
    }

    if (activity == 'ActivityDemoHome') {
      return SpaDemoHomePage(navigate: navigate);
    }

    if (activity == 'ActivityDemoArticleDetail') {
      return SpaArticleDetailPage(
        articleId: arguments is int ? arguments as int : 1,
        goBack: goBack,
      );
    }

    final Widget? body =
        buildFormsPage(
          activity,
          context,
          navigate: navigate,
          goBack: goBack,
          arguments: arguments,
        ) ??
        buildNavigationPage(
          activity,
          context,
          navigate: navigate,
          goBack: goBack,
          arguments: arguments,
        ) ??
        buildOverlayPage(
          activity,
          context,
          navigate: navigate,
          goBack: goBack,
          arguments: arguments,
        ) ??
        buildDisplayPage(
          activity,
          context,
          navigate: navigate,
          goBack: goBack,
          arguments: arguments,
        ) ??
        buildScreenPage(
          activity,
          context,
          navigate: navigate,
          goBack: goBack,
          arguments: arguments,
        ) ??
        buildExtraPage(
          activity,
          context,
          navigate: navigate,
          goBack: goBack,
          arguments: arguments,
        );

    if (body is SpaOwnScaffold) return body;
    if (activity == 'ActivitySideNavigation') {
      return Scaffold(
        backgroundColor: context.seedColor.bg.layerDefault,
        body: body,
      );
    }

    return Scaffold(
      backgroundColor: context.seedColor.bg.layerDefault,
      appBar: SeedTopNavigation(
        titleText: activity == 'ActivityDetail' && arguments is Map
            ? ((arguments as Map)['title'] as String? ?? 'Detail')
            : activity == 'ActivityTransitionStyle'
            ? (arguments is Map
                      ? (arguments as Map)['transitionStyle'] as String?
                      : null) ??
                  'Transition Styles'
            : activity == 'ActivityMannerTempLevel'
            ? 'MannerTempLevel'
            : activity == 'ActivityPluginBasicUI'
            ? 'Random Long Title Hello World'
            : activity == 'ActivityAvatarStack'
            ? 'Avatar'
            : activity == 'ActivityPartialDarkMode'
            ? 'Partial Dark Mode'
            : spaActivityTitle(activity),
        centerTitle: false,
        actions: [
          if (activity == 'ActivityPartialDarkMode')
            for (var i = 0; i < 2; i++)
              SeedTopNavigationIconButton(
                icon: const Icon(Icons.notifications_none),
                semanticsLabel: 'Notification ${i + 1}',
                onPressed: () {},
              ),
          SeedTopNavigationIconButton(
            icon: const Icon(Icons.home_outlined),
            semanticsLabel: '홈으로',
            onPressed: goHome,
          ),
        ],
      ),
      body: flutter_material.Material(
        type: flutter_material.MaterialType.transparency,
        child:
            body ??
            SeedResultSection(
              asset: const Icon(Icons.search_off_rounded, size: 44),
              title: '페이지를 찾지 못했습니다.',
              description: '주소를 확인하거나 홈으로 돌아가 주세요.',
              primaryActionLabel: '홈으로',
              onPrimaryAction: goHome,
            ),
      ),
    );
  }
}

class _SpaHomePage extends StatefulWidget {
  const _SpaHomePage({required this.navigate, required this.depth});

  final SpaNavigate navigate;
  final int depth;

  @override
  State<_SpaHomePage> createState() => _SpaHomePageState();
}

class _SpaHomePageState extends State<_SpaHomePage> {
  final ScrollController _scroll = ScrollController();
  final List<GlobalKey> _sectionKeys = List.generate(
    spaSections.length,
    (_) => GlobalKey(),
  );
  int _selectedSection = 0;
  bool _isJumping = false;
  bool _showPinnedSectionTitle = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_updateSelectedSection);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _updateSelectedSection() {
    if (_isJumping) return;
    var lastVisible = 0;
    final mobile = MediaQuery.sizeOf(context).width < 600;
    final showPinned = mobile && _scroll.offset > 80;
    for (var index = 0; index < _sectionKeys.length; index++) {
      final render = _sectionKeys[index].currentContext?.findRenderObject();
      if (render is! RenderBox || !render.attached) continue;
      final top = render.localToGlobal(Offset.zero).dy;
      if (top <= MediaQuery.paddingOf(context).top + (mobile ? 188 : 148)) {
        lastVisible = index;
      }
    }
    if ((lastVisible != _selectedSection ||
            showPinned != _showPinnedSectionTitle) &&
        mounted) {
      setState(() {
        _selectedSection = lastVisible;
        _showPinnedSectionTitle = showPinned;
      });
    }
  }

  Future<void> _jumpTo(int index) async {
    final render = _sectionKeys[index].currentContext?.findRenderObject();
    if (render is! RenderBox || !_scroll.hasClients) return;
    setState(() {
      _isJumping = true;
      _selectedSection = index;
    });
    final top = render.localToGlobal(Offset.zero).dy;
    final mobile = MediaQuery.sizeOf(context).width < 600;
    final offset =
        (_scroll.offset +
                top -
                MediaQuery.paddingOf(context).top -
                (mobile ? 172 : 132))
            .clamp(0.0, _scroll.position.maxScrollExtent);
    await _scroll.animateTo(
      offset,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOutCubic,
    );
    if (mounted) {
      setState(() {
        _isJumping = false;
        _showPinnedSectionTitle = mobile && _scroll.offset > 80;
      });
    }
  }

  void _handleEntry(SpaEntry entry) {
    if (entry.activity == 'HomeAlertDialogStep') {
      showSeedDialog(
        context: context,
        child: SeedAlertDialog(
          title: '제목',
          description:
              'Lorem ipsum dolor sit amet consectetur adipisicing elit.',
          footer: Builder(
            builder: (dialogContext) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SeedButton(
                  label: '확인',
                  isFullWidth: true,
                  onPressed: () => Navigator.pop(dialogContext),
                ),
                const SizedBox(height: 8),
                SeedButton(
                  label: 'ActivityChipButton',
                  isFullWidth: true,
                  variant: SeedButtonVariant.neutralSolid,
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    widget.navigate('ActivityChipButton');
                  },
                ),
              ],
            ),
          ),
        ),
      );
    } else if (entry.activity.startsWith('Snackbar')) {
      if (entry.activity == 'SnackbarWorkaround') {
        final controller = SeedSnackbarProvider.of(context);
        controller.close();
        Future<void>.delayed(Duration.zero, () {
          if (mounted) {
            controller.show(
              child: const SeedSnackbar(message: 'Workaround Snackbar'),
            );
          }
        });
        return;
      }
      final variant = switch (entry.activity) {
        'SnackbarPositive' => SeedSnackbarVariant.positive,
        'SnackbarCritical' => SeedSnackbarVariant.critical,
        _ => SeedSnackbarVariant.neutral,
      };
      final queued = entry.activity == 'SnackbarQueued';
      SeedSnackbarProvider.of(context).show(
        strategy: queued
            ? SeedSnackbarStrategy.queued
            : SeedSnackbarStrategy.immediate,
        child: SeedSnackbar(
          message: queued ? 'Queued Snackbar' : 'Disco Party!',
          actionLabel: queued ? null : 'Dance',
          onAction: queued ? null : () {},
          variant: variant,
        ),
      );
    } else {
      widget.navigate(entry.activity, arguments: entry.arguments);
    }
  }

  Widget _buildSection(SpaSection section, int index) {
    final colors = context.seedColor;
    return Column(
      key: _sectionKeys[index],
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
          child: Row(
            children: [
              Icon(section.icon, size: 20, color: colors.fg.neutralSubtle),
              const SizedBox(width: 6),
              Text(section.title, style: context.seedTypography.t5Medium),
            ],
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: ColoredBox(
            color: colors.bg.layerDefault,
            child: Column(
              children: [
                for (var i = 0; i < section.entries.length; i++)
                  if (section.entries[i].activity == 'HomeListMenu')
                    MenuAnchor(
                      menuChildren: [
                        SeedMenu(
                          groups: [
                            SeedMenuGroupData(
                              items: [
                                SeedMenuItemData(
                                  label: '추가',
                                  prefixIcon: const Icon(Icons.add),
                                  onTap: () => showSeedSnackbar(
                                    context: context,
                                    message: '추가',
                                  ),
                                ),
                                SeedMenuItemData(
                                  label: '수정',
                                  prefixIcon: const Icon(Icons.edit),
                                  onTap: () => showSeedSnackbar(
                                    context: context,
                                    message: '수정',
                                  ),
                                ),
                                SeedMenuItemData(
                                  label: '삭제',
                                  prefixIcon: const Icon(Icons.delete),
                                  isDestructive: true,
                                  onTap: () => showSeedSnackbar(
                                    context: context,
                                    message: '삭제',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                      builder: (context, controller, _) => SeedListItem(
                        titleText: section.entries[i].title,
                        showDivider: false,
                        onTap: () => controller.isOpen
                            ? controller.close()
                            : controller.open(),
                      ),
                    )
                  else
                    SeedListItem(
                      titleText: section.entries[i].activity == 'ActivityHome'
                          ? '홈 다시 push (깊이: ${widget.depth})'
                          : section.entries[i].title,
                      detailText:
                          section.entries[i].activity.startsWith('Snackbar')
                          ? null
                          : section.entries[i].activity,
                      showDivider: false,
                      onTap: () => _handleEntry(section.entries[i]),
                    ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 1280
        ? 4
        : width >= 960
        ? 3
        : width >= 600
        ? 2
        : 1;
    final available = width - 32 - (columns - 1) * 20;
    final cardWidth = available / columns;

    return Scaffold(
      backgroundColor: colors.bg.layerBasement,
      appBar: SeedTopNavigation(
        titleText: 'Home',
        centerTitle: false,
        backgroundColor: colors.bg.layerBasement,
        leading: Navigator.of(context).canPop()
            ? SeedTopNavigationIconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                semanticsLabel: '뒤로',
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
        actions: [
          SeedTopNavigationIconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            semanticsLabel: '알림',
            onPressed: () =>
                showSeedSnackbar(context: context, message: '새로운 알림이 없습니다.'),
          ),
        ],
      ),
      body: Stack(
        children: [
          SeedPullToRefresh(
            onRefresh: () async =>
                Future<void>.delayed(const Duration(milliseconds: 1000)),
            child: CustomScrollView(
              controller: _scroll,
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SpaChipBarDelegate(
                    background: colors.bg.layerBasement,
                    index: _selectedSection,
                    onSelect: _jumpTo,
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  sliver: SliverToBoxAdapter(
                    child: Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: [
                        for (var i = 0; i < spaSections.length; i++)
                          SizedBox(
                            width: cardWidth,
                            child: _buildSection(spaSections[i], i),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (columns == 1 && _showPinnedSectionTitle)
            Positioned(
              top: 52,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: ColoredBox(
                  key: const ValueKey('spa-pinned-section-title'),
                  color: colors.bg.layerBasement,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
                    child: Row(
                      children: [
                        Icon(
                          spaSections[_selectedSection].icon,
                          size: 18,
                          color: colors.fg.neutralSubtle,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          spaSections[_selectedSection].title,
                          style: context.seedTypography.t5Medium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SpaChipBarDelegate extends SliverPersistentHeaderDelegate {
  _SpaChipBarDelegate({
    required this.background,
    required this.index,
    required this.onSelect,
  });
  final Color background;
  final int index;
  final ValueChanged<int> onSelect;

  @override
  double get minExtent => 52;
  @override
  double get maxExtent => 52;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: background,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: spaSections.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) => SeedChip(
          label: spaSections[i].title,
          checked: index == i,
          onCheckedChange: (_) => onSelect(i),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _SpaChipBarDelegate old) =>
      old.background != background ||
      old.index != index ||
      old.onSelect != onSelect;
}
