import 'dart:math' as math;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:want_allure/want_allure.dart';

final class VaultIdleCountdown extends StatefulWidget {
  final Duration Function() remaining;
  const VaultIdleCountdown({super.key, required this.remaining});
  @override
  State<VaultIdleCountdown> createState() => _VaultIdleCountdownState();
}

final class _VaultIdleCountdownState extends State<VaultIdleCountdown>
    with WidgetsBindingObserver {
  Timer? _timer;
  bool _active = true;
  void _sync() {
    _timer?.cancel();
    if (_active && TickerMode.valuesOf(context).enabled) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _active =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _active = state == AppLifecycleState.resumed;
    if (mounted) setState(_sync);
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.remaining();
    final seconds = ((remaining.inMilliseconds + 999) ~/ 1000).clamp(0, 300);
    final label = Localizations.localeOf(context).languageCode == 'ru'
        ? 'До блокировки'
        : 'Until lock';
    return Center(
      child: SizedBox(
        width: 160,
        child: Column(
          spacing: 8,
          children: [
            Semantics(
              label:
                  '$label: ${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}',
              child: ExcludeSemantics(
                child: WantTypography(
                  '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}',
                  variant: WantTypographyVariant.h3,
                ),
              ),
            ),
            WantProgress(
              label: label,
              value: remaining.inMilliseconds.toDouble(),
              max: const Duration(minutes: 5).inMilliseconds.toDouble(),
            ),
          ],
        ),
      ),
    );
  }
}

final class VaultSafeDial extends StatefulWidget {
  final bool opened;
  final Duration Function() remaining;
  final String label;
  final VoidCallback? onPressed;
  const VaultSafeDial({
    super.key,
    required this.opened,
    required this.remaining,
    required this.label,
    required this.onPressed,
  });
  @override
  State<VaultSafeDial> createState() => _VaultSafeDialState();
}

final class _VaultSafeDialState extends State<VaultSafeDial>
    with SingleTickerProviderStateMixin {
  late final _frames = AnimationController(
    vsync: this,
    duration: const Duration(minutes: 5),
  );
  void _motion() {
    if (widget.opened && !WantTheme.reducedMotionOf(context)) {
      if (!_frames.isAnimating) _frames.repeat();
    } else {
      _frames.stop();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _motion();
  }

  @override
  void didUpdateWidget(VaultSafeDial oldWidget) {
    super.didUpdateWidget(oldWidget);
    _motion();
  }

  @override
  void dispose() {
    _frames.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: widget.label,
    button: true,
    toggled: widget.opened,
    child: WantTooltip(
      message: widget.label,
      child: SizedBox.square(
        dimension: 196,
        child: WantGlow(
          borderRadius: BorderRadius.circular(999),
          paused: widget.onPressed == null,
          child: WantButton(
            onPressed: widget.onPressed,
            variant: WantButtonVariant.secondary,
            child: ExcludeSemantics(
              child: AnimatedBuilder(
                animation: _frames,
                builder: (context, _) {
                  final fraction = widget.opened
                      ? (WantTheme.reducedMotionOf(context)
                            ? 1.0
                            : (widget.remaining().inMicroseconds /
                                      const Duration(minutes: 5).inMicroseconds)
                                  .clamp(0.0, 1.0))
                      : 0.0;
                  return CustomPaint(
                    size: const Size(160, 160),
                    painter: _DialPainter(
                      fraction,
                      WantTheme.of(context).color('primary'),
                      WantTheme.of(context).color('foreground'),
                      WantTheme.of(context).color('muted-foreground'),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

final class _DialPainter extends CustomPainter {
  final double fraction;
  final Color primary, ink, muted;
  const _DialPainter(this.fraction, this.primary, this.ink, this.muted);
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = muted;
    canvas.drawCircle(center, 76, line);
    for (var i = 0; i < 24; i++) {
      final angle = i * math.pi / 12;
      canvas.drawLine(
        center + Offset(math.sin(angle), math.cos(angle)) * 66,
        center +
            Offset(math.sin(angle), math.cos(angle)) * (i % 3 == 0 ? 56 : 61),
        line..strokeWidth = 2,
      );
    }
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: 76),
      -math.pi / 2,
      math.pi * 2 * fraction,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..color = primary,
    );
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-fraction * math.pi / 2);
    final spoke = Paint()
      ..color = ink
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final angle = i * math.pi * 2 / 3;
      canvas.drawLine(
        Offset.zero,
        Offset(math.sin(angle), math.cos(angle)) * 39,
        spoke,
      );
    }
    canvas.drawCircle(Offset.zero, 15, Paint()..color = primary);
    canvas.restore();
    canvas.drawCircle(center, 4, Paint()..color = ink);
  }

  @override
  bool shouldRepaint(_DialPainter old) =>
      fraction != old.fraction ||
      primary != old.primary ||
      ink != old.ink ||
      muted != old.muted;
}
