import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';

import '../../localization/seed_localizations.dart';
import 'seed_field.dart';
import 'seed_text_input.dart';
import 'seed_input_button.dart';
import '../chip/seed_chip.dart';

/// Controlled/uncontrolled Form integration reusable with every SEED input.
///
/// [value] is authoritative when non-null or [controlled] is true. [FormFieldState.didChange]
/// proposals notify [onValueChanged] without committing parent-owned values.
class SeedFormField<T> extends FormField<T> {
  /// Creates a reusable Flutter FormField with optional parent ownership.
  /// [value] is authoritative when non-null or [controlled] is true (including
  /// a controlled null); otherwise [initialValue] seeds internal form state.
  /// [onValueChanged] receives proposed changes. [builder], [validator], [onSaved],
  /// [onReset], [enabled], [autovalidateMode], [forceErrorText] and [restorationId]
  /// have their Flutter FormField meanings.
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
    super.forceErrorText,
    super.restorationId,
  }) : super(initialValue: controlled ? value : value ?? initialValue);

  /// Includes a null [value] in parent-controlled state.
  final bool controlled;
  /// Parent-provided controlled value; null may be authoritative if [controlled] is true.
  final T? value;
  /// Called with each proposed form value, including controlled edits.
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
  /// Creates a SEED TextField with label, description and Flutter Form support.
  /// [value] is parent-controlled; [defaultValue] initializes an uncontrolled field.
  /// [controller] is externally owned and cannot accompany either value argument.
  /// [onValueChange] reports [SeedTextValueChange] (including sliced graphemes);
  /// [onValueChanged] is deprecated, and [onChanged] receives a plain string.
  /// [maxGraphemeCount] shows a counter and invalidates oversized input, while
  /// [enforceMaxLength] defaults to false, retaining the untruncated value.
  /// [required] controls the marker and semantics, not automatic validation.
  /// [validator], [onSaved], [onReset], [forceErrorText], [errorMessage]
  /// and [autovalidateMode] integrate with [Form].
  /// [labelWeight], [indicator], [description] and [placeholder] match React.
  /// [clearable] and other native keyboard, selection, focus, restoration,
  /// formatter and editing options are Flutter composition extensions.
  /// Defaults: outline, large, enabled, one line, non-resizing.
  const SeedTextField({
    super.key,
    this.controller,
    this.value,
    this.defaultValue,
    this.label,
    this.labelWeight = SeedFieldLabelWeight.medium,
    this.description,
    this.errorMessage,
    this.required = false,
    this.indicator,
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
    ValueChanged<SeedTextValueChange>? onValueChange,
    @Deprecated('Use onValueChange instead.')
    ValueChanged<SeedTextValueChange>? onValueChanged,
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
    this.clearable = false,
    this.obscureText = false,
    this.keyboardType,
    this.autofillHints,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.textCapitalization = TextCapitalization.none,
    this.restorationId,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.scrollPadding = const EdgeInsets.all(20),
    this.onTapOutside,
    this.onTap,
    this.onEditingComplete,
    this.cursorColor,
    this.enableInteractiveSelection,
    this.selectionControls,
    this.contextMenuBuilder = SeedTextInput.defaultContextMenuBuilder,
    this.smartDashesType,
    this.smartQuotesType,
    this.undoController,
    this.canRequestFocus = true,
    this.maxLengthEnforcement,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.textInputAction,
    this.onFieldSubmitted,
    this.autofocus = false,
    this.onReset,
    this.forceErrorText,
  }) : onValueChanged = onValueChange ?? onValueChanged,
       assert(onValueChange == null || onValueChanged == null),
       assert(
         controller == null || (value == null && defaultValue == null),
         'A controller cannot be combined with value or defaultValue.',
       );

  /// Creates a multiline textarea field that auto-resizes by default,
  /// matching React's `<TextFieldTextarea>`.
  /// Creates a multiline TextField in the React TextFieldTextarea style.
  /// Unlike the default constructor, [autoResize] defaults true, [maxLines]
  /// defaults null and [keyboardType] defaults to multiline. All controlled,
  /// validation, callback and Flutter input settings otherwise match [SeedTextField].
  const SeedTextField.textarea({
    super.key,
    this.controller,
    this.value,
    this.defaultValue,
    this.label,
    this.labelWeight = SeedFieldLabelWeight.medium,
    this.description,
    this.errorMessage,
    this.required = false,
    this.indicator,
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
    ValueChanged<SeedTextValueChange>? onValueChange,
    @Deprecated('Use onValueChange instead.')
    ValueChanged<SeedTextValueChange>? onValueChanged,
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
    this.autofillHints,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.textCapitalization = TextCapitalization.none,
    this.restorationId,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.scrollPadding = const EdgeInsets.all(20),
    this.onTapOutside,
    this.onTap,
    this.onEditingComplete,
    this.cursorColor,
    this.enableInteractiveSelection,
    this.selectionControls,
    this.contextMenuBuilder = SeedTextInput.defaultContextMenuBuilder,
    this.smartDashesType,
    this.smartQuotesType,
    this.undoController,
    this.canRequestFocus = true,
    this.maxLengthEnforcement,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.textInputAction,
    this.onFieldSubmitted,
    this.autofocus = false,
    this.onReset,
    this.forceErrorText,
  }) : onValueChanged = onValueChange ?? onValueChanged,
       assert(onValueChange == null || onValueChanged == null),
       assert(
         controller == null || (value == null && defaultValue == null),
         'A controller cannot be combined with value or defaultValue.',
       );

  /// Externally owned text controller, mutually exclusive with [value]
  /// and [defaultValue]. Its text drives counter, validation and save behavior.
  final TextEditingController? controller;
  /// Value and display texts: [value] is controlled, [defaultValue] is
  /// an initial uncontrolled seed, [label] names the field, [description] provides
  /// helper text, [errorMessage] forces a Form error, and [placeholder] hints text.
  final String? value,
      defaultValue,
      label,
      description,
      errorMessage,
      placeholder;

  /// Text beside the label, as React TextField's `indicator`.
  final String? indicator;
  /// Field and editor flags: [required] shows semantics and a required mark;
  /// [enabled] allows typing; [readOnly] protects content; [enforceMaxLength]
  /// opts into Flutter length enforcement; [autoResize] grows the editor;
  /// [clearable] adds a Flutter clear button; [obscureText] hides input; and
  /// [responsive] enables the 1280px size breakpoint. All except enabled
  /// default false; enabled defaults true.
  final bool required,
      enabled,
      readOnly,
      enforceMaxLength,
      autoResize,
      clearable,
      obscureText,
      responsive;
  /// Icons decorating the editable text before and after its value.
  final Widget? prefixIcon, suffixIcon;
  /// Optional leading and trailing inline text.
  final String? prefixText, suffixText;
  /// Optional Unicode grapheme maximum and text line bounds.
  /// [maxGraphemeCount] drives the counter and form validation independently
  /// from [enforceMaxLength]. Default maxLines is 1, or null for textarea.
  final int? maxGraphemeCount, maxLines, minLines;
  /// Callbacks for user text edits and Flutter Form save, respectively.
  /// [onSaved] receives the live controller text.
  final ValueChanged<String>? onChanged, onSaved;
  @Deprecated('Use onValueChange instead.')
  /// Deprecated callback name; use [onValueChange].
  final ValueChanged<SeedTextValueChange>? onValueChanged;
  /// React-aligned grapheme callback with full and sliced value information.
  /// The original string is never truncated merely by this callback.
  ValueChanged<SeedTextValueChange>? get onValueChange => onValueChanged;
  /// Optional Form validation callback; grapheme-count validation also applies.
  /// The required marker alone does not install a nonempty-value validator.
  final FormFieldValidator<String>? validator;
  /// Flutter text edit formatters applied before change callbacks.
  final List<TextInputFormatter>? inputFormatters;
  /// Flutter custom editor builder receiving context, current controller
  /// and focus node in place of the built-in [SeedTextInput].
  final Widget Function(BuildContext, TextEditingController, FocusNode)?
  inputBuilder;
  /// Externally owned focus node, or null for an internal focus node.
  final FocusNode? focusNode;
  /// Input outline/underline appearance; defaults to outline.
  final SeedTextInputVariant variant;
  /// Input size; defaults to large.
  final SeedTextInputSize size;
  /// Maximum text editor height, chiefly useful for textarea inputs.
  final double? maxHeight;
  /// Flutter keyboard type (textarea defaults to multiline).
  final TextInputType? keyboardType;
  /// Flutter Form validation timing (default disabled).
  final AutovalidateMode autovalidateMode;
  /// Platform IME action sent to the inner editor.
  final TextInputAction? textInputAction;
  /// User submit callback forwarded to the inner text editor.
  final ValueChanged<String>? onFieldSubmitted;
  /// Whether the editor requests focus on mount (default false).
  final bool autofocus;
  /// Callback after Form reset restores the controlled/default/initial text.
  final VoidCallback? onReset;
  /// Flutter Form forced-error override, taking precedence over [errorMessage].
  /// When removed, ordinary [validator] outcomes apply again.
  final String? forceErrorText;
  // Flutter input extensions, independent of React value ownership.
  /// Flutter autofill hints for the inner editor.
  final Iterable<String>? autofillHints;
  /// Enable Flutter keyboard autocorrection (default true).
  final bool autocorrect;
  /// Enable platform suggestions (default true).
  final bool enableSuggestions;
  /// Text capitalization policy (default none).
  final TextCapitalization textCapitalization;
  /// Flutter state restoration ID for text editing.
  final String? restorationId;
  /// Editable text alignment (default start).
  final TextAlign textAlign;
  /// Explicit direction override for entered text.
  final TextDirection? textDirection;
  /// Keyboard-reveal scrolling padding (20 logical pixels per edge by default).
  final EdgeInsets scrollPadding;
  /// Flutter tap-outside callback forwarded to [SeedTextInput].
  final TapRegionCallback? onTapOutside;
  /// Callback fired on a text editor tap.
  final VoidCallback? onTap;
  /// Flutter editing-completion callback.
  final VoidCallback? onEditingComplete;
  /// Cursor color override for the editor.
  final Color? cursorColor;
  /// Whether Flutter text selection gestures and actions are available.
  final bool? enableInteractiveSelection;
  /// Custom Flutter text selection controls.
  final TextSelectionControls? selectionControls;
  /// Custom text selection context menu builder.
  /// Defaults to [SeedTextInput.defaultContextMenuBuilder]; null disables it.
  final EditableTextContextMenuBuilder? contextMenuBuilder;
  /// Flutter automatic dash substitution mode.
  final SmartDashesType? smartDashesType;
  /// Flutter automatic quote substitution mode.
  final SmartQuotesType? smartQuotesType;
  /// External Flutter undo history controller.
  final UndoHistoryController? undoController;
  /// Whether the editor is focusable (default true).
  final bool canRequestFocus;
  /// Flutter enforcement policy when [enforceMaxLength] supplies maxLength.
  final MaxLengthEnforcement? maxLengthEnforcement;

  /// The official `labelWeight`.
  final SeedFieldLabelWeight labelWeight;

  @override
  State<SeedTextField> createState() => _SeedTextFieldState();
}

class _SeedTextFieldState extends State<SeedTextField> with RestorationMixin {
  late final RestorableTextEditingController _restorableController;
  bool _controllerRegistered = false;
  bool _resetting = false;
  @override
  String? get restorationId => widget.restorationId;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    _controller.removeListener(_changed);
    if (widget.controller == null && !_controllerRegistered) {
      _controller.dispose();
    }
    registerForRestoration(_restorableController, 'text');
    _controllerRegistered = true;
    if (widget.controller == null) {
      _controller = _restorableController.value;
      if (widget.value != null) _controller.text = widget.value!;
    }
    _controller.addListener(_changed);
    _syncFormValue(_controller.text);
  }

  late TextEditingController _controller;
  late String _controllerInitialText;
  final FocusNode _focusNode = FocusNode();
  final GlobalKey<FormFieldState<String>> _field = GlobalKey();
  @override
  void initState() {
    super.initState();
    _restorableController = RestorableTextEditingController(
      text: widget.value ?? widget.defaultValue,
    );
    _attach();
  }

  void _attach() {
    _controller =
        widget.controller ??
        (_controllerRegistered
            ? _restorableController.value
            : TextEditingController(text: widget.value ?? widget.defaultValue));
    _controllerInitialText = _controller.text;
    _controller.addListener(_changed);
  }

  void _changed() {
    if (!mounted) return;
    setState(() {});
    _syncFormValue(_controller.text);
  }

  void _syncFormValue(String value) {
    if (_resetting) return;
    if (SchedulerBinding.instance.schedulerPhase !=
        SchedulerPhase.persistentCallbacks) {
      final field = _field.currentState;
      if (field != null && field.value != value) field.didChange(value);
      return;
    }
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
      if (widget.controller == null) {
        _restorableController.value.value = old.value;
      }
      _attach();
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
    _restorableController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      UnmanagedRestorationScope(bucket: bucket, child: _buildField(context));

  Widget _buildField(BuildContext context) => FormField<String>(
    key: _field,
    initialValue: widget.value ?? widget.defaultValue ?? _controllerInitialText,
    enabled: widget.enabled,
    forceErrorText: widget.forceErrorText ?? widget.errorMessage,
    validator: (value) {
      final currentValue = _controller.text;
      final error = widget.validator?.call(currentValue);
      if (error != null) return error;
      if (widget.maxGraphemeCount != null &&
          currentValue.characters.length > widget.maxGraphemeCount!) {
        return SeedLocalizations.label(
          context,
          SeedLabel.maxLengthExceeded,
        ).replaceAll('{max}', '${widget.maxGraphemeCount}');
      }
      return null;
    },
    onSaved: (_) => widget.onSaved?.call(_controller.text),
    onReset: () {
      _resetting = true;
      try {
        _controller.text =
            widget.value ?? widget.defaultValue ?? _controllerInitialText;
      } finally {
        _resetting = false;
      }
      widget.onReset?.call();
    },
    autovalidateMode: widget.autovalidateMode,
    builder: (field) {
      final count = _controller.text.characters.length;
      final over =
          widget.maxGraphemeCount != null && count > widget.maxGraphemeCount!;
      return SeedField(
        label: widget.label,
        labelWeight: widget.labelWeight,
        indicatorText: widget.indicator,
        disabled: !widget.enabled,
        readOnly: widget.readOnly,
        focusNode: widget.focusNode ?? _focusNode,
        helperText: widget.description,
        errorMessage: field.errorText ?? widget.errorMessage,
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
          textInputAction: widget.textInputAction,
          onSubmitted: widget.onFieldSubmitted,
          autofocus: widget.autofocus,
          autofillHints: widget.autofillHints,
          autocorrect: widget.autocorrect,
          enableSuggestions: widget.enableSuggestions,
          textCapitalization: widget.textCapitalization,
          restorationId: widget.restorationId,
          textAlign: widget.textAlign,
          textDirection: widget.textDirection,
          scrollPadding: widget.scrollPadding,
          onTapOutside: widget.onTapOutside,
          onTap: widget.onTap,
          onEditingComplete: widget.onEditingComplete,
          cursorColor: widget.cursorColor,
          enableInteractiveSelection: widget.enableInteractiveSelection,
          selectionControls: widget.selectionControls,
          contextMenuBuilder: widget.contextMenuBuilder,
          smartDashesType: widget.smartDashesType,
          smartQuotesType: widget.smartQuotesType,
          undoController: widget.undoController,
          canRequestFocus: widget.canRequestFocus,
          maxLengthEnforcement: widget.maxLengthEnforcement,

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
            if (field.value != value) field.didChange(value);
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
  /// Creates an input-shaped picker trigger with optional removable value chips.
  /// [values] is controlled; [defaultValues] seeds internal state and is a
  /// Flutter extension. [onValuesChange] receives immutable proposed lists,
  /// while deprecated [onValuesChanged] is its alias. [onPressed] opens
  /// application-owned pickers; it does not populate choices by itself.
  /// [label], [description], [errorMessage], [placeholder], [labelWeight]
  /// and [required] configure the surrounding Field. [prefixIcon], [suffixIcon],
  /// [prefixText] and [suffixText] decorate the trigger. [showValueChips] is a
  /// Flutter extension (default true); false displays comma-separated values.
  /// [showClear] defaults false; [enabled] true; [readOnly] false; [size] large.
  const SeedFieldButton({
    super.key,
    this.values,
    this.defaultValues = const [],
    ValueChanged<List<String>>? onValuesChange,
    @Deprecated('Use onValuesChange instead.')
    ValueChanged<List<String>>? onValuesChanged,
    this.onPressed,
    this.label,
    this.labelWeight = SeedFieldLabelWeight.medium,
    this.description,
    this.errorMessage,
    this.placeholder,
    this.showValueChips = true,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.enabled = true,
    this.readOnly = false,
    this.showClear = false,
    this.size = SeedInputButtonSize.large,
    this.required = false,
  }) : onValuesChanged = onValuesChange ?? onValuesChanged,
       assert(onValuesChange == null || onValuesChanged == null);
  /// Parent-controlled selected values; null uses internal [defaultValues] state.
  final List<String>? values;
  /// Initial uncontrolled selections, a Flutter-only extension (default empty).
  final List<String> defaultValues;
  @Deprecated('Use onValuesChange instead.')
  /// Deprecated callback alias for [onValuesChange].
  final ValueChanged<List<String>>? onValuesChanged;
  /// React-style callback receiving the proposed list of selected values.
  ValueChanged<List<String>>? get onValuesChange => onValuesChanged;
  /// Called when the trigger is activated to open an app-owned selection UI.
  final VoidCallback? onPressed;
  /// Field/trigger text options: [label] is the accessible field name,
  /// [description] is helper text, [errorMessage] drives invalid styling,
  /// [placeholder] appears when empty, and [prefixText]/[suffixText] frame values.
  final String? label,
      description,
      errorMessage,
      placeholder,
      prefixText,
      suffixText;

  /// Flutter extension: removable chips. False shows the values as plain text,
  /// like React's `FieldButtonValue`.
  final bool showValueChips;
  /// Icons decorating the picker trigger before and after its value.
  final Widget? prefixIcon, suffixIcon;
  /// Control flags: enabled permits interaction (default true); readOnly
  /// blocks editing (default false); showClear exposes clearing when values
  /// exist (default false); required shows a marker (default false).
  final bool enabled, readOnly, showClear, required;
  /// Input trigger size, default large at 52 logical pixels.
  final SeedInputButtonSize size;

  /// The official `labelWeight`.
  final SeedFieldLabelWeight labelWeight;

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
    labelWeight: widget.labelWeight,
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
      // The official FieldButton renders a suffix icon only when one is given.
      showDefaultSuffix: false,
      prefixText: widget.prefixText,
      suffixText: widget.suffixText,
      size: widget.size,
      showClear: widget.showClear,
      onClear: () => update([]),
      onPressed: widget.onPressed,
      valueChild: values.isEmpty || !widget.showValueChips
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
