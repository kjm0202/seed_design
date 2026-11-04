import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' as seed_material;
import 'package:seed_design/seed_design.dart';
import 'package:seed_design_example/stackflow_spa/spa_paths.dart';
import 'package:seed_design_example/stackflow_spa/stackflow_spa.dart';

// Registered diagnostic routes that intentionally render the generic
// "unsupported example" page. Keep this list independent of production
// dispatch: a lost build*Page case must not silently reclassify an implemented
// route as unsupported.
const _unsupportedActivities = <String>{
  'ActivityPopTest',
  'ActivityAnimateFalseTest',
  'ActivityCodegenTest',
  'ActivityPerfCheck',
  'ActivityE2EImageBehavior',
  'ActivityIacvtLeak',
  'ActivityIacvtSidePanel',
  'ActivityIacvtOverlay',
  'ActivityIacvtMargin',
  'ActivityIacvtExperiment',
  'ActivityMixedVersionTest',
};

// Implemented routes that are not part of the themed SPA tour, checked
// separately below.
const _notFoundActivity = 'ActivityNotFound';

const _e2eActivity = 'ActivityE2ETextareaAutoresizeScroll';

const _unsupportedText = '구현되지 않은 예제입니다.';

const _notFoundText = '404 Not Found';

Object? _argumentsFor(String activity) => switch (activity) {
  'ActivityDetail' => <String, Object>{
    'title': 'Route smoke test',
    'body': 'Opened through Navigator.pushNamed.',
  },
  'ActivityDemoArticleDetail' => 1,
  'ActivityTransitionStyle' => <String, String>{
    'transitionStyle': 'slideFromRightIOS',
  },
  _ => null,
};

Future<void> _openRoute(
  WidgetTester tester,
  String path, {
  Object? arguments,
  Brightness brightness = Brightness.light,
}) async {
  // Size the app like a phone. Avoid pumpAndSettle: some demo activities
  // intentionally animate, schedule delayed work, or open modal routes.
  tester.view.physicalSize = const Size(440, 960);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  tester.platformDispatcher.platformBrightnessTestValue = brightness;
  addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

  await tester.pumpWidget(const StackflowSpaApp());
  await tester.pump();

  final navigator = tester.state<NavigatorState>(find.byType(Navigator));
  navigator.pushNamed(path, arguments: arguments);

  // A fixed, short window runs the route transition and its post-frame
  // overlay opener without waiting for demo timers or looping animations.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 350));
  await tester.pump();

  expect(
    tester.takeException(),
    isNull,
    reason: '$path threw while navigating or building.',
  );
}

Future<void> _disposeRoute(WidgetTester tester, String path) async {
  // Release route-owned controllers and timers before the next activity.
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  expect(tester.takeException(), isNull, reason: '$path failed to dispose.');
}

void main() {
  final tourRoutes = spaActivityPaths.entries
      .where(
        (entry) =>
            !_unsupportedActivities.contains(entry.key) &&
            entry.key != _notFoundActivity &&
            entry.key != _e2eActivity,
      )
      .toList(growable: false);
  final unsupportedRoutes = spaActivityPaths.entries
      .where((entry) => _unsupportedActivities.contains(entry.key))
      .toList(growable: false);

  test('route names and paths are unique; classifications are explicit', () {
    expect(
      spaActivityPaths.values.toSet().length,
      spaActivityPaths.length,
      reason: 'Each activity must have a unique browser path.',
    );
    expect(spaActivityPaths.keys, containsAll(_unsupportedActivities));
    expect(
      spaActivityPaths.keys,
      containsAll(const [_notFoundActivity, _e2eActivity]),
    );
    expect(tourRoutes, isNotEmpty);
    expect(
      tourRoutes.length + unsupportedRoutes.length + 2,
      spaActivityPaths.length,
    );
  });

  const brightness = Brightness.light;
  for (final route in tourRoutes) {
    testWidgets(
      '${route.key} opens ${route.value} without errors, fallback or 404 '
      '($brightness)',
      (tester) async {
        await _openRoute(
          tester,
          route.value,
          arguments: _argumentsFor(route.key),
          brightness: brightness,
        );

        expect(
          find.text(_notFoundText, skipOffstage: false),
          findsNothing,
          reason: '${route.key} (${route.value}) fell through to the 404 page.',
        );
        expect(
          find.text(_unsupportedText, skipOffstage: false),
          findsNothing,
          reason:
              '${route.key} (${route.value}) resolved to the generic '
              'unsupported fallback.',
        );
        expect(
          find.byType(SeedTopNavigation, skipOffstage: false),
          findsWidgets,
          reason:
              '${route.key} (${route.value}) did not create the SPA app bar.',
        );
        for (final element
            in find.byType(SeedTopNavigation, skipOffstage: false).evaluate()) {
          expect(
            Theme.of(element).brightness,
            brightness,
            reason: '${route.key} lost the stock Flutter theme.',
          );
          expect(
            seed_material.Theme.of(element).brightness,
            brightness,
            reason: '${route.key} lost the SEED theme.',
          );
          expect(
            Theme.of(element).colorScheme.surface,
            seed_material.Theme.of(element).colorScheme.surface,
            reason: '${route.key} has mismatched surface colors.',
          );
        }

        await _disposeRoute(tester, route.value);
      },
    );
  }

  group('registered unsupported diagnostic routes', () {
    for (final route in unsupportedRoutes) {
      testWidgets('${route.key} (${route.value}) shows the generic fallback', (
        tester,
      ) async {
        await _openRoute(tester, route.value);

        expect(
          find.text(_unsupportedText, skipOffstage: false),
          findsOneWidget,
          reason: '${route.key} must remain an explicit unsupported example.',
        );
        expect(
          find.text(_notFoundText, skipOffstage: false),
          findsNothing,
          reason: '${route.key} is registered and must not be treated as 404.',
        );

        await _disposeRoute(tester, route.value);
      });
    }
  });

  testWidgets('$_e2eActivity opens without fallback or 404', (tester) async {
    final path = spaActivityPaths[_e2eActivity]!;
    await _openRoute(tester, path);

    expect(find.text(_unsupportedText, skipOffstage: false), findsNothing);
    expect(find.text(_notFoundText, skipOffstage: false), findsNothing);

    await _disposeRoute(tester, path);
  });

  testWidgets('the registered 404 path renders the dedicated 404 page', (
    tester,
  ) async {
    final path = spaActivityPaths[_notFoundActivity]!;
    await _openRoute(tester, path);

    expect(find.text(_notFoundText, skipOffstage: false), findsOneWidget);
    expect(find.text(_unsupportedText, skipOffstage: false), findsNothing);

    await _disposeRoute(tester, path);
  });

  testWidgets('an unknown URL renders the 404 page, not the fallback', (
    tester,
  ) async {
    const unknown = '/__unregistered-route__/nested';
    expect(spaPathActivities.containsKey(unknown), isFalse);
    await _openRoute(tester, unknown);

    expect(find.text(_notFoundText, skipOffstage: false), findsOneWidget);
    expect(find.text(_unsupportedText, skipOffstage: false), findsNothing);

    await _disposeRoute(tester, unknown);
  });
}
