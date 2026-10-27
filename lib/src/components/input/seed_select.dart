import '../chip/seed_chip.dart';
import 'seed_field.dart';
import '../overlay/seed_anchored_overlay.dart';

import 'package:flutter/services.dart';

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
  const SeedSelectItem({
    required this.value,
    required this.label,
    this.description,
    this.prefixIcon,
    this.enabled = true,
    this.labelWidget,
  });

  final Widget? labelWidget;
  final T value;
  final String label;
  final String? description;
  final Widget? prefixIcon;
  final bool enabled;
}

/// A group of items in a [SeedSelect].
class SeedSelectGroup<T> {
  const SeedSelectGroup({this.label, required this.items});

  final String? label;
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
  const SeedSelect({
    super.key,
    required this.groups,
    this.value,
    this.placeholder = '선택해주세요',
    this.prefixIcon,
    this.onChanged,
    this.size = SeedInputButtonSize.medium,
    this.enabled = true,
    this.isError = false,
    this.readOnly = false,
    this.controlled = false,
    this.matchWidth = true,
    this.menuAlignment = AlignmentDirectional.bottomStart,
    this.menuOffset = Offset.zero,
    this.side,
    this.align = SeedOverlayAlign.start,
    this.flip = true,
    this.shift = true,
    this.multiple = false,
    this.values,
    Set<T>? defaultValues,
    Set<T>? initialValues,
    this.defaultValue,
    this.onValueChange,
    this.onValuesChanged,
    this.open,
    this.defaultOpen = false,
    SeedOverlayOpenChanged? onOpenChanged,
    SeedOverlayOpenChanged? onOpenChange,
    this.onOpenStateChanged,
    this.onValueChanged,
    this.maxMenuHeight = 480,
    this.valueBuilder,
    this.formatValue,
    this.label,
    this.description,
    this.errorMessage,
    this.showClear = false,
    this.onClear,
  }) : onOpenChanged = onOpenChanged ?? onOpenChange,
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

  /// Selected option values, matching React for both single and multiple mode.
  /// An empty list is a controlled empty selection.
  final List<T>? value;

  /// Placeholder text when [value] is null.
  final String placeholder;

  /// Prefix icon for the trigger.
  final Widget? prefixIcon;

  /// Callback when a value is selected.
  final ValueChanged<T>? onChanged;

  /// The size variant of the select trigger.
  final SeedInputButtonSize size;

  /// Whether the select is enabled.
  final bool enabled;

  /// Whether the select trigger displays an error stroke.
  final bool isError;
  final bool readOnly;
  final bool controlled, matchWidth;
  final AlignmentGeometry menuAlignment;
  final Offset menuOffset;
  final SeedOverlaySide? side;
  final SeedOverlayAlign align;
  final bool flip, shift;
  final bool multiple;
  final Set<T>? values;
  final Set<T> initialValues;

  /// Legacy set-valued seed; prefer the React-compatible list [defaultValue].
  Set<T> get defaultValues => initialValues;
  final List<T>? defaultValue;
  final ValueChanged<List<T>>? onValueChange;
  final ValueChanged<Set<T>>? onValuesChanged;
  final bool? open;
  final bool defaultOpen;
  final SeedOverlayOpenChanged? onOpenChanged;

  /// Optional visibility-only observer, alongside [onOpenChanged].
  final ValueChanged<bool>? onOpenStateChanged;
  SeedOverlayOpenChanged? get onOpenChange => onOpenChanged;
  final ValueChanged<T?>? onValueChanged;
  final double maxMenuHeight;
  final Widget Function(BuildContext, List<SeedSelectItem<T>>)? valueBuilder;
  final String Function(List<SeedSelectItem<T>>)? formatValue;
  final String? label;
  final String? description;
  final String? errorMessage;
  final bool showClear;
  final VoidCallback? onClear;

  @override
  State<SeedSelect<T>> createState() => _SeedSelectState<T>();
}

class _SeedSelectState<T> extends State<SeedSelect<T>> {
  final MenuController _menuController = MenuController();
  final SeedOverlayController _anchored = SeedOverlayController();

  bool _reportedOpen = false;
  void _emitOpen(bool open, SeedOverlayDismissReason reason) {
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
  void _requestOpen(
    bool value, {
    SeedOverlayDismissReason reason = SeedOverlayDismissReason.trigger,
  }) {
    if (widget.readOnly || !widget.enabled) return;
    _emitOpen(value, reason);
    if (widget.open == null) {
      if (widget.side != null) {
        value ? _anchored.open() : _anchored.close(reason);
      } else {
        value ? _menuController.open() : _menuController.close();
      }
    }
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted &&
          widget.enabled &&
          !widget.readOnly &&
          (widget.open ?? widget.defaultOpen) &&
          widget.side == null) {
        _menuController.open();
      }
    });
  }

  @override
  void didUpdateWidget(SeedSelect<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.open != null) _reportedOpen = widget.open!;
    if (widget.side != null) return;
    if ((!widget.enabled || widget.readOnly) && _menuController.isOpen) {
      _menuController.close();
    } else if (widget.open != null && oldWidget.open != widget.open) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !widget.enabled || widget.readOnly) return;
        widget.open! ? _menuController.open() : _menuController.close();
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
          ? SeedInputButtonSize.small
          : SeedInputButtonSize.medium;
    }
    return widget.size;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.seedColor;
    final typography = context.seedTypography;

    final menu = LayoutBuilder(
      builder: (context, constraints) => widget.side == null
          ? MenuAnchor(
              alignmentOffset: widget.menuOffset,
              crossAxisUnconstrained: false,
              onClose: () {
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
              side: widget.side!,
              align: widget.align,
              flip: widget.flip,
              shift: widget.shift,
              controller: _anchored,
              open: !widget.enabled || widget.readOnly ? false : widget.open,
              defaultOpen:
                  widget.enabled && !widget.readOnly && widget.defaultOpen,
              onOpenChanged: (open, reason) {
                if (widget.enabled && !widget.readOnly) {
                  _emitOpen(open, reason);
                }
              },
              triggerBuilder: (context, open, toggle) => _trigger(
                context,
                open,
                widget.enabled && !widget.readOnly ? toggle : () {},
              ),
              overlayBuilder: (context) => Material(
                color: colors.bg.layerFloating,
                borderRadius: SeedBorderRadius.r5,
                elevation: 6,
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
                        ): () => FocusScope.of(context)
                            .nextFocus(),
                        const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
                            FocusScope.of(context).previousFocus(),
                        const SingleActivator(LogicalKeyboardKey.home): () {
                          final descendants = FocusScope.of(context)
                              .traversalDescendants
                              .toList();
                          if (descendants.isNotEmpty) {
                            descendants.first.requestFocus();
                          }
                        },
                        const SingleActivator(LogicalKeyboardKey.end): () {
                          final descendants = FocusScope.of(context)
                              .traversalDescendants
                              .toList();
                          if (descendants.isNotEmpty) {
                            descendants.last.requestFocus();
                          }
                        },
                      },
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(vertical: 8),
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
    );
    if (widget.label != null ||
        widget.description != null ||
        widget.errorMessage != null) {
      return SeedField(
        label: widget.label,
        helperText: widget.description,
        errorMessage: widget.errorMessage,
        child: menu,
      );
    }
    return menu;
  }

  @override
  void dispose() {
    _anchored.dispose();
    super.dispose();
  }

  Widget _trigger(BuildContext context, bool open, VoidCallback toggle) {
    final effectiveSize = _effectiveSize(context);
    return SeedInputButton(
      size: widget.size,
      expanded: open,
      value: widget.multiple
          ? (widget.formatValue?.call(_selectedItems) ??
                _selectedItems.map((item) => item.label).join(', '))
          : _selectedItem?.label,
      valueChild:
          widget.valueBuilder?.call(context, _selectedItems) ??
          (widget.multiple &&
                  _selectedItems.isNotEmpty &&
                  widget.formatValue == null
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      for (final item in _selectedItems)
                        SeedChip(
                          label: item.label,
                          onDeleted: widget.enabled && !widget.readOnly
                              ? () => _select(item.value)
                              : null,
                        ),
                    ],
                  ),
                )
              : null),
      readOnly: widget.readOnly,
      showClear: widget.showClear,
      onClear: () {
        _changeValues({});
        widget.onClear?.call();
      },
      placeholder: widget.placeholder,
      prefixIcon: _selectedItem?.prefixIcon ?? widget.prefixIcon,
      suffixIcon: AnimatedRotation(
        turns: open ? 0.5 : 0,
        duration: open ? SeedDuration.d3 : SeedDuration.d2,
        child: Icon(
          Icons.keyboard_arrow_down,
          size: effectiveSize == SeedInputButtonSize.medium ? 20 : 16,
        ),
      ),
      enabled: widget.enabled,
      isError: widget.isError,
      onPressed: toggle,
    );
  }

  List<Widget> _buildMenuChildren(
    BuildContext context,
    SeedColorScheme colors,
    SeedTypography typography,
  ) {
    final effectiveSize = _effectiveSize(context);
    final isLarge = effectiveSize == SeedInputButtonSize.medium;
    final children = <Widget>[];

    for (int g = 0; g < widget.groups.length; g++) {
      final group = widget.groups[g];

      if (g > 0) {
        children.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: SeedDimension.x4),
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

        children.add(
          Semantics(
            selected: isSelected,
            child: MenuItemButton(
              closeOnActivate: false,
              style: ButtonStyle(
                padding: WidgetStatePropertyAll(
                  EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: isLarge ? 12 : 10,
                  ),
                ),
                minimumSize: const WidgetStatePropertyAll(Size.zero),
                overlayColor: WidgetStatePropertyAll(
                  colors.bg.transparentPressed,
                ),
                shape: const WidgetStatePropertyAll(
                  RoundedRectangleBorder(borderRadius: SeedBorderRadius.r3),
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
