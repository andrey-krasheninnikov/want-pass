import 'package:flutter/material.dart';
import 'package:want_allure/want_allure.dart';

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
        ? Duration(milliseconds: widget.startup ? 950 : 820)
        : Duration(milliseconds: widget.startup ? 0 : 400);
    _progress.forward();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = WantTheme.of(context);
    return ColoredBox(
      color: theme.color('background'),
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _progress,
          builder: (context, _) {
            final t = _motion ? _progress.value : 1.0;
            final reveal = Curves.easeOutCubic.transform(
              (t / .28).clamp(0, 1).toDouble(),
            );
            final fade = (1 - ((t - .67) / .33).clamp(0, 1)).toDouble();
            if (widget.startup) {
              const asset = 'assets/brand/logo-dark.png';
              final wave = Curves.easeOutCubic.transform(t);
              return Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: [
                  if (_motion && !MediaQuery.highContrastOf(context))
                    Center(
                      child: Opacity(
                        opacity: .34 * (1 - wave),
                        child: Transform.scale(
                          scale: 1 + wave * 4.6,
                          child: Image.asset(
                            asset,
                            width: 160,
                            height: 160,
                            excludeFromSemantics: true,
                          ),
                        ),
                      ),
                    ),
                  Center(
                    child: Image.asset(
                      asset,
                      width: 160,
                      height: 160,
                      excludeFromSemantics: true,
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Transform.translate(
                      offset: Offset(0, 106 + (1 - reveal) * 6),
                      child: Opacity(
                        opacity: reveal * fade,
                        child: WantTypography(
                          widget.title,
                          variant: WantTypographyVariant.h3,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            return Center(
              child: Semantics(
                liveRegion: true,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 12,
                  children: [
                    ExcludeSemantics(
                      child: Transform.scale(
                        scale: .82 + reveal * .18,
                        child: Icon(
                          Icons.check_circle_outline,
                          color: theme.color('success'),
                          size: 56,
                        ),
                      ),
                    ),
                    WantTypography(
                      widget.title,
                      variant: WantTypographyVariant.h3,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
