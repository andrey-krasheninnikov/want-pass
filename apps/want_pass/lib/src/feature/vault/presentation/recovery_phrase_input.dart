import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:want_allure/want_allure.dart';
import 'package:want_pass/src/feature/vault/presentation/_barrel.dart';
import 'package:want_pass_core/want_pass_core.dart';

final class RecoveryPhraseInput extends StatefulWidget {
  final TextEditingController controller;
  final Future<RecoveryWordsV1?> Function(String) inspect;
  final ValueChanged<bool> onValidChanged;
  final bool enabled;
  const RecoveryPhraseInput({
    super.key,
    required this.controller,
    required this.inspect,
    required this.onValidChanged,
    this.enabled = true,
  });

  @override
  State<RecoveryPhraseInput> createState() => _RecoveryPhraseInputState();
}

final class _RecoveryPhraseInputState extends State<RecoveryPhraseInput> {
  final _words = List.generate(24, (_) => TextEditingController());
  final _focus = List.generate(24, (_) => FocusNode());
  RecoveryWordsV1? _parsed;
  String _last = '';
  int _serial = 0;
  bool _manual = false, _syncing = false, _clipboardFailed = false;

  String _label(String en, String ru) =>
      Localizations.localeOf(context).languageCode == 'ru' ? ru : en;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_edited);
    if (widget.controller.text.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _edited();
      });
    }
  }

  @override
  void dispose() {
    _serial++;
    widget.controller.removeListener(_edited);
    _parsed = null;
    _last = '';
    for (final word in _words) {
      word.dispose();
    }
    for (final node in _focus) {
      node.dispose();
    }
    super.dispose();
  }

  void _edited() {
    final text = widget.controller.text;
    if (_last == text) return;
    _last = text;
    final serial = ++_serial;
    widget.onValidChanged(false);
    setState(() {
      _parsed = null;
      _clipboardFailed = false;
    });
    if (text.isEmpty) {
      _fill(const []);
      return;
    }
    unawaited(() async {
      final parsed = await widget.inspect(text);
      if (!mounted || _serial != serial) return;
      _fill(parsed != null && parsed.recognized ? parsed.words : const []);
      setState(() {
        _parsed = parsed;
        if (parsed?.recognized == false) _manual = false;
      });
      widget.onValidChanged(parsed?.complete == true);
    }());
  }

  void _fill(List<String> words) {
    _syncing = true;
    try {
      for (var i = 0; i < 24; i++) {
        final word = i < words.length ? words[i] : '';
        if (_words[i].text != word) _words[i].text = word;
      }
    } finally {
      _syncing = false;
    }
  }

  void _manualEdit(int index, String value) {
    if (_syncing) return;
    final trimmed = value.trim();
    if (trimmed.startsWith('{') ||
        trimmed.startsWith('[') ||
        trimmed.contains(RegExp(r'[\s,]'))) {
      widget.controller.text = value;
      return;
    }
    widget.controller.text = jsonEncode(
      _words.map((field) => field.text.trim()).toList(),
    );
    if (value.endsWith(' ') && trimmed.isNotEmpty && index < 23) {
      _focus[index + 1].requestFocus();
    }
  }

  Future<void> _paste() async {
    final serial = _serial;
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      if (!mounted || serial != _serial || !widget.enabled) return;
      if (data?.text == null || data!.text!.isEmpty) {
        setState(() => _clipboardFailed = true);
        return;
      }
      widget.controller.text = data.text!;
    } on PlatformException {
      if (mounted) setState(() => _clipboardFailed = true);
    }
  }

  Widget _wordField(int index) => Focus(
    onKeyEvent: (_, event) {
      if (event is! KeyDownEvent) return KeyEventResult.ignored;
      if (event.logicalKey == LogicalKeyboardKey.backspace &&
          _words[index].text.isEmpty &&
          index > 0) {
        _focus[index - 1].requestFocus();
        return KeyEventResult.handled;
      }
      if ((event.logicalKey == LogicalKeyboardKey.space ||
              event.logicalKey == LogicalKeyboardKey.enter) &&
          _words[index].text.isNotEmpty &&
          index < 23) {
        _focus[index + 1].requestFocus();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    },
    child: VaultSecretInput(
      key: ValueKey('phrase-word-${index + 1}'),
      label: _label('Word ${index + 1}', 'Слово ${index + 1}'),
      controller: _words[index],
      focusNode: _focus[index],
      enabled: widget.enabled,
      autofocus: false,
      last: index == 23,
      concealed: false,
      invalid: _parsed?.invalidPositions.contains(index + 1) == true,
      onSubmitted: () {},
      onChanged: (value) => _manualEdit(index, value),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final parsed = _parsed;
    final count = parsed?.words.where((word) => word.isNotEmpty).length ?? 0;
    final invalid = parsed?.invalidPositions ?? const <int>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            WantButton(
              variant: WantButtonVariant.secondary,
              onPressed: widget.enabled ? _paste : null,
              child: Text(_label('Paste from clipboard', 'Вставить из буфера')),
            ),
            WantButton(
              variant: WantButtonVariant.secondary,
              onPressed: widget.enabled
                  ? () => setState(() => _manual = !_manual)
                  : null,
              child: Text(
                _manual
                    ? _label('Paste as text', 'Ввод текстом')
                    : _label('Enter word by word', 'Ввести по словам'),
              ),
            ),
            WantTypography('$count / 24', colorRole: 'muted-foreground'),
          ],
        ),
        if (_manual)
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = (constraints.maxWidth / 110).floor().clamp(1, 4);
              final width =
                  (constraints.maxWidth - (columns - 1) * 8) / columns;
              return FocusTraversalGroup(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    for (var i = 0; i < 24; i++)
                      SizedBox(width: width, child: _wordField(i)),
                  ],
                ),
              );
            },
          )
        else
          VaultSecretInput(
            label: _label('Words or JSON', 'Слова или JSON'),
            controller: widget.controller,
            enabled: widget.enabled,
            autofocus: false,
            last: true,
            multiline: true,
            concealed: false,
            invalid: invalid.isNotEmpty || parsed?.recognized == false,
            onSubmitted: () {},
          ),
        if (_clipboardFailed)
          WantTypography(
            _label(
              'Clipboard text is unavailable.',
              'В буфере нет доступного текста.',
            ),
            liveRegion: true,
          ),
        if (invalid.isNotEmpty)
          WantTypography(
            _label(
              'Check word positions ${invalid.join(', ')}.',
              'Проверьте слова под номерами ${invalid.join(', ')}.',
            ),
            colorRole: 'destructive',
            liveRegion: true,
          )
        else if (parsed?.recognized == false ||
            (count == 24 && parsed?.complete == false))
          WantTypography(
            _label(
              'Check the order and spelling of all 24 words.',
              'Проверьте порядок и написание 24 слов.',
            ),
            colorRole: 'destructive',
            liveRegion: true,
          ),
      ],
    );
  }
}
