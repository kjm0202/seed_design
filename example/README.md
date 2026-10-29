# Stackflow SPA example

[한국어](README_ko.md)

The default example is a Flutter port of the official SEED Design `examples/stackflow-spa`. Browse component activities from `ActivityHome`, or open `/demo/home` for the article list, category filter, and detail demo. The app follows the system light/dark theme.

[Open the web showcase](https://kjm0202.github.io/seed_design/).

Requires Flutter 3.47.0 or later and Dart 3.13.0 or later.

## Run

From the repository root:

```sh
cd example
flutter pub get
flutter run
```

For the browser, use `flutter run -d chrome`. The same default entrypoint is used for every platform and the published web showcase.

The port uses Flutter’s `Navigator` for named routes, push/replace/pop, and native back gestures. DOM/CSS-only behavior and some transitions are adapted for Flutter. Intentional web bug reproducers, performance probes, and E2E fixtures are excluded from the supported tour.

## Source files

| File | Contents |
| --- | --- |
| [main.dart](lib/main.dart) | Default app entrypoint |
| [stackflow_spa.dart](lib/stackflow_spa/stackflow_spa.dart) | App theme, route handling, and activity home |
| [spa_catalog.dart](lib/stackflow_spa/spa_catalog.dart) | Home sections and activity links |
| [spa_paths.dart](lib/stackflow_spa/spa_paths.dart) | Activity names and route paths |
| [forms_pages.dart](lib/stackflow_spa/forms_pages.dart) | Input and selection activities |
| [display_pages.dart](lib/stackflow_spa/display_pages.dart) | Buttons, badges, and display activities |
| [navigation_pages.dart](lib/stackflow_spa/navigation_pages.dart) | Navigation and layout activities |
| [overlay_pages.dart](lib/stackflow_spa/overlay_pages.dart) | Dialog, sheet, and overlay activities |
| [screen_pages.dart](lib/stackflow_spa/screen_pages.dart) | App screen and transition activities |
| [extra_pages.dart](lib/stackflow_spa/extra_pages.dart) | Additional component activities |
| [demo_pages.dart](lib/stackflow_spa/demo_pages.dart) | Article list, filters, and detail screens |

## Tests

From the example directory:

```sh
flutter test
# Run against a booted iOS Simulator or Android Emulator:
flutter test integration_test/stackflow_spa_navigation_test.dart -d <device-id>
```

Widget tests cover the default entrypoint, supported activity routes, component variants, and article/filter/detail interactions.

## Web deployment

The [GitHub Pages workflow](../.github/workflows/showcase.yml) builds and deploys this app when the example or library changes on `master`. You can also run it manually from the repository’s Actions tab.

To build the same site locally, run this from the example directory:

```sh
flutter build web --release --base-href /seed_design/
```
