import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';

final class VaultSecretInput extends StatefulWidget {
  final String label;
  final FocusNode? focusNode;
  final TextEditingController controller;
  final bool enabled;
  final bool autofocus;
  final bool last;
  final bool multiline;
  final bool preserveLineBreaks;
  final bool protectClipboard;
  final bool concealed;
  final ValueNotifier<bool>? sharedObscure;
  final bool showVisibilityToggle;
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
    this.protectClipboard = false,
    this.concealed = true,
    this.sharedObscure,
    this.showVisibilityToggle = true,
    this.postfix,
    this.invalid = false,
    required this.onSubmitted,
    this.onChanged,
  });
  @override
  State<VaultSecretInput> createState() => _VaultSecretInputState();
}

final class _VaultSecretInputState extends State<VaultSecretInput> {
  late final _localObscure = ValueNotifier(widget.concealed);
  ValueNotifier<bool> get _obscure => widget.sharedObscure ?? _localObscure;

  @override
  void dispose() {
    _localObscure.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
    valueListenable: _obscure,
    builder: (context, obscure, _) {
      final multiline =
          widget.multiline || (widget.preserveLineBreaks && !obscure);
      // Concealed single-line editing strips LF, so reveal before editing these values.
      final input = FTextField(
        enableInteractiveSelection: !widget.protectClipboard,
        label: Text(widget.label),
        description: widget.concealed && widget.preserveLineBreaks && obscure
            ? Text(
                Localizations.localeOf(context).languageCode == 'ru'
                    ? 'Покажите значение, чтобы изменить его.'
                    : 'Show the value to edit it.',
              )
            : null,
        readOnly: widget.concealed && widget.preserveLineBreaks && obscure,
        style: const FTextFieldStyleDelta.delta(
          errorPadding: EdgeInsetsGeometryDelta.value(EdgeInsets.zero),
        ),
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
                    if (widget.showVisibilityToggle)
                      VaultSecretAction(
                        label: obscure
                            ? labels
                                  .passwordFieldUnobscureTextButtonSemanticsLabel
                            : labels
                                  .passwordFieldObscureTextButtonSemanticsLabel,
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
      if (!widget.protectClipboard) return input;
      final editable =
          widget.enabled &&
          !(widget.preserveLineBreaks && obscure && widget.concealed);
      void paste() {
        if (editable) _pasteSavedValue(multiline);
      }

      void selectAll() {
        if (editable) {
          widget.controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset: widget.controller.text.length,
          );
        }
      }

      return CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.keyV, meta: true): paste,
          const SingleActivator(LogicalKeyboardKey.keyV, control: true): paste,
          const SingleActivator(LogicalKeyboardKey.keyA, meta: true): selectAll,
          const SingleActivator(LogicalKeyboardKey.keyA, control: true):
              selectAll,
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: input),
            VaultSecretAction(
              label: Localizations.localeOf(context).languageCode == 'ru'
                  ? 'Вставить'
                  : 'Paste',
              onPressed: editable ? paste : null,
              child: const Icon(Icons.content_paste_outlined, size: 18),
            ),
          ],
        ),
      );
    },
  );

  Future<void> _pasteSavedValue(bool multiline) async {
    final controller = widget.controller;
    final previous = controller.value;
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted ||
        !widget.enabled ||
        !identical(controller, widget.controller) ||
        previous != controller.value ||
        data?.text == null) {
      return;
    }
    final text = multiline
        ? data!.text!
        : data!.text!.replaceAll(RegExp(r'[\r\n]'), '');
    final selection = previous.selection.isValid
        ? previous.selection
        : TextSelection.collapsed(offset: previous.text.length);
    controller.value = previous.replaced(selection, text);
    widget.onChanged?.call(controller.text);
  }
}

final class VaultSecretAction extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget child;
  final double size;
  final bool flush;
  const VaultSecretAction({
    super.key,
    required this.label,
    required this.onPressed,
    required this.child,
    this.size = 44,
    this.flush = false,
  });
  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: FButton.icon(
      variant: FButtonVariant.ghost,
      style: FButtonStyleDelta.delta(
        decoration: FVariants.from(const BoxDecoration(), variants: {}),
        iconContentStyle: flush
            ? const FButtonIconContentStyleDelta.delta(
                padding: EdgeInsetsGeometryDelta.value(EdgeInsets.zero),
              )
            : null,
      ),
      semanticsLabel: label,
      onPress: onPressed,
      child: child,
    ),
  );
}
