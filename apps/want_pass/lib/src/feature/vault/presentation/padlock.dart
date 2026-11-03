import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:want_allure/want_allure.dart';

final class VaultPadlock extends StatefulWidget {
  final bool opened;
  final String label;
  final VoidCallback? onPressed;
  const VaultPadlock({
    super.key,
    required this.opened,
    required this.label,
    this.onPressed,
  });
  @override
  State<VaultPadlock> createState() => _VaultPadlockState();
}

final class _VaultPadlockState extends State<VaultPadlock>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final _opening = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
    value: widget.opened ? 1 : 0,
  );
  late final _press = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 100),
  );
  bool _active = true;
  bool get _motion =>
      _active &&
      TickerMode.valuesOf(context).enabled &&
      !WantTheme.reducedMotionOf(context);
  @override
  void initState() {
    super.initState();
    _active =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didUpdateWidget(covariant VaultPadlock old) {
    super.didUpdateWidget(old);
    if (old.opened != widget.opened) {
      final target = widget.opened ? 1.0 : 0.0;
      if (_motion) {
        _opening.animateTo(target, curve: Curves.easeInOutCubic);
      } else {
        _opening.value = target;
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _active = state == AppLifecycleState.resumed;
    if (!_active) {
      _opening.stop();
      _press.stop();
      _press.value = 0;
      _opening.value = widget.opened ? 1 : 0;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_motion) {
      _opening.value = widget.opened ? 1 : 0;
      _press.value = 0;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _opening.dispose();
    _press.dispose();
    super.dispose();
  }

  void _tap() {
    if (_motion) {
      _press.forward(from: 0).then((_) {
        if (mounted) _press.reverse();
      });
    }
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final color = WantTheme.of(context)
        .color(widget.opened ? 'success' : 'warning');
    final ru = Localizations.localeOf(context).languageCode == 'ru';
    return Semantics(
      hint: ru
          ? 'Перетаскивайте влево и вправо или используйте стрелки для вращения.'
          : 'Drag left and right or use the arrow keys to rotate.',
      child: SizedBox.square(
        dimension: 64,
        child: FButton.icon(
          variant: FButtonVariant.ghost,
          style: FButtonStyleDelta.delta(
            decoration: FVariants.from(const BoxDecoration(), variants: {}),
            tappableStyle: const FTappableStyleDelta.delta(
              pressedEnterDuration: Duration.zero,
              pressedExitDuration: Duration.zero,
            ),
          ),
          semanticsLabel: widget.label,
          onPress: widget.onPressed == null ? null : _tap,
          child: AnimatedBuilder(
            animation: Listenable.merge([_opening, _press]),
            builder: (context, _) {
              final opening = _opening.value;
              return Transform.rotate(
                angle: math.sin(_press.value * math.pi) * .08,
                child: SizedBox.square(
                  dimension: 44,
                  child: Stack(
                    children: [
                      if (!MediaQuery.highContrastOf(context))
                        Positioned.fill(
                          child: IgnorePointer(
                            child: AnimatedContainer(
                              duration: _motion
                                  ? const Duration(milliseconds: 420)
                                  : Duration.zero,
                              margin: const EdgeInsets.all(11),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withValues(alpha: .28),
                                    blurRadius: 18,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      Positioned.fill(
                        child: Transform.scale(
                          scale: 1.8,
                          child: WantSvg3D.builder(
                            svgBuilder: (context) async {
                              final svg = await DefaultAssetBundle.of(context)
                                  .loadString('assets/brand/lock.svg');
                              return svg.replaceFirst(
                                'id="shackle"',
                                'id="shackle" transform="translate(0 ${-opening}) rotate(${-25 * opening} 7.5 9.75)"',
                              );
                            },
                            semanticsLabel: ru
                                ? 'Повернуть замок'
                                : 'Rotate lock',
                            depth: .24,
                            autoRotate: false,
                            paused: !_active,
                            glow: false,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
