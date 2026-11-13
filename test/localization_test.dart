import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

Widget _label(SeedLabel label) => Builder(
  builder: (context) => Text(SeedLocalizations.label(context, label)),
);

Widget _localizedHost(Widget child, Locale locale) => MaterialApp(
  locale: locale,
  supportedLocales: const [Locale('en', 'US'), Locale('ko', 'KR')],
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  home: Scaffold(body: child),
);

void main() {
  for (final locale in [const Locale('en'), const Locale('ko')]) {
    testWidgets('SEED fallback copy follows $locale', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: locale,
          supportedLocales: const [Locale('en'), Locale('ko')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: Scaffold(body: _label(SeedLabel.requiredInput)),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text(locale.languageCode == 'ko' ? '필수 입력' : 'Required'),
        findsOneWidget,
      );
    });
  }

  testWidgets('all DatePicker constructors follow the app locale', (
    tester,
  ) async {
    final october = DateTime(2026, 10);
    for (final picker in [
      SeedDatePicker(defaultViewDate: october),
      SeedDatePicker.range(defaultViewDate: october),
      SeedDatePicker.multiple(defaultViewDate: october),
    ]) {
      await tester.pumpWidget(_localizedHost(picker, const Locale('en', 'US')));
      await tester.pumpAndSettle();
      expect(find.text('October 2026'), findsOneWidget);
      await tester.pumpWidget(_localizedHost(picker, const Locale('ko', 'KR')));
      await tester.pumpAndSettle();
      expect(find.text('2026년 10월'), findsOneWidget);
    }
    await tester.pumpWidget(
      _localizedHost(
        SeedDatePicker(
          defaultViewDate: october,
          locale: const Locale('ko', 'KR'),
        ),
        const Locale('en', 'US'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('2026년 10월'), findsOneWidget);
  });

  testWidgets('TimePicker follows the app locale and accepts an override', (
    tester,
  ) async {
    List<String?> columnLabels() => tester
        .widget<SeedWheelPicker>(find.byType(SeedWheelPicker))
        .columns
        .map((column) => column.semanticsLabel)
        .toList();

    const picker = SeedTimePicker(
      defaultValue: TimeOfDay(hour: 13, minute: 15),
    );
    await tester.pumpWidget(_localizedHost(picker, const Locale('en', 'US')));
    await tester.pumpAndSettle();
    expect(columnLabels(), ['Hour', 'Minute', 'AM/PM']);
    expect(find.text('PM'), findsWidgets);

    await tester.pumpWidget(_localizedHost(picker, const Locale('ko', 'KR')));
    await tester.pumpAndSettle();
    expect(columnLabels(), ['오전/오후', '시', '분']);
    expect(find.text('오후'), findsWidgets);

    await tester.pumpWidget(
      _localizedHost(
        const SeedTimePicker(locale: Locale('en', 'US')),
        const Locale('ko', 'KR'),
      ),
    );
    await tester.pumpAndSettle();
    expect(columnLabels(), ['Hour', 'Minute', 'AM/PM']);
  });

  testWidgets('pickers fall back to English for an unsupported locale', (
    tester,
  ) async {
    const unsupported = Locale('zz');
    const korean = Locale('ko', 'KR');
    await tester.pumpWidget(
      _localizedHost(
        SeedDatePicker(
          defaultViewDate: DateTime(2026, 10),
          locale: unsupported,
        ),
        korean,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('October 2026'), findsOneWidget);

    await tester.pumpWidget(
      _localizedHost(const SeedTimePicker(locale: unsupported), korean),
    );
    await tester.pumpAndSettle();
    expect(find.text('AM'), findsWidgets);
  });

  testWidgets('Field and Chip localize visible and accessible labels', (
    tester,
  ) async {
    final content = Column(
      children: [
        const SeedField(label: 'Name', optional: true, child: SizedBox()),
        const SeedField(
          label: 'Nickname',
          optional: true,
          indicatorText: '(custom)',
          child: SizedBox(),
        ),
        SeedChip(label: 'Apple', onDeleted: () {}),
      ],
    );
    for (final (locale, optional, delete) in [
      (const Locale('en', 'US'), '(optional)', 'Delete Apple'),
      (const Locale('ko', 'KR'), '(선택)', 'Apple 삭제'),
    ]) {
      await tester.pumpWidget(_localizedHost(content, locale));
      await tester.pumpAndSettle();
      expect(find.text(optional), findsOneWidget);
      expect(find.text('(custom)'), findsOneWidget);
      expect(find.bySemanticsLabel(delete), findsOneWidget);
    }
    await tester.pumpWidget(
      _localizedHost(
        SeedLocalizations(
          labels: const {
            SeedLabel.optionalInput: '(facultatif)',
            SeedLabel.deleteChip: 'Supprimer {label}',
          },
          child: content,
        ),
        const Locale('en', 'US'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('(facultatif)'), findsOneWidget);
    expect(find.bySemanticsLabel('Supprimer Apple'), findsOneWidget);
  });

  testWidgets('notification counts use singular, plural and custom labels', (
    tester,
  ) async {
    final navigation = SeedBottomNavigation(
      currentIndex: 0,
      onTap: (_) {},
      items: const [
        SeedBottomNavigationItem(
          icon: Icon(Icons.chat),
          label: 'Chat',
          notificationCount: 1,
        ),
        SeedBottomNavigationItem(
          icon: Icon(Icons.inbox),
          label: 'Inbox',
          notificationCount: 2,
        ),
      ],
    );
    String value(String label) =>
        tester.getSemantics(find.bySemanticsLabel(label)).value;
    const english = Locale('en', 'US');
    await tester.pumpWidget(_localizedHost(navigation, english));
    expect(value('Chat'), '1 unread notification');
    expect(value('Inbox'), '2 unread notifications');

    Future<void> showOverrides(Map<SeedLabel, String> labels) =>
        tester.pumpWidget(
          _localizedHost(
            SeedLocalizations(labels: labels, child: navigation),
            english,
          ),
        );

    await showOverrides(const {
      SeedLabel.unreadNotifications: 'Unread: {count}',
    });
    expect(value('Chat'), 'Unread: 1');
    expect(value('Inbox'), 'Unread: 2');

    await showOverrides(const {
      SeedLabel.unreadNotification: '{count} new message',
      SeedLabel.unreadNotifications: '{count} new messages',
    });
    expect(value('Chat'), '1 new message');
    expect(value('Inbox'), '2 new messages');
  });

  testWidgets('nested label overrides survive in place and in a dialog', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SeedLocalizations(
          labels: const {
            SeedLabel.requiredInput: 'Application required label',
            SeedLabel.confirm: 'Application confirm label',
          },
          child: SeedLocalizations(
            labels: const {SeedLabel.confirm: 'Screen confirm label'},
            child: Builder(
              builder: (context) => Scaffold(
                body: Column(
                  children: [
                    _label(SeedLabel.requiredInput),
                    _label(SeedLabel.confirm),
                    TextButton(
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (_) => Dialog(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _label(SeedLabel.requiredInput),
                              _label(SeedLabel.confirm),
                            ],
                          ),
                        ),
                      ),
                      child: const Text('Open'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    expect(find.text('Application required label'), findsOneWidget);
    expect(find.text('Screen confirm label'), findsOneWidget);
    expect(find.text('Application confirm label'), findsNothing);
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    final dialog = find.byType(Dialog);
    expect(
      find.descendant(
        of: dialog,
        matching: find.text('Application required label'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: dialog, matching: find.text('Screen confirm label')),
      findsOneWidget,
    );
  });
}
