import 'package:material_ui/material_ui.dart';

/// Internal value holder for components with official uncontrolled defaults.
///
/// Unlike a [FormField], it never registers with an enclosing [Form], so
/// `Form.reset()` and `Form.save()` leave the component alone. Wrap the
/// component in a `SeedFormField` to opt into Form behavior.
/// While [controlled] is true, [value] is shown and remembered, so the holder
/// resumes from the last controlled value if the parent stops controlling it.
class SeedUncontrolledValue<T> extends StatefulWidget {
  /// Initial value used until the component changes it.
  final T initialValue;

  /// Shows [value] instead of the held value.
  final bool controlled;

  /// Parent-provided value used while [controlled] is true.
  final T? value;

  /// Builds the component with the current value and a setter for local edits.
  final Widget Function(BuildContext context, T value, ValueChanged<T> setValue)
  builder;

  /// Creates a holder that starts from [initialValue].
  const SeedUncontrolledValue({
    super.key,
    required this.initialValue,
    required this.builder,
    this.controlled = false,
    this.value,
  });

  @override
  State<SeedUncontrolledValue<T>> createState() =>
      _SeedUncontrolledValueState<T>();
}

class _SeedUncontrolledValueState<T> extends State<SeedUncontrolledValue<T>> {
  late T _value = widget.controlled ? widget.value as T : widget.initialValue;

  @override
  void didUpdateWidget(SeedUncontrolledValue<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controlled) _value = widget.value as T;
  }

  void _setValue(T value) {
    if (!mounted || widget.controlled) return;
    setState(() => _value = value);
  }

  @override
  Widget build(BuildContext context) => widget.builder(
    context,
    widget.controlled ? widget.value as T : _value,
    _setValue,
  );
}
