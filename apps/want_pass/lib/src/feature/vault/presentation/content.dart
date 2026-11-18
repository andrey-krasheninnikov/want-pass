import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:bloc_effects/bloc_effects.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image/image.dart' as img;
import 'package:want_allure/want_allure.dart';
import 'package:want_pass/src/feature/appearance/application/_barrel.dart';
import 'package:want_pass/src/feature/appearance/presentation/_barrel.dart';
import 'package:want_pass/src/feature/vault/application/_barrel.dart';
import 'package:want_pass/src/feature/vault/presentation/_barrel.dart';
import 'package:want_pass_core/want_pass_core.dart';

part 'card_editor.dart';
part 'group_icon_picker.dart';
part 'sections.dart';
part 'workspace.dart';
part 'preview.dart';

String _text(BuildContext context, String en, String ru) =>
    Localizations.localeOf(context).languageCode == 'ru' ? ru : en;

final class VaultContentView extends StatefulWidget {
  final VaultController controller;
  final AppearanceController? appearance;
  const VaultContentView({
    super.key,
    required this.controller,
    this.appearance,
  });
  @override
  State<VaultContentView> createState() => _VaultContentViewState();
}

final class _Actions extends StatelessWidget {
  final List<Widget> children;
  const _Actions({required this.children});
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) =>
        constraints.maxWidth < 420 ||
            MediaQuery.textScalerOf(context).scale(16) > 22
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
}

final class _ContentError extends StatelessWidget {
  final VaultErrorV1? error;
  const _ContentError(this.error);
  @override
  Widget build(BuildContext context) => error == null
      ? const SizedBox.shrink()
      : WantTypography(
          _text(
            context,
            error is VaultRejectedErrorV1 &&
                    (error as VaultRejectedErrorV1).kind ==
                        VaultFailureKindV1.unsupported
                ? 'Check required fields, supported formats and size limits. Saved values are preserved.'
                : 'The action could not be completed. Your saved data is preserved.',
            error is VaultRejectedErrorV1 &&
                    (error as VaultRejectedErrorV1).kind ==
                        VaultFailureKindV1.unsupported
                ? 'Проверьте обязательные поля, поддерживаемые форматы и ограничения размера. Сохранённые значения не изменены.'
                : 'Действие не выполнено. Сохранённые данные не потеряны.',
          ),
          colorRole: 'destructive',
          liveRegion: true,
        );
}

final class _GroupEditor extends StatefulWidget {
  final VaultController controller;
  final GroupV1? group;
  final BigInt revision;
  final VoidCallback onDone;
  final VoidCallback? onCancel;
  final bool embedded;
  final VoidCallback? onDelete;
  const _GroupEditor({
    super.key,
    required this.controller,
    required this.group,
    required this.revision,
    required this.onDone,
    this.onCancel,
    this.embedded = false,
    this.onDelete,
  });
  @override
  State<_GroupEditor> createState() => _GroupEditorState();
}

final class _GroupEditorState extends State<_GroupEditor> {
  late final _name = TextEditingController(text: widget.group?.name);
  late final _description = TextEditingController(
    text: widget.group?.description,
  );
  late String _icon = widget.group?.icon ?? 'folder';
  late final _originalTone = _GroupTone.fromLogo(
    widget.group?.logo ?? const [],
    _icon,
  );
  late _GroupTone _tone = _originalTone ?? _GroupTone.brand;
  late List<int> _logo = _originalTone == null
      ? widget.group?.logo ?? const []
      : const [];
  bool _saving = false;
  bool _iconError = false;
  @override
  void dispose() {
    _name.clear();
    _description.clear();
    _name.dispose();
    _description.dispose();
    _logo = const [];
    super.dispose();
  }

  bool get dirty =>
      _name.text != (widget.group?.name ?? '') ||
      _description.text != (widget.group?.description ?? '') ||
      _icon != (widget.group?.icon ?? 'folder') ||
      _tone != (_originalTone ?? _GroupTone.brand) ||
      !listEquals(
        _logo,
        _originalTone == null
            ? widget.group?.logo ?? const <int>[]
            : const <int>[],
      );

  Future<bool> _save() async {
    final controller = widget.controller;
    if (_saving || controller.state.busy) return false;
    setState(() {
      _saving = true;
      _iconError = false;
    });
    try {
      List<int> logo = _logo;
      if (logo.isEmpty && _tone != _GroupTone.brand) {
        try {
          logo = await _tone.render(_icon);
        } on Object {
          if (mounted) setState(() => _iconError = true);
          return false;
        }
      }
      if (!mounted || controller.state.phase != VaultPhase.unlocked) {
        return false;
      }
      final saved = await controller.saveGroup(
        GroupDraftV1(
          id: widget.group?.id,
          name: _name.text,
          description: _description.text,
          icon: _icon,
          logo: List.unmodifiable(logo),
        ),
        revision: widget.revision,
      );
      if (mounted && saved) widget.onDone();
      return saved;
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<VaultController, VaultState>(
        bloc: widget.controller,
        builder: (context, state) {
          if (state.phase != VaultPhase.unlocked) {
            return const SizedBox.shrink();
          }
          final busy = _saving || state.busy;
          return _EditorFrame(
            embedded: widget.embedded,
            title: _text(
              context,
              widget.group == null ? 'New group' : 'Group',
              widget.group == null ? 'Новая группа' : 'Группа',
            ),
            actions: _Actions(
              children: [
                WantButton(
                  key: const ValueKey('content-cancel'),
                  variant: WantButtonVariant.secondary,
                  onPressed: busy ? null : widget.onCancel ?? widget.onDone,
                  child: Text(_text(context, 'Cancel', 'Отмена')),
                ),
                WantButton(
                  key: const ValueKey('group-save'),
                  onPressed: busy ? null : () => unawaited(_save()),
                  child: Text(_text(context, 'Save', 'Сохранить')),
                ),
              ],
            ),
            child: Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 16,
                  children: [
                    WantInput(
                      key: const ValueKey('group-name'),
                      label: Text(_text(context, 'Name *', 'Название *')),
                      description: Text(
                        _text(
                          context,
                          'Up to 512 UTF-8 bytes',
                          'До 512 байт UTF-8',
                        ),
                      ),
                      controller: _name,
                      enabled: !busy,
                      autofocus: true,
                      onSubmitted: (_) => unawaited(_save()),
                    ),
                    WantTextarea(
                      key: const ValueKey('group-description'),
                      label: Text(_text(context, 'Description', 'Описание')),
                      description: Text(
                        _text(context, 'Up to 16 KiB', 'До 16 KiB'),
                      ),
                      controller: _description,
                      enabled: !busy,
                    ),
                    _GroupIconPicker(
                      icon: _icon,
                      image: _logo,
                      tone: _tone,
                      enabled: !busy,
                      selectImage: widget.controller.selectGroupLogo,
                      onChanged: (icon, image, tone) => setState(() {
                        _icon = icon;
                        _logo = image;
                        _tone = tone;
                      }),
                    ),
                    if (_iconError)
                      WantTypography(
                        _text(
                          context,
                          'Could not prepare the group icon.',
                          'Не удалось подготовить иконку группы.',
                        ),
                        colorRole: 'destructive',
                        liveRegion: true,
                      ),
                    if (widget.group != null)
                      WantButton(
                        key: const ValueKey('group-delete'),
                        variant: WantButtonVariant.destructive,
                        onPressed: busy ? null : widget.onDelete,
                        child: Text(
                          _text(context, 'Delete group', 'Удалить группу'),
                        ),
                      ),
                    _ContentError(state.error),
                  ],
                ),
              ),
            ),
          );
        },
      );
}

final class _DeleteContentDialog extends StatelessWidget {
  final VaultController controller;
  final bool group;
  final Future<bool> Function() onConfirm;
  final ValueChanged<bool> onDone;
  const _DeleteContentDialog({
    required this.controller,
    required this.group,
    required this.onConfirm,
    required this.onDone,
  });
  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<VaultController, VaultState>(
    bloc: controller,
    listenWhen: (a, b) => a.phase != b.phase,
    listener: (context, state) {
      if (state.phase != VaultPhase.unlocked && context.mounted) onDone(false);
    },
    builder: (context, state) => WantDialog(
      title: _text(
        context,
        group ? 'Delete group?' : 'Delete card?',
        group ? 'Удалить группу?' : 'Удалить карточку?',
      ),
      actions: _Actions(
        children: [
          WantButton(
            key: const ValueKey('delete-cancel'),
            variant: WantButtonVariant.secondary,
            onPressed: state.busy ? null : () => onDone(false),
            child: Text(_text(context, 'Cancel', 'Отмена')),
          ),
          WantButton(
            key: const ValueKey('delete-confirm'),
            variant: WantButtonVariant.destructive,
            onPressed: state.busy
                ? null
                : () async {
                    final saved = await onConfirm();
                    if (context.mounted && saved) onDone(true);
                  },
            child: Text(_text(context, 'Delete', 'Удалить')),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [
          Text(
            _text(
              context,
              group
                  ? 'Only the group and its memberships are removed. Every card is preserved.'
                  : 'The card and its values will be removed from this vault.',
              group
                  ? 'Удалится только группа и её связи. Все карточки сохранятся.'
                  : 'Карточка и её значения будут удалены из сейфа.',
            ),
          ),
          _ContentError(state.error),
        ],
      ),
    ),
  );
}

final class _EditorFrame extends StatelessWidget {
  final bool embedded;
  final String title;
  final Widget child, actions;
  const _EditorFrame({
    required this.embedded,
    required this.title,
    required this.child,
    required this.actions,
  });
  @override
  Widget build(BuildContext context) => embedded
      ? Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            WantTypography(title, variant: WantTypographyVariant.h3),
            child,
            actions,
          ],
        )
      : WantDialog(title: title, actions: actions, child: child);
}
