part of 'content.dart';

final class _BackupDialog extends StatefulWidget {
  final VaultController controller;
  final bool create;
  const _BackupDialog({required this.controller, required this.create});
  @override
  State<_BackupDialog> createState() => _BackupDialogState();
}

final class _BackupDialogState extends State<_BackupDialog> {
  final _phrase = TextEditingController();
  final _choices = <(BackupEntryKindV1, String), BackupSelectionV1>{};
  BackupModeV1? _mode;
  BackupReviewV1? _review;
  String? _source;
  bool _valid = false, _busy = false, _replaceConfirmed = false, _done = false;
  String? _error;
  int _offset = 0;
  static const _pageSize = 8;

  String tr(String en, String ru) => _text(context, en, ru);

  @override
  void dispose() {
    _phrase.dispose();
    _choices.clear();
    super.dispose();
  }

  String _failed() {
    final error = widget.controller.state.error;
    if (error is VaultRejectedErrorV1) {
      return switch (error.kind) {
        VaultFailureKindV1.invalidPhrase ||
        VaultFailureKindV1.credentials => tr(
          'Check the recovery phrase saved when this backup was created.',
          'Проверьте фразу, сохранённую на момент создания этой копии.',
        ),
        VaultFailureKindV1.unsupported || VaultFailureKindV1.corrupt => tr(
          'This backup format cannot be read, or the file is damaged.',
          'Формат копии не поддерживается или файл повреждён.',
        ),
        VaultFailureKindV1.stale => tr(
          'The vault changed. Review the backup again.',
          'Данные сейфа изменились. Повторите предпросмотр.',
        ),
        _ => tr(
          'The operation could not be completed.',
          'Не удалось завершить операцию.',
        ),
      };
    }
    return tr(
      'The operation could not be completed.',
      'Не удалось завершить операцию.',
    );
  }

  Future<void> _chooseFile() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final path = await widget.controller.selectBackupSource();
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (path != null) {
        _source = path;
        _review = null;
        _choices.clear();
        _offset = 0;
      } else if (widget.controller.state.error != null) {
        _error = _failed();
      }
    });
  }

  Future<void> _export() async {
    final revision = widget.controller.state.content?.revision;
    if (_busy || revision == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final path = await widget.controller.exportBackupToDirectory();
    final saved = path != null;
    if (!mounted) return;
    setState(() {
      _busy = false;
      _done = saved;
      if (path != null) _source = path;
      if (!saved && widget.controller.state.error != null) {
        _error = _failed();
      }
    });
  }

  Future<void> _preview({BackupSelectionV1? choice}) async {
    final source = _source, mode = _mode;
    if (_busy || !_valid || source == null || mode == null) return;
    final choices = Map.of(_choices);
    if (choice != null) choices[(choice.kind, choice.id)] = choice;
    setState(() {
      _busy = true;
      _error = null;
      _replaceConfirmed = false;
    });
    final value = await widget.controller.previewBackup(
      source,
      _phrase.text,
      mode,
      choices.values.toList(),
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (value == null) {
        final error = widget.controller.state.error;
        if (choice != null &&
            error is VaultRejectedErrorV1 &&
            (error.kind == VaultFailureKindV1.corrupt ||
                error.kind == VaultFailureKindV1.confirmation)) {
          _error = tr(
            'These versions cannot be combined. Review the related records or keep both versions.',
            'Выбранные версии несовместимы. Проверьте связанные записи или сохраните обе версии.',
          );
        } else {
          _error = _failed();
        }
        return;
      }
      _review = value;
      _choices
        ..clear()
        ..addAll(choices);
      if (_offset >= value.conflicts.length) _offset = 0;
    });
  }

  Future<void> _apply() async {
    final source = _source, mode = _mode, review = _review;
    if (_busy ||
        source == null ||
        mode == null ||
        review == null ||
        !review.resolved ||
        (mode == BackupModeV1.replace && !_replaceConfirmed)) {
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final success = await widget.controller.applyBackup(
      source,
      _phrase.text,
      mode,
      _choices.values.toList(),
      review,
    );
    if (!mounted) return;
    if (success) {
      _phrase.clear();
      _choices.clear();
    }
    setState(() {
      _busy = false;
      _done = success;
      _review = null;
      _replaceConfirmed = false;
      if (!success) _error = _failed();
    });
  }

  String _kind(BackupEntryKindV1 kind) => switch (kind) {
    BackupEntryKindV1.group => tr('Group', 'Группа'),
    BackupEntryKindV1.service => tr('Service', 'Сервис'),
    BackupEntryKindV1.template => tr('Template', 'Шаблон'),
    BackupEntryKindV1.card => tr('Card', 'Карточка'),
    BackupEntryKindV1.history => tr('Historical version', 'Версия в истории'),
  };

  Widget _conflict(BackupDifferenceV1 d) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      WantTypography(
        '${_kind(d.kind)} · ${d.localName}',
        variant: WantTypographyVariant.h4,
      ),
      Text(tr('From backup: ${d.incomingName}', 'В копии: ${d.incomingName}')),
      WantSelect<BackupDecisionV1>(
        key: ValueKey((d.kind, d.id)),
        value: d.decision,
        enabled: !_busy,
        hint: tr('Choose a version', 'Выберите версию'),
        options: [
          WantOption(
            value: BackupDecisionV1.local,
            label: tr('Keep current', 'Оставить текущую'),
          ),
          WantOption(
            value: BackupDecisionV1.incoming,
            label: tr('Use backup version', 'Взять из копии'),
          ),
          WantOption(
            value: BackupDecisionV1.both,
            label: tr('Keep both versions', 'Сохранить обе версии'),
          ),
        ],
        onChanged: (choice) {
          if (choice != null) {
            unawaited(
              _preview(choice: BackupSelectionV1(d.kind, d.id, choice)),
            );
          }
        },
      ),
    ],
  );

  Widget _options() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 12,
    children: [
      WantButton(
        key: const ValueKey('backup-select-file'),
        variant: WantButtonVariant.secondary,
        onPressed: _busy ? null : _chooseFile,
        child: Text(
          _source == null
              ? tr('Choose backup file', 'Выбрать файл копии')
              : Uri.file(_source!).pathSegments.last,
        ),
      ),
      Text(
        tr(
          'Use the 24 words that were active when this backup was created.',
          'Введите 24 слова, которые действовали при создании этой копии.',
        ),
      ),
      RecoveryPhraseInput(
        key: const ValueKey('backup-recovery-phrase'),
        controller: _phrase,
        inspect: widget.controller.inspectRecoveryWords,
        enabled: !_busy,
        onValidChanged: (valid) {
          if (mounted && _valid != valid) setState(() => _valid = valid);
        },
      ),
      WantSelect<BackupModeV1>(
        key: const ValueKey('backup-mode'),
        value: _mode,
        enabled: !_busy,
        label: Text(tr('Import strategy', 'Способ восстановления')),
        hint: tr('Choose a strategy', 'Выберите способ'),
        options: [
          WantOption(
            value: BackupModeV1.merge,
            label: tr('Merge with this vault', 'Объединить с текущим сейфом'),
          ),
          WantOption(
            value: BackupModeV1.replace,
            label: tr('Replace current data', 'Полностью заменить данные'),
          ),
        ],
        onChanged: (mode) => setState(() {
          _mode = mode;
          _choices.clear();
          _offset = 0;
        }),
      ),
    ],
  );

  Widget _summary(BackupReviewV1 review) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 12,
    children: [
      WantTypography(
        tr('Changes to this vault', 'Изменения в текущем сейфе'),
        variant: WantTypographyVariant.h3,
      ),
      Text(
        tr(
          'Added ${review.added} · Changed ${review.changed} · Removed ${review.removed} · Identical ${review.identical}',
          'Будет добавлено ${review.added}, изменено ${review.changed}, удалено ${review.removed}. Совпадают ${review.identical}.',
        ),
      ),
      if (review.removed > 0)
        Text(
          _mode == BackupModeV1.replace
              ? tr(
                  'Removals include all local SSH profiles.',
                  'В число удалений входят все локальные SSH-профили.',
                )
              : tr(
                  'Removals include SSH profiles whose key or resource binding changes.',
                  'В число удалений входят SSH-профили с изменённым ключом или привязкой ресурса.',
                ),
        ),
      if (review.conflicts.isNotEmpty) ...[
        WantTypography(
          tr(
            'Conflicts · ${review.conflicts.length}',
            'Конфликты · ${review.conflicts.length}',
          ),
        ),
        for (final difference in review.conflicts.skip(_offset).take(_pageSize))
          _conflict(difference),
        if (review.conflicts.length > _pageSize)
          _Actions(
            children: [
              WantButton(
                variant: WantButtonVariant.secondary,
                onPressed: _busy || _offset == 0
                    ? null
                    : () => setState(() => _offset -= _pageSize),
                child: Text(tr('Previous conflicts', 'Предыдущие конфликты')),
              ),
              WantButton(
                variant: WantButtonVariant.secondary,
                onPressed:
                    _busy || _offset + _pageSize >= review.conflicts.length
                    ? null
                    : () => setState(() => _offset += _pageSize),
                child: Text(tr('Next conflicts', 'Следующие конфликты')),
              ),
            ],
          ),
      ],
      if (_mode == BackupModeV1.replace)
        WantCheckbox(
          value: _replaceConfirmed,
          label: Text(
            tr(
              'Replace the current vault contents with this backup.',
              'Заменить содержимое текущего сейфа данными из копии.',
            ),
          ),
          onChanged: _busy
              ? null
              : (value) => setState(() => _replaceConfirmed = value),
        ),
      WantButton(
        variant: WantButtonVariant.ghost,
        onPressed: _busy
            ? null
            : () => setState(() {
                _review = null;
                _replaceConfirmed = false;
              }),
        child: Text(tr('Change import options', 'Изменить параметры')),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final review = _review;
    final title = widget.create
        ? tr('Export backup', 'Экспорт копии')
        : tr('Restore backup', 'Восстановление из копии');
    return PopScope<void>(
      canPop: !_busy,
      child: WantDialog(
        title: title,
        actions: _Actions(
          children: [
            WantButton(
              variant: WantButtonVariant.secondary,
              onPressed: _busy ? null : () => Navigator.of(context).pop(),
              child: Text(
                _done ? tr('Done', 'Готово') : tr('Cancel', 'Отмена'),
              ),
            ),
            if (!_done)
              if (widget.create)
                WantButton(
                  key: const ValueKey('backup-export-confirm'),
                  onPressed: _busy ? null : _export,
                  child: Text(tr('Choose folder', 'Выбрать папку')),
                )
              else if (review == null)
                WantButton(
                  key: const ValueKey('backup-preview'),
                  onPressed:
                      !_valid || _source == null || _mode == null || _busy
                      ? null
                      : () => _preview(),
                  child: Text(tr('Preview', 'Предпросмотр')),
                )
              else
                WantButton(
                  key: const ValueKey('backup-apply'),
                  onPressed:
                      _busy ||
                          !review.resolved ||
                          (_mode == BackupModeV1.replace && !_replaceConfirmed)
                      ? null
                      : _apply,
                  variant: _mode == BackupModeV1.replace
                      ? WantButtonVariant.destructive
                      : WantButtonVariant.primary,
                  child: Text(tr('Apply changes', 'Применить изменения')),
                ),
          ],
        ),
        child: Flexible(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                if (_done)
                  WantTypography(
                    widget.create
                        ? tr(
                            'Saved ${Uri.file(_source!).pathSegments.last}',
                            'Сохранён файл ${Uri.file(_source!).pathSegments.last}',
                          )
                        : tr('Backup restored.', 'Копия восстановлена.'),
                    liveRegion: true,
                  )
                else if (widget.create)
                  Text(
                    tr(
                      'Choose a folder for a new .wpassbackup file. It includes cards, groups, templates, services and available history. Keep your current recovery phrase to open it later.',
                      'Выберите папку для нового файла .wpassbackup. В него войдут карточки, группы, шаблоны, сервисы и доступная история. Для открытия понадобится текущая фраза восстановления.',
                    ),
                  )
                else if (review == null)
                  _options()
                else
                  _summary(review),
                if (_error != null)
                  WantTypography(
                    _error!,
                    colorRole: 'destructive',
                    liveRegion: true,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
