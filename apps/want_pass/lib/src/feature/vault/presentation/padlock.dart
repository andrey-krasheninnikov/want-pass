import 'dart:math' as math;

import 'package:ditredi/ditredi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    duration: const Duration(milliseconds: 240),
  );
  final _camera = DiTreDiController(
    rotationX: 8,
    rotationY: -20,
    lightStrength: .7,
    ambientLightStrength: .65,
  );
  final _hinge = Matrix4.identity();
  late final Future<Widget> _scene;
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
    _opening.addListener(_poseShackle);
    _poseShackle();
    _scene = _loadScene();
  }

  Future<Widget> _loadScene() async {
    final models = await Future.wait([
      ObjParser().loadFromResources('assets/brand/lock-body.obj'),
      ObjParser().loadFromResources('assets/brand/lock-shackle.obj'),
    ]);
    return RepaintBoundary(
      child: DiTreDi(
        figures: [
          Group3D(models[0]),
          TransformModifier3D(Group3D(models[1]), _hinge),
        ],
        controller: _camera,
      ),
    );
  }

  void _poseShackle() {
    final value = _opening.value;
    _hinge
      ..setIdentity()
      ..translateByDouble(-.375, .1875 + value / 12, 0, 1)
      ..rotateZ(value * 25 * math.pi / 180)
      ..translateByDouble(.375, -.1875, 0, 1);
    _camera.update();
  }

  void _rotate(double degrees) {
    _camera.update(rotationY: (_camera.rotationY + degrees) % 360);
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
    _camera.dispose();
    super.dispose();
  }

  void _tap() {
    if (_motion) _press.forward(from: 0);
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = WantTheme.of(context);
    final ru = Localizations.localeOf(context).languageCode == 'ru';
    return Semantics(
      hint: ru
          ? 'Перетаскивайте влево и вправо или используйте стрелки для вращения.'
          : 'Drag left and right or use the arrow keys to rotate.',
      child: SizedBox.square(
        dimension: 64,
        child: Focus(
          canRequestFocus: false,
          onKeyEvent: (_, event) {
            if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
              return KeyEventResult.ignored;
            }
            if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              _rotate(-15);
            } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              _rotate(15);
            } else {
              return KeyEventResult.ignored;
            }
            return KeyEventResult.handled;
          },
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
              child: MouseRegion(
                cursor: SystemMouseCursors.grab,
                child: GestureDetector(
                  onHorizontalDragUpdate: (event) =>
                      _rotate(event.delta.dx * .6),
                  child: FutureBuilder<Widget>(
                    future: _scene,
                    builder: (context, snapshot) =>
                        snapshot.data ??
                        Icon(
                          widget.opened
                              ? Icons.lock_open_outlined
                              : Icons.lock_outline,
                          color: theme.color('primary'),
                        ),
                  ),
                ),
              ),
              builder: (context, child) => Transform.rotate(
                angle: math.pow(math.sin(_press.value * math.pi), 2) * .045,
                child: SizedBox.square(dimension: 44, child: child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
