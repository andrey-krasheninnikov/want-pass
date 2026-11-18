import 'dart:async';

import 'package:bloc_effects/bloc_effects.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
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
  final _obscurePasswords = ValueNotifier(true);
  PasswordPolicyStatusV4? _passwordPolicy;
  Timer? _passwordDebounce;
  int _passwordRevision = 0;
  bool _savingRecovery = false, _celebratingSetup = false;
  bool _completingRecovery = false;
  final _confirmation = TextEditingController();
  final _phrase = TextEditingController();
  final _passwordHint = TextEditingController();
  final _recoveryHint = TextEditingController();
  final _background = WantBackgroundController();
  final _headingFocus = FocusNode();
  final _unlockFocus = FocusNode();
  late final PageController _pages;
  late bool _includeAppearance;
  int _step = 1, _navigationEpoch = 0;
  bool _recovering = false, _advancing = false, _sliding = false;
  int _phraseArrival = 0;
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
    _confirmation.addListener(_phraseChanged);
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
    final revision = ++_passwordRevision;
    _passwordDebounce?.cancel();
    if (mounted) setState(() => _passwordPolicy = null);
    if (text.isEmpty) return;
    _passwordDebounce = Timer(const Duration(milliseconds: 120), () async {
      final policy = await widget.controller.checkSetupPassword(text);
      if (!mounted || revision != _passwordRevision || _step != 1) return;
      setState(() => _passwordPolicy = policy);
    });
  }

  void _phraseChanged() {
    if (mounted) setState(() {});
  }

  bool _keyboard(KeyEvent event) {
    widget.controller.activity();
    final keyboard = HardwareKeyboard.instance;
    final modifier = Theme.of(context).platform == TargetPlatform.macOS
        ? keyboard.isMetaPressed
        : keyboard.isControlPressed;
    if (event is KeyDownEvent &&
        modifier &&
        !keyboard.isAltPressed &&
        !keyboard.isShiftPressed &&
        event.logicalKey == LogicalKeyboardKey.keyL) {
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
    _passwordRevision++;
    _passwordDebounce?.cancel();
    _passwordPolicy = null;
    _obscurePasswords.value = true;
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
    _confirmation.removeListener(_phraseChanged);
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
    _obscurePasswords.dispose();
    _pages.dispose();
    _background.dispose();
    _headingFocus.dispose();
    _unlockFocus.dispose();
    super.dispose();
  }

  void _go(int step, {bool retry = false}) {
    final epoch = ++_navigationEpoch;
    widget.controller.dismissFailure();
    _hideOverlay();
    FocusScope.of(context).unfocus();
    if (step != 1) _obscurePasswords.value = true;
    final animate =
        _pages.hasClients &&
        !retry &&
        TickerMode.valuesOf(context).enabled &&
        !WantTheme.reducedMotionOf(context);
    setState(() {
      _step = step;
      _sliding = animate;
      if (retry) _phraseArrival++;
    });
    if (animate) {
      unawaited(
        _pages
            .animateToPage(
              step,
              duration: const Duration(milliseconds: 360),
              curve: Curves.easeInOutCubic,
            )
            .then((_) {
              if (!mounted || epoch != _navigationEpoch) return;
              setState(() => _sliding = false);
              _headingFocus.requestFocus();
            }),
      );
    } else {
      if (_pages.hasClients) _pages.jumpToPage(step);
      if (!retry) _headingFocus.requestFocus();
    }
  }

  bool _canAdvance(VaultState state) =>
      !state.busy &&
      !_advancing &&
      !_sliding &&
      widget.appearance?.state.busy != true &&
      switch (_step) {
        0 => !_recovering || _phrase.text.trim().isNotEmpty,
        1 =>
          _passwordPolicy?.valid == true &&
              _password.text == _confirmation.text,
        2 => state.passwordSaved,
        3 =>
          state.setupChallenge != null &&
              state.recoveryExportCompleted &&
              !_savingRecovery,
        4 => state.phraseSaved && state.lossAccepted,
        5 =>
          state.setupChallenge != null &&
              state.setupAnswers.every((answer) => answer != null),
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
      } else if (_step < 5) {
        _go(_step + 1);
      } else {
        _completingRecovery = _recovering;
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

  Widget _saveAction(
    String key,
    String label,
    Widget icon,
    VoidCallback? action,
  ) => WantButton(
    key: ValueKey(key),
    variant: WantButtonVariant.secondary,
    onPressed: action,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 8,
      children: [
        ExcludeSemantics(child: icon),
        Flexible(child: Text(label)),
      ],
    ),
  );

  Future<void> _saveRecovery(Future<void> Function() save) async {
    if (_savingRecovery) return;
    setState(() => _savingRecovery = true);
    try {
      await save();
    } finally {
      if (mounted) setState(() => _savingRecovery = false);
    }
  }

  Widget _passwordChecklist() {
    final status = _passwordPolicy;
    final theme = WantTheme.of(context);
    final green = Theme.of(context).brightness == Brightness.dark
        ? theme.color('success')
        : Color.alphaBlend(
            Colors.black.withValues(alpha: .52),
            theme.color('success'),
          );
    final requirements = [
      (
        _text('At least 15 characters', 'Минимум 15 символов'),
        status?.minimumLength,
      ),
      (
        _text('At most 1,024 UTF-8 bytes', 'Не больше 1024 байт UTF-8'),
        status?.maximumBytes,
      ),
      (_text('An uppercase letter', 'Заглавная буква'), status?.uppercase),
      (_text('A lowercase letter', 'Строчная буква'), status?.lowercase),
      (_text('A digit from 0 to 9', 'Цифра от 0 до 9'), status?.digit),
      (_text('A special character', 'Спецсимвол'), status?.special),
      (_text('One line', 'Одна строка'), status?.singleLine),
      (
        _text('Passwords match', 'Пароли совпадают'),
        _password.text.isNotEmpty && _password.text == _confirmation.text,
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        for (final (label, passed) in requirements)
          Semantics(
            label: passed == true
                ? _text('Met', 'Выполнено')
                : _text('Pending', 'Не выполнено'),
            child: Row(
              spacing: 8,
              children: [
                Icon(
                  passed == true ? Icons.check : Icons.circle_outlined,
                  size: 14,
                  color: WantTheme.of(context)
                      .color(passed == true ? 'success' : 'muted-foreground'),
                ),
                Flexible(
                  child: Text(
                    label,
                    style: theme.forui.typography.body.sm.copyWith(
                      color: passed == true
                          ? green
                          : theme.color('muted-foreground'),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _secret(
    String key,
    String label,
    TextEditingController field,
    VaultState state, {
    bool last = false,
    bool multiline = false,
    bool sharedVisibility = false,
    bool showVisibilityToggle = true,
  }) => VaultSecretInput(
    key: ValueKey(key),
    label: label,
    controller: field,
    enabled: !state.busy && !_advancing,
    autofocus: false,
    last: last,
    multiline: multiline,
    sharedObscure: sharedVisibility ? _obscurePasswords : null,
    showVisibilityToggle: showVisibilityToggle,
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
  String _title(VaultState state, [int? step]) {
    if (state.phase == VaultPhase.loading) {
      return _text('Opening vault', 'Открытие сейфа');
    }
    if (state.phase == VaultPhase.unavailable) {
      return _text('Vault unavailable', 'Сейф недоступен');
    }
    return switch (step ?? _step) {
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
      _ => _text('Check recovery words', 'Проверьте слова восстановления'),
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
            widget.controller.confirmRecoveryQr(challenge.revision);
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
      _sliding = false;
      _step = 0;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _pages.hasClients) _pages.jumpToPage(0);
    });
  }

  Future<void> _openWebsite() async {
    var launched = false;
    try {
      launched = await url_launcher.launchUrl(
        Uri.https('pass.want.foundation'),
        mode: url_launcher.LaunchMode.externalApplication,
      );
    } on PlatformException {
      // The system browser may be unavailable.
    } on MissingPluginException {
      // This host may not provide a URL launcher.
    }
    if (!mounted || launched) return;
    showWantSnackbar(
      context: context,
      variant: WantSnackbarVariant.info,
      variantLabel: _text('Info', 'Информация'),
      closeLabel: _text('Close', 'Закрыть'),
      title: Text(
        _text(
          'Could not open the Want Pass website.',
          'Не удалось открыть сайт Want Pass.',
        ),
      ),
    );
  }

  void _showUnlock() {
    _unlockFocus.requestFocus();
  }

  Widget _ambient(VaultState state, bool setup, {required Widget child}) =>
      VaultFilaments(
        enabled: !setup && state.phase == VaultPhase.locked,
        backdrop: setup
            ? WantBackgroundMotion(
                controller: _background,
                showPauseControl: false,
                alternateWithLightning: true,
                transitionDuration: const Duration(milliseconds: 1600),
                pauseLabel: _text('Pause background', 'Остановить фон'),
                resumeLabel: _text('Resume background', 'Включить фон'),
                child: const SizedBox.expand(),
              )
            : null,
        child: child,
      );

  Widget _arrival(Object view, Widget child) {
    final reduced =
        WantTheme.reducedMotionOf(context) ||
        !TickerMode.valuesOf(context).enabled;
    return TweenAnimationBuilder<double>(
      key: ValueKey(view),
      tween: Tween(begin: 0, end: 1),
      curve: Curves.easeInOutCubic,
      duration: reduced ? Duration.zero : const Duration(milliseconds: 320),
      child: child,
      builder: (context, progress, child) {
        final value = reduced ? 1.0 : progress;
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 5),
            child: child,
          ),
        );
      },
    );
  }

  Widget _surface({
    required bool setup,
    required VaultPhase phase,
    required Widget child,
  }) => _arrival(
    setup ? (_recovering ? 'recovery' : 'setup') : phase,
    setup
        ? WantCard(hoverEffect: false, padding: EdgeInsets.zero, child: child)
        : child,
  );

  void _effect(BuildContext context, VaultEffect effect) {
    switch (effect) {
      case VaultRecoveryReset():
        if (widget.controller.state.phase != VaultPhase.confirmation) return;
        _go(3, retry: true);
        _dialog(
          (context) => WantDialog(
            title: _text('Check the phrase again', 'Сверьте фразу ещё раз'),
            actions: WantButton(
              key: const ValueKey('recovery-retry'),
              onPressed: _hideOverlay,
              child: Text(_text('OK', 'Понятно')),
            ),
            child: Text(
              _text(
                'One or more answers were incorrect. Save the same phrase again before retrying.',
                'Один или несколько ответов неверны. Сохраните ту же фразу и повторите проверку.',
              ),
            ),
          ),
        );
      case VaultSetupCompletedV1():
        if (widget.controller.state.phase == VaultPhase.unlocked) {
          setState(() => _celebratingSetup = true);
        }
      case VaultCredentialCopiedV1():
        return;
      case VaultNotice(:final kind):
        if (kind == VaultNoticeKind.locked ||
            kind == VaultNoticeKind.unlocked ||
            kind == VaultNoticeKind.copied) {
          return;
        }
        final success = kind == VaultNoticeKind.exported;
        showWantSnackbar(
          context: context,
          variant: success
              ? WantSnackbarVariant.success
              : WantSnackbarVariant.info,
          variantLabel: success
              ? _text('Success', 'Готово')
              : _text('Info', 'Информация'),
          closeLabel: _text('Close', 'Закрыть'),
          title: Text(
            success
                ? _text('File saved', 'Файл сохранён')
                : _text('Saving file…', 'Сохраняем файл…'),
          ),
        );
    }
  }

  Widget _setupChrome(VaultState state) {
    final total = 6 - _firstStep;
    final theme = WantTheme.of(context);
    final primary = theme.color('primary');
    final complete = Color.alphaBlend(
      primary.withValues(alpha: .92),
      theme.color('card'),
    );
    return ListenableBuilder(
      listenable: _pages,
      builder: (context, _) {
        final page = (_pages.hasClients ? _pages.page ?? _step : _step)
            .clamp(_firstStep, 5)
            .toDouble();
        final from = page.floor();
        final to = page.ceil();
        final mix = page - from;

        Widget labels(
          String Function(int) label,
          WantTypographyVariant variant, {
          required Alignment alignment,
        }) => Stack(
          alignment: alignment,
          children: [
            Opacity(
              opacity: 1 - mix,
              child: WantTypography(label(from), variant: variant),
            ),
            if (from != to)
              Opacity(
                opacity: mix,
                child: WantTypography(label(to), variant: variant),
              ),
          ],
        );

        String counter(int step) => '${step - _firstStep + 1} / $total';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Row(
              spacing: 4,
              children: [
                for (var i = _firstStep; i < 6; i++)
                  Expanded(
                    child: Semantics(
                      label: _text(
                        'Step ${i - _firstStep + 1} of $total',
                        'Шаг ${i - _firstStep + 1} из $total',
                      ),
                      selected: i == _step,
                      child: Container(
                        key: ValueKey('setup-segment-$i'),
                        height: 6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: page < i
                              ? Color.lerp(
                                  theme.color('muted-foreground'),
                                  primary,
                                  (1 + page - i).clamp(0, 1).toDouble(),
                                )
                              : Color.lerp(
                                  primary,
                                  complete,
                                  (page - i).clamp(0, 1).toDouble(),
                                ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Semantics(
              label: counter(_step),
              liveRegion: true,
              excludeSemantics: true,
              child: labels(
                counter,
                WantTypographyVariant.caption,
                alignment: Alignment.center,
              ),
            ),
            Focus(
              focusNode: _headingFocus,
              child: Semantics(
                header: true,
                label: _title(state, _step),
                excludeSemantics: true,
                child: labels(
                  (step) => _title(state, step),
                  WantTypographyVariant.h2,
                  alignment: Alignment.centerLeft,
                ),
              ),
            ),
          ],
        );
      },
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
    final slides = [
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
          sharedVisibility: true,
        ),
        _secret(
          'password-confirmation',
          _text('Confirm password', 'Повторите пароль'),
          _confirmation,
          state,
          last: true,
          sharedVisibility: true,
          showVisibilityToggle: false,
        ),
        _passwordChecklist(),
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
        _row([
          _saveAction(
            'recovery-copy',
            _text('Copy JSON', 'Скопировать JSON'),
            const Icon(Icons.content_copy, size: 18),
            state.busy || challenge == null || _savingRecovery
                ? null
                : () =>
                      unawaited(_saveRecovery(widget.controller.copyRecovery)),
          ),
          _saveAction(
            'recovery-download',
            _text('Download JSON', 'Скачать JSON'),
            const WantIcon(WantIcons.download, size: 18),
            state.busy || challenge == null || _savingRecovery
                ? null
                : () => unawaited(
                    _saveRecovery(widget.controller.downloadRecovery),
                  ),
          ),
          _saveAction(
            'recovery-qr',
            _text('Show QR', 'Показать QR'),
            const Icon(Icons.qr_code, size: 18),
            state.busy || challenge == null || _savingRecovery
                ? null
                : () => _showQr(state),
          ),
        ]),
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
      _slide([
        if (challenge != null)
          for (var i = 0; i < 3; i++) ...[
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
                          : () => widget.controller.chooseSetupWord(i, option),
                      child: Text(option, textDirection: TextDirection.ltr),
                    ),
                  ),
              ],
            ),
          ],
      ]),
    ];
    if (_phraseArrival > 0) {
      slides[3] = _arrival(_phraseArrival, slides[3]);
    }
    return slides;
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
            if (state.phase != VaultPhase.unlocked) _celebratingSetup = false;
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
        if (_celebratingSetup && state.phase == VaultPhase.unlocked) {
          return VaultMoment(
            key: const ValueKey('setup-complete'),
            startup: false,
            title: _completingRecovery
                ? _text('Access restored', 'Доступ восстановлен')
                : _text('Vault created', 'Сейф создан'),
            onComplete: () {
              if (mounted) setState(() => _celebratingSetup = false);
            },
          );
        }
        return Listener(
          onPointerDown: (_) => widget.controller.activity(),
          onPointerHover: (_) => widget.controller.activity(),
          onPointerSignal: (_) => widget.controller.activity(),
          child: Material(
            color: WantTheme.of(context).color('background'),
            textStyle: WantTheme.of(context).forui.typography.body.sm
                .copyWith(fontSize: 16, height: 1.7),
            child: _ambient(
              state,
              setup,
              child: SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: setup ? 720 : double.infinity,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        spacing: 16,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                spacing: 12,
                                children: [
                                  VaultSecretAction(
                                    key: const ValueKey('want-pass-website'),
                                    label: _text(
                                      'Open Want Pass website',
                                      'Открыть сайт Want Pass',
                                    ),
                                    onPressed: () => unawaited(_openWebsite()),
                                    child: SizedBox.square(
                                      dimension: 48,
                                      child: WantSvg3D.asset(
                                        'assets/brand/logo.svg',
                                        semanticsLabel: 'Want Pass',
                                        glow: !MediaQuery.highContrastOf(
                                          context,
                                        ),
                                        placeholderBuilder: (_) => Image.asset(
                                          'assets/brand/logo-dark.png',
                                        ),
                                        errorBuilder: (_, _) => Image.asset(
                                          'assets/brand/logo-dark.png',
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (!setup &&
                                      state.phase != VaultPhase.unavailable)
                                    VaultPadlock(
                                      key: const ValueKey('vault-padlock'),
                                      opened:
                                          state.phase == VaultPhase.unlocked,
                                      label: state.phase == VaultPhase.unlocked
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
                                          : state.phase == VaultPhase.unlocked
                                          ? () => unawaited(
                                              widget.controller.lock(),
                                            )
                                          : state.phase == VaultPhase.locked
                                          ? _showUnlock
                                          : null,
                                    ),
                                ],
                              ),
                              if (widget.appearance case final appearance?)
                                AppearanceControls(controller: appearance),
                            ],
                          ),
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) => _surface(
                                setup: setup,
                                phase: state.phase,
                                child: SizedBox(
                                  height: constraints.maxHeight,
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      spacing: 12,
                                      children: [
                                        if (setup)
                                          _setupChrome(state)
                                        else if (state.phase ==
                                                VaultPhase.loading ||
                                            state.phase ==
                                                VaultPhase.unavailable)
                                          Semantics(
                                            header: true,
                                            child: WantTypography(
                                              _title(state),
                                              variant: WantTypographyVariant.h2,
                                            ),
                                          ),
                                        if (setup)
                                          Expanded(
                                            child: IgnorePointer(
                                              ignoring: _sliding,
                                              child: PageView(
                                                controller: _pages,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                children: _slides(state),
                                              ),
                                            ),
                                          )
                                        else if (state.phase ==
                                            VaultPhase.unlocked)
                                          Expanded(
                                            child: VaultContentView(
                                              controller: widget.controller,
                                              appearance: widget.appearance,
                                            ),
                                          )
                                        else if (state.phase ==
                                            VaultPhase.locked)
                                          Expanded(
                                            child: Center(
                                              child: VaultUnlockForm(
                                                controller: widget.controller,
                                                focusNode: _unlockFocus,
                                                onRecovery: _startRecovery,
                                                errorText: _error,
                                              ),
                                            ),
                                          )
                                        else
                                          Expanded(child: _slide([])),
                                        if (state.error case final error?
                                            when state.phase !=
                                                    VaultPhase.locked &&
                                                state.phase !=
                                                    VaultPhase.unlocked)
                                          WantTypography(
                                            _error(error),
                                            colorRole: 'destructive',
                                            liveRegion: true,
                                          ),
                                        if (state.busy && setup)
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
                                                    : _step == 5
                                                    ? 'vault-confirm'
                                                    : 'setup-next',
                                              ),
                                              onPressed: _canAdvance(state)
                                                  ? () => unawaited(_next())
                                                  : null,
                                              child: Text(
                                                _step == 5
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
      'Check your password or recovery phrase.',
      'Проверьте пароль или фразу восстановления.',
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
