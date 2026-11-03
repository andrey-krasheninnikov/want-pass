part of 'content.dart';

String _serviceLabel(BuildContext context, String id) => id == 'other'
    ? _text(context, 'Other', 'Другое')
    : const {
            'microsoft': 'Microsoft',
            'google': 'Google',
            'apple': 'Apple',
            'github': 'GitHub',
            'gitlab': 'GitLab',
            'atlassian': 'Atlassian',
            'jira': 'Jira',
            'confluence': 'Confluence',
            'telegram': 'Telegram',
            'aws': 'AWS',
            'azure': 'Azure',
            'gcp': 'GCP',
            'cloudflare': 'Cloudflare',
            'docker': 'Docker',
            'ghcr': 'GHCR',
            'npm': 'npm',
            'pypi': 'PyPI',
            'crates-io': 'crates.io',
            'firebase': 'Firebase',
            'supabase': 'Supabase',
            'sentry': 'Sentry',
          }[id] ??
          id;
String _environmentLabel(EnvironmentV1 value) => switch (value) {
  EnvironmentV1.unitTests => 'unit-tests',
  EnvironmentV1.integrationTests => 'integration-tests',
  EnvironmentV1.e2eTests => 'e2e-tests',
  EnvironmentV1.preRelease => 'pre-release',
  _ => value.name,
};
String _typeLabel(BuildContext context, CardTypeV1 type) => switch (type) {
  CardTypeV1.account => _text(context, 'Account', 'Учётная запись'),
  CardTypeV1.pat => 'PAT',
  CardTypeV1.rsa => 'RSA',
  CardTypeV1.ed25519 => 'Ed25519',
  CardTypeV1.secretKey => _text(context, 'Secret key', 'Секретный ключ'),
  CardTypeV1.passphrase => _text(context, 'Passphrase', 'Парольная фраза'),
  CardTypeV1.recoveryCodes => _text(
    context,
    'Recovery codes',
    'Коды восстановления',
  ),
  CardTypeV1.recoveryUrl => 'Recovery URL',
  CardTypeV1.secretQa => _text(context, 'Secret question', 'Секретный вопрос'),
  CardTypeV1.vless => 'VLESS',
  CardTypeV1.wireGuard => 'WireGuard',
  CardTypeV1.gpg => 'GPG',
  CardTypeV1.certificate => _text(
    context,
    'Certificate and key',
    'Сертификат и ключ',
  ),
  CardTypeV1.oauth => 'OAuth',
  CardTypeV1.dsn => 'DSN',
  CardTypeV1.kubeconfig => 'kubeconfig',
  CardTypeV1.webhookSecret => _text(
    context,
    'Webhook signing secret',
    'Ключ подписи webhook',
  ),
  CardTypeV1.secureNote => _text(context, 'Secure note', 'Защищённая заметка'),
  CardTypeV1.file => _text(context, 'Secure file', 'Защищённый файл'),
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
  FieldIdV1.certificate => _text(
    context,
    'Certificate, PEM',
    'Сертификат, PEM',
  ),
  FieldIdV1.clientId => 'Client ID',
  FieldIdV1.clientSecret => 'Client secret',
  FieldIdV1.accessToken => 'Access token',
  FieldIdV1.refreshToken => 'Refresh token',
  FieldIdV1.question => _text(context, 'Question', 'Вопрос'),
  FieldIdV1.answer => _text(context, 'Answer', 'Ответ'),
};

final class _CardEditor extends StatefulWidget {
  final VaultController controller;
  final CardV1? card;
  final String? initialGroupId;
  final BigInt revision;
  final VoidCallback onDone;
  final VoidCallback? onDelete;
  const _CardEditor({
    required this.controller,
    required this.card,
    this.initialGroupId,
    required this.revision,
    required this.onDone,
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
  late EnvironmentV1? _environment = widget.card?.summary.environment;
  late bool _totp = _values[FieldIdV1.totpSeed]!.text.isNotEmpty;
  late bool _recovery =
      _values[FieldIdV1.recoveryCodes]!.text.isNotEmpty ||
      _values[FieldIdV1.reserveLogins]!.text.isNotEmpty;
  AttachmentDraftV1? _attachment;
  @override
  void initState() {
    super.initState();
    for (final field in [_name, _description, ..._values.values]) {
      field.addListener(_edited);
    }
  }

  void _edited() {
    if (mounted) {
      setState(() {});
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
    _groups.clear();
    _attachment = null;
    super.dispose();
  }

  Future<void> _save() async {
    final spec = widget.controller.state.catalog!.presets.firstWhere(
      (p) => p.cardType == _type,
    );
    final fields = <CardFieldDraftV1>[];
    for (final field in spec.fields) {
      if (_type == CardTypeV1.account) {
        if ([
              FieldIdV1.totpSeed,
              FieldIdV1.totpAlgorithm,
              FieldIdV1.totpDigits,
              FieldIdV1.totpPeriod,
            ].contains(field.id) &&
            (!_totp || _values[FieldIdV1.totpSeed]!.text.isEmpty)) {
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
    final saved = await widget.controller.saveCard(
      CardDraftV1(
        id: widget.card?.summary.id,
        name: _name.text,
        description: _description.text,
        service: _service ?? '',
        cardType: _type,
        environment: _environment,
        groupIds: List.unmodifiable(_groups),
        fields: List.unmodifiable(fields),
        attachment: _attachment,
      ),
      revision: widget.revision,
    );
    if (mounted && saved) widget.onDone();
  }

  Future<void> _selectFile() async {
    final file = await widget.controller.selectAttachment();
    if (mounted &&
        file != null &&
        widget.controller.state.phase == VaultPhase.unlocked) {
      setState(() => _attachment = file);
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
    if (spec.id == FieldIdV1.totpAlgorithm) {
      input = WantSelect<String>(
        key: key,
        value: field.text,
        options: [
          for (final value in ['SHA1', 'SHA256', 'SHA512'])
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
            child: IconButton(
              tooltip: _text(
                context,
                'Copy saved: ${_fieldLabel(context, spec.id)}',
                'Скопировать: ${_fieldLabel(context, spec.id)}',
              ),
              onPressed: busy || !_copyAllowed
                  ? null
                  : () => unawaited(
                      widget.controller.copyCard(
                        widget.card!.summary.id,
                        field: spec.id,
                      ),
                    ),
              icon: const Icon(Icons.copy_outlined),
            ),
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
      final spec = catalog.presets.firstWhere((p) => p.cardType == _type);
      return WantDialog(
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
              onPressed: state.busy ? null : widget.onDone,
              child: Text(_text(context, 'Cancel', 'Отмена')),
            ),
            WantButton(
              key: const ValueKey('account-save'),
              onPressed: state.busy || _service == null
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
                WantSelect<CardTypeV1>(
                  key: const ValueKey('card-type'),
                  value: _type,
                  label: Text(_text(context, 'Type', 'Тип')),
                  enabled: widget.card == null && !state.busy,
                  options: [
                    for (final preset in catalog.presets)
                      WantOption(
                        value: preset.cardType,
                        label: _typeLabel(context, preset.cardType),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _type = value);
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
                WantInput(
                  key: const ValueKey('account-description'),
                  label: Text(_text(context, 'Description', 'Описание')),
                  controller: _description,
                  enabled: !state.busy,
                  maxLines: 3,
                ),
                WantSelect<String>(
                  key: const ValueKey('card-service'),
                  value: _service,
                  label: Text(_text(context, 'Service *', 'Сервис *')),
                  hint: _text(context, 'Choose a service', 'Выберите сервис'),
                  enabled: !state.busy,
                  options: [
                    for (final service in catalog.services)
                      WantOption(
                        value: service,
                        label: _serviceLabel(context, service),
                      ),
                  ],
                  onChanged: (value) => setState(() => _service = value),
                ),
                WantSelect<String>(
                  key: const ValueKey('card-environment'),
                  value: _environment?.name ?? 'none',
                  label: Text(_text(context, 'Environment', 'Окружение')),
                  enabled: !state.busy,
                  options: [
                    WantOption(
                      value: 'none',
                      label: _text(context, 'No environment', 'Без окружения'),
                    ),
                    for (final value in EnvironmentV1.values)
                      WantOption(
                        value: value.name,
                        label: _environmentLabel(value),
                      ),
                  ],
                  onChanged: (value) => setState(
                    () => _environment = value == null || value == 'none'
                        ? null
                        : EnvironmentV1.values.byName(value),
                  ),
                ),
                for (final field in spec.fields)
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
                        : (value) => setState(() => _totp = value),
                  ),
                  WantCheckbox(
                    value: _recovery,
                    label: Text(
                      _text(context, 'Recovery data', 'Резервные данные'),
                    ),
                    onChanged: state.busy
                        ? null
                        : (value) => setState(() => _recovery = value),
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
                if (_type == CardTypeV1.file) ...[
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
                      onPressed: state.busy
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
                              : () => setState(() {
                                  if (!_groups.add(group.id)) {
                                    _groups.remove(group.id);
                                  }
                                }),
                          child: Text(group.name),
                        ),
                      ),
                  ],
                ),
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
    if (!mounted || !_active) return;
    final remaining = _code?.validUntil.difference(DateTime.now().toUtc());
    final delay = remaining != null && remaining < const Duration(seconds: 1)
        ? (remaining > Duration.zero ? remaining : Duration.zero)
        : const Duration(seconds: 1);
    _timer = Timer(delay, () {
      if (!mounted || !_active) return;
      if (_code == null ||
          !DateTime.now().toUtc().isBefore(_code!.validUntil)) {
        setState(() => _code = null);
        unawaited(_refresh());
      } else {
        setState(() {});
      }
      _schedule();
    });
  }

  Future<void> _refresh() async {
    if (_loading || !_active) return;
    final epoch = _epoch;
    _loading = true;
    try {
      final code = await widget.controller.readTotp(widget.id);
      if (mounted && _active && epoch == _epoch) {
        setState(
          () => _code =
              code != null && DateTime.now().toUtc().isBefore(code.validUntil)
              ? code
              : null,
        );
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
        IconButton(
          key: const ValueKey('card-copy-otp'),
          tooltip: _text(
            context,
            'Copy current OTP',
            'Скопировать текущий OTP',
          ),
          onPressed: code == null || widget.controller.state.busy
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
