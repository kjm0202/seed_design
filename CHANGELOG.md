## Unreleased

### Breaking changes

#### Source compatibility

- **List rows** now expose `showDivider` as `bool?` on `SeedListItem`, `SeedListLinkItem`, `SeedCheckListItem`, `SeedRadioListItem`, and `SeedSwitchListItem`. Null inherits `SeedList.showDividers` and resolves to false for standalone rows. Handle null when reading the property, using the parent list setting when applicable.
- **Widget types** changed for `SeedToggleButton` (`StatelessWidget` → `StatefulWidget`) and `SeedResponsivePair` (`StatelessWidget` → `MultiChildRenderObjectWidget`). Use `Widget` for variables and return types that only hold or return these widgets. `SeedAspectRatio` now composes `AspectRatio`. Use `ratio` in place of the inherited `aspectRatio` getter and use Flutter's `AspectRatio` directly where that type is required.
- **`SeedInputButtonSize`** adds `large`. Add a `large` case to exhaustive switches. `small` remains a distinct deprecated enum value with the same 40px dimensions as `medium`.
- **`SeedBgColors`** requires `neutralSolidMuted` and `neutralSolidMutedPressed` in direct constructor calls.
- **Picker fields** are nullable in two places. Read `picker.defaultValue ?? picker.min` for the quantity picker's initial seed before clamping. Use `SeedSliderMarker.resolveAlign(min, max)` for the effective alignment. An omitted marker alignment resolves to start at the minimum, end at the maximum, and center otherwise.
- **Enums** gain values: `SeedDatePickerLayout.twoWeeks` and new `SeedLabel` keys (search, two-week navigation, reorder announcements). Add cases to exhaustive switches over these enums.

#### Defaults and behavior

- **Buttons and fields.** `SeedButton.textColor` applies to ghost buttons with `enabled: true`, and `fontWeight` applies to ghost buttons. Use `SeedInputButtonSize.large` for the previous 52px `medium` size. The new `medium` is 40px and the default remains 52px under `large`. Set `clearable: true` on `SeedTextInput` or `SeedTextField` to keep the clear button.
- **Form validation and reset.** Server errors and grapheme-limit violations in `SeedTextField` now affect `FormState.validate()`. Clear a server error when the form can be submitted again. Uncontrolled `SeedRadioGroup` and `SeedQuantityPicker` no longer register with the enclosing form. Wrap them in `SeedFormField` when validation, saving, or resetting should be owned by the form.
- **List and choice controls.** Dividers are hidden by default. Set `showDividers: true` on the list or `showDivider: true` on a row to retain them. Standalone Checkbox, Radio, and Switch controls use their official visual sizes with a 44px touch target, and labeled rows use the official minimum heights. Use Space to toggle these controls and their check, radio, and switch list rows. Enter no longer toggles them.
- **Layout.** `SeedFloat.offset` now defaults to zero instead of 16px on all sides. `SeedResponsive.largeBreakpoint` moves from 1024 to 1280. Supply the earlier values explicitly to retain those layouts. Supply `SeedFooter.copyright` explicitly to display the previous copyright text. Grid auto-placement uses sparse placement. With only `rows` set, row flow uses a single column. Specify columns or explicit `row` and `column` positions where the layout depended on the previous placement.
- **Picker locale.** DatePicker and TimePicker follow the app locale when omitted and fall back to English (`en_US`) when no supported locale is available. Pass `locale: const Locale('ko', 'KR')` to keep Korean formatting in an app that uses another language. The public `locale` properties are now nullable.
- **Attachments and pickers.** Pass `maxCount: 10` to `SeedAttachmentInput` to keep the previous attachment limit of ten. The default is now one. An omitted quantity starts at `min`. Pass `defaultValue: 1` to retain the previous initial seed, subject to the picker's bounds. Reselecting the current date no longer emits `onValueChange`. TimePicker rounds minute ties up, so 10:05 with a ten-minute step becomes 10:10.
- **Select.** The default popup uses an anchored overlay and an 8px menu gap. Set `menuOffset: Offset.zero` to retain a zero gap. A non-default `menuAlignment` still uses `MenuAnchor`. Update widget tests that locate the default popup by its `MenuAnchor` implementation.
- **Multiple Select value.** A `SeedSelect(multiple: true)` trigger shows the selected labels joined by `, `, like React's `SelectValue`, instead of removable chips. Use `formatValue` to change the text, or `valueBuilder` to render chips or other custom content.
- **Menu focus.** Tab requests dismissal and moves focus beyond the menu. Shift+Tab from the menu can return to its trigger while leaving it open. Account for these focus transitions in keyboard handlers and tests.
- **Material Snackbar.** `showSeedSnackbar` now reports `SnackBarClosedReason.action` instead of `hide` when the action is selected. Update consumers of `ScaffoldFeatureController.closed` that branch on the previous reason. A snackbar with both an action label and callback persists by default. Pass `persist: false` to keep its timeout.
- **SEED Snackbar controller.** An active entry exits before the next entry enters. `SeedSnackbarController.show` defaults `removeDelay` to 200ms and calls the active entry's `onClose` after removal. Move logic that depends on removal into that callback.
- **Navigation.** `SeedTabs.fill` defaults to true. Pass `fill: false` to retain intrinsic tab widths. Adaptive `SeedTopNavigation` centers titles on iOS only and uses a chevron for the default back action. Set `centerTitle` or provide `leading` for the earlier presentation. The bar can now infer Drawer and EndDrawer actions. Use explicit `leading` and `actions` to control the buttons, or disable inference with `automaticallyImplyLeading: false`. String titles and subtitles follow the ambient text scaler. Pass a `titleTextScaler` clamped to 1.0–1.2 to retain the previous limits.
- **SEED 3.3.0 colors.** `bg.neutralWeakAlpha` and its pressed color now use `gray-alpha-200/300`, and `stroke.neutralWeak` uses the translucent `gray-alpha-400`. Outlines of `neutralOutline` and `brandOutline` buttons, the neutral outline Badge, outline Chips, ReactionButton, and the disabled square Checkbox move from `stroke.neutralMuted` to `stroke.neutralWeak`. Update tests that compare these colors as opaque values.
- **Tabs reveal.** A selected tab within 16px of a scroll edge now scrolls to leave 16px beside it, and the ChipTabs reveal box no longer includes the 8px gap.
- **Top navigation text button.** The label follows the system text scale between 1.0 and 1.2, and the button hugs its label instead of filling a loosely constrained slot.
- **Attachment reorder.** Items that cannot move (disabled or read-only) no longer expose move accessibility actions. A keyboard reorder shows the item at its provisional position and announces start, cancel, and drop. The list is no longer a Material `ReorderableListView`; update tests that locate it by that type. With a trigger in RTL, the start padding now sits before the trigger.
- **Collapsed side navigation.** The flyout is a disclosure built on `SeedNavigationMenu`: hover opens after 200ms and closes after 100ms, hover and mouse clicks keep focus where it was, and sub-items without `onTap` stay enabled. The flyout no longer highlights the selected sub-item's background.
- **DatePicker.** Changing the visible range in non-continuous layouts fades the new rows in with a 20px slide. Reduced motion keeps the fade only.

### Added and deprecated APIs

- Add locale-aware, overridable labels through `SeedLocalizations`. Omitted labels follow the locale and explicit strings take precedence.
- Add opt-in `preserveComponentThemes` to the Material bridge. It defaults to false. When enabled, supplied Material component theme fields take precedence and SEED fills the remaining fields.
- Add `SeedSelectFormField` for validation, save, reset, and restoration, and `SeedTabBar` for Material `TabController` and `TabBarView` integration. Add English and Korean migration guides.
- Add `SeedTopNavigation.slot` for custom content that fills the space between leading and trailing actions. Use it separately from title and subtitle inputs. Add `bottom`, `titleTextScaler`, and `automaticallyImplyLeading` to the navigation bar, and optional Hero tags and tooltips to `SeedFloatingActionButton`.
- Add text input autofill, IME, editing, and restoration options. Add `forceErrorText` and `restorationId` to `SeedFormField`. Add `showDefaultSuffix` and `contentScale` to `SeedInputButton`, and `showValueChips` to `SeedFieldButton` for choosing chips or plain text.
- Add `invalid` to Field, TextInput, InputButton, Select, and QuantityPicker. Deprecate the corresponding `isInvalid`, `hasError`, and `isError` inputs. Add `description` to Field and `placeholder` to TextInput, with `helperText` and `hintText` retained as compatibility inputs.
- Add `pressed`, `defaultPressed`, and `onPressedChange` to ToggleButton, and `variant` to ContextualFloatingButton, Checkbox, and Checkmark. Their existing `selected` and `onSelectedChanged`, `tone`, and `shape` inputs remain available as deprecated aliases.
- Add `invalid` and `required` to Checkbox, Radio, and Switch. Add `labelWeight` to TextField, FieldButton, Select, Slider, and RadioGroup, `indicatorText` to Field, and `indicator` to TextField, attachment fields, and Slider. Add `showRequiredIndicator` to RadioGroup and Slider, `required` to Fieldset, `labelWeight` to attachment fields, `tone` to RadioListItem, and `jumpMultiplier` to Slider.
- Add `SeedAttachmentInput.scrollPadding` for scroll content in regular and reorderable lists, with a default of `EdgeInsets.zero`. Add `SeedFooterLink.uri` for link semantics.
- Add `SeedPagination.visibleItemCount` with 7 or 9 controls including arrows. `maxVisibleSlots` continues to count page slots. Add `SeedTablePagination.rangeLabel`, Grid's CSS-style `colSpan` and one-based start/end lines, and full-span placement via `SeedGridItem.full`. Add `SeedLayoutContent` with density presets and `SeedScrollFogMask`. Allow `SeedAspectRatio.ratio` to be omitted, with a default of 4/3.
- Add ordered `flipFallbackSides` to HelpBubbleTrigger and AnchoredOverlay, plus `fitMinExtent` and `tabExitsContent` to AnchoredOverlay. Add `focusableWhenScrollable` to ScrollArea and `onClosePressed` to BottomSheet. Dialog and sheet helpers accept route builders and Navigator, route, and focus options. Bottom sheets support constraint overrides. Add `showSeedSnackbar.onVisible`.
- Add `semanticsLabel` to SegmentedControl, Select, InputButton, SelectBoxGroup, ChipRadioGroup, Menu, and Popover. Add control focus rings and options to customize focus and link semantics on `SeedPressable`. Set `activateOnEnter: false` to activate on Space only, and `unfocusOnDisabledTap` so a pointer tap on a disabled choice row blurs the focused input, as native controls do.
- Align tokens and the official reference fixture with SEED React/CSS 3.3.0.
- Add `SeedSearchInput` with `onSubmit`, `blurOnSubmit`, and a clear button that keeps the input focused.
- Add `SeedSegmentedTextInput` with segments, separators, masked dots, paste and autofill distribution, and `SeedSegmentedTextInputFormField`.
- Add `SeedNavigationMenu` with its root, trigger, content, group, and item widgets.
- Add `SeedDatePickerLayout.twoWeeks`, which shows two weeks and moves by two weeks.
- Add `SeedConsistentWidth`, `SeedLoadingIndicator`, and `SeedStaticTextScope` with the 42 `tNStatic{Regular,Medium,Bold}` text styles.
- Add `extendSafeAreaX` to Tabs, TabBar, TabsView, ChipTabsView, PageBanner, AttachmentInput, and the attachment fields.
- Add `titleWidget`, `descriptionWidget`, and `suffixIcon` to `SeedAccordionItem`, and `errorMessage` and `errorIcon` to `SeedFieldset`.

### Fixes and accessibility

- Preserve focus requested by a search submit callback. Keep the caret at the end of masked segmented input when it receives keyboard focus, and use the available segment width for fill placeholders.
- Stop `SeedSegmentedTextInput` segments from drawing the app theme's Material input border inside the group frame. Keep the example Home grid valid during Android's zero-size first frame.
- `SeedTopNavigation.slot` places text buttons like icon buttons: their 10px padding overhangs the bar edge and the slot, so labels line up with the 16px bar padding. With the Android layout, a leading button also keeps the 16px gap before the slot.
- The attachment dropzone's drag hint keeps its `fg.neutralSubtle` color when the field is full or disabled; only the select button dims.
- Reach the first and last available weeks in the two-week calendar, and end the previous transition when the layout or week start changes.
- Preserve unrelated focus when a controlled navigation menu reopens, reset reinserted sidebar items to their initial state, and wait for the sidebar width transition before enabling flyouts and tooltips.
- Hovering a navigation menu or collapsed sidebar flyout opens it again after it closed on leave. Only a keyboard-opened flyout closes when focus leaves it, as in React, and a Popover opened while focus is elsewhere no longer closes at once.
- Update horizontal safe-area insets when the view changes inside a `SafeArea`. Keep keyboard attachment reorder within both insets and cancel a provisional move when its target disappears.
- Keep focus on the moving attachment when rapid arrow presses scroll its new position into view, so Space can still confirm the new order.
- Preserve Switch, Tabs and WheelPicker selection across label and item changes. Reconcile QuantityPicker bounds, and move the two-month calendar one month at a time.
- Apply Fieldset disabled state to text inputs and input buttons. Keep chip removal and tag actions accessible, and allow separate required-marker and character-count display. Add explicit radio select-box groups and independent Select display and typeahead text.
- Open menus with arrow keys, separate sheet drag dismissal from the backdrop, and forward close and handle callbacks through sheet wrappers. Avoid floating controls after a Snackbar controller swap and report discarded entries separately.
- Add light and dark gray-alpha and banner colors, retain partial theme overrides, and honor end-only Grid lines and full-span precedence.

- Localize optional Field indicators and Chip delete announcements. Use singular wording for one unread notification and preserve enclosing label overrides inside nested scopes and dialogs.
- Outside taps in dismissible routes close the topmost Select, Menu, or Popover. Track moving anchors and restore nested-menu keyboard focus and Escape handling after an Accordion collapses. Menus keep the requested side when their contents fit and size long menus before trying a fallback side. After pointer or semantic activation, the first arrow key targets the appropriate enabled item in Menu or the selected option in Select when available.
- Plain-text Popovers size within `minWidth` and `maxWidth` and reserve their scroll fade only on overflow. Custom content keeps the max-width layout, and narrow footers keep action labels readable. Scrolling Dialog bodies accept keyboard focus and arrow-key scrolling. Remove the extra Dialog root tab stop and the shadows on Dialog and AlertDialog.
- Match BottomSheet and MenuSheet drag dismissal to the React thresholds of 25% of height or 0.4px/ms, with backdrop fade during drag. Keep MenuSheet items at least 52px tall and snapping BottomSheet footers next to their content.
- Name HelpBubble content as a dialog whose bounds exclude the arrow. Semantics tests can find the dialog node inside `SeedHelpBubble`. FieldButton and Select expose the field name and shown value, radio groups expose named radio groups, and a labelled single Slider exposes one slider node. List links expose a single link node. Field label taps, sheet handles, and attachment dropzones avoid unnamed button nodes. MenuSheet retains an accessible close action when its visible cancel button is hidden, and ReactionButton uses its label as its accessible name. Updated localized defaults include the sidebar toggle and attachment remove and retry actions.
- Keep choice marks on the first line of wrapped labels and stretched Switch labels at the trailing edge. RadioListItem uses a large mark inside the row. Place Fieldset descriptions below the controls and use medium field label typography. Draw focus rings around the control mark and inset them on List rows and Accordion triggers. `SeedToggleButton` draws its focus ring with the full pill radius.
- Keep strokes from shifting input, quantity, reaction, outline Chip, and SelectBox content. Align the Field required mark and show the default error icon. Align PageBanner icons to the first line and preserve the 40px minimum height with an action. Align text-attached badges to the top of the line and attachment remove buttons to the overhanging position. Keep Chip icon spacing and align ListHeader and Popover close-button geometry.
- Let attachment dropzones span the field width and clear stale progress in `SeedAttachmentController.updateStatus`. Restore owned text controllers through Flutter's editing lifecycle. Prevent duplicate Material Snackbar action callbacks.
- Give `SeedResponsivePair` children equal shares and stack them in reverse order at full width when they overflow. Apply alignment to wrapping `SeedFlex`, move the Footer country selector into navigation, and use horizontal layout bleed for `SeedButton(bleed: true)`.
- Align Select option styling and transitions, add typeahead and looping arrow navigation, apply `formatValue` to single selection, and clear stale pointer state. Press feedback scales Select content while the InputButton root stays in place. FieldButton omits the default chevron.
- Align Slider to a 26px track layout with a 20px thumb, one bounded value bubble, and no Material dots on stepped ranges. Preserve step precision, step through `allowedValues`, and support Home, End, PageUp, PageDown, and Shift+Arrow. Fix mixed fixed/flexible WheelPicker columns, and size TimePicker columns to their widest value like React's `max-content` instead of fixed shares. Add WheelPicker mouse drag and PageUp/PageDown support, and use the corrected scroll-fog mask.
- Let Pagination and TablePagination render without a Material ancestor. Use 40px value-sized table selectors and compact range labels such as `51-75`. Preserve collapsed SideNavigation state and current-item indication. Give the flyout a 240px minimum width and a visible group heading without a tooltip over it. Truncate item labels on one line, inset press surfaces, and remove header and footer dividers. Keep the page scroll position on tab arrow navigation.
- Align the remaining visual feedback with React, including Accordion hover surfaces, flat WheelPicker styling, and ink-free DatePicker, Menu, Footer, and SideNavigation controls. Correct `SeedScrollFog` opacity and mask direction. Preserve text selection in pull-to-refresh content.
- Toggling `extendSafeAreaX` at runtime no longer remounts content: TabsView keeps the selected carousel page and page state, Tabs and ChipTabsView keep the strip's scroll offset, AttachmentInput keeps its scroll offset, keyboard focus, and a provisional keyboard reorder, and PageBanner keeps its content state.

### Example and web

- Add the App Bar text button demo and a home entry for Search Bar. Search Bar dismisses the keyboard on a body tap and shows the close action in place when opened as the root screen.
- Expand the safe area demo with live inset values, swipeable and content-width tabs, a magic banner, attachment lists, a dropzone, and Image Frame overlays. Show keyboard reorder instructions in the attachment demos.
- Add demos for SearchInput, segmented number fields, navigation menus, the two-week calendar, consistent text width, loading, static typography, horizontal safe areas, and Accordion and Fieldset slots. Card number, resident number, and Search Bar are showcase compositions.
- Align the Stackflow showcase's platform transitions, responsive layouts, browser font scaling, and component demos. Preserve per-Activity Step history while isolating fresh Activities, retain parent screens for pushed modals, and keep sheet draft controllers alive through dismissal.
- Add the textarea autoresize and scroll demo at `/e2e/textarea-autoresize-scroll`.
- Use path URLs and a GitHub Pages `404.html` app shell so showcase routes open directly and survive page refreshes.

## 1.0.0

### Breaking changes

- **Select:** Use list-valued `value/defaultValue/onValueChange` for single and multiple selection.
- **Time Picker:** Default to 00:00 and five-minute steps; allow only 1/5/10/15/30-minute steps.
- **Text Input / Text Field:** Disallow controllers combined with values or defaults.
- **Attachments:** Default to one entry and disallow controllers combined with entries or defaults.
- **Menu:** Report item selection as `SeedOverlayDismissReason.itemClick` instead of `action`; update consumers that inspect dismissal reasons.
- **Snackbar:** Default controllers and providers to `SeedSnackbarStrategy.immediate`; specify `queued` to retain queueing. Restart the full timeout after hover/focus pause ends.
- **Tooltip:** Default opening delay to 200ms instead of 500ms and `keepOpenOnContentHover` to false. Set explicit values to retain the previous behavior; closing delay remains 100ms.
- **Bottom Sheet:** For `showSeedBottomSheet` with snap points, default to a 90% viewport content cap and fade the backdrop from the last snap index. Review existing fractional snap layouts; direct `SeedSnappingBottomSheet` use retains its full-height default.
- **Side Panel:** Apply the default 80% safe-width cap on desktop as well as mobile; use `maxWidth` to specify an explicit cap.

### Bug fixes

- **State management:** Initialize defaults once and respect parent-controlled edits, empty selections, and form resets.
- **Accessibility:** Bridge semantic focus and activation to actual keyboard focus; handle repeated arrow keys and skip disabled choices.
- **Themes:** Honor explicit font overrides with supplied SEED themes.
- **Material controls:** Match selected-state colors to Seed brand colors.
- **Material migration:** Correct form-field and Tooltip replacement guidance.
- **Linear Progress Indicator:** Preserve numeric progress and semantics during migration.
- **Accordion:** Expose a heading containing a separate named button; fix single-item expansion and full-width pressed cards.
- **Attachments:** Fix single-entry batches, preview overflow, filename extensions, and disabled-state actions.
- **Attachment dropzone:** Keep dashed borders visible outside dragging.
- **Avatar:** Fix badge geometry, 20px badge visibility, fallback clipping, and loading/error placeholders.
- **Alert Dialog:** Fix responsive actions and overflow; make backdrop dismissal opt-in.
- **Badge:** Match default variants to React.
- **Bottom Sheet:** Preserve snap indices, controller synchronization, minimum-height resizing, and dismissal settings; re-resolve pixel snaps on viewport resize without interrupting handle drags.
- **Button:** Match default variants to React and preserve variant-specific loading backgrounds when interaction is disabled.
- **Callout:** Fix link/icon defaults, multiline alignment, magic-icon colors, and the 40px close target.
- **Checkbox:** Match the default brand tone to React.
- **Chip:** Match the default solid variant to React.
- **Content Placeholder:** Render the twelve official illustrations with correct clipping and sizing.
- **Date Picker:** Fix initial continuous-calendar freezes and restore month/year wheel navigation.
- **Dialog:** Fix exit scale, headerless close-button space, and short-body spacing/fades.
- **FAB:** Fix content width and Contextual Floating Button defaults; require icon-only labels.
- **Field:** Focus inputs when their labels are activated.
- **Footer:** Prevent narrow-layout overflow.
- **Help Bubble:** Fit content height and preserve the 38px close target.
- **Image Frame:** Correct defaults and overlay insets.
- **Input Button:** Correct clear-button availability.
- **List:** Preserve pressed-state layout and divider suppression.
- **Manner Badge:** Exclude decorative emoji from screen readers.
- **Menu:** Fix small styling, keyboard search/wrapping, accessibility roles, and callback-free selection.
- **Menu Sheet:** Match handle-swipe dismissal, preserve non-dismissible sheets, and use the correct swipeable/non-swipeable header spacing.
- **Notification Badge:** Correct placement in Bottom Navigation and Tabs.
- **Overlays:** Fix nested outside-click boundaries, topmost Escape handling, initial content focus, Tab/Shift+Tab traversal, and trigger focus restoration. Preserve controlled dismissal reasons and default Popover focus-out policy to `closeOnInteractOutside`.
- **Pagination:** Correct compact page ranges.
- **Progress Circle:** Announce `loading...` for indeterminate progress without supplying a false percentage; honor explicit semantics overrides.
- **Pull to refresh:** Preserve scroll ownership, rebase retreating gestures, rearm held contacts after re-enabling or loading, block interrupted multitouch gestures, and settle rejected refreshes safely. Match touch-slop delivery and ready callbacks on each move above the threshold.
- **Radio:** Restore interaction feedback and pointer selection.
- **Reaction Button:** Keep touch targets independent of icon size.
- **Segmented Control:** Correct selected disabled colors.
- **Select:** Keep controlled popups open when dismissal is rejected, while reporting Tab dismissal requests as `focusOut`. Focus the selected or first enabled option and keep readonly triggers focusable without allowing edits.
- **Side Navigation:** Fix parent actions, active-child expansion, and collapsed-submenu access.
- **Side Panel:** Correct desktop widths.
- **Snackbar:** Preserve explicit queued FIFO order, helper prefix icons, and provider lifecycle across route changes.
- **Switch:** Keep row touch targets independent of switch graphics, controlled switches enabled without callbacks, and disabled checked brand tracks in the brand color.
- **Table Pagination:** Separate the range selector from the total count and use medium-sized selectors.
- **Tabs:** Fix value precedence, large-label sizing, carousel height, and intermediate-page selection. Reveal selected line/chip tabs in LTR and RTL layouts, support mouse carousel drags, and honor lazy-mount and unmount policies.
- **Tag:** Prevent overflow with enlarged text, measure actual rendered content, and retain accessible labels when truncating.
- **Text Input / Text Field:** Synchronize external controllers with form validation.
- **Tooltip:** Match Help Bubble placement and transitions; keep descriptive content out of keyboard and accessibility focus traversal.
- **Wheel Picker:** Commit after scrolling settles and honor Small/custom row heights. Expose one adjustable semantic control per column, retain focus across controlled value/option changes, and preserve rapid repeated-key targets and readonly focus boundaries.
- **Examples:** Correct Manner Temp and attachment demos, remove duplicate controls, and preserve category/tab state and nested modal parents.
- **Packaging:** Update bundled example font/image attribution and exclude development documents from the published package.

### Features

- **Public API:** Add official React callback names; retain legacy aliases as deprecated APIs with replacement hints.
- **Examples:** Replace the custom component catalog with a Flutter clone of Karrot's official SEED Design React Stackflow SPA example. Include component, form, and screen activity routes, an article/filter/detail demo, synchronized browser URLs, Back, Forward, and modal-step history, and browser-native list alerts with a native Flutter fallback. Replace legacy catalog tests with SPA route and interaction coverage.
- **Accordion:** Add groups, accessible headings, and content fading.
- **Attachments:** Add `SeedAttachmentController`, progress/retry controls, independent `invalid` state, `showRequiredIndicator`, and configurable `representativeLabel` text.
- **Badge:** Add accessible actions and fixed icon slots.
- **Bottom Navigation:** Add disabled items and screen-reader notification values.
- **Bottom Sheet:** Add snap points, handle-tap cycling, keyboard positioning options `fixed/repositionInputs`, and content-height controls `snapContentHeightFraction/contentHeightFraction`.
- **Callout:** Add controlled visibility and self-dismissal.
- **Checkbox:** Add `checked/defaultChecked/onCheckedChange`.
- **Chip:** Add checked-state APIs and radio groups.
- **Date Picker:** Add typed `.range/.multiple` constructors, `selectionMode/visibleRange`, layouts, and constraints.
- **FAB:** Add transitions.
- **Image Frame:** Add pressed-state APIs, accessible heart toggles, nine-position overlays, and image callbacks.
- **Input Button:** Add responsive sizes.
- **List:** Add accessibility semantics, `SeedListItem.linkUrl`, and `SeedListLinkItem` with a URI and consumer-managed navigation callback.
- **Menu:** Add responsive sizes.
- **Menu Sheet:** Add selection, dismissal, per-group `groupLabelAlignments`, and `swipeable/handleDragDismissible` options.
- **Notification Badge:** Add sizes, accessibility labels, and icon/text positioning.
- **Overlays:** Add controlled triggers, placement, focus, dismissal, separate Alert/Sheet Escape policies, and Flutter-specific `contentFocusable` control for anchored content.
- **Pagination:** Add `page`.
- **Pull to refresh:** Add pull-to-refresh support.
- **Reaction Button:** Add `pressed/defaultPressed/onPressedChange`.
- **SelectBox:** Add checked-state APIs and radio-group `onValueChange`.
- **Side Navigation:** Add collapsed-state APIs and item `onOpenChange`.
- **Side Panel:** Add responsive layouts and a `semanticsLabel` override for visually hidden titles.
- **Slider:** Add `values/defaultValues/onValuesChange/onValuesCommit`.
- **Snackbar:** Add queue strategies and pause support.
- **Switch:** Add checked-state APIs and single-target rows.
- **Table Pagination:** Add combined page and page-size state.
- **Tabs:** Add string values, carousels, and configurable `chipListPadding` on tabs and tab views.
- **Text Field:** Add structured fields and grapheme-aware callbacks.
- **Tooltip:** Add bool-only `onOpenChange` and configurable delays.
- **Wheel Picker:** Add value defaults, change details, index callbacks, looping, item taps, and disabled states.

## 0.3.0

- Fix Menu Sheet width and safe-area alignment on wide screens.
- Align Side Panel layout and scrolling with official specifications; change the
  default width from 480px to 720px.
- Refine confirmation dialog, bottom sheet, and detail panel examples.
- Center numbered pagination in the catalog.

## 0.2.0

- Add gradient tokens, `articleNote`, reaction button labels, input/picker size
  options, and vertical select box layouts.
- Align component dimensions, typography, colors, and interaction states with
  official SEED specifications, including changes to default sizes and styles.
- Improve Bottom Sheet layout, keyboard handling, and header customization.
  Show the close button and hide the handle by default.
- Fix narrow-screen pagination and segmented controls, add Result Section padding
  overrides, and align Alert Dialog text to the direction start.
- Show focus rings for keyboard interaction and hide them after pointer clicks.

## 0.1.1

* Add a Flutter Web showcase hosted on GitHub Pages, with automatic deployment.
* Link the showcase from the English and Korean READMEs.

## 0.1.0

* Initial Release
* Support Flutter 3.47.0 and later with Dart 3.13.0 and later; align package and example SDK requirements.
