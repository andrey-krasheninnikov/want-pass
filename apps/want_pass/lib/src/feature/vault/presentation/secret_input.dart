import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:want_allure/want_allure.dart';

final class VaultSecretInput extends StatefulWidget {
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
  State<VaultSecretInput> createState() => _VaultSecretInputState();
}

final class _VaultSecretInputState extends State<VaultSecretInput>
    implements TextSelectionGestureDetectorBuilderDelegate {
  final _focus = FocusNode();
  @override
  final editableTextKey = GlobalKey<EditableTextState>();
  late final _gestures = TextSelectionGestureDetectorBuilder(delegate: this);
  @override
  bool get forcePressEnabled => false;
  @override
  bool get selectionEnabled => widget.enabled;

  @override
  void initState() {
    super.initState();
    _focus.canRequestFocus = widget.enabled;
  }

  @override
  void didUpdateWidget(VaultSecretInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    _focus.canRequestFocus = widget.enabled;
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = WantTheme.of(context);
    return Semantics(
      enabled: widget.enabled,
      onTap: widget.enabled ? _focus.requestFocus : null,
      onFocus: widget.enabled ? _focus.requestFocus : null,
      child: _gestures.buildGestureDetector(
        behavior: HitTestBehavior.translucent,
        child: ListenableBuilder(
          listenable: Listenable.merge([_focus, widget.controller]),
          builder: (context, child) => InputDecorator(
            isFocused: _focus.hasFocus,
            isEmpty: widget.controller.text.isEmpty,
            decoration: InputDecoration(
              labelText: widget.label,
              enabled: widget.enabled,
              labelStyle: TextStyle(color: theme.color('muted-foreground')),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: theme.color('border')),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: theme.color('primary')),
              ),
            ),
            child: _ExactEditableText(
              key: editableTextKey,
              controller: widget.controller,
              focusNode: _focus,
              style: DefaultTextStyle.of(context).style
                  .copyWith(color: theme.color('foreground')),
              cursorColor: theme.color('primary'),
              backgroundCursorColor: theme.color('muted-foreground'),
              readOnly: !widget.enabled,
              autofocus: widget.autofocus,
              textInputAction: widget.last
                  ? TextInputAction.done
                  : TextInputAction.next,
              onSubmitted: widget.last ? (_) => widget.onSubmitted() : null,
            ),
          ),
        ),
      ),
    );
  }
}

final class _ExactEditableText extends EditableText {
  _ExactEditableText({
    super.key,
    required super.controller,
    required super.focusNode,
    required super.style,
    required super.cursorColor,
    required super.backgroundCursorColor,
    required super.readOnly,
    required super.autofocus,
    required super.textInputAction,
    required super.onSubmitted,
  }) : super(
         obscureText: true,
         autocorrect: false,
         enableSuggestions: false,
         enableIMEPersonalizedLearning: false,
         stylusHandwritingEnabled: false,
         autofillHints: const [],
         smartDashesType: SmartDashesType.disabled,
         smartQuotesType: SmartQuotesType.disabled,
         keyboardType: TextInputType.visiblePassword,
         selectionControls: desktopTextSelectionHandleControls,
         contextMenuBuilder: (context, state) =>
             AdaptiveTextSelectionToolbar.editableText(
               editableTextState: state,
             ),
       );

  // The SDK adds an LF filter to single-line editors; passwords must stay exact.
  @override
  List<TextInputFormatter>? get inputFormatters => null;
}
