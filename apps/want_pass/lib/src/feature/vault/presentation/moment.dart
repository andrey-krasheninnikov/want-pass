import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:want_allure/want_allure.dart';

const vaultSplashLogo = ResizeImage(
  AssetImage('assets/brand/logo-dark.png'),
  width: 480,
);

final class VaultMoment extends StatefulWidget {
  final bool startup;
  final String title;
  final VoidCallback onComplete;

  const VaultMoment({
    super.key,
    required this.startup,
    required this.title,
    required this.onComplete,
  });

  @override
  State<VaultMoment> createState() => _VaultMomentState();
}

final class _VaultMomentState extends State<VaultMoment>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _progress;
  AppLifecycleState? _lifecycle;
  bool _motion = true, _tickerEnabled = true;

  @override
  void initState() {
    super.initState();
    final binding = WidgetsBinding.instance;
    _lifecycle = binding.lifecycleState;
    binding.addObserver(this);
    _progress = AnimationController(vsync: this)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) widget.onComplete();
          });
        }
      });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _motion = !WantTheme.reducedMotionOf(context);
    _tickerEnabled = TickerMode.valuesOf(context).enabled;
    _sync();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycle = state;
    _sync();
  }

  void _sync() {
    if (_progress.isCompleted) return;
    if (!_tickerEnabled ||
        (_lifecycle != null && _lifecycle != AppLifecycleState.resumed)) {
      _progress.stop();
      return;
    }
    _progress.duration = _motion
        ? Duration(milliseconds: widget.startup ? 1200 : 1400)
        : Duration(milliseconds: widget.startup ? 0 : 400);
    _progress.forward();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _progress.dispose();
    super.dispose();
  }

  double _phase(double progress, double begin, double end) => Curves
      .easeInOutCubic
      .transform(((progress - begin) / (end - begin)).clamp(0, 1).toDouble());

  @override
  Widget build(BuildContext context) {
    final theme = WantTheme.of(context);
    const logo = Image(
      image: vaultSplashLogo,
      width: 160,
      height: 160,
      excludeFromSemantics: true,
    );
    final title = WantTypography(
      widget.title,
      variant: WantTypographyVariant.h3,
    );
    final waveVisible = _motion && !MediaQuery.highContrastOf(context);
    return ColoredBox(
      color: theme.color('background'),
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _progress,
          child: title,
          builder: (context, child) {
            final t = _progress.value;
            if (widget.startup) {
              final wave = _phase(t, .03, .92);
              final waveOpacity =
                  _phase(t, .04, .24) * (1 - _phase(t, .24, .90)) * .23;
              final wordmark = _phase(t, .16, .43) * (1 - _phase(t, .65, .92));
              return Stack(
                fit: StackFit.expand,
                children: [
                  if (waveVisible && waveOpacity > 0)
                    Center(
                      child: Opacity(
                        opacity: waveOpacity,
                        child: Transform.scale(
                          scale: 1 + wave * 2.6,
                          child: logo,
                        ),
                      ),
                    ),
                  Center(
                    child: Opacity(
                      opacity: _motion ? 1 - _phase(t, .78, 1) : 1,
                      child: logo,
                    ),
                  ),
                  if (_motion)
                    Center(
                      child: Transform.translate(
                        offset: const Offset(0, 106),
                        child: Opacity(opacity: wordmark, child: child),
                      ),
                    ),
                ],
              );
            }
            final exit = _motion ? 1 - _phase(t, .81, 1) : 1.0;
            final color = theme.color(
              MediaQuery.highContrastOf(context)
                  ? 'foreground'
                  : 'success-text',
            );
            return Center(
              child: Opacity(
                opacity: exit,
                child: Semantics(
                  liveRegion: true,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 4,
                    children: [
                      ExcludeSemantics(
                        child: CustomPaint(
                          size: const Size.square(108),
                          painter: _VaultCreatedPainter(
                            color: color,
                            outline: _motion ? _phase(t, 0, .34) : 1,
                            check: _motion ? _phase(t, .20, .49) : 1,
                            burst: waveVisible ? _phase(t, .40, .73) : 0,
                          ),
                        ),
                      ),
                      Opacity(
                        opacity: _motion ? _phase(t, .36, .58) : 1,
                        child: child,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

final class _VaultCreatedPainter extends CustomPainter {
  final Color color;
  final double outline, check, burst;
  const _VaultCreatedPainter({
    required this.color,
    required this.outline,
    required this.check,
    required this.burst,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: 27),
      -math.pi / 2,
      2 * math.pi * outline,
      false,
      paint,
    );
    final tick = Path()
      ..moveTo(center.dx - 12, center.dy)
      ..lineTo(center.dx - 4, center.dy + 8)
      ..lineTo(center.dx + 13, center.dy - 9);
    final stroke = tick.computeMetrics().first;
    canvas.drawPath(stroke.extractPath(0, stroke.length * check), paint);
    if (burst > 0 && burst < 1) {
      paint
        ..style = PaintingStyle.fill
        ..color = color.withValues(alpha: math.sin(math.pi * burst) * .55);
      for (var i = 0; i < 6; i++) {
        final theta = (i + .5) * math.pi / 3;
        final offset =
            Offset(math.cos(theta), math.sin(theta)) * (31 + burst * 17);
        final pixel = center + offset;
        canvas.drawRect(
          Rect.fromCenter(center: pixel, width: 3, height: 3),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_VaultCreatedPainter oldDelegate) =>
      color != oldDelegate.color ||
      outline != oldDelegate.outline ||
      check != oldDelegate.check ||
      burst != oldDelegate.burst;
}
