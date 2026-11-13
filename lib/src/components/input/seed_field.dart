import '../../localization/seed_localizations.dart';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/semantics.dart' show SemanticsValidationResult;

import '../../foundations/dimensions/seed_dimension.dart';
import '../../theme/seed_theme.dart';
import 'seed_required_indicator.dart';

/// Weight for [SeedField] label.
/// The [medium] weight is the default; [bold] emphasizes labels.
enum SeedFieldLabelWeight {
  /// Medium weight, used by default.
  medium,

  /// Bold label weight.
  bold,
}

/// Shared state for SEED inputs inside a [SeedField]. Custom inputs can read
/// this scope to apply the same disabled, read-only and invalid policy.
class SeedFieldScope extends InheritedWidget {
  /// Shares the parent Field's presentation and interaction state with child inputs.
  /// [disabled], [readOnly] and [isInvalid] are required; [required] defaults
  /// to false. [name] identifies the field, [label] names its control, and
  /// [focusNode] and registration callbacks connect label taps with focus.
  const SeedFieldScope({
    super.key,
    required this.disabled,
    required this.readOnly,
    required this.isInvalid,
    this.required = false,
    this.name,
    this.label,
    this.focusNode,
    this.registerFocusNode,
    this.unregisterFocusNode,
    required super.child,
  });

  /// Inherited interaction, validation, and required states.
  ///
  /// The required flag is semantic; it does not install a validator.
  final bool disabled, readOnly, isInvalid, required;

  /// Optional identifier inherited by child controls.
  final String? name;

  /// The field label, which names a button-like control (React `<label for>`).
  /// Visible label inherited for input accessibility names.
  final String? label;

  /// Optional input focus target.
  final FocusNode? focusNode;

  /// Callbacks that register and unregister child focus nodes.
  final ValueChanged<FocusNode>? registerFocusNode, unregisterFocusNode;

  /// Reads the nearest [SeedFieldScope], returning null when outside a Field.
  static SeedFieldScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SeedFieldScope>();
  @override
  /// Notifies inputs when inherited state or focus metadata changes.
  bool updateShouldNotify(SeedFieldScope oldWidget) =>
      disabled != oldWidget.disabled ||
      readOnly != oldWidget.readOnly ||
      isInvalid != oldWidget.isInvalid ||
      required != oldWidget.required ||
      name != oldWidget.name ||
      label != oldWidget.label ||
      focusNode != oldWidget.focusNode;
}

/// Field container component of SEED Design System.
///
/// Wraps input elements with standard Header (label, requirement mark, sub-actions)
/// and Footer (helper text, error message, character count).
class SeedField extends StatefulWidget {
  /// Optional displayed field label; tapping it forwards focus to a child.
  final String? label;

  /// Label font weight; defaults to medium.
  final SeedFieldLabelWeight labelWeight;

  /// Shows a required marker and required semantics (default false).
  final bool required;

  /// Overrides the required marker visibility independently of [required].
  /// Null preserves the existing behavior of showing it when required.
  final bool? showRequiredIndicator;

  /// Shows the localized optional label suffix (default false).
  final bool optional;

  /// Custom widget replacing the required mark.
  final Widget? indicator;

  /// Text beside the label, such as React's `Field.IndicatorText`.
  final String? indicatorText;

  /// Optional header action opposite the label.
  final Widget? subAction;

  /// Required input or custom control body.
  final Widget child;

  /// React's `description`; [helperText] is the Material-style alias.
  final String? helperText;

  /// Official description getter alias for [helperText].
  String? get description => helperText;

  /// Optional icon preceding the helper description.
  final Widget? descriptionIcon;

  /// Validation message displayed below the control.
  final String? errorMessage;

  /// Icon preceding an error message, replacing the default critical icon.
  final Widget? errorIcon;

  /// Current character count displayed in the footer.
  final String? characterCount;

  /// Maximum count displayed after [characterCount].
  final String? maxCharacterCount;

  /// Legacy stored invalid flag; prefer [invalid].
  @Deprecated('Use invalid instead.')
  final bool isInvalid;

  /// React-aligned name for the deprecated [isInvalid] field.
  bool get invalid => isInvalid;

  /// Disabled/read-only modes inherited by child controls; default false.
  final bool disabled, readOnly;

  /// Optional semantic identifier for the input body.
  final String? name;

  /// Optional focus target used when tapping the field label.
  final FocusNode? focusNode;

  /// Creates a SEED Field composition around required [child].
  /// [label], [labelWeight], [required], [optional], [indicator],
  /// [indicatorText] and [subAction] configure the header. [description] is
  /// the official text and [helperText] its Material-style alias.
  /// [descriptionIcon], [errorMessage], [errorIcon], [characterCount] and
  /// [maxCharacterCount] configure the footer. [invalid] replaces [isInvalid].
  /// [disabled], [readOnly], [name] and [focusNode] propagate control
  /// semantics and label focus. Required indicates requirement visually and
  /// accessibly; callers must separately provide actual validation.
  const SeedField({
    super.key,
    this.label,
    this.labelWeight = SeedFieldLabelWeight.medium,
    this.required = false,
    this.showRequiredIndicator,
    this.optional = false,
    this.indicator,
    this.indicatorText,
    this.subAction,
    required this.child,
    String? description,
    String? helperText,
    this.descriptionIcon,
    this.errorMessage,
    this.errorIcon,
    this.characterCount,
    this.maxCharacterCount,
    bool? invalid,
    @Deprecated('Use invalid instead.') bool? isInvalid,
    this.disabled = false,
    this.readOnly = false,
    this.name,
    this.focusNode,
  }) : isInvalid = invalid ?? isInvalid ?? false,
       assert(invalid == null || isInvalid == null),
       helperText = description ?? helperText,
       assert(description == null || helperText == null);

  @override
  State<SeedField> createState() => _SeedFieldState();

  Widget _build(
    BuildContext context,
    FocusNode effectiveFocusNode,
    VoidCallback focusInput,
    _SeedFieldState state,
  ) {
    final colors = context.seedColor;
    final typography = context.seedTypography;
    final textScaler = MediaQuery.textScalerOf(context);

    final bool showRequired = showRequiredIndicator ?? required;
    final descriptions = [?helperText, ?errorMessage];
    final bool hasHeader =
        label != null || subAction != null || indicatorText != null || optional;
    final bool hasFooter =
        errorMessage != null ||
        helperText != null ||
        characterCount != null ||
        maxCharacterCount != null;

    final TextStyle labelStyle =
        (labelWeight == SeedFieldLabelWeight.bold
                ? typography.t5Bold
                : typography.t5Medium)
            .copyWith(color: colors.fg.neutral);

    return SeedFieldScope(
      disabled: disabled,
      readOnly: readOnly,
      isInvalid: isInvalid || errorMessage != null,
      required: required,
      name: name,
      label: label,
      focusNode: effectiveFocusNode,
      registerFocusNode: state._register,
      unregisterFocusNode: state._unregister,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasHeader) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SeedDimension.x0_5,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      // The required mark is offset from the label's top edge.
                      crossAxisAlignment: showRequired
                          ? CrossAxisAlignment.start
                          : CrossAxisAlignment.center,
                      children: [
                        if (label != null)
                          Flexible(
                            child: GestureDetector(
                              onTap: disabled ? null : focusInput,
                              // Like a <label>, the tap only forwards focus;
                              // the input already carries this name.
                              excludeFromSemantics: true,
                              child: ExcludeSemantics(
                                child: Text(
                                  label!,
                                  style: labelStyle,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        if (showRequired) ...[
                          Padding(
                            padding: EdgeInsets.only(
                              left: textScaler.scale(2.0),
                              top: textScaler.scale(4.0),
                            ),
                            child:
                                indicator ??
                                Semantics(
                                  label: SeedLocalizations.label(
                                    context,
                                    SeedLabel.requiredInput,
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Retained for screen reader and widget test query compatibility
                                      const Opacity(
                                        opacity: 0,
                                        child: SizedBox(
                                          width: 0,
                                          height: 0,
                                          child: Text(
                                            '*',
                                            style: TextStyle(fontSize: 0),
                                          ),
                                        ),
                                      ),
                                      CustomPaint(
                                        size: Size.square(
                                          textScaler.scale(6.0),
                                        ),
                                        painter: SeedRequiredIndicatorPainter(
                                          colors.fg.critical,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                          ),
                        ],
                        if (indicatorText != null || optional) ...[
                          const SizedBox(width: SeedDimension.x1),
                          Text(
                            indicatorText ??
                                SeedLocalizations.label(
                                  context,
                                  SeedLabel.optionalInput,
                                ),
                            style: typography.t4Regular.copyWith(
                              height: 22 / 14,
                              color: colors.fg.neutralSubtle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (subAction != null) ...[
                    const SizedBox(width: SeedDimension.x2_5),
                    subAction!,
                  ],
                ],
              ),
            ),
            const SizedBox(height: SeedDimension.x2),
          ],
          Semantics(
            identifier: name,
            label: label,
            hint: descriptions.isEmpty ? null : descriptions.join('\n'),
            isRequired: required,
            validationResult: isInvalid || errorMessage != null
                ? SemanticsValidationResult.invalid
                : SemanticsValidationResult.none,
            child: child,
          ),
          if (hasFooter) ...[
            const SizedBox(height: SeedDimension.x2),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SeedDimension.x0_5,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: errorMessage != null
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Centers the icon on the first line of text.
                              Padding(
                                padding: EdgeInsets.only(
                                  top: textScaler.scale(1.5),
                                ),
                                child: IconTheme(
                                  data: IconThemeData(
                                    color: colors.fg.critical,
                                    size: SeedDimension.x4,
                                  ),
                                  child: errorIcon ?? const Icon(Icons.error),
                                ),
                              ),
                              const SizedBox(width: SeedDimension.x1_5),
                              Expanded(
                                child: Semantics(
                                  liveRegion: true,
                                  child: Text(
                                    errorMessage!,
                                    style: typography.t4Regular.copyWith(
                                      color: colors.fg.critical,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : helperText != null
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (descriptionIcon != null) ...[
                                IconTheme(
                                  data: IconThemeData(
                                    color: colors.fg.neutralSubtle,
                                    size: SeedDimension.x4,
                                  ),
                                  child: descriptionIcon!,
                                ),
                                const SizedBox(width: SeedDimension.x1_5),
                              ],
                              Expanded(
                                child: Text(
                                  helperText!,
                                  style: typography.t4Regular.copyWith(
                                    color: colors.fg.neutralSubtle,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                  if (characterCount != null || maxCharacterCount != null) ...[
                    const SizedBox(width: SeedDimension.x2),
                    Text.rich(
                      TextSpan(
                        children: [
                          if (characterCount != null)
                            TextSpan(
                              text: characterCount,
                              style: typography.t4Regular.copyWith(
                                color: isInvalid || errorMessage != null
                                    ? colors.fg.critical
                                    : int.tryParse(characterCount ?? '') == 0
                                    ? colors.fg.neutralSubtle
                                    : colors.fg.neutral,
                              ),
                            ),
                          if (maxCharacterCount != null)
                            TextSpan(
                              text: '/$maxCharacterCount',
                              style: typography.t4Regular.copyWith(
                                color: isInvalid || errorMessage != null
                                    ? colors.fg.critical
                                    : colors.fg.neutralSubtle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The official Field.RequiredIndicator asterisk, in its 6 x 6 viewBox.
class _SeedFieldState extends State<SeedField> {
  final FocusNode _focusNode = FocusNode();
  final Set<FocusNode> _inputs = {};

  void _register(FocusNode node) => _inputs.add(node);
  void _unregister(FocusNode node) => _inputs.remove(node);

  void _focusInput() {
    if (widget.disabled) return;
    final node =
        widget.focusNode ??
        _inputs.where((node) => node.canRequestFocus).firstOrNull ??
        _focusNode;
    node.requestFocus();
  }

  @override
  Widget build(BuildContext context) =>
      widget._build(context, widget.focusNode ?? _focusNode, _focusInput, this);

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}
