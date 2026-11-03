import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:want_allure/want_allure.dart';
import 'package:want_pass/src/feature/vault/application/_barrel.dart';
import 'package:want_pass/src/feature/vault/presentation/_barrel.dart';
import 'package:want_pass_core/want_pass_core.dart';

final class VaultUnlockForm extends StatefulWidget {
  final VaultController controller;
  final FocusNode focusNode;
  final VoidCallback onRecovery;
  final String requirements;
  final String Function(VaultErrorV1) errorText;
  const VaultUnlockForm({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onRecovery,
    required this.requirements,
    required this.errorText,
  });
  @override
  State<VaultUnlockForm> createState() => _VaultUnlockFormState();
}

final class _VaultUnlockFormState extends State<VaultUnlockForm> {
  final _password = TextEditingController();
  Timer? _debounce;
  String _lastText = '';
  int _revision = 0;
  bool _rejected = false, _submitting = false, _invalidAttempt = false;
  String _text(String en, String ru) =>
      Localizations.localeOf(context).languageCode == 'ru' ? ru : en;

  @override
  void initState() {
    super.initState();
    _password.addListener(_edited);
  }

  void _edited() {
    final text = _password.text;
    if (text == _lastText) return;
    _lastText = text;
    _revision++;
    _debounce?.cancel();
    if (_invalidAttempt) setState(() => _invalidAttempt = false);
    widget.controller.dismissFailure();
    unawaited(widget.controller.validatePassword(''));
    if (text.isNotEmpty) {
      _debounce = Timer(
        const Duration(milliseconds: 150),
        () => unawaited(widget.controller.validatePassword(text)),
      );
    }
  }

  Future<void> _submit() async {
    if (_submitting || widget.controller.state.busy) return;
    _debounce?.cancel();
    final revision = ++_revision;
    final text = _password.text;
    setState(() => _submitting = true);
    try {
      final valid = await widget.controller.validatePassword(text);
      if (!mounted || revision != _revision || text != _password.text) return;
      if (!valid) {
        setState(
          () => _invalidAttempt =
              text.isEmpty || widget.controller.state.passwordValid == false,
        );
        return;
      }
      await widget.controller.unlock(text);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _revision++;
    _debounce?.cancel();
    _password.removeListener(_edited);
    _password.clear();
    _lastText = '';
    _password.dispose();
    unawaited(widget.controller.validatePassword(''));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      BlocListener<VaultController, VaultState>(
        bloc: widget.controller,
        listener: (context, state) {
          if (state.error case VaultRejectedErrorV1(
            kind: VaultFailureKindV1.credentials,
          )) {
            setState(() => _rejected = true);
          }
        },
        child: BlocBuilder<VaultController, VaultState>(
          bloc: widget.controller,
          builder: (context, state) {
            final busy = state.busy || _submitting;
            final rejected =
                state.error is VaultRejectedErrorV1 &&
                (state.error! as VaultRejectedErrorV1).kind ==
                    VaultFailureKindV1.credentials;
            final operationalError = switch (state.error) {
              VaultRejectedErrorV1(
                kind: VaultFailureKindV1.credentials ||
                    VaultFailureKindV1.invalidPassword,
              ) =>
                null,
              final error => error,
            };
            final submit = WantButton(
              key: const ValueKey('vault-unlock'),
              size: WantButtonSize.icon,
              variant: state.passwordValid == true
                  ? WantButtonVariant.primary
                  : WantButtonVariant.secondary,
              semanticsLabel: _text('Continue', 'Продолжить'),
              onPressed: busy ? null : () => unawaited(_submit()),
              child: const WantIcon(WantIcons.arrowRight),
            );
            final recovery = WantButton(
              key: const ValueKey('vault-recovery'),
              variant: WantButtonVariant.secondary,
              onPressed: busy ? null : widget.onRecovery,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 8,
                children: [
                  const WantIcon(WantIcons.arrowLeft, size: 18),
                  Flexible(
                    child: Text(_text('Recover access', 'Восстановить доступ')),
                  ),
                ],
              ),
            );
            final hint = WantPopover(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 8,
                children: [
                  const WantIcon(WantIcons.info, size: 18),
                  Flexible(
                    child: Text(_text('Show hint', 'Показать подсказку')),
                  ),
                ],
              ),
              triggerBuilder: (context, toggle, child) => WantButton(
                key: const ValueKey('vault-show-hint'),
                variant: WantButtonVariant.secondary,
                onPressed: busy ? null : toggle,
                child: child,
              ),
              contentBuilder: (context, close) => ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 280),
                child: WantTypography(
                  state.hints.password.isEmpty
                      ? _text(
                          'No password hint was added.',
                          'Подсказка к паролю не добавлена.',
                        )
                      : state.hints.password,
                ),
              ),
            );
            return ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 12,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    spacing: 8,
                    children: [
                      Expanded(
                        child: VaultSecretInput(
                          key: const ValueKey('unlock-password'),
                          label: _text('Master password', 'Мастер-пароль'),
                          controller: _password,
                          enabled: !busy,
                          autofocus: true,
                          focusNode: widget.focusNode,
                          last: true,
                          invalid: _invalidAttempt || rejected,
                          postfix: VaultPasswordHelp(
                            label: _text(
                              'Password requirements',
                              'Требования к паролю',
                            ),
                            message: widget.requirements,
                          ),
                          onSubmitted: () => unawaited(_submit()),
                        ),
                      ),
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned.fill(
                            child: IgnorePointer(
                              child: ExcludeSemantics(
                                child: AnimatedOpacity(
                                  opacity:
                                      state.passwordValid == true &&
                                          !busy &&
                                          !MediaQuery.highContrastOf(context)
                                      ? 1
                                      : 0,
                                  duration: WantTheme.reducedMotionOf(context)
                                      ? Duration.zero
                                      : const Duration(milliseconds: 180),
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(999),
                                      boxShadow: [
                                        BoxShadow(
                                          color: WantTheme.of(context)
                                              .color('primary')
                                              .withValues(alpha: .25),
                                          blurRadius: 24,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          submit,
                        ],
                      ),
                    ],
                  ),
                  if (_rejected)
                    LayoutBuilder(
                      builder: (context, constraints) =>
                          constraints.maxWidth < 360 ||
                              MediaQuery.textScalerOf(context).scale(16) > 24
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              spacing: 8,
                              children: [recovery, hint],
                            )
                          : Row(
                              spacing: 8,
                              children: [
                                Expanded(child: recovery),
                                Expanded(child: hint),
                              ],
                            ),
                    ),
                  if (operationalError != null)
                    WantTypography(
                      widget.errorText(operationalError),
                      colorRole: 'destructive',
                      liveRegion: true,
                    ),
                ],
              ),
            );
          },
        ),
      );
}
