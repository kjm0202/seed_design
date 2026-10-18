# Example app

[한국어](README_ko.md)

Try the package’s buttons, inputs, menus, and other components. Use the button in the top-right corner to switch between light and dark themes.

Requires Flutter 3.47.0 or later and Dart 3.13.0 or later.

## Run

From the repository root:

```sh
cd example
flutter pub get
flutter run
```

## Source files

| File | Contents |
| --- | --- |
| [main.dart](lib/main.dart) | App setup, theme switching, and tab navigation |
| [components_tab.dart](lib/tabs/components_tab.dart) | Buttons, badges, chips, lists, and selection controls |
| [feedback_tab.dart](lib/tabs/feedback_tab.dart) | Manner temperature, progress indicators, skeletons, and help bubbles |
| [inputs_tab.dart](lib/tabs/inputs_tab.dart) | Text inputs, quantity controls, and date and time pickers |
| [navigation_tab.dart](lib/tabs/navigation_tab.dart) | Pagination, tables, images, and navigation menus |
| [overlays_tab.dart](lib/tabs/overlays_tab.dart) | Dialogs, bottom sheets, side panels, and notifications |
| [seed_menu_example.dart](lib/widgets/seed_menu_example.dart) | A dropdown menu opened by a more-options button |

## Tests

From the example directory:

```sh
flutter test
```
