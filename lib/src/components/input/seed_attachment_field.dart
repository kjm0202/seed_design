import 'package:material_ui/material_ui.dart';

import 'seed_attachment_input.dart';
import 'seed_field.dart';

/// UI entries only. File selection, validation and uploading belong to the app.
class SeedAttachmentController extends ChangeNotifier {
  SeedAttachmentController({
    List<SeedAttachmentItem> items = const [],
    this.maxCount = 10,
    this.enabled = true,
    this.readOnly = false,
  }) : _items = List.of(items),
       assert(maxCount > 0);
  List<SeedAttachmentItem> _items;
  int maxCount;
  bool enabled, readOnly;
  List<SeedAttachmentItem> get items => List.unmodifiable(_items);
  bool get canEdit => enabled && !readOnly;

  /// Disabling the trigger still allows pruning existing entries.
  bool get canRemove => !readOnly;
  bool get canAdd => canEdit && _items.length < maxCount;
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
      replaceItems([entries.last]);
      return;
    }
    final ids = _items.map((entry) => entry.id).toSet();
    final added = entries
        .where((entry) => ids.add(entry.id))
        .take((maxCount - _items.length).clamp(0, maxCount));
    replaceItems([..._items, ...added]);
  }

  void updateStatus(
    String id,
    SeedAttachmentStatus status, {
    double? progress,
  }) => replaceItems([
    for (final item in _items)
      if (item.id == id)
        item.copyWith(status: status, progress: progress)
      else
        item,
  ]);
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
  const SeedAttachmentDisplayField({
    super.key,
    this.controller,
    this.entries,
    List<SeedAttachmentItem>? defaultEntries,
    List<SeedAttachmentItem>? initialEntries,
    this.onEntriesChanged,
    this.onTrigger,
    this.onRetry,
    this.maxEntries = 10,
    this.enabled = true,
    this.readOnly = false,
    this.reorderable = false,
    this.label,
    this.description,
    this.errorMessage,
    this.itemBuilder,
    this.inset = EdgeInsets.zero,
    this.showDropzone = false,
    this.isDraggingOver = false,
    this.itemSize = 80,
  }) : initialEntries = defaultEntries ?? initialEntries ?? const [],
       assert(defaultEntries == null || initialEntries == null),
       assert(
         controller == null ||
             (entries == null &&
                 defaultEntries == null &&
                 initialEntries == null),
         'A controller cannot be combined with entries or an initial seed.',
       );
  final SeedAttachmentController? controller;
  final List<SeedAttachmentItem>? entries;
  final List<SeedAttachmentItem> initialEntries;

  /// One-time seed; [initialEntries] is a compatibility alias.
  List<SeedAttachmentItem> get defaultEntries => initialEntries;
  final ValueChanged<List<SeedAttachmentItem>>? onEntriesChanged;
  final ValueChanged<SeedAttachmentController>? onTrigger;
  final void Function(SeedAttachmentItem, SeedAttachmentController)? onRetry;
  final int maxEntries;
  final bool enabled, readOnly, reorderable, showDropzone, isDraggingOver;
  final double itemSize;
  final String? label, description, errorMessage;
  final Widget Function(BuildContext, SeedAttachmentController)? itemBuilder;
  final EdgeInsetsGeometry inset;
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
  Widget build(BuildContext context) => SeedField(
    label: widget.label,
    helperText: widget.description,
    errorMessage: widget.errorMessage,
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
                onAdd: () => widget.onTrigger?.call(_controller),
                onRemove: (item) => _controller.remove(item.id),
                onRetry: (item) => widget.onRetry?.call(item, _controller),
                onReorder: widget.reorderable ? _controller.reorder : null,
              ),
        ],
      ),
    ),
  );
}

class SeedAttachmentField extends SeedAttachmentDisplayField {
  SeedAttachmentField({
    super.key,
    super.controller,
    List<SeedAttachmentItem>? items,
    List<SeedAttachmentItem>? defaultItems,
    List<SeedAttachmentItem>? initialItems,
    ValueChanged<List<SeedAttachmentItem>>? onItemsChanged,
    VoidCallback? onAdd,
    super.onRetry,
    int maxCount = 10,
    super.enabled,
    super.readOnly,
    super.reorderable,
    super.label,
    super.description,
    super.errorMessage,
    super.itemBuilder,
    super.inset,
    super.showDropzone,
    super.isDraggingOver,
    super.itemSize,
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
