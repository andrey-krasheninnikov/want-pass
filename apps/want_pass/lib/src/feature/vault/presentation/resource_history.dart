part of 'content.dart';

const _resourceMethods = <ResourceKindV1, List<BindingMethodV1>>{
  ResourceKindV1.webApp: [
    BindingMethodV1.web,
    BindingMethodV1.netrc,
    BindingMethodV1.mtls,
  ],
  ResourceKindV1.restEndpoint: [
    BindingMethodV1.rest,
    BindingMethodV1.netrc,
    BindingMethodV1.mtls,
    BindingMethodV1.awsCli,
  ],
  ResourceKindV1.sshHost: [BindingMethodV1.ssh],
  ResourceKindV1.gitRepository: [
    BindingMethodV1.git,
    BindingMethodV1.ssh,
    BindingMethodV1.netrc,
  ],
  ResourceKindV1.packageRegistry: [
    BindingMethodV1.registry,
    BindingMethodV1.netrc,
    BindingMethodV1.mtls,
  ],
  ResourceKindV1.containerRegistry: [
    BindingMethodV1.registry,
    BindingMethodV1.netrc,
    BindingMethodV1.mtls,
  ],
  ResourceKindV1.database: [BindingMethodV1.database, BindingMethodV1.mtls],
  ResourceKindV1.kubernetesContext: [
    BindingMethodV1.kubernetes,
    BindingMethodV1.mtls,
  ],
};
String _resourceName(BuildContext c, ResourceKindV1 k) => switch (k) {
  ResourceKindV1.webApp => _text(c, 'Web app', 'Веб-приложение'),
  ResourceKindV1.restEndpoint => 'REST API',
  ResourceKindV1.sshHost => _text(c, 'SSH host', 'SSH-сервер'),
  ResourceKindV1.gitRepository => _text(c, 'Git repository', 'Git-репозиторий'),
  ResourceKindV1.packageRegistry => _text(
    c,
    'Package registry',
    'Реестр пакетов',
  ),
  ResourceKindV1.containerRegistry => _text(
    c,
    'Container registry',
    'Реестр контейнеров',
  ),
  ResourceKindV1.database => _text(c, 'Database', 'База данных'),
  ResourceKindV1.kubernetesContext => _text(
    c,
    'Kubernetes context',
    'Контекст Kubernetes',
  ),
};
String _methodName(BindingMethodV1 k) => switch (k) {
  BindingMethodV1.web => 'Web',
  BindingMethodV1.rest => 'REST',
  BindingMethodV1.ssh => 'SSH',
  BindingMethodV1.git => 'Git',
  BindingMethodV1.registry => 'Registry',
  BindingMethodV1.database => 'Database',
  BindingMethodV1.kubernetes => 'Kubernetes',
  BindingMethodV1.awsCli => 'AWS CLI',
  BindingMethodV1.netrc => 'netrc',
  BindingMethodV1.mtls => 'mTLS',
};

TemplateVersionV1? _cardTemplate(
  ContentSnapshotV2 snapshot,
  CardSummaryV1 card,
) => snapshot.templates
    .where((t) => t.id == card.customTemplateId)
    .firstOrNull
    ?.versions
    .where((v) => v.number == card.templateVersion)
    .firstOrNull;
String _fieldKey(FieldIdV1 f) =>
    f.name.replaceAllMapped(RegExp(r'[A-Z]'), (m) => '-${m[0]!.toLowerCase()}');

final class _ResourceEditor extends StatefulWidget {
  final VaultController controller;
  const _ResourceEditor({required this.controller});
  @override
  State<_ResourceEditor> createState() => _ResourceEditorState();
}

final class _ResourceEditorState extends State<_ResourceEditor> {
  String? selected;
  BigInt? revision;
  List<ResourceBindingV1>? bindings;
  bool editing = false, saving = false;
  String bindingId = '';
  ResourceKindV1 kind = ResourceKindV1.webApp;
  BindingMethodV1 method = BindingMethodV1.web;
  final target = TextEditingController(), fields = <String>{};
  @override
  void dispose() {
    target.dispose();
    super.dispose();
  }

  Future<void> choose(String id) async {
    setState(() {
      selected = id;
      bindings = null;
      editing = false;
      revision = widget.controller.state.content!.revision;
    });
    final value = await widget.controller.readBindings(id);
    if (mounted && selected == id) setState(() => bindings = value);
  }

  void edit([ResourceBindingV1? b]) => setState(() {
    editing = true;
    bindingId = b?.id ?? '';
    target.text = b?.target ?? '';
    kind = b?.kind ?? ResourceKindV1.webApp;
    method = b?.method ?? BindingMethodV1.web;
    fields.clear();
    fields.addAll(b?.fields ?? []);
  });
  Future<void> save({bool remove = false}) async {
    final id = selected, base = revision, old = bindings;
    if (saving || id == null || base == null || old == null) return;
    setState(() => saving = true);
    try {
      final updated = [
        for (final b in old)
          if (b.id != bindingId) b,
        if (!remove)
          ResourceBindingV1(
            id: bindingId,
            kind: kind,
            target: target.text,
            method: method,
            fields: fields.toList(),
          ),
      ];
      if (await widget.controller.editCatalog(
            SaveBindingsV1(id, updated),
            base,
          ) &&
          mounted) {
        await choose(id);
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext c) {
    final state = widget.controller.state, snapshot = state.content!;
    final card = snapshot.cards.where((v) => v.id == selected).firstOrNull;
    final preset = state.catalog!.presets
        .where((p) => p.cardType == card?.cardType)
        .firstOrNull;
    final names = <String, String>{
      if (card != null)
        for (final f
            in _cardTemplate(snapshot, card)?.fields ?? <TemplateFieldV1>[])
          f.id: f.label,
      for (final f in preset?.fields ?? <FieldSpecV1>[])
        _fieldKey(f.id): _fieldLabel(c, f.id),
      if (card?.cardType.requiresAttachment == true)
        'attachment': _text(c, 'Attachment', 'Вложение'),
    };
    return _SectionPanel(
      title: _text(c, 'Card bindings', 'Привязки карточки'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          if (snapshot.cards.isEmpty)
            Text(
              _text(
                c,
                'Create a card to add a target resource.',
                'Создайте карточку, чтобы добавить ресурс назначения.',
              ),
            )
          else
            _pick<String>(
              c,
              _text(c, 'Card', 'Карточка'),
              selected,
              snapshot.cards.map((v) => v.id),
              (id) =>
                  snapshot.cards.where((v) => v.id == id).firstOrNull?.name ??
                  id,
              choose,
              enabled: !saving,
            ),
          if (selected != null && bindings == null)
            WantButton(
              variant: WantButtonVariant.secondary,
              onPressed: () => choose(selected!),
              child: Text(_text(c, 'Load bindings', 'Загрузить привязки')),
            ),
          if (bindings != null && !editing) ...[
            for (final b in bindings!)
              ListTile(
                leading: const Icon(Icons.link),
                title: Text(b.target),
                subtitle: Text(
                  '${_resourceName(c, b.kind)} · ${_methodName(b.method)} · ${b.fields.map((k) => names[k] ?? k).join(', ')}',
                ),
                trailing: const Icon(Icons.edit_outlined),
                onTap: () => edit(b),
              ),
            WantButton(
              onPressed: edit,
              child: Text(_text(c, 'Add binding', 'Добавить привязку')),
            ),
          ],
          if (editing) ...[
            _pick<ResourceKindV1>(
              c,
              _text(c, 'Resource', 'Ресурс'),
              kind,
              ResourceKindV1.values,
              (k) => _resourceName(c, k),
              (v) => setState(() {
                kind = v;
                method = _resourceMethods[v]!.first;
              }),
            ),
            WantInput(
              label: Text(_text(c, 'Destination', 'Адрес назначения')),
              controller: target,
            ),
            _pick<BindingMethodV1>(
              c,
              _text(c, 'Usage method', 'Способ использования'),
              method,
              _resourceMethods[kind]!,
              _methodName,
              (v) => setState(() => method = v),
            ),
            Text(_text(c, 'Available fields', 'Доступные поля')),
            for (final entry in names.entries)
              WantCheckbox(
                value: fields.contains(entry.key),
                label: Text(entry.value),
                onChanged: (v) => setState(() {
                  if (v) {
                    fields.add(entry.key);
                  } else {
                    fields.remove(entry.key);
                  }
                }),
              ),
            _Actions(
              children: [
                WantButton(
                  variant: WantButtonVariant.secondary,
                  onPressed: saving
                      ? null
                      : () => setState(() => editing = false),
                  child: Text(_text(c, 'Cancel', 'Отмена')),
                ),
                WantButton(
                  onPressed: saving || fields.isEmpty ? null : save,
                  child: Text(_text(c, 'Save', 'Сохранить')),
                ),
              ],
            ),
            if (bindingId.isNotEmpty)
              WantButton(
                variant: WantButtonVariant.destructive,
                onPressed: saving ? null : () => save(remove: true),
                child: Text(_text(c, 'Remove binding', 'Удалить привязку')),
              ),
          ],
          _ContentError(state.error),
        ],
      ),
    );
  }
}

final class _HistoryBrowser extends StatefulWidget {
  final VaultController controller;
  const _HistoryBrowser({required this.controller});
  @override
  State<_HistoryBrowser> createState() => _HistoryBrowserState();
}

final class _HistoryBrowserState extends State<_HistoryBrowser> {
  List<HistorySummaryV1>? entries;
  String? selectedCard, selectedEntry;
  HistoricalCardV1? detail;
  bool confirming = false, working = false;
  BigInt? revision;
  int request = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(load());
    });
  }

  Future<void> load() async {
    final serial = ++request;
    setState(() {
      entries = null;
      selectedEntry = null;
      detail = null;
      confirming = false;
      revision = widget.controller.state.content!.revision;
    });
    final value = await widget.controller.readHistory();
    if (mounted && serial == request) {
      setState(() {
        entries = value;
        if (!(value ?? []).any((e) => e.cardId == selectedCard)) {
          selectedCard = null;
        }
      });
    }
  }

  Future<void> show(HistorySummaryV1 entry) async {
    final previous = selectedEntry, serial = ++request;
    setState(() {
      selectedEntry = previous == entry.id ? null : entry.id;
      detail = null;
      confirming = false;
    });
    if (previous == entry.id) return;
    final value = await widget.controller.readHistoricalCard(entry.id);
    if (mounted && serial == request) setState(() => detail = value);
  }

  Future<void> change(CatalogEditV1 edit) async {
    if (working || revision == null) return;
    setState(() => working = true);
    try {
      if (await widget.controller.editCatalog(edit, revision!) && mounted) {
        await load();
      }
    } finally {
      if (mounted) setState(() => working = false);
    }
  }

  @override
  Widget build(BuildContext c) {
    final snapshot = widget.controller.state.content!;
    final rows = entries, card = detail;
    final names = <String, String>{
      for (final e in rows ?? <HistorySummaryV1>[]) e.cardId: e.name,
    };
    final filtered =
        rows?.where((e) => selectedCard == null || selectedCard == e.cardId) ??
        <HistorySummaryV1>[];
    return _SectionPanel(
      title: _text(
        c,
        'Card changes · 365 days',
        'Изменения карточек · 365 дней',
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          if (rows == null || snapshot.revision != revision)
            WantButton(
              variant: WantButtonVariant.secondary,
              onPressed: load,
              child: Text(_text(c, 'Load history', 'Загрузить историю')),
            ),
          if (rows?.isEmpty == true)
            Text(_text(c, 'No saved revisions', 'Сохранённых версий пока нет')),
          if (rows?.isNotEmpty == true) ...[
            _pick<String>(
              c,
              _text(c, 'Card', 'Карточка'),
              selectedCard ?? '',
              ['', ...names.keys],
              (id) => names[id] ?? _text(c, 'All cards', 'Все карточки'),
              (v) => setState(() {
                request++;
                selectedCard = v.isEmpty ? null : v;
                selectedEntry = null;
                detail = null;
                confirming = false;
              }),
            ),
            for (final e in filtered) ...[
              ListTile(
                leading: const Icon(Icons.history),
                title: Text(e.name),
                subtitle: Text(
                  '${MaterialLocalizations.of(c).formatMediumDate(e.at.toLocal())} · ${TimeOfDay.fromDateTime(e.at.toLocal()).format(c)} · ${_serviceLabel(c, e.service)}',
                ),
                trailing: Icon(
                  selectedEntry == e.id ? Icons.expand_less : Icons.expand_more,
                ),
                onTap: () => show(e),
              ),
              if (selectedEntry == e.id &&
                  card != null &&
                  snapshot.revision == revision)
                WantCard(
                  hoverEffect: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 8,
                    children: [
                      if (card.description.isNotEmpty) Text(card.description),
                      for (final f in card.fields)
                        Text('${_fieldLabel(c, f.id)} · ${f.value}'),
                      for (final v in card.customValues)
                        Text(
                          '${_cardTemplate(snapshot, card.summary)?.fields.where((f) => f.id == v.fieldId).firstOrNull?.label ?? v.fieldId} · ${v.file?.name ?? v.value}',
                        ),
                      if (card.attachment != null)
                        Text(
                          '${card.attachment!.name} · ${card.attachment!.size} B',
                        ),
                      for (final b in card.bindings)
                        Text('${_methodName(b.method)} · ${b.target}'),
                      WantButton(
                        onPressed: working
                            ? null
                            : () => change(RestoreHistoryV1(e.id)),
                        child: Text(
                          _text(
                            c,
                            'Restore this version',
                            'Восстановить эту версию',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
            if (!confirming)
              WantButton(
                variant: WantButtonVariant.secondary,
                onPressed: () => setState(() => confirming = true),
                child: Text(
                  selectedCard == null
                      ? _text(c, 'Clear all history', 'Очистить всю историю')
                      : _text(
                          c,
                          'Clear card history',
                          'Очистить историю карточки',
                        ),
                ),
              )
            else ...[
              Text(
                _text(
                  c,
                  'This clears the selected revisions from this vault. Current cards and independently exported backups keep their data.',
                  'Эти версии будут удалены из сейфа. Текущие карточки и ранее экспортированные резервные копии сохранят свои данные.',
                ),
              ),
              _Actions(
                children: [
                  WantButton(
                    variant: WantButtonVariant.secondary,
                    onPressed: working
                        ? null
                        : () => setState(() => confirming = false),
                    child: Text(_text(c, 'Cancel', 'Отмена')),
                  ),
                  WantButton(
                    variant: WantButtonVariant.destructive,
                    onPressed: working
                        ? null
                        : () => change(ClearHistoryV1(selectedCard, true)),
                    child: Text(
                      _text(c, 'Confirm deletion', 'Подтвердить удаление'),
                    ),
                  ),
                ],
              ),
            ],
          ],
          _ContentError(widget.controller.state.error),
        ],
      ),
    );
  }
}
