part of 'content.dart';

final class _BiometrySettings extends StatefulWidget {
  final VaultController controller;
  const _BiometrySettings(this.controller);
  @override
  State<_BiometrySettings> createState() => _BiometrySettingsState();
}

final class _BiometrySettingsState extends State<_BiometrySettings> {
  late var _status = widget.controller.biometricStatus();
  bool _busy = false, _failed = false;
  Future<void> _change(bool enable) async {
    setState(() => _busy = true);
    final saved = await widget.controller.setBiometricEnabled(enable);
    if (mounted) {
      setState(() {
        _busy = false;
        _failed = !saved;
        _status = widget.controller.biometricStatus();
      });
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: _status,
    builder: (context, snapshot) {
      final status = snapshot.data;
      if (status == null || (!status.available && !status.enabled)) {
        return const SizedBox.shrink();
      }
      return SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Touch ID'),
        subtitle: _failed
            ? Text(
                _text(
                  context,
                  'Touch ID settings could not be changed.',
                  'Не удалось изменить настройки Touch ID.',
                ),
              )
            : null,
        value: status.enabled,
        onChanged: _busy ? null : _change,
      );
    },
  );
}

String _operationLabel(BuildContext context, ProtectedOperationV1 operation) {
  final (en, ru) = switch (operation) {
    ProtectedOperationV1.reveal => ('Reveal a value', 'Показать значение'),
    ProtectedOperationV1.copy => ('Copy a value', 'Скопировать значение'),
    ProtectedOperationV1.exportData => ('Export data', 'Экспортировать данные'),
    ProtectedOperationV1.transfer => ('Transfer a secret', 'Передать секрет'),
    ProtectedOperationV1.integrationGrant => (
      'Authorize an integration',
      'Разрешить интеграцию',
    ),
    ProtectedOperationV1.recoveryKit => (
      'Use the recovery kit',
      'Использовать комплект восстановления',
    ),
    ProtectedOperationV1.delete => ('Delete data', 'Удалить данные'),
    ProtectedOperationV1.protection => ('Change protection', 'Изменить защиту'),
  };
  return _text(context, en, ru);
}

Future<T?> _showProtectionDialog<T>(
  NavigatorState navigator,
  VaultController controller,
  WidgetBuilder builder,
) async {
  if (controller.state.phase != VaultPhase.unlocked) return null;
  final revision = controller.state.content?.revision;
  final route = DialogRoute<T>(
    context: navigator.context,
    barrierDismissible: false,
    builder: builder,
  );
  final result = navigator.push(route);
  final sub = controller.stream.listen((state) {
    if ((state.phase != VaultPhase.unlocked ||
            state.content?.revision != revision) &&
        route.isActive) {
      navigator.removeRoute(route);
    }
  });
  try {
    return await result;
  } finally {
    await sub.cancel();
  }
}

Future<String?> promptVaultOperation(
  GlobalKey<NavigatorState> key,
  VaultController controller,
  ProtectedOperationV1 operation,
) async {
  final navigator = key.currentState;
  if (navigator == null) return null;
  await VaultQuickAccess.notifyNative('showConfirmation');
  if (!navigator.mounted || controller.state.phase != VaultPhase.unlocked) {
    return null;
  }
  return _showProtectionDialog<String>(
    navigator,
    controller,
    (context) => _OperationCodeDialog(operation),
  );
}

final class _OperationCodeDialog extends StatefulWidget {
  final ProtectedOperationV1 operation;
  const _OperationCodeDialog(this.operation);
  @override
  State<_OperationCodeDialog> createState() => _OperationCodeDialogState();
}

final class _OperationCodeDialogState extends State<_OperationCodeDialog> {
  final code = TextEditingController();
  bool get ready => RegExp(r'^[0-9]{6}$').hasMatch(code.text);
  void submit() {
    if (ready) Navigator.of(context).pop(code.text);
  }

  @override
  void dispose() {
    code.clear();
    code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(_operationLabel(context, widget.operation)),
    content: VaultSecretInput(
      label: _text(context, 'Authenticator code', 'Код аутентификатора'),
      controller: code,
      enabled: true,
      autofocus: true,
      last: true,
      onChanged: (_) => setState(() {}),
      onSubmitted: submit,
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(_text(context, 'Cancel', 'Отмена')),
      ),
      WantButton(
        onPressed: ready ? submit : null,
        child: Text(_text(context, 'Confirm', 'Подтвердить')),
      ),
    ],
  );
}

Future<void> showProtectionSettings(
  BuildContext context,
  VaultController controller,
) => _showProtectionDialog<void>(
  Navigator.of(context, rootNavigator: true),
  controller,
  (_) => _FactorSettings(controller),
);

final class _FactorSettings extends StatefulWidget {
  final VaultController controller;
  const _FactorSettings(this.controller);
  @override
  State<_FactorSettings> createState() => _FactorSettingsState();
}

final class _FactorSettingsState extends State<_FactorSettings> {
  final _code = TextEditingController();
  final _operations = <ProtectedOperationV1>{};
  ProtectionSettingsDtoV1? _settings;
  String? _seed;
  bool _busy = true, _failed = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final settings = await widget.controller.readProtection();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _settings = settings;
      _failed = settings == null;
      if (settings != null) _operations.addAll(settings.operations);
    });
  }

  Future<void> _begin() async {
    setState(() => _busy = true);
    final seed = await widget.controller.beginExternalFactor();
    if (mounted) {
      setState(() {
        _busy = false;
        _seed = seed;
        _failed = seed == null;
      });
    }
  }

  Future<void> _save({bool disable = false}) async {
    if (_busy || !RegExp(r'^[0-9]{6}$').hasMatch(_code.text)) return;
    setState(() => _busy = true);
    final done = await widget.controller.saveExternalFactor(
      _code.text,
      _operations,
      enrolling: _seed != null,
      disable: disable,
    );
    if (!mounted) return;
    if (done) {
      Navigator.of(context).pop();
      return;
    }
    _code.clear();
    setState(() {
      _busy = false;
      _failed = true;
    });
  }

  @override
  void dispose() {
    _seed = null;
    _code.clear();
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enrolled = _settings?.enrolled ?? false;
    final setup = _seed;
    final editing = enrolled || setup != null;
    final canSave = !_busy && RegExp(r'^[0-9]{6}$').hasMatch(_code.text);
    return AlertDialog(
      scrollable: true,
      title: Text(
        _text(context, 'External authenticator', 'Внешний аутентификатор'),
      ),
      content: SizedBox(
        width: 420,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            if (_settings == null && _busy) const LinearProgressIndicator(),
            if (!editing && _settings != null)
              Text(
                _text(
                  context,
                  'Require a fresh code before selected actions.',
                  'Запрашивайте свежий код перед выбранными действиями.',
                ),
              ),
            if (setup != null) ...[
              Text(
                _text(
                  context,
                  'Scan in your external authenticator or enter the setup key.',
                  'Отсканируйте код внешним аутентификатором или введите ключ настройки.',
                ),
              ),
              Center(
                child: QrImageView(
                  data:
                      'otpauth://totp/Want%20Pass:Vault?secret=$setup&issuer=Want%20Pass',
                  size: 172,
                  backgroundColor: Colors.white,
                ),
              ),
              Text(setup),
            ],
            if (editing) ...[
              for (final action in ProtectedOperationV1.values)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value:
                      action == ProtectedOperationV1.protection ||
                      _operations.contains(action),
                  title: Text(_operationLabel(context, action)),
                  onChanged: _busy || action == ProtectedOperationV1.protection
                      ? null
                      : (value) => setState(() {
                          if (value == true) {
                            _operations.add(action);
                          } else {
                            _operations.remove(action);
                          }
                        }),
                ),
              VaultSecretInput(
                label: _text(
                  context,
                  'Fresh six-digit code',
                  'Свежий шестизначный код',
                ),
                controller: _code,
                enabled: !_busy,
                autofocus: false,
                last: true,
                onChanged: (_) => setState(() {}),
                onSubmitted: () => _save(),
              ),
            ],
            if (_failed)
              Text(
                _text(
                  context,
                  'Unable to confirm. Wait for the next code and try again.',
                  'Подтверждение не прошло. Дождитесь следующего кода и повторите.',
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(_text(context, 'Close', 'Закрыть')),
        ),
        if (enrolled)
          TextButton(
            onPressed: canSave ? () => _save(disable: true) : null,
            child: Text(_text(context, 'Disable', 'Отключить')),
          ),
        if (editing)
          WantButton(
            onPressed: canSave ? () => _save() : null,
            child: Text(_text(context, 'Save', 'Сохранить')),
          )
        else if (_settings != null)
          WantButton(
            onPressed: _busy ? null : _begin,
            child: Text(_text(context, 'Set up', 'Настроить')),
          ),
      ],
    );
  }
}
