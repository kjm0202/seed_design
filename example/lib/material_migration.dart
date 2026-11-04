import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

void main() => runApp(const MaterialMigrationExample());

/// Run with: flutter run -t lib/material_migration.dart
class MaterialMigrationExample extends StatelessWidget {
  const MaterialMigrationExample({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    restorationScopeId: 'migration-example',
    locale: const Locale('ko'),
    supportedLocales: const [Locale('ko'), Locale('en')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: ThemeData().withSeedDesign(preserveComponentThemes: true),
    darkTheme: ThemeData(brightness: Brightness.dark)
        .withSeedDesign(preserveComponentThemes: true),
    home: const DefaultTabController(length: 2, child: _MigrationScreen()),
  );
}

class _MigrationScreen extends StatefulWidget {
  const _MigrationScreen();
  @override
  State<_MigrationScreen> createState() => _MigrationScreenState();
}

class _MigrationScreenState extends State<_MigrationScreen> {
  final _form = GlobalKey<FormState>();
  var _email = '';
  var _contact = <String>[];
  var _notifications = true;
  void _submit() {
    if (!_form.currentState!.validate()) return;
    _form.currentState!.save();
    FocusScope.of(context).unfocus();
    showSeedSnackbar(
      context: context,
      message: '저장: $_email · ${_contact.join(', ')}',
      actionLabel: '되돌리기',
      onAction: () => _form.currentState!.reset(),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const SeedTopNavigation(
      titleText: 'Material → SEED',
      bottom: SeedTabBar(
        items: [
          SeedTabItem(label: '입력 폼'),
          SeedTabItem(label: '기존 위젯'),
        ],
      ),
    ),
    drawer: const Drawer(
      child: SafeArea(child: Center(child: Text('기존 Drawer'))),
    ),
    body: TabBarView(
      children: [
        Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              SeedTextField(
                restorationId: 'email',
                label: '이메일',
                required: true,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.email],
                autocorrect: false,
                validator: (value) => value != null && value.contains('@')
                    ? null
                    : '이메일을 입력해 주세요',
                onSaved: (value) => _email = value,
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 16),
              SeedSelectFormField<String>(
                label: '연락 방법',
                groups: const [
                  SeedSelectGroup(
                    items: [
                      SeedSelectItem(value: 'chat', label: '채팅'),
                      SeedSelectItem(value: 'email', label: '이메일로 연락'),
                    ],
                  ),
                ],
                validator: (values) =>
                    values == null || values.isEmpty ? '연락 방법을 선택해 주세요' : null,
                onSaved: (values) => _contact = values ?? [],
              ),
              const SizedBox(height: 24),
              SeedButton(label: '저장', onPressed: _submit),
              TextButton(
                onPressed: () => _form.currentState!.reset(),
                child: const Text('초기화'),
              ),
            ],
          ),
        ),
        ListView(
          padding: const EdgeInsets.all(24),
          children: [
            SwitchListTile(
              title: const Text('기존 Material 동작 유지'),
              value: _notifications,
              onChanged: (value) => setState(() => _notifications = value),
            ),
            const LinearProgressIndicator(value: .6, semanticsLabel: '진행률'),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => showSeedDialog<void>(
                context: context,
                routeSettings: const RouteSettings(name: '/migration-dialog'),
                builder: (dialogContext) => SeedDialog(
                  title: 'SEED 오버레이',
                  content: const Text('기존 Navigator와 결과값 흐름을 유지합니다.'),
                  primaryAction: SeedButton(
                    label: '확인',
                    onPressed: () => Navigator.of(dialogContext).pop(),
                  ),
                ),
              ),
              child: const Text('다이얼로그 열기'),
            ),
          ],
        ),
      ],
    ),
  );
}
