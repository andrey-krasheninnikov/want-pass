import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';

final class VaultSecretInput extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool enabled;
  final bool autofocus;
  final bool last;
  final bool multiline;
  final Widget? postfix;
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
          : (context, style, variants) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ?widget.postfix,
                FTextField.defaultObscureIconBuilder(
                  context,
                  style,
                  _obscure,
                  variants,
                ),
              ],
            ),
    ),
  );
}
