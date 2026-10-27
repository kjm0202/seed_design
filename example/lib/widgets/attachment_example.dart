import 'package:material_ui/material_ui.dart';
import 'package:seed_design/seed_design.dart';

/// External entry state only: no file picker or upload operation is performed.
class AttachmentExample extends StatefulWidget {
  const AttachmentExample({super.key});

  @override
  State<AttachmentExample> createState() => _AttachmentExampleState();
}

class _AttachmentExampleState extends State<AttachmentExample> {
  final SeedAttachmentController _controller = SeedAttachmentController(
    items: const [
      SeedAttachmentItem(id: 'ready', name: '이미지 예시', isRepresentative: true),
      SeedAttachmentItem(
        id: 'progress',
        name: '진행 중 예시',
        status: SeedAttachmentStatus.uploading,
        progress: .6,
      ),
      SeedAttachmentItem(
        id: 'error',
        name: '오류 예시',
        status: SeedAttachmentStatus.error,
      ),
    ],
  );
  final List<SeedAttachmentItem> _files = [
    const SeedAttachmentItem(
      id: 'file-ready',
      name: 'sample.pdf',
      sizeText: '2.4 MB',
      type: SeedAttachmentType.file,
    ),
    const SeedAttachmentItem(
      id: 'file-progress',
      name: '진행 중 예시',
      type: SeedAttachmentType.file,
      status: SeedAttachmentStatus.uploading,
      progress: .6,
    ),
    const SeedAttachmentItem(
      id: 'file-error',
      name: '오류 예시',
      type: SeedAttachmentType.file,
      status: SeedAttachmentStatus.error,
    ),
  ];
  int _fileEntryId = 0;
  int _entryId = 0;

  void _add() => _controller.addEntries([
    SeedAttachmentItem(id: 'example-${_entryId++}', name: '예시 항목'),
  ]);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _controller,
    builder: (context, _) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SeedAttachmentDropzone(
          label: '예시 첨부 항목 추가',
          enabled: _controller.canAdd,
          onTap: _add,
        ),
        const SizedBox(height: 12),
        const Text('Media Attachments'),
        const SizedBox(height: 8),
        SeedAttachmentDisplayField(
          controller: _controller,
          reorderable: true,
          onTrigger: (_) => _add(),
          onRetry: (item, controller) =>
              controller.updateStatus(item.id, SeedAttachmentStatus.completed),
        ),
        const SizedBox(height: 16),
        const Text('File Attachments'),
        const SizedBox(height: 8),
        SeedAttachmentInput(
          items: _files,
          onAdd: () => setState(
            () => _files.add(
              SeedAttachmentItem(
                id: 'sample-${_fileEntryId++}',
                name: 'sample.pdf',
                sizeText: '2.4 MB',
                type: SeedAttachmentType.file,
              ),
            ),
          ),
          onRemove: (item) => setState(() => _files.remove(item)),
          onRetry: (item) => setState(() {
            final index = _files.indexOf(item);
            _files[index] = item.copyWith(
              status: SeedAttachmentStatus.completed,
            );
          }),
        ),
      ],
    ),
  );
}
