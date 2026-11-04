import 'package:material_ui/material_ui.dart';

import '../overlay/seed_anchored_overlay.dart';
import 'seed_input_button.dart';
import 'seed_select.dart';
import 'seed_text_field.dart';

/// Flutter Form adapter for SEED Select, including validation, save and reset.
///
/// Uses the official list-valued selection API in single and multiple mode.
/// With [value] (or [controlled]), the parent remains authoritative on reset.
class SeedSelectFormField<T> extends SeedFormField<List<T>> {
  /// Creates a [Form]-registered Select backed by a list-valued field.
  ///
  /// [groups] provides the options. A non-null [value] controls the
  /// selection, including an empty list; [controlled] also makes null an
  /// explicitly controlled empty value. Otherwise [defaultValue] seeds the
  /// local form value (default empty), and form reset restores this seed.
  /// [onValueChange] receives an unmodifiable selection list after changes.
  ///
  /// The inherited [validator], [onSaved], [onReset], [autovalidateMode],
  /// and [restorationId] connect to Flutter's [Form] lifecycle.
  /// [errorMessage] overrides validation error text when supplied.
  /// [enabled] controls interaction, while [readOnly] leaves it viewable but
  /// uneditable. [multiple] enables selecting several items.
  ///
  /// [label] and [description] render the field text; [placeholder] and
  /// [prefixIcon] customize the trigger. [size] defaults to medium.
  /// [showClear] adds a clear-selection action; [matchWidth] defaults true;
  /// [maxMenuHeight] defaults to 480 logical pixels and [side] specifies popup
  /// placement. [open], [defaultOpen], and [onOpenChange] control and observe
  /// popup visibility separately from the selection.
  /// [valueBuilder] and [formatValue] customize selected-value rendering.
  SeedSelectFormField({
    super.key,
    required List<SeedSelectGroup<T>> groups,
    List<T>? value,
    List<T> defaultValue = const [],
    super.controlled,
    ValueChanged<List<T>>? onValueChange,
    super.validator,
    super.onSaved,
    super.onReset,
    super.autovalidateMode,
    super.restorationId,
    String? errorMessage,
    super.enabled,
    bool readOnly = false,
    bool multiple = false,
    String? label,
    String? description,
    String? placeholder,
    Widget? prefixIcon,
    SeedInputButtonSize size = SeedInputButtonSize.medium,
    bool showClear = false,
    bool matchWidth = true,
    double maxMenuHeight = 480,
    SeedOverlaySide? side,
    bool? open,
    bool defaultOpen = false,
    SeedOverlayOpenChanged? onOpenChange,
    Widget Function(BuildContext, List<SeedSelectItem<T>>)? valueBuilder,
    String Function(List<SeedSelectItem<T>>)? formatValue,
  }) : super(
         value: value == null ? null : List<T>.unmodifiable(value),
         initialValue: List<T>.unmodifiable(defaultValue),
         forceErrorText: errorMessage,
         onValueChanged: (next) =>
             onValueChange?.call(List<T>.unmodifiable(next ?? <T>[])),
         builder: (field) => SeedSelect<T>(
           groups: groups,
           value: field.value ?? <T>[],
           onValueChange: field.didChange,
           enabled: enabled,
           readOnly: readOnly,
           multiple: multiple,
           label: label,
           description: description,
           placeholder: placeholder,
           prefixIcon: prefixIcon,
           size: size,
           errorMessage: field.errorText,
           isError: field.hasError,
           showClear: showClear,
           matchWidth: matchWidth,
           maxMenuHeight: maxMenuHeight,
           side: side,
           open: open,
           defaultOpen: defaultOpen,
           onOpenChange: onOpenChange,
           valueBuilder: valueBuilder,
           formatValue: formatValue,
         ),
       );
}
