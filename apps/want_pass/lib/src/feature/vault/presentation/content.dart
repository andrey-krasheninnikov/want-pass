import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:want_allure/want_allure.dart';
import 'package:want_pass/src/feature/vault/application/_barrel.dart';
import 'package:want_pass/src/feature/vault/presentation/_barrel.dart';
import 'package:want_pass_core/want_pass_core.dart';

String _text(BuildContext context, String en, String ru) =>
    Localizations.localeOf(context).languageCode == 'ru' ? ru : en;

final class VaultContentView extends StatefulWidget {
  final VaultController controller;
  const VaultContentView({super.key, required this.controller});
  @override
  State<VaultContentView> createState() => _VaultContentViewState();
}

final class _VaultContentViewState extends State<VaultContentView> {
  String _filter = 'all';
  DialogRoute<void>? _overlay;
  void _closeDialog() {
    final route = _overlay;
    _overlay = null;
    if (route?.isActive == true) route!.navigator?.removeRoute(route);
  }

  void _show(WidgetBuilder builder) {
    _closeDialog();
    widget.controller.dismissFailure();
    final route = DialogRoute<void>(
      context: context,
      barrierDismissible: false,
      builder: builder,
    );
    _overlay = route;
    unawaited(
      Navigator.of(context).push(route).whenComplete(() {
        if (identical(_overlay, route)) _overlay = null;
      }),
    );
  }

  void _group([GroupV1? group]) {
    final revision = widget.controller.state.content!.revision;
    _show(
      (context) => _GroupEditor(
        controller: widget.controller,
        group: group,
        revision: revision,
        onDone: _closeDialog,
        onDelete: group == null ? null : () => _deleteGroup(group),
      ),
    );
  }

  Future<void> _account([String? id]) async {
    final revision = widget.controller.state.content!.revision;
    final account = id == null ? null : await widget.controller.readAccount(id);
    if (!mounted ||
        widget.controller.state.phase != VaultPhase.unlocked ||
        (id != null && account == null)) {
      return;
    }
    _show(
      (context) => _AccountEditor(
        controller: widget.controller,
        account: account,
        initialGroupId:
            widget.controller.state.content!.groups.any((g) => g.id == _filter)
            ? _filter
            : null,
        revision: revision,
        onDone: _closeDialog,
        onDelete: account == null ? null : () => _deleteAccount(account),
      ),
    );
  }

  void _deleteGroup(GroupV1 group) {
    final revision = widget.controller.state.content!.revision;
    _show(
      (context) => _DeleteContentDialog(
        controller: widget.controller,
        group: true,
        onConfirm: () =>
            widget.controller.deleteGroup(group.id, revision: revision),
        onDone: _closeDialog,
      ),
    );
  }

  void _deleteAccount(AccountV1 account) {
    final revision = widget.controller.state.content!.revision;
    _show(
      (context) => _DeleteContentDialog(
        controller: widget.controller,
        group: false,
        onConfirm: () =>
            widget.controller.deleteAccount(account.id, revision: revision),
        onDone: _closeDialog,
      ),
    );
  }

  @override
  void dispose() {
    _closeDialog();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<VaultController, VaultState>(
    bloc: widget.controller,
    listenWhen: (a, b) => a.phase != b.phase,
    listener: (context, state) {
      if (state.phase != VaultPhase.unlocked) _closeDialog();
    },
    builder: (context, state) {
      if (state.phase != VaultPhase.unlocked) return const SizedBox.shrink();
      final snapshot = state.content;
      if (snapshot == null) {
        return Center(
          child: WantButton(
            onPressed: state.busy
                ? null
                : () => unawaited(widget.controller.loadContent()),
            child: Text(_text(context, 'Load vault', 'Загрузить сейф')),
          ),
        );
      }
      final filter =
          _filter == 'all' ||
              _filter == 'none' ||
              snapshot.groups.any((g) => g.id == _filter)
          ? _filter
          : 'all';
      final accounts = snapshot.accounts
          .where(
            (a) =>
                filter == 'all' ||
                (filter == 'none'
                    ? a.groupIds.isEmpty
                    : a.groupIds.contains(filter)),
          )
          .toList();
      Widget groupButton(String id, String label, {GroupV1? group}) => Row(
        children: [
          Expanded(
            child: WantButton(
              key: ValueKey('group-filter-$id'),
              variant: filter == id
                  ? WantButtonVariant.primary
                  : WantButtonVariant.ghost,
              onPressed: () => setState(() => _filter = id),
              child: Row(
                spacing: 8,
                children: [
                  if (group != null)
                    VaultGroupLogo(icon: group.icon, bytes: group.logo),
                  Expanded(child: Text(label, overflow: TextOverflow.ellipsis)),
                ],
              ),
            ),
          ),
          if (group != null)
            WantTooltip(
              message: _text(context, 'Edit group', 'Изменить группу'),
              child: IconButton(
                key: ValueKey('group-edit-$id'),
                tooltip: _text(context, 'Edit group', 'Изменить группу'),
                onPressed: state.busy ? null : () => _group(group),
                icon: const Icon(Icons.more_horiz),
              ),
            ),
        ],
      );
      final groups = ListView(
        children: [
          groupButton('all', _text(context, 'All', 'Все')),
          groupButton('none', _text(context, 'Without a group', 'Без группы')),
          for (final group in snapshot.groups)
            groupButton(group.id, group.name, group: group),
        ],
      );
      final cards = accounts.isEmpty
          ? Center(
              child: WantTypography(
                _text(
                  context,
                  'Create a card for this selection',
                  'Создайте карточку для этой подборки',
                ),
                colorRole: 'muted-foreground',
              ),
            )
          : ListView.separated(
              itemCount: accounts.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final account = accounts[index];
                return WantCard(
                  hoverEffect: false,
                  padding: const EdgeInsets.all(8),
                  child: WantButton(
                    key: ValueKey('account-${account.id}'),
                    variant: WantButtonVariant.ghost,
                    onPressed: state.busy
                        ? null
                        : () => unawaited(_account(account.id)),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        account.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                );
              },
            );
      return Column(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox.square(
                dimension: 84,
                child: FittedBox(
                  child: VaultSafeDial(
                    key: const ValueKey('vault-dial'),
                    opened: true,
                    remaining: () => widget.controller.idleRemaining,
                    label: _text(context, 'Lock vault', 'Заблокировать сейф'),
                    onPressed: () =>
                        unawaited(widget.controller.lock(notify: true)),
                  ),
                ),
              ),
              VaultIdleCountdown(
                remaining: () => widget.controller.idleRemaining,
              ),
            ],
          ),
          _Actions(
            children: [
              WantButton(
                key: const ValueKey('group-create'),
                variant: WantButtonVariant.secondary,
                onPressed: state.busy ? null : _group,
                child: Text(_text(context, 'New group', 'Новая группа')),
              ),
              WantButton(
                key: const ValueKey('account-create'),
                onPressed: state.busy ? null : () => unawaited(_account()),
                child: Text(_text(context, 'New card', 'Новая карточка')),
              ),
            ],
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => constraints.maxWidth >= 800
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 20,
                      children: [
                        SizedBox(width: 240, child: groups),
                        Expanded(child: cards),
                      ],
                    )
                  : Column(
                      spacing: 12,
                      children: [
                        WantSelect<String>(
                          value: filter,
                          label: Text(_text(context, 'Group', 'Группа')),
                          options: [
                            WantOption(
                              value: 'all',
                              label: _text(context, 'All', 'Все'),
                            ),
                            WantOption(
                              value: 'none',
                              label: _text(
                                context,
                                'Without a group',
                                'Без группы',
                              ),
                            ),
                            for (final group in snapshot.groups)
                              WantOption(value: group.id, label: group.name),
                          ],
                          onChanged: (value) {
                            if (value != null) setState(() => _filter = value);
                          },
                        ),
                        if (snapshot.groups.any((g) => g.id == filter))
                          WantButton(
                            variant: WantButtonVariant.ghost,
                            onPressed: state.busy
                                ? null
                                : () => _group(
                                    snapshot.groups.firstWhere(
                                      (g) => g.id == filter,
                                    ),
                                  ),
                            child: Text(
                              _text(context, 'Edit group', 'Изменить группу'),
                            ),
                          ),
                        Expanded(child: cards),
                      ],
                    ),
            ),
          ),
        ],
      );
    },
  );
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
                ? 'Check required fields and size limits. Logos must be PNG or JPEG up to 5 MiB and 4096 × 4096.'
                : 'The change could not be saved. Your saved data is preserved.',
            error is VaultRejectedErrorV1 &&
                    (error as VaultRejectedErrorV1).kind ==
                        VaultFailureKindV1.unsupported
                ? 'Проверьте обязательные поля и ограничения. Логотип: PNG или JPEG до 5 MiB и 4096 × 4096.'
                : 'Изменение не сохранено. Сохранённые данные не потеряны.',
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
  final VoidCallback? onDelete;
  const _GroupEditor({
    required this.controller,
    required this.group,
    required this.revision,
    required this.onDone,
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
  late List<int> _logo = widget.group?.logo ?? const [];
  @override
  void dispose() {
    _name.clear();
    _description.clear();
    _name.dispose();
    _description.dispose();
    _logo = const [];
    super.dispose();
  }

  Future<void> _save() async {
    final saved = await widget.controller.saveGroup(
      GroupDraftV1(
        id: widget.group?.id,
        name: _name.text,
        description: _description.text,
        icon: _icon,
        logo: List.unmodifiable(_logo),
      ),
      revision: widget.revision,
    );
    if (mounted && saved) widget.onDone();
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<VaultController, VaultState>(
    bloc: widget.controller,
    builder: (context, state) => WantDialog(
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
            onPressed: widget.onDone,
            child: Text(_text(context, 'Cancel', 'Отмена')),
          ),
          WantButton(
            key: const ValueKey('group-save'),
            onPressed: state.busy ? null : () => unawaited(_save()),
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
                  _text(context, 'Up to 512 UTF-8 bytes', 'До 512 байт UTF-8'),
                ),
                controller: _name,
                enabled: !state.busy,
                autofocus: true,
                onSubmitted: (_) => unawaited(_save()),
              ),
              WantTextarea(
                key: const ValueKey('group-description'),
                label: Text(_text(context, 'Description', 'Описание')),
                description: Text(_text(context, 'Up to 16 KiB', 'До 16 KiB')),
                controller: _description,
                enabled: !state.busy,
              ),
              Row(
                spacing: 12,
                children: [
                  VaultGroupLogo(icon: _icon, bytes: _logo),
                  Expanded(
                    child: WantSelect<String>(
                      value: _icon,
                      label: Text(_text(context, 'Icon', 'Иконка')),
                      options: [
                        for (final (value, en, ru) in [
                          ('folder', 'Folder', 'Папка'),
                          ('building', 'Company', 'Компания'),
                          ('briefcase', 'Work', 'Работа'),
                          ('code', 'Code', 'Код'),
                          ('home', 'Home', 'Дом'),
                          ('key', 'Key', 'Ключ'),
                        ])
                          WantOption(
                            value: value,
                            label: _text(context, en, ru),
                          ),
                      ],
                      enabled: !state.busy,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _icon = value;
                            _logo = const [];
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              _Actions(
                children: [
                  WantButton(
                    key: const ValueKey('group-logo-select'),
                    variant: WantButtonVariant.secondary,
                    onPressed: state.busy
                        ? null
                        : () async {
                            final bytes = await widget.controller
                                .selectGroupLogo();
                            if (mounted && bytes != null) {
                              setState(() => _logo = bytes);
                            }
                          },
                    child: Text(
                      _text(context, 'Choose image', 'Выбрать изображение'),
                    ),
                  ),
                  if (_logo.isNotEmpty)
                    WantButton(
                      variant: WantButtonVariant.ghost,
                      onPressed: state.busy
                          ? null
                          : () => setState(() => _logo = const []),
                      child: Text(
                        _text(context, 'Remove image', 'Убрать изображение'),
                      ),
                    ),
                ],
              ),
              if (widget.group != null)
                WantButton(
                  key: const ValueKey('group-delete'),
                  variant: WantButtonVariant.destructive,
                  onPressed: state.busy ? null : widget.onDelete,
                  child: Text(_text(context, 'Delete group', 'Удалить группу')),
                ),
              _ContentError(state.error),
            ],
          ),
        ),
      ),
    ),
  );
}

final class _AccountEditor extends StatefulWidget {
  final VaultController controller;
  final AccountV1? account;
  final String? initialGroupId;
  final BigInt revision;
  final VoidCallback onDone;
  final VoidCallback? onDelete;
  const _AccountEditor({
    required this.controller,
    required this.account,
    this.initialGroupId,
    required this.revision,
    required this.onDone,
    this.onDelete,
  });
  @override
  State<_AccountEditor> createState() => _AccountEditorState();
}

final class _AccountEditorState extends State<_AccountEditor> {
  late final _name = TextEditingController(text: widget.account?.name);
  late final _description = TextEditingController(
    text: widget.account?.description,
  );
  late final _login = TextEditingController(text: widget.account?.login);
  late final _password = TextEditingController(text: widget.account?.password);
  late final _groups = <String>{
    ...?widget.account?.groupIds,
    if (widget.account == null && widget.initialGroupId != null)
      widget.initialGroupId!,
  };
  @override
  void dispose() {
    for (final field in [_name, _description, _login, _password]) {
      field.clear();
      field.dispose();
    }
    _groups.clear();
    super.dispose();
  }

  Future<void> _save() async {
    final saved = await widget.controller.saveAccount(
      AccountDraftV1(
        id: widget.account?.id,
        name: _name.text,
        description: _description.text,
        login: _login.text,
        password: _password.text,
        groupIds: List.unmodifiable(_groups),
      ),
      revision: widget.revision,
    );
    if (mounted && saved) widget.onDone();
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<VaultController, VaultState>(
        bloc: widget.controller,
        builder: (context, state) => WantDialog(
          title: _text(
            context,
            widget.account == null ? 'New card' : 'Card',
            widget.account == null ? 'Новая карточка' : 'Карточка',
          ),
          actions: _Actions(
            children: [
              WantButton(
                key: const ValueKey('content-cancel'),
                variant: WantButtonVariant.secondary,
                onPressed: widget.onDone,
                child: Text(_text(context, 'Cancel', 'Отмена')),
              ),
              WantButton(
                key: const ValueKey('account-save'),
                onPressed: state.busy ? null : () => unawaited(_save()),
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
                    key: const ValueKey('account-name'),
                    label: Text(_text(context, 'Name *', 'Название *')),
                    description: Text(
                      _text(
                        context,
                        'Up to 512 UTF-8 bytes',
                        'До 512 байт UTF-8',
                      ),
                    ),
                    controller: _name,
                    enabled: !state.busy,
                    autofocus: true,
                  ),
                  WantTextarea(
                    key: const ValueKey('account-description'),
                    label: Text(_text(context, 'Description', 'Описание')),
                    controller: _description,
                    enabled: !state.busy,
                  ),
                  FTextField(
                    key: const ValueKey('account-login'),
                    label: Text(
                      _text(context, 'Login / email *', 'Логин / email *'),
                    ),
                    control: FTextFieldControl.managed(controller: _login),
                    enabled: !state.busy,
                    autocorrect: false,
                    enableSuggestions: false,
                    enableIMEPersonalizedLearning: false,
                    stylusHandwritingEnabled: false,
                    autofillHints: null,
                    smartDashesType: SmartDashesType.disabled,
                    smartQuotesType: SmartQuotesType.disabled,
                  ),
                  VaultSecretInput(
                    key: const ValueKey('account-password'),
                    label: _text(context, 'Password *', 'Пароль *'),
                    controller: _password,
                    enabled: !state.busy,
                    autofocus: false,
                    last: true,
                    onSubmitted: () => unawaited(_save()),
                  ),
                  WantTypography(
                    _text(context, 'Groups', 'Группы'),
                    variant: WantTypographyVariant.h4,
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final group in state.content?.groups ?? <GroupV1>[])
                        Semantics(
                          selected: _groups.contains(group.id),
                          child: WantButton(
                            key: ValueKey('account-group-${group.id}'),
                            variant: _groups.contains(group.id)
                                ? WantButtonVariant.primary
                                : WantButtonVariant.secondary,
                            onPressed: state.busy
                                ? null
                                : () => setState(() {
                                    if (!_groups.add(group.id)) {
                                      _groups.remove(group.id);
                                    }
                                  }),
                            child: Text(group.name),
                          ),
                        ),
                    ],
                  ),
                  if (widget.account != null)
                    WantButton(
                      key: const ValueKey('account-delete'),
                      variant: WantButtonVariant.destructive,
                      onPressed: state.busy ? null : widget.onDelete,
                      child: Text(
                        _text(context, 'Delete card', 'Удалить карточку'),
                      ),
                    ),
                  _ContentError(state.error),
                ],
              ),
            ),
          ),
        ),
      );
}

final class _DeleteContentDialog extends StatelessWidget {
  final VaultController controller;
  final bool group;
  final Future<bool> Function() onConfirm;
  final VoidCallback onDone;
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
      if (state.phase != VaultPhase.unlocked && context.mounted) onDone();
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
            onPressed: state.busy ? null : onDone,
            child: Text(_text(context, 'Cancel', 'Отмена')),
          ),
          WantButton(
            key: const ValueKey('delete-confirm'),
            variant: WantButtonVariant.destructive,
            onPressed: state.busy
                ? null
                : () async {
                    final saved = await onConfirm();
                    if (context.mounted && saved) onDone();
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
