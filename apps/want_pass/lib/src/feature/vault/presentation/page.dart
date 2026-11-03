import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:want_allure/want_allure.dart';
import 'package:want_pass/src/feature/vault/application/_barrel.dart';
import 'package:want_pass_core/want_pass_core.dart';

class VaultPage extends StatefulWidget {
  final VaultController controller;
  const VaultPage({super.key, required this.controller});
  @override
  State<VaultPage> createState() => _VaultPageState();
}

class _VaultPageState extends State<VaultPage> {
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  final _phrase = TextEditingController();
  final _answers = List.generate(3, (_) => TextEditingController());
  bool _recovering = false;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_keyboardActivity);
  }

  bool _keyboardActivity(KeyEvent event) {
    widget.controller.activity();
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      unawaited(widget.controller.lock());
      return true;
    }
    return false;
  }

  void _clear() {
    for (final field in [_password, _confirmation, _phrase, ..._answers]) {
      field.clear();
    }
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_keyboardActivity);
    for (final field in [_password, _confirmation, _phrase, ..._answers]) {
      field.dispose();
    }
    super.dispose();
  }

  String _text(String english, String russian) =>
      Localizations.localeOf(context).languageCode == 'ru' ? russian : english;

  void _submit(VaultState state) {
    if (state.busy) return;
    if (state.phase == VaultPhase.confirmation) {
      final answers = _answers
          .map((field) => field.text)
          .toList(growable: false);
      _clear();
      unawaited(widget.controller.confirm(answers));
    } else {
      final password = _password.text;
      final confirmation = _confirmation.text;
      final phrase = _phrase.text;
      _clear();
      if (_recovering) {
        unawaited(
          widget.controller.prepareRecovery(
            phrase: phrase,
            password: password,
            confirmation: confirmation,
          ),
        );
      } else if (state.phase == VaultPhase.missing) {
        unawaited(
          widget.controller.prepareCreation(
            password: password,
            confirmation: confirmation,
          ),
        );
      } else {
        unawaited(widget.controller.unlock(password));
      }
    }
  }

  Widget _secretInput(
    String key,
    String label,
    TextEditingController controller,
    VaultState state, {
    bool autofocus = false,
    bool last = false,
  }) => KeyedSubtree(
    key: ValueKey(key),
    // WantInput does not expose the controls that disable keyboard learning.
    child: TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: WantTheme.of(context).color('muted-foreground'),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: WantTheme.of(context).color('border')),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: WantTheme.of(context).color('primary')),
        ),
      ),
      style: TextStyle(color: WantTheme.of(context).color('foreground')),
      cursorColor: WantTheme.of(context).color('primary'),
      obscureText: true,
      autofocus: autofocus,
      enabled: !state.busy,
      autocorrect: false,
      enableSuggestions: false,
      enableIMEPersonalizedLearning: false,
      stylusHandwritingEnabled: false,
      autofillHints: const [],
      smartDashesType: SmartDashesType.disabled,
      smartQuotesType: SmartQuotesType.disabled,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: last ? TextInputAction.done : TextInputAction.next,
      onSubmitted: last ? (_) => _submit(state) : null,
    ),
  );

  String _error(VaultErrorV1 error) => switch (error) {
    VaultRejectedErrorV1(kind: VaultFailureKindV1.invalidPassword) => _text(
      'Use at least 15 characters and at most 1,024 UTF-8 bytes.',
      'Используйте не менее 15 символов и не более 1024 UTF-8 байт.',
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
    listenWhen: (previous, current) => previous.phase != current.phase,
    listener: (context, state) {
      if (state.phase != VaultPhase.confirmation) {
        _clear();
        if (state.phase != VaultPhase.loading) {
          setState(() => _recovering = false);
        }
      }
    },
    builder: (context, state) {
      final creating = state.phase == VaultPhase.missing;
      final challenge = state.challenge;
      return Listener(
        onPointerDown: (_) => widget.controller.activity(),
        onPointerHover: (_) => widget.controller.activity(),
        onPointerSignal: (_) => widget.controller.activity(),
        child: Material(
          color: WantTheme.of(context).color('background'),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: WantCard(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 16,
                      children: [
                        const WantTypography(
                          'Want Pass',
                          variant: WantTypographyVariant.h1,
                        ),
                        if (state.phase == VaultPhase.loading)
                          WantTypography(
                            _text('Opening your vault…', 'Открываем сейф…'),
                            liveRegion: true,
                          ),
                        if (state.phase == VaultPhase.unavailable)
                          WantTypography(
                            _text(
                              'Your vault is unavailable.',
                              'Сейф недоступен.',
                            ),
                            variant: WantTypographyVariant.lead,
                          ),
                        if (state.phase == VaultPhase.unlocked) ...[
                          WantTypography(
                            _text(
                              'Your vault is unlocked.',
                              'Сейф разблокирован.',
                            ),
                            variant: WantTypographyVariant.lead,
                          ),
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
                            colorRole: 'muted-foreground',
                          ),
                          WantButton(
                            key: const ValueKey('vault-lock'),
                            onPressed: () =>
                                unawaited(widget.controller.lock()),
                            child: Text(
                              _text('Lock vault', 'Заблокировать сейф'),
                            ),
                          ),
                        ],
                        if (state.phase == VaultPhase.confirmation &&
                            challenge != null) ...[
                          WantTypography(
                            _text(
                              'Save your recovery phrase',
                              'Сохраните фразу восстановления',
                            ),
                            variant: WantTypographyVariant.lead,
                          ),
                          WantTypography(
                            _text(
                              'These 24 words grant access to the vault. Write them down in a safe place. They cannot restore a deleted vault file.',
                              'Эти 24 слова дают доступ к сейфу. Запишите их в безопасном месте. Они не восстанавливают удалённый файл сейфа.',
                            ),
                          ),
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children: [
                              for (var i = 0; i < challenge.words.length; i++)
                                SizedBox(
                                  width: 118,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      WantTypography(
                                        '${i + 1}',
                                        colorRole: 'muted-foreground',
                                      ),
                                      WantTypography(challenge.words[i]),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          WantTypography(
                            _text(
                              'The phrase disappears after confirmation. Enter the requested words to confirm your copy.',
                              'После подтверждения фраза больше не отображается. Введите запрошенные слова, чтобы проверить вашу запись.',
                            ),
                          ),
                          for (var i = 0; i < 3; i++)
                            _secretInput(
                              'recovery-confirm-$i',
                              _text(
                                'Word ${challenge.positions[i] + 1}',
                                'Слово № ${challenge.positions[i] + 1}',
                              ),
                              _answers[i],
                              state,
                              last: i == 2,
                            ),
                          WantButton(
                            key: const ValueKey('vault-confirm'),
                            onPressed: state.busy ? null : () => _submit(state),
                            child: Text(
                              _text(
                                'Confirm saved phrase',
                                'Подтвердить сохранение фразы',
                              ),
                            ),
                          ),
                          WantButton(
                            variant: WantButtonVariant.secondary,
                            onPressed: state.busy
                                ? null
                                : () => unawaited(widget.controller.lock()),
                            child: Text(_text('Cancel', 'Отмена')),
                          ),
                        ],
                        if (state.phase == VaultPhase.missing ||
                            state.phase == VaultPhase.locked) ...[
                          WantTypography(
                            _recovering
                                ? _text(
                                    'Recover access',
                                    'Восстановление доступа',
                                  )
                                : creating
                                ? _text(
                                    'Create your local vault',
                                    'Создайте локальный сейф',
                                  )
                                : _text(
                                    'Unlock your vault',
                                    'Разблокируйте сейф',
                                  ),
                            variant: WantTypographyVariant.lead,
                          ),
                          if (creating)
                            WantTypography(
                              _text(
                                'Works without an account or network. Keep your 24 recovery words to restore access.',
                                'Работает без аккаунта и сети. Сохраните 24 слова для восстановления доступа.',
                              ),
                            ),
                          if (_recovering) ...[
                            WantTypography(
                              _text(
                                'Recovery requires this vault file and its 24 words. A new password and phrase replace the current access methods after confirmation.',
                                'Для восстановления нужны файл сейфа и его 24 слова. Новый пароль и фраза заменят текущие способы доступа после подтверждения.',
                              ),
                            ),
                            _secretInput(
                              'recovery-phrase',
                              _text('Recovery phrase', 'Фраза восстановления'),
                              _phrase,
                              state,
                            ),
                          ],
                          _secretInput(
                            'master-password',
                            _recovering
                                ? _text(
                                    'New master password',
                                    'Новый мастер-пароль',
                                  )
                                : _text('Master password', 'Мастер-пароль'),
                            _password,
                            state,
                            autofocus: true,
                            last: !creating && !_recovering,
                          ),
                          if (creating || _recovering) ...[
                            WantTypography(
                              _text(
                                'At least 15 characters. Spaces and Unicode are allowed.',
                                'Не менее 15 символов. Разрешены пробелы и Unicode.',
                              ),
                              colorRole: 'muted-foreground',
                            ),
                            _secretInput(
                              'password-confirmation',
                              _text(
                                'Confirm master password',
                                'Повторите мастер-пароль',
                              ),
                              _confirmation,
                              state,
                              last: true,
                            ),
                          ],
                          WantButton(
                            key: ValueKey(
                              _recovering
                                  ? 'vault-recover'
                                  : creating
                                  ? 'vault-create'
                                  : 'vault-unlock',
                            ),
                            onPressed: state.busy ? null : () => _submit(state),
                            child: Text(
                              _recovering
                                  ? _text(
                                      'Continue recovery',
                                      'Продолжить восстановление',
                                    )
                                  : creating
                                  ? _text('Create vault', 'Создать сейф')
                                  : _text('Unlock', 'Разблокировать'),
                            ),
                          ),
                          if (!creating)
                            WantButton(
                              key: const ValueKey('vault-recovery'),
                              variant: WantButtonVariant.secondary,
                              onPressed: state.busy
                                  ? null
                                  : () {
                                      _clear();
                                      setState(
                                        () => _recovering = !_recovering,
                                      );
                                    },
                              child: Text(
                                _recovering
                                    ? _text(
                                        'Back to unlock',
                                        'Назад к разблокировке',
                                      )
                                    : _text(
                                        'Forgot your password?',
                                        'Забыли пароль?',
                                      ),
                              ),
                            ),
                        ],
                        if (state.busy)
                          WantTypography(
                            _text('Working…', 'Выполняем операцию…'),
                            liveRegion: true,
                          ),
                        if (state.error case final error?)
                          WantTypography(
                            _error(error),
                            colorRole: 'destructive',
                            liveRegion: true,
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
