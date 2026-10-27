import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

import 'tabs/components_tab.dart';
import 'tabs/feedback_tab.dart';
import 'tabs/inputs_tab.dart';
import 'tabs/navigation_tab.dart';
import 'tabs/overlays_tab.dart';

void main() {
  runApp(const SeedDesignCatalogApp());
}

/// Root demo application for the SEED Design System catalog.
class SeedDesignCatalogApp extends StatefulWidget {
  const SeedDesignCatalogApp({super.key});

  @override
  State<SeedDesignCatalogApp> createState() => _SeedDesignCatalogAppState();
}

class _SeedDesignCatalogAppState extends State<SeedDesignCatalogApp> {
  bool _isDark = false;

  void _toggleTheme() {
    setState(() => _isDark = !_isDark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SEED Design System Flutter',
      debugShowCheckedModeBanner: false,
      theme: SeedThemeData.light().toThemeData(),
      darkTheme: SeedThemeData.dark().toThemeData(),
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      home: SeedSnackbarProvider(
        child: CatalogHomePage(isDark: _isDark, onToggleTheme: _toggleTheme),
      ),
    );
  }
}

/// Catalog home page managing top-level tabs and responsive shell.
class CatalogHomePage extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const CatalogHomePage({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  State<CatalogHomePage> createState() => _CatalogHomePageState();
}

class _CatalogHomePageState extends State<CatalogHomePage> {
  int _selectedTabIndex = 0;
  final ScrollController _scrollController = ScrollController();

  static const List<Widget> _tabs = [
    ComponentsTab(),
    FeedbackTab(),
    InputsTab(),
    NavigationTab(),
    OverlaysTab(),
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: SeedDuration.d6,
        curve: SeedCurves.exitExpressive,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;

    return Scaffold(
      backgroundColor: colors.bg.layerDefault,
      appBar: SeedTopNavigation(
        titleText: 'SEED Design System',
        actions: [
          SeedTopNavigationIconButton(
            icon: Icon(
              widget.isDark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
            semanticsLabel: widget.isDark ? '라이트 모드로 전환' : '다크 모드로 전환',
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      bottomNavigationBar: SeedSnackbarAvoidOverlap(
        child: SeedBottomNavigation(
          currentIndex: _selectedTabIndex,
          onTap: (index) {
            setState(() => _selectedTabIndex = index);
            _scrollToTop();
          },
          items: const [
            SeedBottomNavigationItem(
              label: '컴포넌트',
              icon: Icon(Icons.widgets_outlined),
              activeIcon: Icon(Icons.widgets),
            ),
            SeedBottomNavigationItem(
              label: '피드백 & 상태',
              icon: Icon(Icons.insights_outlined),
              activeIcon: Icon(Icons.insights),
              showNotificationDot: true,
            ),
            SeedBottomNavigationItem(
              label: '입력 & 피커',
              icon: Icon(Icons.edit_note_outlined),
              activeIcon: Icon(Icons.edit_note),
            ),
            SeedBottomNavigationItem(
              label: '탐색 & 레이아웃',
              icon: Icon(Icons.view_quilt_outlined),
              activeIcon: Icon(Icons.view_quilt),
            ),
            SeedBottomNavigationItem(
              label: '오버레이',
              icon: Icon(Icons.layers_outlined),
              activeIcon: Icon(Icons.layers),
            ),
          ],
        ),
      ),
      floatingActionButton: SeedContextualFloatingButton(
        icon: const Icon(Icons.vertical_align_top_rounded),
        label: '맨 위로',
        onPressed: _scrollToTop,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.all(SeedDimension.x4),
          child: _tabs[_selectedTabIndex],
        ),
      ),
    );
  }
}
