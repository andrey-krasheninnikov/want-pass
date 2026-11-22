part of 'content.dart';

final class _VaultContentViewState extends State<VaultContentView>
    with WidgetsBindingObserver {
  final _search = TextEditingController();
  _LocalToolsHost? _localTools;
  final _searchFocus = FocusNode();
  final _listFocus = FocusNode();
  final _detailsFocus = FocusNode();
  final _listScroll = ScrollController();
  var _cardEditor = GlobalKey<_CardEditorState>();
  var _groupEditor = GlobalKey<_GroupEditorState>();
  final _logins = <String, String?>{};
  final _visible = <String>{}, _wanted = <String>{};
  Timer? _debounce, _rowTimer;
  CardMatchesV1? _matches;
  String _group = 'all', _type = 'all', _service = 'all', _environment = 'all';
  String? _selected;
  CardV1? _card;
  GroupV1? _editGroup;
  bool _editing = false, _editingGroup = false, _compactDetail = false;
  bool _finding = false,
      _pendingFind = false,
      _searching = false,
      _reading = false;
  bool _active = true, _ticker = true, _disposing = false, _guarding = false;
  int _epoch = 0;
  BigInt? _revision, _editorRevision;
  Route<dynamic>? _overlay, _guardOverlay;
  Completer<void>? _availability;
  int _navigation = 0;
  _VaultSection _section = _VaultSection.secrets;
  bool _menuExpanded = false, _dockMenu = false;
  bool _restoreScheduled = false;
  int _lastShortcut = -1;
  late WorkspaceLayoutV1 _paneWidths =
      widget.appearance?.state.settings.layout ?? const WorkspaceLayoutV1();
  bool get _browsing => _available && _section == _VaultSection.secrets;
  bool get _available =>
      mounted &&
      !_disposing &&
      _active &&
      _ticker &&
      widget.controller.state.phase == VaultPhase.unlocked;
  bool get _dirty =>
      _cardEditor.currentState?.dirty == true ||
      _groupEditor.currentState?.dirty == true;

  @override
  void initState() {
    super.initState();
    _revision = widget.controller.state.content?.revision;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.macOS) {
      _localTools = _LocalToolsHost(widget.controller, () => context)..start();
    }
    _active =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    WidgetsBinding.instance.addObserver(this);
    _search.addListener(_changed);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _refresh();
        _searchFocus.requestFocus();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ticker = TickerMode.valuesOf(context).enabled;
    if (_ticker != ticker) {
      _ticker = ticker;
      _suspend();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _active = state == AppLifecycleState.resumed;
    _suspend();
  }

  void _suspend() {
    _epoch++;
    _debounce?.cancel();
    _rowTimer?.cancel();
    if (mounted) setState(_logins.clear);
    if (_available) {
      _wanted.addAll(_visible);
      _refresh();
      _scheduleRows();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_available) _releaseAvailability();
      });
    }
  }

  void _releaseAvailability() {
    final waiting = _availability;
    _availability = null;
    if (waiting != null && !waiting.isCompleted) waiting.complete();
  }

  Future<bool> _waitAvailable() async {
    if (_available) return true;
    if (!mounted ||
        _disposing ||
        widget.controller.state.phase != VaultPhase.unlocked) {
      return false;
    }
    final waiting = _availability ??= Completer<void>();
    await waiting.future;
    return _available;
  }

  void _closeOverlay() {
    final guard = _guardOverlay;
    _guardOverlay = null;
    if (guard?.isActive == true) guard!.navigator?.removeRoute(guard);
    final route = _overlay;
    _overlay = null;
    if (route?.isActive == true) route!.navigator?.removeRoute(route);
  }

  @override
  void dispose() {
    _disposing = true;
    _localTools?.dispose();
    _navigation++;
    _releaseAvailability();
    _epoch++;
    _debounce?.cancel();
    _rowTimer?.cancel();
    _closeOverlay();
    WidgetsBinding.instance.removeObserver(this);
    _search.removeListener(_changed);
    _search.clear();
    _search.dispose();
    _searchFocus.dispose();
    _listFocus.dispose();
    _detailsFocus.dispose();
    _listScroll.dispose();
    _logins.clear();
    _wanted.clear();
    _visible.clear();
    _card = null;
    _matches = null;
    super.dispose();
  }

  void _changed() {
    if (!_browsing) return;
    widget.controller.activity();
    _epoch++;
    _debounce?.cancel();
    setState(() => _searching = true);
    _debounce = Timer(const Duration(milliseconds: 150), _refresh);
  }

  void _refresh() {
    if (_browsing) unawaited(_find());
  }

  Future<void> _find() async {
    _pendingFind = true;
    if (_finding ||
        !_browsing ||
        widget.controller.state.busy ||
        widget.controller.state.content == null) {
      return;
    }
    _finding = true;
    try {
      while (_pendingFind && _browsing && !widget.controller.state.busy) {
        _pendingFind = false;
        final epoch = _epoch;
        setState(() => _searching = true);
        final matches = await widget.controller.searchCards(
          CardSearchV1(
            text: _search.text,
            cardType: _type == 'all' ? null : CardTypeV1.values.byName(_type),
            service: _service == 'all' ? null : _service,
            environment: _environment == 'all' || _environment == 'none'
                ? null
                : EnvironmentV1.values.byName(_environment),
            withoutEnvironment: _environment == 'none',
          ),
        );
        if (!_browsing) return;
        if (epoch != _epoch) {
          _pendingFind = true;
          continue;
        }
        setState(() {
          _matches = matches;
          _searching = false;
        });
        _scheduleRows();
      }
    } finally {
      _finding = false;
    }
  }

  List<CardSummaryV1> get _cards {
    final snapshot = widget.controller.state.content;
    if (snapshot == null || _matches?.revision != snapshot.revision) {
      return const [];
    }
    final byId = {for (final c in snapshot.cards) c.id: c};
    return [
      for (final id in _matches!.cardIds)
        if (byId[id] case final c?)
          if (_search.text.isNotEmpty ||
              _group == 'all' ||
              (_group == 'none'
                  ? c.groupIds.isEmpty
                  : c.groupIds.contains(_group)))
            c,
    ];
  }

  void _visibility(String id, bool visible) {
    if (_disposing) return;
    if (visible) {
      _visible.add(id);
      if (!_logins.containsKey(id)) _wanted.add(id);
    } else {
      _visible.remove(id);
      _wanted.remove(id);
      _logins.remove(id);
    }
    _scheduleRows();
  }

  void _scheduleRows() {
    if (!_browsing || _reading || _wanted.isEmpty) return;
    _rowTimer?.cancel();
    _rowTimer = Timer(
      const Duration(milliseconds: 16),
      () => unawaited(_readRows()),
    );
  }

  Future<void> _readRows() async {
    if (!_browsing || _reading || widget.controller.state.busy) return;
    _reading = true;
    final epoch = _epoch;
    final ids = _wanted.take(50).toList();
    _wanted.removeAll(ids);
    try {
      final rows = await widget.controller.readCardListRows(ids);
      if (!_browsing) return;
      if (epoch != _epoch) {
        _wanted.addAll(ids.where(_visible.contains));
        return;
      }
      if (rows == null) return;
      setState(() {
        for (final r in rows) {
          if (_visible.contains(r.id)) _logins[r.id] = r.login;
        }
      });
    } finally {
      _reading = false;
      if (_browsing) _scheduleRows();
    }
  }

  Future<bool> _leaveEditor() async {
    if (_guarding || widget.controller.state.busy) return false;
    if (!_dirty) return true;
    _guarding = true;
    try {
      final route = DialogRoute<String>(
        context: context,
        barrierDismissible: false,
        builder: (context) => WantDialog(
          title: _text(context, 'Unsaved changes', 'Несохранённые изменения'),
          showTitle: false,
          child: Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 20,
                children: [
                  WantTypography(
                    _text(
                      context,
                      'Unsaved changes',
                      'Несохранённые изменения',
                    ),
                    variant: WantTypographyVariant.h3,
                  ),
                  Text(
                    _text(
                      context,
                      'Save these changes before continuing?',
                      'Сохранить изменения перед переходом?',
                    ),
                  ),
                  _Actions(
                    children: [
                      WantButton(
                        variant: WantButtonVariant.secondary,
                        onPressed: () => Navigator.pop(context, 'stay'),
                        child: Text(_text(context, 'Stay', 'Остаться')),
                      ),
                      WantButton(
                        key: const ValueKey('discard-changes'),
                        variant: WantButtonVariant.secondary,
                        onPressed: () => Navigator.pop(context, 'discard'),
                        child: Text(_text(context, 'Discard', 'Не сохранять')),
                      ),
                      WantButton(
                        onPressed: () => Navigator.pop(context, 'save'),
                        child: Text(_text(context, 'Save', 'Сохранить')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      _guardOverlay = route;
      final choice = await Navigator.of(context).push(route);
      if (identical(_guardOverlay, route)) _guardOverlay = null;
      if (!await _waitAvailable()) return false;
      if (choice == 'discard') return true;
      if (choice == 'save') {
        if (_groupEditor.currentState case final editor?) {
          return await editor._save();
        }
        if (_cardEditor.currentState case final editor?) {
          return await editor._save();
        }
        return false;
      }
      return false;
    } finally {
      _guarding = false;
    }
  }

  Future<void> _navigate(VoidCallback action) async {
    final navigation = ++_navigation;
    if (!await _waitAvailable() || navigation != _navigation) return;
    if (await _leaveEditor() &&
        await _waitAvailable() &&
        navigation == _navigation) {
      widget.controller.dismissFailure();
      setState(action);
    }
  }

  void _stopEditing() {
    _cardEditor = GlobalKey<_CardEditorState>();
    _groupEditor = GlobalKey<_GroupEditorState>();
    _editing = _editingGroup = false;
    _card = null;
    _editGroup = null;
    _editorRevision = null;
  }

  void _chooseGroup(String id) => unawaited(
    _navigate(() {
      _stopEditing();
      _group = id;
      _search.clear();
      _selected = null;
      _compactDetail = false;
    }),
  );
  void _chooseCard(String id) => unawaited(
    _navigate(() {
      _stopEditing();
      _selected = id;
      _compactDetail = true;
      _listFocus.requestFocus();
    }),
  );
  void _newCard() => unawaited(
    _navigate(() {
      _stopEditing();
      _editing = true;
      _editorRevision = widget.controller.state.content!.revision;
      _compactDetail = true;
    }),
  );
  void _groupForm([GroupV1? group]) => unawaited(
    _navigate(() {
      _stopEditing();
      if (group == null) {
        unawaited(_newGroupDialog());
        return;
      }
      _editing = _editingGroup = true;
      _editGroup = group;
      _editorRevision = widget.controller.state.content!.revision;
      _compactDetail = true;
    }),
  );

  Future<void> _showBackup(bool create) async {
    if (_overlay != null || !_available || widget.controller.state.busy) return;
    final route = DialogRoute<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _withActivity(
        _BackupDialog(controller: widget.controller, create: create),
      ),
    );
    _overlay = route;
    await Navigator.of(context).push(route);
    await route.completed;
    if (identical(_overlay, route)) _overlay = null;
  }

  Future<void> _showReset() async {
    final appearance = widget.appearance;
    if (appearance == null ||
        _overlay != null ||
        !_available ||
        widget.controller.state.busy) {
      return;
    }
    final route = DialogRoute<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _withActivity(
        _ResetVaultDialog(
          controller: widget.controller,
          onReset: (phrase) => appearance.resetWith(
            (restoreDefaults) => widget.controller.resetApplication(
              phrase,
              onReset: restoreDefaults,
            ),
          ),
        ),
      ),
    );
    _overlay = route;
    await Navigator.of(context).push(route);
    await route.completed;
    if (identical(_overlay, route)) _overlay = null;
  }

  Future<void> _newGroupDialog() async {
    if (_overlay != null || !_browsing) return;
    final snapshot = widget.controller.state.content!;
    final ids = snapshot.groups.map((group) => group.id).toSet();
    late final DialogRoute<bool> route;
    void close(bool saved) {
      if (route.isCurrent) route.navigator?.pop(saved);
    }

    Future<void> cancel() async {
      if (await _leaveEditor() && await _waitAvailable()) close(false);
    }

    route = DialogRoute<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _withActivity(
        PopScope<bool>(
          canPop: false,
          onPopInvokedWithResult: (popped, _) {
            if (!popped) unawaited(cancel());
          },
          child: _GroupEditor(
            key: _groupEditor,
            controller: widget.controller,
            group: null,
            revision: snapshot.revision,
            onDone: () => close(true),
            onCancel: () => unawaited(cancel()),
          ),
        ),
      ),
    );
    _overlay = route;
    final saved = await Navigator.of(context).push(route);
    await route.completed;
    if (identical(_overlay, route)) _overlay = null;
    if (saved != true || !await _waitAvailable() || !_browsing) return;
    final groups = widget.controller.state.content?.groups ?? const [];
    final created = groups
        .where((group) => !ids.contains(group.id))
        .firstOrNull;
    if (created == null) return;
    setState(() {
      _group = created.id;
      _search.clear();
      _selected = null;
      _compactDetail = false;
    });
  }

  void _selectSection(_VaultSection section) {
    if (_overlay != null) return;
    if (section == _section) {
      if (_menuExpanded && !_dockMenu) {
        setState(() => _menuExpanded = false);
      }
      return;
    }
    unawaited(
      _navigate(() {
        _stopEditing();
        _section = section;
        if (!_dockMenu) _menuExpanded = false;
        _epoch++;
        _debounce?.cancel();
        _rowTimer?.cancel();
        _logins.clear();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_available || section != _section) return;
          _refresh();
        });
      }),
    );
  }

  Widget _menu(VaultState state, double width) {
    final catalog = state.catalog!;
    final toggleLabel = _menuExpanded
        ? _text(context, 'Collapse menu', 'Свернуть меню')
        : _text(context, 'Expand menu', 'Развернуть меню');

    int? count(_VaultSection section) => switch (section) {
      _VaultSection.secrets => state.content!.cards.length,
      _VaultSection.services =>
        catalog.services.where((service) => service != 'other').length +
            state.content!.services.where((s) => !s.archived).length,
      _VaultSection.types =>
        catalog.presets.length + 1 + state.content!.templates.length,
      _VaultSection.environments => EnvironmentV1.values.length,
      _VaultSection.integrations => 0,
      _VaultSection.resources || _VaultSection.history => null,
      _VaultSection.ai || _VaultSection.general => null,
    };

    return SizedBox(
      width: width,
      child: ColoredBox(
        color: WantTheme.of(context).color('background'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Tooltip(
                  message: toggleLabel,
                  excludeFromSemantics: true,
                  child: WantButton(
                    key: const ValueKey('vault-menu-toggle'),
                    pill: false,
                    size: WantButtonSize.icon,
                    variant: WantButtonVariant.ghost,
                    semanticsLabel: toggleLabel,
                    onPressed: () =>
                        setState(() => _menuExpanded = !_menuExpanded),
                    child: Icon(_menuExpanded ? Icons.menu_open : Icons.menu),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    for (final section in _VaultSection.values)
                      _menuItem(section, count(section)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuItem(_VaultSection section, int? count) {
    final label = section.label(context);
    final icon = Icon(section.icon, size: 20);
    final selected = section == _section;
    return Tooltip(
      message: label,
      excludeFromSemantics: true,
      child: Semantics(
        selected: selected,
        child: WantButton(
          key: ValueKey('vault-tab-${section.name}'),
          pill: false,
          size: _menuExpanded ? WantButtonSize.medium : WantButtonSize.icon,
          variant: selected
              ? WantButtonVariant.secondary
              : WantButtonVariant.ghost,
          semanticsLabel: !_menuExpanded ? label : null,
          onPressed: () => _selectSection(section),
          child: _menuExpanded
              ? Row(
                  spacing: 8,
                  children: [
                    icon,
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (count != null)
                      Text(
                        '$count',
                        style: TextStyle(
                          color: WantTheme.of(context)
                              .color('muted-foreground'),
                        ),
                      ),
                  ],
                )
              : icon,
        ),
      ),
    );
  }

  Widget _withMenu(VaultState state, Widget child) => LayoutBuilder(
    builder: (context, box) {
      const collapsedWidth = 56.0;
      _dockMenu =
          box.maxWidth >= 1000 &&
          MediaQuery.textScalerOf(context).scale(16) <= 24;
      final menuWidth = _menuExpanded
          ? (box.maxWidth - 44).clamp(collapsedWidth, 244.0).toDouble()
          : collapsedWidth;
      final overlay = _menuExpanded && !_dockMenu;
      final leftInset = (_dockMenu ? menuWidth : collapsedWidth) + 8;
      return Stack(
        fit: StackFit.expand,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.only(start: leftInset),
            child: ExcludeFocus(
              excluding: overlay,
              child: ExcludeSemantics(excluding: overlay, child: child),
            ),
          ),
          if (overlay)
            ModalBarrier(
              color: WantTheme.of(context)
                  .color('foreground')
                  .withValues(alpha: .14),
              dismissible: true,
              semanticsLabel: _text(context, 'Collapse menu', 'Свернуть меню'),
              onDismiss: () => setState(() => _menuExpanded = false),
            ),
          PositionedDirectional(
            start: 0,
            top: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: BorderDirectional(
                  end: BorderSide(color: WantTheme.of(context).color('border')),
                ),
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.only(end: 1),
                child: _menu(state, menuWidth - 1),
              ),
            ),
          ),
        ],
      );
    },
  );

  Future<void> _editCard() async {
    final id = _selected;
    if (id == null || !await _leaveEditor() || !_available) return;
    final revision = widget.controller.state.content!.revision, epoch = _epoch;
    final card = await widget.controller.readCard(id);
    if (!_available ||
        card == null ||
        epoch != _epoch ||
        _selected != id ||
        widget.controller.state.content?.revision != revision) {
      return;
    }
    setState(() {
      _stopEditing();
      _editing = true;
      _card = card;
      _editorRevision = revision;
      _compactDetail = true;
    });
  }

  Future<void> _saved() async {
    final editor = _editingGroup ? _groupEditor : _cardEditor;
    if (!await _waitAvailable() ||
        editor != (_editingGroup ? _groupEditor : _cardEditor)) {
      return;
    }
    setState(() {
      if (_editingGroup) {
        _group = _editGroup!.id;
      } else {
        _selected =
            _card?.summary.id ?? widget.controller.state.content!.cards.last.id;
      }
      _stopEditing();
    });
    _refresh();
  }

  Future<void> _delete(bool group) async {
    final snapshot = widget.controller.state.content!;
    final id = group ? _editGroup?.id : _card?.summary.id;
    if (id == null) return;
    final route = DialogRoute<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _DeleteContentDialog(
        controller: widget.controller,
        group: group,
        onConfirm: () => group
            ? widget.controller.deleteGroup(id, revision: snapshot.revision)
            : widget.controller.deleteCard(id, revision: snapshot.revision),
        onDone: (removed) {
          _closeOverlay();
          if (_available && removed) {
            setState(() {
              _stopEditing();
              _selected = null;
              _group = 'all';
            });
          }
        },
      ),
    );
    _overlay = route;
    await Navigator.of(context).push(route);
    if (identical(_overlay, route)) _overlay = null;
  }

  void _move(int direction) {
    if (_editing || _guarding) return;
    final cards = _cards;
    if (cards.isEmpty) return;
    final index = cards.indexWhere((c) => c.id == _selected);
    final next = index < 0
        ? (direction > 0 ? 0 : cards.length - 1)
        : (index + direction).clamp(0, cards.length - 1);
    setState(() => _selected = cards[next].id);
    if (_listScroll.hasClients) {
      _listScroll.animateTo(
        (next * 80.0).clamp(0, _listScroll.position.maxScrollExtent),
        duration: WantTheme.reducedMotionOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 120),
        curve: Curves.easeOut,
      );
    }
  }

  void _openSelected() {
    if (_editing) return;
    if (_selected == null) _move(1);
    setState(() => _compactDetail = true);
    _detailsFocus.requestFocus();
  }

  void _escape() {
    if (_editing) {
      unawaited(
        _navigate(() {
          _stopEditing();
          _compactDetail = false;
        }),
      );
    } else if (_search.text.isNotEmpty) {
      _search.clear();
      _searchFocus.requestFocus();
    } else {
      setState(() => _compactDetail = false);
      _listFocus.requestFocus();
    }
  }

  void _copy(FieldIdV1? field, {bool otp = false}) {
    if (_editing || _selected == null) return;
    if (otp ||
        widget.controller.state.content!.cards.any(
          (c) => c.id == _selected && c.cardType == CardTypeV1.account,
        )) {
      unawaited(
        widget.controller.copyCard(_selected!, field: field, currentOtp: otp),
      );
    }
  }

  void _focusSearch() => unawaited(
    _navigate(() {
      _stopEditing();
      _compactDetail = false;
      _searchFocus.requestFocus();
    }),
  );

  Future<void> _showGroups() async {
    if (_overlay != null || !_available || widget.controller.state.busy) return;
    Route<dynamic>? shown;
    await showWantSheet<void>(
      context: context,
      side: WantSheetSide.left,
      builder: (context) {
        if (shown == null) {
          shown = ModalRoute.of(context);
          _overlay = shown;
        }
        final state = widget.controller.state;
        if (!_available) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * .75,
            child: _nav(state, close: () => Navigator.pop(context)),
          ),
        );
      },
    );
    if (identical(_overlay, shown)) _overlay = null;
  }

  Widget _nav(VaultState state, {VoidCallback? close}) {
    final counts = <String, int>{};
    for (final card in state.content!.cards) {
      for (final id in card.groupIds) {
        counts.update(id, (n) => n + 1, ifAbsent: () => 1);
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _navRow(
          'all',
          _text(context, 'All secrets', 'Все секреты'),
          Icons.key_outlined,
          state.content!.cards.length,
          close: close,
        ),
        _navRow(
          'none',
          _text(context, 'Ungrouped', 'Без группы'),
          Icons.inbox_outlined,
          state.content!.cards.where((c) => c.groupIds.isEmpty).length,
          close: close,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: WantTypography(
                _text(context, 'Groups', 'Группы'),
                variant: WantTypographyVariant.label,
                colorRole: 'muted-foreground',
              ),
            ),
            _icon(
              'group-create',
              _text(context, 'New group', 'Новая группа'),
              Icons.create_new_folder_outlined,
              () {
                close?.call();
                _groupForm();
              },
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: state.content!.groups.length,
            itemBuilder: (context, i) {
              final group = state.content!.groups[i];
              return Row(
                children: [
                  Expanded(
                    child: _navRow(
                      group.id,
                      group.name,
                      Icons.folder_outlined,
                      counts[group.id] ?? 0,
                      group: group,
                      close: close,
                    ),
                  ),
                  _icon(
                    'group-edit-${group.id}',
                    _text(context, 'Edit group', 'Изменить группу'),
                    Icons.more_horiz,
                    () {
                      close?.call();
                      _groupForm(group);
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _navRow(
    String id,
    String name,
    IconData icon,
    int count, {
    GroupV1? group,
    VoidCallback? close,
  }) => Semantics(
    selected: _search.text.isEmpty && _group == id,
    child: WantButton(
      key: ValueKey('group-filter-$id'),
      pill: false,
      variant: _search.text.isEmpty && _group == id
          ? WantButtonVariant.secondary
          : WantButtonVariant.ghost,
      onPressed: () {
        close?.call();
        _chooseGroup(id);
      },
      child: Row(
        spacing: 10,
        children: [
          if (group == null)
            Icon(icon, size: 20)
          else
            SizedBox.square(
              dimension: 24,
              child: VaultGroupLogo(icon: group.icon, bytes: group.logo),
            ),
          Expanded(
            child: Text(name, maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
          Text(
            '$count',
            style: TextStyle(
              color: WantTheme.of(context).color('muted-foreground'),
            ),
          ),
        ],
      ),
    ),
  );
  Widget _icon(String key, String label, IconData icon, VoidCallback action) =>
      WantTooltip(
        message: label,
        child: WantButton(
          key: ValueKey(key),
          size: WantButtonSize.icon,
          variant: WantButtonVariant.ghost,
          semanticsLabel: label,
          onPressed: widget.controller.state.busy ? null : action,
          child: Icon(icon, size: 20),
        ),
      );
  Widget _filters(VaultState state) => WantPopover(
    triggerBuilder: (context, toggle, child) => WantButton(
      key: const ValueKey('vault-filters'),
      variant: WantButtonVariant.secondary,
      semanticsLabel: _text(context, 'Filters', 'Фильтры'),
      onPressed: toggle,
      child: child,
    ),
    child: const Icon(Icons.filter_list, size: 20),
    contentBuilder: (context, close) => SizedBox(
      width: 280,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [
          _CatalogSelect<String>(
            key: const ValueKey('filter-type'),
            label: _text(context, 'Type', 'Тип'),
            value: _type,
            values: [
              'all',
              ..._catalogTypes(state.catalog!).map((type) => type.name),
              if (state.content!.templates.isNotEmpty) CardTypeV1.custom.name,
            ],
            itemLabel: (value) => value == 'all'
                ? _text(context, 'All', 'Все')
                : _typeLabel(context, CardTypeV1.values.byName(value)),
            itemIcon: (value) => value == 'all'
                ? const Icon(Icons.list, size: 20)
                : _typeIcon(CardTypeV1.values.byName(value)),
            searchTerms: (value) => value == 'all'
                ? ''
                : _types[CardTypeV1.values.byName(value)]!.$1,
            onChanged: (v) {
              if (v != null) {
                setState(() => _type = v);
                close();
                _changed();
              }
            },
          ),
          _CatalogSelect<String>(
            key: const ValueKey('filter-service'),
            label: _text(context, 'Service', 'Сервис'),
            value: _service,
            values: [
              'all',
              ...state.catalog!.services,
              ...state.content!.services.map((s) => s.id),
            ],
            itemLabel: (value) => value == 'all'
                ? _text(context, 'All', 'Все')
                : _serviceLabel(context, value),
            itemIcon: (value) => value == 'all'
                ? const Icon(Icons.list, size: 20)
                : _serviceIcon(context, value),
            searchTerms: (value) => '$value ${_serviceAliases(value)}',
            onChanged: (v) {
              if (v != null) {
                setState(() => _service = v);
                close();
                _changed();
              }
            },
          ),
          WantSelect<String>(
            key: const ValueKey('filter-environment'),
            label: Text(_text(context, 'Environment', 'Окружение')),
            value: _environment,
            options: [
              WantOption(value: 'all', label: _text(context, 'All', 'Все')),
              WantOption(
                value: 'none',
                label: _text(context, 'Not set', 'Не задано'),
              ),
              for (final e in EnvironmentV1.values)
                WantOption(value: e.name, label: _environmentLabel(e)),
            ],
            onChanged: (v) {
              if (v != null) {
                setState(() => _environment = v);
                close();
                _changed();
              }
            },
          ),
          WantButton(
            variant: WantButtonVariant.ghost,
            onPressed: () {
              setState(() => _type = _service = _environment = 'all');
              close();
              _changed();
            },
            child: Text(_text(context, 'Reset filters', 'Сбросить фильтры')),
          ),
        ],
      ),
    ),
  );
  Widget _toolbar(VaultState state) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 8,
    children: [
      LayoutBuilder(
        builder: (context, box) {
          final search = VaultSecretInput(
            key: const ValueKey('vault-search'),
            label: _text(
              context,
              'Search all secrets',
              'Поиск по всем секретам',
            ),
            controller: _search,
            focusNode: _searchFocus,
            enabled: true,
            autofocus: true,
            last: true,
            concealed: false,
            onSubmitted: _openSelected,
          );
          final actions = Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: [
              _filters(state),
              WantButton(
                key: const ValueKey('account-create'),
                semanticsLabel: _text(context, 'New secret', 'Создать секрет'),
                onPressed: state.busy ? null : _newCard,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  children: [
                    const Icon(Icons.add, size: 20),
                    Text(_text(context, 'Create', 'Создать')),
                  ],
                ),
              ),
            ],
          );
          return box.maxWidth < 520 ||
                  MediaQuery.textScalerOf(context).scale(16) > 24
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 8,
                  children: [
                    search,
                    Align(alignment: Alignment.centerRight, child: actions),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  spacing: 12,
                  children: [
                    Expanded(child: search),
                    actions,
                  ],
                );
        },
      ),
      if (_type != 'all' || _service != 'all' || _environment != 'all')
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            if (_type != 'all')
              _filterChip(
                _typeLabel(context, CardTypeV1.values.byName(_type)),
                () => _type = 'all',
              ),
            if (_service != 'all')
              _filterChip(
                _serviceLabel(context, _service),
                () => _service = 'all',
              ),
            if (_environment != 'all')
              _filterChip(
                _environment == 'none'
                    ? _text(context, 'No environment', 'Без окружения')
                    : _environment,
                () => _environment = 'all',
              ),
          ],
        ),
    ],
  );
  Widget _filterChip(String label, VoidCallback clear) => WantButton(
    variant: WantButtonVariant.secondary,
    onPressed: () {
      setState(clear);
      _changed();
    },
    child: Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [Text(label), const Icon(Icons.close, size: 16)],
    ),
  );
  Widget _list(VaultState state) {
    final cards = _cards;
    return Focus(
      focusNode: _listFocus,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Row(
            children: [
              Expanded(
                child: WantTypography(
                  _search.text.isNotEmpty
                      ? _text(context, 'Search results', 'Результаты поиска')
                      : _text(context, 'Secrets', 'Секреты'),
                  variant: WantTypographyVariant.label,
                ),
              ),
              Text('${cards.length}'),
            ],
          ),
          SizedBox(
            height: 2,
            child: _searching ? const LinearProgressIndicator() : null,
          ),
          if (_search.text.isNotEmpty && _matches != null)
            Wrap(
              spacing: 4,
              children: [
                for (final group in state.content!.groups)
                  if (_matches!.groupIds.contains(group.id))
                    WantButton(
                      variant: WantButtonVariant.ghost,
                      onPressed: () => _chooseGroup(group.id),
                      child: Text(group.name),
                    ),
              ],
            ),
          Expanded(
            child: cards.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 12,
                      children: [
                        if (!_searching)
                          Text(
                            _text(context, 'No results', 'Ничего не найдено'),
                          ),
                        WantButton(
                          variant: WantButtonVariant.secondary,
                          onPressed: _newCard,
                          child: Text(
                            _text(context, 'Create secret', 'Создать секрет'),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    key: const ValueKey('vault-list'),
                    controller: _listScroll,
                    itemCount: cards.length,
                    itemBuilder: (context, i) {
                      final card = cards[i];
                      return _WorkspaceRow(
                        key: ValueKey('account-${card.id}'),
                        card: card,
                        login: _logins[card.id],
                        selected: card.id == _selected,
                        onPressed: () => _chooseCard(card.id),
                        onVisibility: (v) => _visibility(card.id, v),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _details(VaultState state) => Focus(
    focusNode: _detailsFocus,
    child: _editing
        ? (_editingGroup
              ? _GroupEditor(
                  key: _groupEditor,
                  embedded: true,
                  controller: widget.controller,
                  group: _editGroup,
                  revision: _editorRevision!,
                  onDone: _saved,
                  onCancel: () => unawaited(_navigate(_stopEditing)),
                  onDelete: _editGroup == null
                      ? null
                      : () => unawaited(_delete(true)),
                )
              : _CardEditor(
                  key: _cardEditor,
                  embedded: true,
                  controller: widget.controller,
                  card: _card,
                  initialGroupId: _group == 'all' || _group == 'none'
                      ? null
                      : _group,
                  revision: _editorRevision!,
                  onDone: _saved,
                  onCancel: () => unawaited(_navigate(_stopEditing)),
                  onDelete: _card == null
                      ? null
                      : () => unawaited(_delete(false)),
                ))
        : _selected == null
        ? Center(
            child: Text(_text(context, 'Select a secret', 'Выберите секрет')),
          )
        : _CardPreview(
            key: ValueKey('preview-$_selected'),
            controller: widget.controller,
            id: _selected!,
            revision: state.content!.revision,
            outsideFilter: !_cards.any((c) => c.id == _selected),
            onEdit: () => unawaited(_editCard()),
          ),
  );
  Widget _panel(Widget child) =>
      Padding(padding: const EdgeInsets.all(16), child: child);
  Widget _layout(VaultState state) => LayoutBuilder(
    builder: (context, box) {
      final scaled = MediaQuery.textScalerOf(context).scale(16) > 24;
      final wide = box.maxWidth >= 1060 && !scaled;
      final dual = box.maxWidth >= 696 && !scaled;
      final navigation = _panel(_nav(state));
      final list = _panel(_list(state));
      final details = _panel(_details(state));
      final panes = wide || dual
          ? _resizablePanes(box.maxWidth, wide, navigation, list, details)
          : (_compactDetail || _editing ? details : list);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          _toolbar(state),
          if (!wide)
            Row(
              children: [
                Expanded(
                  child: WantButton(
                    key: const ValueKey('groups-open'),
                    variant: WantButtonVariant.ghost,
                    onPressed: () => unawaited(_showGroups()),
                    child: Text(_text(context, 'Groups', 'Группы')),
                  ),
                ),
                if (!dual && (_compactDetail || _editing))
                  Expanded(
                    child: WantButton(
                      variant: WantButtonVariant.ghost,
                      onPressed: _escape,
                      child: Text(_text(context, 'Back', 'Назад')),
                    ),
                  ),
              ],
            ),
          Expanded(child: panes),
          if (dual)
            WantTypography(
              _text(
                context,
                '↑ ↓ Select   Enter Details   ⌘/Ctrl E Edit   ⌘/Ctrl L Lock',
                '↑ ↓ Выбор   Enter Подробности   ⌘/Ctrl E Изменить   ⌘/Ctrl L Блокировка',
              ),
              variant: WantTypographyVariant.caption,
              colorRole: 'muted-foreground',
            ),
        ],
      );
    },
  );
  Widget _resizablePanes(
    double width,
    bool wide,
    Widget navigation,
    Widget list,
    Widget details,
  ) {
    const divider = 12.0;
    const groupMin = 176.0, listMin = 240.0, detailsMin = 320.0;
    final usable = width - divider * (wide ? 2 : 1);
    (double, double) widths(WorkspaceLayoutV1 preferences) {
      final groups = wide
          ? (usable * preferences.groupFraction)
                .clamp(groupMin, usable - listMin - detailsMin)
                .toDouble()
          : 0.0;
      final fraction = wide
          ? preferences.listFraction
          : preferences.dualListFraction;
      final secrets = (usable * fraction)
          .clamp(listMin, usable - groups - detailsMin)
          .toDouble();
      return (groups, secrets);
    }

    final (groups, secrets) = widths(_paneWidths);

    void resize(int boundary, double delta) {
      final preferences = _paneWidths;
      final (groups, secrets) = widths(preferences);
      if (boundary == 0) {
        delta = delta.clamp(groupMin - groups, secrets - listMin).toDouble();
      } else {
        delta = delta
            .clamp(listMin - secrets, usable - groups - secrets - detailsMin)
            .toDouble();
      }
      if (delta == 0) return;
      setState(() {
        _paneWidths = WorkspaceLayoutV1(
          groupFraction: boundary == 0
              ? (groups + delta) / usable
              : preferences.groupFraction,
          listFraction: wide
              ? (secrets + (boundary == 0 ? -delta : delta)) / usable
              : preferences.listFraction,
          dualListFraction: wide
              ? preferences.dualListFraction
              : (secrets + delta) / usable,
        );
      });
    }

    void save() {
      if (widget.appearance case final appearance?
          when appearance.state.settings.layout != _paneWidths) {
        unawaited(appearance.saveLayout(_paneWidths));
      }
    }

    Widget handle(int boundary, String label) => _PaneDivider(
      key: ValueKey('vault-pane-divider-$boundary'),
      width: divider,
      label: label,
      onDelta: (delta) => resize(boundary, delta),
      onDone: save,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (wide) ...[
          SizedBox(width: groups, child: navigation),
          handle(0, _text(context, 'Resize groups', 'Изменить ширину групп')),
        ],
        SizedBox(width: secrets, child: list),
        handle(1, _text(context, 'Resize secrets', 'Изменить ширину секретов')),
        Expanded(child: details),
      ],
    );
  }

  Widget _withActivity(Widget child) => Listener(
    behavior: HitTestBehavior.translucent,
    onPointerDown: (_) => widget.controller.activity(),
    onPointerHover: (_) => widget.controller.activity(),
    onPointerSignal: (_) => widget.controller.activity(),
    child: child,
  );

  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<VaultController, VaultState>(
    bloc: widget.controller,
    listener: (context, state) {
      if (state.phase != VaultPhase.unlocked) {
        _navigation++;
        _releaseAvailability();
        _epoch++;
        _debounce?.cancel();
        _rowTimer?.cancel();
        _closeOverlay();
        _search.clear();
        _logins.clear();
        _card = null;
        _matches = null;
      } else if (_revision != state.content?.revision) {
        _revision = state.content?.revision;
        _epoch++;
        _logins.clear();
        _wanted.addAll(_visible);
        _refresh();
      } else if (!state.busy) {
        if (_pendingFind) _refresh();
        _scheduleRows();
      }
    },
    builder: (context, state) {
      if (state.phase != VaultPhase.unlocked) {
        return const SizedBox.shrink();
      }
      if (state.content == null || state.catalog == null) {
        return Center(
          child: WantButton(
            onPressed: state.busy
                ? null
                : () => unawaited(widget.controller.loadContent()),
            child: Text(_text(context, 'Load vault', 'Загрузить сейф')),
          ),
        );
      }
      final mac = Theme.of(context).platform == TargetPlatform.macOS;
      final shortcut = widget.shortcutRequest;
      if (shortcut != null && shortcut.$1 != _lastShortcut && !state.busy) {
        _lastShortcut = shortcut.$1;
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!mounted ||
              widget.controller.state.phase != VaultPhase.unlocked) {
            return;
          }
          widget.onShortcutOpened?.call();
          await _navigate(() {
            _stopEditing();
            _section = _VaultSection.secrets;
            _compactDetail = true;
            if (shortcut.$2 == 'create') {
              _editing = true;
              _editorRevision = widget.controller.state.content!.revision;
            } else {
              _selected = shortcut.$3;
            }
          });
          if (shortcut.$2 == 'settings' &&
              _available &&
              _selected == shortcut.$3) {
            await _editCard();
          }
        });
      }
      if (widget.restoreRequested && !_restoreScheduled && !state.busy) {
        _restoreScheduled = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_available || widget.controller.state.busy || _overlay != null) {
            _restoreScheduled = false;
            return;
          }
          widget.onRestoreOpened?.call();
          unawaited(_showBackup(false));
        });
      }
      SingleActivator key(LogicalKeyboardKey k, {bool shift = false}) =>
          SingleActivator(k, meta: mac, control: !mac, shift: shift);
      return _withActivity(
        _withMenu(
          state,
          _section == _VaultSection.secrets
              ? CallbackShortcuts(
                  bindings: {
                    key(LogicalKeyboardKey.keyK): _focusSearch,
                    key(LogicalKeyboardKey.keyF): _focusSearch,
                    key(LogicalKeyboardKey.keyN): _newCard,
                    key(LogicalKeyboardKey.keyN, shift: true): _groupForm,
                    key(LogicalKeyboardKey.keyE): () => unawaited(_editCard()),
                    key(LogicalKeyboardKey.keyS): () {
                      if (_editing && !state.busy) {
                        unawaited(
                          _editingGroup
                              ? _groupEditor.currentState!._save()
                              : _cardEditor.currentState!._save(),
                        );
                      }
                    },
                    key(LogicalKeyboardKey.keyL): () =>
                        unawaited(widget.controller.lock()),
                    key(LogicalKeyboardKey.keyC, shift: true): () =>
                        _copy(FieldIdV1.password),
                    key(LogicalKeyboardKey.keyU, shift: true): () =>
                        _copy(FieldIdV1.login),
                    key(LogicalKeyboardKey.keyT, shift: true): () =>
                        _copy(null, otp: true),
                    if (!_editing) ...{
                      const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
                          _move(1),
                      const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
                          _move(-1),
                      const SingleActivator(LogicalKeyboardKey.enter):
                          _openSelected,
                    },
                    const SingleActivator(LogicalKeyboardKey.escape): _escape,
                  },
                  child: _layout(state),
                )
              : _VaultSectionView(
                  key: ValueKey(_section),
                  section: _section,
                  controller: widget.controller,
                  catalog: state.catalog!,
                  appearance: widget.appearance,
                  onReset: state.busy ? null : _showReset,
                  onBackup: state.busy ? null : _showBackup,
                ),
        ),
      );
    },
  );
}

final class _PaneDivider extends StatefulWidget {
  final double width;
  final String label;
  final ValueChanged<double> onDelta;
  final VoidCallback onDone;

  const _PaneDivider({
    super.key,
    required this.width,
    required this.label,
    required this.onDelta,
    required this.onDone,
  });

  @override
  State<_PaneDivider> createState() => _PaneDividerState();
}

final class _PaneDividerState extends State<_PaneDivider> {
  bool _focused = false, _hovered = false, _dragging = false;

  void _step(double delta) {
    widget.onDelta(delta);
    widget.onDone();
  }

  void _finish() {
    setState(() => _dragging = false);
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: widget.label,
    onIncrease: () => _step(16),
    onDecrease: () => _step(-16),
    child: Focus(
      onFocusChange: (value) => setState(() => _focused = value),
      onKeyEvent: (_, event) {
        if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
          return KeyEventResult.ignored;
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          _step(-16);
        } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
          _step(16);
        } else {
          return KeyEventResult.ignored;
        }
        return KeyEventResult.handled;
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeLeftRight,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: (_) => setState(() => _dragging = true),
          onHorizontalDragUpdate: (event) => widget.onDelta(event.delta.dx),
          onHorizontalDragEnd: (_) => _finish(),
          onHorizontalDragCancel: _finish,
          child: SizedBox(
            width: widget.width,
            child: VerticalDivider(
              width: widget.width,
              thickness: _focused || _hovered || _dragging ? 2 : 1,
              color: WantTheme.of(
                context,
              ).color(_focused || _hovered || _dragging ? 'primary' : 'border'),
            ),
          ),
        ),
      ),
    ),
  );
}

final class _WorkspaceRow extends StatefulWidget {
  final CardSummaryV1 card;
  final String? login;
  final bool selected;
  final VoidCallback onPressed;
  final ValueChanged<bool> onVisibility;
  const _WorkspaceRow({
    super.key,
    required this.card,
    this.login,
    required this.selected,
    required this.onPressed,
    required this.onVisibility,
  });
  @override
  State<_WorkspaceRow> createState() => _WorkspaceRowState();
}

final class _WorkspaceRowState extends State<_WorkspaceRow> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onVisibility(true);
    });
  }

  @override
  void dispose() {
    widget.onVisibility(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    selected: widget.selected,
    child: WantButton(
      pill: false,
      variant: widget.selected
          ? WantButtonVariant.secondary
          : WantButtonVariant.ghost,
      onPressed: widget.onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          spacing: 12,
          children: [
            SizedBox.square(
              dimension: 32,
              child: Center(child: _typeIcon(widget.card.cardType, size: 22)),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text(
                    widget.card.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    widget.login ?? _serviceLabel(context, widget.card.service),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: WantTheme.of(context).color('muted-foreground'),
                    ),
                  ),
                  Text(
                    [
                      _typeLabel(context, widget.card.cardType),
                      if (widget.card.environment != null)
                        _environmentLabel(widget.card.environment!),
                    ].join(' · '),
                    style: TextStyle(
                      fontSize: 12,
                      color: WantTheme.of(context).color('muted-foreground'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
