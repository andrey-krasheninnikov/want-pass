part of 'content.dart';

Widget _pick<T>(
  BuildContext context,
  String label,
  T? selected,
  Iterable<T> choices,
  String Function(T) title,
  ValueChanged<T> select, {
  bool enabled = true,
}) => _CatalogSelect<T>(
  label: label,
  value: selected,
  values: choices,
  itemLabel: title,
  searchTerms: title,
  itemIcon: (_) => const Icon(Icons.chevron_right, size: 16),
  enabled: enabled,
  onChanged: (v) {
    if (v != null) select(v);
  },
);

String _kindLabel(BuildContext c, CustomFieldKindV1 kind) => switch (kind) {
  CustomFieldKindV1.text => _text(c, 'Text', 'Текст'),
  CustomFieldKindV1.concealed => _text(
    c,
    'Concealed value',
    'Скрытое значение',
  ),
  CustomFieldKindV1.url => 'URL',
  CustomFieldKindV1.otp => 'TOTP',
  CustomFieldKindV1.codes => _text(c, 'Code list', 'Список кодов'),
  CustomFieldKindV1.file => _text(c, 'File', 'Файл'),
};

final class _ManagedCatalog extends StatefulWidget {
  const _ManagedCatalog({
    required this.controller,
    required this.services,
    required this.builtins,
  });
  final VaultController controller;
  final bool services;
  final Widget builtins;
  @override
  State<_ManagedCatalog> createState() => _ManagedCatalogState();
}

final class _ManagedCatalogState extends State<_ManagedCatalog> {
  String? editing;
  @override
  Widget build(BuildContext context) {
    final snapshot = widget.controller.state.content!;
    final services = widget.services;
    if (editing != null) {
      return services
          ? _ServiceForm(
              key: ValueKey(editing),
              controller: widget.controller,
              item: snapshot.services.where((t) => t.id == editing).firstOrNull,
              onDone: () => setState(() => editing = null),
            )
          : _TemplateForm(
              key: ValueKey(editing),
              controller: widget.controller,
              item: snapshot.templates
                  .where((t) => t.id == editing)
                  .firstOrNull,
              onDone: () => setState(() => editing = null),
            );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        _SectionPanel(
          title: services
              ? _text(context, 'Your services', 'Ваши сервисы')
              : _text(context, 'Your templates', 'Ваши шаблоны'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              if (services)
                for (final s in snapshot.services)
                  ListTile(
                    leading: SizedBox.square(
                      dimension: 28,
                      child: VaultGroupLogo(icon: s.icon, bytes: s.logo),
                    ),
                    title: Text(s.name),
                    subtitle: s.archived
                        ? Text(_text(context, 'Archived', 'В архиве'))
                        : s.description.isEmpty
                        ? null
                        : Text(s.description),
                    trailing: const Icon(Icons.edit_outlined),
                    onTap: () => setState(() => editing = s.id),
                  )
              else
                for (final t in snapshot.templates)
                  ListTile(
                    leading: const Icon(Icons.tune),
                    title: Text(t.versions.last.name),
                    subtitle: Text('v${t.versions.last.number}'),
                    trailing: const Icon(Icons.edit_outlined),
                    onTap: () => setState(() => editing = t.id),
                  ),
              WantButton(
                onPressed: () => setState(() => editing = ''),
                child: Text(
                  services
                      ? _text(context, 'Add service', 'Добавить сервис')
                      : _text(context, 'Add type', 'Добавить тип'),
                ),
              ),
            ],
          ),
        ),
        widget.builtins,
      ],
    );
  }
}

final class _ServiceForm extends StatefulWidget {
  final VaultController controller;
  final ServiceDefinitionV1? item;
  final VoidCallback onDone;
  const _ServiceForm({
    super.key,
    required this.controller,
    required this.item,
    required this.onDone,
  });
  @override
  State<_ServiceForm> createState() => _ServiceFormState();
}

final class _ServiceFormState extends State<_ServiceForm> {
  late final name = TextEditingController(text: widget.item?.name),
      description = TextEditingController(text: widget.item?.description);
  late final revision = widget.controller.state.content!.revision;
  late String icon = widget.item?.icon ?? 'building';
  late List<int> logo = widget.item?.logo ?? [];
  var tone = _GroupTone.brand;
  bool removing = false, saving = false;
  String? replacement;
  bool get referenced => widget.controller.state.content!.cards.any(
    (c) => c.service == widget.item?.id,
  );
  @override
  void dispose() {
    name.dispose();
    description.dispose();
    logo = [];
    super.dispose();
  }

  Future<void> save({bool remove = false}) async {
    if (saving) return;
    setState(() => saving = true);
    try {
      final image = !remove && logo.isEmpty && tone != _GroupTone.brand
          ? await tone.render(icon)
          : logo;
      if (!mounted || widget.controller.state.phase != VaultPhase.unlocked) {
        return;
      }
      final edit = remove
          ? RemoveServiceV1(
              widget.item!.id,
              replacement == '' ? null : replacement,
              referenced && replacement == '',
            )
          : SaveServiceV1(
              ServiceDefinitionV1(
                id: widget.item?.id ?? '',
                name: name.text,
                description: description.text,
                icon: icon,
                logo: image,
                archived: widget.item?.archived ?? false,
              ),
            );
      if (await widget.controller.editCatalog(edit, revision) && mounted) {
        widget.onDone();
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext c) {
    final state = widget.controller.state;
    final targets = [
      ...state.catalog!.services,
      ...state.content!.services
          .where((s) => s.id != widget.item?.id && !s.archived)
          .map((s) => s.id),
    ];
    return _SectionPanel(
      title: _text(c, 'Service', 'Сервис'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Row(
            spacing: 8,
            children: [
              _GroupIconPicker(
                icon: icon,
                image: logo,
                tone: tone,
                enabled: !saving,
                selectImage: widget.controller.selectGroupLogo,
                onChanged: (i, image, t) => setState(() {
                  icon = i;
                  logo = image;
                  tone = t;
                }),
              ),
              Expanded(
                child: WantInput(
                  label: Text(_text(c, 'Name', 'Название')),
                  controller: name,
                  enabled: !saving,
                ),
              ),
            ],
          ),
          WantTextarea(
            label: Text(_text(c, 'Description', 'Описание')),
            controller: description,
            enabled: !saving,
          ),
          _Actions(
            children: [
              WantButton(
                variant: WantButtonVariant.secondary,
                onPressed: saving ? null : widget.onDone,
                child: Text(_text(c, 'Cancel', 'Отмена')),
              ),
              WantButton(
                onPressed: saving ? null : save,
                child: Text(_text(c, 'Save', 'Сохранить')),
              ),
            ],
          ),
          if (widget.item != null && !widget.item!.archived && !removing)
            WantButton(
              variant: WantButtonVariant.destructive,
              onPressed: saving ? null : () => setState(() => removing = true),
              child: Text(_text(c, 'Remove service', 'Удалить сервис')),
            ),
          if (removing) ...[
            if (referenced)
              Text(
                _text(
                  c,
                  'Keep the service on existing cards, or move them to another service.',
                  'Можно сохранить сервис на существующих карточках или перенести их в другой сервис.',
                ),
              ),
            if (referenced)
              _pick<String>(
                c,
                _text(c, 'Existing cards', 'Существующие карточки'),
                replacement,
                ['', ...targets],
                (v) => v.isEmpty
                    ? _text(c, 'Keep existing references', 'Сохранить связи')
                    : _serviceLabel(c, v),
                (v) => setState(() => replacement = v),
              ),
            WantButton(
              variant: WantButtonVariant.destructive,
              onPressed: saving || (referenced && replacement == null)
                  ? null
                  : () => save(remove: true),
              child: Text(_text(c, 'Confirm removal', 'Подтвердить удаление')),
            ),
          ],
          _ContentError(state.error),
        ],
      ),
    );
  }
}

final class _FieldRow {
  final String id;
  final TextEditingController label;
  CustomFieldKindV1 kind;
  bool required;
  _FieldRow([TemplateFieldV1? field])
    : id = field?.id ?? '',
      label = TextEditingController(text: field?.label),
      kind = field?.kind ?? CustomFieldKindV1.text,
      required = field?.required ?? false;
  TemplateFieldV1 get definition => TemplateFieldV1(
    id: id,
    label: label.text,
    kind: kind,
    required: required,
  );
}

final class _TemplateForm extends StatefulWidget {
  final VaultController controller;
  final TemplateDefinitionV1? item;
  final VoidCallback onDone;
  const _TemplateForm({
    super.key,
    required this.controller,
    required this.item,
    required this.onDone,
  });
  @override
  State<_TemplateForm> createState() => _TemplateFormState();
}

final class _TemplateFormState extends State<_TemplateForm> {
  late final revision = widget.controller.state.content!.revision;
  late final name = TextEditingController(
    text: widget.item?.versions.last.name,
  );
  late final rows =
      widget.item?.versions.last.fields.map((f) => _FieldRow(f)).toList() ??
      [_FieldRow()];
  bool saving = false;
  @override
  void dispose() {
    name.dispose();
    for (final row in rows) {
      row.label.dispose();
    }
    super.dispose();
  }

  Future<void> save() async {
    if (saving) return;
    setState(() => saving = true);
    try {
      if (await widget.controller.editCatalog(
            SaveTemplateV1(
              widget.item?.id,
              name.text,
              rows.map((row) => row.definition).toList(),
            ),
            revision,
          ) &&
          mounted) {
        widget.onDone();
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext c) => _SectionPanel(
    title: _text(c, 'Card template', 'Шаблон карточки'),
    content: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        WantInput(
          label: Text(_text(c, 'Template name', 'Название шаблона')),
          controller: name,
        ),
        if (widget.item != null)
          Text(
            _text(
              c,
              'Saving changes creates a version. Existing cards keep their version until you update them.',
              'Изменения создадут версию шаблона. Существующие карточки сохранят прежнюю версию до подтверждения обновления.',
            ),
          ),
        for (final row in rows)
          WantCard(
            key: ObjectKey(row),
            hoverEffect: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: WantInput(
                        controller: row.label,
                        label: Text(_text(c, 'Field name', 'Название поля')),
                      ),
                    ),
                    IconButton(
                      tooltip: _text(c, 'Remove field', 'Удалить поле'),
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: saving
                          ? null
                          : () => setState(() {
                              rows.remove(row);
                              row.label.dispose();
                            }),
                    ),
                  ],
                ),
                _pick<CustomFieldKindV1>(
                  c,
                  _text(c, 'Field format', 'Формат поля'),
                  row.kind,
                  CustomFieldKindV1.values,
                  (k) => _kindLabel(c, k),
                  (v) => setState(() => row.kind = v),
                ),
                WantCheckbox(
                  value: row.required,
                  label: Text(_text(c, 'Required', 'Обязательное')),
                  onChanged: (v) => setState(() => row.required = v),
                ),
              ],
            ),
          ),
        WantButton(
          variant: WantButtonVariant.secondary,
          onPressed: saving
              ? null
              : () => setState(() => rows.add(_FieldRow())),
          child: Text(_text(c, 'Add field', 'Добавить поле')),
        ),
        _Actions(
          children: [
            WantButton(
              variant: WantButtonVariant.secondary,
              onPressed: saving ? null : widget.onDone,
              child: Text(_text(c, 'Cancel', 'Отмена')),
            ),
            WantButton(
              onPressed: saving || rows.isEmpty ? null : save,
              child: Text(_text(c, 'Save template', 'Сохранить шаблон')),
            ),
          ],
        ),
        _ContentError(widget.controller.state.error),
      ],
    ),
  );
}
