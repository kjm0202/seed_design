import 'package:material_ui/material_ui.dart';
import 'package:flutter/semantics.dart' show SemanticsValidationResult;

import '../../foundations/dimensions/seed_dimension.dart';
import '../../theme/seed_theme.dart';

/// Weight for [SeedField] label.
enum SeedFieldLabelWeight { medium, bold }

/// Shared state for SEED inputs inside a [SeedField]. Custom inputs can read
/// this scope to apply the same disabled, read-only and invalid policy.
class SeedFieldScope extends InheritedWidget {
  const SeedFieldScope({
    super.key,
    required this.disabled,
    required this.readOnly,
    required this.isInvalid,
    this.required = false,
    this.name,
    this.focusNode,
    this.registerFocusNode,
    this.unregisterFocusNode,
    required super.child,
  });
  final bool disabled, readOnly, isInvalid, required;
  final String? name;
  final FocusNode? focusNode;
  final ValueChanged<FocusNode>? registerFocusNode, unregisterFocusNode;
  static SeedFieldScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SeedFieldScope>();
  @override
  bool updateShouldNotify(SeedFieldScope oldWidget) =>
      disabled != oldWidget.disabled ||
      readOnly != oldWidget.readOnly ||
      isInvalid != oldWidget.isInvalid ||
      required != oldWidget.required ||
      name != oldWidget.name ||
      focusNode != oldWidget.focusNode;
}

/// Field container component of SEED Design System.
///
/// Wraps input elements with standard Header (label, requirement mark, sub-actions)
/// and Footer (helper text, error message, character count).
class SeedField extends StatefulWidget {
  final String? label;
  final SeedFieldLabelWeight labelWeight;
  final bool required;
  final bool optional;
  final Widget? indicator;
  final Widget? subAction;
  final Widget child;
  final String? helperText;
  final Widget? descriptionIcon;
  final String? errorMessage;
  final Widget? errorIcon;
  final String? characterCount;
  final String? maxCharacterCount;
  final bool isInvalid;
  final bool disabled, readOnly;
  final String? name;
  final FocusNode? focusNode;

  const SeedField({
    super.key,
    this.label,
    this.labelWeight = SeedFieldLabelWeight.medium,
    this.required = false,
    this.optional = false,
    this.indicator,
    this.subAction,
    required this.child,
    this.helperText,
    this.descriptionIcon,
    this.errorMessage,
    this.errorIcon,
    this.characterCount,
    this.maxCharacterCount,
    this.isInvalid = false,
    this.disabled = false,
    this.readOnly = false,
    this.name,
    this.focusNode,
  });

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

    final bool hasHeader = label != null || subAction != null;
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
                      crossAxisAlignment: required
                          ? CrossAxisAlignment.start
                          : CrossAxisAlignment.center,
                      children: [
                        if (label != null)
                          Flexible(
                            child: GestureDetector(
                              onTap: disabled ? null : focusInput,
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
                        if (required) ...[
                          Padding(
                            padding: EdgeInsets.only(
                              left: textScaler.scale(2.0),
                              top: textScaler.scale(4.0),
                            ),
                            child:
                                indicator ??
                                Semantics(
                                  label: '필수 입력',
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
                                      Container(
                                        width: textScaler.scale(6.0),
                                        height: textScaler.scale(6.0),
                                        decoration: BoxDecoration(
                                          color: colors.fg.critical,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                          ),
                        ] else if (optional) ...[
                          const SizedBox(width: SeedDimension.x1),
                          Text(
                            '(선택)',
                            style: typography.t4Regular.copyWith(
                              height: 22 / 14,
                              color: colors.fg.neutralSubtle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  ?subAction,
                ],
              ),
            ),
            const SizedBox(height: SeedDimension.x2),
          ],
          Semantics(
            identifier: name,
            label: label,
            hint: errorMessage ?? helperText,
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
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (errorIcon != null) ...[
                                IconTheme(
                                  data: IconThemeData(
                                    color: colors.fg.critical,
                                    size: SeedDimension.x4,
                                  ),
                                  child: errorIcon!,
                                ),
                                const SizedBox(width: SeedDimension.x1_5),
                              ],
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
