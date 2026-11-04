import 'dart:async';

import '../../localization/seed_localizations.dart';

import 'seed_field.dart';
import '../overlay/seed_anchored_overlay.dart';

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

import '../../foundations/feedback/seed_scale_feedback.dart';
import '../../foundations/motion/seed_motion.dart';

import 'package:material_ui/material_ui.dart';

import '../../foundations/colors/seed_color_scheme.dart';
import '../../foundations/dimensions/seed_dimension.dart';
import '../../foundations/radius/seed_radius.dart';
import '../../foundations/typography/seed_typography.dart';
import '../../theme/seed_theme.dart';
import '../layout/seed_divider.dart';
import 'seed_input_button.dart';

/// An individual option item in a [SeedSelect].
class SeedSelectItem<T> {
  /// Creates an option with a machine [value], visible [label], and optional
  /// [description], [prefixIcon], and custom [labelWidget].
  ///
  /// [enabled] defaults to true.
  const SeedSelectItem({
    required this.value,
    required this.label,
    this.description,
    this.prefixIcon,
    this.enabled = true,
    this.labelWidget,
  });

  /// Flutter-specific replacement widget for the option's label content.
  final Widget? labelWidget;

  /// Value reported by a selection callback.
  final T value;

  /// Option text shown in the menu and searched by keyboard typeahead.
  ///
  /// Selection identity is determined by [value], not by this label.
  final String label;

  /// Secondary descriptive text under the label.
  final String? description;

  /// Leading icon displayed before the label.
  final Widget? prefixIcon;

  /// Whether this option can be selected; defaults to true.
  final bool enabled;
}

/// A group of items in a [SeedSelect].
class SeedSelectGroup<T> {
  /// Groups [items] under an optional visible [label].
  const SeedSelectGroup({this.label, required this.items});

  /// Optional group heading.
  final String? label;

  /// Options in this group, shown in their supplied order.
  final List<SeedSelectItem<T>> items;
}

/// A SEED Design Select component for form inputs.
///
/// Combines an input-styled trigger button with an anchored popup menu of options
/// organized into items and groups.
///
/// A non-null list [value] controls selection, including an empty list. [controlled] also treats null as
/// an authoritative empty selection. Defaults seed local state once. [open] is
/// independent of selection ownership; [onOpenChanged] proposes visibility with
/// a reason, without overriding a supplied [open].
class SeedSelect<T> extends StatefulWidget {
  /// Creates a single- or multi-select from [groups].
  ///
  /// React's `value`, `defaultValue`, and `onValueChange` use [List]
  /// for both modes; [multiple] enables multi-selection. When [value] is null
  /// and [controlled] is false, [defaultValue] initializes local selection.
  /// [values], [initialValues], and [defaultValues] are legacy set-valued
  /// alternatives; supplying them alongside the list equivalents is invalid.
  ///
  /// [open] controls popup visibility independently of the selected values.
  /// [onOpenChange] receives the proposed state and dismissal reason;
  /// [onOpenChanged] is its deprecated alias. With the default [menuAlignment]
  /// the anchored overlay positions using [side], [align], [flip], [shift],
  /// and [menuOffset]; a custom alignment retains the compatibility popup.
  /// [semanticsLabel] names the trigger when a visible [label] is absent.
  const SeedSelect({
    super.key,
    required this.groups,
    this.value,
    String? placeholder,
    this.prefixIcon,
    this.onChanged,
    this.size = SeedInputButtonSize.large,
    this.enabled = true,
    bool? invalid,
    @Deprecated('Use invalid instead.') bool? isError,
    this.readOnly = false,
    this.controlled = false,
    this.matchWidth = true,
    this.menuAlignment = AlignmentDirectional.bottomStart,
    this.menuOffset = const Offset(0, SeedDimension.x2),
    this.side,
    this.align = SeedOverlayAlign.start,
    this.flip = true,
    this.shift = true,
    this.multiple = false,
    @Deprecated('Use value instead.') this.values,
    @Deprecated('Use defaultValue instead.') Set<T>? defaultValues,
    @Deprecated('Use defaultValue instead.') Set<T>? initialValues,
    this.defaultValue,
    this.onValueChange,
    this.onValuesChanged,
    this.open,
    this.defaultOpen = false,
    @Deprecated('Use onOpenChange instead.')
    SeedOverlayOpenChanged? onOpenChanged,
    SeedOverlayOpenChanged? onOpenChange,
    this.onOpenStateChanged,
    this.onValueChanged,
    this.maxMenuHeight = 480,
    this.valueBuilder,
    this.formatValue,
    this.label,
    this.labelWeight = SeedFieldLabelWeight.medium,
    this.description,
    this.errorMessage,
    this.showClear = false,
    this.onClear,
    this.semanticsLabel,
    // Preserve the public named parameter and String getter.
    // ignore: prefer_initializing_formals
  }) : _placeholder = placeholder,
       isError = invalid ?? isError ?? false,
       assert(invalid == null || isError == null),
       onOpenChanged = onOpenChanged ?? onOpenChange,
       initialValues = defaultValues ?? initialValues ?? const {},
       assert(onOpenChanged == null || onOpenChange == null),
       assert(defaultValues == null || initialValues == null),
       assert(
         defaultValue == null ||
             (defaultValues == null && initialValues == null),
       ),
       assert(value == null || values == null);

  /// The groups and options available for selection.
  final List<SeedSelectGroup<T>> groups;

  /// Accessible name of the trigger, like the official SelectTrigger
  /// `aria-label`, for a Select without a visible [label].
  final String? semanticsLabel;

  /// Selected option values, matching React for both single and multiple mode.
  /// An empty list is a controlled empty selection.
  final List<T>? value;

  /// Placeholder text when [value] is null.
  final String? _placeholder;
  /// Text shown when no options are selected (default `선택해주세요`).
  String get placeholder => _placeholder ?? '선택해주세요';

  /// Prefix icon for the trigger.
  final Widget? prefixIcon;

  /// Legacy scalar callback, called with an option as it is selected.
  ///
  /// Prefer [onValueChange] to observe the full selected-value list.
  final ValueChanged<T>? onChanged;

  /// The size variant of the select trigger.
  final SeedInputButtonSize size;

  /// Whether the select is enabled.
  final bool enabled;

  /// Whether the select trigger displays an error stroke.
  @Deprecated('Use invalid instead.')
  final bool isError;
  /// Whether the trigger displays invalid/error styling (default false).
  bool get invalid => isError;

  /// Whether users can interact without changing selection (default false).
  final bool readOnly;

  /// [controlled] makes null [value] mean an explicitly empty controlled
  /// selection; [matchWidth] sizes the popup to its trigger (default true).
  final bool controlled, matchWidth;

  /// Compatibility popup alignment; defaults to bottom-start.
  final AlignmentGeometry menuAlignment;

  /// Offset of the popup from its anchor, defaulting to 8 logical pixels down.
  final Offset menuOffset;

  /// Preferred anchored-popup side, when specified.
  final SeedOverlaySide? side;

  /// Alignment of the popup along its chosen [side] (default start).
  final SeedOverlayAlign align;

  /// Whether the popup can flip sides or shift along the viewport to fit.
  final bool flip, shift;

  /// Enables selecting several options (default false).
  final bool multiple;

  /// Deprecated controlled set-valued selection; prefer [value].
  @Deprecated('Use value instead.')
  final Set<T>? values;

  /// Deprecated uncontrolled set seed; prefer [defaultValue].
  @Deprecated('Use defaultValue instead.')
  final Set<T> initialValues;

  /// Legacy set-valued seed; prefer the React-compatible list [defaultValue].
  @Deprecated('Use defaultValue instead.')
  Set<T> get defaultValues => initialValues;
  /// Initial uncontrolled selected values, as in the React Select API.
  final List<T>? defaultValue;

  /// Called with the complete selection whenever a user proposes a change.
  final ValueChanged<List<T>>? onValueChange;

  /// Legacy observer receiving a set of selected values.
  final ValueChanged<Set<T>>? onValuesChanged;

  /// Externally controlled popup visibility, or null for local visibility.
  final bool? open;

  /// Initial uncontrolled popup visibility (default false).
  final bool defaultOpen;

  /// Deprecated callback name for [onOpenChange].
  @Deprecated('Use onOpenChange instead.')
  final SeedOverlayOpenChanged? onOpenChanged;

  /// Optional visibility-only observer, alongside [onOpenChanged].
  final ValueChanged<bool>? onOpenStateChanged;
  /// Reports proposed popup visibility with a [SeedOverlayDismissReason].
  SeedOverlayOpenChanged? get onOpenChange => onOpenChanged;

  /// Legacy scalar observer of selected value, or null when cleared.
  final ValueChanged<T?>? onValueChanged;

  /// Maximum popup height, in logical pixels (default 480).
  final double maxMenuHeight;

  /// Flutter-specific widget builder for the trigger's selected-value display.
  final Widget Function(BuildContext, List<SeedSelectItem<T>>)? valueBuilder;

  /// Formats selected option labels into trigger text.
  final String Function(List<SeedSelectItem<T>>)? formatValue;

  /// Optional field label above the Select.
  final String? label;

  /// The official `labelWeight`.
  final SeedFieldLabelWeight labelWeight;
  /// Supporting description below the field.
  final String? description;

  /// Validation message displayed in the field.
  final String? errorMessage;

  /// Shows a clear-selection control (default false).
  final bool showClear;

  /// Invoked when the clear-selection control is activated.
  final VoidCallback? onClear;

  @override
  State<SeedSelect<T>> createState() => _SeedSelectState<T>();
}

class _SeedSelectState<T> extends State<SeedSelect<T>> {
  final MenuController _menuController = MenuController();
  final SeedOverlayController _anchored = SeedOverlayController();
  final List<FocusNode> _menuItemFocusNodes = [];
  final FocusNode _menuTriggerFocus = FocusNode();
  final FocusNode _readOnlyFocus = FocusNode();
  final FocusNode _readOnlyVisualFocus = FocusNode();
  bool _showReadOnlyFocus = false;
  int? _triggerPointer;
  bool _pointerOpenAwaitingKeyboardHighlight = false;

  /// A custom [SeedSelect.menuAlignment] keeps the legacy MenuAnchor, whose
  /// alignment has no equivalent in the official floating placement.
  bool get _usesMenuAnchor =>
      widget.side == null &&
      widget.menuAlignment != AlignmentDirectional.bottomStart;

  bool get _menuIsOpen => _usesMenuAnchor
      ? _menuController.isOpen
      : widget.open ?? _anchored.isOpen;

  /// The active option while Shift+Tab has moved focus back to the open
  /// Select's trigger; React keeps it highlighted and keeps handling its keys.
  int? _triggerHeldHighlight;

  bool _reportedOpen = false;
  void _emitOpen(bool open, SeedOverlayDismissReason reason) {
    if (!open) _triggerHeldHighlight = null;
    if (_reportedOpen == open && widget.open == null) return;
    _reportedOpen = open;
    widget.onOpenStateChanged?.call(open);
    widget.onOpenChanged?.call(open, reason);
  }

  late Set<T> _values = Set.of(widget.defaultValue ?? widget.defaultValues);
  bool get _selectionControlled =>
      widget.controlled || widget.value != null || widget.values != null;
  Set<T> get _selectedValues {
    final Iterable<T> selected =
        widget.value ?? widget.values ?? (widget.controlled ? <T>[] : _values);
    return (widget.multiple ? selected : selected.take(1)).toSet();
  }

  void _changeValues(Set<T> next) {
    if (!_selectionControlled) setState(() => _values = next);
    widget.onValueChange?.call(List<T>.unmodifiable(next));
    if (widget.multiple) {
      widget.onValuesChanged?.call(Set<T>.unmodifiable(next));
    } else {
      widget.onValueChanged?.call(next.firstOrNull);
      if (next.isNotEmpty) widget.onChanged?.call(next.first);
    }
  }

  SeedSelectItem<T>? _findItem(T value) {
    for (final group in widget.groups) {
      for (final item in group.items) {
        if (item.value == value) return item;
      }
    }
    return null;
  }

  List<SeedSelectItem<T>> get _selectedItems => [
    for (final value in _selectedValues) ?_findItem(value),
  ];

  void _syncMenuItemFocusNodes() {
    final count = widget.groups.fold<int>(
      0,
      (n, group) => n + group.items.length,
    );
    while (_menuItemFocusNodes.length < count) {
      _menuItemFocusNodes.add(
        FocusNode(
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent &&
                _pointerOpenAwaitingKeyboardHighlight) {
              // React's pointer-open Select has no highlighted option yet.
              // Its first Arrow key highlights the selected option (or first
              // enabled option), rather than stepping to the next one.
              // Material MenuAnchor already focuses that same option on open.
              if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
                  event.logicalKey == LogicalKeyboardKey.arrowUp) {
                setState(() => _pointerOpenAwaitingKeyboardHighlight = false);
                return KeyEventResult.handled;
              }
              if (event.logicalKey == LogicalKeyboardKey.enter ||
                  event.logicalKey == LogicalKeyboardKey.space) {
                _pointerOpenAwaitingKeyboardHighlight = false;
                _requestOpen(false);
                return KeyEventResult.handled;
              }
              if (event.logicalKey == LogicalKeyboardKey.home ||
                  event.logicalKey == LogicalKeyboardKey.end) {
                setState(() => _pointerOpenAwaitingKeyboardHighlight = false);
              }
            }
            if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.tab) {
              final shift = HardwareKeyboard.instance.isShiftPressed;
              if (shift && !_usesMenuAnchor) {
                setState(() {
                  _triggerHeldHighlight = _menuItemFocusNodes.indexOf(node);
                  _pointerOpenAwaitingKeyboardHighlight = false;
                });
                (SeedFieldScope.maybeOf(context)?.focusNode ??
                        _menuTriggerFocus)
                    .requestFocus();
                return KeyEventResult.handled;
              }
              _requestOpen(false, reason: SeedOverlayDismissReason.focusOut);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                final trigger =
                    SeedFieldScope.maybeOf(context)?.focusNode ??
                    _menuTriggerFocus;
                trigger.requestFocus();
                if (shift) {
                  FocusScope.of(context).previousFocus();
                } else {
                  FocusScope.of(context).nextFocus();
                }
              });
              return KeyEventResult.handled;
            }
            return _handleTypeahead(event, open: true);
          },
        ),
      );
    }
    while (_menuItemFocusNodes.length > count) {
      _menuItemFocusNodes.removeLast().dispose();
    }
  }

  // floating-ui useTypeahead's default reset delay, used by useSelectHighlight.
  static const _typeaheadResetDelay = Duration(milliseconds: 750);
  String _typeaheadQuery = '';
  Timer? _typeaheadReset;

  /// While open, a match moves the highlight. On a closed single-select trigger
  /// it commits directly without opening, like a native select.
  KeyEventResult _handleTypeahead(KeyEvent event, {required bool open}) {
    if (event is! KeyDownEvent ||
        HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed ||
        HardwareKeyboard.instance.isAltPressed) {
      return KeyEventResult.ignored;
    }
    final character = event.character?.toLowerCase();
    if (character == null || character.isEmpty) return KeyEventResult.ignored;
    // Space belongs to the search only once a search is in progress.
    if (character.trim().isEmpty &&
        (character != ' ' || _typeaheadQuery.isEmpty)) {
      return KeyEventResult.ignored;
    }
    final items = [for (final group in widget.groups) ...group.items];
    if (items.isEmpty) return KeyEventResult.ignored;
    _typeaheadReset?.cancel();
    _typeaheadReset = Timer(_typeaheadResetDelay, () => _typeaheadQuery = '');
    _typeaheadQuery += character;
    // Repeated characters cycle through items with the same initial.
    final query = _typeaheadQuery.split('').every((c) => c == character)
        ? character
        : _typeaheadQuery;
    final current = open
        ? _menuItemFocusNodes.indexWhere((node) => node.hasFocus)
        : items.indexWhere((item) => _selectedValues.contains(item.value));
    for (var step = query.length > 1 ? 0 : 1; step <= items.length; step++) {
      final index = (current + step) % items.length;
      final item = items[index];
      if (!item.enabled || !item.label.toLowerCase().startsWith(query)) {
        continue;
      }
      if (open) {
        setState(() => _pointerOpenAwaitingKeyboardHighlight = false);
        final node = _menuItemFocusNodes[index];
        node.requestFocus();
        _revealOption(node);
      } else if (!_selectedValues.contains(item.value)) {
        _changeValues({item.value});
      }
      break;
    }
    return KeyEventResult.handled;
  }

  void _focusOpenMenu() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_menuIsOpen || widget.readOnly || !widget.enabled) {
        return;
      }
      void focus(FocusNode node) {
        node.requestFocus();
        if (!_usesMenuAnchor) _revealOption(node);
      }

      var index = 0;
      FocusNode? firstEnabled;
      for (final group in widget.groups) {
        for (final item in group.items) {
          if (item.enabled && index < _menuItemFocusNodes.length) {
            final node = _menuItemFocusNodes[index];
            firstEnabled ??= node;
            if (_selectedValues.contains(item.value)) {
              focus(node);
              return;
            }
          }
          index++;
        }
      }
      if (firstEnabled != null) focus(firstEnabled);
    });
  }

  /// Moves the highlight among enabled options, like useSelectHighlight.
  void _moveHighlight({int? delta, bool? toEnd}) {
    final items = [for (final group in widget.groups) ...group.items];
    final enabled = [
      for (var i = 0; i < items.length; i++)
        if (items[i].enabled && i < _menuItemFocusNodes.length) i,
    ];
    if (enabled.isEmpty) return;
    final focused = _menuItemFocusNodes.indexWhere((node) => node.hasFocus);
    final current = focused >= 0 ? focused : _triggerHeldHighlight ?? -1;
    final int target;
    if (toEnd != null) {
      target = toEnd ? enabled.last : enabled.first;
    } else {
      final position = enabled.indexOf(current);
      target = position < 0
          ? enabled.first
          : enabled[(position + delta!) % enabled.length];
    }
    final node = _menuItemFocusNodes[target];
    if (focused >= 0) {
      node.requestFocus();
    } else {
      // Focus stays on the trigger; only the highlight moves.
      setState(() => _triggerHeldHighlight = target);
    }
    _revealOption(node);
  }

  /// Scrolls only as far as needed, like `scrollIntoView({block: "nearest"})`.
  void _revealOption(FocusNode node) {
    final context = node.context;
    if (context == null) return;
    for (final policy in const [
      ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
      ScrollPositionAlignmentPolicy.keepVisibleAtStart,
    ]) {
      Scrollable.ensureVisible(context, alignmentPolicy: policy);
    }
  }

  void _requestOpen(
    bool value, {
    SeedOverlayDismissReason reason = SeedOverlayDismissReason.trigger,
  }) {
    if (widget.readOnly || !widget.enabled) return;
    // Semantic clicks have no raw pointer id; SeedPressable records their
    // click modality before invoking this callback. Actual keyboard events
    // clear that modality, including after a cancelled pointer gesture.
    final pointerOpen = _triggerPointer != null || seedLastInputWasPointer;
    _triggerPointer = null;
    _pointerOpenAwaitingKeyboardHighlight = value && pointerOpen;
    // React's trigger takes focus on press, so closing returns to it rather
    // than to whichever control had focus before.
    if (value && !_usesMenuAnchor) {
      (SeedFieldScope.maybeOf(context)?.focusNode ?? _menuTriggerFocus)
          .requestFocus();
    }
    _emitOpen(value, reason);
    if (widget.open == null) {
      if (_usesMenuAnchor) {
        value ? _menuController.open() : _menuController.close();
      } else {
        value ? _anchored.open() : _anchored.close(reason);
      }
      if (value) _focusOpenMenu();
    }
  }

  /// The official useSelectHighlight trigger keys. While the Select is open
  /// and its trigger holds focus, the same keys keep driving the list.
  KeyEventResult _handleTriggerKey(KeyEvent event, bool open) {
    final field = SeedFieldScope.maybeOf(context);
    if (!widget.enabled || (field?.disabled ?? false)) {
      return KeyEventResult.ignored;
    }
    if (event is KeyDownEvent) {
      final key = event.logicalKey;
      final vertical =
          key == LogicalKeyboardKey.arrowDown ||
          key == LogicalKeyboardKey.arrowUp;
      if (!open && vertical) {
        _triggerPointer = null;
        _requestOpen(true);
        return KeyEventResult.handled;
      }
      if (open && !_usesMenuAnchor) {
        if (vertical) {
          _moveHighlight(delta: key == LogicalKeyboardKey.arrowDown ? 1 : -1);
          return KeyEventResult.handled;
        }
        if (key == LogicalKeyboardKey.home || key == LogicalKeyboardKey.end) {
          _moveHighlight(toEnd: key == LogicalKeyboardKey.end);
          return KeyEventResult.handled;
        }
        final held = _triggerHeldHighlight;
        if (key == LogicalKeyboardKey.tab) {
          if (HardwareKeyboard.instance.isShiftPressed) {
            _requestOpen(false, reason: SeedOverlayDismissReason.focusOut);
            FocusScope.of(context).previousFocus();
          } else if (held != null && held < _menuItemFocusNodes.length) {
            _menuItemFocusNodes[held].requestFocus();
            setState(() => _triggerHeldHighlight = null);
          } else {
            _focusOpenMenu();
          }
          return KeyEventResult.handled;
        }
      }
    }
    if (open) {
      return _usesMenuAnchor
          ? KeyEventResult.ignored
          : _handleTypeahead(event, open: true);
    }
    return widget.multiple
        ? KeyEventResult.ignored
        : _handleTypeahead(event, open: false);
  }

  /// The button's own Enter/Space activation lands here. While the open list
  /// is driven from its trigger, the keyboard commits the highlighted option.
  void _activateTrigger(bool open) {
    final held = _triggerHeldHighlight;
    final items = [for (final group in widget.groups) ...group.items];
    if (open &&
        _triggerPointer == null &&
        held != null &&
        held < items.length) {
      if (items[held].enabled) _select(items[held].value);
      return;
    }
    _requestOpen(!open);
  }

  void _select(T value) {
    if (!widget.enabled || widget.readOnly) return;
    if (widget.multiple) {
      final next = Set<T>.of(_selectedValues);
      next.contains(value) ? next.remove(value) : next.add(value);
      _changeValues(next);
    } else {
      final alreadySelected = _selectedValues.contains(value);
      if (!alreadySelected) {
        _changeValues({value});
      }
      _requestOpen(false, reason: SeedOverlayDismissReason.action);
    }
  }

  @override
  void initState() {
    super.initState();
    _reportedOpen = widget.open ?? widget.defaultOpen;
    final openOnMount =
        widget.enabled &&
        !widget.readOnly &&
        (widget.open ?? widget.defaultOpen);
    if (openOnMount && !_usesMenuAnchor && widget.open == null) {
      _anchored.open();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !openOnMount) return;
      if (_usesMenuAnchor) _menuController.open();
      _focusOpenMenu();
    });
  }

  @override
  void didUpdateWidget(SeedSelect<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.open != null) _reportedOpen = widget.open!;
    final blocked = !widget.enabled || widget.readOnly;
    if (!_usesMenuAnchor) {
      if (blocked && _anchored.isOpen) {
        _anchored.close();
      } else if (!blocked && widget.open == true && oldWidget.open != true) {
        _focusOpenMenu();
      }
      return;
    }
    if (blocked && _menuController.isOpen) {
      _menuController.close();
    } else if (widget.open != null && oldWidget.open != widget.open) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !widget.enabled || widget.readOnly) return;
        widget.open! ? _menuController.open() : _menuController.close();
        if (widget.open!) _focusOpenMenu();
      });
    }
  }

  SeedSelectItem<T>? get _selectedItem {
    final items = _selectedItems;
    return items.length == 1 ? items.first : null;
  }

  SeedInputButtonSize _effectiveSize(BuildContext context) {
    if (widget.size == SeedInputButtonSize.responsive) {
      return MediaQuery.sizeOf(context).width >= 1280
          ? SeedInputButtonSize.medium
          : SeedInputButtonSize.large;
    }
    return widget.size;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;
    _syncMenuItemFocusNodes();

    final menu = LayoutBuilder(
      builder: (context, constraints) => _usesMenuAnchor
          ? MenuAnchor(
              alignmentOffset: widget.menuOffset,
              crossAxisUnconstrained: false,
              onClose: () {
                _pointerOpenAwaitingKeyboardHighlight = false;
                if (widget.open != false) {
                  _emitOpen(
                    false,
                    HardwareKeyboard.instance.logicalKeysPressed.contains(
                          LogicalKeyboardKey.escape,
                        )
                        ? SeedOverlayDismissReason.escapeKey
                        : SeedOverlayDismissReason.outside,
                  );
                  if (widget.open == true) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted &&
                          widget.open == true &&
                          widget.enabled &&
                          !widget.readOnly) {
                        _menuController.open();
                      }
                    });
                  }
                }
              },
              controller: _menuController,
              style: MenuStyle(
                alignment: widget.menuAlignment,
                maximumSize: WidgetStatePropertyAll(
                  Size(double.infinity, widget.maxMenuHeight),
                ),
                minimumSize: WidgetStatePropertyAll(
                  Size(
                    widget.matchWidth && constraints.hasBoundedWidth
                        ? constraints.maxWidth
                        : 0,
                    0,
                  ),
                ),
                backgroundColor: WidgetStatePropertyAll(
                  colors.bg.layerFloating,
                ),
                surfaceTintColor: const WidgetStatePropertyAll(
                  Colors.transparent,
                ),
                elevation: const WidgetStatePropertyAll(6.0),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(borderRadius: SeedBorderRadius.r5),
                ),
                padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(vertical: SeedDimension.x2),
                ),
              ),
              menuChildren: _buildMenuChildren(context, colors, typography),
              builder: (context, controller, child) => _trigger(
                context,
                controller.isOpen,
                () => _requestOpen(!controller.isOpen),
              ),
            )
          : SeedAnchoredOverlay(
              side: widget.side ?? SeedOverlaySide.bottom,
              align: widget.align,
              gap: widget.menuOffset.dy,
              overflowPadding: SeedDimension.x2,
              flip: widget.flip,
              shift: widget.shift,
              controller: _anchored,
              open: !widget.enabled || widget.readOnly ? false : widget.open,
              // Options take focus themselves in _focusOpenMenu.
              autoFocus: false,
              enterCurve: SeedCurves.enter,
              exitCurve: SeedCurves.exit,
              exitScale: 0.95,
              scaleFromAnchor: true,
              onOpenChanged: (open, reason) {
                if (widget.enabled && !widget.readOnly) {
                  _emitOpen(open, reason);
                }
              },
              triggerBuilder: (context, open, toggle) => _trigger(
                context,
                open,
                widget.enabled && !widget.readOnly
                    ? () => _activateTrigger(open)
                    : () {},
              ),
              overlayBuilder: (context) => DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: SeedBorderRadius.r5,
                  boxShadow: context.seedShadows.s3,
                ),
                child: Material(
                  color: colors.bg.layerFloating,
                  borderRadius: SeedBorderRadius.r5,
                  clipBehavior: Clip.antiAlias,
                  child: SizedBox(
                    width: widget.matchWidth && constraints.hasBoundedWidth
                        ? constraints.maxWidth
                        : 240,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: widget.maxMenuHeight,
                      ),
                      child: CallbackShortcuts(
                        bindings: {
                          const SingleActivator(
                            LogicalKeyboardKey.arrowDown,
                          ): () =>
                              _moveHighlight(delta: 1),
                          const SingleActivator(
                            LogicalKeyboardKey.arrowUp,
                          ): () =>
                              _moveHighlight(delta: -1),
                          const SingleActivator(LogicalKeyboardKey.home): () =>
                              _moveHighlight(toEnd: false),
                          const SingleActivator(LogicalKeyboardKey.end): () =>
                              _moveHighlight(toEnd: true),
                        },
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            vertical: SeedDimension.x2,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: _buildMenuChildren(
                              context,
                              colors,
                              typography,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
    if (widget.label != null ||
        widget.description != null ||
        widget.errorMessage != null) {
      return SeedField(
        label: widget.label,
        labelWeight: widget.labelWeight,
        helperText: widget.description,
        errorMessage: widget.errorMessage,
        child: menu,
      );
    }
    return menu;
  }

  @override
  void dispose() {
    _typeaheadReset?.cancel();
    _anchored.dispose();
    _menuTriggerFocus.dispose();
    for (final node in _menuItemFocusNodes) {
      node.dispose();
    }
    _readOnlyFocus.dispose();
    _readOnlyVisualFocus.dispose();
    super.dispose();
  }

  String? get _displayValue {
    final items = _selectedItems;
    // React never calls formatValue for an empty or unresolved selection.
    if (items.isNotEmpty && widget.formatValue != null) {
      return widget.formatValue!(items);
    }
    return widget.multiple
        ? items.map((item) => item.label).join(', ')
        : _selectedItem?.label;
  }

  Widget _trigger(BuildContext context, bool open, VoidCallback toggle) {
    final effectiveSize = _effectiveSize(context);
    final field = SeedFieldScope.maybeOf(context);
    final trigger = SeedInputButton(
      size: widget.size,
      contentScale: true,
      semanticsLabel: widget.semanticsLabel,
      // The readonly appearance has no independent focus target.
      focusNode: widget.readOnly
          ? _readOnlyVisualFocus
          : field?.focusNode ?? _menuTriggerFocus,
      expanded: open,
      value: _displayValue,
      // React SelectValue displays the selected labels joined by ", " for
      // both single and multiple selections. Chip-like custom rendering is
      // still available explicitly through valueBuilder, never by default.
      valueChild: widget.valueBuilder?.call(context, _selectedItems),
      readOnly: widget.readOnly,
      showClear: widget.showClear,
      onClear: () {
        _triggerPointer = null;
        _changeValues({});
        widget.onClear?.call();
      },
      placeholder:
          widget._placeholder ??
          SeedLocalizations.label(context, SeedLabel.selectPlaceholder),
      prefixIcon: _selectedItem?.prefixIcon ?? widget.prefixIcon,
      suffixIcon: AnimatedRotation(
        turns: open ? 0.5 : 0,
        duration: open ? SeedDuration.d3 : SeedDuration.d2,
        child: Icon(
          Icons.keyboard_arrow_down,
          size: effectiveSize == SeedInputButtonSize.large ? 20 : 16,
        ),
      ),
      enabled: widget.enabled,
      isError: widget.isError,
      onPressed: toggle,
    );
    if (!widget.readOnly) {
      return Focus(
        canRequestFocus: false,
        skipTraversal: true,
        includeSemantics: false,
        onKeyEvent: (_, event) => _handleTriggerKey(event, open),
        child: Listener(
          onPointerDown: (event) => _triggerPointer = event.pointer,
          onPointerCancel: (event) {
            if (_triggerPointer == event.pointer) _triggerPointer = null;
          },
          onPointerUp: (event) {
            // GestureDetector activates the trigger after raw pointer dispatch.
            // Keep this event's origin until then, but never beyond this gesture
            // (e.g. a clear-button tap or a drag that did not open the Select).
            scheduleMicrotask(() {
              if (mounted && _triggerPointer == event.pointer) {
                _triggerPointer = null;
              }
            });
          },
          child: trigger,
        ),
      );
    }

    // Select's readonly combobox remains a focus target (useSelect.ts), while
    // FieldButton's readonly trigger is disabled. Keep that distinction here
    // instead of changing SeedInputButton for every consumer.
    final focusNode = field?.focusNode ?? _readOnlyFocus;
    final enabled = widget.enabled && !(field?.disabled ?? false);
    return Focus(
      // Flutter's default directional traversal moves focus on ArrowDown/
      // ArrowUp. React's readonly combobox ignores those keys and keeps DOM
      // focus on its trigger (useSelectHighlight.ts). Consume the traversal
      // intent here while preserving the editable Select's keyboard handling.
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: (_, event) {
        // A key press makes the pointer-focused trigger focus-visible.
        if (event is KeyDownEvent && focusNode.hasFocus) setState(() {});
        if ((event is KeyDownEvent || event is KeyRepeatEvent) &&
            (event.logicalKey == LogicalKeyboardKey.arrowDown ||
                event.logicalKey == LogicalKeyboardKey.arrowUp)) {
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Semantics(
        container: true,
        button: true,
        readOnly: true,
        enabled: enabled,
        focusable: enabled,
        focused: focusNode.hasFocus,
        onFocus: enabled && defaultTargetPlatform != TargetPlatform.iOS
            ? focusNode.requestFocus
            : null,
        expanded: false,
        label: widget.semanticsLabel ?? widget.label ?? field?.label,
        value: _displayValue ?? widget.placeholder,
        child: FocusableActionDetector(
          enabled: enabled,
          focusNode: focusNode,
          includeFocusSemantics: false,
          onFocusChange: (_) => setState(() {}),
          onShowFocusHighlight: (value) =>
              setState(() => _showReadOnlyFocus = value),
          child: Listener(
            onPointerDown: enabled ? (_) => focusNode.requestFocus() : null,
            child: DecoratedBox(
              position: DecorationPosition.foreground,
              decoration: BoxDecoration(
                borderRadius: effectiveSize == SeedInputButtonSize.large
                    ? SeedBorderRadius.r3
                    : SeedBorderRadius.r2,
                border:
                    _showReadOnlyFocus && enabled && !seedLastInputWasPointer
                    ? Border.all(
                        color: context.seedColor.stroke.focusRing,
                        width: 2,
                      )
                    : null,
              ),
              child: ExcludeSemantics(child: trigger),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMenuChildren(
    BuildContext context,
    SeedColorScheme colors,
    SeedTypography typography,
  ) {
    final effectiveSize = _effectiveSize(context);
    final isLarge = effectiveSize == SeedInputButtonSize.large;
    final children = <Widget>[];
    var itemIndex = 0;

    for (int g = 0; g < widget.groups.length; g++) {
      final group = widget.groups[g];

      if (g > 0) {
        children.add(
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: SeedDimension.x4,
              vertical: SeedDimension.x2,
            ),
            child: SeedDivider(),
          ),
        );
      }

      if (group.label != null) {
        children.add(
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: SeedDimension.x4,
              vertical: isLarge ? SeedDimension.x2_5 : SeedDimension.x2,
            ),
            child: Text(
              group.label!,
              style: (isLarge ? typography.t4Medium : typography.t3Regular)
                  .copyWith(color: colors.fg.neutralSubtle),
            ),
          ),
        );
      }

      for (final item in group.items) {
        final isSelected = _selectedValues.contains(item.value);
        final itemEnabled = widget.enabled && item.enabled;
        final optionIndex = itemIndex++;

        children.add(
          Semantics(
            selected: isSelected,
            child: MenuItemButton(
              focusNode: _menuItemFocusNodes[optionIndex],
              onHover: (hovering) {
                if (hovering &&
                    (_pointerOpenAwaitingKeyboardHighlight ||
                        _triggerHeldHighlight != null)) {
                  setState(() {
                    _pointerOpenAwaitingKeyboardHighlight = false;
                    _triggerHeldHighlight = null;
                  });
                }
              },
              closeOnActivate: false,
              // The official content has the trigger's width, so labels wrap.
              overflowAxis: _usesMenuAnchor ? Axis.horizontal : Axis.vertical,
              style: ButtonStyle(
                // Material derives 12px from the standard density and 8px here,
                // the official affix gaps of the large and medium menus.
                visualDensity: isLarge
                    ? VisualDensity.standard
                    : const VisualDensity(horizontal: -2),
                padding: WidgetStatePropertyAll(
                  EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: isLarge ? 12 : 10,
                  ),
                ),
                minimumSize: const WidgetStatePropertyAll(Size.zero),
                // The official option has no 48px mobile tap-target floor.
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                overlayColor: const WidgetStatePropertyAll(Colors.transparent),
                splashFactory: NoSplash.splashFactory,
                backgroundBuilder: (context, states, child) =>
                    _SelectItemHighlight(
                      highlighted:
                          itemEnabled &&
                          // Hover moves focus, so one option is highlighted even
                          // when scrolling slides another under the cursor.
                          (states.contains(WidgetState.pressed) ||
                              _triggerHeldHighlight == optionIndex ||
                              (states.contains(WidgetState.focused) &&
                                  !_pointerOpenAwaitingKeyboardHighlight)),
                      child: child,
                    ),
                foregroundBuilder: (context, states, child) => SeedContentScale(
                  pressed: itemEnabled && states.contains(WidgetState.pressed),
                  child: child ?? const SizedBox.shrink(),
                ),
              ),
              onPressed: widget.enabled && !widget.readOnly && item.enabled
                  ? () => _select(item.value)
                  : null,
              leadingIcon: item.prefixIcon != null
                  ? IconTheme(
                      data: IconThemeData(
                        size: isLarge ? 22 : 18,
                        color: itemEnabled
                            ? colors.fg.neutral
                            : colors.fg.disabled,
                      ),
                      child: item.prefixIcon!,
                    )
                  : null,
              trailingIcon: isSelected
                  ? Icon(
                      Icons.check,
                      color: itemEnabled
                          ? colors.fg.neutral
                          : colors.fg.disabled,
                      size: isLarge ? 14 : 12,
                    )
                  : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  item.labelWidget ??
                      Text(
                        item.label,
                        style:
                            (isLarge
                                    ? typography.t5Regular
                                    : typography.t4Regular)
                                .copyWith(
                                  color: itemEnabled
                                      ? colors.fg.neutral
                                      : colors.fg.disabled,
                                  fontWeight: FontWeight.normal,
                                ),
                      ),
                  if (item.description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.description!,
                      style:
                          (isLarge
                                  ? typography.t3Regular
                                  : typography.t2Regular)
                              .copyWith(
                                color: itemEnabled
                                    ? colors.fg.neutralSubtle
                                    : colors.fg.disabled,
                              ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }
    }

    return children;
  }
}

/// The official item's `::before`: the pressed color inset by marginX.
class _SelectItemHighlight extends StatelessWidget {
  const _SelectItemHighlight({required this.highlighted, this.child});

  final bool highlighted;
  final Widget? child;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Positioned.fill(
        child: AnimatedPadding(
          padding: EdgeInsets.symmetric(
            horizontal: highlighted ? SeedDimension.x2 : 0,
          ),
          duration: SeedDuration.d3,
          curve: SeedCurves.easing,
          child: AnimatedContainer(
            duration: SeedDuration.colorTransition,
            curve: SeedCurves.easing,
            decoration: BoxDecoration(
              color: highlighted
                  ? context.seedColor.bg.transparentPressed
                  : context.seedColor.bg.transparentPressed.withValues(
                      alpha: 0,
                    ),
              borderRadius: SeedBorderRadius.r3,
            ),
          ),
        ),
      ),
      ?child,
    ],
  );
}
