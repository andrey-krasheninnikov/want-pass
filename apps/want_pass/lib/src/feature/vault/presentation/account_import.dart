part of 'content.dart';

Future<void> showAccountImportDialog(
  BuildContext context,
  VaultController controller,
) async {
  final revision = controller.state.content?.revision;
  if (controller.state.phase != VaultPhase.unlocked || revision == null) return;
  final navigator = Navigator.of(context, rootNavigator: true);
  late final DialogRoute<void> route;
  void close() {
    if (route.isCurrent) {
      navigator.pop();
    } else if (route.isActive) {
      navigator.removeRoute(route);
    }
  }

  route = DialogRoute<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _AccountImportDialog(controller: controller, onDone: close),
  );
  final closed = navigator.push(route);
  final subscription = controller.stream.listen((state) {
    if (state.phase != VaultPhase.unlocked ||
        state.content?.revision != revision) {
      if (route.isActive) navigator.removeRoute(route);
    }
  });
  try {
    await closed;
  } finally {
    await subscription.cancel();
  }
}

final class _AccountImportDialog extends StatefulWidget {
  final VaultController controller;
  final VoidCallback onDone;

  const _AccountImportDialog({required this.controller, required this.onDone});

  @override
  State<_AccountImportDialog> createState() => _AccountImportDialogState();
}

final class _AccountImportDialogState extends State<_AccountImportDialog> {
  AccountImportPreviewV1? _preview;
  final _selected = <int>{};
  bool _busy = false;
  bool _failed = false;

  @override
  void dispose() {
    final preview = _preview;
    if (preview != null) {
      unawaited(widget.controller.cancelAccountImport(preview.token));
    }
    super.dispose();
  }

  Future<void> _choose(
    AccountImportSourceV1 source, {
    bool clipboard = false,
  }) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _failed = false;
    });
    final controller = widget.controller;
    final preview = await controller.prepareAccountImport(
      source,
      clipboard: clipboard,
    );
    if (!mounted) {
      if (preview != null) await controller.cancelAccountImport(preview.token);
      return;
    }
    setState(() {
      _busy = false;
      _preview = preview;
      _failed = preview == null && controller.state.error != null;
      if (preview != null) {
        for (final (i, row) in preview.rows.indexed) {
          if (!row.duplicate) _selected.add(i);
        }
      }
    });
  }

  Future<void> _apply() async {
    final preview = _preview;
    if (_busy || preview == null) return;
    setState(() => _busy = true);
    final applied = await widget.controller.applyAccountImport(
      preview.token,
      _selected.toList(),
    );
    if (!mounted) return;
    _preview = null;
    if (applied) {
      widget.onDone();
    } else {
      setState(() {
        _busy = false;
        _failed = true;
        _selected.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final preview = _preview;
    return PopScope<void>(
      canPop: !_busy,
      child: WantDialog(
        title: _text(context, 'Import accounts', 'Импорт учётных записей'),
        actions: _Actions(
          children: [
            WantButton(
              variant: WantButtonVariant.secondary,
              onPressed: _busy ? null : widget.onDone,
              child: Text(_text(context, 'Cancel', 'Отмена')),
            ),
            if (preview != null)
              WantButton(
                key: const ValueKey('account-import-apply'),
                onPressed: _busy ? null : _apply,
                child: Text(
                  _text(
                    context,
                    'Import (${_selected.length})',
                    'Импортировать (${_selected.length})',
                  ),
                ),
              ),
          ],
        ),
        child: Flexible(
          child: preview == null
              ? SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 12,
                    children: [
                      Text(
                        _text(
                          context,
                          'Apple Passwords imports logins, passwords, website addresses and notes. Passkeys and verification codes stay in Apple Passwords.',
                          'Из Apple Passwords переносятся логины, пароли, адреса сайтов и заметки. Ключи входа и коды подтверждения остаются в Apple Passwords.',
                        ),
                      ),
                      WantButton(
                        key: const ValueKey('account-import-apple'),
                        variant: WantButtonVariant.secondary,
                        onPressed: _busy
                            ? null
                            : () =>
                                  _choose(AccountImportSourceV1.applePasswords),
                        child: Text(
                          _text(
                            context,
                            'Choose Apple Passwords CSV',
                            'Выбрать CSV из Apple Passwords',
                          ),
                        ),
                      ),
                      Text(
                        _text(
                          context,
                          'For Google Authenticator, select all parts of an export together. You can also paste setup links, one per line.',
                          'Для Google Authenticator выберите все изображения одного экспорта сразу. Ссылки настройки также можно вставить по одной на строку.',
                        ),
                      ),
                      WantButton(
                        key: const ValueKey('account-import-images'),
                        variant: WantButtonVariant.secondary,
                        onPressed: _busy
                            ? null
                            : () =>
                                  _choose(AccountImportSourceV1.authenticator),
                        child: Text(
                          _text(
                            context,
                            'Choose QR images',
                            'Выбрать изображения QR',
                          ),
                        ),
                      ),
                      WantButton(
                        key: const ValueKey('account-import-clipboard'),
                        variant: WantButtonVariant.secondary,
                        onPressed: _busy
                            ? null
                            : () => _choose(
                                AccountImportSourceV1.authenticator,
                                clipboard: true,
                              ),
                        child: Text(
                          _text(
                            context,
                            'Paste setup links',
                            'Вставить ссылки настройки',
                          ),
                        ),
                      ),
                      if (_failed)
                        WantTypography(
                          _text(
                            context,
                            'Import could not finish. Check the file format and include every part of the same QR export.',
                            'Импорт не завершён. Проверьте формат файла и выберите все части одного QR-экспорта.',
                          ),
                          colorRole: 'destructive',
                          liveRegion: true,
                        ),
                    ],
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: preview.rows.length,
                  itemBuilder: (context, index) {
                    final row = preview.rows[index];
                    return WantCheckbox(
                      key: ValueKey('account-import-row-$index'),
                      value: _selected.contains(index),
                      enabled: !_busy,
                      onChanged: (selected) => setState(() {
                        if (selected) {
                          _selected.add(index);
                        } else {
                          _selected.remove(index);
                        }
                      }),
                      label: Text(
                        row.duplicate
                            ? _text(
                                context,
                                '${row.name} · Add a copy',
                                '${row.name} · Добавить копию',
                              )
                            : row.name,
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
