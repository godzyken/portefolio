import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:portefolio/core/provider/provider_extentions.dart';
import 'package:portefolio/core/service/unified_image_manager.dart';
import 'package:portefolio/core/ui/ui_widgets_extentions.dart';

import '../../../../core/config/image_preload_config.dart';
import '../../../../core/routes/router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _initializeApp();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      final manager = ref.read(unifiedImageManagerProvider);

      // 1. Initialiser le manager (scan du manifest)
      await manager.initialize(config: createLocalImageConfiguration(context));

      // 2. Définir ce qu'on attend ABSOLUMENT avant de partir
      // On ne veut peut-être pas attendre les 300 images, juste les critiques
      final criticalImages = ImagePreloadConfig.allImagesToPreload
          .where((img) => img.strategy == PreloadStrategy.critical)
          .toList();

      if (criticalImages.isNotEmpty) {
        await manager.preloadWithPriorities(criticalImages, context: context);
      }

      // 3. Petit délai de courtoisie pour l'animation
      await Future.delayed(const Duration(milliseconds: 1000));

      // 4. Redirection sécurisée
      if (mounted) {
        ref.read(goRouterProvider).go('/');
      }
    } catch (e) {
      debugPrint('❌ Erreur splash: $e');
      // En cas d'erreur, on part quand même à l'accueil pour ne pas bloquer l'utilisateur
      if (mounted) ref.read(goRouterProvider).go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(imageCacheStatsProvider);
    final precacheState = ref.watch(precacheNotifierProvider);

    precacheState.whenData((_) async {
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        final router = ref.read(goRouterProvider);
        router.go('/');
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          // Background gradient animé
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
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
              );
            },
          ),

          // Contenu central
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo avec animation
                AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00D9FF)
                                    .withValues(alpha: 0.4),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/entreprises/logo_godzyken.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stack) =>
                                  const Icon(Icons.person, size: 50),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // Titres
                _buildAnimatedText('Godzyken', isTitle: true),
                const SizedBox(height: 12),
                _buildAnimatedText('Portfolio', isTitle: false),

                const SizedBox(height: 60),

                // Indicateur de chargement custom
                RepaintBoundary(
                  child: CustomPaint(
                    size: const Size(80, 80),
                    painter: _LoadingPainter(
                      progress: stats.loadProgress,
                      color: const Color(0xFF00D9FF),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Texte de chargement
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      ResponsiveText.bodySmall(
                        '${(stats.loadProgress * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Color(0xFF00D9FF),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ResponsiveText.bodySmall(
                        'Chargement des ressources...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Version en bas
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: const _AppVersionText(),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedText(String text, {required bool isTitle}) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) =>
          Opacity(opacity: _fadeAnimation.value, child: child),
      child: isTitle
          ? ResponsiveText.displaySmall(text,
              style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2))
          : ResponsiveText.titleMedium(text,
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.6),
                  letterSpacing: 1)),
    );
  }
}

/// Widget pour afficher la version de l'app de manière dynamique
class _AppVersionText extends StatelessWidget {
  const _AppVersionText();

  Future<String> _getAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return 'v${packageInfo.version}';
    } catch (e) {
      return 'v1.0.0'; // Fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getAppVersion(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        return ResponsiveText.bodySmall(
          snapshot.data!,
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

/// Custom painter pour l'indicateur de chargement (légèrement optimisé)
class _LoadingPainter extends CustomPainter {
  final double progress;
  final Color color;

  final Paint _backgroundPaint;
  final Paint _progressPaint;
  final Paint _pointPaint;
  final Paint _glowPaint;

  _LoadingPainter({required this.progress, required this.color})
      : _backgroundPaint = Paint()
          ..color = color.withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
        _progressPaint = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
        _pointPaint = Paint()
          ..color = color
          ..style = PaintingStyle.fill,
        _glowPaint = Paint()
          ..color = color.withValues(alpha: 0.3)
          ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Cercle de fond
    canvas.drawCircle(center, radius, _backgroundPaint);

    // Arc de progression
    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Démarrer en haut
      sweepAngle,
      false,
      _progressPaint,
    );

    // Point lumineux
    final angle = -math.pi / 2 + sweepAngle;
    final pointOffset = Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );

    // Glow du point
    canvas.drawCircle(pointOffset, 10, _glowPaint);
    // Point lui-même
    canvas.drawCircle(pointOffset, 6, _pointPaint);
  }

  @override
  bool shouldRepaint(_LoadingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
