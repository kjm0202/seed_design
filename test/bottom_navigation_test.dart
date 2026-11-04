import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

Widget host(Widget child) => MaterialApp(
  locale: const Locale('ko'),
  supportedLocales: const [Locale('en'), Locale('ko')],
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
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
}
