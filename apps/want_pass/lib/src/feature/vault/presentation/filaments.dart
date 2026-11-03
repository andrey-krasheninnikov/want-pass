import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter/scheduler.dart';
import 'package:want_allure/want_allure.dart';

final class VaultFilaments extends StatefulWidget {
  final Widget child;
  const VaultFilaments({super.key, required this.child});
  @override
  State<VaultFilaments> createState() => _VaultFilamentsState();
}

final class _VaultFilamentsState extends State<VaultFilaments>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static Future<ui.FragmentProgram>? _program;
  final _time = ValueNotifier<double>(0);
  late final Ticker _ticker;
  ui.FragmentShader? _shader;
  Offset _pointer = Offset.zero;
  double _base = 0, _lastPaint = 0;
  bool _active = true;
  @override
  void initState() {
    super.initState();
    _active =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    WidgetsBinding.instance.addObserver(this);
    _ticker = createTicker((elapsed) {
      final now = elapsed.inMicroseconds / 1000000;
      if (now - _lastPaint < 1 / 30) return;
      _lastPaint = now;
      _time.value = _base + now;
    });
    _load();
  }

  Future<void> _load() async {
    try {
      final program = await (_program ??= ui.FragmentProgram.fromAsset(
        'shaders/filaments.frag',
      ));
      if (mounted) setState(() => _shader = program.fragmentShader());
    } on Object {
      _program = null;
    }
  }

  void _sync() {
    final running =
        _active &&
        TickerMode.valuesOf(context).enabled &&
        !WantTheme.reducedMotionOf(context) &&
        !MediaQuery.highContrastOf(context);
    if (running && !_ticker.isActive) {
      _base = _time.value;
      _lastPaint = 0;
      _ticker.start();
    } else if (!running && _ticker.isActive) {
      _ticker.stop();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _active = state == AppLifecycleState.resumed;
    _sync();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    _time.dispose();
    _shader?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = WantTheme.of(context);
    final decoration = MediaQuery.highContrastOf(context)
        ? const SizedBox.expand()
        : RepaintBoundary(
            child: ExcludeSemantics(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _FilamentPainter(
                    time: _time,
                    shader: _shader,
                    background: theme.color('background'),
                    line: theme.color('primary'),
                    pointer: () => _pointer,
                  ),
                ),
              ),
            ),
          );
    return LayoutBuilder(
      builder: (context, box) => Listener(
        onPointerHover: (event) {
          if (_ticker.isActive && box.maxWidth > 0 && box.maxHeight > 0) {
            _pointer = Offset(
              (event.localPosition.dx / box.maxWidth - .5).clamp(-.5, .5),
              (event.localPosition.dy / box.maxHeight - .5).clamp(-.5, .5),
            );
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [decoration, widget.child],
        ),
      ),
    );
  }
}

final class _FilamentPainter extends CustomPainter {
  final ValueNotifier<double> time;
  final ui.FragmentShader? shader;
  final Color background, line;
  final Offset Function() pointer;
  _FilamentPainter({
    required this.time,
    required this.shader,
    required this.background,
    required this.line,
    required this.pointer,
  }) : super(repaint: time);
  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final shader = this.shader;
    if (shader != null) {
      final point = pointer();
      final values = [
        size.width,
        size.height,
        time.value,
        point.dx,
        point.dy,
        background.r,
        background.g,
        background.b,
        background.a,
        line.r,
        line.g,
        line.b,
        line.a,
      ];
      for (var i = 0; i < values.length; i++) {
        shader.setFloat(i, values[i]);
      }
      canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
    } else {
      canvas.drawRect(Offset.zero & size, Paint()..color = background);
      for (var strand = 0; strand < 10; strand++) {
        final path = Path();
        for (var step = 0; step <= 60; step++) {
          final x = step / 60;
          final y =
              .16 +
              strand * .071 +
              math.sin(x * 4.5 + strand * .46) * .15 +
              math.sin(x * 9 - strand * .21) * .026;
          step == 0
              ? path.moveTo(x * size.width, y * size.height)
              : path.lineTo(x * size.width, y * size.height);
        }
        canvas.drawPath(
          path,
          Paint()
            ..color = line.withValues(alpha: .16)
            ..style = PaintingStyle.stroke
            ..strokeWidth = .7 + strand % 3 * .25,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FilamentPainter old) =>
      old.shader != shader || old.background != background || old.line != line;
}
