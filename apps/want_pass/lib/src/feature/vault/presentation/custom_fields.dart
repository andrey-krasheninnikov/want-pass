part of 'content.dart';

final class _CardTemplateDraft {
  String? id;
  TemplateVersionV1? version;
  bool accepted = false;
  final content = <String, TextEditingController>{},
      files = <String, AttachmentDraftV1>{},
      existingFiles = <String, AttachmentV1>{};
  void select(
    String templateId,
    TemplateVersionV1 next, {
    List<CustomValueViewV1> values = const [],
    bool migrate = false,
  }) {
    final previous = version;
    if (!migrate) clear();
    if (migrate) {
      final compatible = next.fields
          .where(
            (f) =>
                previous?.fields.any((p) => p.id == f.id && p.kind == f.kind) ??
                false,
          )
          .map((f) => f.id)
          .toSet();
      for (final key
          in content.keys.where((k) => !compatible.contains(k)).toList()) {
        content.remove(key)!.dispose();
        files.remove(key);
        existingFiles.remove(key);
      }
      accepted = true;
    }
    id = templateId;
    version = next;
    for (final field in next.fields) {
      final saved = values.where((v) => v.fieldId == field.id).firstOrNull;
      content.putIfAbsent(
        field.id,
        () => TextEditingController(text: saved?.value),
      );
      if (saved?.file != null) existingFiles[field.id] = saved!.file!;
    }
  }

  List<CustomValueDraftV1> input() => [
    for (final f in version!.fields)
      CustomValueDraftV1(
        fieldId: f.id,
        value: content[f.id]?.text ?? '',
        file: files[f.id],
        keepFile: existingFiles.containsKey(f.id) && !files.containsKey(f.id),
      ),
  ];
  void clear() {
    for (final c in content.values) {
      c.clear();
      c.dispose();
    }
    content.clear();
    files.clear();
    existingFiles.clear();
    id = null;
    version = null;
    accepted = false;
  }

  void dispose() => clear();
}

final class _CustomFields extends StatelessWidget {
  final _CardTemplateDraft draft;
  final List<TemplateDefinitionV1> templates;
  final VaultController controller;
  final CardSummaryV1? existing;
  final bool busy;
  final ValueChanged<VoidCallback> onUpdate;
  const _CustomFields({
    required this.draft,
    required this.templates,
    required this.controller,
    required this.existing,
    required this.busy,
    required this.onUpdate,
  });
  @override
  Widget build(BuildContext c) {
    final current = draft.version!,
        template = templates.firstWhere((t) => t.id == draft.id),
        latest = template.versions.last;
    final changed = latest.fields
            .where((f) => !current.fields.contains(f))
            .map((f) => f.label),
        removed = current.fields
            .where((f) => !latest.fields.any((n) => n.id == f.id))
            .map((f) => f.label);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: [
        _pick<String>(
          c,
          _text(c, 'Template', 'Шаблон'),
          draft.id,
          templates.map((t) => t.id),
          (id) => templates.firstWhere((t) => t.id == id).versions.last.name,
          (id) => onUpdate(() {
            final t = templates.firstWhere((t) => t.id == id);
            draft.select(id, t.versions.last);
          }),
          enabled: !busy && existing == null,
        ),
        Text('${current.name} · v${current.number}'),
        if (current.number < latest.number)
          WantCard(
            hoverEffect: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: [
                Text(
                  '${_text(c, 'A new template version is available', 'Доступна новая версия шаблона')} · v${latest.number}',
                ),
                if (changed.isNotEmpty)
                  Text(
                    '${_text(c, 'Added or changed', 'Добавлены или изменены')}: ${changed.join(', ')}',
                  ),
                if (removed.isNotEmpty)
                  Text(
                    '${_text(c, 'Removed fields', 'Удалённые поля')}: ${removed.join(', ')}',
                  ),
                Text(
                  _text(
                    c,
                    'Values with a new format must be entered again. You can recover prior values from history after saving.',
                    'Значения с новым форматом нужно ввести заново. После сохранения прежние значения доступны в истории.',
                  ),
                ),
                WantButton(
                  variant: WantButtonVariant.secondary,
                  onPressed: busy
                      ? null
                      : () => onUpdate(
                          () =>
                              draft.select(template.id, latest, migrate: true),
                        ),
                  child: Text(_text(c, 'Use this version', 'Применить версию')),
                ),
              ],
            ),
          ),
        for (final f in current.fields)
          if (f.kind == CustomFieldKindV1.file) ...[
            Text('${f.label}${f.required ? ' *' : ''}'),
            if (draft.files[f.id] != null || draft.existingFiles[f.id] != null)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      draft.files[f.id]?.name ??
                          draft.existingFiles[f.id]!.name,
                    ),
                  ),
                  if (existing != null &&
                      draft.existingFiles[f.id] != null &&
                      !draft.files.containsKey(f.id))
                    IconButton(
                      tooltip: _text(c, 'Export file', 'Выгрузить файл'),
                      icon: const Icon(Icons.download_outlined),
                      onPressed: busy
                          ? null
                          : () => controller.downloadAttachment(
                              existing!.id,
                              draft.existingFiles[f.id]!.name,
                              fieldId: f.id,
                            ),
                    ),
                  IconButton(
                    tooltip: _text(c, 'Remove file', 'Убрать файл'),
                    icon: const Icon(Icons.close),
                    onPressed: busy
                        ? null
                        : () => onUpdate(() {
                            draft.files.remove(f.id);
                            draft.existingFiles.remove(f.id);
                          }),
                  ),
                ],
              ),
            WantButton(
              variant: WantButtonVariant.secondary,
              onPressed: busy
                  ? null
                  : () async {
                      final file = await controller.selectAttachment();
                      if (c.mounted &&
                          file != null &&
                          draft.version == current) {
                        onUpdate(() => draft.files[f.id] = file);
                      }
                    },
              child: Text(_text(c, 'Choose file', 'Выбрать файл')),
            ),
          ] else
            VaultSecretInput(
              key: ValueKey('custom-${f.id}'),
              label: '${f.label}${f.required ? ' *' : ''}',
              controller: draft.content[f.id]!,
              protectClipboard: existing != null,
              enabled: !busy,
              autofocus: false,
              last: false,
              concealed: !{
                CustomFieldKindV1.text,
                CustomFieldKindV1.url,
              }.contains(f.kind),
              preserveLineBreaks: f.kind == CustomFieldKindV1.codes,
              onChanged: (_) {
                controller.activity();
                onUpdate(() {});
              },
              onSubmitted: () {},
            ),
      ],
    );
  }
}
