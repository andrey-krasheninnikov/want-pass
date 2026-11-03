part of 'content.dart';

final class _VaultBrowser extends StatefulWidget {
  final VaultController controller;
  final void Function(GroupV1?) onGroup;
  final void Function(String?) onCard;
  const _VaultBrowser({
    required this.controller,
    required this.onGroup,
    required this.onCard,
  });
  @override
  State<_VaultBrowser> createState() => _VaultBrowserState();
}

final class _VaultBrowserState extends State<_VaultBrowser>
    with WidgetsBindingObserver {
  final _search = TextEditingController();
  final _expanded = <String>{};
  final _visible = <String, int>{};
  final _rows = <String, CardRowV1>{};
  List<({String groupId, GroupV1? group, CardSummaryV1? card})> _entries =
      const [];
  CardMatchesV1? _matches;
  String _type = 'all', _service = 'all', _environment = 'all';
  Timer? _debounce, _rowTimer, _otpExpiry;
  int _epoch = 0;
  bool _disposed = false, _tickerEnabled = true;
  bool _active = true,
      _reading = false,
      _pendingRows = false,
      _searching = false;
  bool get _available =>
      !_disposed &&
      mounted &&
      _active &&
      _tickerEnabled &&
      widget.controller.state.phase == VaultPhase.unlocked;

  @override
  void initState() {
    super.initState();
    _active =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_find());
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _epoch++;
    _debounce?.cancel();
    _rowTimer?.cancel();
    _otpExpiry?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _search.clear();
    _search.dispose();
    _rows.clear();
    _visible.clear();
    _matches = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _active = state == AppLifecycleState.resumed;
    _suspendOrRefresh();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final enabled = TickerMode.valuesOf(context).enabled;
    if (enabled == _tickerEnabled) return;
    _tickerEnabled = enabled;
    if (!enabled) {
      _epoch++;
      _rowTimer?.cancel();
      _otpExpiry?.cancel();
      _debounce?.cancel();
      _rows.clear();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _suspendOrRefresh();
      });
    }
  }

  void _suspendOrRefresh() {
    _epoch++;
    _debounce?.cancel();
    _rowTimer?.cancel();
    _otpExpiry?.cancel();
    if (!_available) {
      if (mounted) setState(_rows.clear);
      return;
    }
    unawaited(_find());
  }

  void _changed() {
    if (!_available) return;
    widget.controller.activity();
    _epoch++;
    _debounce?.cancel();
    _rowTimer?.cancel();
    _otpExpiry?.cancel();
    setState(() {
      _searching = true;
      _rows.clear();
    });
    _debounce = Timer(
      const Duration(milliseconds: 250),
      () => unawaited(_find()),
    );
  }

  void _applyFilters() {
    widget.controller.activity();
    _epoch++;
    _debounce?.cancel();
    _rowTimer?.cancel();
    _otpExpiry?.cancel();
    setState(() {
      _searching = true;
      _rows.clear();
    });
    unawaited(_find());
  }

  Future<void> _find() async {
    if (!_available ||
        widget.controller.state.content == null ||
        widget.controller.state.busy) {
      return;
    }
    final epoch = ++_epoch;
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
    if (!_available || epoch != _epoch) return;
    setState(() {
      _searching = false;
      _matches = matches;
      _rows.clear();
      _buildEntries();
    });
    _scheduleRows();
  }

  void _buildEntries() {
    final snapshot = widget.controller.state.content;
    final matches = _matches;
    if (snapshot == null ||
        matches == null ||
        matches.revision != snapshot.revision) {
      _entries = const [];
      return;
    }
    final ids = matches.cardIds.toSet();
    final byGroup = <String, List<CardSummaryV1>>{};
    for (final card in snapshot.cards) {
      if (!ids.contains(card.id)) continue;
      for (final id in card.groupIds.isEmpty ? ['none'] : card.groupIds) {
        (byGroup[id] ??= []).add(card);
      }
    }
    final entries = <({String groupId, GroupV1? group, CardSummaryV1? card})>[];
    void group(String id, GroupV1? group) {
      final cards = byGroup[id] ?? const <CardSummaryV1>[];
      if (_search.text.isNotEmpty ||
          _type != 'all' ||
          _service != 'all' ||
          _environment != 'all') {
        if (cards.isEmpty &&
            !(_search.text.isNotEmpty &&
                matches.groupIds.contains(id) &&
                _type == 'all' &&
                _service == 'all' &&
                _environment == 'all')) {
          return;
        }
      }
      entries.add((groupId: id, group: group, card: null));
      if (_expanded.contains(id)) {
        for (final card in cards) {
          entries.add((groupId: id, group: group, card: card));
        }
      }
    }

    for (final item in snapshot.groups) {
      group(item.id, item);
    }
    if (byGroup.containsKey('none')) group('none', null);
    _entries = entries;
  }

  void _visibility(String id, bool visible) {
    if (!mounted || _disposed) return;
    if (visible) {
      _visible[id] = (_visible[id] ?? 0) + 1;
    } else {
      final count = (_visible[id] ?? 1) - 1;
      if (count <= 0) {
        _visible.remove(id);
        _rows.remove(id);
      } else {
        _visible[id] = count;
      }
    }
    _scheduleRows();
  }

  void _scheduleRows() {
    _pendingRows = true;
    if (_reading || !_available) return;
    _rowTimer?.cancel();
    _rowTimer = Timer(
      const Duration(milliseconds: 16),
      () => unawaited(_readRows()),
    );
  }

  void _scheduleOtpExpiry() {
    _otpExpiry?.cancel();
    if (!_available) return;
    final now = DateTime.now().toUtc();
    final deadlines =
        _rows.values
            .map((r) => r.otp?.validUntil)
            .whereType<DateTime>()
            .where((d) => d.isAfter(now))
            .toList()
          ..sort();
    if (deadlines.isEmpty) return;
    _otpExpiry = Timer(deadlines.first.difference(now), () {
      if (!_available) return;
      setState(() {});
      _scheduleOtpExpiry();
    });
  }

  Future<void> _readRows() async {
    if (!_available) return;
    // Expiration remains local even while native work or clipboard publication is pending.
    setState(() {});
    if (widget.controller.state.busy || _reading) return;
    _reading = true;
    _pendingRows = false;
    var completed = false;
    final epoch = _epoch;
    final ids = _visible.keys.toList(growable: false);
    try {
      for (var start = 0; start < ids.length; start += 50) {
        final end = (start + 50).clamp(0, ids.length);
        final rows = await widget.controller.readCardRows(
          ids.sublist(start, end),
        );
        if (!_available || epoch != _epoch) return;
        if (rows == null) return;
        setState(() {
          for (final row in rows) {
            if (_visible.containsKey(row.id)) _rows[row.id] = row;
          }
        });
        _scheduleOtpExpiry();
      }
      completed = true;
    } finally {
      _reading = false;
      if (_available) {
        if (_pendingRows) {
          _scheduleRows();
        } else if (completed) {
          final now = DateTime.now().toUtc();
          final deadlines =
              _rows.values
                  .map((r) => r.otp?.validUntil)
                  .whereType<DateTime>()
                  .toList()
                ..sort();
          if (deadlines.isNotEmpty) {
            _rowTimer?.cancel();
            final delay = deadlines.first.difference(now);
            _rowTimer = Timer(
              delay.isNegative ? const Duration(milliseconds: 100) : delay,
              () => unawaited(_readRows()),
            );
          }
        }
      }
    }
  }

  Widget _filters(BuildContext context, VaultState state) => WantPopover(
    child: Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        const Icon(Icons.filter_list, size: 20),
        Text(_text(context, 'Filters', 'Фильтры')),
      ],
    ),
    triggerBuilder: (context, toggle, child) => WantButton(
      key: const ValueKey('vault-filters'),
      variant: WantButtonVariant.secondary,
      onPressed: toggle,
      child: child,
    ),
    contentBuilder: (context, close) => SizedBox(
      width: 280,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [
          WantSelect<String>(
            key: const ValueKey('filter-type'),
            value: _type,
            label: Text(_text(context, 'Type', 'Тип')),
            options: [
              WantOption(value: 'all', label: _text(context, 'All', 'Все')),
              for (final type in CardTypeV1.values)
                WantOption(value: type.name, label: _typeLabel(context, type)),
            ],
            onChanged: (v) {
              if (v != null) {
                setState(() => _type = v);
                close();
                _applyFilters();
              }
            },
          ),
          WantSelect<String>(
            key: const ValueKey('filter-service'),
            value: _service,
            label: Text(_text(context, 'Service', 'Сервис')),
            options: [
              WantOption(value: 'all', label: _text(context, 'All', 'Все')),
              for (final service in state.catalog?.services ?? <String>[])
                WantOption(
                  value: service,
                  label: _serviceLabel(context, service),
                ),
            ],
            onChanged: (v) {
              if (v != null) {
                setState(() => _service = v);
                close();
                _applyFilters();
              }
            },
          ),
          WantSelect<String>(
            key: const ValueKey('filter-environment'),
            value: _environment,
            label: Text(_text(context, 'Environment', 'Окружение')),
            options: [
              WantOption(value: 'all', label: _text(context, 'All', 'Все')),
              WantOption(
                value: 'none',
                label: _text(context, 'Not set', 'Не задано'),
              ),
              for (final env in EnvironmentV1.values)
                WantOption(value: env.name, label: _environmentLabel(env)),
            ],
            onChanged: (v) {
              if (v != null) {
                setState(() => _environment = v);
                close();
                _applyFilters();
              }
            },
          ),
          WantButton(
            variant: WantButtonVariant.ghost,
            onPressed: () {
              setState(() {
                _type = _service = _environment = 'all';
                _search.clear();
              });
              close();
              _applyFilters();
            },
            child: Text(_text(context, 'Reset', 'Сбросить')),
          ),
        ],
      ),
    ),
  );
  Widget _toolbar(BuildContext context, VaultState state) {
    final actions = Wrap(
      alignment: WrapAlignment.end,
      runSpacing: 8,
      spacing: 8,
      children: [
        WantTooltip(
          message: _text(context, 'New group', 'Новая группа'),
          child: WantButton(
            key: const ValueKey('group-create'),
            size: WantButtonSize.icon,
            variant: WantButtonVariant.secondary,
            semanticsLabel: _text(context, 'New group', 'Новая группа'),
            onPressed: state.busy ? null : () => widget.onGroup(null),
            child: const Icon(Icons.create_new_folder_outlined, size: 20),
          ),
        ),
        WantTooltip(
          message: _text(context, 'New card', 'Новая карточка'),
          child: WantButton(
            key: const ValueKey('account-create'),
            size: WantButtonSize.icon,
            semanticsLabel: _text(context, 'New card', 'Новая карточка'),
            onPressed: state.busy ? null : () => widget.onCard(null),
            child: const Icon(Icons.add_card_outlined, size: 20),
          ),
        ),
        _filters(context, state),
      ],
    );
    final search = VaultSecretInput(
      key: const ValueKey('vault-search'),
      label: _text(
        context,
        'Search groups, cards and values',
        'Поиск по группам, карточкам и значениям',
      ),
      controller: _search,
      enabled: true,
      autofocus: false,
      last: true,
      concealed: false,
      onChanged: (_) => _changed(),
      onSubmitted: () {
        _debounce?.cancel();
        unawaited(_find());
      },
    );
    return LayoutBuilder(
      builder: (context, box) => box.maxWidth >= 640
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: 12,
              children: [
                Expanded(child: search),
                actions,
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: [
                search,
                Align(alignment: Alignment.centerRight, child: actions),
              ],
            ),
    );
  }

  Widget _groupRow(BuildContext context, String id, GroupV1? group, bool busy) {
    final expanded = _expanded.contains(id);
    return Semantics(
      container: true,
      expanded: expanded,
      child: Row(
        children: [
          Expanded(
            child: WantButton(
              key: ValueKey('group-filter-$id'),
              variant: WantButtonVariant.secondary,
              onPressed: () {
                widget.controller.activity();
                setState(() {
                  expanded ? _expanded.remove(id) : _expanded.add(id);
                  _buildEntries();
                });
              },
              child: Row(
                spacing: 12,
                children: [
                  AnimatedRotation(
                    turns: expanded ? .25 : 0,
                    duration: WantTheme.reducedMotionOf(context)
                        ? Duration.zero
                        : const Duration(milliseconds: 180),
                    child: const Icon(Icons.chevron_right, size: 20),
                  ),
                  const Spacer(),
                  if (group != null)
                    VaultGroupLogo(icon: group.icon, bytes: group.logo),
                  Flexible(
                    child: Text(
                      group?.name ??
                          _text(context, 'Without a group', 'Без группы'),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (group != null)
            WantButton(
              key: ValueKey('group-edit-$id'),
              size: WantButtonSize.icon,
              variant: WantButtonVariant.ghost,
              semanticsLabel: _text(context, 'Edit group', 'Изменить группу'),
              onPressed: busy ? null : () => widget.onGroup(group),
              child: const Icon(Icons.more_horiz, size: 20),
            )
          else
            const SizedBox(width: 44),
        ],
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<VaultController, VaultState>(
    bloc: widget.controller,
    listener: (context, state) {
      if (state.phase != VaultPhase.unlocked) {
        _epoch++;
        _debounce?.cancel();
        _rowTimer?.cancel();
        _otpExpiry?.cancel();
        _search.clear();
        _rows.clear();
        _visible.clear();
        _matches = null;
        _entries = const [];
      } else if (_matches?.revision != state.content?.revision ||
          (!state.busy && _searching)) {
        unawaited(_find());
      } else if (!state.busy) {
        _scheduleRows();
      }
    },
    builder: (context, state) {
      if (state.phase != VaultPhase.unlocked) return const SizedBox.shrink();
      if (state.content == null) {
        return Center(
          child: WantButton(
            onPressed: state.busy
                ? null
                : () => unawaited(widget.controller.loadContent()),
            child: Text(_text(context, 'Load vault', 'Загрузить сейф')),
          ),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          _toolbar(context, state),
          if (_searching)
            const SizedBox(height: 2, child: LinearProgressIndicator()),
          Expanded(
            child: LayoutBuilder(
              builder: (context, box) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: box.maxWidth < 720 ? 720 : box.maxWidth,
                  height: box.maxHeight,
                  child: CustomScrollView(
                    key: const ValueKey('vault-table'),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _text(context, 'Values', 'Значения'),
                                ),
                              ),
                              SizedBox(
                                width: 260,
                                child: Text(
                                  _text(
                                    context,
                                    'Group / card',
                                    'Группа / карточка',
                                  ),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_entries.isEmpty && !_searching)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Text(
                              _text(
                                context,
                                'No matching groups or cards',
                                'Подходящих групп или карточек нет',
                              ),
                            ),
                          ),
                        ),
                      SliverList.builder(
                        itemCount: _entries.length,
                        itemBuilder: (context, index) {
                          final entry = _entries[index];
                          final card = entry.card;
                          if (card == null) {
                            return Padding(
                              key: ValueKey('group-${entry.groupId}'),
                              padding: const EdgeInsets.only(bottom: 4, top: 8),
                              child: _groupRow(
                                context,
                                entry.groupId,
                                entry.group,
                                state.busy,
                              ),
                            );
                          }
                          return _SecretTableRow(
                            key: ValueKey('${entry.groupId}/${card.id}'),
                            groupId: entry.groupId,
                            card: card,
                            row: _rows[card.id],
                            controller: widget.controller,
                            busy: state.busy,
                            onOpen: () => widget.onCard(card.id),
                            onVisibility: (visible) =>
                                _visibility(card.id, visible),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

final class _SecretTableRow extends StatefulWidget {
  final String groupId;
  final CardSummaryV1 card;
  final CardRowV1? row;
  final VaultController controller;
  final bool busy;
  final VoidCallback onOpen;
  final ValueChanged<bool> onVisibility;
  const _SecretTableRow({
    super.key,
    required this.groupId,
    required this.card,
    required this.row,
    required this.controller,
    required this.busy,
    required this.onOpen,
    required this.onVisibility,
  });
  @override
  State<_SecretTableRow> createState() => _SecretTableRowState();
}

final class _SecretTableRowState extends State<_SecretTableRow> {
  bool _announced = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _announced = true;
        widget.onVisibility(true);
      }
    });
  }

  @override
  void dispose() {
    if (_announced) widget.onVisibility(false);
    super.dispose();
  }

  Widget _value(
    BuildContext context, {
    required String key,
    required String label,
    required String value,
    required VoidCallback onPressed,
  }) => WantTooltip(
    message: _text(context, 'Copy ', 'Скопировать: ') + label,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 220, minWidth: 110),
      child: WantButton(
        key: ValueKey(key),
        variant: WantButtonVariant.ghost,
        semanticsLabel: _text(context, 'Copy ', 'Скопировать: ') + label,
        onPressed: widget.busy ? null : onPressed,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: WantTheme.of(context).color('muted-foreground'),
              ),
            ),
            Text(value, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    ),
  );
  @override
  Widget build(BuildContext context) {
    final row = widget.row;
    final card = widget.card;
    final otp = row?.otp;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: WantTheme.of(context).color('border')),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 12,
          children: [
            Expanded(
              child: row == null
                  ? const SizedBox(height: 44, child: Center(child: Text('…')))
                  : Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        for (final field in row.fields)
                          _value(
                            context,
                            key:
                                'card-field-${widget.groupId}-${card.id}-${field.name}',
                            label: _fieldLabel(context, field),
                            value: field == FieldIdV1.login
                                ? row.login ?? '••••••••'
                                : '••••••••',
                            onPressed: () => unawaited(
                              widget.controller.copyCard(card.id, field: field),
                            ),
                          ),
                        if (otp != null)
                          _value(
                            context,
                            key: 'card-otp-${widget.groupId}-${card.id}',
                            label: 'OTP',
                            value:
                                DateTime.now().toUtc().isBefore(otp.validUntil)
                                ? otp.code
                                : '••••••',
                            onPressed: () => unawaited(
                              widget.controller.copyCard(
                                card.id,
                                currentOtp: true,
                              ),
                            ),
                          ),
                        if (row.attachment case final file?)
                          WantButton(
                            key: ValueKey('card-file-${card.id}'),
                            variant: WantButtonVariant.ghost,
                            onPressed: widget.busy ? null : widget.onOpen,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 8,
                              children: [
                                const Icon(Icons.attach_file, size: 20),
                                Flexible(
                                  child: Text(
                                    '${file.name} · ${file.size} B',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
            ),
            SizedBox(
              width: 260,
              child: Row(
                children: [
                  Expanded(
                    child: WantButton(
                      key: ValueKey('account-${card.id}'),
                      variant: WantButtonVariant.ghost,
                      onPressed: widget.busy ? null : widget.onOpen,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              card.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              [
                                _serviceLabel(context, card.service),
                                _typeLabel(context, card.cardType),
                                if (card.environment != null)
                                  _environmentLabel(card.environment!),
                              ].join(' · '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: WantTheme.of(context)
                                    .color('muted-foreground'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  WantButton(
                    key: ValueKey('card-edit-${widget.groupId}-${card.id}'),
                    size: WantButtonSize.icon,
                    variant: WantButtonVariant.ghost,
                    semanticsLabel: _text(
                      context,
                      'Card details',
                      'Подробнее о карточке',
                    ),
                    onPressed: widget.busy ? null : widget.onOpen,
                    child: const Icon(Icons.more_horiz, size: 20),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
