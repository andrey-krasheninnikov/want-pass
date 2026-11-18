part of 'content.dart';

enum _VaultSection {
  secrets('Secrets', 'Секреты', Icons.lock_outline),
  services('Services', 'Сервисы', Icons.apps_outlined),
  types('Types', 'Типы', Icons.category_outlined),
  environments('Environments', 'Окружения', Icons.layers_outlined),
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
  final CardCatalogV1 catalog;
  final AppearanceController? appearance;

  const _VaultSectionView({
    super.key,
    required this.section,
    required this.catalog,
    required this.appearance,
  });

  @override
  Widget build(BuildContext context) {
    final child = switch (section) {
      _VaultSection.services => _CatalogPanel(
        addLabel: _text(context, 'Add service', 'Добавить сервис'),
        label: _text(context, 'Built-in services', 'Встроенные сервисы'),
        entries: [
          for (final service in catalog.services)
            Text(_serviceLabel(context, service)),
        ],
      ),
      _VaultSection.types => _CatalogPanel(
        addLabel: _text(context, 'Add type', 'Добавить тип'),
        label: _text(context, 'Built-in types', 'Встроенные типы'),
        entries: [
          for (final preset in catalog.presets)
            Text(_typeLabel(context, preset.cardType)),
        ],
      ),
      _VaultSection.environments => _CatalogPanel(
        addLabel: _text(context, 'Add environment', 'Добавить окружение'),
        label: _text(context, 'Built-in environments', 'Встроенные окружения'),
        entries: [
          for (final environment in EnvironmentV1.values)
            Text(_environmentLabel(environment)),
        ],
      ),
      _VaultSection.resources => _SectionPanel(
        title: _text(context, 'No target resources', 'Нет ресурсов назначения'),
        content: _UnavailableAction(
          _text(context, 'Add resource', 'Добавить ресурс'),
        ),
      ),
      _VaultSection.integrations => _SectionPanel(
        title: _text(context, 'No integrations', 'Нет интеграций'),
        content: _UnavailableAction(
          _text(context, 'Add integration', 'Добавить интеграцию'),
        ),
      ),
      _VaultSection.ai => const _AISettingsView(),
      _VaultSection.general => _SectionPanel(
        title: _text(context, 'Appearance', 'Оформление'),
        content: appearance == null
            ? null
            : AppearanceControls(controller: appearance!),
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
        _UnavailableAction(addLabel),
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
