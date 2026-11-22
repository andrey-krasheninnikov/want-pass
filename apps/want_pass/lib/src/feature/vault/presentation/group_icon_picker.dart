part of 'content.dart';

enum _GroupTone {
  brand(null, 'Brand', 'Фирменный'),
  blue(Color(0xff4b7ff2), 'Blue', 'Синий'),
  teal(Color(0xff16837d), 'Teal', 'Бирюзовый'),
  green(Color(0xff27884b), 'Green', 'Зелёный'),
  amber(Color(0xffad6815), 'Amber', 'Янтарный'),
  red(Color(0xffcc444b), 'Red', 'Красный'),
  pink(Color(0xffad4ba4), 'Pink', 'Розовый');

  static const _pngTag = 'WantPassGroupIcon';
  final Color? tint;
  final String en, ru;
  const _GroupTone(this.tint, this.en, this.ru);

  static _GroupTone? fromLogo(List<int> bytes, String icon) {
    if (bytes.isEmpty) return null;
    try {
      final info = img.PngDecoder().startDecode(Uint8List.fromList(bytes));
      if (info is! img.PngInfo) return null;
      final tag = info.textData[_pngTag];
      for (final tone in values) {
        if (tone.tint != null && tag == '1:$icon:${tone.name}') return tone;
      }
    } on Object {
      // An ordinary logo or an invalid image needs no editable color metadata.
    }
    return null;
  }

  Future<Uint8List> render(String icon) async {
    const size = 128;
    final glyph = vaultGroupIcons[icon] ?? Icons.folder_outlined;
    final text = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(glyph.codePoint),
        style: TextStyle(
          color: tint,
          fontFamily: glyph.fontFamily,
          package: glyph.fontPackage,
          fontSize: 96,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final recorder = ui.PictureRecorder();
    text.paint(
      Canvas(recorder),
      Offset((size - text.width) / 2, (size - text.height) / 2),
    );
    text.dispose();
    final picture = recorder.endRecording();
    try {
      final bitmap = await picture.toImage(size, size);
      try {
        final png = await bitmap.toByteData(format: ui.ImageByteFormat.png);
        final image = img.decodePng(png!.buffer.asUint8List())!;
        image.addTextData({_pngTag: '1:$icon:$name'});
        return img.encodePng(image);
      } finally {
        bitmap.dispose();
      }
    } finally {
      picture.dispose();
    }
  }
}

final class _GroupIconPicker extends StatefulWidget {
  final String icon;
  final List<int> image;
  final _GroupTone tone;
  final bool enabled;
  final Future<List<int>?> Function() selectImage;
  final void Function(String icon, List<int> image, _GroupTone tone) onChanged;

  const _GroupIconPicker({
    required this.icon,
    required this.image,
    required this.tone,
    required this.enabled,
    required this.selectImage,
    required this.onChanged,
  });

  @override
  State<_GroupIconPicker> createState() => _GroupIconPickerState();
}

final class _GroupIconPickerState extends State<_GroupIconPicker> {
  bool _selecting = false;

  String _iconLabel(String id) => switch (id) {
    'building' => _text(context, 'Company', 'Компания'),
    'briefcase' => _text(context, 'Work', 'Работа'),
    'code' => _text(context, 'Code', 'Код'),
    'home' => _text(context, 'Home', 'Дом'),
    'key' => _text(context, 'Key', 'Ключ'),
    _ => _text(context, 'Folder', 'Папка'),
  };

  Future<void> _upload(BuildContext popoverContext, VoidCallback close) async {
    if (_selecting || !widget.enabled) return;
    setState(() => _selecting = true);
    try {
      final bytes = await widget.selectImage();
      if (!mounted || !popoverContext.mounted || bytes == null) return;
      widget.onChanged(widget.icon, bytes, _GroupTone.brand);
      close();
    } finally {
      if (mounted) setState(() => _selecting = false);
    }
  }

  @override
  Widget build(BuildContext context) => WantPopover(
    child: VaultGroupLogo(
      icon: widget.icon,
      bytes: widget.image,
      tint: widget.tone.tint,
    ),
    triggerBuilder: (context, toggle, child) => Tooltip(
      message: _text(context, 'Choose group icon', 'Выбрать иконку группы'),
      excludeFromSemantics: true,
      child: WantButton(
        key: const ValueKey('group-icon-picker'),
        variant: WantButtonVariant.secondary,
        size: WantButtonSize.icon,
        pill: false,
        semanticsLabel: _text(
          context,
          'Choose group icon',
          'Выбрать иконку группы',
        ),
        onPressed: widget.enabled ? toggle : null,
        child: child,
      ),
    ),
    contentBuilder: (context, close) => ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 222),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _choice(
                key: const ValueKey('group-logo-select'),
                label: _text(context, 'Upload image', 'Загрузить изображение'),
                selected: widget.image.isNotEmpty,
                onPressed: () => unawaited(_upload(context, close)),
                child: const Icon(Icons.file_upload_outlined, size: 20),
              ),
              for (final entry in vaultGroupIcons.entries)
                _choice(
                  key: ValueKey('group-icon-${entry.key}'),
                  label: _iconLabel(entry.key),
                  selected: widget.image.isEmpty && widget.icon == entry.key,
                  onPressed: () =>
                      widget.onChanged(entry.key, const [], widget.tone),
                  child: Icon(entry.value, color: widget.tone.tint, size: 20),
                ),
            ],
          ),
          Divider(height: 1, color: WantTheme.of(context).color('border')),
          Semantics(
            label: _text(context, 'Icon color', 'Цвет иконки'),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tone in _GroupTone.values)
                  _choice(
                    key: ValueKey('group-tone-${tone.name}'),
                    label: _text(context, tone.en, tone.ru),
                    selected: widget.image.isEmpty && tone == widget.tone,
                    onPressed: widget.image.isEmpty
                        ? () => widget.onChanged(widget.icon, const [], tone)
                        : null,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color:
                            tone.tint ?? WantTheme.of(context).color('primary'),
                        shape: BoxShape.circle,
                      ),
                      child: const SizedBox.square(dimension: 15),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _choice({
    required Key key,
    required String label,
    required bool selected,
    required VoidCallback? onPressed,
    required Widget child,
  }) => Semantics(
    selected: selected,
    child: WantTooltip(
      message: label,
      child: SizedBox.square(
        dimension: 44,
        child: WantButton(
          key: key,
          size: WantButtonSize.icon,
          variant: selected
              ? WantButtonVariant.secondary
              : WantButtonVariant.ghost,
          semanticsLabel: label,
          onPressed: widget.enabled && !_selecting ? onPressed : null,
          child: child,
        ),
      ),
    ),
  );
}
