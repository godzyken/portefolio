import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/provider/unified_image_provider.dart';
import '../../../../core/ui/widgets/responsive_text.dart';
import '../../controller/splash_state.dart';
import '../../provider/splash_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  final Widget? logo;
  final Color? backgroundColor;
  final String targetRoute;

  const SplashScreen({
    super.key,
    this.logo,
    this.backgroundColor,
    this.targetRoute = '/',
  });

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // ✅ On lance le précache mais on NE passe plus le context au notifier
      ref.read(splashProvider.notifier).start();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final splashState = ref.watch(splashProvider);
    final stats = ref.watch(imageCacheStatsProvider);

    // ✅ Navigation gérée ICI dans le widget, pas dans le notifier
    ref.listen<SplashState>(splashProvider, (previous, next) {
      if (next.phase == SplashPhase.ready && mounted) {
        context.go(widget.targetRoute);
      }
    });

    final double progress = splashState.progress > 0
        ? splashState.progress
        : (stats.totalAssets > 0
            ? ((stats.totalLoaded + stats.failed) / stats.totalAssets)
                .clamp(0.0, 1.0)
            : 0.0);

    final bool isInitializing =
        splashState.phase == SplashPhase.idle || stats.totalAssets == 0;
    final bool isFinished = splashState.isReady || progress >= 1.0;

    final bg = widget.backgroundColor ?? Theme.of(context).colorScheme.surface;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0 + (_controller.value * 0.2),
                  colors: [
                    const Color(0xFF00D9FF).withValues(alpha: 0.15),
                    const Color(0xFF0A0A0A),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLogo(),
                const SizedBox(height: 40),
                _buildAnimatedText('Godzyken', isTitle: true),
                const SizedBox(height: 12),
                _buildAnimatedText('Portfolio', isTitle: false),
                const SizedBox(height: 60),
                RepaintBoundary(
                  child: splashState.hasError
                      ? _buildError(splashState)
                      : _buildCircularProgress(progress, isFinished),
                ),
                const SizedBox(height: 24),
                _buildStatusText(splashState, progress, isInitializing),
              ],
            ),
          ),
          const Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: _AppVersionText(),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: FadeTransition(opacity: _fadeAnimation, child: child),
      ),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00D9FF).withValues(alpha: 0.4),
              blurRadius: 40,
              spreadRadius: 10,
            ),
          ],
        ),
        child: ClipOval(
          child: widget.logo ??
              Image.asset(
                'assets/images/entreprises/logo_godzyken.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.person, size: 50, color: Colors.white),
              ),
        ),
      ),
    );
  }

  Widget _buildAnimatedText(String text, {required bool isTitle}) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (_, child) =>
          Opacity(opacity: _fadeAnimation.value, child: child),
      child: isTitle
          ? ResponsiveText.displaySmall(
              text,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            )
          : ResponsiveText.titleMedium(
              text,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.6),
                letterSpacing: 1,
              ),
            ),
    );
  }

  Widget _buildCircularProgress(double progress, bool isFinished) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedScale(
          scale: isFinished ? 1.2 : 1.0,
          duration: const Duration(milliseconds: 500),
          child: CustomPaint(
            size: const Size(80, 80),
            painter: _LoadingPainter(
              progress: progress,
              color: const Color(0xFF00D9FF),
            ),
          ),
        ),
        if (isFinished) ...[
          const SizedBox(height: 8),
          const ResponsiveText.bodyMedium(
            "C'est prêt !",
            style: TextStyle(color: Colors.greenAccent),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusText(
    SplashState state,
    double progress,
    bool isInitializing,
  ) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          ResponsiveText.bodySmall(
            isInitializing
                ? 'Initialisation...'
                : '${(progress * 100).toInt()}%',
            style: const TextStyle(
              color: Color(0xFF00D9FF),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              key: ValueKey(state.statusMessage),
              state.statusMessage.isNotEmpty
                  ? state.statusMessage
                  : 'Chargement des ressources...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(SplashState state) {
    return Column(
      key: const ValueKey('error'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
        const SizedBox(height: 12),
        Text(
          state.statusMessage,
          style: const TextStyle(color: Colors.redAccent),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: () => ref.read(splashProvider.notifier).start(),
          icon: const Icon(Icons.refresh),
          label: const Text('Réessayer'),
        ),
      ],
    );
  }
}

// ── AppVersionText ────────────────────────────────────────────────────────────

class _AppVersionText extends StatelessWidget {
  const _AppVersionText();

  Future<String> _getVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return 'v${info.version}';
    } catch (_) {
      return 'v1.0.0';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getVersion(),
      builder: (_, snap) {
        if (!snap.hasData) return const SizedBox.shrink();
        return ResponsiveText.bodySmall(
          snap.data!,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.3),
          ),
        );
      },
    );
  }
}

// ── LoadingPainter ────────────────────────────────────────────────────────────

class _LoadingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _LoadingPainter({required this.progress, required this.color});

  late final _bgPaint = Paint()
    ..color = color.withValues(alpha: 0.1)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  late final _progressPaint = Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4
    ..strokeCap = StrokeCap.round;

  late final _glowPaint = Paint()
    ..color = color.withValues(alpha: 0.2)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    final clampedProgress = progress.clamp(0.0, 1.0);
    final sweepAngle = 2 * math.pi * clampedProgress;

    canvas.drawCircle(center, radius, _bgPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      _progressPaint,
    );

    if (clampedProgress > 0) {
      final angle = -math.pi / 2 + sweepAngle;
      final tip = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawCircle(tip, 6, _glowPaint);
      canvas.drawCircle(tip, 3, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_LoadingPainter old) => old.progress != progress;
}
