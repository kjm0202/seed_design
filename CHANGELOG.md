## 2.0.0

Based on SEED Design React/CSS 3.3.0.

### Breaking changes

#### Source compatibility

- **Aspect Ratio:** Compose `AspectRatio` in `SeedAspectRatio`; use `ratio` instead of the inherited `aspectRatio` getter, and Flutter's `AspectRatio` directly where that type is required.
- **Colors:** Require `neutralSolidMuted` and `neutralSolidMutedPressed` in direct `SeedBgColors` constructor calls.
- **Date Picker:** Add `SeedDatePickerLayout.twoWeeks`; add a `twoWeeks` case to exhaustive switches.
- **Input Button:** Add `SeedInputButtonSize.large`; add a `large` case to exhaustive switches. `small` stays a distinct deprecated value with `medium`'s 40px dimensions.
- **List:** Type row `showDivider` as `bool?` on `SeedListItem`, `SeedListLinkItem`, `SeedCheckListItem`, `SeedRadioListItem`, and `SeedSwitchListItem`; null inherits `SeedList.showDividers`, or false for standalone rows. Handle null when reading it, using the parent list setting where applicable.
- **Quantity Picker:** Read the nullable initial seed as `picker.defaultValue ?? picker.min` before clamping.
- **Slider:** Make marker alignment nullable; use `SeedSliderMarker.resolveAlign(min, max)` for the effective value. Omitted alignment resolves to start at the minimum, end at the maximum, and center otherwise.
- **Widget types:** Change `SeedToggleButton` (`StatelessWidget` → `StatefulWidget`) and `SeedResponsivePair` (`StatelessWidget` → `MultiChildRenderObjectWidget`); use `Widget` for variables and return types that only hold or return them.

#### Defaults and behavior

- **Attachments:** Default `SeedAttachmentInput.maxCount` to one instead of ten; pass `maxCount: 10` to keep the old limit.
- **Attachments:** Hide move accessibility actions on items that cannot move (disabled or read-only).
- **Attachments:** Show a keyboard-reordered item at its provisional position and announce start, cancel, and drop.
- **Attachments:** Stop using a Material `ReorderableListView` for the list; update tests that locate it by that type.
- **Attachments:** In RTL with a trigger, place the start padding before the trigger.
- **Button:** Apply `SeedButton.textColor` to ghost buttons with `enabled: true`, and `fontWeight` to ghost buttons.
- **Checkbox / Radio / Switch:** Use the official visual sizes with a 44px touch target for standalone controls, and the official minimum heights for labeled rows.
- **Checkbox / Radio / Switch:** Toggle these controls and their check, radio, and switch list rows with Space, not Enter.
- **Colors:** Use `gray-alpha-200/300` for `bg.neutralWeakAlpha` and its pressed color, and translucent `gray-alpha-400` for `stroke.neutralWeak`, per SEED 3.3.0.
- **Colors:** Move outlines of `neutralOutline` and `brandOutline` buttons, the neutral outline Badge, outline Chips, ReactionButton, and the disabled square Checkbox from `stroke.neutralMuted` to `stroke.neutralWeak`; update tests that compare these colors as opaque values.
- **Date Picker:** Stop emitting `onValueChange` when the current date is reselected.
- **Date Picker:** Fade new rows in with a 20px slide when the visible range changes in non-continuous layouts; reduced motion keeps only the fade.
- **Date Picker:** Use the narrowest range allowed when several of `firstDate`, `lastDate`, `monthRange`, and `yearRange` are set, instead of letting one take precedence.
- **Date Picker:** Apply `constraints` to date removal in multiple mode; `seedMaxSelectionCount` always allows a removal.
- **Date Picker / Time Picker:** Follow the app locale when `locale` is omitted, falling back to English (`en_US`) without a supported locale; pass `locale: const Locale('ko', 'KR')` to keep Korean formatting in apps using another language. The public `locale` properties are nullable.
- **Float:** Default `SeedFloat.offset` to zero instead of 16px on all sides; pass the old value to keep the layout.
- **Footer:** Supply `SeedFooter.copyright` explicitly to show the previous copyright text.
- **Forms:** Stop registering uncontrolled `SeedRadioGroup` and `SeedQuantityPicker` with the enclosing form; wrap them in `SeedFormField` when the form should own validation, saving, or resetting.
- **Grid:** Use sparse auto-placement, and a single column for row flow when only `rows` is set; specify columns or explicit `row` and `column` positions where layouts depended on the old placement.
- **Help Bubble:** Close `SeedHelpBubbleTrigger` when focus leaves its content; set `closeOnInteractOutside: false` to keep it open.
- **Input Button:** Shrink `SeedInputButtonSize.medium` to 40px; use `large` for the previous 52px `medium`. The default stays 52px under `large`.
- **List:** Hide dividers by default; set `showDividers: true` on the list or `showDivider: true` on a row to keep them.
- **Material Snackbar:** Report `SnackBarClosedReason.action` instead of `hide` from `showSeedSnackbar` when the action is selected; update `ScaffoldFeatureController.closed` consumers that branch on the old reason.
- **Material Snackbar:** Persist snackbars with both an action label and callback by default; pass `persist: false` to keep the timeout.
- **Menu:** Request dismissal and move focus beyond the menu on Tab; Shift+Tab can return to the trigger while leaving the menu open. Account for these focus transitions in keyboard handlers and tests.
- **Quantity Picker:** Start an omitted quantity at `min`; pass `defaultValue: 1` for the previous initial seed, subject to the picker's bounds.
- **Responsive:** Move `SeedResponsive.largeBreakpoint` from 1024 to 1280; pass the old value to keep the layout.
- **Select:** Use an anchored overlay with an 8px menu gap for the default popup; set `menuOffset: Offset.zero` for a zero gap. A non-default `menuAlignment` still uses `MenuAnchor`; update widget tests that find the default popup by its `MenuAnchor` implementation.
- **Select:** Show `SeedSelect(multiple: true)` values as labels joined by `, `, like React's `SelectValue`, instead of removable chips; use `formatValue` to change the text or `valueBuilder` for chips or other custom content.
- **Side Navigation:** Make the collapsed flyout a disclosure built on `SeedNavigationMenu`: hover opens after 200ms and closes after 100ms, hover and mouse clicks keep focus in place, and sub-items without `onTap` stay enabled.
- **Side Navigation:** Stop highlighting the selected sub-item's background in the flyout.
- **Side Panel:** Report swiping a `SeedSidePanel` closed as `SeedOverlayDismissReason.drag` instead of `outside`; update handlers that branch on the old reason.
- **Slider:** Show fractional values in full in the default label instead of rounding to one decimal place (0.25 no longer shows as 0.3); use `valueFormatter` for a fixed format.
- **Snackbar:** Exit the active entry before the next one enters.
- **Snackbar:** Default `SeedSnackbarController.show`'s `removeDelay` to 200ms and call the active entry's `onClose` after removal; move removal-dependent logic into that callback.
- **Tabs:** Default `SeedTabs.fill` to true; pass `fill: false` for intrinsic tab widths.
- **Tabs:** Scroll a selected tab within 16px of a scroll edge to leave 16px beside it; exclude the 8px gap from the ChipTabs reveal box.
- **Text Field:** Include server errors and grapheme-limit violations in `FormState.validate()`; clear a server error once the form can be submitted again.
- **Text Input / Text Field:** Set `clearable: true` on `SeedTextInput` or `SeedTextField` to keep the clear button.
- **Time Picker:** Round minute ties up; 10:05 with a ten-minute step becomes 10:10.
- **Top Navigation:** Center adaptive `SeedTopNavigation` titles on iOS only and use a chevron for the default back action; set `centerTitle` or provide `leading` for the earlier presentation.
- **Top Navigation:** Infer Drawer and EndDrawer actions; use explicit `leading` and `actions` to control the buttons, or `automaticallyImplyLeading: false` to disable inference.
- **Top Navigation:** String titles and subtitles still clamp the ambient text scale to 1.0–1.2; pass `titleTextScaler` for another scaler.
- **Top Navigation:** Scale text button labels with the system text scale between 1.0 and 1.2, and hug the label instead of filling a loosely constrained slot.

### Added and deprecated APIs

- **Accordion:** Add `titleWidget`, `descriptionWidget`, and `suffixIcon` to `SeedAccordionItem`.
- **Aspect Ratio:** Make `SeedAspectRatio.ratio` optional, defaulting to 4/3.
- **Attachments:** Add `SeedAttachmentInput.scrollPadding` (default `EdgeInsets.zero`) for scroll content in regular and reorderable lists.
- **Bottom Sheet:** Add `onClosePressed`, constraint overrides, and `dragDismissible` on `showSeedBottomSheet`.
- **Breakpoints:** Add `SeedBreakpoint` (the official `base`, `sm`, `md`, `lg`, and `xl`, with `SeedBreakpoint.of(context)` for the viewport) and `SeedResponsiveValue<T>` for per-breakpoint values.
- **Buttons:** Add `disableOnLoading` to ContextualFloatingButton, ReactionButton, and ToggleButton.
- **Callout:** Add `showCloseButton`.
- **Checkbox:** Add `SeedCheckboxGroup`, which stacks checkboxes with the official 4px gap.
- **Checkbox / Radio / Switch:** Add `invalid` and `required`.
- **Collapsible:** Add `SeedCollapsible`, `SeedCollapsibleTrigger`, and `SeedCollapsibleContent`, the official headless Collapsible, with `SeedCollapsible.of` for the open state.
- **Colors:** Add light and dark `SeedPalette.grayAlpha100Light`–`grayAlpha1000Dark` colors and `SeedColorScheme.banner` (`SeedBannerColors`).
- **Consistent Width:** Add `SeedConsistentWidth`.
- **Date Picker:** Add `SeedDatePickerLayout.twoWeeks`, which shows two weeks and moves by two weeks.
- **Date Picker:** Add `wheelBuilder`, with `SeedDatePickerWheelRenderProps` and `SeedDatePickerWheelColumn`, to replace the year/month wheel.
- **Dialog / Sheets:** Accept route builders and Navigator, route, and focus options in dialog and sheet helpers.
- **Docs:** Add English and Korean migration guides.
- **FAB:** Add optional Hero tags and tooltips to `SeedFloatingActionButton`.
- **Field / Text Input:** Add `description` to Field and `placeholder` to TextInput; keep `helperText` and `hintText` as compatibility inputs.
- **Field Button:** Add `showValueChips` to `SeedFieldButton` to choose chips or plain text.
- **Field Button:** Add `SeedFieldButton.indicator`.
- **Fieldset:** Add `required`, `labelBold`, `errorMessage`, and `errorIcon` to `SeedFieldset`.
- **Footer:** Add `SeedFooterLink.uri` for link semantics.
- **Form Field:** Add `forceErrorText` and `restorationId` to `SeedFormField`.
- **Grid:** Add CSS-style `colSpan`, one-based start/end lines, and full-span placement via `SeedGridItem.full`.
- **Image Frame:** Add `SeedImageFrameIndicator` and `SeedImageFrameIcon` for corner slots and floaters.
- **Input Button:** Add `showDefaultSuffix` and `contentScale` to `SeedInputButton`.
- **Invalid state:** Add `invalid` to Field, TextInput, InputButton, Select, and QuantityPicker; deprecate the corresponding `isInvalid`, `hasError`, and `isError` inputs.
- **Labels and indicators:** Add `labelWeight` to TextField, FieldButton, Select, Slider, RadioGroup, and attachment fields.
- **Labels and indicators:** Add `indicatorText` to Field; `indicator` to TextField, attachment fields, and Slider; and `showRequiredIndicator` to Field, TextField, FieldButton, RadioGroup, and Slider.
- **Layout:** Add `SeedLayoutContent` with density presets.
- **Loading Indicator:** Add `SeedLoadingIndicator`.
- **Localization:** Add `SeedLocalizations` for locale-aware, overridable labels keyed by `SeedLabel`; omitted labels follow the locale and explicit strings take precedence.
- **Material bridge:** Add opt-in `preserveComponentThemes` (default false); when enabled, supplied Material component theme fields take precedence and SEED fills the rest.
- **Middle Truncate:** Add `SeedMiddleTruncate`, which shortens text in the middle and keeps its last `end` characters; attachment file names now use it.
- **Modals:** Add `SeedModalScope`, which tells modal content how it is presented, including `shouldUseBottomSheet` for responsive dialogs and side panels.
- **Navigation Menu:** Add `SeedNavigationMenu` with its root, trigger, content, group, and item widgets.
- **Overlays:** Add ordered `flipFallbackSides` to HelpBubbleTrigger and AnchoredOverlay, and `fitMinExtent` and `tabExitsContent` to AnchoredOverlay.
- **Pagination:** Add `SeedPagination.visibleItemCount` for 7 or 9 controls including arrows; `maxVisibleSlots` still counts page slots.
- **Pressable:** Add control focus rings and options to customize focus and link semantics on `SeedPressable`.
- **Pressable:** Add `activateOnEnter: false` to activate on Space only, and `unfocusOnDisabledTap`, which blurs the focused input on a pointer tap on a disabled choice row, as native controls do.
- **Pressable:** Add `semanticsReadOnly` and `semanticsValidationResult` to `SeedPressable`, and `focusVisible` and `surfaceSize` to `SeedInteractionState`.
- **Radio:** Add `rowBuilder` to Radio and `tone` to RadioListItem.
- **Radio:** Add `invalid` and `errorMessage` to `SeedRadioGroup`; an invalid group marks its options invalid and shows the message in place of the description.
- **Safe area:** Add `extendSafeAreaX` to Tabs, TabBar, TabsView, ChipTabsView, PageBanner, AttachmentInput, and the attachment fields.
- **Scroll Area:** Add `focusableWhenScrollable`.
- **Scroll Fog:** Add `SeedScrollFogMask`.
- **Search Input:** Add `SeedSearchInput` with `onSubmit`, `blurOnSubmit`, and a clear button that keeps the input focused.
- **Segmented Text Input:** Add `SeedSegmentedTextInput` with segments, separators, masked dots, and paste and autofill distribution, plus `SeedSegmentedTextInputFormField`.
- **Select:** Add `SeedSelectFormField` for validation, save, reset, and restoration.
- **Select:** Add `SeedSelect.formatSelectedValue`, also on `SeedSelectFormField`, with `SeedSelectSelectedItem` for formatting selected values whose options have not loaded yet.
- **Select:** Add `textValue` and `typeaheadLabel` to `SeedSelectItem` for separate display and search text.
- **SelectBox:** Add `SeedSelectBoxGroup.radio` for an explicit radio group.
- **Semantics:** Add `semanticsLabel` to SegmentedControl, Select, InputButton, SelectBoxGroup, ChipRadioGroup, Menu, and Popover.
- **Side Navigation:** Add `SeedSideNavigationProvider`, `SeedSideNavigationContextValue`, and `SeedSideNavigationInset`, so content beside the navigation can read and toggle its collapsed state.
- **Side Panel:** Add `closeOnInteractOutside` and `closeOnEscape` to `SeedSidePanelTrigger`.
- **Slider:** Add `jumpMultiplier`.
- **Snackbar:** Add `showSeedSnackbar.onVisible`, and `onDiscard` on `SeedSnackbarController.show` for entries removed before they are shown.
- **Table Pagination:** Add `SeedTablePagination.rangeLabel`.
- **Tabs:** Add `SeedTabBar` for Material `TabController` and `TabBarView` integration.
- **Text Field:** Add `hideCharacterCount`.
- **Text Input:** Add autofill, IME, editing, and restoration options.
- **Toggle Button:** Add `pressed`, `defaultPressed`, and `onPressedChange`; keep `selected` and `onSelectedChanged` as deprecated aliases.
- **Tokens:** Align tokens and the official reference fixture with SEED React/CSS 3.3.0.
- **Top Navigation:** Add `SeedTopNavigation.slot` for custom content filling the space between leading and trailing actions; use it separately from title and subtitle inputs.
- **Top Navigation:** Add `bottom`, `titleTextScaler`, and `automaticallyImplyLeading`.
- **Typography:** Add `SeedStaticTextScope` with the 42 `tNStatic{Regular,Medium,Bold}` text styles and the `t1Static`–`t14Static` tokens in `SeedFontSize` and `SeedLineHeight`.
- **Variants:** Add `variant` to ContextualFloatingButton, Checkbox, and Checkmark; keep the existing `tone` and `shape` inputs as deprecated aliases.

### Fixes and accessibility

- **Accordion:** Release focus from content once it finishes collapsing, so Enter or Space no longer activates a hidden control.
- **Accordion:** Keep item focus by value.
- **Attachments:** Keep the dropzone drag hint's `fg.neutralSubtle` color when the field is full or disabled; dim only the select button.
- **Attachments:** Let dropzones span the field width; clear stale progress in `SeedAttachmentController.updateStatus`.
- **Attachments:** Support keyboard reordering in reorderable lists: Space picks up the focused item, arrow keys move it, Space drops it, and Escape cancels.
- **Attachments:** Keep keyboard reorder within both insets; cancel a provisional move when its target disappears.
- **Attachments:** Keep focus on the moving item when rapid arrow presses scroll its new position into view, so Space can still confirm the new order.
- **Attachments:** Align remove buttons to the overhanging position, and route taps on the overhanging part to the button.
- **Attachments:** Show the retry action only when `onRetry` is supplied.
- **Badge:** Align text-attached badges to the top of the line.
- **Bottom Sheet / Menu Sheet:** Match drag dismissal to React's thresholds of 25% of height or 0.4px/ms, fading the backdrop during drag.
- **Bottom Sheet:** Keep snapping footers next to their content.
- **Button:** Use horizontal layout bleed for `SeedButton(bleed: true)`.
- **Choice controls:** Keep choice marks on the first line of wrapped labels, and stretched Switch labels at the trailing edge.
- **Chip:** Keep icon spacing.
- **Chip / Tag:** Keep chip removal and tag actions accessible.
- **Date Picker:** Reach the first and last available weeks in the two-week calendar; end the previous transition when the layout or week start changes.
- **Date Picker:** Move the two-month calendar one month at a time.
- **Dialog:** Accept keyboard focus and arrow-key scrolling in scrolling bodies; remove the extra root tab stop.
- **Dialog / Alert Dialog:** Remove shadows.
- **Examples:** Keep the Home grid valid during Android's zero-size first frame.
- **Field:** Align the required mark and show the default error icon.
- **Field Button:** Omit the default chevron.
- **Field Button / Select:** Expose the field name and shown value.
- **Fieldset:** Apply disabled state to buttons, text inputs, and input buttons, including through nested Fieldsets.
- **Fieldset:** Place descriptions below the controls and use medium field label typography.
- **Flex:** Apply alignment to wrapping `SeedFlex`.
- **Focus rings:** Draw around the control mark, inset on List rows and Accordion triggers, and with the full pill radius on `SeedToggleButton`.
- **Footer:** Move the country selector into navigation.
- **Grid:** Honor end-only lines and full-span precedence.
- **Grid:** Keep an item with only `row` on that row in a column-flow Grid with `rows`.
- **Help Bubble:** Name content as a dialog whose bounds exclude the arrow; semantics tests can find the dialog node inside `SeedHelpBubble`.
- **List:** Expose list links as a single link node.
- **List Header / Popover:** Align close-button geometry.
- **Localization:** Localize optional Field indicators and Chip delete announcements, and use singular wording for one unread notification.
- **Localization:** Preserve enclosing label overrides inside nested scopes and dialogs.
- **Localization:** Update localized defaults, including the sidebar toggle and attachment remove and retry actions.
- **Material Snackbar:** Prevent duplicate action callbacks.
- **Menu:** Open with arrow keys; ArrowUp on a closed trigger opens on the last enabled item.
- **Menu:** Restore nested-menu keyboard focus and Escape handling after an Accordion collapses.
- **Menu:** Keep the requested side when contents fit; size long menus before trying a fallback side.
- **Menu:** Close on Tab and move focus to the stop after the trigger, including triggers that skip traversal or sit last in their own `FocusScope`.
- **Menu / Select:** After pointer or semantic activation, aim the first arrow key at the appropriate enabled Menu item, or at the selected Select option when available.
- **Menu / Popover / Select:** Expose Menu and Popover trigger expanded state, and Menu and Select option groups as labelled groups.
- **Menu Sheet:** Keep items at least 52px tall.
- **Menu Sheet:** Keep an accessible close action when the visible cancel button is hidden.
- **Navigation Menu:** Preserve unrelated focus when a controlled menu reopens.
- **Navigation Menu / Side Navigation:** Reopen a navigation menu or collapsed sidebar flyout on hover after it closed on leave; close a flyout on focus loss only when keyboard-opened, as in React.
- **Overlays:** Close the topmost Select, Menu, or Popover on outside taps in dismissible routes, and track moving anchors.
- **Page Banner:** Align icons to the first line and keep the 40px minimum height with an action.
- **Pagination / Table Pagination:** Render without a Material ancestor.
- **Popover:** Stop closing at once when opened while focus is elsewhere.
- **Popover:** Size plain-text content within `minWidth` and `maxWidth`, reserving the scroll fade only on overflow; keep the max-width layout for custom content and readable action labels in narrow footers.
- **Popover:** Take the accessible name and description from the rendered title and description, so `titleText` and `descriptionText` no longer apply when custom `title` or `description` widgets replace them; `semanticsLabel` still takes precedence.
- **Pressable:** Scale press feedback by the measured surface and apply it without animation under reduced motion.
- **Pull to refresh:** Preserve text selection in content.
- **Pull to refresh:** Accept pulls on content that fits the viewport when using an explicit `ScrollController` or `primary: false`.
- **Quantity Picker:** Reconcile bounds.
- **Radio:** Expose radio groups as named radio groups.
- **Radio:** Stop reporting a change when an already selected Radio is activated.
- **Radio List Item:** Use a large mark inside the row.
- **Reaction Button:** Use the label as the accessible name.
- **Responsive modals:** Keep body state when the layout crosses the 768px breakpoint. In bottom-sheet form, keep the dialog's maximum height and body padding, and the side panel's custom title and description widgets, close button, and body padding.
- **Responsive Pair:** Give `SeedResponsivePair` children equal shares; stack them in reverse order at full width on overflow.
- **Safe area:** Update horizontal insets when the view changes inside a `SafeArea`.
- **Safe area:** Stop remounting content when `extendSafeAreaX` toggles at runtime: TabsView keeps the selected carousel page and page state, Tabs and ChipTabsView keep the strip's scroll offset, AttachmentInput keeps its scroll offset, keyboard focus, and provisional keyboard reorder, and PageBanner keeps its content state.
- **Scroll Area:** Update `focusableWhenScrollable` as content starts or stops overflowing, independent of `fogOnlyWhenScrollable`.
- **Scroll Fog:** Correct `SeedScrollFog` opacity and mask direction.
- **Search Input:** Preserve focus requested by a submit callback.
- **Segmented Text Input:** Keep the caret at the end of masked input when it receives keyboard focus; use the available segment width for fill placeholders.
- **Segmented Text Input:** Stop segments from drawing the app theme's Material input border inside the group frame.
- **Select:** Align option styling and transitions, add typeahead and looping arrow navigation, apply `formatValue` to single selection, and clear stale pointer state.
- **Select:** Scale Select content on press while the InputButton root stays in place.
- **SelectBox:** Show a dash for an indeterminate check mark.
- **Semantics:** Avoid unnamed button nodes for Field label taps, sheet handles, and attachment dropzones.
- **Semantics:** Expose `SeedSegment.invalid` to accessibility.
- **Sheets:** Forward close and handle callbacks through sheet wrappers.
- **Side Navigation:** Reset reinserted items to their initial state; wait for the width transition before enabling flyouts and tooltips.
- **Side Navigation:** Preserve collapsed state and current-item indication.
- **Side Navigation:** Give the flyout a 240px minimum width and a visible group heading without a tooltip over it.
- **Side Navigation:** Truncate item labels to one line, inset press surfaces, and remove header and footer dividers.
- **Side Navigation:** Apply `defaultOpen` only to newly added items; show sub-item badges in the collapsed flyout.
- **Slider:** Align to a 26px track layout with a 20px thumb, one bounded value bubble, and no Material dots on stepped ranges.
- **Slider:** Preserve step precision, step through `allowedValues`, and support Home, End, PageUp, PageDown, and Shift+Arrow.
- **Slider:** Stop enforcing `minStepsBetweenThumbs` on range Sliders with `allowedValues`, as in React; move continuous Slider keyboard and accessibility increments by `step`.
- **Slider:** Expose one slider node for a labelled single Slider.
- **Snackbar:** Avoid floating controls after a controller swap.
- **Snackbar:** Replace every waiting entry on an `immediate` `SeedSnackbarController.show`, as in React, reporting each through `onClose` and `onDiscard`.
- **Snackbar:** Track the `SeedSnackbarAvoidOverlap` region's position as well as its size; move the snackbar up only when a registered region overlaps it.
- **Strokes:** Keep strokes from shifting input, quantity, reaction, outline Chip, and SelectBox content.
- **Switch / Tabs / Wheel Picker:** Preserve selection across label and item changes.
- **Table Pagination:** Use 40px value-sized selectors and compact range labels such as `51-75`.
- **Tabs:** Keep the page scroll position on arrow-key tab navigation.
- **Tabs:** Reveal the keyboard-focused tab even when a controlled parent rejects or delays the selection.
- **Tabs View:** Keep lazily mounted pages and measured heights with their tab values when tabs are reordered, inserted, or removed.
- **Text Input:** Restore owned text controllers through Flutter's editing lifecycle.
- **Themes:** Retain partial overrides.
- **Time Picker:** Size columns to their widest value, like React's `max-content`, instead of fixed shares.
- **Tooltip:** Open without delay in a `SeedTooltipDelayGroup` while another tooltip of the group is open; a tooltip's own `openDelay` or `closeDelay` overrides the group's.
- **Top Navigation:** Place text buttons in `SeedTopNavigation.slot` like icon buttons, their 10px padding overhanging the bar edge and the slot so labels line up with the 16px bar padding; keep the 16px gap between a leading button and the slot in the Android layout.
- **Visual feedback:** Align the remaining feedback with React, including Accordion hover surfaces, flat WheelPicker styling, and ink-free DatePicker, Menu, Footer, and SideNavigation controls.
- **Wheel Picker:** Fix mixed fixed/flexible columns; add mouse drag and PageUp/PageDown support; use the corrected scroll-fog mask.
- **Wheel Picker:** Return to the committed selection when a column becomes disabled or read-only or its options change; move without animation under reduced motion.

### Example and web

- **App Bar:** Add the text button demo.
- **Search Bar:** Add a home entry; dismiss the keyboard on a body tap, and show the close action in place when opened as the root screen.
- **Safe area:** Add live inset values, swipeable and content-width tabs, a magic banner, attachment lists, a dropzone, and Image Frame overlays to the demo.
- **Attachments:** Show keyboard reorder instructions in the demos.
- **Demos:** Add SearchInput, segmented number fields, navigation menus, the two-week calendar, consistent text width, loading, static typography, horizontal safe areas, and Accordion and Fieldset slots.
- **Showcase:** Present card number, resident number, and Search Bar as showcase compositions.
- **Stackflow:** Align the showcase's platform transitions, responsive layouts, browser font scaling, and component demos.
- **Stackflow:** Preserve per-Activity Step history while isolating fresh Activities, retain parent screens for pushed modals, and keep sheet draft controllers alive through dismissal.
- **Textarea:** Add the autoresize and scroll demo at `/e2e/textarea-autoresize-scroll`.
- **Web:** Use path URLs and a GitHub Pages `404.html` app shell so showcase routes open directly and survive page refreshes.

## 1.0.0

Based on SEED Design React/CSS 3.0.1.

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
