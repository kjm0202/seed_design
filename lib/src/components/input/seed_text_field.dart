import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import 'seed_field.dart';
import 'seed_text_input.dart';
import 'seed_input_button.dart';
import '../chip/seed_chip.dart';

/// Controlled/uncontrolled Form integration reusable with every SEED input.
///
/// [value] is authoritative when non-null or [controlled] is true. [FormFieldState.didChange]
/// proposals notify [onValueChanged] without committing parent-owned values.
class SeedFormField<T> extends FormField<T> {
  const SeedFormField({
    super.key,
    this.value,
    this.controlled = false,
    T? initialValue,
    this.onValueChanged,
    required super.builder,
    super.validator,
    super.onSaved,
    super.onReset,
    super.enabled,
    super.autovalidateMode,
  }) : super(initialValue: controlled ? value : value ?? initialValue);

  /// Includes a null [value] in parent-controlled state.
  final bool controlled;
  final T? value;
  final ValueChanged<T?>? onValueChanged;
  @override
  FormFieldState<T> createState() => _SeedFormFieldState<T>();
}

class _SeedFormFieldState<T> extends FormFieldState<T> {
  @override
  SeedFormField<T> get widget => super.widget as SeedFormField<T>;
  @override
  void didUpdateWidget(SeedFormField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controlled || widget.value != null) setValue(widget.value);
  }

  @override
  void didChange(T? value) {
    super.didChange(
      widget.controlled || widget.value != null ? widget.value : value,
    );
    widget.onValueChanged?.call(value);
  }

  @override
  void reset() {
    super.reset();
    if (widget.controlled || widget.value != null) setValue(widget.value);
  }
}

/// Label, description, validation and live grapheme count around a SEED input.
class SeedTextField extends StatefulWidget {
  const SeedTextField({
    super.key,
    this.controller,
    this.value,
    this.defaultValue,
    this.label,
    this.description,
    this.errorMessage,
    this.required = false,
    this.enabled = true,
    this.readOnly = false,
    this.placeholder,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.maxGraphemeCount,
    this.enforceMaxLength = false,
    this.onChanged,
    this.onValueChanged,
    this.onSaved,
    this.validator,
    this.inputFormatters,
    this.inputBuilder,
    this.focusNode,
    this.variant = SeedTextInputVariant.outline,
    this.size = SeedTextInputSize.large,
    this.responsive = false,
    this.maxLines = 1,
    this.minLines,
    this.autoResize = false,
    this.maxHeight,
    this.clearable = true,
    this.obscureText = false,
    this.keyboardType,
    this.autovalidateMode = AutovalidateMode.disabled,
  }) : assert(
         controller == null || (value == null && defaultValue == null),
         'A controller cannot be combined with value or defaultValue.',
       );

  /// Creates a multiline textarea field that auto-resizes by default,
  /// matching React's `<TextFieldTextarea>`.
  const SeedTextField.textarea({
    super.key,
    this.controller,
    this.value,
    this.defaultValue,
    this.label,
    this.description,
    this.errorMessage,
    this.required = false,
    this.enabled = true,
    this.readOnly = false,
    this.placeholder,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.maxGraphemeCount,
    this.enforceMaxLength = false,
    this.onChanged,
    this.onValueChanged,
    this.onSaved,
    this.validator,
    this.inputFormatters,
    this.inputBuilder,
    this.focusNode,
    this.variant = SeedTextInputVariant.outline,
    this.size = SeedTextInputSize.large,
    this.responsive = false,
    this.maxLines,
    this.minLines,
    this.autoResize = true,
    this.maxHeight,
    this.clearable = false,
    this.obscureText = false,
    this.keyboardType = TextInputType.multiline,
    this.autovalidateMode = AutovalidateMode.disabled,
  }) : assert(
         controller == null || (value == null && defaultValue == null),
         'A controller cannot be combined with value or defaultValue.',
       );

  final TextEditingController? controller;
  final String? value,
      defaultValue,
      label,
      description,
      errorMessage,
      placeholder;
  final bool required,
      enabled,
      readOnly,
      enforceMaxLength,
      autoResize,
      clearable,
      obscureText,
      responsive;
  final Widget? prefixIcon, suffixIcon;
  final String? prefixText, suffixText;
  final int? maxGraphemeCount, maxLines, minLines;
  final ValueChanged<String>? onChanged, onSaved;
  final ValueChanged<SeedTextValueChange>? onValueChanged;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final Widget Function(BuildContext, TextEditingController, FocusNode)?
  inputBuilder;
  final FocusNode? focusNode;
  final SeedTextInputVariant variant;
  final SeedTextInputSize size;
  final double? maxHeight;
  final TextInputType? keyboardType;
  final AutovalidateMode autovalidateMode;
  @override
  State<SeedTextField> createState() => _SeedTextFieldState();
}

class _SeedTextFieldState extends State<SeedTextField> {
  late TextEditingController _controller;
  late String _controllerInitialText;
  final FocusNode _focusNode = FocusNode();
  final GlobalKey<FormFieldState<String>> _field = GlobalKey();
  @override
  void initState() {
    super.initState();
    _attach();
  }

  void _attach() {
    _controller =
        widget.controller ??
        TextEditingController(text: widget.value ?? widget.defaultValue);
    _controllerInitialText = _controller.text;
    _controller.addListener(_changed);
  }

  void _changed() {
    if (!mounted) return;
    setState(() {});
    _syncFormValue(_controller.text);
  }

  void _syncFormValue(String value) {
    // Controller listeners may run during build. Updating the enclosing Form
    // must wait until that frame completes, and superseded values are ignored.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _controller.text != value) return;
      final field = _field.currentState;
      if (field != null && field.value != value) field.didChange(value);
    });
  }

  void _syncControlledValue(String value) {
    _controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  @override
  void didUpdateWidget(SeedTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      final old = _controller;
      old.removeListener(_changed);
      _attach();
      if (oldWidget.controller == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
      }
    }
    if (widget.controller == null &&
        widget.value != null &&
        widget.value != _controller.text) {
      _syncControlledValue(widget.value!);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_changed);
    _focusNode.dispose();
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FormField<String>(
    key: _field,
    initialValue: _controller.text,
    enabled: widget.enabled,
    validator: widget.validator,
    onSaved: (_) => widget.onSaved?.call(_controller.text),
    onReset: () => _controller.text =
        widget.value ?? widget.defaultValue ?? _controllerInitialText,
    autovalidateMode: widget.autovalidateMode,
    builder: (field) {
      final count = _controller.text.characters.length;
      final over =
          widget.maxGraphemeCount != null && count > widget.maxGraphemeCount!;
      return SeedField(
        label: widget.label,
        disabled: !widget.enabled,
        readOnly: widget.readOnly,
        focusNode: widget.focusNode ?? _focusNode,
        helperText: widget.description,
        errorMessage: widget.errorMessage ?? field.errorText,
        required: widget.required,
        isInvalid: over || field.hasError || widget.errorMessage != null,
        characterCount: widget.maxGraphemeCount == null ? null : '$count',
        maxCharacterCount: widget.maxGraphemeCount?.toString(),
        child: SeedTextInput(
          controller: _controller,
          hintText: widget.placeholder,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          required: widget.required,
          focusNode: widget.focusNode ?? _focusNode,
          clearable: widget.clearable,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          variant: widget.variant,
          size: widget.size,
          responsive: widget.responsive,
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.suffixIcon,
          prefixText: widget.prefixText,
          suffixText: widget.suffixText,
          maxLength: widget.enforceMaxLength ? widget.maxGraphemeCount : null,
          maxGraphemeCount: widget.maxGraphemeCount,
          inputFormatters: widget.inputFormatters,
          inputBuilder: widget.inputBuilder,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          autoResize: widget.autoResize,
          maxHeight: widget.maxHeight,
          hasError: over || field.hasError || widget.errorMessage != null,
          onChanged: (value) {
            field.didChange(value);
            widget.onChanged?.call(value);
            if (widget.controller == null && widget.value != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted ||
                    widget.controller != null ||
                    widget.value == null) {
                  return;
                }
                if (_controller.text != widget.value) {
                  _syncControlledValue(widget.value!);
                }
              });
            }
          },
          onValueChanged: widget.onValueChanged,
        ),
      );
    },
  );
}

/// Field-shaped button with removable chips and external picker activation.
class SeedFieldButton extends StatefulWidget {
  const SeedFieldButton({
    super.key,
    this.values,
    this.defaultValues = const [],
    this.onValuesChanged,
    this.onPressed,
    this.label,
    this.description,
    this.errorMessage,
    this.placeholder,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.enabled = true,
    this.readOnly = false,
    this.showClear = false,
    this.size = SeedInputButtonSize.medium,
    this.required = false,
  });
  final List<String>? values;
  final List<String> defaultValues;
  final ValueChanged<List<String>>? onValuesChanged;
  final VoidCallback? onPressed;
  final String? label,
      description,
      errorMessage,
      placeholder,
      prefixText,
      suffixText;
  final Widget? prefixIcon, suffixIcon;
  final bool enabled, readOnly, showClear, required;
  final SeedInputButtonSize size;
  @override
  State<SeedFieldButton> createState() => _SeedFieldButtonState();
}

class _SeedFieldButtonState extends State<SeedFieldButton> {
  late List<String> _values = List.of(widget.defaultValues);
  List<String> get values => widget.values ?? _values;
  void update(List<String> next) {
    if (!widget.enabled || widget.readOnly) return;
    if (widget.values == null) setState(() => _values = next);
    widget.onValuesChanged?.call(List.unmodifiable(next));
  }

  @override
  Widget build(BuildContext context) => SeedField(
    label: widget.label,
    helperText: widget.description,
    errorMessage: widget.errorMessage,
    required: widget.required,
    child: SeedInputButton(
      value: values.join(', '),
      placeholder: widget.placeholder,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      isError: widget.errorMessage != null,
      prefixIcon: widget.prefixIcon,
      suffixIcon: widget.suffixIcon,
      prefixText: widget.prefixText,
      suffixText: widget.suffixText,
      size: widget.size,
      showClear: widget.showClear,
      onClear: () => update([]),
      onPressed: widget.onPressed,
      valueChild: values.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  for (var i = 0; i < values.length; i++)
                    SeedChip(
                      label: values[i],
                      onDeleted: widget.readOnly || !widget.enabled
                          ? null
                          : () => update(List.of(values)..removeAt(i)),
                    ),
                ],
              ),
            ),
    ),
  );
}
