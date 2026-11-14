import 'package:material_ui/material_ui.dart';

import 'seed_attachment_input.dart';
import 'seed_field.dart';

/// UI entries only. File selection, validation and uploading belong to the app.
class SeedAttachmentController extends ChangeNotifier {
  /// Creates a UI-only controller from initial [items].
  /// [maxCount] defaults to 1 and must be positive; [enabled] defaults to true and
  /// [readOnly] to false. Selecting, validating and uploading files belong to callers.
  SeedAttachmentController({
    List<SeedAttachmentItem> items = const [],
    this.maxCount = 1,
    this.enabled = true,
    this.readOnly = false,
  }) : _items = List.of(items),
       assert(maxCount > 0);
  List<SeedAttachmentItem> _items;

  /// Maximum number of entries [addEntries] accepts; existing entries are not pruned.
  int maxCount;

  /// Interaction gates: enabled blocks additions/reordering when false; readOnly also blocks removal.
  bool enabled, readOnly;

  /// Unmodifiable snapshot of the ordered entries.
  List<SeedAttachmentItem> get items => List.unmodifiable(_items);

  /// Whether adding or reordering is allowed.
  bool get canEdit => enabled && !readOnly;

  /// Disabling the trigger still allows pruning existing entries.
  bool get canRemove => !readOnly;

  /// Whether the controller is editable and below [maxCount].
  bool get canAdd => canEdit && _items.length < maxCount;

  /// Replaces all entries; entry IDs must be unique.
  /// [notify] defaults to true and controls whether listeners are notified.
  void replaceItems(List<SeedAttachmentItem> items, {bool notify = true}) {
    assert(
      items.map((item) => item.id).toSet().length == items.length,
      'Attachment IDs must be unique',
    );
    _items = List.of(items);
    if (notify) notifyListeners();
  }

  /// UI single mode replaces the displayed entry; no file or network operation occurs.
  void addEntries(List<SeedAttachmentItem> entries) {
    if (!canEdit || entries.isEmpty) return;
    if (maxCount == 1) {
      replaceItems([entries.first]);
      return;
    }
    final ids = _items.map((entry) => entry.id).toSet();
    final added = entries
        .where((entry) => ids.add(entry.id))
        .take((maxCount - _items.length).clamp(0, maxCount));
    replaceItems([..._items, ...added]);
  }

  /// Replaces the status for entry [id] with [status] and optional [progress].
  /// Null [progress] clears any previous progress, even if edits are disabled.
  void updateStatus(
    String id,
    SeedAttachmentStatus status, {
    double? progress,
  }) => replaceItems([
    for (final item in _items)
      if (item.id == id)
        // React replaces the status details, so progress never outlives them.
        item.copyWith(
          status: status,
          progress: progress,
          clearProgress: progress == null,
        )
      else
        item,
  ]);

  /// Removes the entry matching [id] when item and controller allow removal.
  /// Disabled controllers can still remove; read-only controllers cannot.
  void remove(String id) {
    if (!canRemove) return;
    final item = _items.where((item) => item.id == id).firstOrNull;
    if (item == null || item.readOnly || !item.enabled || !item.removeEnabled) {
      return;
    }
    replaceItems(_items.where((item) => item.id != id).toList());
  }

  /// Uses ReorderableListView's destination-before-removal convention.
  void reorder(int from, int to) {
    if (!canEdit ||
        from < 0 ||
        from >= _items.length ||
        to < 0 ||
        to > _items.length) {
      return;
    }
    final item = _items[from];
    if (item.readOnly || !item.enabled) return;
    final items = List.of(_items)..removeAt(from);
    items.insert(to > from ? to - 1 : to, item);
    replaceItems(items);
  }
}

/// Field composition for externally supplied image/file previews.
class SeedAttachmentDisplayField extends StatefulWidget {
  /// Composes the React AttachmentDisplay field with externally supplied entries.
  /// [entries] is controlled; [defaultEntries] is an uncontrolled initial seed.
  /// [controller] is mutually exclusive with either. [initialEntries] and
  /// [onEntriesChanged] are deprecated aliases; [onEntriesChange] reports proposals.
  ///
  /// [onTrigger] receives the active controller for application-owned selection;
  /// [onRetry] receives an item and controller. [maxEntries] defaults to 1.
  /// [enabled] gates addition; [readOnly] additionally blocks removal.
  /// [reorderable] enables item dragging. [itemBuilder] overrides the default list.
  /// [label], [description], [indicator], [labelWeight], [showRequiredIndicator]
  /// and [errorMessage] configure the field. [invalid] defaults to null and then
  /// follows the presence of [errorMessage]. [showDropzone] swaps the add tile for
  /// the dropzone, with externally supplied [isDraggingOver] highlight.
  /// [inset], [itemSize], [triggerIcon] and [representativeLabel] are composition
  /// options, not automatic file-handling features. [extendSafeAreaX] is
  /// forwarded to [SeedAttachmentInput.extendSafeAreaX].
  const SeedAttachmentDisplayField({
    super.key,
    this.controller,
    this.entries,
    List<SeedAttachmentItem>? defaultEntries,
    @Deprecated('Use defaultEntries instead.')
    List<SeedAttachmentItem>? initialEntries,
    ValueChanged<List<SeedAttachmentItem>>? onEntriesChange,
    @Deprecated('Use onEntriesChange instead.')
    ValueChanged<List<SeedAttachmentItem>>? onEntriesChanged,
    this.onTrigger,
    this.onRetry,
    this.maxEntries = 1,
    this.enabled = true,
    this.readOnly = false,
    this.reorderable = false,
    this.label,
    this.description,
    this.errorMessage,
    this.invalid,
    this.showRequiredIndicator = false,
    this.indicator,
    this.labelWeight = SeedFieldLabelWeight.medium,
    this.itemBuilder,
    this.inset = EdgeInsets.zero,
    this.showDropzone = false,
    this.isDraggingOver = false,
    this.itemSize = 80,
    this.triggerIcon,
    String? representativeLabel,
    this.extendSafeAreaX = false,
    // Preserve the public named parameter and getter.
    // ignore: prefer_initializing_formals
  }) : _representativeLabel = representativeLabel,
       onEntriesChanged = onEntriesChange ?? onEntriesChanged,
       assert(onEntriesChange == null || onEntriesChanged == null),
       initialEntries = defaultEntries ?? initialEntries ?? const [],
       assert(defaultEntries == null || initialEntries == null),
       assert(
         controller == null ||
             (entries == null &&
                 defaultEntries == null &&
                 initialEntries == null),
         'A controller cannot be combined with entries or an initial seed.',
       );

  /// Optional externally owned controller; it is not disposed by the field.
  final SeedAttachmentController? controller;

  /// Controlled attachment list; the parent commits proposed updates.
  final List<SeedAttachmentItem>? entries;
  @Deprecated('Use defaultEntries instead.')
  /// Deprecated initial-list alias; use [defaultEntries].
  final List<SeedAttachmentItem> initialEntries;

  /// One-time seed; [initialEntries] is a compatibility alias.
  List<SeedAttachmentItem> get defaultEntries => initialEntries;
  @Deprecated('Use onEntriesChange instead.')
  /// Deprecated callback alias; use [onEntriesChange].
  final ValueChanged<List<SeedAttachmentItem>>? onEntriesChanged;

  /// React-aligned callback receiving proposed attachment lists.
  ValueChanged<List<SeedAttachmentItem>>? get onEntriesChange =>
      onEntriesChanged;

  /// Add-trigger callback; caller uses controller to add selected entries.
  final ValueChanged<SeedAttachmentController>? onTrigger;

  /// Retry intent callback receiving the affected entry and active controller.
  final void Function(SeedAttachmentItem, SeedAttachmentController)? onRetry;

  /// Maximum number of entries permitted by the add control (default 1).
  final int maxEntries;

  /// Flags for add availability, read-only protection, drag reordering,
  /// dropzone visibility and external drag-over feedback, respectively.
  /// Only [enabled] defaults to true; the other flags default to false.
  final bool enabled, readOnly, reorderable, showDropzone, isDraggingOver;

  /// Square preview width and height, in logical pixels (default 80).
  final double itemSize;

  /// Optional custom icon for the add tile.
  final Widget? triggerIcon;

  /// Badge text for the representative item. Existing callers retain '대표'.
  final String? _representativeLabel;

  /// Representative image badge text; defaults to '대표'.
  String get representativeLabel => _representativeLabel ?? '대표';

  /// Optional field label, helper description and error message.
  final String? label, description, errorMessage;

  /// Independent validation state. When omitted, a legacy [errorMessage]
  /// continues to indicate an invalid field.
  final bool? invalid;

  /// Displays the required mark beside [label], as in React AttachmentDisplayField.
  final bool showRequiredIndicator;

  /// Text beside [label], as in React AttachmentDisplayField.
  final String? indicator;

  /// Label type weight; defaults to [SeedFieldLabelWeight.medium].
  final SeedFieldLabelWeight labelWeight;

  /// Custom item-list builder, called with the live attachment controller.
  final Widget Function(BuildContext, SeedAttachmentController)? itemBuilder;

  /// Padding around attachment content (default [EdgeInsets.zero]).
  final EdgeInsetsGeometry inset;

  /// Bleeds the default attachment list under the horizontal safe-area
  /// insets; see [SeedAttachmentInput.extendSafeAreaX]. Defaults to false.
  ///
  /// As in React, where the dropzone keeps a margin of the insets, the
  /// label, description, error and dropzone stay inside the safe area; only
  /// the scrolling list extends. A custom [itemBuilder] list is not affected.
  final bool extendSafeAreaX;
  @override
  State<SeedAttachmentDisplayField> createState() =>
      _SeedAttachmentDisplayFieldState();
}

class _SeedAttachmentDisplayFieldState
    extends State<SeedAttachmentDisplayField> {
  late SeedAttachmentController _controller;
  @override
  void initState() {
    super.initState();
    _attach();
  }

  void _attach() {
    _controller =
        widget.controller ??
        SeedAttachmentController(
          items: widget.entries ?? widget.defaultEntries,
        );
    _configure();
    _controller.addListener(_changed);
  }

  void _configure() {
    _controller.maxCount = widget.maxEntries;
    _controller.enabled = widget.enabled;
    _controller.readOnly = widget.readOnly;
  }

  void _changed() {
    if (mounted) {
      final next = _controller.items;
      if (widget.entries != null) {
        _controller.replaceItems(widget.entries!, notify: false);
      }
      widget.onEntriesChanged?.call(next);
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(SeedAttachmentDisplayField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _controller.removeListener(_changed);
      if (oldWidget.controller == null) _controller.dispose();
      _attach();
    } else {
      _configure();
    }
    if (widget.entries != null && oldWidget.entries != widget.entries) {
      _controller.replaceItems(widget.entries!, notify: false);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_changed);
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final invalid = widget.invalid ?? widget.errorMessage != null;
    return SeedField(
      label: widget.label,
      labelWeight: widget.labelWeight,
      required: widget.showRequiredIndicator,
      indicatorText: widget.indicator,
      isInvalid: invalid,
      helperText: widget.description,
      errorMessage: invalid ? widget.errorMessage : null,
      child: Padding(
        padding: widget.inset,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.showDropzone) ...[
              SeedAttachmentDropzone(
                enabled: _controller.canAdd,
                isDraggingOver: widget.isDraggingOver,
                onTap: () => widget.onTrigger?.call(_controller),
              ),
              const SizedBox(height: 8),
            ],
            widget.itemBuilder?.call(context, _controller) ??
                SeedAttachmentInput(
                  items: widget.entries ?? _controller.items,
                  maxCount: widget.maxEntries,
                  enabled: widget.enabled,
                  readOnly: widget.readOnly,
                  itemSize: widget.itemSize,
                  triggerIcon: widget.triggerIcon,
                  representativeLabel: widget._representativeLabel,
                  showTrigger: !widget.showDropzone,
                  onAdd: () => widget.onTrigger?.call(_controller),
                  onRemove: (item) => _controller.remove(item.id),
                  onRetry: widget.onRetry == null
                      ? null
                      : (item) => widget.onRetry!(item, _controller),
                  onReorder: widget.reorderable ? _controller.reorder : null,
                  extendSafeAreaX: widget.extendSafeAreaX,
                ),
          ],
        ),
      ),
    );
  }
}

/// Compatibility alias of [SeedAttachmentDisplayField] with item-based names.
class SeedAttachmentField extends SeedAttachmentDisplayField {
  /// Compatibility wrapper exposing [SeedAttachmentDisplayField] composition.
  /// [items]/[defaultItems]/[initialItems] map to entries/defaultEntries/
  /// initialEntries; [onItemsChanged] maps to onEntriesChange; [onAdd] invokes
  /// the add trigger without passing a controller. [maxCount] maps to maxEntries
  /// and defaults to 1. Other named arguments are forwarded unchanged.
  SeedAttachmentField({
    super.key,
    super.controller,
    List<SeedAttachmentItem>? items,
    List<SeedAttachmentItem>? defaultItems,
    List<SeedAttachmentItem>? initialItems,
    ValueChanged<List<SeedAttachmentItem>>? onItemsChanged,
    VoidCallback? onAdd,
    super.onRetry,
    int maxCount = 1,
    super.enabled,
    super.readOnly,
    super.reorderable,
    super.label,
    super.description,
    super.errorMessage,
    super.invalid,
    super.showRequiredIndicator,
    super.indicator,
    super.labelWeight,
    super.itemBuilder,
    super.inset,
    super.showDropzone,
    super.isDraggingOver,
    super.itemSize,
    super.triggerIcon,
    super.representativeLabel,
    super.extendSafeAreaX,
  }) : super(
         entries: items,
         defaultEntries: defaultItems,
         initialEntries: initialItems,
         onEntriesChanged: onItemsChanged,
         maxEntries: maxCount,
         onTrigger: onAdd == null ? null : _trigger(onAdd),
       );
  static ValueChanged<SeedAttachmentController> _trigger(
    VoidCallback callback,
  ) =>
      (_) => callback();
}
