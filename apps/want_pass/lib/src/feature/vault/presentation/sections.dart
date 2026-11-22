part of 'content.dart';

enum _VaultSection {
  secrets('Secrets', 'Секреты', Icons.lock_outline),
  services('Services', 'Сервисы', Icons.apps_outlined),
  types('Types', 'Типы', Icons.category_outlined),
  environments('Environments', 'Окружения', Icons.layers_outlined),
  history('History', 'История', Icons.history),
  resources('Target resources', 'Ресурсы назначения', Icons.adjust),
  integrations('Integrations', 'Интеграции', Icons.extension_outlined),
  ai('AI settings', 'Настройки AI', Icons.auto_awesome_outlined),
  general('General settings', 'Общие настройки', Icons.settings_outlined);

  final String en, ru;
  final IconData icon;
  const _VaultSection(this.en, this.ru, this.icon);

  String label(BuildContext context) => _text(context, en, ru);
}

final class _VaultSectionView extends StatelessWidget {
  final _VaultSection section;
  final VaultController controller;
  final CardCatalogV1 catalog;
  final AppearanceController? appearance;
  final VoidCallback? onReset;
  final ValueChanged<bool>? onBackup;

  const _VaultSectionView({
    super.key,
    required this.section,
    required this.controller,
    required this.catalog,
    required this.appearance,
    required this.onReset,
    required this.onBackup,
  });

  @override
  Widget build(BuildContext context) {
    final child = switch (section) {
      _VaultSection.services => _ManagedCatalog(
        controller: controller,
        services: true,
        builtins: _CatalogPanel(
          addLabel: '',
          label: _text(context, 'Built-in services', 'Встроенные сервисы'),
          entries: [
            for (final service in catalog.services.where((id) => id != 'other'))
              _catalogLabel(
                _serviceIcon(context, service),
                _serviceLabel(context, service),
              ),
          ],
        ),
      ),
      _VaultSection.types => _ManagedCatalog(
        controller: controller,
        services: false,
        builtins: _CatalogPanel(
          addLabel: '',
          label: _text(context, 'Built-in types', 'Встроенные типы'),
          entries: [
            for (final type in _catalogTypes(catalog))
              _catalogLabel(_typeIcon(type), _typeLabel(context, type)),
            _catalogLabel(
              const Icon(Icons.lock_person_outlined, size: 20),
              _text(
                context,
                'Passkey · requires a system provider',
                'Passkey · требуется системный провайдер',
              ),
            ),
          ],
        ),
      ),
      _VaultSection.environments => _CatalogPanel(
        addLabel: _text(context, 'Add environment', 'Добавить окружение'),
        label: _text(context, 'Built-in environments', 'Встроенные окружения'),
        entries: [
          for (final environment in EnvironmentV1.values)
            Text(_environmentLabel(environment)),
        ],
      ),
      _VaultSection.resources => _ResourceEditor(controller: controller),
      _VaultSection.history => _HistoryBrowser(controller: controller),
      _VaultSection.integrations => _LocalToolsSettings(controller: controller),
      _VaultSection.ai => const _AISettingsView(),
      _VaultSection.general => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          _SectionPanel(
            title: _text(context, 'Security', 'Безопасность'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WantButton(
                  onPressed: () => showProtectionSettings(context, controller),
                  child: Text(
                    _text(
                      context,
                      'External authenticator',
                      'Внешний аутентификатор',
                    ),
                  ),
                ),
                _BiometrySettings(controller),
              ],
            ),
          ),
          _SectionPanel(
            title: _text(context, 'Import accounts', 'Импорт учётных записей'),
            content: WantButton(
              onPressed: () => showAccountImportDialog(context, controller),
              child: Text(
                _text(
                  context,
                  'Apple Passwords or Google Authenticator',
                  'Пароли Apple или Google Authenticator',
                ),
              ),
            ),
          ),
          if (defaultTargetPlatform == TargetPlatform.macOS)
            const _ShortcutSettings(),
          _SectionPanel(
            title: _text(context, 'Appearance', 'Оформление'),
            content: appearance == null
                ? null
                : AppearanceControls(controller: appearance!),
          ),
          _SectionPanel(
            title: _text(context, 'Backups', 'Резервные копии'),
            content: _Actions(
              children: [
                WantButton(
                  key: const ValueKey('vault-backup-export'),
                  onPressed: onBackup == null ? null : () => onBackup!(true),
                  child: Text(_text(context, 'Export backup', 'Экспорт копии')),
                ),
                WantButton(
                  key: const ValueKey('vault-backup-restore'),
                  variant: WantButtonVariant.secondary,
                  onPressed: onBackup == null ? null : () => onBackup!(false),
                  child: Text(
                    _text(context, 'Restore backup', 'Восстановление из копии'),
                  ),
                ),
              ],
            ),
          ),
          if (appearance != null)
            _SectionPanel(
              title: _text(context, 'Local data', 'Локальные данные'),
              content: Align(
                alignment: AlignmentDirectional.centerStart,
                child: WantButton(
                  key: const ValueKey('vault-reset-open'),
                  variant: WantButtonVariant.destructive,
                  pill: false,
                  onPressed: onReset,
                  child: Text(
                    _text(context, 'Reset app', 'Сбросить приложение'),
                  ),
                ),
              ),
            ),
        ],
      ),
      _VaultSection.secrets => const SizedBox.shrink(),
    };
    return SingleChildScrollView(
      key: ValueKey('vault-section-${section.name}'),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Align(
        alignment: AlignmentDirectional.topStart,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              Semantics(
                header: true,
                child: WantTypography(
                  section.label(context),
                  variant: WantTypographyVariant.h2,
                ),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

final class _ResetVaultDialog extends StatefulWidget {
  final VaultController controller;
  final Future<bool> Function(String phrase) onReset;

  const _ResetVaultDialog({required this.controller, required this.onReset});

  @override
  State<_ResetVaultDialog> createState() => _ResetVaultDialogState();
}

final class _ResetVaultDialogState extends State<_ResetVaultDialog> {
  final _phrase = TextEditingController();
  bool _busy = false, _failed = false, _valid = false;

  @override
  void dispose() {
    _phrase.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || !_valid) return;
    setState(() {
      _busy = true;
      _failed = false;
    });
    final reset = await widget.onReset(_phrase.text);
    if (!mounted) return;
    if (reset) {
      _phrase.clear();
      return;
    }
    setState(() {
      _busy = false;
      _failed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final error = widget.controller.state.error;
    final rejected =
        error is VaultRejectedErrorV1 &&
        (error.kind == VaultFailureKindV1.credentials ||
            error.kind == VaultFailureKindV1.invalidPhrase);
    return PopScope<void>(
      canPop: !_busy,
      child: WantDialog(
        title: _text(context, 'Reset app', 'Сброс приложения'),
        actions: _Actions(
          children: [
            WantButton(
              variant: WantButtonVariant.secondary,
              onPressed: _busy ? null : () => Navigator.of(context).pop(),
              child: Text(_text(context, 'Cancel', 'Отмена')),
            ),
            WantButton(
              key: const ValueKey('vault-reset-confirm'),
              variant: WantButtonVariant.destructive,
              onPressed: _busy || !_valid ? null : () => unawaited(_submit()),
              child: Text(
                _text(context, 'Erase local data', 'Удалить локальные данные'),
              ),
            ),
          ],
        ),
        child: Flexible(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                Text(
                  _text(
                    context,
                    'This permanently deletes the local vault and device settings. Enter your recovery phrase as words or numbered JSON.',
                    'Локальный сейф и настройки устройства будут удалены без возможности отмены. Введите фразу восстановления словами или в виде JSON с номерами.',
                  ),
                ),
                RecoveryPhraseInput(
                  key: const ValueKey('vault-reset-phrase'),
                  controller: _phrase,
                  inspect: widget.controller.inspectRecoveryWords,
                  enabled: !_busy,
                  onValidChanged: (valid) => setState(() {
                    _valid = valid;
                    _failed = false;
                  }),
                ),
                if (_failed)
                  WantTypography(
                    rejected
                        ? _text(
                            context,
                            'Check your recovery phrase.',
                            'Проверьте фразу восстановления.',
                          )
                        : _text(
                            context,
                            'Could not reset the app. Try again.',
                            'Не удалось сбросить приложение. Попробуйте ещё раз.',
                          ),
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

final class _CatalogPanel extends StatelessWidget {
  final String label, addLabel;
  final List<Widget> entries;
  const _CatalogPanel({
    required this.label,
    required this.addLabel,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) => _SectionPanel(
    title: label,
    content: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final entry in entries)
              DecoratedBox(
                decoration: BoxDecoration(
                  color: WantTheme.of(context).color('muted'),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: entry,
                ),
              ),
          ],
        ),
        if (addLabel.isNotEmpty) _UnavailableAction(addLabel),
      ],
    ),
  );
}

final class _SectionPanel extends StatelessWidget {
  final String title;
  final String? description;
  final Widget? content;
  const _SectionPanel({required this.title, this.description, this.content});

  @override
  Widget build(BuildContext context) => WantCard(
    hoverEffect: false,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Semantics(
          header: true,
          child: WantTypography(title, variant: WantTypographyVariant.h3),
        ),
        if (description != null)
          WantTypography(description!, colorRole: 'muted-foreground'),
        ?content,
      ],
    ),
  );
}

final class _AISettingsView extends StatelessWidget {
  const _AISettingsView();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 12,
    children: [
      _SectionPanel(
        title: _text(context, 'Provider and model', 'Провайдер и модель'),
        content: Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _UnavailableAction(
              _text(context, 'Select provider', 'Выбрать провайдера'),
            ),
            _UnavailableAction(
              _text(context, 'Select model', 'Выбрать модель'),
            ),
          ],
        ),
      ),
      _SectionPanel(
        title: _text(context, 'MCP clients', 'Клиенты MCP'),
        description: _text(
          context,
          'No clients connected',
          'Нет подключённых клиентов',
        ),
        content: _UnavailableAction(
          _text(context, 'Add client', 'Добавить клиента'),
        ),
      ),
      _SectionPanel(
        title: _text(context, 'Vault permissions', 'Разрешения сейфа'),
        description: _text(
          context,
          'No external access granted',
          'Внешний доступ не предоставлен',
        ),
      ),
    ],
  );
}

final class _UnavailableAction extends StatelessWidget {
  final String label;
  const _UnavailableAction(this.label);

  @override
  Widget build(BuildContext context) => Align(
    alignment: AlignmentDirectional.centerStart,
    child: WantButton(
      variant: WantButtonVariant.secondary,
      onPressed: null,
      child: Text(label),
    ),
  );
}
