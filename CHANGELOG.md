## Unreleased

- Define the 1.0 public API contract in `PUBLIC_API_CONTRACT.md`.
- Add canonical default-value names for text, date/time, select and attachment
  inputs while retaining their initial-value aliases. Defaults seed local state
  once and no longer overwrite calendar/time edits on rebuild.
- Honor controlled empty selections in calendars, selects, card groups, segmented
  controls and form fields; keep parent-owned values through rejected edits/reset.
- **Breaking:** standardize Select and Tooltip `onOpenChanged` callbacks to
  `(open, reason)`. Select provides `onOpenStateChanged` for bool-only observers;
  its `onOpenChange` alias is deprecated.
- **Breaking:** reject simultaneous text/attachment controller and value/seed
  inputs. Keep externally controlled text synchronized with form validation and
  reset, and give explicit tab indices precedence over controllers.
- Preserve controlled Select visibility when dismissal requests are rejected.

- Use fill layout and a single notification in the first Tabs example; keep
  enlarged tab labels within their targets and allow scrolling when needed.
- Apply the first measured carousel height immediately, retain the previous height
  while measuring another page, and preserve later tab-height transitions.

- Fix React/Flutter A–D follow-up regressions: clip avatar fallbacks, resize
  attachment previews for enlarged text, and retain only filename extensions.
- Restore responsive alert action layout, keep dialog exit scale at 1, reserve
  headerless close-button space, and expose independent alert/sheet Escape policies.
- Preserve snap-sheet indices through animation and synchronize controllers after
  user gestures; correct accordion heading names and composed Field label focus.
- Keep closeable Help Bubbles at their natural content height with a full 38px
  close target, and align tooltip placement and motion with Help Bubble triggers.
- Separate reaction-icon layout from its touch target and switch-row graphics
  from standalone hit boxes; restore radio-row feedback and pointer selection.

- Review worker D findings: align Image Frame defaults and overlay insets, add
  nine-position floaters, accessible heart toggles and image load/error callbacks.
- Fix Input Button clear availability and add responsive Input Button/Menu sizes.
- Keep list content layout stable during pressed feedback, expose list semantics
  and add a single-target switch row; hide decorative manner-badge emoji from speech.
- Correct small Menu tokens, keyboard typeahead/wrapping, menu roles and selection
  of callback-free items; expose Menu Sheet selection/dismissal/alignment options.
- Add Notification Badge size/label and icon/text positioning; use the shared
  positioner in bottom navigation and tabs while retaining count convenience rules.

- Review React/Flutter worker A findings: normalize single accordion selection,
  add heading semantics and content fading, and keep separated pressed cards full width.
- Align button/badge default variants; add accessible badge actions and fixed icon slots.
- Make alert backdrop dismissal opt-in, responsively arrange actions, and scroll overflowing alert content.
- Use official avatar badge geometry and mask paths, hide badges at 20px, and keep
  placeholders visible until the first image frame.
- Allow pruning attachments when adding is disabled; preserve filename extensions
  and draw dashed dropzone borders outside the dragging state.
- Match React defaults for Checkbox/Checkmark (brand), Chip (solid), and Contextual
  Floating Button (solid); require a label for icon-only floating buttons.
- Give Callout controlled/default visibility and self-dismiss behavior, underline
  links by default, omit automatic prefix icons unless requested, and correct
  multiline alignment, magic icon colors, and the full 40px close target.
- Start snap sheets at the first caller-supplied point, preserve indices for
  reversed/duplicate points, cycle points by tapping the handle, and honor
  non-dismissible snapping sheets.
- Render the twelve official Content Placeholder paths with square clipped corners
  and constrained asset sizing instead of substitute Material icons.

- Remove excess spacing and fade from short dialog bodies; reserve the official fade band
  only when the body actually overflows.
- Fix carousel tab animations selecting intermediate pages, including rapid retargeting
  and user drags that interrupt transitions.
- Match the official compact pagination window so earlier neighboring pages remain reachable.
- Keep extended FABs at their content width and preserve snap-sheet resizing across minimum heights.
- Match official manner-temperature examples and attachment progress/retry layouts; tidy catalog
  headings, separate SeedPressable, remove the duplicate xsmall toggle example and update the footer.
- Add React-equivalent calendar modes and constraints, multiple selection, range
  sliders, structured fields, grapheme callbacks, accordion groups and tab carousels.
- Add controlled overlay triggers, placement/focus/dismiss handling, tooltip delays,
  sheet snap points, responsive panels, Snackbar strategies/pause and UI entry controllers.
- Add selection/layout variants, chip radio groups, FAB transitions, pull-to-refresh,
  and interactive examples integrated into the existing catalog tabs.
- Keep attachment handling UI-only: no native file picker, OS drop receiver,
  file validation or upload transport is included.
- Fix continuous calendar freezes by anchoring lazy month lists at the target month
  instead of laying out the preceding century during an initial scroll jump.
- Add widget and iOS/Android integration coverage for repeated calendar mode changes,
  scrolling, selection, far-year navigation and variable-height date cells.

- Restore Date Picker month/year header selection with year and month wheels,
  bounded navigation, looping months, and Escape/focus handling.
- Preserve Snackbar messages in FIFO order and forward prefix icons from the helper.
- Fix Side Navigation parent actions and active-child expansion; make collapsed
  submenus accessible by click and keyboard.
- Honor List divider suppression, selected disabled segment colors, Large chip
  tab sizing, and desktop Side Panel widths.
- Commit wheel selections after scrolling settles, support item taps and disabled
  pickers, and apply Small sizing and custom row heights consistently.
- Fall back to identity placeholders on Avatar image errors; display file upload
  progress and retry actions, and block retries when attachments are disabled.
- Add disabled Bottom Navigation items and screen reader notification values.
- Prevent narrow Footer layouts and enlarged tag text from overflowing.

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
