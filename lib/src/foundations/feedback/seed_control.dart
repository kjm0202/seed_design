import 'package:material_ui/material_ui.dart';

import '../../components/input/seed_required_indicator.dart';
import '../../localization/seed_localizations.dart';
import '../../theme/seed_theme.dart';
import '../dimensions/seed_dimension.dart';

/// Color emphasis used by SEED controls, independent of enabled state.
enum SeedControlTone {
  /// Default neutral control treatment.
  neutral,

  /// Brand-accented control treatment.
  brand,
}

/// Font-weight emphasis used for SEED control labels.
enum SeedLabelWeight {
  /// Regular-weight label.
  regular,

  /// Emphasized bold label.
  bold,
}

/// A labelled group whose disabled state reaches participating SEED controls.
class SeedFieldset extends StatelessWidget {
  /// Groups a SEED control with optional [label], [description], and [indicator].
  ///
  /// [labelBold] defaults to false and uses a bold label. [required] adds the
  /// official Field required mark after the label. [enabled] defaults to true
  /// and disables controls that consume [SeedControlScope] when false; [child]
  /// is required. Arbitrary Flutter widgets do not inherit this state.
  const SeedFieldset({
    super.key,
    this.label,
    this.labelBold = false,
    this.description,
    this.errorMessage,
    this.errorIcon,
    this.indicator,
    this.required = false,
    this.enabled = true,
    required this.child,
  });

  /// Optional fieldset legend, painted as a t5 label and exposed on the group Semantics node.
  final String? label;

  /// The official field label is t5 medium, or bold through `labelWeight`.
  final bool labelBold;

  /// Optional help copy, painted in the footer below [child] like the
  /// official Field description (t4 regular, fg.neutralSubtle).
  final String? description;

  /// Optional group error, as with React's `Fieldset.ErrorMessage`.
  ///
  /// When non-null it replaces [description] in the footer, is painted in
  /// `fg.critical` with [errorIcon], and is announced politely when it
  /// appears or changes. Errors of individual controls inside [child] are
  /// independent and unaffected. Like the official fieldset, the group
  /// itself is not marked invalid; the message describes it.
  final String? errorMessage;

  /// Optional icon before [errorMessage]; defaults to the Field error icon.
  final Widget? errorIcon;

  /// Optional trailing widget in the label row, such as indicator text.
  final Widget? indicator;

  /// Shows the official Field required mark after the label (default false).
  final bool required;

  /// Whether controls inside this fieldset are enabled.
  ///
  /// Defaults to true and composes with any ancestor [SeedControlScope].
  final bool enabled;

  /// The grouped field control content.
  final Widget child;

  /// Builds the semantic legend, description, and disabled-state scope around [child].
  @override
  Widget build(BuildContext context) {
    final typography = context.seedTypography;
    final colors = context.seedColor;
    final textScaler = MediaQuery.textScalerOf(context);
    return SeedControlScope(
      enabled: enabled && SeedControlScope.enabledOf(context),
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        label: label,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (label != null || indicator != null || required)
              Padding(
                padding: const EdgeInsets.only(bottom: SeedDimension.x2),
                child: Row(
                  crossAxisAlignment: required
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.center,
                  children: [
                    if (label != null)
                      Flexible(
                        child: ExcludeSemantics(
                          child: Text(
                            label!,
                            style: labelBold
                                ? typography.t5Bold
                                : typography.t5Medium,
                          ),
                        ),
                      ),
                    // Same glyph and offset as SeedField's required mark.
                    if (required)
                      Padding(
                        padding: EdgeInsets.only(
                          left: textScaler.scale(2.0),
                          top: textScaler.scale(4.0),
                        ),
                        child: Semantics(
                          label: SeedLocalizations.label(
                            context,
                            SeedLabel.requiredInput,
                          ),
                          child: CustomPaint(
                            size: Size.square(textScaler.scale(6.0)),
                            painter: SeedRequiredIndicatorPainter(
                              colors.fg.critical,
                            ),
                          ),
                        ),
                      ),
                    ?indicator,
                  ],
                ),
              ),
            child,
            // Official RadioGroup/Field compositions render the description
            // in a footer after the controls.
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(
                  top: SeedDimension.x2,
                  left: SeedDimension.x0_5,
                  right: SeedDimension.x0_5,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Centers the icon on the first line of text.
                    Padding(
                      padding: EdgeInsets.only(top: textScaler.scale(1.5)),
                      child: ExcludeSemantics(
                        child: IconTheme(
                          data: IconThemeData(
                            color: colors.fg.critical,
                            size: SeedDimension.x4,
                          ),
                          child: errorIcon ?? const Icon(Icons.error),
                        ),
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
                ),
              )
            else if (description != null)
              Padding(
                padding: const EdgeInsets.only(
                  top: SeedDimension.x2,
                  left: SeedDimension.x0_5,
                  right: SeedDimension.x0_5,
                ),
                child: Text(
                  description!,
                  style: typography.t4Regular.copyWith(
                    color: colors.fg.neutralSubtle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Inherited enabled-state contract shared by fields and SEED controls; nested scopes compose disabled state.
class SeedControlScope extends InheritedWidget {
  /// Provides an inherited effective [enabled] state to descendant SEED controls.
  const SeedControlScope({
    super.key,
    required this.enabled,
    required super.child,
  });

  /// Whether this scope permits its descendant controls to be enabled.
  final bool enabled;

  /// Returns whether every enclosing control scope is enabled.
  static bool enabledOf(BuildContext context) {
    var enabled = true;
    context.visitAncestorElements((element) {
      if (element is InheritedElement && element.widget is SeedControlScope) {
        final scope =
            context.dependOnInheritedElement(element) as SeedControlScope;
        enabled = enabled && scope.enabled;
      }
      return true;
    });
    return enabled;
  }

  /// Notifies dependent controls only when [enabled] changes.
  @override
  bool updateShouldNotify(SeedControlScope oldWidget) =>
      enabled != oldWidget.enabled;
}
