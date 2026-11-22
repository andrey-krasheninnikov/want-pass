part of 'content.dart';

final class _ShortcutSettings extends StatefulWidget {
  const _ShortcutSettings();
  @override
  State<_ShortcutSettings> createState() => _ShortcutSettingsState();
}

final class _ShortcutSettingsState extends State<_ShortcutSettings> {
  Map? configuration;
  bool failed = false, busy = false;
  @override
  void initState() {
    super.initState();
    unawaited(update());
  }

  Future<void> update([String? name, String? chord]) async {
    if (busy) return;
    setState(() => busy = true);
    try {
      final result = await VaultQuickAccess.channel
          .invokeMapMethod<Object?, Object?>(
            name == null ? 'configuration' : 'change',
            name == null ? null : {'name': name, 'chord': chord},
          );
      if (mounted) {
        setState(() {
          configuration = result;
          failed = result == null;
        });
      }
    } on PlatformException {
      if (mounted) setState(() => failed = true);
    } on MissingPluginException {
      if (mounted) setState(() => failed = true);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext c) {
    final options = <String, String>{'off': _text(c, 'Off', 'Выключено')};
    for (final o in configuration?['options'] as List? ?? []) {
      if (o is Map && o['id'] is String && o['label'] is String) {
        options[o['id'] as String] = o['label'] as String;
      }
    }
    final selected = configuration?['selected'] as Map? ?? {},
        errors = configuration?['errors'] as Map? ?? {};
    return _SectionPanel(
      title: _text(c, 'Global shortcuts', 'Глобальные сочетания клавиш'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          if (failed)
            Text(
              _text(
                c,
                'macOS could not register global shortcuts.',
                'macOS не удалось зарегистрировать глобальные сочетания.',
              ),
            ),
          for (final name in ['search', 'create']) ...[
            _pick<String>(
              c,
              name == 'search'
                  ? _text(c, 'Search near the cursor', 'Поиск у курсора')
                  : _text(c, 'New card', 'Новая карточка'),
              selected[name] as String?,
              options.keys,
              (id) => options[id] ?? id,
              (id) => update(name, id),
              enabled: configuration != null && !busy,
            ),
            if (errors[name] != null)
              Text(
                errors[name] == 'conflict'
                    ? _text(
                        c,
                        'This shortcut is already in use. Choose another combination.',
                        'Это сочетание уже занято. Выберите другое.',
                      )
                    : _text(
                        c,
                        'macOS denied shortcut registration. Check the keyboard settings or choose another combination.',
                        'macOS отказала в регистрации. Проверьте настройки клавиатуры или выберите другое сочетание.',
                      ),
              ),
          ],
        ],
      ),
    );
  }
}
