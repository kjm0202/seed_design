import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

Widget host(Widget child) => MaterialApp(
  home: SeedMaterialBridge(
    child: Scaffold(
      body: Center(child: SizedBox(width: 360, child: child)),
    ),
  ),
);

Widget restorableApp(Widget child, {Locale locale = const Locale('en')}) =>
    MaterialApp(
      restorationScopeId: 'app',
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('ko')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData().withSeedDesign(),
      home: Scaffold(
        body: Center(child: SizedBox(width: 360, child: child)),
      ),
    );

class RouteLog extends NavigatorObserver {
  final List<Route<dynamic>> pushed = [];
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      pushed.add(route);
}

void main() {
  test(
    'explicit font overrides a supplied SEED theme without losing fallbacks',
    () {
      final base = SeedThemeData.dark(fontFamily: 'SeedFont');
      final seed = base.copyWith(
        typography: base.typography.mapStyles(
          (style) => style.copyWith(fontFamilyFallback: const ['SeedFallback']),
        ),
      );
      final original = ThemeData(
        fontFamily: 'HostFont',
        visualDensity: VisualDensity.compact,
      );
      final theme = original.withSeedDesign(
        seedTheme: seed,
        fontFamily: 'ExplicitFont',
      );
      expect(theme.textTheme.bodyMedium!.fontFamily, 'ExplicitFont');
      expect(theme.textTheme.displayLarge!.fontFamily, 'ExplicitFont');
      expect(
        theme.extension<SeedTypography>()!.t4Regular.fontFamily,
        'ExplicitFont',
      );
      expect(
        theme.extension<SeedTypography>()!.t13Bold.fontFamily,
        'ExplicitFont',
      );
      expect(theme.appBarTheme.titleTextStyle!.fontFamily, 'ExplicitFont');
      expect(
        theme.filledButtonTheme.style!.textStyle!.resolve({})!.fontFamily,
        'ExplicitFont',
      );
      expect(
        theme.textTheme.bodyMedium!.fontFamilyFallback,
        contains('SeedFallback'),
      );
      expect(
        theme.extension<SeedTypography>()!.t4Regular.fontFamilyFallback,
        contains('SeedFallback'),
      );
      expect(theme.visualDensity, VisualDensity.compact);
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.primary, seed.colorScheme.fg.brand);
      expect(seed.typography.t4Regular.fontFamily, 'SeedFont');
      expect(original.textTheme.bodyMedium!.fontFamily, 'HostFont');
    },
  );

  test(
    'supplied SEED theme retains its font and brightness without font override',
    () {
      final seed = SeedThemeData.dark(fontFamily: 'SeedFont');
      final theme = ThemeData(fontFamily: 'HostFont')
          .withSeedDesign(seedTheme: seed, brightness: Brightness.light);
      expect(theme.brightness, Brightness.dark);
      expect(theme.textTheme.bodyMedium!.fontFamily, 'SeedFont');
      expect(
        theme.extension<SeedTypography>()!.t4Regular.fontFamily,
        'SeedFont',
      );
    },
  );

  for (final brightness in Brightness.values) {
    testWidgets('incremental controls share brand colors in $brightness mode', (
      tester,
    ) async {
      late ThemeData theme;
      late SeedThemeData seed;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: brightness),
          home: SeedMaterialBridge(
            child: Builder(
              builder: (context) {
                theme = Theme.of(context);
                seed = context.seedTheme;
                return Scaffold(
                  body: Wrap(
                    children: [
                      Checkbox(value: true, onChanged: (_) {}),
                      const SeedCheckmark(
                        key: ValueKey('seed-check'),
                        value: true,
                      ),
                      Switch(value: true, onChanged: (_) {}),
                      SeedSwitchMark(
                        key: const ValueKey('seed-switch'),
                        checked: true,
                        onCheckedChange: (_) {},
                      ),
                      RadioGroup<String>(
                        groupValue: 'selected',
                        onChanged: (_) {},
                        child: const Radio<String>(value: 'selected'),
                      ),
                      SeedRadio<String>(
                        key: const ValueKey('seed-radio'),
                        value: 'selected',
                        groupValue: 'selected',
                        onChanged: (_) {},
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
      final selected = {WidgetState.selected};
      final disabled = {WidgetState.selected, WidgetState.disabled};
      final checkbox = tester.widget<Container>(
        find
            .descendant(
              of: find.byKey(const ValueKey('seed-check')),
              matching: find.byType(Container),
            )
            .first,
      );
      final switchTrack = tester.widget<AnimatedContainer>(
        find
            .descendant(
              of: find.byKey(const ValueKey('seed-switch')),
              matching: find.byType(AnimatedContainer),
            )
            .first,
      );
      final radio = tester.widget<Container>(
        find
            .descendant(
              of: find.byKey(const ValueKey('seed-radio')),
              matching: find.byType(Container),
            )
            .first,
      );
      expect(
        theme.checkboxTheme.fillColor!.resolve(selected),
        (checkbox.decoration! as BoxDecoration).color,
      );
      expect(
        theme.switchTheme.trackColor!.resolve(selected),
        (switchTrack.decoration! as BoxDecoration).color,
      );
      expect(
        theme.radioTheme.fillColor!.resolve(selected),
        (radio.decoration! as BoxDecoration).color,
      );
      expect(
        theme.checkboxTheme.checkColor!.resolve(selected),
        seed.colorScheme.fg.onBrandSolid,
      );
      expect(
        theme.switchTheme.thumbColor!.resolve(selected),
        seed.colorScheme.fg.onBrandSolid,
      );
      expect(
        theme.checkboxTheme.fillColor!.resolve(disabled),
        seed.colorScheme.bg.disabled,
      );
      expect(
        theme.checkboxTheme.checkColor!.resolve(disabled),
        seed.colorScheme.fg.disabled,
      );
      expect(
        theme.switchTheme.trackColor!.resolve(disabled),
        seed.colorScheme.bg.disabled,
      );
      expect(
        theme.radioTheme.fillColor!.resolve(disabled),
        seed.colorScheme.bg.disabled,
      );
      expect(tester.takeException(), isNull);
    });
  }

  test('replacement catalog distinguishes form fields, tooltips and linear progress', () {
    expect(SeedMigration.componentMapping['TextField'], 'SeedTextInput');
    expect(SeedMigration.componentMapping['TextFormField'], 'SeedTextField');
    expect(
      SeedMigration.componentMapping['TextField / TextFormField'],
      'SeedTextInput / SeedTextField',
    );
    expect(SeedMigration.componentMapping['Tooltip'], 'SeedHelpBubbleTooltip');
    expect(
      SeedMigration.componentMapping['LinearProgressIndicator'],
      'LinearProgressIndicator (withSeedDesign theme)',
    );
  });

  testWidgets(
    'TextFormField replacement preserves validation, save and reset',
    (tester) async {
      final form = GlobalKey<FormState>();
      String? saved;
      await tester.pumpWidget(
        host(
          Form(
            key: form,
            child: SeedTextField(
              defaultValue: 'initial',
              validator: (value) =>
                  value?.startsWith('ok') == true ? null : 'Enter ok',
              onSaved: (value) => saved = value,
            ),
          ),
        ),
      );
      expect(form.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Enter ok'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'ok saved');
      expect(form.currentState!.validate(), isTrue);
      await tester.pump();
      form.currentState!.save();
      expect(saved, 'ok saved');
      form.currentState!.reset();
      await tester.pump();
      expect(find.text('initial'), findsOneWidget);
    },
  );

  testWidgets(
    'Tooltip replacement opens after hover delay and on keyboard focus',
    (tester) async {
      await tester.pumpWidget(
        host(
          SeedHelpBubbleTooltip(
            title: 'Migration tip',
            openDelay: const Duration(milliseconds: 100),
            closeDelay: const Duration(milliseconds: 50),
            child: TextButton(onPressed: () {}, child: const Text('Target')),
          ),
        ),
      );
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(find.text('Target')));
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('Migration tip'), findsNothing);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();
      expect(find.text('Migration tip'), findsOneWidget);
      await mouse.moveTo(Offset.zero);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();
      expect(find.text('Migration tip'), findsNothing);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
      expect(find.text('Migration tip'), findsOneWidget);
      await mouse.removePointer();
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'retained linear progress preserves numeric values and announcements',
    (tester) async {
      Widget progress(double value, String announcement) => host(
        LinearProgressIndicator(
          value: value,
          semanticsLabel: 'Download',
          semanticsValue: announcement,
        ),
      );
      await tester.pumpWidget(progress(0.35, '35%'));
      final finder = find.byType(LinearProgressIndicator);
      expect(tester.getSemantics(finder).getSemanticsData().value, '35%');
      expect(tester.getSemantics(finder).getSemanticsData().label, 'Download');
      expect(find.byType(SeedSkeleton), findsNothing);
      await tester.pumpWidget(progress(0.75, '75%'));
      await tester.pumpAndSettle();
      expect(tester.widget<LinearProgressIndicator>(finder).value, 0.75);
      expect(tester.getSemantics(finder).getSemanticsData().value, '75%');
    },
  );

  testWidgets(
    'bridge preserves host configuration and captures its theme in dialogs',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            fontFamily: 'HostFont',
            visualDensity: VisualDensity.compact,
          ),
          home: SeedMaterialBridge(
            brightness: Brightness.dark,
            child: Builder(
              builder: (context) {
                expect(Theme.of(context).visualDensity, VisualDensity.compact);
                expect(Theme.of(context).brightness, Brightness.dark);
                expect(context.seedIsDark, isTrue);
                expect(context.seedTypography.t4Regular.fontFamily, 'HostFont');
                return Scaffold(
                  body: TextButton(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (context) {
                        expect(context.seedIsDark, isTrue);
                        expect(Theme.of(context).brightness, Brightness.dark);
                        return const AlertDialog(title: Text('Captured theme'));
                      },
                    ),
                    child: const Text('Open'),
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Captured theme'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  group('Form, Navigator and theme contracts', () {
    testWidgets(
      'programmatic controller edits validate immediately and reset clears interaction',
      (tester) async {
        final controller = TextEditingController(text: 'initial');
        addTearDown(controller.dispose);
        final form = GlobalKey<FormState>();
        var changes = 0;
        await tester.pumpWidget(
          restorableApp(
            Form(
              key: form,
              onChanged: () => changes++,
              child: SeedTextField(
                controller: controller,
                validator: (value) => value == 'initial' ? null : 'Invalid',
              ),
            ),
          ),
        );
        controller.text = 'changed';
        expect(form.currentState!.validate(), isFalse);
        await tester.pump();
        expect(find.text('Invalid'), findsOneWidget);
        form.currentState!.reset();
        await tester.pump();
        expect(controller.text, 'initial');
        final field = tester.state<FormFieldState<String>>(
          find.byType(FormField<String>),
        );
        expect(field.value, 'initial');
        expect(field.hasInteractedByUser, isFalse);
        changes = 0;
        await tester.enterText(find.byType(TextField), 'once');
        expect(changes, 1);
      },
    );

    testWidgets('forceErrorText takes precedence over cosmetic errorMessage', (
      tester,
    ) async {
      final form = GlobalKey<FormState>();
      await tester.pumpWidget(
        restorableApp(
          Form(
            key: form,
            child: const SeedTextField(
              errorMessage: 'Secondary',
              forceErrorText: 'Authoritative',
            ),
          ),
        ),
      );
      expect(form.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Authoritative'), findsOneWidget);
      expect(find.text('Secondary'), findsNothing);
    });
    testWidgets(
      'server errors block Form validation and clear on parent update',
      (tester) async {
        final form = GlobalKey<FormState>();
        var serverError = 'Server rejected';
        late StateSetter update;
        await tester.pumpWidget(
          restorableApp(
            StatefulBuilder(
              builder: (context, setState) {
                update = setState;
                return Form(
                  key: form,
                  child: SeedTextField(
                    defaultValue: 'valid text',
                    errorMessage: serverError.isEmpty ? null : serverError,
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                );
              },
            ),
          ),
        );
        expect(form.currentState!.validate(), isFalse);
        expect(find.text('Server rejected'), findsOneWidget);
        update(() => serverError = '');
        await tester.pump();
        expect(form.currentState!.validate(), isTrue);
        await tester.pump();
        expect(find.text('Server rejected'), findsNothing);
      },
    );

    testWidgets(
      'grapheme overflow blocks submission without truncating React value',
      (tester) async {
        final form = GlobalKey<FormState>();
        await tester.pumpWidget(
          restorableApp(
            Form(key: form, child: const SeedTextField(maxGraphemeCount: 2)),
          ),
        );
        await tester.enterText(find.byType(TextField), '👨‍👩‍👧‍👦ab');
        expect(form.currentState!.validate(), isFalse);
        await tester.pump();
        expect(find.text('👨‍👩‍👧‍👦ab'), findsOneWidget);
        expect(find.text('Use at most 2 characters'), findsOneWidget);
        await tester.enterText(find.byType(TextField), '👨‍👩‍👧‍👦a');
        expect(form.currentState!.validate(), isTrue);
      },
    );

    testWidgets(
      'form inputs retain autofill, IME submit, capitalization and editing callbacks',
      (tester) async {
        final events = <String>[];
        await tester.pumpWidget(
          restorableApp(
            SeedTextField(
              autofillHints: const [AutofillHints.email],
              textCapitalization: TextCapitalization.none,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              enableSuggestions: false,
              onChanged: (value) => events.add('change:$value'),
              onEditingComplete: () => events.add('complete'),
              onFieldSubmitted: (value) => events.add('submit:$value'),
            ),
          ),
        );
        await tester.enterText(find.byType(TextField), 'neighbor@example.com');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        expect(events, [
          'change:neighbor@example.com',
          'complete',
          'submit:neighbor@example.com',
        ]);
        final input = tester.widget<EditableText>(find.byType(EditableText));
        expect(input.autofillHints, [AutofillHints.email]);
        expect(input.autocorrect, isFalse);
        expect(input.enableSuggestions, isFalse);
        expect(tester.takeException(), isNull);
      },
    );

    for (final formField in [false, true]) {
      testWidgets(
        'owned text controller restores after restart form=$formField',
        (tester) async {
          await tester.pumpWidget(
            restorableApp(
              formField
                  ? const SeedTextField(
                      restorationId: 'name',
                      defaultValue: 'initial',
                    )
                  : const SeedTextInput(
                      restorationId: 'name',
                      defaultValue: 'initial',
                    ),
            ),
          );
          await tester.enterText(find.byType(TextField), 'restored name');
          await tester.pump();
          await tester.restartAndRestore();
          expect(find.text('restored name'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets(
      'select Form adapter validates saves and resets its single selection',
      (tester) async {
        final form = GlobalKey<FormState>();
        List<String>? saved;
        var resets = 0;
        await tester.pumpWidget(
          restorableApp(
            Form(
              key: form,
              child: SeedSelectFormField<String>(
                groups: const [
                  SeedSelectGroup(
                    items: [
                      SeedSelectItem(value: 'a', label: 'Apple'),
                      SeedSelectItem(value: 'b', label: 'Banana'),
                    ],
                  ),
                ],
                validator: (value) => value!.isEmpty ? 'Choose fruit' : null,
                onSaved: (value) => saved = value,
                onReset: () => resets++,
              ),
            ),
          ),
        );
        expect(form.currentState!.validate(), isFalse);
        await tester.pump();
        expect(find.text('Choose fruit'), findsOneWidget);
        await tester.tap(find.text('Select an option'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Banana'));
        await tester.pumpAndSettle();
        expect(form.currentState!.validate(), isTrue);
        form.currentState!.save();
        expect(saved, ['b']);
        form.currentState!.reset();
        await tester.pumpAndSettle();
        expect(resets, 1);
        expect(find.text('Select an option'), findsOneWidget);
        expect(find.text('Banana'), findsNothing);
      },
    );

    testWidgets(
      'controlled empty Select proposals and reset preserve parent ownership',
      (tester) async {
        final form = GlobalKey<FormState>();
        final changes = <List<String>>[];
        List<String>? saved;
        await tester.pumpWidget(
          restorableApp(
            Form(
              key: form,
              child: SeedSelectFormField<String>(
                value: const [],
                groups: const [
                  SeedSelectGroup(
                    items: [SeedSelectItem(value: 'a', label: 'Apple')],
                  ),
                ],
                onValueChange: changes.add,
                onSaved: (value) => saved = value,
              ),
            ),
          ),
        );
        await tester.tap(find.text('Select an option'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Apple'));
        await tester.pumpAndSettle();
        expect(changes, [
          ['a'],
        ]);
        expect(find.text('Select an option'), findsOneWidget);
        form.currentState!.reset();
        form.currentState!.save();
        expect(saved, isEmpty);
      },
    );

    testWidgets(
      'top navigation preserves drawer and Material tab content in both directions',
      (tester) async {
        late TabController controller;
        await tester.pumpWidget(
          MaterialApp(
            home: DefaultTabController(
              length: 2,
              child: Builder(
                builder: (context) {
                  controller = DefaultTabController.of(context);
                  return const Scaffold(
                    appBar: SeedTopNavigation(
                      titleText: 'Navigation',
                      bottom: SeedTabBar(
                        items: [
                          SeedTabItem(label: 'First'),
                          SeedTabItem(label: 'Second'),
                        ],
                      ),
                    ),
                    drawer: Drawer(
                      child: Center(child: Text('Drawer content')),
                    ),
                    body: TabBarView(
                      children: [
                        Center(child: Text('Page one')),
                        Center(child: Text('Page two')),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
        await tester.tap(find.byType(DrawerButton));
        await tester.pumpAndSettle();
        expect(find.text('Drawer content').hitTestable(), findsOneWidget);
        final scaffold = tester.state<ScaffoldState>(find.byType(Scaffold));
        scaffold.closeDrawer();
        await tester.pumpAndSettle();
        await tester.tap(find.text('Second'));
        await tester.pumpAndSettle();
        expect(controller.index, 1);
        expect(find.text('Page two').hitTestable(), findsOneWidget);
        await tester.drag(find.byType(TabBarView), const Offset(600, 0));
        await tester.pumpAndSettle();
        expect(controller.index, 0);
        expect(tester.widget<SeedTabs>(find.byType(SeedTabs)).selectedIndex, 0);
        expect(find.text('Page one').hitTestable(), findsOneWidget);
      },
    );

    testWidgets(
      'Snackbar Undo persists and reports action once, explicit timeout remains available',
      (tester) async {
        ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? controller;
        var actions = 0;
        await tester.pumpWidget(
          restorableApp(
            Builder(
              builder: (context) => TextButton(
                onPressed: () => controller = showSeedSnackbar(
                  context: context,
                  message: 'Removed',
                  actionLabel: 'Undo',
                  onAction: () => actions++,
                  duration: const Duration(seconds: 1),
                ),
                child: const Text('Show'),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Show'));
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 8));
        expect(find.text('Undo'), findsOneWidget);
        await tester.tap(find.text('Undo'));
        await tester.tap(find.text('Undo'));
        await tester.pumpAndSettle();
        expect(actions, 1);
        expect(await controller!.closed, SnackBarClosedReason.action);
        await tester.pumpWidget(
          restorableApp(
            Builder(
              builder: (context) => TextButton(
                onPressed: () => controller = showSeedSnackbar(
                  context: context,
                  message: 'Temporary',
                  actionLabel: 'Undo',
                  onAction: () {},
                  persist: false,
                  duration: const Duration(seconds: 1),
                ),
                child: const Text('Show temporary'),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Show temporary'));
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();
        expect(find.text('Temporary'), findsNothing);
        expect(await controller!.closed, SnackBarClosedReason.timeout);
      },
    );

    testWidgets(
      'overlay builders select Navigator, preserve scoped theme and return route results',
      (tester) async {
        final outer = RouteLog();
        final inner = RouteLog();
        int? result;
        await tester.pumpWidget(
          MaterialApp(
            navigatorObservers: [outer],
            home: SeedTheme(
              data: SeedThemeData.dark(),
              child: SeedLocalizations(
                labels: const {SeedLabel.confirm: 'Proceed'},
                child: Navigator(
                  observers: [inner],
                  onGenerateRoute: (_) => MaterialPageRoute<void>(
                    builder: (context) => Scaffold(
                      body: Column(
                        children: [
                          TextButton(
                            onPressed: () async {
                              result = await showSeedDialog<int>(
                                context: context,
                                useRootNavigator: false,
                                routeSettings: const RouteSettings(
                                  name: '/confirmation',
                                ),
                                builder: (routeContext) {
                                  expect(routeContext.seedIsDark, isTrue);
                                  expect(
                                    SeedLocalizations.label(
                                      routeContext,
                                      SeedLabel.confirm,
                                    ),
                                    'Proceed',
                                  );
                                  return SeedDialog(
                                    content: TextButton(
                                      onPressed: () =>
                                          Navigator.of(routeContext).pop(7),
                                      child: const Text('Return result'),
                                    ),
                                  );
                                },
                              );
                            },
                            child: const Text('Dialog'),
                          ),
                          TextButton(
                            onPressed: () => showSeedBottomSheet<void>(
                              context: context,
                              useRootNavigator: true,
                              routeSettings: const RouteSettings(
                                name: '/wide-sheet',
                              ),
                              constraints: const BoxConstraints(maxWidth: 600),
                              builder: (_) => const SizedBox(
                                width: 600,
                                height: 100,
                                child: Text('Wide sheet'),
                              ),
                            ),
                            child: const Text('Sheet'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        final outerCount = outer.pushed.length;
        await tester.tap(find.text('Dialog'));
        await tester.pumpAndSettle();
        expect(inner.pushed.last.settings.name, '/confirmation');
        expect(outer.pushed.length, outerCount);
        await tester.tap(find.text('Return result'));
        await tester.pumpAndSettle();
        expect(result, 7);
        await tester.tap(find.text('Sheet'));
        await tester.pumpAndSettle();
        expect(outer.pushed.last.settings.name, '/wide-sheet');
        expect(
          tester
              .getSize(
                find
                    .ancestor(
                      of: find.text('Wide sheet'),
                      matching: find.byType(SizedBox),
                    )
                    .first,
              )
              .width,
          600,
        );
      },
    );

    testWidgets(
      'default copy follows locale and explicit alert labels are never translated',
      (tester) async {
        for (final locale in [const Locale('en'), const Locale('ko')]) {
          await tester.pumpWidget(
            restorableApp(
              const SeedAlertDialog(title: 'Confirm'),
              locale: locale,
            ),
          );
          expect(
            find.text(locale.languageCode == 'ko' ? '확인' : 'OK'),
            findsOneWidget,
          );
          expect(
            find.text(locale.languageCode == 'ko' ? '취소' : 'Cancel'),
            findsOneWidget,
          );
        }
        await tester.pumpWidget(
          restorableApp(
            const SeedAlertDialog(
              title: 'Confirm',
              confirmText: '확인',
              cancelText: null,
            ),
          ),
        );
        expect(find.text('확인'), findsOneWidget);
        expect(find.text('Cancel'), findsNothing);
      },
    );

    testWidgets(
      'localized semantics and text remain overridable in an English app',
      (tester) async {
        await tester.pumpWidget(
          restorableApp(
            const SeedLocalizations(
              labels: {
                SeedLabel.clearInput: 'Effacer',
                SeedLabel.selectPlaceholder: 'Choisir',
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SeedTextInput(defaultValue: 'Hello', clearable: true),
                  SeedSelect<String>(groups: []),
                ],
              ),
            ),
          ),
        );
        expect(find.bySemanticsLabel('Effacer'), findsOneWidget);
        expect(find.text('Choisir'), findsOneWidget);
      },
    );

    test('theme bridge can preserve Material component overrides while installing SEED tokens', () {
      final original = ThemeData(
        inputDecorationTheme: const InputDecorationTheme(
          contentPadding: EdgeInsets.all(31),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(minimumSize: const Size(120, 72)),
        ),
        appBarTheme: const AppBarTheme(centerTitle: false),
      );
      final migrated = original.withSeedDesign(preserveComponentThemes: true);
      expect(
        migrated.inputDecorationTheme.contentPadding,
        const EdgeInsets.all(31),
      );
      expect(
        migrated.filledButtonTheme.style!.minimumSize!.resolve({}),
        const Size(120, 72),
      );
      expect(migrated.appBarTheme.centerTitle, isFalse);
      expect(migrated.extension<SeedTypography>(), isNotNull);
      expect(
        migrated.colorScheme.primary,
        const SeedColorScheme.light().fg.brand,
      );
    });

    test('preserved button styles win over SEED values they also set', () {
      final migrated = ThemeData(
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.all(30),
            shape: const StadiumBorder(),
            backgroundColor: const Color(0xFF123456),
          ),
        ),
      ).withSeedDesign(preserveComponentThemes: true);
      final seed = ThemeData().withSeedDesign().filledButtonTheme.style!;
      final style = migrated.filledButtonTheme.style!;
      expect(style.padding!.resolve({}), const EdgeInsets.all(30));
      expect(style.shape!.resolve({}), const StadiumBorder());
      expect(style.backgroundColor!.resolve({}), const Color(0xFF123456));
      expect(style.textStyle!.resolve({}), seed.textStyle!.resolve({}));
    });

    test('partial component overrides keep the remaining SEED fields', () {
      final migrated = ThemeData(
        dialogTheme: const DialogThemeData(insetPadding: EdgeInsets.all(8)),
        appBarTheme: const AppBarTheme(centerTitle: false),
        chipTheme: const ChipThemeData(shape: RoundedRectangleBorder()),
      ).withSeedDesign(preserveComponentThemes: true);
      final seed = ThemeData().withSeedDesign();
      expect(migrated.dialogTheme.insetPadding, const EdgeInsets.all(8));
      expect(migrated.dialogTheme.shape, seed.dialogTheme.shape);
      expect(
        migrated.dialogTheme.backgroundColor,
        seed.dialogTheme.backgroundColor,
      );
      expect(migrated.appBarTheme.centerTitle, isFalse);
      expect(
        migrated.appBarTheme.titleTextStyle,
        seed.appBarTheme.titleTextStyle,
      );
      expect(migrated.chipTheme.shape, const RoundedRectangleBorder());
      expect(migrated.chipTheme.labelStyle, seed.chipTheme.labelStyle);
      expect(
        ThemeData().withSeedDesign(preserveComponentThemes: true).cardTheme,
        seed.cardTheme,
      );
    });

    testWidgets(
      'uncontrolled RadioGroup and QuantityPicker do not register with a Form',
      (tester) async {
        final form = GlobalKey<FormState>();
        final radios = <String?>[];
        await tester.pumpWidget(
          restorableApp(
            Form(
              key: form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SeedRadioGroup<String>(
                    label: 'Size',
                    defaultValue: 'a',
                    onChanged: radios.add,
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SeedRadio(value: 'a', label: 'A'),
                        SeedRadio(value: 'b', label: 'B'),
                      ],
                    ),
                  ),
                  SeedQuantityPicker(defaultValue: 1, onChanged: (_) {}),
                ],
              ),
            ),
          ),
        );
        expect(find.byType(FormField), findsNothing);
        await tester.tap(find.text('B'));
        await tester.tap(find.byIcon(Icons.add_rounded));
        await tester.pump();
        form.currentState!.reset();
        await tester.pump();
        expect(radios, ['b']);
        expect(
          tester
              .widget<RadioGroup<String>>(find.byType(RadioGroup<String>))
              .groupValue,
          'b',
        );
        expect(find.text('2'), findsOneWidget);
      },
    );

    testWidgets('SeedFormField opts a SEED checkbox into Form validation', (
      tester,
    ) async {
      final form = GlobalKey<FormState>();
      await tester.pumpWidget(
        restorableApp(
          Form(
            key: form,
            child: SeedFormField<bool>(
              initialValue: false,
              validator: (agreed) => agreed == true ? null : 'Required',
              builder: (field) => SeedCheckbox(
                label: 'Agree to terms',
                checked: field.value ?? false,
                onCheckedChange: field.didChange,
              ),
            ),
          ),
        ),
      );
      expect(form.currentState!.validate(), isFalse);
      await tester.tap(find.text('Agree to terms'));
      await tester.pump();
      expect(form.currentState!.validate(), isTrue);
      form.currentState!.reset();
      await tester.pump();
      expect(form.currentState!.validate(), isFalse);
    });

    testWidgets('FAB supports explicit Material Hero and tooltip integration', (
      tester,
    ) async {
      await tester.pumpWidget(
        restorableApp(
          SeedFloatingActionButton(
            heroTag: 'compose',
            tooltip: 'Compose message',
            semanticsLabel: 'Compose message',
            icon: const Icon(Icons.add),
            onPressed: () {},
          ),
        ),
      );
      final hero = find.descendant(
        of: find.byType(SeedFloatingActionButton),
        matching: find.byType(Hero),
      );
      expect(tester.widget<Hero>(hero).tag, 'compose');
      expect(
        tester.widget<Tooltip>(find.byType(Tooltip)).message,
        'Compose message',
      );
    });
  });

  group('material_ui integration', () {
    for (final brightness in Brightness.values) {
      testWidgets('bottom sheet supports ListTile in $brightness mode', (
        tester,
      ) async {
        final seedTheme = brightness == Brightness.light
            ? SeedThemeData.light()
            : SeedThemeData.dark();
        String? selection;
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('ko'),
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            theme: seedTheme.toThemeData(),
            home: Scaffold(
              body: Builder(
                builder: (context) => SeedButton(
                  label: 'Open sheet',
                  onPressed: () async {
                    selection = await showSeedBottomSheet<String>(
                      context: context,
                      child: SeedBottomSheet(
                        title: 'Sort',
                        content: Builder(
                          builder: (sheetContext) => ListTile(
                            selected: true,
                            selectedTileColor:
                                seedTheme.colorScheme.bg.brandWeak,
                            title: const Text('Latest'),
                            onTap: () =>
                                Navigator.of(sheetContext).pop('latest'),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open sheet'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('Sort'), findsOneWidget);

        await tester.tap(find.text('Latest'));
        await tester.pumpAndSettle();
        expect(selection, 'latest');
        expect(find.text('Sort'), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets(
      'material_ui Korean localizations support Seed inputs and dialogs',
      (tester) async {
        bool? confirmed;
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('ko'),
            supportedLocales: const [Locale('en'), Locale('ko')],
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            theme: SeedThemeData.light().toThemeData(),
            home: Builder(
              builder: (context) {
                expect(MaterialLocalizations.of(context).okButtonLabel, '확인');
                expect(
                  context.seedColor.fg.brand,
                  Theme.of(context).colorScheme.primary,
                );
                return Scaffold(
                  body: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SeedTextInput(hintText: '이름'),
                      SeedButton(
                        label: '다이얼로그 열기',
                        onPressed: () async {
                          confirmed = await showSeedAlertDialog(
                            context: context,
                            title: '변경 확인',
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), '동네 이웃');
        expect(find.text('동네 이웃'), findsOneWidget);
        await tester.tap(find.text('다이얼로그 열기'));
        await tester.pumpAndSettle();
        expect(find.text('변경 확인'), findsOneWidget);
        await tester.tap(find.text('확인'));
        await tester.pumpAndSettle();
        expect(confirmed, isTrue);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
