part of 'content.dart';

String _environmentLabel(EnvironmentV1 value) => switch (value) {
  EnvironmentV1.unitTests => 'unit-tests',
  EnvironmentV1.integrationTests => 'integration-tests',
  EnvironmentV1.e2eTests => 'e2e-tests',
  EnvironmentV1.preRelease => 'pre-release',
  _ => value.name,
};
String _fieldLabel(BuildContext context, FieldIdV1 field) => switch (field) {
  FieldIdV1.login => _text(context, 'Login / email', 'Логин / email'),
  FieldIdV1.password => _text(context, 'Password', 'Пароль'),
  FieldIdV1.totpSeed => _text(
    context,
    'TOTP key / otpauth URI',
    'Ключ TOTP / otpauth URI',
  ),
  FieldIdV1.totpAlgorithm => _text(context, 'Algorithm', 'Алгоритм'),
  FieldIdV1.totpDigits => _text(context, 'Digits', 'Количество цифр'),
  FieldIdV1.totpPeriod => _text(context, 'Period, seconds', 'Период, секунды'),
  FieldIdV1.recoveryCodes => _text(
    context,
    'Recovery codes, one per line',
    'Коды восстановления, по одному в строке',
  ),
  FieldIdV1.reserveLogins => _text(
    context,
    'Reserve logins / emails, one per line',
    'Резервные логины / email, по одному в строке',
  ),
  FieldIdV1.value => _text(context, 'Value', 'Значение'),
  FieldIdV1.publicKey => _text(context, 'Public key', 'Публичный ключ'),
  FieldIdV1.privateKey => _text(context, 'Private key', 'Закрытый ключ'),
  FieldIdV1.certificate => _text(context, 'Certificate', 'Сертификат'),
  FieldIdV1.clientId => 'Client ID',
  FieldIdV1.clientSecret => 'Client secret',
  FieldIdV1.accessToken => 'Access token',
  FieldIdV1.refreshToken => 'Refresh token',
  FieldIdV1.question => _text(context, 'Question', 'Вопрос'),
  FieldIdV1.answer => _text(context, 'Answer', 'Ответ'),
  FieldIdV1.keyId => _text(context, 'Key ID', 'ID ключа'),
  FieldIdV1.accessKeyId => _text(context, 'Access Key ID', 'ID ключа доступа'),
  FieldIdV1.sessionToken => _text(context, 'Session token', 'Токен сессии'),
  FieldIdV1.jsonKey => _text(context, 'JSON key', 'Ключ JSON'),
  FieldIdV1.project => _text(context, 'Project', 'Проект'),
  FieldIdV1.tenantId => _text(context, 'Tenant ID', 'ID клиента организации'),
  FieldIdV1.expiresAt => _text(
    context,
    'Expiry, YYYY-MM-DD or YYYY-MM-DDTHH:MM:SSZ',
    'Срок, ГГГГ-ММ-ДД или время UTC в ISO 8601',
  ),
  FieldIdV1.namespace => _text(context, 'Namespace', 'Пространство имён'),
  FieldIdV1.accountName => _text(
    context,
    'Service account',
    'Имя учётной записи',
  ),
  FieldIdV1.configuration => _text(context, 'Configuration', 'Конфигурация'),
  FieldIdV1.identity => _text(context, 'Identifier', 'Идентификатор'),
  FieldIdV1.containerFormat => _text(
    context,
    'Container format',
    'Формат контейнера',
  ),
  FieldIdV1.teamId => _text(context, 'Team ID', 'ID команды'),
  FieldIdV1.issuerId => _text(context, 'Issuer ID', 'ID издателя'),
  FieldIdV1.endpoint => _text(context, 'Host or address', 'Хост или адрес'),
  FieldIdV1.variables => _text(
    context,
    'NAME=value, one per line',
    'ИМЯ=значение, по одному в строке',
  ),
  FieldIdV1.url => _text(context, 'URL', 'URL'),
  FieldIdV1.domain => _text(context, 'Domain', 'Домен'),
  FieldIdV1.cookieName => _text(context, 'Cookie name', 'Имя cookie'),
  FieldIdV1.hotpSeed => _text(
    context,
    'HOTP seed, Base32',
    'Ключ HOTP, Base32',
  ),
  FieldIdV1.counter => _text(context, 'Counter', 'Счётчик'),
  FieldIdV1.product => _text(context, 'Product', 'Продукт'),
  FieldIdV1.ssid => _text(context, 'SSID', 'SSID'),
  FieldIdV1.device => _text(context, 'Device', 'Устройство'),
  FieldIdV1.pin => _text(context, 'PIN', 'PIN'),
  FieldIdV1.carrier => _text(context, 'Carrier', 'Оператор'),
  FieldIdV1.puk => _text(context, 'PUK', 'PUK'),
  FieldIdV1.cardNumber => _text(context, 'Card number', 'Номер карты'),
  FieldIdV1.holder => _text(context, 'Holder', 'Владелец'),
  FieldIdV1.expiryMonth => _text(context, 'Expiry, YYYY-MM', 'Срок, ГГГГ-ММ'),
  FieldIdV1.iban => _text(context, 'IBAN', 'IBAN'),
  FieldIdV1.accountNumber => _text(context, 'Account number', 'Номер счёта'),
  FieldIdV1.bic => _text(context, 'BIC', 'BIC'),
  FieldIdV1.documentType => _text(context, 'Document type', 'Тип документа'),
  FieldIdV1.documentNumber => _text(
    context,
    'Document number',
    'Номер документа',
  ),
  FieldIdV1.authority => _text(context, 'Issuing authority', 'Орган выдачи'),
  FieldIdV1.mnemonic => _text(context, 'Mnemonic words', 'Мнемоническая фраза'),
  FieldIdV1.walletPassphrase => _text(
    context,
    'Wallet passphrase',
    'Парольная фраза кошелька',
  ),
  FieldIdV1.network => _text(context, 'Network', 'Сеть'),
  FieldIdV1.address => _text(context, 'Public address', 'Публичный адрес'),
  FieldIdV1.scopes => _text(
    context,
    'Scopes, one per line',
    'Области доступа, по одной в строке',
  ),
};

final class _CardEditor extends StatefulWidget {
  final VaultController controller;
  final CardV1? card;
  final String? initialGroupId;
  final BigInt revision;
  final VoidCallback onDone;
  final VoidCallback? onCancel;
  final bool embedded;
  final VoidCallback? onDelete;
  const _CardEditor({
    super.key,
    required this.controller,
    required this.card,
    this.initialGroupId,
    required this.revision,
    required this.onDone,
    this.onCancel,
    this.embedded = false,
    this.onDelete,
  });
  @override
  State<_CardEditor> createState() => _CardEditorState();
}

final class _CardEditorState extends State<_CardEditor> {
  late final _name = TextEditingController(text: widget.card?.summary.name);
  late final _description = TextEditingController(
    text: widget.card?.description,
  );
  late final _values = {
    for (final id in FieldIdV1.values)
      id: TextEditingController(
        text:
            widget.card?.fields.where((f) => f.id == id).firstOrNull?.value ??
            switch (id) {
              FieldIdV1.totpAlgorithm => 'SHA1',
              FieldIdV1.totpDigits => '6',
              FieldIdV1.totpPeriod => '30',
              FieldIdV1.counter => '0',
              FieldIdV1.containerFormat => 'PKCS#12',
              _ => '',
            },
      ),
  };
  late final _initialValues = {
    for (final entry in _values.entries) entry.key: entry.value.text,
  };
  late final _groups = <String>{
    ...?widget.card?.summary.groupIds,
    if (widget.card == null && widget.initialGroupId != null)
      widget.initialGroupId!,
  };
  late CardTypeV1 _type = widget.card?.summary.cardType ?? CardTypeV1.account;
  late String? _service = widget.card?.summary.service;
  final _custom = _CardTemplateDraft();
  bool _ready = true;
  Future<void> _loadCustom() async {
    final summary = widget.card?.summary;
    if (summary == null || summary.cardType != CardTypeV1.custom) return;
    final template = widget.controller.state.content!.templates
        .where((t) => t.id == summary.customTemplateId)
        .firstOrNull;
    final version = template?.versions
        .where((v) => v.number == summary.templateVersion)
        .firstOrNull;
    if (template == null || version == null) return;
    final values = await widget.controller.readCustomValues(summary.id);
    if (!mounted || values == null) return;
    setState(() {
      _custom.select(template.id, version, values: values);
      _ready = true;
    });
  }

  late EnvironmentV1? _environment = widget.card?.summary.environment;
  late bool _totp = _values[FieldIdV1.totpSeed]!.text.isNotEmpty;
  late bool _recovery =
      _values[FieldIdV1.recoveryCodes]!.text.isNotEmpty ||
      _values[FieldIdV1.reserveLogins]!.text.isNotEmpty;
  AttachmentDraftV1? _attachment;
  bool _invalidKeyFile = false;
  bool _dirty = false, _more = false;
  bool get dirty => _dirty;
  @override
  void initState() {
    super.initState();
    if (_type == CardTypeV1.custom) {
      _ready = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(_loadCustom());
      });
    }
    for (final field in [_name, _description, ..._values.values]) {
      field.addListener(_edited);
    }
  }

  void _change(VoidCallback action) {
    setState(() {
      _dirty = true;
      action();
    });
  }

  void _edited() {
    if (mounted) {
      _dirty = true;
      _change(() {});
      widget.controller.activity();
    }
  }

  @override
  void dispose() {
    for (final field in [_name, _description, ..._values.values]) {
      field.removeListener(_edited);
      field.clear();
      field.dispose();
    }
    _custom.dispose();
    _groups.clear();
    _attachment = null;
    super.dispose();
  }

  Future<bool> _save() async {
    if (!_ready) return false;
    final spec = widget.controller.state.catalog!.presets
        .where((p) => p.cardType == _type)
        .firstOrNull;
    final fields = <CardFieldDraftV1>[];
    for (final field in spec?.fields ?? <FieldSpecV1>[]) {
      if (_type == CardTypeV1.account) {
        if ([
              FieldIdV1.totpSeed,
              FieldIdV1.totpAlgorithm,
              FieldIdV1.totpDigits,
              FieldIdV1.totpPeriod,
            ].contains(field.id) &&
            !_totp) {
          continue;
        }
        if ([
              FieldIdV1.recoveryCodes,
              FieldIdV1.reserveLogins,
            ].contains(field.id) &&
            !_recovery) {
          continue;
        }
      }
      fields.add(
        CardFieldDraftV1(id: field.id, value: _values[field.id]!.text),
      );
    }
    final draft = CardDraftV1(
      id: widget.card?.summary.id,
      name: _name.text,
      description: _description.text,
      service: _service ?? '',
      cardType: _type,
      environment: _environment,
      groupIds: List.unmodifiable(_groups),
      fields: List.unmodifiable(fields),
      attachment: _attachment,
    );
    final saved = _type == CardTypeV1.custom
        ? _custom.version != null &&
              await widget.controller.editCatalog(
                SaveCustomCardV1(
                  draft,
                  _custom.id!,
                  _custom.version!.number,
                  _custom.accepted,
                  _custom.input(),
                ),
                widget.revision,
              )
        : await widget.controller.saveCard(draft, revision: widget.revision);
    if (mounted && saved) widget.onDone();
    return saved;
  }

  Widget _customFields(
    BuildContext c,
    List<TemplateDefinitionV1> templates,
    bool busy,
  ) {
    if (!_ready) {
      return WantButton(
        variant: WantButtonVariant.secondary,
        onPressed: busy ? null : _loadCustom,
        child: Text(_text(c, 'Load card fields', 'Загрузить поля карточки')),
      );
    }
    final template = templates.where((t) => t.id == _custom.id).firstOrNull;
    if (template == null || _custom.version == null) {
      return const SizedBox.shrink();
    }
    return _CustomFields(
      draft: _custom,
      templates: templates,
      controller: widget.controller,
      existing: widget.card?.summary,
      busy: busy,
      onUpdate: (action) => _change(action),
    );
  }

  Future<void> _selectFile() async {
    final file = await widget.controller.selectAttachment();
    if (mounted &&
        file != null &&
        widget.controller.state.phase == VaultPhase.unlocked) {
      _change(() => _attachment = file);
    }
  }

  Future<void> _selectP8() async {
    final type = _type;
    final file = await widget.controller.selectAttachment();
    if (!mounted ||
        file == null ||
        type != _type ||
        widget.controller.state.phase != VaultPhase.unlocked) {
      return;
    }
    try {
      final value = utf8.decode(file.bytes);
      _change(() {
        _invalidKeyFile = false;
        _values[FieldIdV1.privateKey]!.text = value;
      });
    } on FormatException {
      setState(() => _invalidKeyFile = true);
    }
  }

  bool get _copyAllowed =>
      widget.card != null &&
      (_type != CardTypeV1.account ||
          (_totp ==
                  widget.card!.fields.any(
                    (f) => f.id == FieldIdV1.totpSeed && f.value.isNotEmpty,
                  ) &&
              _recovery ==
                  widget.card!.fields.any(
                    (f) =>
                        [
                          FieldIdV1.recoveryCodes,
                          FieldIdV1.reserveLogins,
                        ].contains(f.id) &&
                        f.value.isNotEmpty,
                  ))) &&
      _values.entries.every((entry) {
        return _initialValues[entry.key] == entry.value.text;
      });
  Widget _field(BuildContext context, FieldSpecV1 spec, bool busy) {
    final field = _values[spec.id]!;
    final label = _fieldLabel(context, spec.id) + (spec.required ? ' *' : '');
    final key = ValueKey(switch (spec.id) {
      FieldIdV1.login => 'account-login',
      FieldIdV1.password => 'account-password',
      _ => 'card-field-${spec.id.name}',
    });
    Widget input;
    if (spec.id == FieldIdV1.totpAlgorithm ||
        spec.id == FieldIdV1.containerFormat) {
      input = WantSelect<String>(
        key: key,
        value: field.text,
        options: [
          for (final value
              in spec.id == FieldIdV1.containerFormat
                  ? ['PKCS#12', 'JKS']
                  : ['SHA1', 'SHA256', 'SHA512'])
            WantOption(value: value, label: value),
        ],
        onChanged: busy
            ? null
            : (value) {
                if (value != null) field.text = value;
              },
        label: Text(label),
      );
    } else if (spec.concealed) {
      input = VaultSecretInput(
        key: key,
        label: label,
        controller: field,
        enabled: !busy,
        autofocus: false,
        last: false,
        preserveLineBreaks: true,
        protectClipboard: widget.card != null,
        onSubmitted: () => unawaited(_save()),
      );
    } else {
      input = VaultSecretInput(
        key: key,
        label: label,
        controller: field,
        enabled: !busy,
        autofocus: false,
        last: false,
        concealed: false,
        multiline: spec.multiline,
        protectClipboard: widget.card != null,
        onSubmitted: () => unawaited(_save()),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 4,
      children: [
        input,
        if (widget.card != null &&
            widget.card!.fields.any(
              (f) => f.id == spec.id && f.value.isNotEmpty,
            ))
          Align(
            alignment: Alignment.centerRight,
            child: _copyAllowed
                ? _CopyAction(
                    controller: widget.controller,
                    id: widget.card!.summary.id,
                    field: spec.id,
                    label: _text(
                      context,
                      'Copy saved: ${_fieldLabel(context, spec.id)}',
                      'Скопировать: ${_fieldLabel(context, spec.id)}',
                    ),
                  )
                : const SizedBox.shrink(),
          ),
      ],
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<VaultController, VaultState>(
    bloc: widget.controller,
    builder: (context, state) {
      final catalog = state.catalog;
      if (catalog == null) return const SizedBox.shrink();
      final spec = catalog.presets
          .where((p) => p.cardType == _type)
          .firstOrNull;
      final templates = state.content!.templates,
          services = state.content!.services;
      return _EditorFrame(
        embedded: widget.embedded,
        title: _text(
          context,
          widget.card == null ? 'New card' : 'Card',
          widget.card == null ? 'Новая карточка' : 'Карточка',
        ),
        actions: _Actions(
          children: [
            WantButton(
              key: const ValueKey('content-cancel'),
              variant: WantButtonVariant.secondary,
              onPressed: state.busy ? null : widget.onCancel ?? widget.onDone,
              child: Text(_text(context, 'Cancel', 'Отмена')),
            ),
            WantButton(
              key: const ValueKey('account-save'),
              onPressed: state.busy || !_ready || _service == null
                  ? null
                  : () => unawaited(_save()),
              child: Text(_text(context, 'Save', 'Сохранить')),
            ),
          ],
        ),
        child: Flexible(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: [
                _CatalogSelect<CardTypeV1>(
                  key: const ValueKey('card-type'),
                  value: _type,
                  label: _text(context, 'Type', 'Тип'),
                  enabled: widget.card == null && !state.busy,
                  values: [
                    ..._catalogTypes(catalog),
                    if (templates.isNotEmpty) CardTypeV1.custom,
                  ],
                  itemLabel: (value) => _typeLabel(context, value),
                  searchTerms: (value) => _types[value]!.$1,
                  itemIcon: _typeIcon,
                  onChanged: (value) {
                    if (value == null || value == _type) return;
                    for (final field in spec?.fields ?? <FieldSpecV1>[]) {
                      _values[field.id]!.text = _initialValues[field.id]!;
                    }
                    _change(() {
                      _type = value;
                      _ready = true;
                      if (value == CardTypeV1.custom) {
                        _custom.select(
                          templates.first.id,
                          templates.first.versions.last,
                        );
                      } else {
                        _custom.clear();
                      }
                      _attachment = null;
                      _invalidKeyFile = false;
                    });
                  },
                ),
                if (_type != CardTypeV1.account)
                  WantTypography(
                    _text(
                      context,
                      'Storage only. Tool integration is not enabled.',
                      'Хранение. Интеграция с инструментами не включена.',
                    ),
                    colorRole: 'muted-foreground',
                  ),
                WantInput(
                  key: const ValueKey('account-name'),
                  label: Text(_text(context, 'Name *', 'Название *')),
                  controller: _name,
                  enabled: !state.busy,
                  autofocus: true,
                ),
                _CatalogSelect<String>(
                  key: const ValueKey('card-service'),
                  value: _service,
                  label: _text(context, 'Service *', 'Сервис *'),
                  hint: _text(context, 'Choose a service', 'Выберите сервис'),
                  enabled: !state.busy,
                  values: [
                    ...catalog.services,
                    ...services
                        .where((s) => !s.archived || s.id == _service)
                        .map((s) => s.id),
                  ],
                  itemLabel: (service) =>
                      _serviceLabel(context, service, services),
                  searchTerms: (service) =>
                      '$service ${_serviceAliases(service)}',
                  itemIcon: (service) =>
                      _serviceIcon(context, service, services),
                  onChanged: (value) => _change(() => _service = value),
                ),
                if (_type == CardTypeV1.custom)
                  _customFields(context, templates, state.busy),
                for (final field in spec?.fields ?? <FieldSpecV1>[])
                  if (_type != CardTypeV1.account ||
                      (![
                        FieldIdV1.totpSeed,
                        FieldIdV1.totpAlgorithm,
                        FieldIdV1.totpDigits,
                        FieldIdV1.totpPeriod,
                        FieldIdV1.recoveryCodes,
                        FieldIdV1.reserveLogins,
                      ].contains(field.id)) ||
                      (_totp &&
                          [
                            FieldIdV1.totpSeed,
                            FieldIdV1.totpAlgorithm,
                            FieldIdV1.totpDigits,
                            FieldIdV1.totpPeriod,
                          ].contains(field.id)) ||
                      (_recovery &&
                          [
                            FieldIdV1.recoveryCodes,
                            FieldIdV1.reserveLogins,
                          ].contains(field.id)))
                    _field(context, field, state.busy),
                if (_type == CardTypeV1.account) ...[
                  WantCheckbox(
                    value: _totp,
                    label: Text(_text(context, 'TOTP', 'TOTP')),
                    onChanged: state.busy
                        ? null
                        : (value) => _change(() => _totp = value),
                  ),
                  WantCheckbox(
                    value: _recovery,
                    label: Text(
                      _text(context, 'Recovery data', 'Резервные данные'),
                    ),
                    onChanged: state.busy
                        ? null
                        : (value) => _change(() => _recovery = value),
                  ),
                  if (widget.card != null &&
                      widget.card!.fields.any(
                        (f) => f.id == FieldIdV1.totpSeed && f.value.isNotEmpty,
                      ))
                    _CardTotp(
                      controller: widget.controller,
                      id: widget.card!.summary.id,
                    ),
                  if (widget.card != null)
                    WantButton(
                      key: const ValueKey('card-copy-all'),
                      variant: WantButtonVariant.secondary,
                      onPressed: state.busy || !_copyAllowed
                          ? null
                          : () => unawaited(
                              widget.controller.copyCard(
                                widget.card!.summary.id,
                              ),
                            ),
                      child: Text(
                        _text(context, 'Copy all', 'Скопировать всё'),
                      ),
                    ),
                ],
                if ([
                  CardTypeV1.rsa,
                  CardTypeV1.ed25519,
                  CardTypeV1.gpg,
                  CardTypeV1.certificate,
                ].contains(_type))
                  WantTypography(
                    _text(
                      context,
                      'Encrypted keys are checked as containers. Their protected contents are not decrypted or verified.',
                      'Зашифрованные ключи проверяются как контейнеры. Их защищённое содержимое не расшифровывается и не проверяется.',
                    ),
                    colorRole: 'muted-foreground',
                  ),
                if (_type == CardTypeV1.apnsKey ||
                    _type == CardTypeV1.appStoreConnectKey) ...[
                  WantButton(
                    variant: WantButtonVariant.secondary,
                    onPressed: state.busy ? null : _selectP8,
                    child: Text(
                      _text(context, 'Choose .p8 key', 'Выбрать ключ .p8'),
                    ),
                  ),
                  if (_invalidKeyFile)
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        _text(
                          context,
                          'Choose a UTF-8 .p8 key file',
                          'Выберите файл ключа .p8 в UTF-8',
                        ),
                      ),
                    ),
                ],
                if (_type.requiresAttachment) ...[
                  WantTypography(
                    _attachment?.name ??
                        widget.card?.attachment?.name ??
                        _text(
                          context,
                          'Select a file up to 20 MiB',
                          'Выберите файл до 20 MiB',
                        ),
                  ),
                  if (_attachment != null || widget.card?.attachment != null)
                    Text(
                      '${_attachment?.bytes.length ?? widget.card!.attachment!.size} ${_text(context, 'bytes', 'байт')}',
                    ),
                  WantButton(
                    key: const ValueKey('card-file-select'),
                    variant: WantButtonVariant.secondary,
                    onPressed: state.busy
                        ? null
                        : () => unawaited(_selectFile()),
                    child: Text(_text(context, 'Choose file', 'Выбрать файл')),
                  ),
                  if (widget.card?.attachment != null)
                    WantButton(
                      key: const ValueKey('card-file-download'),
                      variant: WantButtonVariant.secondary,
                      onPressed: state.busy || _attachment != null
                          ? null
                          : () => unawaited(
                              widget.controller.downloadAttachment(
                                widget.card!.summary.id,
                                widget.card!.attachment!.name,
                              ),
                            ),
                      child: Text(
                        _text(context, 'Save file', 'Сохранить файл'),
                      ),
                    ),
                ],
                Semantics(
                  expanded: _more,
                  child: WantButton(
                    key: const ValueKey('card-more'),
                    variant: WantButtonVariant.ghost,
                    onPressed: () => setState(() => _more = !_more),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _text(
                              context,
                              'Details (optional)',
                              'Дополнительно',
                            ),
                          ),
                        ),
                        Icon(
                          _more ? Icons.expand_less : Icons.expand_more,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                if (_more) ...[
                  WantInput(
                    key: const ValueKey('account-description'),
                    label: Text(_text(context, 'Description', 'Описание')),
                    controller: _description,
                    enabled: !state.busy,
                    maxLines: 3,
                  ),
                  WantSelect<String>(
                    key: const ValueKey('card-environment'),
                    value: _environment?.name ?? 'none',
                    label: Text(_text(context, 'Environment', 'Окружение')),
                    enabled: !state.busy,
                    options: [
                      WantOption(
                        value: 'none',
                        label: _text(
                          context,
                          'No environment',
                          'Без окружения',
                        ),
                      ),
                      for (final value in EnvironmentV1.values)
                        WantOption(
                          value: value.name,
                          label: _environmentLabel(value),
                        ),
                    ],
                    onChanged: (value) => _change(
                      () => _environment = value == null || value == 'none'
                          ? null
                          : EnvironmentV1.values.byName(value),
                    ),
                  ),
                  WantTypography(_text(context, 'Groups', 'Группы')),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final group in state.content!.groups)
                        Semantics(
                          selected: _groups.contains(group.id),
                          child: WantButton(
                            key: ValueKey('account-group-${group.id}'),
                            variant: _groups.contains(group.id)
                                ? WantButtonVariant.primary
                                : WantButtonVariant.secondary,
                            onPressed: state.busy
                                ? null
                                : () => _change(() {
                                    _dirty = true;
                                    if (!_groups.add(group.id)) {
                                      _groups.remove(group.id);
                                    }
                                  }),
                            child: Text(group.name),
                          ),
                        ),
                    ],
                  ),
                ],
                _ContentError(state.error),
                if (widget.card != null)
                  WantButton(
                    key: const ValueKey('account-delete'),
                    variant: WantButtonVariant.destructive,
                    onPressed: state.busy ? null : widget.onDelete,
                    child: Text(
                      _text(context, 'Delete card', 'Удалить карточку'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

final class _CardTotp extends StatefulWidget {
  final VaultController controller;
  final String id;
  const _CardTotp({required this.controller, required this.id});
  @override
  State<_CardTotp> createState() => _CardTotpState();
}

final class _CardTotpState extends State<_CardTotp>
    with WidgetsBindingObserver {
  Timer? _timer;
  TotpCodeV1? _code;
  bool _loading = false;
  bool _foreground = true;
  bool _visible = false;
  bool _requiresReveal = false;
  int _epoch = 0;
  bool get _active => _foreground && _visible;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final visible = TickerMode.valuesOf(context).enabled;
    if (_visible == visible) return;
    _visible = visible;
    _activationChanged();
  }

  void _activationChanged() {
    _epoch++;
    _timer?.cancel();
    _code = null;
    if (_active) unawaited(_refresh());
  }

  void _schedule() {
    _timer?.cancel();
    if (!mounted || !_active || (_requiresReveal && _code == null)) return;
    final remaining = _code?.validUntil.difference(DateTime.now().toUtc());
    final delay = remaining != null && remaining < const Duration(seconds: 1)
        ? (remaining > Duration.zero ? remaining : Duration.zero)
        : const Duration(seconds: 1);
    _timer = Timer(delay, () {
      if (!mounted || !_active) return;
      if (_code == null ||
          !DateTime.now().toUtc().isBefore(_code!.validUntil)) {
        setState(() => _code = null);
        if (!_requiresReveal) unawaited(_refresh());
      } else {
        setState(() {});
      }
      _schedule();
    });
  }

  Future<void> _refresh({bool explicitReveal = false}) async {
    if (_loading || !_active) return;
    final epoch = _epoch;
    _loading = true;
    try {
      final code = explicitReveal
          ? await widget.controller.readTotp(widget.id)
          : (await widget.controller.readCardPreview(widget.id))?.row.otp;
      if (mounted && _active && epoch == _epoch) {
        setState(() {
          if (!explicitReveal) _requiresReveal = code == null;
          _code =
              code != null && DateTime.now().toUtc().isBefore(code.validUntil)
              ? code
              : null;
        });
      }
    } finally {
      _loading = false;
      _schedule();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    setState(_activationChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _code = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now().toUtc();
    final code = _active && _code != null && now.isBefore(_code!.validUntil)
        ? _code
        : null;
    final remaining = code == null
        ? 0
        : (code.validUntil.difference(now).inMilliseconds / 1000).ceil();
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WantTypography(
                code?.code ?? '••••••',
                variant: WantTypographyVariant.h3,
              ),
              if (code != null)
                Text(
                  _text(
                    context,
                    'Refresh in ${remaining.clamp(0, 86400)} s',
                    'Обновление через ${remaining.clamp(0, 86400)} с',
                  ),
                ),
            ],
          ),
        ),
        if (_requiresReveal && code == null)
          IconButton(
            tooltip: _text(context, 'Show current OTP', 'Показать текущий OTP'),
            onPressed: _loading || widget.controller.state.busy
                ? null
                : () => _refresh(explicitReveal: true),
            icon: const Icon(Icons.visibility_outlined),
          ),
        IconButton(
          key: const ValueKey('card-copy-otp'),
          tooltip: _text(
            context,
            'Copy current OTP',
            'Скопировать текущий OTP',
          ),
          onPressed:
              (code == null && !_requiresReveal) || widget.controller.state.busy
              ? null
              : () => unawaited(
                  widget.controller.copyCard(widget.id, currentOtp: true),
                ),
          icon: const Icon(Icons.copy_outlined),
        ),
      ],
    );
  }
}
