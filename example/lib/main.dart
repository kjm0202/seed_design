import 'package:flutter/widgets.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'stackflow_spa/stackflow_spa.dart';

/// Runs the SEED Design Stackflow SPA example.
void main() {
  // React's historySyncPlugin uses path URLs such as /accordion.
  usePathUrlStrategy();
  runApp(const StackflowSpaApp());
}
