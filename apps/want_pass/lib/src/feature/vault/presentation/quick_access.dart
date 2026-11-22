part of 'content.dart';

final class VaultQuickAccess {
  static const channel = MethodChannel('want_pass/shortcuts');
  final VaultController _controller;
  final BuildContext Function() _context;
  final void Function(String action, String? id) _navigate;
  final _offered = <String>{}, _actions = <String>{};
  String? _selected;
  BigInt? _revision;
  bool _disposed = false;
  VaultQuickAccess(this._controller, this._context, this._navigate) {
    if (defaultTargetPlatform == TargetPlatform.macOS && !kIsWeb) {
      channel.setMethodCallHandler(_handle);
    }
  }
  void sync() {
    if (_disposed || defaultTargetPlatform != TargetPlatform.macOS || kIsWeb) {
      return;
    }
    final unlocked = _controller.state.phase == VaultPhase.unlocked;
    if (!unlocked) {
      _offered.clear();
      _actions.clear();
      _selected = null;
      _revision = null;
    }
    final ru = Localizations.localeOf(_context()).languageCode == 'ru';
    unawaited(_sync(unlocked, ru));
  }

  Future<void> _sync(bool unlocked, bool ru) async {
    try {
      await channel.invokeMethod<void>('state', {
        'unlocked': unlocked,
        'russian': ru,
      });
    } on MissingPluginException {
      return;
    }
  }

  static Future<void> notifyNative(String operation, [Object? argument]) async {
    if (defaultTargetPlatform != TargetPlatform.macOS || kIsWeb) return;
    try {
      await channel.invokeMethod<void>(operation, argument);
    } on MissingPluginException {
      return;
    }
  }

  void dispose() {
    _disposed = true;
    _offered.clear();
    _actions.clear();
    if (defaultTargetPlatform == TargetPlatform.macOS && !kIsWeb) {
      channel.setMethodCallHandler(null);
    }
  }

  Future<dynamic> _handle(MethodCall call) async {
    if (_disposed) return null;
    final state = _controller.state, snapshot = state.content;
    final args = call.arguments is Map ? call.arguments as Map : const {};
    if (call.method == 'navigate') {
      final action = args['action'], id = args['id'];
      if (action == 'unlock' || action == 'create') {
        _navigate(action as String, null);
      } else if (action == 'settings' &&
          id is String &&
          state.phase == VaultPhase.unlocked &&
          id == _selected &&
          _actions.contains('settings')) {
        _navigate('settings', id);
      }
      return true;
    }
    if (state.phase != VaultPhase.unlocked || state.busy || snapshot == null) {
      return null;
    }
    if (call.method == 'query') {
      final text = args['text'];
      if (text is! String || text.length > 1024) return const [];
      final matches = await _controller.searchCards(CardSearchV1(text: text));
      if (matches == null ||
          _disposed ||
          _controller.state.content?.revision != matches.revision) {
        return const [];
      }
      final ids = matches.cardIds.toSet(), used = args['usage'];
      final rows = rankQuickCards(
        snapshot.cards.where((c) => ids.contains(c.id)),
        text,
        used is Map ? used : const {},
      );
      _offered.clear();
      _offered.addAll(rows.map((c) => c.id));
      _actions.clear();
      _selected = null;
      _revision = snapshot.revision;
      return [
        for (final card in rows) {'id': card.id, 'name': card.name},
      ];
    }
    if (_revision != snapshot.revision) return null;
    if (call.method == 'actions') {
      final id = call.arguments;
      if (id is! String || !_offered.contains(id)) return const [];
      final card = snapshot.cards.where((c) => c.id == id).firstOrNull;
      if (card == null) return const [];
      final row = await _controller.readCardPreview(id);
      if (row == null ||
          _disposed ||
          !_offered.contains(id) ||
          _controller.state.content?.revision != _revision) {
        return const [];
      }
      final c = _context();
      if (!c.mounted) return const [];
      final allowedFields = row.row.fields.where(
        (f) => !{
          FieldIdV1.totpSeed,
          FieldIdV1.totpAlgorithm,
          FieldIdV1.totpPeriod,
          FieldIdV1.totpDigits,
          FieldIdV1.hotpSeed,
          FieldIdV1.counter,
        }.contains(f),
      );
      final custom =
          _cardTemplate(
            snapshot,
            card,
          )?.fields.where((f) => f.kind != CustomFieldKindV1.file) ??
          const <TemplateFieldV1>[];
      final hasOtp = row.row.fields.contains(FieldIdV1.totpSeed);
      final entries = <Map<String, String>>[
        if (card.cardType != CardTypeV1.hotp &&
            (allowedFields.isNotEmpty || hasOtp || custom.isNotEmpty))
          {'id': 'all', 'title': _text(c, 'Copy all', 'Скопировать всё')},
        for (final f in allowedFields)
          {
            'id': 'field:${f.name}',
            'title':
                '${_text(c, 'Copy', 'Скопировать')} · ${_fieldLabel(c, f)}',
          },
        if (hasOtp)
          {
            'id': 'otp',
            'title': _text(c, 'Copy current OTP', 'Скопировать текущий OTP'),
          },
        for (final f in custom)
          {
            'id': 'custom:${f.id}',
            'title': '${_text(c, 'Copy', 'Скопировать')} · ${f.label}',
          },
        {
          'id': 'settings',
          'title': _text(c, 'Card settings', 'Настройки карточки'),
        },
      ];
      _selected = id;
      _actions.clear();
      _actions.addAll(entries.map((e) => e['id']!));
      return entries;
    }
    if (call.method == 'copy') {
      final id = args['id'], action = args['action'];
      if (action is! String ||
          id is! String ||
          id != _selected ||
          !_actions.contains(action) ||
          action == 'settings') {
        return false;
      }
      var copied = false;
      void markCopied() => copied = true;
      if (action == 'all') {
        await _controller.copyQuickCard(
          id,
          snapshot.revision,
          onCopied: markCopied,
        );
      } else {
        await _controller.copyCard(
          id,
          field: action.startsWith('field:')
              ? FieldIdV1.values.byName(action.substring(6))
              : null,
          customField: action.startsWith('custom:')
              ? action.substring(7)
              : null,
          currentOtp: action == 'otp',
          onCopied: markCopied,
        );
      }
      return copied &&
          !_disposed &&
          _controller.state.phase == VaultPhase.unlocked;
    }
    return null;
  }
}
