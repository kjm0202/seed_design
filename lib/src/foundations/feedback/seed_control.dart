import 'package:material_ui/material_ui.dart';

import '../../theme/seed_theme.dart';

enum SeedControlTone { neutral, brand }

enum SeedLabelWeight { regular, bold }

/// Native equivalent of a labelled fieldset. Disabled state reaches all SEED controls.
class SeedFieldset extends StatelessWidget {
  const SeedFieldset({
    super.key,
    this.label,
    this.description,
    this.indicator,
    this.enabled = true,
    required this.child,
  });
  final String? label;
  final String? description;
  final Widget? indicator;
  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context) => SeedControlScope(
    enabled: enabled && SeedControlScope.enabledOf(context),
    child: Semantics(
      container: true,
      explicitChildNodes: true,
      label: label,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null || indicator != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  if (label != null)
                    Flexible(
                      child: ExcludeSemantics(
                        child: Text(
                          label!,
                          style: context.seedTypography.t4Bold,
                        ),
                      ),
                    ),
                  ?indicator,
                ],
              ),
            ),
          if (description != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                description!,
                style: context.seedTypography.t3Regular,
              ),
            ),
          child,
        ],
      ),
    ),
  );
}

class SeedControlScope extends InheritedWidget {
  const SeedControlScope({
    super.key,
    required this.enabled,
    required super.child,
  });
  final bool enabled;
  static bool enabledOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SeedControlScope>()?.enabled ??
      true;
  @override
  bool updateShouldNotify(SeedControlScope oldWidget) =>
      enabled != oldWidget.enabled;
}
