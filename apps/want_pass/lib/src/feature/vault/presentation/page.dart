import 'dart:async';

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
  late final PageController _pages;
  final _background = WantBackgroundController();
  final _headingFocus = FocusNode();
  int _step = 1;
  int _navigationEpoch = 0;
  bool _recovering = false, _showHint = false;
  DialogRoute<void>? _qr;
  @override
  void initState() {
    super.initState();
    _step = widget.appearance?.state.settings.configured == false ? 0 : 1;
    _pages = PageController(initialPage: _step);
    HardwareKeyboard.instance.addHandler(_keyboard);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.controller.state.phase == VaultPhase.locked) {
        unawaited(widget.controller.readHints());
      }
    });
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

  void _hideQr() {
    final route = _qr;
    _qr = null;
    if (route != null && route.isActive) route.navigator?.removeRoute(route);
  }

  void _clear() {
    for (final field in [
      _password,
      _confirmation,
      _phrase,
      _passwordHint,
      _recoveryHint,
    ]) {
      field.clear();
    }
    _hideQr();
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_keyboard);
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

  String _text(String en, String ru) =>
      Localizations.localeOf(context).languageCode == 'ru' ? ru : en;
  void _go(int step) {
    _navigationEpoch++;
    widget.controller.dismissFailure();
    _hideQr();
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

  Future<void> _next(VaultState state) async {
    if (state.busy || widget.appearance?.state.busy == true) return;
    final navigationEpoch = _navigationEpoch;
    if (_step == 0) {
      final appearance = widget.appearance;
      if (!_recovering && appearance != null) {
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
        if (!mounted ||
            navigationEpoch != _navigationEpoch ||
            appearance.state.failed) {
          return;
        }
      }
      if (mounted) _go(1);
    } else if (_step == 1) {
      await widget.controller.prepareSetup(
        password: _password.text,
        confirmation: _confirmation.text,
        phrase: _recovering ? _phrase.text : null,
      );
      if (mounted &&
          navigationEpoch == _navigationEpoch &&
          widget.controller.state.setupChallenge != null &&
          widget.controller.state.error == null) {
        _go(2);
      }
    } else if (_step == 2) {
      _go(3);
    } else if (_step < 5 && state.quizPassed[_step - 3]) {
      _go(_step + 1);
    } else if (_step == 5 && state.quizPassed.every((v) => v)) {
      await widget.controller.confirmSetup(
        answers: state.setupAnswers.cast<String>(),
        password: _password.text,
        hints: VaultHintsDtoV2(
          password: _passwordHint.text,
          recovery: _recoveryHint.text,
        ),
      );
    }
  }

  Widget _secret(
    String key,
    String label,
    TextEditingController controller,
    VaultState state, {
    bool last = false,
  }) => VaultSecretInput(
    key: ValueKey(key),
    label: label,
    controller: controller,
    enabled: !state.busy,
    autofocus: false,
    last: last,
    onSubmitted: () => unawaited(_next(state)),
  );
  Widget _hint(
    String key,
    String label,
    TextEditingController controller,
    VaultState state,
  ) => WantInput(
    key: ValueKey(key),
    label: Text(label),
    controller: controller,
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
  Widget _row(List<Widget> buttons) => LayoutBuilder(
    builder: (context, size) => size.maxWidth < 420
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: buttons,
          )
        : Row(
            spacing: 12,
            children: [for (final button in buttons) Expanded(child: button)],
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
    if (state.phase == VaultPhase.unlocked) return _text('Vault', 'Сейф');
    if (state.phase == VaultPhase.locked && !_recovering) {
      return _text('Unlock', 'Разблокировка');
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
      2 => _text('Save recovery phrase', 'Сохраните фразу'),
      _ => _text('Check ${_step - 2} of 3', 'Проверка ${_step - 2} из 3'),
    };
  }

  void _showQr(VaultState state) {
    final challenge = state.setupChallenge;
    if (state.busy || challenge == null || _qr != null) return;
    final route = DialogRoute<void>(
      context: context,
      builder: (context) => WantDialog(
        title: _text('Recovery QR', 'QR восстановления'),
        actions: WantButton(
          onPressed: _hideQr,
          child: Text(_text('Close', 'Закрыть')),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            Text(
              _text(
                'Anyone with this code can open your vault. Keep it private.',
                'Этот код даёт доступ к сейфу. Храните его в тайне.',
              ),
            ),
            ExcludeSemantics(
              child: QrImageView(
                data: challenge.words.join(' '),
                size: 260,
                backgroundColor: Colors.white,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Colors.black,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    _qr = route;
    unawaited(
      Navigator.of(context).push(route).whenComplete(() {
        if (identical(_qr, route)) _qr = null;
      }),
    );
  }

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

  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<VaultController, VaultState>(
    bloc: widget.controller,
    listenWhen: (a, b) => a.phase != b.phase,
    listener: (context, state) {
      if (state.phase != VaultPhase.confirmation) {
        _navigationEpoch++;
        _clear();
        setState(() {
          _recovering = false;
          _showHint = false;
          _step = widget.appearance?.state.settings.configured == false ? 0 : 1;
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
      final challenge = state.setupChallenge;
      final uncertain =
          state.error is VaultRejectedErrorV1 &&
          (state.error as VaultRejectedErrorV1).kind ==
              VaultFailureKindV1.writeUncertain;
      final nextEnabled =
          !state.busy &&
          widget.appearance?.state.busy != true &&
          (_step < 3 || state.quizPassed[_step - 3]);
      final appearance = widget.appearance;
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
                            Image.asset(
                              Theme.of(context).brightness == Brightness.dark
                                  ? 'assets/brand/logo-dark.png'
                                  : 'assets/brand/logo-light.png',
                              width: 48,
                              height: 48,
                              excludeFromSemantics: true,
                            ),
                            if (appearance != null)
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
                                      if (setup)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            for (var i = 0; i < 6; i++)
                                              Semantics(
                                                label: _text(
                                                  'Step ${i + 1} of 6',
                                                  'Шаг ${i + 1} из 6',
                                                ),
                                                selected: i == _step,
                                                child: AnimatedContainer(
                                                  duration:
                                                      WantTheme.reducedMotionOf(
                                                        context,
                                                      )
                                                      ? Duration.zero
                                                      : const Duration(
                                                          milliseconds: 180,
                                                        ),
                                                  width: i == _step ? 36 : 16,
                                                  height: 6,
                                                  decoration: BoxDecoration(
                                                    color: WantTheme.of(context)
                                                        .color(
                                                          i <= _step
                                                              ? 'primary'
                                                              : 'muted',
                                                        ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
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
                                            children: [
                                              _slide(
                                                _recovering
                                                    ? [
                                                        WantTypography(
                                                          _text(
                                                            'Use the existing vault file and its 24 words. Recovery replaces its password and phrase after confirmation.',
                                                            'Нужны текущий файл сейфа и его 24 слова. После подтверждения восстановление заменит пароль и фразу.',
                                                          ),
                                                        ),
                                                        if (state
                                                            .hints
                                                            .recovery
                                                            .isNotEmpty)
                                                          Text(
                                                            state
                                                                .hints
                                                                .recovery,
                                                          ),
                                                        _secret(
                                                          'recovery-phrase',
                                                          _text(
                                                            'Recovery phrase',
                                                            'Фраза восстановления',
                                                          ),
                                                          _phrase,
                                                          state,
                                                          last: true,
                                                        ),
                                                      ]
                                                    : [
                                                        WantTypography(
                                                          _text(
                                                            'Choose your language and theme. You can change them above later.',
                                                            'Выберите язык и тему. Позже их можно изменить вверху.',
                                                          ),
                                                        ),
                                                        if (appearance
                                                                ?.state
                                                                .failed ==
                                                            true)
                                                          Text(
                                                            _text(
                                                              'Could not save appearance. Try again.',
                                                              'Не удалось сохранить оформление. Повторите попытку.',
                                                            ),
                                                          ),
                                                      ],
                                              ),
                                              _slide([
                                                _secret(
                                                  'master-password',
                                                  _text(
                                                    'Master password',
                                                    'Мастер-пароль',
                                                  ),
                                                  _password,
                                                  state,
                                                ),
                                                _secret(
                                                  'password-confirmation',
                                                  _text(
                                                    'Confirm password',
                                                    'Повторите пароль',
                                                  ),
                                                  _confirmation,
                                                  state,
                                                  last: true,
                                                ),
                                                WantTypography(
                                                  _text(
                                                    'At least 15 characters, uppercase and lowercase letters, a digit and a special character. Spaces and Unicode are allowed.',
                                                    'Минимум 15 символов, заглавная и строчная буквы, цифра и спецсимвол. Разрешены пробелы и Unicode.',
                                                  ),
                                                  colorRole: 'muted-foreground',
                                                ),
                                                _hint(
                                                  'password-hint',
                                                  _text(
                                                    'Password hint (optional)',
                                                    'Подсказка к паролю (необязательно)',
                                                  ),
                                                  _passwordHint,
                                                  state,
                                                ),
                                                WantTypography(
                                                  _text(
                                                    'Hints are stored openly. Do not include your password or recovery words.',
                                                    'Подсказки хранятся открыто. Не указывайте пароль или слова восстановления.',
                                                  ),
                                                  colorRole: 'muted-foreground',
                                                ),
                                              ]),
                                              _slide([
                                                WantTypography(
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
                                                      for (
                                                        var i = 0;
                                                        i <
                                                            challenge
                                                                .words
                                                                .length;
                                                        i++
                                                      )
                                                        SizedBox(
                                                          width: 130,
                                                          child: Row(
                                                            spacing: 8,
                                                            children: [
                                                              WantTypography(
                                                                '${i + 1}',
                                                                variant:
                                                                    WantTypographyVariant
                                                                        .caption,
                                                                colorRole: 'muted-foreground',
                                                              ),
                                                              Text(
                                                                challenge
                                                                    .words[i],
                                                                textDirection:
                                                                    TextDirection
                                                                        .ltr,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                _row([
                                                  WantButton(
                                                    key: const ValueKey(
                                                      'recovery-download',
                                                    ),
                                                    variant: WantButtonVariant
                                                        .secondary,
                                                    onPressed: state.busy
                                                        ? null
                                                        : () => unawaited(
                                                            widget.controller
                                                                .downloadRecovery(),
                                                          ),
                                                    child: Text(
                                                      _text(
                                                        'Download',
                                                        'Скачать',
                                                      ),
                                                    ),
                                                  ),
                                                  WantButton(
                                                    key: const ValueKey(
                                                      'recovery-copy',
                                                    ),
                                                    variant: WantButtonVariant
                                                        .secondary,
                                                    onPressed: state.busy
                                                        ? null
                                                        : () => unawaited(
                                                            widget.controller
                                                                .copyRecovery(),
                                                          ),
                                                    child: Text(
                                                      _text(
                                                        'Copy',
                                                        'Скопировать',
                                                      ),
                                                    ),
                                                  ),
                                                  WantButton(
                                                    key: const ValueKey(
                                                      'recovery-qr',
                                                    ),
                                                    variant: WantButtonVariant
                                                        .secondary,
                                                    onPressed: state.busy
                                                        ? null
                                                        : () => _showQr(state),
                                                    child: const Text('QR'),
                                                  ),
                                                ]),
                                                WantTypography(
                                                  _text(
                                                    'TXT, clipboard and QR contain the phrase in plain text. Clipboard clears after 60 seconds if unchanged.',
                                                    'TXT, буфер обмена и QR содержат открытую фразу. Буфер очищается через 60 секунд, если не изменён.',
                                                  ),
                                                  colorRole: 'muted-foreground',
                                                ),
                                                _hint(
                                                  'recovery-hint',
                                                  _text(
                                                    'Where you keep the phrase (optional)',
                                                    'Где хранится фраза (необязательно)',
                                                  ),
                                                  _recoveryHint,
                                                  state,
                                                ),
                                                WantTypography(
                                                  _text(
                                                    'This hint is visible before unlock.',
                                                    'Эта подсказка видна до разблокировки.',
                                                  ),
                                                  colorRole: 'muted-foreground',
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
                                                        for (final option
                                                            in challenge
                                                                .choices[i])
                                                          Semantics(
                                                            selected:
                                                                state
                                                                    .setupAnswers[i] ==
                                                                option,
                                                            inMutuallyExclusiveGroup:
                                                                true,
                                                            child: WantButton(
                                                              key: ValueKey(
                                                                'quiz-$i-$option',
                                                              ),
                                                              variant:
                                                                  state.setupAnswers[i] ==
                                                                      option
                                                                  ? WantButtonVariant
                                                                        .primary
                                                                  : WantButtonVariant
                                                                        .secondary,
                                                              onPressed:
                                                                  state.busy ||
                                                                      uncertain
                                                                  ? null
                                                                  : () => widget
                                                                        .controller
                                                                        .chooseSetupWord(
                                                                          i,
                                                                          option,
                                                                        ),
                                                              child: Text(
                                                                option,
                                                                textDirection:
                                                                    TextDirection
                                                                        .ltr,
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ],
                                                ]),
                                            ],
                                          ),
                                        )
                                      else
                                        Expanded(
                                          child: _slide([
                                            if (state.phase ==
                                                VaultPhase.unlocked) ...[
                                              WantTypography(
                                                _text(
                                                  'There are no secrets in this vault yet.',
                                                  'В сейфе пока нет секретов.',
                                                ),
                                              ),
                                              WantTypography(
                                                _text(
                                                  'Locks after five idle minutes and when your Mac locks or sleeps.',
                                                  'Блокируется через пять минут бездействия, при блокировке и сне Mac.',
                                                ),
                                              ),
                                              WantButton(
                                                key: const ValueKey(
                                                  'vault-lock',
                                                ),
                                                onPressed: () => unawaited(
                                                  widget.controller.lock(),
                                                ),
                                                child: Text(
                                                  _text(
                                                    'Lock vault',
                                                    'Заблокировать сейф',
                                                  ),
                                                ),
                                              ),
                                            ],
                                            if (state.phase ==
                                                VaultPhase.locked) ...[
                                              VaultSecretInput(
                                                key: const ValueKey(
                                                  'master-password',
                                                ),
                                                label: _text(
                                                  'Master password',
                                                  'Мастер-пароль',
                                                ),
                                                controller: _password,
                                                enabled: !state.busy,
                                                autofocus: false,
                                                last: true,
                                                onSubmitted: () => unawaited(
                                                  widget.controller.unlock(
                                                    _password.text,
                                                  ),
                                                ),
                                              ),
                                              _row([
                                                WantButton(
                                                  key: const ValueKey(
                                                    'vault-unlock',
                                                  ),
                                                  onPressed: state.busy
                                                      ? null
                                                      : () => unawaited(
                                                          widget.controller
                                                              .unlock(
                                                                _password.text,
                                                              ),
                                                        ),
                                                  child: Text(
                                                    _text(
                                                      'Unlock',
                                                      'Разблокировать',
                                                    ),
                                                  ),
                                                ),
                                                WantButton(
                                                  key: const ValueKey(
                                                    'vault-recovery',
                                                  ),
                                                  variant: WantButtonVariant
                                                      .secondary,
                                                  onPressed: state.busy
                                                      ? null
                                                      : () {
                                                          widget.controller
                                                              .dismissFailure();
                                                          setState(
                                                            () => _showHint =
                                                                !_showHint,
                                                          );
                                                        },
                                                  child: Text(
                                                    _text(
                                                      'Forgot password?',
                                                      'Забыли пароль?',
                                                    ),
                                                  ),
                                                ),
                                              ]),
                                              if (_showHint) ...[
                                                WantTypography(
                                                  state.hints.password.isEmpty
                                                      ? _text(
                                                          'No password hint was saved.',
                                                          'Подсказка к паролю не сохранена.',
                                                        )
                                                      : state.hints.password,
                                                ),
                                                WantButton(
                                                  key: const ValueKey(
                                                    'start-recovery',
                                                  ),
                                                  variant: WantButtonVariant
                                                      .secondary,
                                                  onPressed: state.busy
                                                      ? null
                                                      : () {
                                                          widget.controller
                                                              .dismissFailure();
                                                          _password.clear();
                                                          setState(() {
                                                            _recovering = true;
                                                            _step = 0;
                                                          });
                                                          WidgetsBinding
                                                              .instance
                                                              .addPostFrameCallback((
                                                                _,
                                                              ) {
                                                                if (mounted &&
                                                                    _pages
                                                                        .hasClients) {
                                                                  _pages
                                                                      .jumpToPage(
                                                                        0,
                                                                      );
                                                                }
                                                              });
                                                        },
                                                  child: Text(
                                                    _text(
                                                      'Use recovery phrase',
                                                      'Восстановить по фразе',
                                                    ),
                                                  ),
                                                ),
                                              ],
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
                                          if (_step > 0)
                                            WantButton(
                                              key: const ValueKey('setup-back'),
                                              variant:
                                                  WantButtonVariant.secondary,
                                              onPressed: state.busy || uncertain
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
                                              onPressed: state.busy
                                                  ? null
                                                  : () {
                                                      _clear();
                                                      setState(
                                                        () =>
                                                            _recovering = false,
                                                      );
                                                    },
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
                                            onPressed: nextEnabled
                                                ? () => unawaited(_next(state))
                                                : null,
                                            child: Text(
                                              _step == 5
                                                  ? _text('Finish', 'Завершить')
                                                  : _text('Continue', 'Далее'),
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
  );
}
