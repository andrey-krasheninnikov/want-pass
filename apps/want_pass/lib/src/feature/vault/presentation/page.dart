import 'dart:async';

import 'package:bloc_effects/bloc_effects.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:want_allure/want_allure.dart';
import 'package:want_pass/src/feature/appearance/application/_barrel.dart';
import 'package:want_pass/src/feature/appearance/presentation/_barrel.dart';
import 'package:want_pass/src/feature/vault/application/_barrel.dart';
import 'package:want_pass/src/feature/vault/presentation/_barrel.dart';
import 'package:want_pass_core/want_pass_core.dart';

class VaultPage extends StatefulWidget {
  final VaultController controller;
  final AppearanceController? appearance;
  const VaultPage({super.key, required this.controller, this.appearance});
  @override
  State<VaultPage> createState() => _VaultPageState();
}

class _VaultPageState extends State<VaultPage> {
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  final _phrase = TextEditingController();
  final _passwordHint = TextEditingController();
  final _recoveryHint = TextEditingController();
  final _background = WantBackgroundController();
  final _headingFocus = FocusNode();
  late final PageController _pages;
  late bool _includeAppearance;
  int _step = 1, _navigationEpoch = 0;
  bool _recovering = false, _advancing = false;
  String _lastPasswordText = '';
  DialogRoute<void>? _overlay;
  int get _firstStep => _recovering || _includeAppearance ? 0 : 1;
  String _text(String en, String ru) =>
      Localizations.localeOf(context).languageCode == 'ru' ? ru : en;

  @override
  void initState() {
    super.initState();
    _includeAppearance = widget.appearance?.state.settings.configured == false;
    _step = _firstStep;
    _pages = PageController(initialPage: _step);
    _password.addListener(_passwordChanged);
    _phrase.addListener(_phraseChanged);
    HardwareKeyboard.instance.addHandler(_keyboard);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.controller.state.phase == VaultPhase.locked) {
        unawaited(widget.controller.readHints());
      }
    });
  }

  void _passwordChanged() {
    final text = _password.text;
    if (text == _lastPasswordText) return;
    _lastPasswordText = text;
    widget.controller.acknowledge(password: false);
  }

  void _phraseChanged() {
    if (mounted) setState(() {});
  }

  bool _keyboard(KeyEvent event) {
    widget.controller.activity();
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      unawaited(widget.controller.lock());
      return true;
    }
    return false;
  }

  void _hideOverlay() {
    final route = _overlay;
    _overlay = null;
    if (route != null && route.isActive) route.navigator?.removeRoute(route);
  }

  void _clear() {
    _hideOverlay();
    for (final field in [
      _password,
      _confirmation,
      _phrase,
      _passwordHint,
      _recoveryHint,
    ]) {
      field.clear();
    }
    _lastPasswordText = '';
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_keyboard);
    _password.removeListener(_passwordChanged);
    _phrase.removeListener(_phraseChanged);
    _clear();
    for (final field in [
      _password,
      _confirmation,
      _phrase,
      _passwordHint,
      _recoveryHint,
    ]) {
      field.dispose();
    }
    _pages.dispose();
    _background.dispose();
    _headingFocus.dispose();
    super.dispose();
  }

  void _go(int step) {
    _navigationEpoch++;
    widget.controller.dismissFailure();
    _hideOverlay();
    FocusScope.of(context).unfocus();
    setState(() => _step = step);
    if (_pages.hasClients) {
      if (WantTheme.reducedMotionOf(context)) {
        _pages.jumpToPage(step);
      } else {
        unawaited(
          _pages.animateToPage(
            step,
            duration: const Duration(milliseconds: 180),
            curve: const Cubic(.32, .72, 0, 1),
          ),
        );
      }
    }
    _headingFocus.requestFocus();
  }

  bool _canAdvance(VaultState state) =>
      !state.busy &&
      !_advancing &&
      widget.appearance?.state.busy != true &&
      switch (_step) {
        0 => !_recovering || _phrase.text.trim().isNotEmpty,
        2 => state.passwordSaved,
        3 => state.setupChallenge != null,
        4 => state.phraseSaved && state.lossAccepted,
        >= 5 => state.setupChallenge != null && state.quizPassed[_step - 5],
        _ => true,
      };
  Future<void> _next() async {
    final state = widget.controller.state;
    if (!_canAdvance(state)) return;
    final epoch = _navigationEpoch;
    setState(() => _advancing = true);
    try {
      if (_step == 0) {
        if (_recovering) {
          if (!await widget.controller.validateRecovery(_phrase.text)) return;
        } else if (widget.appearance case final appearance?) {
          final current = appearance.state.settings;
          await appearance.save(
            AppearanceSettingsV1(
              theme: current.theme,
              language:
                  current.language ??
                  (Localizations.localeOf(context).languageCode == 'ru'
                      ? AppearanceLanguageV1.ru
                      : AppearanceLanguageV1.en),
              configured: true,
            ),
          );
          if (appearance.state.failed) return;
        }
        if (mounted && epoch == _navigationEpoch) _go(1);
      } else if (_step == 1) {
        await widget.controller.prepareSetup(
          password: _password.text,
          confirmation: _confirmation.text,
          phrase: _recovering ? _phrase.text : null,
        );
        if (mounted &&
            epoch == _navigationEpoch &&
            widget.controller.state.setupChallenge != null &&
            widget.controller.state.error == null) {
          _go(2);
        }
      } else if (_step < 7) {
        _go(_step + 1);
      } else {
        await widget.controller.confirmSetup(
          answers: state.setupAnswers.cast<String>(),
          password: _password.text,
          hints: VaultHintsDtoV2(
            password: _passwordHint.text,
            recovery: _recoveryHint.text,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _advancing = false);
    }
  }

  Widget _icon(String key, String label, Widget icon, VoidCallback? action) =>
      WantTooltip(
        message: label,
        child: Semantics(
          label: label,
          button: true,
          child: WantButton(
            key: ValueKey(key),
            variant: WantButtonVariant.secondary,
            onPressed: action,
            child: ExcludeSemantics(child: icon),
          ),
        ),
      );
  String get _passwordRequirements => _text(
    'At least 15 characters, uppercase and lowercase letters, an ASCII digit and a special character. Maximum: 1,024 UTF-8 bytes. Spaces and Unicode are allowed.',
    'Минимум 15 символов, заглавная и строчная буквы, ASCII-цифра и спецсимвол. Максимум: 1024 UTF-8 байта. Разрешены пробелы и Unicode.',
  );
  Widget _requirements() => VaultPasswordHelp(
    key: const ValueKey('password-requirements'),
    label: _text('Password requirements', 'Требования к паролю'),
    message: _passwordRequirements,
  );
  Widget _secret(
    String key,
    String label,
    TextEditingController field,
    VaultState state, {
    bool last = false,
    bool multiline = false,
    Widget? postfix,
  }) => VaultSecretInput(
    key: ValueKey(key),
    label: label,
    controller: field,
    enabled: !state.busy && !_advancing,
    autofocus: false,
    last: last,
    multiline: multiline,
    postfix: postfix,
    onSubmitted: () => unawaited(_next()),
  );
  Widget _hint(
    String key,
    String label,
    TextEditingController field,
    VaultState state,
  ) => WantInput(
    key: ValueKey(key),
    label: Text(label),
    controller: field,
    enabled: !state.busy,
    inputFormatters: [
      TextInputFormatter.withFunction((old, next) {
        if (next.text.runes.length <= 256) return next;
        final text = String.fromCharCodes(next.text.runes.take(256));
        return TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      }),
    ],
  );
  Widget _check(
    String key,
    String label,
    bool value,
    ValueChanged<bool> changed,
    VaultState state,
  ) => WantCheckbox(
    key: ValueKey(key),
    value: value,
    enabled: !state.busy,
    label: Text(label),
    onChanged: changed,
  );
  Widget _row(List<Widget> children) => LayoutBuilder(
    builder: (context, size) =>
        size.maxWidth < 300 || MediaQuery.textScalerOf(context).scale(16) > 24
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: children,
          )
        : Row(
            spacing: 8,
            children: [for (final child in children) Expanded(child: child)],
          ),
  );
  Widget _slide(List<Widget> children) => SingleChildScrollView(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: children,
    ),
  );
  String _title(VaultState state) {
    if (state.phase == VaultPhase.loading) {
      return _text('Opening vault', 'Открытие сейфа');
    }
    if (state.phase == VaultPhase.unavailable) {
      return _text('Vault unavailable', 'Сейф недоступен');
    }
    if (state.phase == VaultPhase.unlocked) {
      return _text('Access granted', 'Доступ разрешен');
    }
    if (state.phase == VaultPhase.locked && !_recovering) {
      return _text('Sign-in required', 'Требуется вход');
    }
    return switch (_step) {
      0 =>
        _recovering
            ? _text('Recovery phrase', 'Фраза восстановления')
            : _text('Appearance', 'Оформление'),
      1 =>
        _recovering
            ? _text('New master password', 'Новый мастер-пароль')
            : _text('Master password', 'Мастер-пароль'),
      2 => _text('Password hint', 'Подсказка к паролю'),
      3 => _text('Save recovery phrase', 'Сохраните фразу'),
      4 => _text('Phrase location', 'Где хранится фраза'),
      _ => _text('Check ${_step - 4} of 3', 'Проверка ${_step - 4} из 3'),
    };
  }

  void _dialog(WidgetBuilder builder, {bool clearPassword = false}) {
    if (_overlay != null) return;
    final route = DialogRoute<void>(context: context, builder: builder);
    _overlay = route;
    unawaited(
      Navigator.of(context).push(route).whenComplete(() {
        if (identical(_overlay, route)) {
          _overlay = null;
          if (clearPassword) _password.clear();
        }
      }),
    );
  }

  void _showQr(VaultState state) {
    final challenge = state.setupChallenge;
    if (state.busy || challenge == null) return;
    _dialog(
      (context) => WantDialog(
        title: _text('Recovery QR', 'QR восстановления'),
        showTitle: false,
        constraints: const BoxConstraints(minWidth: 280, maxWidth: 320),
        actions: WantButton(
          key: const ValueKey('qr-saved'),
          onPressed: () {
            widget.controller.acknowledge(phrase: true);
            _hideOverlay();
          },
          child: Text(_text('I saved it', 'Я сохранил')),
        ),
        child: LayoutBuilder(
          builder: (context, size) => ExcludeSemantics(
            child: QrImageView(
              key: const ValueKey('recovery-qr-image'),
              data: challenge.json,
              size: size.maxWidth.clamp(0, 256),
              padding: const EdgeInsets.all(16),
              backgroundColor: Colors.white,
              eyeStyle: QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: WantTheme.of(context).color('primary'),
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Color(0xff141414),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _startRecovery() {
    _hideOverlay();
    _password.clear();
    widget.controller.dismissFailure();
    setState(() {
      _recovering = true;
      _step = 0;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _pages.hasClients) _pages.jumpToPage(0);
    });
  }

  void _showUnlock() {
    widget.controller.dismissFailure();
    _dialog(
      (context) => VaultUnlockDialog(
        controller: widget.controller,
        onRecovery: _startRecovery,
        requirements: _passwordRequirements,
      ),
    );
  }

  void _effect(BuildContext context, VaultEffect effect) {
    switch (effect) {
      case VaultRecoveryReset():
        _go(3);
      case VaultRecoveryRegenerated():
        _dialog(
          (context) => WantDialog(
            title: _text('Save the new phrase', 'Сохраните новую фразу'),
            actions: WantButton(
              onPressed: _hideOverlay,
              child: Text(_text('Continue', 'Продолжить')),
            ),
            child: Text(
              _text(
                'One word was incorrect. A new phrase has been created. Save it again and repeat all three checks. The previous phrase is no longer valid for this setup.',
                'Одно из слов указано неверно. Создана новая фраза. Сохраните её заново и пройдите все три проверки. Прежняя фраза больше не подходит для этой настройки.',
              ),
            ),
          ),
        );
      case VaultNotice(:final kind):
        final success =
            kind == VaultNoticeKind.copied ||
            kind == VaultNoticeKind.exported ||
            kind == VaultNoticeKind.unlocked;
        showWantSnackbar(
          context: context,
          variant: success
              ? WantSnackbarVariant.success
              : WantSnackbarVariant.info,
          variantLabel: success
              ? _text('Success', 'Готово')
              : _text('Info', 'Информация'),
          closeLabel: _text('Close', 'Закрыть'),
          title: Text(switch (kind) {
            VaultNoticeKind.copied => _text(
              'Recovery JSON copied',
              'JSON восстановления скопирован',
            ),
            VaultNoticeKind.exportStarted => _text(
              'Saving recovery JSON…',
              'Сохраняем JSON восстановления…',
            ),
            VaultNoticeKind.exported => _text(
              'Recovery JSON saved',
              'JSON восстановления сохранён',
            ),
            VaultNoticeKind.unlocked => _text(
              'Access granted',
              'Доступ разрешен',
            ),
            VaultNoticeKind.locked => _text(
              'Vault locked',
              'Сейф заблокирован',
            ),
          }),
        );
    }
  }

  Widget _progress() {
    final total = 8 - _firstStep;
    final theme = WantTheme.of(context);
    return Column(
      spacing: 8,
      children: [
        Row(
          spacing: 4,
          children: [
            for (var i = _firstStep; i < 8; i++)
              Expanded(
                child: Semantics(
                  label: _text(
                    'Step ${i - _firstStep + 1} of $total',
                    'Шаг ${i - _firstStep + 1} из $total',
                  ),
                  selected: i == _step,
                  child: AnimatedContainer(
                    key: ValueKey('setup-segment-$i'),
                    height: 6,
                    duration: WantTheme.reducedMotionOf(context)
                        ? Duration.zero
                        : const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: i == _step
                          ? theme.color('primary')
                          : i < _step
                          ? Color.alphaBlend(
                              theme.color('primary').withValues(alpha: .92),
                              theme.color('card'),
                            )
                          : theme.color('muted-foreground'),
                    ),
                  ),
                ),
              ),
          ],
        ),
        WantAnimatedText(
          '${_step - _firstStep + 1} / $total',
          key: const ValueKey('setup-counter'),
          liveRegion: true,
        ),
      ],
    );
  }

  List<Widget> _slides(VaultState state) {
    final challenge = state.setupChallenge;
    final uncertain =
        state.error is VaultRejectedErrorV1 &&
        (state.error as VaultRejectedErrorV1).kind ==
            VaultFailureKindV1.writeUncertain;
    final hintWarning = WantTypography(
      _text(
        'Hints are stored openly. Do not include your password or recovery words.',
        'Подсказки хранятся открыто. Не указывайте пароль или слова восстановления.',
      ),
      colorRole: 'muted-foreground',
    );
    return [
      _slide(
        _recovering
            ? [
                Text(
                  _text(
                    'Use the existing vault file and its 24 recovery words or numbered JSON. Recovery replaces its password and phrase after confirmation.',
                    'Нужны текущий файл сейфа и его 24 слова или JSON с номерами слов. Восстановление заменит пароль и фразу после подтверждения.',
                  ),
                ),
                if (state.hints.recovery.isNotEmpty) Text(state.hints.recovery),
                _secret(
                  'recovery-phrase',
                  _text(
                    'Recovery phrase or JSON',
                    'Фраза восстановления или JSON',
                  ),
                  _phrase,
                  state,
                  multiline: true,
                ),
              ]
            : [
                Text(
                  _text(
                    'Choose your language and theme. You can change them above later.',
                    'Выберите язык и тему. Позже их можно изменить вверху.',
                  ),
                ),
              ],
      ),
      _slide([
        _secret(
          'master-password',
          _text('Master password', 'Мастер-пароль'),
          _password,
          state,
          postfix: _requirements(),
        ),
        _secret(
          'password-confirmation',
          _text('Confirm password', 'Повторите пароль'),
          _confirmation,
          state,
          last: true,
        ),
      ]),
      _slide([
        _hint(
          'password-hint',
          _text(
            'Password hint (optional)',
            'Подсказка к паролю (необязательно)',
          ),
          _passwordHint,
          state,
        ),
        hintWarning,
        _check(
          'password-saved',
          _text(
            'I saved my password in a safe place',
            'Я сохранил пароль в надёжном месте',
          ),
          state.passwordSaved,
          (v) => widget.controller.acknowledge(password: v),
          state,
        ),
      ]),
      _slide([
        Text(
          _text(
            'These 24 words grant access to this vault. They cannot restore a deleted vault file.',
            'Эти 24 слова дают доступ к сейфу. Они не восстанавливают удалённый файл сейфа.',
          ),
        ),
        if (challenge != null)
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (var i = 0; i < challenge.words.length; i++)
                SizedBox(
                  width: 130,
                  child: Row(
                    spacing: 8,
                    children: [
                      WantTypography(
                        '${i + 1}',
                        variant: WantTypographyVariant.caption,
                        colorRole: 'muted-foreground',
                      ),
                      Text(
                        challenge.words[i],
                        textDirection: TextDirection.ltr,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        Row(
          spacing: 8,
          children: [
            const WantIcon(WantIcons.download),
            WantTypography(
              _text('Save', 'Сохранить'),
              variant: WantTypographyVariant.h4,
            ),
          ],
        ),
        Row(
          spacing: 8,
          children: [
            Expanded(
              child: _icon(
                'recovery-copy',
                _text('Copy JSON', 'Скопировать JSON'),
                const Icon(Icons.content_copy),
                state.busy || challenge == null
                    ? null
                    : () => unawaited(widget.controller.copyRecovery()),
              ),
            ),
            Expanded(
              child: _icon(
                'recovery-download',
                _text('Download JSON', 'Скачать JSON'),
                const WantIcon(WantIcons.file),
                state.busy || challenge == null
                    ? null
                    : () => unawaited(widget.controller.downloadRecovery()),
              ),
            ),
            Expanded(
              child: _icon(
                'recovery-qr',
                _text('Show QR', 'Показать QR'),
                const Icon(Icons.qr_code),
                state.busy || challenge == null ? null : () => _showQr(state),
              ),
            ),
          ],
        ),
        WantTypography(
          _text(
            'JSON, clipboard and QR contain the same numbered words in plain text. Clipboard clears after 60 seconds if unchanged.',
            'JSON, буфер обмена и QR содержат одинаковые пронумерованные слова открытым текстом. Буфер очищается через 60 секунд, если не изменён.',
          ),
          colorRole: 'muted-foreground',
        ),
      ]),
      _slide([
        _hint(
          'recovery-hint',
          _text(
            'Where you keep the phrase (optional)',
            'Где хранится фраза (необязательно)',
          ),
          _recoveryHint,
          state,
        ),
        hintWarning,
        _check(
          'phrase-saved',
          _text(
            'I saved the phrase in a safe place',
            'Я сохранил фразу в надёжном месте',
          ),
          state.phraseSaved,
          (v) => widget.controller.acknowledge(phrase: v),
          state,
        ),
        _check(
          'recovery-loss-accepted',
          _text(
            'I understand that if I lose the phrase and forget my master password, I cannot recover this vault',
            'Я понимаю, что при утрате фразы и забытом мастер-пароле не смогу восстановить доступ к сейфу',
          ),
          state.lossAccepted,
          (v) => widget.controller.acknowledge(loss: v),
          state,
        ),
      ]),
      for (var i = 0; i < 3; i++)
        _slide([
          if (challenge != null) ...[
            WantTypography(
              _text(
                'Choose word ${challenge.positions[i] + 1}',
                'Выберите слово № ${challenge.positions[i] + 1}',
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final option in challenge.choices[i])
                  Semantics(
                    selected: state.setupAnswers[i] == option,
                    inMutuallyExclusiveGroup: true,
                    child: WantButton(
                      key: ValueKey('quiz-$i-$option'),
                      variant: state.setupAnswers[i] == option
                          ? WantButtonVariant.primary
                          : WantButtonVariant.secondary,
                      onPressed: state.busy || uncertain
                          ? null
                          : () => unawaited(
                              widget.controller.chooseSetupWord(i, option),
                            ),
                      child: Text(option, textDirection: TextDirection.ltr),
                    ),
                  ),
              ],
            ),
          ],
        ]),
    ];
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocEffectListener<VaultController, VaultEffect>(
    effector: widget.controller,
    listener: _effect,
    child: BlocConsumer<VaultController, VaultState>(
      bloc: widget.controller,
      listenWhen: (a, b) => a.phase != b.phase,
      listener: (context, state) {
        if (state.phase != VaultPhase.confirmation) {
          _navigationEpoch++;
          _clear();
          setState(() {
            _recovering = false;
            _includeAppearance =
                widget.appearance?.state.settings.configured == false;
            _step = _firstStep;
          });
          if (_pages.hasClients) _pages.jumpToPage(_step);
          if (state.phase == VaultPhase.locked) {
            unawaited(widget.controller.readHints());
          }
        }
      },
      builder: (context, state) {
        final setup =
            state.phase == VaultPhase.missing ||
            state.phase == VaultPhase.confirmation ||
            _recovering;
        final uncertain =
            state.error is VaultRejectedErrorV1 &&
            (state.error as VaultRejectedErrorV1).kind ==
                VaultFailureKindV1.writeUncertain;
        return Listener(
          onPointerDown: (_) => widget.controller.activity(),
          onPointerHover: (_) => widget.controller.activity(),
          onPointerSignal: (_) => widget.controller.activity(),
          child: Material(
            color: WantTheme.of(context).color('background'),
            textStyle: WantTheme.of(context).forui.typography.body.sm
                .copyWith(fontSize: 16, height: 1.7),
            child: WantBackgroundMotion(
              controller: _background,
              showPauseControl: false,
              alternateWithLightning: true,
              pauseLabel: _text('Pause background', 'Остановить фон'),
              resumeLabel: _text('Resume background', 'Включить фон'),
              child: SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        spacing: 16,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: 48,
                                height: 48,
                                child: WantGlow(
                                  borderRadius: BorderRadius.circular(24),
                                  child: WantSvg3D.asset(
                                    'assets/brand/logo.svg',
                                    semanticsLabel: 'Want Pass',
                                    glow: false,
                                    placeholderBuilder: (_) => Image.asset(
                                      'assets/brand/logo-dark.png',
                                    ),
                                    errorBuilder: (_, error) => Image.asset(
                                      'assets/brand/logo-dark.png',
                                    ),
                                  ),
                                ),
                              ),
                              if (widget.appearance case final appearance?)
                                AppearanceControls(controller: appearance),
                            ],
                          ),
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) => WantCard(
                                padding: EdgeInsets.zero,
                                child: SizedBox(
                                  height: constraints.maxHeight,
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      spacing: 12,
                                      children: [
                                        if (setup) _progress(),
                                        Focus(
                                          focusNode: _headingFocus,
                                          child: Semantics(
                                            header: true,
                                            child: WantTypography(
                                              _title(state),
                                              variant: WantTypographyVariant.h2,
                                            ),
                                          ),
                                        ),
                                        if (setup)
                                          Expanded(
                                            child: PageView(
                                              controller: _pages,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              children: _slides(state),
                                            ),
                                          )
                                        else
                                          Expanded(
                                            child: _slide([
                                              if (state.phase ==
                                                      VaultPhase.unlocked ||
                                                  state.phase ==
                                                      VaultPhase.locked) ...[
                                                Center(
                                                  child: VaultSafeDial(
                                                    key: const ValueKey(
                                                      'vault-dial',
                                                    ),
                                                    opened:
                                                        state.phase ==
                                                        VaultPhase.unlocked,
                                                    remaining: () => widget
                                                        .controller
                                                        .idleRemaining,
                                                    label:
                                                        state.phase ==
                                                            VaultPhase.unlocked
                                                        ? _text(
                                                            'Lock vault',
                                                            'Заблокировать сейф',
                                                          )
                                                        : _text(
                                                            'Unlock vault',
                                                            'Разблокировать сейф',
                                                          ),
                                                    onPressed: state.busy
                                                        ? null
                                                        : state.phase ==
                                                              VaultPhase
                                                                  .unlocked
                                                        ? () => unawaited(
                                                            widget.controller
                                                                .lock(
                                                                  notify: true,
                                                                ),
                                                          )
                                                        : _showUnlock,
                                                  ),
                                                ),
                                                if (state.phase ==
                                                    VaultPhase.unlocked)
                                                  VaultIdleCountdown(
                                                    remaining: () => widget
                                                        .controller
                                                        .idleRemaining,
                                                  ),
                                              ],
                                            ]),
                                          ),
                                        if (state.error case final error?)
                                          WantTypography(
                                            _error(error),
                                            colorRole: 'destructive',
                                            liveRegion: true,
                                          ),
                                        if (state.busy)
                                          WantTypography(
                                            _text(
                                              'Working…',
                                              'Выполняем операцию…',
                                            ),
                                            liveRegion: true,
                                          ),
                                        if (setup)
                                          _row([
                                            if (_step > _firstStep)
                                              WantButton(
                                                key: const ValueKey(
                                                  'setup-back',
                                                ),
                                                variant:
                                                    WantButtonVariant.secondary,
                                                onPressed:
                                                    state.busy ||
                                                        _advancing ||
                                                        uncertain
                                                    ? null
                                                    : () => _go(_step - 1),
                                                child: Text(
                                                  _text('Back', 'Назад'),
                                                ),
                                              ),
                                            if (_step == 0 && _recovering)
                                              WantButton(
                                                variant:
                                                    WantButtonVariant.secondary,
                                                onPressed:
                                                    state.busy || _advancing
                                                    ? null
                                                    : () => unawaited(
                                                        widget.controller
                                                            .lock(),
                                                      ),
                                                child: Text(
                                                  _text(
                                                    'Back to unlock',
                                                    'К разблокировке',
                                                  ),
                                                ),
                                              ),
                                            WantButton(
                                              key: ValueKey(
                                                _step == 1
                                                    ? (_recovering
                                                          ? 'vault-recover'
                                                          : 'vault-create')
                                                    : _step == 7
                                                    ? 'vault-confirm'
                                                    : 'setup-next',
                                              ),
                                              onPressed: _canAdvance(state)
                                                  ? () => unawaited(_next())
                                                  : null,
                                              child: Text(
                                                _step == 7
                                                    ? _text(
                                                        'Finish',
                                                        'Завершить',
                                                      )
                                                    : _text(
                                                        'Continue',
                                                        'Далее',
                                                      ),
                                              ),
                                            ),
                                          ]),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );

  String _error(VaultErrorV1 error) => switch (error) {
    VaultRejectedErrorV1(kind: VaultFailureKindV1.invalidPassword) => _text(
      'Use 15 or more characters, an uppercase letter, a lowercase letter, a digit and a special character. Maximum: 1,024 UTF-8 bytes.',
      'Используйте минимум 15 символов, заглавную и строчную буквы, цифру и спецсимвол. Максимум: 1024 UTF-8 байта.',
    ),
    VaultRejectedErrorV1(kind: VaultFailureKindV1.passwordMismatch) => _text(
      'The passwords do not match.',
      'Пароли не совпадают.',
    ),
    VaultRejectedErrorV1(kind: VaultFailureKindV1.invalidPhrase) => _text(
      'Enter all 24 English recovery words in their original order.',
      'Введите все 24 английских слова восстановления в исходном порядке.',
    ),
    VaultRejectedErrorV1(kind: VaultFailureKindV1.confirmation) => _text(
      'Check the requested words and try again.',
      'Проверьте запрошенные слова и повторите попытку.',
    ),
    VaultRejectedErrorV1(kind: VaultFailureKindV1.credentials) => _text(
      'Access could not be verified. Check your password or recovery phrase; the vault file may also be damaged.',
      'Не удалось подтвердить доступ. Проверьте пароль или recovery-фразу; файл сейфа также может быть повреждён.',
    ),
    VaultRejectedErrorV1(kind: VaultFailureKindV1.unsupported) => _text(
      'This vault format is not supported. The file has not been changed.',
      'Формат сейфа не поддерживается. Файл не изменён.',
    ),
    VaultRejectedErrorV1(kind: VaultFailureKindV1.writeUncertain) => _text(
      'Saving could not be confirmed. Keep your new recovery phrase and retry confirmation.',
      'Сохранение не подтверждено. Сохраните новую recovery-фразу и повторите подтверждение.',
    ),
    VaultRejectedErrorV1(kind: VaultFailureKindV1.exists) => _text(
      'A vault already exists. Restart Want Pass to open it.',
      'Сейф уже существует. Перезапустите Want Pass, чтобы открыть его.',
    ),
    VaultRejectedErrorV1(kind: VaultFailureKindV1.busy) => _text(
      'The vault is in use. Finish the current operation or close its other instance.',
      'Сейф используется. Завершите текущую операцию или закройте другой экземпляр.',
    ),
    VaultRejectedErrorV1() || VaultUnexpectedErrorV1() => _text(
      'The vault is unavailable. Restart Want Pass and try again. Your file has not been reset.',
      'Сейф недоступен. Перезапустите Want Pass и повторите попытку. Файл не сброшен.',
    ),
  };
}
