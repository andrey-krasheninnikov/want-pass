import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';

final class VaultSecretInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool enabled;
  final bool autofocus;
  final bool last;
  final VoidCallback onSubmitted;
  const VaultSecretInput({
    super.key,
    required this.label,
    required this.controller,
    required this.enabled,
    required this.autofocus,
    required this.last,
    required this.onSubmitted,
  });
  @override
  Widget build(BuildContext context) => FTextField.password(
    label: Text(label),
    control: FTextFieldControl.managed(controller: controller),
    enabled: enabled,
    autofocus: autofocus,
    autocorrect: false,
    enableSuggestions: false,
    enableIMEPersonalizedLearning: false,
    stylusHandwritingEnabled: false,
    autofillHints: const [],
    smartDashesType: SmartDashesType.disabled,
    smartQuotesType: SmartQuotesType.disabled,
    textInputAction: last ? TextInputAction.done : TextInputAction.next,
    onSubmit: last ? (_) => onSubmitted() : null,
  );
}
