import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:want_allure/want_allure.dart';

final class VaultSecretInput extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool enabled;
  final bool autofocus;
  final bool last;
  final bool multiline;
  final Widget? postfix;
  final bool invalid;
  final VoidCallback onSubmitted;
  const VaultSecretInput({
    super.key,
    required this.label,
    required this.controller,
    required this.enabled,
    required this.autofocus,
    required this.last,
    this.multiline = false,
    this.postfix,
    this.invalid = false,
    required this.onSubmitted,
  });
  @override
  State<VaultSecretInput> createState() => _VaultSecretInputState();
}

final class _VaultSecretInputState extends State<VaultSecretInput> {
  final _obscure = ValueNotifier(true);

  @override
  void dispose() {
    _obscure.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
    valueListenable: _obscure,
    builder: (context, obscure, _) => FTextField(
      label: Text(widget.label),
      error: widget.invalid ? const SizedBox.shrink() : null,
      control: FTextFieldControl.managed(controller: widget.controller),
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      obscureText: !widget.multiline && obscure,
      maxLines: widget.multiline ? 4 : 1,
      keyboardType: widget.multiline
          ? TextInputType.multiline
          : TextInputType.visiblePassword,
      autocorrect: false,
      enableSuggestions: false,
      enableIMEPersonalizedLearning: false,
      stylusHandwritingEnabled: false,
      // Empty hints still enable autofill and macOS completion when revealed.
      autofillHints: null,
      smartDashesType: SmartDashesType.disabled,
      smartQuotesType: SmartQuotesType.disabled,
      textInputAction: widget.last
          ? TextInputAction.done
          : TextInputAction.next,
      onSubmit: widget.last ? (_) => widget.onSubmitted() : null,
      suffixBuilder: widget.multiline
          ? null
          : (context, _, variants) {
              final labels =
                  FLocalizations.of(context) ?? FDefaultLocalizations();
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ?widget.postfix,
                  _postfixButton(
                    label: obscure
                        ? labels.passwordFieldUnobscureTextButtonSemanticsLabel
                        : labels.passwordFieldObscureTextButtonSemanticsLabel,
                    onPressed: variants.contains(FTextFieldVariant.disabled)
                        ? null
                        : () => _obscure.value = !obscure,
                    child: obscure
                        ? context.theme.icons.eye(context)
                        : context.theme.icons.eyeClosed(context),
                  ),
                ],
              );
            },
    ),
  );
}

final class VaultPasswordHelp extends StatelessWidget {
  final String label, message;
  const VaultPasswordHelp({
    super.key,
    required this.label,
    required this.message,
  });
  @override
  Widget build(BuildContext context) => WantPopover(
    child: const WantIcon(WantIcons.question, size: 18),
    triggerBuilder: (context, toggle, child) =>
        _postfixButton(label: label, onPressed: toggle, child: child),
    contentBuilder: (context, close) => ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 280),
      child: Text(message),
    ),
  );
}

Widget _postfixButton({
  required String label,
  required VoidCallback? onPressed,
  required Widget child,
}) => SizedBox.square(
  dimension: 44,
  child: FButton.icon(
    variant: FButtonVariant.ghost,
    style: FButtonStyleDelta.delta(
      decoration: FVariants.from(const BoxDecoration(), variants: {}),
    ),
    semanticsLabel: label,
    onPress: onPressed,
    child: child,
  ),
);
