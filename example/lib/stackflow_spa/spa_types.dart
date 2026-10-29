import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart' as mui;

/// A Flutter equivalent of Stackflow's push(activity, params).
typedef SpaNavigate = void Function(String activity, {Object? arguments});

/// Activities that draw their surface in a modal route above the host page.
const spaModalActivities = {
  'ActivityBottomSheet',
  'ActivityBottomSheetInputFocus',
  'ActivityBottomSheetTextField',
  'ActivityBottomSheetKeyboardPlayground',
  'ActivityNestedBottomSheet',
  'ActivityMenuSheet',
  'ActivityMenuSheetSimple',
  'ActivitySwipeableMenuSheet',
  'ActivitySidePanel',
  'ActivityResponsiveSidePanel',
  'ActivityAlertDialog',
  'ActivityResponsiveDialog',
  'ActivityBottomSheetModalTest',
};

/// Activity pages are built by feature groups. Return null for unknown names.
typedef SpaActivityBuilder = Widget? Function(
  String activity,
  BuildContext context, {
  required SpaNavigate navigate,
  required VoidCallback goBack,
  Object? arguments,
});

/// Marks activities that own their actual top bar and content insets.
class SpaOwnScaffold extends StatelessWidget {
  const SpaOwnScaffold({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) =>
      mui.Material(type: mui.MaterialType.transparency, child: child);
}
