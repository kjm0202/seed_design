import 'package:integration_test/integration_test.dart';

import '../test/material_migration_test.dart' as migration_contract;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  migration_contract.main();
}
