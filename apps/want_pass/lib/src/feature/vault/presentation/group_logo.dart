import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:want_allure/want_allure.dart';

final class VaultGroupLogo extends StatefulWidget {
  final String icon;
  final List<int> bytes;
  const VaultGroupLogo({super.key, required this.icon, this.bytes = const []});
  @override
  State<VaultGroupLogo> createState() => _VaultGroupLogoState();
}

final class _VaultGroupLogoState extends State<VaultGroupLogo> {
  ui.Image? _image;
  int _epoch = 0;
  @override
  void initState() {
    super.initState();
    _decode();
  }

  @override
  void didUpdateWidget(VaultGroupLogo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.bytes, widget.bytes)) _decode();
  }

  Future<void> _decode() async {
    final epoch = ++_epoch;
    _image?.dispose();
    _image = null;
    if (widget.bytes.isEmpty) return;
    try {
      final codec = await ui.instantiateImageCodec(
        Uint8List.fromList(widget.bytes),
        targetWidth: 64,
        allowUpscaling: false,
      );
      try {
        final image = (await codec.getNextFrame()).image;
        if (!mounted || epoch != _epoch) {
          image.dispose();
          return;
        }
        setState(() => _image = image);
      } finally {
        codec.dispose();
      }
    } on Object {
      /* A malformed image keeps the selected built-in icon. */
    }
  }

  @override
  void dispose() {
    _epoch++;
    _image?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox.square(
      dimension: 36,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: _image == null
            ? Icon(switch (widget.icon) {
                'building' => Icons.business_outlined,
                'briefcase' => Icons.work_outline,
                'code' => Icons.code,
                'home' => Icons.home_outlined,
                'key' => Icons.key_outlined,
                _ => Icons.folder_outlined,
              }, color: WantTheme.of(context).color('primary'))
            : RawImage(image: _image, fit: BoxFit.contain),
      ),
    ),
  );
}
