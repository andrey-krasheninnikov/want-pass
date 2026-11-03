import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:want_allure/want_allure.dart';

final class VaultSecretInput extends StatefulWidget {
  final String label;
  final FocusNode? focusNode;
  final TextEditingController controller;
  final bool enabled;
  final bool autofocus;
  final bool last;
  final bool multiline;
  final bool preserveLineBreaks;
  final bool concealed;
  final Widget? postfix;
  final bool invalid;
  final VoidCallback onSubmitted;
  final ValueChanged<String>? onChanged;
  const VaultSecretInput({
    super.key,
    required this.label,
    this.focusNode,
    required this.controller,
    required this.enabled,
    required this.autofocus,
    required this.last,
    this.multiline = false,
    this.preserveLineBreaks = false,
    this.concealed = true,
    this.postfix,
    this.invalid = false,
    required this.onSubmitted,
    this.onChanged,
  });
  @override
  State<VaultSecretInput> createState() => _VaultSecretInputState();
}

final class _VaultSecretInputState extends State<VaultSecretInput> {
  late final _obscure = ValueNotifier(widget.concealed);

  @override
  void dispose() {
    _obscure.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
    valueListenable: _obscure,
    builder: (context, obscure, _) {
      final multiline =
          widget.multiline || (widget.preserveLineBreaks && !obscure);
      // Concealed single-line editing strips LF, so reveal before editing these values.
      return FTextField(
        label: Text(widget.label),
        description: widget.concealed && widget.preserveLineBreaks && obscure
            ? Text(
                Localizations.localeOf(context).languageCode == 'ru'
                    ? 'Покажите значение, чтобы изменить его.'
                    : 'Show the value to edit it.',
              )
            : null,
        readOnly: widget.concealed && widget.preserveLineBreaks && obscure,
        error: widget.invalid ? const SizedBox.shrink() : null,
        control: FTextFieldControl.managed(
          controller: widget.controller,
          onChange: (value) => widget.onChanged?.call(value.text),
        ),
        enabled: widget.enabled,
        autofocus: widget.autofocus,
        focusNode: widget.focusNode,
        obscureText: widget.concealed && !widget.multiline && obscure,
        maxLines: multiline ? 4 : 1,
        keyboardType: multiline
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
        textInputAction: multiline
            ? TextInputAction.newline
            : widget.last
            ? TextInputAction.done
            : TextInputAction.next,
        onSubmit: widget.last && !multiline
            ? (_) => widget.onSubmitted()
            : null,
        suffixBuilder: widget.multiline || !widget.concealed
            ? null
            : (context, _, variants) {
                final labels =
                    FLocalizations.of(context) ?? FDefaultLocalizations();
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ?widget.postfix,
                    VaultSecretAction(
                      label: obscure
                          ? labels
                                .passwordFieldUnobscureTextButtonSemanticsLabel
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
      );
    },
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
        VaultSecretAction(label: label, onPressed: toggle, child: child),
    contentBuilder: (context, close) => ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 280),
      child: Text(message),
    ),
  );
}

final class VaultSecretAction extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget child;
  const VaultSecretAction({
    super.key,
    required this.label,
    required this.onPressed,
    required this.child,
  });
  @override
  Widget build(BuildContext context) => SizedBox.square(
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
}
