part of 'content.dart';

typedef _ToolMap = Map<String, dynamic>;

Iterable<_ToolMap> _toolRows(Object? value) => value is List
    ? value.whereType<Map>().map((v) => Map<String, dynamic>.from(v))
    : const [];

final class _LocalToolsHost {
  static const _channel = MethodChannel('want_pass/local_tools');
  final VaultController controller;
  final BuildContext Function() context;
  StreamSubscription<VaultState>? _subscription;
  DialogRoute<bool>? _dialog;
  BigInt? _revision;
  int _reads = 0;
  bool _closed = false, _handling = false;
  _LocalToolsHost(this.controller, this.context);

  bool get _open => !_closed && controller.state.phase == VaultPhase.unlocked;

  void start() {
    _channel.setMethodCallHandler(_request);
    _subscription = controller.stream.listen((state) {
      if (!_open) {
        _closeDialog();
        unawaited(_listen(null));
      } else if (state.content?.revision != _revision) {
        _revision = state.content?.revision;
        unawaited(_refresh());
      }
    });
    unawaited(_refresh());
  }

  Future<void> _listen(List<String>? profiles) async {
    try {
      await _channel.invokeMethod<bool>(
        profiles == null ? 'stop' : 'listen',
        profiles,
      );
    } on MissingPluginException {
      return;
    } on PlatformException {
      return;
    }
  }

  Future<void> _refresh() async {
    final read = ++_reads;
    final view = await controller.localTool(LocalToolCommandV1.dashboard, {});
    if (!_open || read != _reads || view is! Map) return;
    await _listen([
      for (final p in _toolRows(view['profiles'])) p['id'] as String,
    ]);
  }

  void _closeDialog() {
    final route = _dialog;
    if (route?.isActive == true) route!.navigator?.removeRoute(route);
  }

  void dispose() {
    _closed = true;
    _closeDialog();
    unawaited(_subscription?.cancel());
    _channel.setMethodCallHandler(null);
    unawaited(_listen(null));
  }

  Future<bool> _confirm(_ToolMap scope) async {
    if (!_open || _dialog != null) return false;
    final host = context();
    final navigator = Navigator.of(host, rootNavigator: true);
    final fields = (scope['fields'] as List).join(', ');
    final route = DialogRoute<bool>(
      context: host,
      barrierDismissible: false,
      builder: (context) => WantDialog(
        title: _text(
          context,
          'Authorize local tool',
          'Разрешить локальную операцию',
        ),
        actions: _Actions(
          children: [
            WantButton(
              variant: WantButtonVariant.secondary,
              onPressed: () => navigator.pop(false),
              child: Text(_text(context, 'Deny', 'Отклонить')),
            ),
            WantButton(
              onPressed: () => navigator.pop(true),
              child: Text(_text(context, 'Allow', 'Разрешить')),
            ),
          ],
        ),
        child: Flexible(
          child: SingleChildScrollView(
            child: Text(
              '${scope['client']} · ${scope['action']}\n${scope['resource']}\n${scope['environment']} · $fields',
            ),
          ),
        ),
      ),
    );
    _dialog = route;
    final timer = Timer(const Duration(seconds: 50), _closeDialog);
    try {
      return await navigator.push(route) == true && _open;
    } finally {
      timer.cancel();
      _dialog = null;
    }
  }

  Future<Object?> _request(MethodCall call) async {
    if (call.method != 'request' ||
        !_open ||
        _handling ||
        call.arguments is! Map) {
      return null;
    }
    _handling = true;
    try {
      final args = Map<String, dynamic>.from(call.arguments as Map);
      final targetArgs = Map<String, dynamic>.from(args['body'] as Map);
      final action = args['action'] as String;
      final token = args['token'] as String;
      Future<bool> active() async =>
          _open &&
          (await _channel.invokeMethod<bool>('active', token) ?? false);
      Future<Object?> perform(LocalToolCommandV1 command, Object body) =>
          controller.localTool(command, body, admitted: active);
      if (action == 'identity') {
        if (targetArgs.length != 1 || targetArgs['profile'] is! String) {
          return null;
        }
        return await perform(
          LocalToolCommandV1.agentIdentity,
          targetArgs['profile'],
        );
      }
      final data = await controller.localTool(LocalToolCommandV1.dashboard, {});
      if (!_open || data is! Map) return null;
      final authorize = action == 'authorize';
      final operation = authorize
          ? targetArgs['operation']
          : (action == 'public-key' ? 'ssh' : action);
      if (!['search', 'store', 'ssh', 'sign'].contains(operation)) return null;
      final id = targetArgs[operation == 'sign' ? 'profile' : 'target'];
      if (id is! String || id.length > 60) return null;
      final _ToolMap scope;
      if (operation == 'ssh' || operation == 'sign') {
        final profile = _toolRows(data['profiles'])
            .where((p) => p['id'] == id || p['alias'] == id)
            .firstOrNull;
        if (profile == null) return null;
        scope = Map<String, dynamic>.from(profile['scope'] as Map);
      } else {
        final binding = _toolRows(data['bindings'])
            .where((v) => v['id'] == id)
            .firstOrNull;
        if (binding == null) return null;
        scope = {
          'client': 'wpass',
          'action': operation,
          'target': id,
          'resource': binding['resource'],
          'fields': operation == 'search'
              ? ['name', 'service']
              : ['login', 'password'],
          'environment': binding['environment'],
        };
      }
      if (!authorize &&
          !_toolRows(data['grants']).any(
            (g) =>
                mapEquals(
                  Map.of(g)..remove('fields'),
                  Map.of(scope)..remove('fields'),
                ) &&
                listEquals(g['fields'] as List, scope['fields'] as List),
          )) {
        return null;
      }
      if (authorize || operation == 'store' || operation == 'sign') {
        if (!await _confirm(scope) || !await active()) return null;
      }
      if (authorize) {
        return await perform(LocalToolCommandV1.grant, scope);
      }
      if (operation == 'sign') {
        return await perform(LocalToolCommandV1.agentSign, targetArgs);
      }
      if (action == 'public-key') {
        return await perform(LocalToolCommandV1.request, {
          'scope': scope,
          'export_public_key': true,
        });
      }
      final input = <String, dynamic>{'scope': scope};
      if (operation == 'search') input['query'] = targetArgs['query'];
      if (operation == 'store') {
        final entry = targetArgs['entry'];
        if (entry is! Map ||
            entry.length != 3 ||
            ![
              'login',
              'password',
              'name',
            ].every((key) => entry[key] is String)) {
          return null;
        }
        input.addAll(Map<String, dynamic>.from(entry));
      }
      return await perform(LocalToolCommandV1.request, input);
    } on Object {
      return null;
    } finally {
      _handling = false;
    }
  }
}

final class _LocalToolsSettings extends StatefulWidget {
  final VaultController controller;
  const _LocalToolsSettings({required this.controller});
  @override
  State<_LocalToolsSettings> createState() => _LocalToolsSettingsState();
}

final class _LocalToolsSettingsState extends State<_LocalToolsSettings> {
  _ToolMap _view = {};
  bool _busy = false, _failed = false;
  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final result = await widget.controller.localTool(
      LocalToolCommandV1.dashboard,
      {},
    );
    if (mounted) {
      setState(() {
        _view = result is Map ? Map<String, dynamic>.from(result) : {};
        _failed = result == null;
      });
    }
  }

  Future<T?> _modal<T>(WidgetBuilder builder) async {
    final navigator = Navigator.of(context, rootNavigator: true);
    final route = DialogRoute<T>(context: context, builder: builder);
    final revision = widget.controller.state.content?.revision;
    final closed = navigator.push(route);
    final subscription = widget.controller.stream.listen((state) {
      if (route.isActive &&
          (state.phase != VaultPhase.unlocked ||
              state.content?.revision != revision)) {
        navigator.removeRoute(route);
      }
    });
    try {
      return await closed;
    } finally {
      await subscription.cancel();
    }
  }

  Future<void> _act(LocalToolCommandV1 command, Object body) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _failed = false;
    });
    final result = await widget.controller.localTool(command, body);
    if (!mounted) return;
    if (command == LocalToolCommandV1.publicKey && result is String) {
      await _modal<void>(
        (context) => WantDialog(
          title: _text(context, 'Public key', 'Открытый ключ'),
          actions: WantButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_text(context, 'Done', 'Готово')),
          ),
          child: Flexible(
            child: SingleChildScrollView(child: SelectableText(result)),
          ),
        ),
      );
    }
    if (!mounted) return;
    await _load();
    if (mounted) {
      setState(() {
        _busy = false;
        _failed = result == null;
      });
    }
  }

  Future<void> _create() async {
    final result = await _modal<_ToolMap>(
      (_) => _SshProfileForm(keys: _toolRows(_view['keys']).toList()),
    );
    if (result != null && mounted) {
      await _act(LocalToolCommandV1.configure, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profiles = _toolRows(_view['profiles']);
    final grants = _toolRows(_view['grants']);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        _SectionPanel(
          title: _text(context, 'SSH profiles', 'SSH-профили'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              for (final p in profiles)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${p['alias']} · ${p['user']}@${p['host']}:${p['port']} · ${p['environment']}',
                    ),
                    SelectableText(
                      'wpass authorize ssh ${p['alias']}\nwpass ssh ${p['alias']}',
                    ),
                    Wrap(
                      spacing: 8,
                      children: [
                        WantButton(
                          variant: WantButtonVariant.secondary,
                          onPressed: _busy
                              ? null
                              : () =>
                                    _act(LocalToolCommandV1.publicKey, p['id']),
                          child: Text(
                            _text(
                              context,
                              'Export public key',
                              'Показать открытый ключ',
                            ),
                          ),
                        ),
                        WantButton(
                          variant: WantButtonVariant.secondary,
                          onPressed: _busy
                              ? null
                              : () => _act(
                                  LocalToolCommandV1.disconnect,
                                  p['id'],
                                ),
                          child: Text(
                            _text(context, 'Disconnect', 'Отключить'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              WantButton(
                onPressed: _busy ? null : _create,
                child: Text(
                  _text(context, 'Add SSH profile', 'Добавить SSH-профиль'),
                ),
              ),
            ],
          ),
        ),
        _SectionPanel(
          title: _text(
            context,
            'Local tool access',
            'Доступ локальных инструментов',
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              Text(
                _text(
                  context,
                  'Authorize a scope in the terminal. Permissions expire when the vault locks.',
                  'Чтобы подключить инструмент, запросите доступ из терминала. Разрешения действуют до блокировки сейфа.',
                ),
              ),
              for (final b in _toolRows(_view['bindings']))
                SelectableText(
                  '${b['name']} · ${b['resource']}\nwpass authorize search ${b['id']}\nwpass authorize store ${b['id']}',
                ),
              for (final g in grants)
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      '${g['client']} · ${g['action']} · ${g['resource']} · ${g['environment']}',
                    ),
                    WantButton(
                      variant: WantButtonVariant.secondary,
                      onPressed: _busy
                          ? null
                          : () => _act(LocalToolCommandV1.revoke, g),
                      child: Text(_text(context, 'Revoke', 'Отозвать')),
                    ),
                  ],
                ),
              WantButton(
                variant: WantButtonVariant.secondary,
                onPressed: _busy ? null : _load,
                child: Text(
                  _text(context, 'Refresh permissions', 'Обновить разрешения'),
                ),
              ),
            ],
          ),
        ),
        if (_failed)
          WantTypography(
            _text(
              context,
              'This operation could not be completed.',
              'Не удалось выполнить операцию.',
            ),
            colorRole: 'destructive',
            liveRegion: true,
          ),
      ],
    );
  }
}

final class _SshProfileForm extends StatefulWidget {
  final List<_ToolMap> keys;
  const _SshProfileForm({required this.keys});
  @override
  State<_SshProfileForm> createState() => _SshProfileFormState();
}

final class _SshProfileFormState extends State<_SshProfileForm> {
  final _fields = {
    for (final k in ['alias', 'host', 'user', 'port', 'host_key'])
      k: TextEditingController(text: k == 'port' ? '22' : ''),
  };
  String _key = '', _env = 'development';
  @override
  void dispose() {
    for (final value in _fields.values) {
      value.dispose();
    }
    super.dispose();
  }

  static const environments = [
    'local',
    'unit-tests',
    'integration-tests',
    'e2e-tests',
    'development',
    'stand',
    'feature',
    'stage',
    'pre-release',
    'production',
  ];
  @override
  Widget build(BuildContext context) => WantDialog(
    title: _text(context, 'SSH profile', 'SSH-профиль'),
    actions: _Actions(
      children: [
        WantButton(
          variant: WantButtonVariant.secondary,
          onPressed: () => Navigator.pop(context),
          child: Text(_text(context, 'Cancel', 'Отмена')),
        ),
        WantButton(
          onPressed: _fields.values.any((f) => f.text.trim().isEmpty)
              ? null
              : () => Navigator.pop(context, {
                  for (final f in _fields.entries)
                    f.key: f.key == 'port'
                        ? int.tryParse(f.value.text.trim())
                        : f.value.text.trim(),
                  'key_id': _key.isEmpty ? null : _key,
                  'environment': _env,
                }),
          child: Text(_text(context, 'Save profile', 'Сохранить профиль')),
        ),
      ],
    ),
    child: Flexible(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            for (final f in [
              ('alias', 'Alias', 'Псевдоним'),
              ('host', 'Hostname', 'Имя узла'),
              ('user', 'SSH user', 'Пользователь SSH'),
              ('port', 'Port', 'Порт'),
              (
                'host_key',
                'Server public key (ssh-ed25519)',
                'Открытый ключ сервера (ssh-ed25519)',
              ),
            ])
              WantInput(
                controller: _fields[f.$1],
                label: Text(_text(context, f.$2, f.$3)),
                onChanged: (_) => setState(() {}),
              ),
            WantSelect<String>(
              value: _key,
              options: [
                WantOption(
                  value: '',
                  label: _text(
                    context,
                    'Create Ed25519 key',
                    'Создать ключ Ed25519',
                  ),
                ),
                for (final k in widget.keys)
                  WantOption(
                    value: k['id'] as String,
                    label: k['name'] as String,
                  ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _key = value);
              },
            ),
            WantSelect<String>(
              value: _env,
              options: [
                for (final env in environments)
                  WantOption(value: env, label: env),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _env = value);
              },
            ),
          ],
        ),
      ),
    ),
  );
}
