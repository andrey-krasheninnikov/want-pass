part of 'content.dart';

final class _CardPreview extends StatefulWidget {
  final VaultController controller;
  final String id;
  final BigInt revision;
  final bool outsideFilter;
  final VoidCallback onEdit;
  const _CardPreview({
    super.key,
    required this.controller,
    required this.id,
    required this.revision,
    required this.outsideFilter,
    required this.onEdit,
  });
  @override
  State<_CardPreview> createState() => _CardPreviewState();
}

final class _CardPreviewState extends State<_CardPreview>
    with WidgetsBindingObserver {
  CardPreviewV1? _preview;
  (BigInt, String)? _hotp;
  final _revealed = <FieldIdV1, String>{};
  final _revealing = <FieldIdV1>{};
  final _customRevealed = <String, String>{};
  List<ResourceBindingV1> _bindings = const [];
  String? _binding;
  bool _showTargets = false;
  Timer? _expiry, _refresh;
  int _epoch = 0;
  bool _active = true, _ticker = true, _loading = false, _pending = true;
  bool get _available =>
      mounted &&
      _active &&
      _ticker &&
      widget.controller.state.phase == VaultPhase.unlocked;
  @override
  void initState() {
    super.initState();
    _active =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void didUpdateWidget(covariant _CardPreview old) {
    super.didUpdateWidget(old);
    if (old.id != widget.id || old.revision != widget.revision) {
      final code = _hotp;
      _reset();
      if (old.id == widget.id && code?.$1 == widget.revision) _hotp = code;
      WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ticker = TickerMode.valuesOf(context).enabled;
    if (ticker != _ticker) {
      _ticker = ticker;
      _suspend();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _active = state == AppLifecycleState.resumed;
    _suspend();
  }

  void _reset() {
    _epoch++;
    _expiry?.cancel();
    _refresh?.cancel();
    _revealed.clear();
    _revealing.clear();
    _customRevealed.clear();
    _bindings = const [];
    _binding = null;
    _showTargets = false;
    _preview = null;
    _hotp = null;
    _pending = true;
  }

  void _suspend() {
    _reset();
    if (mounted) setState(() {});
    if (_available) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    }
  }

  @override
  void dispose() {
    _reset();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _load() async {
    if (!_available || _loading) return;
    if (widget.controller.state.busy) {
      _pending = true;
      return;
    }
    _pending = false;
    _loading = true;
    final epoch = _epoch;
    try {
      final preview = await widget.controller.readCardPreview(widget.id);
      if (!_available || epoch != _epoch) return;
      setState(() => _preview = preview);
      if (preview?.row.otp case final code?) {
        final remaining = code.validUntil.difference(DateTime.now().toUtc());
        _expiry?.cancel();
        _refresh?.cancel();
        if (remaining > Duration.zero) {
          _expiry = Timer(remaining, () {
            if (_available) setState(() {});
          });
        }
        _refresh = Timer(
          remaining > Duration.zero
              ? remaining
              : const Duration(milliseconds: 100),
          () => unawaited(_load()),
        );
      }
    } finally {
      _loading = false;
      if (_available && _pending && !widget.controller.state.busy) {
        unawaited(_load());
      }
    }
  }

  Future<void> _nextHotp() async {
    final id = widget.id;
    final result = await widget.controller.nextHotp(id, widget.revision);
    if (result != null &&
        _available &&
        widget.id == id &&
        widget.controller.state.content?.revision == result.snapshot.revision) {
      setState(() => _hotp = (result.snapshot.revision, result.code));
    }
  }

  Future<void> _reveal(FieldIdV1 field) async {
    if (_revealed.containsKey(field)) {
      setState(() => _revealed.remove(field));
      return;
    }
    if (_revealing.contains(field)) return;
    final epoch = _epoch;
    setState(() => _revealing.add(field));
    widget.controller.activity();
    final value = await widget.controller.revealCardField(widget.id, field);
    if (!_available || epoch != _epoch) return;
    setState(() {
      _revealing.remove(field);
      if (value != null) _revealed[field] = value;
    });
  }

  Widget _customValue(TemplateFieldV1 field) {
    final value = _customRevealed[field.id];
    if (field.kind == CustomFieldKindV1.file) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(field.label),
        trailing: IconButton(
          tooltip: _text(context, 'Export file', 'Выгрузить файл'),
          icon: const Icon(Icons.download_outlined),
          onPressed: () => widget.controller.downloadAttachment(
            widget.id,
            'attachment',
            fieldId: field.id,
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(field.label),
        Row(
          children: [
            Expanded(child: Text(value ?? '••••••••')),
            if (field.kind != CustomFieldKindV1.otp)
              VaultSecretAction(
                label: _text(
                  context,
                  'Show or hide value',
                  'Показать или скрыть значение',
                ),
                onPressed: () async {
                  if (value != null) {
                    setState(() => _customRevealed.remove(field.id));
                    return;
                  }
                  final epoch = _epoch;
                  final revealed = await widget.controller.revealCustomField(
                    widget.id,
                    field.id,
                  );
                  if (_available && _epoch == epoch && revealed != null) {
                    setState(() => _customRevealed[field.id] = revealed);
                  }
                },
                child: Icon(
                  value == null
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            VaultSecretAction(
              label: _text(context, 'Copy value', 'Скопировать значение'),
              onPressed: () =>
                  widget.controller.copyCard(widget.id, customField: field.id),
              child: const Icon(Icons.copy),
            ),
          ],
        ),
      ],
    );
  }

  Widget _value(FieldIdV1 field, String? visible) {
    final value = visible ?? _revealed[field];
    final label = _fieldLabel(context, field);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: WantTheme.of(context).color('border')),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 4,
          children: [
            WantTypography(
              label,
              variant: WantTypographyVariant.caption,
              colorRole: 'muted-foreground',
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: value == null
                        ? const Text(
                            '••••••••',
                            style: TextStyle(letterSpacing: 2),
                          )
                        : Text(
                            value,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 15,
                            ),
                          ),
                  ),
                ),
                if (visible == null)
                  VaultSecretAction(
                    label: value == null
                        ? _text(context, 'Show $label', 'Показать: $label')
                        : _text(context, 'Hide $label', 'Скрыть: $label'),
                    onPressed:
                        widget.controller.state.busy ||
                            _revealing.contains(field)
                        ? null
                        : () => unawaited(_reveal(field)),
                    child: Icon(
                      value == null
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 18,
                    ),
                  ),
                _CopyAction(
                  key: ValueKey('preview-copy-${field.name}'),
                  controller: widget.controller,
                  id: widget.id,
                  field: field,
                  label: _text(context, 'Copy $label', 'Скопировать: $label'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocListener<VaultController, VaultState>(
    bloc: widget.controller,
    listener: (context, state) {
      if (state.phase != VaultPhase.unlocked) {
        _reset();
        if (mounted) setState(() {});
      } else if (!state.busy && _pending) {
        unawaited(_load());
      }
    },
    child: Builder(
      builder: (context) {
        final summary = widget.controller.state.content?.cards
            .where((c) => c.id == widget.id)
            .firstOrNull;
        if (summary == null) return const SizedBox.shrink();
        final preview = _preview;
        final template = _cardTemplate(
          widget.controller.state.content!,
          summary,
        );
        final binding = _bindings.where((b) => b.id == _binding).firstOrNull;
        final choosingTarget =
            _showTargets && _bindings.length > 1 && binding == null;
        bool allows(String field) =>
            !choosingTarget &&
            (binding == null || binding.fields.contains(field));
        final code = allows(_fieldKey(FieldIdV1.totpSeed))
            ? preview?.row.otp
            : null;
        final validCode =
            code != null && DateTime.now().toUtc().isBefore(code.validUntil);
        return SingleChildScrollView(
          key: ValueKey('card-preview-${widget.id}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,
                children: [
                  Expanded(
                    child: WantTypography(
                      summary.name,
                      variant: WantTypographyVariant.h3,
                    ),
                  ),
                  WantButton(
                    key: const ValueKey('card-edit'),
                    size: WantButtonSize.icon,
                    variant: WantButtonVariant.ghost,
                    semanticsLabel: _text(context, 'Edit', 'Изменить'),
                    onPressed: widget.controller.state.busy
                        ? null
                        : widget.onEdit,
                    child: const Icon(Icons.edit_outlined, size: 20),
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _catalogLabel(
                    _serviceIcon(context, summary.service),
                    _serviceLabel(context, summary.service),
                  ),
                  _catalogLabel(
                    _typeIcon(summary.cardType),
                    template?.name ?? _typeLabel(context, summary.cardType),
                  ),
                  if (summary.environment != null)
                    Text(_environmentLabel(summary.environment!)),
                ],
              ),
              if (widget.outsideFilter)
                WantTypography(
                  _text(
                    context,
                    'Saved. This secret is outside the current filter.',
                    'Сохранено. Секрет не соответствует текущему фильтру.',
                  ),
                  variant: WantTypographyVariant.caption,
                  colorRole: 'muted-foreground',
                ),
              if (preview == null) ...[
                const SizedBox(height: 96),
                WantButton(
                  variant: WantButtonVariant.secondary,
                  onPressed: _loading ? null : () => unawaited(_load()),
                  child: Text(
                    _text(context, 'Load details', 'Загрузить подробности'),
                  ),
                ),
              ] else ...[
                if (preview.description.isNotEmpty) Text(preview.description),
                if (!_showTargets)
                  WantButton(
                    variant: WantButtonVariant.secondary,
                    onPressed: () async {
                      final epoch = _epoch;
                      final bindings = await widget.controller.readBindings(
                        widget.id,
                      );
                      if (_available && epoch == _epoch && bindings != null) {
                        setState(() {
                          _showTargets = true;
                          _bindings = bindings;
                          if (bindings.length == 1) {
                            _binding = bindings.single.id;
                          }
                        });
                      }
                    },
                    child: Text(
                      _text(context, 'Target resources', 'Ресурсы назначения'),
                    ),
                  )
                else if (_bindings.isEmpty)
                  Text(
                    _text(
                      context,
                      'No target resources',
                      'Нет ресурсов назначения',
                    ),
                  ),
                if (_bindings.isNotEmpty)
                  _pick<String>(
                    context,
                    _text(context, 'Use a target', 'Выбрать назначение'),
                    _binding,
                    _bindings.map((b) => b.id),
                    (id) {
                      final b = _bindings.firstWhere((b) => b.id == id);
                      return '${_methodName(b.method)} · ${b.target}';
                    },
                    (id) => setState(() => _binding = id),
                  ),
                if (choosingTarget)
                  Text(
                    _text(
                      context,
                      'Choose a target to use its fields.',
                      'Выберите назначение, чтобы использовать его поля.',
                    ),
                  ),
                if (template != null)
                  for (final f in template.fields)
                    if (allows(f.id)) _customValue(f),
                for (final field in preview.row.fields)
                  if (allows(_fieldKey(field)))
                    _value(
                      field,
                      field == FieldIdV1.login ? preview.row.login : null,
                    ),
                if (code != null)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: WantTheme.of(context).color('muted'),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 8,
                              children: [
                                const Text('OTP'),
                                Text(
                                  validCode ? code.code : '••••••',
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 28,
                                    letterSpacing: 4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _CopyAction(
                            key: const ValueKey('preview-copy-otp'),
                            controller: widget.controller,
                            id: widget.id,
                            currentOtp: true,
                            label: _text(
                              context,
                              'Copy OTP',
                              'Скопировать OTP',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (summary.cardType == CardTypeV1.hotp &&
                    allows(_fieldKey(FieldIdV1.hotpSeed))) ...[
                  if (_hotp case (final revision, final code)
                      when revision == widget.revision)
                    Text(
                      code,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 28,
                      ),
                    ),
                  WantButton(
                    key: const ValueKey('card-next-hotp'),
                    variant: WantButtonVariant.secondary,
                    onPressed: widget.controller.state.busy ? null : _nextHotp,
                    child: Text(_text(context, 'Next code', 'Следующий код')),
                  ),
                ],
                if (summary.cardType == CardTypeV1.account &&
                    !choosingTarget &&
                    binding == null)
                  Row(
                    children: [
                      const Spacer(),
                      _CopyAction(
                        key: const ValueKey('card-copy-all'),
                        controller: widget.controller,
                        id: widget.id,
                        label: _text(
                          context,
                          'Copy login, password and OTP',
                          'Скопировать логин, пароль и OTP',
                        ),
                      ),
                    ],
                  ),
                if (preview.protectedContainer)
                  WantTypography(
                    _text(
                      context,
                      'Encrypted key container. Protected contents have not been verified.',
                      'Зашифрованный контейнер ключа. Защищённое содержимое не проверено.',
                    ),
                    variant: WantTypographyVariant.caption,
                    colorRole: 'muted-foreground',
                  ),
                if (preview.row.attachment case final file?
                    when allows('attachment')) ...[
                  Text(
                    '${file.name} · ${file.size} ${_text(context, 'bytes', 'байт')}',
                  ),
                  WantButton(
                    key: const ValueKey('card-file-download'),
                    variant: WantButtonVariant.secondary,
                    onPressed: widget.controller.state.busy
                        ? null
                        : () => unawaited(
                            widget.controller.downloadAttachment(
                              widget.id,
                              file.name,
                            ),
                          ),
                    child: Text(_text(context, 'Save file', 'Сохранить файл')),
                  ),
                ],
                Wrap(
                  spacing: 8,
                  children: [
                    for (final group in widget.controller.state.content!.groups)
                      if (summary.groupIds.contains(group.id)) Text(group.name),
                  ],
                ),
              ],
              _ContentError(widget.controller.state.error),
            ],
          ),
        );
      },
    ),
  );
}

final class _CopyAction extends StatefulWidget {
  final VaultController controller;
  final String id, label;
  final FieldIdV1? field;
  final bool currentOtp;
  const _CopyAction({
    super.key,
    required this.controller,
    required this.id,
    required this.label,
    this.field,
    this.currentOtp = false,
  });
  @override
  State<_CopyAction> createState() => _CopyActionState();
}

final class _CopyActionState extends State<_CopyAction> {
  bool _copied = false;
  Timer? _timer;
  @override
  void didUpdateWidget(covariant _CopyAction old) {
    super.didUpdateWidget(old);
    if (old.id != widget.id ||
        old.field != widget.field ||
        old.currentOtp != widget.currentOtp) {
      _timer?.cancel();
      _copied = false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      BlocEffectListener<VaultController, VaultEffect>(
        effector: widget.controller,
        listener: (context, effect) {
          final kind = widget.field != null
              ? CardCopyKindV1.field
              : widget.currentOtp
              ? CardCopyKindV1.otp
              : CardCopyKindV1.account;
          if (effect is VaultCredentialCopiedV1 &&
              effect.cardId == widget.id &&
              effect.kind == kind &&
              effect.field == widget.field) {
            _timer?.cancel();
            setState(() => _copied = true);
            _timer = Timer(const Duration(milliseconds: 1200), () {
              if (mounted) setState(() => _copied = false);
            });
          }
        },
        child: BlocBuilder<VaultController, VaultState>(
          bloc: widget.controller,
          builder: (context, state) => Semantics(
            liveRegion: _copied,
            label: _copied
                ? '${widget.label}: ${_text(context, 'copied', 'скопировано')}'
                : null,
            child: WantTooltip(
              message: widget.label,
              child: VaultSecretAction(
                label: widget.label,
                onPressed: state.busy || state.phase != VaultPhase.unlocked
                    ? null
                    : () => unawaited(
                        widget.controller.copyCard(
                          widget.id,
                          field: widget.field,
                          currentOtp: widget.currentOtp,
                        ),
                      ),
                child: Icon(
                  _copied ? Icons.check : Icons.copy_outlined,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
      );
}
