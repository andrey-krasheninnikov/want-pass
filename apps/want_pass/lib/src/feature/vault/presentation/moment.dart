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
        ? Duration(milliseconds: widget.startup ? 1200 : 900)
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
          child: widget.startup
              ? title
              : Semantics(
                  liveRegion: true,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 12,
                    children: [
                      ExcludeSemantics(
                        child: Icon(
                          Icons.check_circle_outline,
                          color: theme.color('success'),
                          size: 56,
                        ),
                      ),
                      title,
                    ],
                  ),
                ),
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
            final reveal = _phase(t, 0, .34);
            final exit = 1 - _phase(t, .62, 1);
            return Center(
              child: Opacity(
                opacity: _motion ? reveal * exit : 1,
                child: Transform.scale(
                  scale: _motion ? .94 + reveal * .06 : 1,
                  child: child,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
